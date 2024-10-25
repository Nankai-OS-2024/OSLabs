#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static size_t total_size;          // the total size of the physical area
static size_t full_tree_size;      // the size of a full binary tree
static size_t record_area_size;    // the size of the pages to record the node information
static size_t real_tree_size;      // the size of the pages to allocate
static size_t *record_area;        // the head pointer of the record pages
static struct Page *physical_area; // the head pointer of the memories
static struct Page *allocate_area; // the head pointer of the memories to allocate

#define TREE_ROOT (1)
#define LEFT_CHILD(a) ((a) << 1)
#define RIGHT_CHILD(a) (((a) << 1) + 1)
#define PARENT(a) ((a) >> 1)
#define NODE_LENGTH(a) (full_tree_size / POWER_ROUND_DOWN(a))
#define NODE_BEGINNING(a) (POWER_REMAINDER(a) * NODE_LENGTH(a))              // the head address of a node
#define NODE_ENDDING(a) ((POWER_REMAINDER(a) + 1) * NODE_LENGTH(a))          // the end address of a node
#define BUDDY_BLOCK(a, b) (full_tree_size / ((b) - (a)) + (a) / ((b) - (a))) // get the index of a node by its address
#define BUDDY_EMPTY(a) (record_area[(a)] == NODE_LENGTH(a))

#define OR_SHIFT_RIGHT(a, n) ((a) | ((a) >> (n)))
#define ALL_BIT_TO_ONE(a) (OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(a, 1), 2), 4), 8), 16))
#define POWER_REMAINDER(a) ((a) & (ALL_BIT_TO_ONE(a) >> 1))
#define POWER_ROUND_UP(a) (POWER_REMAINDER(a) ? (((a)-POWER_REMAINDER(a)) << 1) : (a))
#define POWER_ROUND_DOWN(a) (POWER_REMAINDER(a) ? ((a)-POWER_REMAINDER(a)) : (a))

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
        full_tree_size = POWER_ROUND_UP(n - 1);
        record_area_size = 1;
    }
    else
    {
        full_tree_size = POWER_ROUND_DOWN(n);
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
        if (n > full_tree_size + (record_area_size << 1))
        {
            full_tree_size <<= 1;
            record_area_size <<= 1;
        }
    }
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;

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
            struct Page *page = &allocate_area[NODE_BEGINNING(block)];
            page->property = full_subtree_size;
            list_add(&(free_list), &(page->page_link));
            set_page_ref(page, 0);
            SetPageProperty(page);
            record_area[LEFT_CHILD(block)] = full_subtree_size;
            real_subtree_size -= full_subtree_size;
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
            block = RIGHT_CHILD(block);
        }
        else
        {
            record_area[LEFT_CHILD(block)] = real_subtree_size;
            record_area[RIGHT_CHILD(block)] = 0;
            block = LEFT_CHILD(block);
        }
    }

    if (real_subtree_size > 0)
    {
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
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
    size_t length = POWER_ROUND_UP(n);

    while (length <= record_area[block] && length < NODE_LENGTH(block))
    {
        size_t left = LEFT_CHILD(block);
        size_t right = RIGHT_CHILD(block);
        if (BUDDY_EMPTY(block))
        {
            size_t begin = NODE_BEGINNING(block);
            size_t end = NODE_ENDDING(block);
            size_t mid = (begin + end) >> 1;
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
    page = &(allocate_area[NODE_BEGINNING(block)]);
    list_del(&(page->page_link));
    record_area[block] = 0;
    nr_free -= length;
    while (block != TREE_ROOT)
    {
        block = PARENT(block);
        record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
    }
    return page;
}

static void buddy_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    struct Page *p = base;
    size_t length = POWER_ROUND_UP(n);
    size_t begin = (base - allocate_area);
    size_t end = begin + length;
    size_t block = BUDDY_BLOCK(begin, end);

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
        block = PARENT(block);
        size_t left = LEFT_CHILD(block);
        size_t right = RIGHT_CHILD(block);
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
        {
            size_t lbegin = NODE_BEGINNING(left);
            size_t rbegin = NODE_BEGINNING(right);
            list_del(&(allocate_area[lbegin].page_link));
            list_del(&(allocate_area[rbegin].page_link));
            record_area[block] = record_area[left] << 1;
            allocate_area[lbegin].property = record_area[left] << 1;
            list_add(&free_list, &(allocate_area[lbegin].page_link));
        }
        else
            record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
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

    // 标记物理区域为保留
    for (page = physical_area; page < physical_area + 1026; page++) {
        SetPageReserved(page);
    }

    // 初始化伙伴系统
    buddy_init();
    buddy_init_memmap(physical_area, 1026);

    struct Page *pages[4] = { NULL }; // 使用数组存储页面指针
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
        cprintf("Page %d reference count is 0\n", i + 1);
    }

    // 确保页面地址在合法范围内
    for (int i = 0; i < num_pages_to_alloc; i++) {
        assert(page2pa(pages[i]) < npage * PGSIZE);
        cprintf("Page %d physical address %lu is within valid range\n", i + 1, page2pa(pages[i]));
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
    cprintf("Allocation failed as expected\n");

    // 释放分配的页面
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
        free_page(pages[i]);
        cprintf("Freed page %d at address %p\n", i + 1, pages[i]);
    }
    assert(nr_free == 3); // 确保空闲页面数正确
    cprintf("Number of free pages: %d\n", nr_free);

    // 重新分配页面
    struct Page *allocated_page;
    assert((allocated_page = alloc_page()) != NULL);
    cprintf("Reallocated a single page at %p\n", allocated_page);
    
    struct Page *double_allocated_page = alloc_pages(2);
    assert(double_allocated_page != NULL);
    cprintf("Allocated two pages at %p\n", double_allocated_page);
    assert(double_allocated_page + 2 == allocated_page);

    // 检查再次分配失败
    assert(alloc_page() == NULL);
    cprintf("Second allocation failed as expected\n");

    // 释放页面
    free_pages(double_allocated_page, 2);
    cprintf("Freed two pages starting at %p\n", double_allocated_page);
    free_page(allocated_page);
    cprintf("Freed the reallocated page at %p\n", allocated_page);
    free_page(pages[3]); // 注意释放最后一个页面
    cprintf("Freed last allocated page at %p\n", pages[3]);

    // 再次分配页面
    assert((page = alloc_pages(4)) == double_allocated_page);
    cprintf("Allocated four pages starting at %p\n", double_allocated_page);
    assert(alloc_page() == NULL);
    cprintf("Final allocation failed as expected\n");

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