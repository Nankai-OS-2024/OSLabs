#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static size_t total_size;          
static size_t full_tree_size;     
static size_t record_area_size;    
static size_t real_tree_size;      
static size_t *record_area;        
static struct Page *physical_area; 
static struct Page *allocate_area; 

//求余数
#define OR_SHIFT_RIGHT(a, n) ((a) | ((a) >> (n)))
#define ALL_BIT_TO_ONE(a) (OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(a, 1), 2), 4), 8), 16))
#define POWER_REMAINDER(a) ((a) & (ALL_BIT_TO_ONE(a) >> 1))

// 获取节点的余数
static inline size_t power_remainder(size_t a) {
    return a & (ALL_BIT_TO_ONE(a) >> 1);
}

// 判断是否为2的幂次
static inline bool is_power_of_2(size_t a) {
    return (a & (a - 1)) == 0;
}

// 返回最近的2的幂次向上取整
static inline size_t power_round_up(size_t a) {
    if (is_power_of_2(a)) return a;
    size_t res = 1;
    while (res < a) res <<= 1;
    return res;
}

// 返回最近的2的幂次向下取整
static inline size_t power_round_down(size_t a) {
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
}
// 获取节点长度
static inline size_t node_length(size_t full_tree_size, size_t a) {
    return full_tree_size / power_round_down(a);
}

// 获取节点开始地址
static inline size_t node_beginning(size_t full_tree_size, size_t a) {
    return power_remainder(a) * node_length(full_tree_size, a);
}

// 获取节点结束地址
static inline size_t node_ending(size_t full_tree_size, size_t a) {
    return (power_remainder(a) + 1) * node_length(full_tree_size, a);
}


// 获取节点的父节点
static inline size_t parent(size_t a) {
    return a >> 1;
}

// 获取左子节点
static inline size_t left_child(size_t a) {
    return a << 1;
}

// 获取右子节点
static inline size_t right_child(size_t a) {
    return (a << 1) + 1;
}

// 计算伙伴块索引
static inline size_t buddy_block(size_t full_tree_size, size_t a, size_t b) {
    return full_tree_size / ((b) - (a)) + (a) / ((b) - (a));
}


#define TREE_ROOT (1)           
#define BUDDY_EMPTY(a) (record_area[(a)] == node_length(full_tree_size, a))

static void buddy_init(void)
{
    list_init(&free_list);
    nr_free = 0;
}

static void buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    struct Page *p;
    for (p = base; p < base + n; p++)
    {
        assert(PageReserved(p));
        p->flags = p->property = 0;
    }
    total_size = n;
    if (n < 512)
    {
        full_tree_size = power_round_up(n - 1);
        record_area_size = 1;
    }
    else
    {
        full_tree_size = power_round_down(n);
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
        //需要多少个内存页来存储记录区域
        if (n > full_tree_size + (record_area_size << 1))
        {
            full_tree_size <<= 1;
            record_area_size <<= 1;
        }
    }
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
    //初始化物理地址
    physical_area = base;
    record_area = KADDR(page2pa(base));
    allocate_area = base + record_area_size;
    memset(record_area, 0, record_area_size * PGSIZE);

    nr_free += real_tree_size;
    size_t block = TREE_ROOT;
    size_t real_subtree_size = real_tree_size;
    size_t full_subtree_size = full_tree_size;

    record_area[block] = real_subtree_size;
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
    {
        full_subtree_size >>= 1;
        if (real_subtree_size > full_subtree_size)
        {
            struct Page *page = &allocate_area[node_beginning(full_tree_size,block)];
            page->property = full_subtree_size;
            list_add(&(free_list), &(page->page_link));
            set_page_ref(page, 0);
            SetPageProperty(page);
            //设置页面的属性为已分配状态
            record_area[left_child(block)] = full_subtree_size;
            real_subtree_size -= full_subtree_size;
            record_area[right_child(block)] = real_subtree_size;
            block = right_child(block);
        }
        else
        {
            record_area[left_child(block)] = real_subtree_size;
            record_area[right_child(block)] = 0;
            block = left_child(block);
        }
    }

    if (real_subtree_size > 0)
    {
        struct Page *page = &allocate_area[node_beginning(full_tree_size , block)];
        page->property = real_subtree_size;
        set_page_ref(page, 0);
        SetPageProperty(page);
        list_add(&(free_list), &(page->page_link));
    }
}

static struct Page *buddy_allocate_pages(size_t n)
{
    assert(n > 0);
    struct Page *page;
    size_t block = TREE_ROOT;
    size_t length = power_round_up(n);

    while (length <= record_area[block] && length < node_length(full_tree_size, block))
    {
        size_t left = left_child(block);
        size_t right = right_child(block);
        
        if (BUDDY_EMPTY(block)) 
        {
            size_t begin = node_beginning(full_tree_size, block);
            size_t mid = (begin + node_ending(full_tree_size, block)) >> 1;

            // 分割当前块
            list_del(&(allocate_area[begin].page_link));
            allocate_area[begin].property >>= 1;
            allocate_area[mid].property = allocate_area[begin].property;

            record_area[left] = record_area[block] >> 1;
            record_area[right] = record_area[block] >> 1;
            list_add(&free_list, &(allocate_area[begin].page_link));
            list_add(&free_list, &(allocate_area[mid].page_link));
            block = left;
        }
        else if (length & record_area[left])
            block = left;
        else if (length & record_area[right])
            block = right;
        else if (length <= record_area[left])
            block = left;
        else if (length <= record_area[right])
            block = right;
    }

    if (length > record_area[block])
        return NULL;

    page = &(allocate_area[node_beginning(full_tree_size, block)]);
    list_del(&(page->page_link));
    record_area[block] = 0;
    nr_free -= length;

    // 更新父节点记录
    while (block != TREE_ROOT) 
    {
        block = parent(block);
        record_area[block] = record_area[left_child(block)] | record_area[right_child(block)];
    }

    return page;
}


static void buddy_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    struct Page *p = base;
    size_t length = power_round_up(n);
    size_t begin = (base - allocate_area);
    size_t end = begin + length;
    size_t block = buddy_block(full_tree_size, begin, end);

    for (; p != base + n; p++)
    {
        assert(!PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = length;
    list_add(&free_list, &(base->page_link));
    nr_free += length;
    record_area[block] = length;

    while (block != TREE_ROOT)
    {
        block = parent(block);
        size_t left = left_child(block);
        size_t right = right_child(block);
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
        {
            size_t lbegin = node_beginning(full_tree_size,left);
            size_t rbegin = node_beginning(full_tree_size, right);
            list_del(&(allocate_area[lbegin].page_link));
            list_del(&(allocate_area[rbegin].page_link));
            record_area[block] = record_area[left] << 1;
            allocate_area[lbegin].property = record_area[left] << 1;
            list_add(&free_list, &(allocate_area[lbegin].page_link));
        }
        else
            record_area[block] = record_area[left_child(block)] | record_area[right_child(block)];
    }
}

static size_t
buddy_nr_free_pages(void)
{
    return nr_free;
}

static void alloc_check(void) {
    size_t total_size_store = total_size;  // 保存总内存大小
    struct Page *page;
    size_t num = 1026;
    //1026是运行临界值
    // 标记物理区域为保留
    for (page = physical_area; page < physical_area + num; page++) {
        SetPageReserved(page);
    }

    // 初始化伙伴系统
    buddy_init();
    buddy_init_memmap(physical_area, num);

    struct Page *pages[5] = { NULL }; // 使用数组存储页面指针
    const int num_pages_to_alloc = sizeof(pages) / sizeof(pages[0]); // 动态计算页面数量

    // 分配四个页面，并确保分配成功
    for (int i = 0; i < num_pages_to_alloc; i++) {
        assert((pages[i] = alloc_page()) != NULL);
        cprintf("Allocated page %d at address %p\n", i + 1, pages[i]);
    }

    // 确保连续分配的页面相邻
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
        assert(pages[i] + 1 == pages[i + 1]);
    }

    // 确认页面引用计数为0
    for (int i = 0; i < num_pages_to_alloc; i++) {
        assert(page_ref(pages[i]) == 0);
    }

    // 确保页面地址在合法范围内
    for (int i = 0; i < num_pages_to_alloc; i++) {
        assert(page2pa(pages[i]) < npage * PGSIZE);
    }

    // 检查空闲列表中的页面
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        page = le2page(le, page_link);
        assert(buddy_allocate_pages(page->property) != NULL);
        cprintf("Allocated from free list: %p\n", page);
    }

    // 检查分配失败的情况
    assert(alloc_page() == NULL);

    // 释放分配的页面
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
        free_page(pages[i]);
        cprintf("Freed page %d at address %p\n", i + 1, pages[i]);
    }
    assert(nr_free == 4); // 确保空闲页面数正确
    cprintf("Number of free pages: %d\n", nr_free);
    

    // 重新分配页面
    struct Page *allocated_page;
    assert((allocated_page = alloc_page()) != NULL);
    cprintf("Reallocated a single page at %p\n", allocated_page);
    
    struct Page *double_allocated_page = alloc_pages(2);
    assert(double_allocated_page != NULL);
    cprintf("Allocated two pages at %p\n", double_allocated_page);

    // 重新分配页面
    struct Page *allocated_page_second;
    assert((allocated_page_second = alloc_page()) != NULL);
    cprintf("Reallocated a single page again at %p\n", allocated_page_second);
    
    // 检查再次分配失败
    assert(alloc_page() == NULL);
    cprintf("Second allocation failed as expected\n");

    // 释放页面
    free_pages(double_allocated_page, 2);
    cprintf("Freed two pages starting at %p\n", double_allocated_page);
    free_page(allocated_page);
    cprintf("Freed the reallocated page at %p\n", allocated_page);
    free_page(allocated_page_second);
    cprintf("Freed the reallocated page again at %p\n", allocated_page_second);

    // 再次分配页面
    assert((page = alloc_pages(4)) == allocated_page);
    cprintf("Allocated four pages starting at %p\n", allocated_page);
    assert(alloc_page() == NULL);
    cprintf("Final allocation succeeded as expected\n");

    assert(nr_free == 0); // 确保没有空闲页面
    cprintf("No free pages remaining\n");

    // 重新标记物理区域
    for (page = physical_area; page < physical_area + total_size_store; page++) {
        SetPageReserved(page);
    }
    buddy_init();
    buddy_init_memmap(physical_area, total_size_store);
    cprintf("Memory re-initialized and reserved\n");
}


const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_allocate_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = alloc_check,
};

