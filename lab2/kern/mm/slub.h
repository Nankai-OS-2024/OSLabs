#ifndef __KERN_MM_SLUB_H__
#define __KERN_MM_SLUB_H__

#include <pmm.h>
#include <list.h>

#define CACHE_NAMELEN 32

#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage)                                    \
        {                                                        \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })

// 双层结构的第一层（kmem缓存）
struct kmem_cache_t
{
    list_entry_t slabs_full;
    list_entry_t slabs_partial;
    list_entry_t slabs_free;
    uint16_t objsize;
    uint16_t num;
    char name[CACHE_NAMELEN];
    list_entry_t cache_link;
};

// 双层结构的第二层（slab块）
struct slab_t
{
    int ref;
    struct kmem_cache_t *cachep;
    uint16_t inuse;
    int16_t free;
    list_entry_t slab_link;
};

// 双层结构存储的实际对象（obj块）
#define TEST_OBJECT_LENTH 1024 // 设置obj结构体的大小为1024

static const char *test_object_name = "test";

struct test_object
{
    char test_member[TEST_OBJECT_LENTH];
};

// 一些个函数声明
struct kmem_cache_t *kmem_cache_create(const char *name, size_t size);
void kmem_cache_destroy(struct kmem_cache_t *cachep);
void *kmem_cache_alloc(struct kmem_cache_t *cachep);
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp);
size_t kmem_cache_size(struct kmem_cache_t *cachep);
const char *kmem_cache_name(struct kmem_cache_t *cachep);
void *kmalloc(size_t size);
void kfree(void *objp);
void kmem_init();

#endif /* ! __KERN_MM_SLUB_H__ */