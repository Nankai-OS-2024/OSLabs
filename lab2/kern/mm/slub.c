#include <slub.h>
#include <list.h>
#include <defs.h>
#include <string.h>
#include <stdio.h>
#include <pmm.h>

// ! 默认值
#define DEFAULT_CTVAL 0x0
#define DEFAULT_DTVAL 0x1
#define SIZED_CACHE_NUM 8
// ! 默认值结束

// ! 工具函数
#define le2slab(le, link) ((struct slab_t *)le2page((struct Page *)le, link))
#define slab2kva(slab) (page2kva((struct Page *)slab))

static inline void *page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
}

static int kmem_sized_index(size_t size)
{
    size_t rsize = ROUNDUP(size, 2);
    int index = 0;
    for (int t = rsize / 32; t; t /= 2)
    {
        index++;
    }
    return index;
}
// ! 工具函数结束

// ! 全局变量
static list_entry_t cache_chain;
static struct kmem_cache_t cache_cache; // 这个cache很特殊，它是包括了所有其它小cache的大cache，全局只有一个
static struct kmem_cache_t *sized_caches[SIZED_CACHE_NUM];
static char *cache_cache_name = "cache";
static char *sized_cache_name = "sized";
// ! 全局变量结束

// ! 函数声明
static void kmem_slab_destroy(struct kmem_cache_t *cachep, struct slab_t *slab);
// ! 函数声明结束

// ! 第一层结构
/* 创建一个kmem_cache */
struct kmem_cache_t *kmem_cache_create(const char *name, size_t size)
{
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
    if (cachep != NULL)
    {
        cachep->objsize = size;                          // 指定这个slab里面存的obj的大小
        cachep->num = PGSIZE / (sizeof(int16_t) + size); // int16_t是空闲链表指针的大小，size是obj的大小
        memcpy(cachep->name, name, CACHE_NAMELEN);
        list_init(&(cachep->slabs_full));
        list_init(&(cachep->slabs_partial));
        list_init(&(cachep->slabs_free));
        list_add(&(cache_chain), &(cachep->cache_link));
    }
    return cachep;
}

/* 销毁kmem_cache_t及其中所有的Slab */
void kmem_cache_destroy(struct kmem_cache_t *cachep)
{
    list_entry_t *head, *le;
    head = &(cachep->slabs_full);
    le = list_next(head);
    while (le != head)
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }
    head = &(cachep->slabs_partial);
    le = list_next(head);
    while (le != head)
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }
    head = &(cachep->slabs_free);
    le = list_next(head);
    while (le != head)
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }
    kmem_cache_free(&(cache_cache), cachep);
}

/* 获得仓库中对象的大小 */
size_t kmem_cache_size(struct kmem_cache_t *cachep)
{
    return cachep->objsize;
}

/* 获得仓库的名称 */
const char *kmem_cache_name(struct kmem_cache_t *cachep)
{
    return cachep->name;
}

/* 找到大小最合适的内置仓库，申请一个对象 */
void *kmalloc(size_t size)
{
    return kmem_cache_alloc(sized_caches[kmem_sized_index(size)]);
}

/* 释放内置仓库对象 */
void kfree(void *objp)
{
    void *base = slab2kva(pages);
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
    kmem_cache_free(slab->cachep, objp);
}

/* 释放仓库的slabs_free链表中所有Slab */
int kmem_cache_shrink(struct kmem_cache_t *cachep)
{
    int count = 0;
    list_entry_t *le = list_next(&(cachep->slabs_free));
    while (le != &(cachep->slabs_free))
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
        count++;
    }
    return count;
}

/* 释放所有的全空闲slab */
int kmem_cache_reap()
{
    int count = 0;
    list_entry_t *le = &(cache_chain);
    while ((le = list_next(le)) != &(cache_chain))
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
    return count;
}
// ! 第一层结构结束

// ! 第二层结构
/* 从pmm_manager中申请一页内存作为完全空闲的slab */
static void *kmem_cache_grow(struct kmem_cache_t *cachep)
{
    struct Page *page = alloc_pages(1);
    cprintf("allocate page for kmem_cache, address: %p\n", page2pa(page));
    void *kva = page2kva(page);
    struct slab_t *slab = (struct slab_t *)page;
    slab->cachep = cachep;
    slab->inuse = slab->free = 0;
    int16_t *bufctl = kva;
    for (int i = 1; i < cachep->num; i++)
    {
        bufctl[i - 1] = i; // 链表结构，初始化时都是空闲，因此都指向自己的下一个元素
    }
    bufctl[cachep->num - 1] = -1;
    void *buf = bufctl + cachep->num;
    // slab下所有的obj全部初始化为DEFAULT_CTVAL
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
    {
        char *objp = (char *)p;
        for (int i = 0; i < cachep->objsize; i++)
        {
            objp[i] = DEFAULT_CTVAL;
        }
    }
    list_add(&(cachep->slabs_free), &(slab->slab_link));
    return slab;
}

/* 释放cachep中的一个slab块对应的页，析构buf中的对象后将page归还 */
static void kmem_slab_destroy(struct kmem_cache_t *cachep, struct slab_t *slab)
{
    struct Page *page = (struct Page *)slab;
    int16_t *bufctl = page2kva(page);
    void *buf = bufctl + cachep->num;
    // slab下所有的obj全部析构为DEFAULT_DTVAL
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
    {
        char *objp = (char *)p;
        for (int i = 0; i < cachep->objsize; i++)
        {

            objp[i] = DEFAULT_DTVAL;
        }
    }
    page->property = page->flags = 0;
    list_del(&(page->page_link));
    free_page(page);
}
// ! 第二层结构结束

// ! 第三层结构
/* 从cachep指向的仓库中分配一个对象，返回指向对象的指针objp */
void *kmem_cache_alloc(struct kmem_cache_t *cachep)
{
    list_entry_t *le = NULL;
    if (!list_empty(&(cachep->slabs_partial)))
    {
        le = list_next(&(cachep->slabs_partial));
    }
    else
    {
        if (list_empty(&(cachep->slabs_free)) && kmem_cache_grow(cachep) == NULL)
        {
            return NULL;
        }
        le = list_next(&(cachep->slabs_free));
    }
    list_del(le);
    struct slab_t *slab = le2slab(le, page_link);
    void *kva = slab2kva(slab);
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
    void *objp = buf + slab->free * cachep->objsize;
    slab->inuse++;
    slab->free = bufctl[slab->free];
    if (slab->inuse == cachep->num)
        list_add(&(cachep->slabs_full), le);
    else
        list_add(&(cachep->slabs_partial), le);
    return objp;
}

/* 将对象objp从cachep中的Slab中释放 */
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp)
{
    void *base = page2kva(pages);
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
    int offset = (objp - buf) / cachep->objsize;
    list_del(&(slab->slab_link));
    bufctl[offset] = slab->free;
    slab->inuse--;
    slab->free = offset;
    if (slab->inuse == 0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
    else
        list_add(&(cachep->slabs_partial), &(slab->slab_link));
}
// ! 第三层结构结束

// ! 测试部分代码
#define TEST_OBJECT_LENTH 1024 // 设置obj结构体的大小为1024，对应存储1024大小obj的cache

static const char *test_object_name = "test";

struct test_object
{
    char test_member[TEST_OBJECT_LENTH];
};

static size_t list_length(list_entry_t *listelm)
{
    size_t len = 0;
    list_entry_t *le = listelm;
    while ((le = list_next(le)) != listelm){
        len++;
    }
    return len;
}

static void check_kmem()
{

    assert(sizeof(struct Page) == sizeof(struct slab_t)); // 页的大小等于slab的大小

    size_t fp = nr_free_pages();

    // 创建一个测试仓库，初始化对象内存空间全为TEST_OBJECT_CTVAL
    // test_object大小为1024字节
    struct kmem_cache_t *cp0 = kmem_cache_create(test_object_name, sizeof(struct test_object));
    assert(cp0 != NULL);                                         // 创建成功
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));  // 对象大小一致
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0); // 名字一样
    struct test_object *p0, *p1, *p2, *p3, *p4, *p5;
    char *p;
    // 在仓库中分配6个对象
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
    assert((p5 = kmem_cache_alloc(cp0)) != NULL);
    p = (char *)p5;
    // 对象的初始值应该都是DEFAULT_CTVAL
    for (int i = 0; i < sizeof(struct test_object); i++)
    {
        assert(p[i] == DEFAULT_CTVAL);
    }
    // 由于刚刚总共分配了6个对象（1024+2），现在应该从pmm_manager取出了2页，因此空闲页数比之前少2
    assert(nr_free_pages() + 2 == fp);
    // 当这2页应当全被占满，都在slabs_full链表中
    assert(list_length(&(cp0->slabs_full)) == 2);
    // 而slabs_partial和slabs_free应该都为空
    assert(list_empty(&(cp0->slabs_partial)) == 1);
    assert(list_empty(&(cp0->slabs_free)) == 1);
    // 释放三个对象，现在slabs_free应当有一块slab
    kmem_cache_free(cp0, p3);
    kmem_cache_free(cp0, p4);
    kmem_cache_free(cp0, p5);
    assert(list_length(&(cp0->slabs_free)) == 1);
    // 释放slabs_free链表中的所有slab
    assert(kmem_cache_shrink(cp0) == 1);    // 一共释放了1个slab
    assert(nr_free_pages() + 1 == fp);      // 现在多了一个空闲页
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
    // p4处的内存被释放，现在对象内存处的值都是析构函数中的DEFAULT_DTVAL
    p = (char *)p4;
    for (int i = 0; i < sizeof(struct test_object); i++){
        assert(p[i] == DEFAULT_DTVAL);
    }
    // 释放对象，现在slabs_free又多了一块slab
    kmem_cache_free(cp0, p0);
    kmem_cache_free(cp0, p1);
    kmem_cache_free(cp0, p2);
    // 释放所有全空闲slab，共释放1个
    assert(kmem_cache_reap() == 1);
    // 现在页全部空闲了
    assert(nr_free_pages() == fp);
    // 释放仓库
    kmem_cache_destroy(cp0);

    // 在内置仓库中申请内存
    assert((p0 = kmalloc(1024)) != NULL);
    // 空闲页少1
    assert(nr_free_pages() + 1 == fp);
    // 在内置仓库中释放对象
    kfree(p0);
    // 释放后，多出一个全空闲slab，释放掉
    assert(kmem_cache_reap() == 1);
    // 空闲页复原
    assert(nr_free_pages() == fp);

    cputs("check_kmem() succeeded, all test passed!\n");
}
// ! 测试部分代码结束

void kmem_init()
{
    // 1. 初始化kmem_cache的cache仓库，简称为cache_cache
    cache_cache.objsize = sizeof(struct kmem_cache_t);
    cache_cache.num = PGSIZE / (sizeof(int16_t) + sizeof(struct kmem_cache_t)); // 算num的时候还要考虑前面int16_t的信息
    memcpy(cache_cache.name, cache_cache_name, CACHE_NAMELEN);

    // 初始化cache_cache的链表
    list_init(&(cache_cache.slabs_full));
    list_init(&(cache_cache.slabs_partial));
    list_init(&(cache_cache.slabs_free));

    // 初始化cache_chain（这个链表会串起来所有的kmem_cache_t）
    list_init(&(cache_chain));
    // 将第一个kmem_cache_t也就是cache_cache加入到cache_chain对应的链表中
    list_add(&(cache_chain), &(cache_cache.cache_link));

    // 2. 初始化8个固定大小的内置仓库
    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2){
        sized_caches[i] = kmem_cache_create(sized_cache_name, size);
    }

    // 3. 进行测试
    check_kmem();
}