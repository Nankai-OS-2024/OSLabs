#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

extern list_entry_t pra_list_head, *curr_ptr;

static int
_lru_init_mm(struct mm_struct *mm)
{

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    curr_ptr = &(page->pra_page_link);

    assert(curr_ptr != NULL && head != NULL);
    list_add((list_entry_t *)mm->sm_priv, curr_ptr);
    return 0;
}

static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    curr_ptr = list_prev(head);
    if (curr_ptr != head)
    {
        cprintf("curr_ptr 0xffffffff%08x\n", curr_ptr);
        list_del(curr_ptr);
        *ptr_page = le2page(curr_ptr, pra_page_link);
    }
    else
    {
        *ptr_page = NULL;
    }
    return 0;
}

static void
print_mm_list()
{
    cprintf("--------begin----------\n");
    list_entry_t *head = &pra_list_head, *le = head;
    while ((le = list_next(le)) != head)
    {
        struct Page *page = le2page(le, pra_page_link);
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
    }
    cprintf("---------end-----------\n");
}

static int
_lru_check_swap(void)
{
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    return 0;
}

static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);
    curr_ptr = list_next(head); // 当前指针初始化为链表的下一个元素

    while (curr_ptr != head)
    {
        struct Page *page = le2page(curr_ptr, pra_page_link);
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);

        if (*ptep & PTE_A)
        {
            list_del(curr_ptr);                         // 从链表中删除当前节点
            list_add(head, curr_ptr);                   // 将当前节点添加到链表头部
            *ptep &= ~PTE_A;                            // 清除访问位
            tlb_invalidate(mm->pgdir, page->pra_vaddr); // 使TLB失效
        }

        // 使用临时指针更新 curr_ptr
        curr_ptr = list_next(curr_ptr); // 更新 curr_ptr 为下一个节点
    }

    cprintf("_lru_tick_event is called!\n");
    return 0;
}

struct swap_manager swap_manager_lru =
    {
        .name = "lru swap manager",
        .init = &_lru_init,
        .init_mm = &_lru_init_mm,
        .tick_event = &_lru_tick_event,
        .map_swappable = &_lru_map_swappable,
        .set_unswappable = &_lru_set_unswappable,
        .swap_out_victim = &_lru_swap_out_victim,
        .check_swap = &_lru_check_swap,
};