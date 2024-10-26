
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02082b7          	lui	t0,0xc0208
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0208137          	lui	sp,0xc0208

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00009517          	auipc	a0,0x9
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0209010 <free_area>
ffffffffc020003a:	00009617          	auipc	a2,0x9
ffffffffc020003e:	52660613          	addi	a2,a2,1318 # ffffffffc0209560 <end>
{
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
{
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	513030ef          	jal	ra,ffffffffc0203d5c <memset>
    cons_init(); // init the console
ffffffffc020004e:	420000ef          	jal	ra,ffffffffc020046e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    // cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00004517          	auipc	a0,0x4
ffffffffc0200056:	d6650513          	addi	a0,a0,-666 # ffffffffc0203db8 <etext+0x32>
ffffffffc020005a:	0b4000ef          	jal	ra,ffffffffc020010e <cputs>

    print_kerninfo();
ffffffffc020005e:	100000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();
    
    idt_init(); // init interrupt descriptor table
ffffffffc0200062:	426000ef          	jal	ra,ffffffffc0200488 <idt_init>

    pmm_init("first_fit");
ffffffffc0200066:	00004517          	auipc	a0,0x4
ffffffffc020006a:	d2250513          	addi	a0,a0,-734 # ffffffffc0203d88 <etext+0x2>
ffffffffc020006e:	2b5020ef          	jal	ra,ffffffffc0202b22 <pmm_init>

    pmm_init("best_fit");
ffffffffc0200072:	00004517          	auipc	a0,0x4
ffffffffc0200076:	d2650513          	addi	a0,a0,-730 # ffffffffc0203d98 <etext+0x12>
ffffffffc020007a:	2a9020ef          	jal	ra,ffffffffc0202b22 <pmm_init>
    
    pmm_init("buddy_system"); // init physical memory management
ffffffffc020007e:	00004517          	auipc	a0,0x4
ffffffffc0200082:	d2a50513          	addi	a0,a0,-726 # ffffffffc0203da8 <etext+0x22>
ffffffffc0200086:	29d020ef          	jal	ra,ffffffffc0202b22 <pmm_init>

    kmem_init(); // init kmem_cache which contains slabs
ffffffffc020008a:	17e030ef          	jal	ra,ffffffffc0203208 <kmem_init>

    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	3fa000ef          	jal	ra,ffffffffc0200488 <idt_init>

    clock_init();  // init clock interrupt
ffffffffc0200092:	39a000ef          	jal	ra,ffffffffc020042c <clock_init>
    
    intr_enable(); // enable irq interrupt
ffffffffc0200096:	3e6000ef          	jal	ra,ffffffffc020047c <intr_enable>

    /* do nothing */
    while (1)
ffffffffc020009a:	a001                	j	ffffffffc020009a <kern_init+0x68>

ffffffffc020009c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020009c:	1141                	addi	sp,sp,-16
ffffffffc020009e:	e022                	sd	s0,0(sp)
ffffffffc02000a0:	e406                	sd	ra,8(sp)
ffffffffc02000a2:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000a4:	3cc000ef          	jal	ra,ffffffffc0200470 <cons_putc>
    (*cnt) ++;
ffffffffc02000a8:	401c                	lw	a5,0(s0)
}
ffffffffc02000aa:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000ac:	2785                	addiw	a5,a5,1
ffffffffc02000ae:	c01c                	sw	a5,0(s0)
}
ffffffffc02000b0:	6402                	ld	s0,0(sp)
ffffffffc02000b2:	0141                	addi	sp,sp,16
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b6:	1101                	addi	sp,sp,-32
ffffffffc02000b8:	862a                	mv	a2,a0
ffffffffc02000ba:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000bc:	00000517          	auipc	a0,0x0
ffffffffc02000c0:	fe050513          	addi	a0,a0,-32 # ffffffffc020009c <cputch>
ffffffffc02000c4:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	7bc030ef          	jal	ra,ffffffffc0203886 <vprintfmt>
    return cnt;
}
ffffffffc02000ce:	60e2                	ld	ra,24(sp)
ffffffffc02000d0:	4532                	lw	a0,12(sp)
ffffffffc02000d2:	6105                	addi	sp,sp,32
ffffffffc02000d4:	8082                	ret

ffffffffc02000d6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d8:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000dc:	8e2a                	mv	t3,a0
ffffffffc02000de:	f42e                	sd	a1,40(sp)
ffffffffc02000e0:	f832                	sd	a2,48(sp)
ffffffffc02000e2:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	00000517          	auipc	a0,0x0
ffffffffc02000e8:	fb850513          	addi	a0,a0,-72 # ffffffffc020009c <cputch>
ffffffffc02000ec:	004c                	addi	a1,sp,4
ffffffffc02000ee:	869a                	mv	a3,t1
ffffffffc02000f0:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e0ba                	sd	a4,64(sp)
ffffffffc02000f6:	e4be                	sd	a5,72(sp)
ffffffffc02000f8:	e8c2                	sd	a6,80(sp)
ffffffffc02000fa:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000fc:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000fe:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200100:	786030ef          	jal	ra,ffffffffc0203886 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200104:	60e2                	ld	ra,24(sp)
ffffffffc0200106:	4512                	lw	a0,4(sp)
ffffffffc0200108:	6125                	addi	sp,sp,96
ffffffffc020010a:	8082                	ret

ffffffffc020010c <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc020010c:	a695                	j	ffffffffc0200470 <cons_putc>

ffffffffc020010e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020010e:	1101                	addi	sp,sp,-32
ffffffffc0200110:	e822                	sd	s0,16(sp)
ffffffffc0200112:	ec06                	sd	ra,24(sp)
ffffffffc0200114:	e426                	sd	s1,8(sp)
ffffffffc0200116:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200118:	00054503          	lbu	a0,0(a0)
ffffffffc020011c:	c51d                	beqz	a0,ffffffffc020014a <cputs+0x3c>
ffffffffc020011e:	0405                	addi	s0,s0,1
ffffffffc0200120:	4485                	li	s1,1
ffffffffc0200122:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200124:	34c000ef          	jal	ra,ffffffffc0200470 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200128:	00044503          	lbu	a0,0(s0)
ffffffffc020012c:	008487bb          	addw	a5,s1,s0
ffffffffc0200130:	0405                	addi	s0,s0,1
ffffffffc0200132:	f96d                	bnez	a0,ffffffffc0200124 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200134:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200138:	4529                	li	a0,10
ffffffffc020013a:	336000ef          	jal	ra,ffffffffc0200470 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020013e:	60e2                	ld	ra,24(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	6442                	ld	s0,16(sp)
ffffffffc0200144:	64a2                	ld	s1,8(sp)
ffffffffc0200146:	6105                	addi	sp,sp,32
ffffffffc0200148:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020014a:	4405                	li	s0,1
ffffffffc020014c:	b7f5                	j	ffffffffc0200138 <cputs+0x2a>

ffffffffc020014e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020014e:	1141                	addi	sp,sp,-16
ffffffffc0200150:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200152:	326000ef          	jal	ra,ffffffffc0200478 <cons_getc>
ffffffffc0200156:	dd75                	beqz	a0,ffffffffc0200152 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200158:	60a2                	ld	ra,8(sp)
ffffffffc020015a:	0141                	addi	sp,sp,16
ffffffffc020015c:	8082                	ret

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	c7850513          	addi	a0,a0,-904 # ffffffffc0203dd8 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f6dff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	c8250513          	addi	a0,a0,-894 # ffffffffc0203df8 <etext+0x72>
ffffffffc020017e:	f59ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	c0458593          	addi	a1,a1,-1020 # ffffffffc0203d86 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	c8e50513          	addi	a0,a0,-882 # ffffffffc0203e18 <etext+0x92>
ffffffffc0200192:	f45ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200196:	00009597          	auipc	a1,0x9
ffffffffc020019a:	e7a58593          	addi	a1,a1,-390 # ffffffffc0209010 <free_area>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	c9a50513          	addi	a0,a0,-870 # ffffffffc0203e38 <etext+0xb2>
ffffffffc02001a6:	f31ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001aa:	00009597          	auipc	a1,0x9
ffffffffc02001ae:	3b658593          	addi	a1,a1,950 # ffffffffc0209560 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	ca650513          	addi	a0,a0,-858 # ffffffffc0203e58 <etext+0xd2>
ffffffffc02001ba:	f1dff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00009597          	auipc	a1,0x9
ffffffffc02001c2:	7a158593          	addi	a1,a1,1953 # ffffffffc020995f <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	c9850513          	addi	a0,a0,-872 # ffffffffc0203e78 <etext+0xf2>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	b5f5                	j	ffffffffc02000d6 <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	cba60613          	addi	a2,a2,-838 # ffffffffc0203ea8 <etext+0x122>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	cc650513          	addi	a0,a0,-826 # ffffffffc0203ec0 <etext+0x13a>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	1cc000ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	cce60613          	addi	a2,a2,-818 # ffffffffc0203ed8 <etext+0x152>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	ce658593          	addi	a1,a1,-794 # ffffffffc0203ef8 <etext+0x172>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	ce650513          	addi	a0,a0,-794 # ffffffffc0203f00 <etext+0x17a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	eb3ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	ce860613          	addi	a2,a2,-792 # ffffffffc0203f10 <etext+0x18a>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	d0858593          	addi	a1,a1,-760 # ffffffffc0203f38 <etext+0x1b2>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	cc850513          	addi	a0,a0,-824 # ffffffffc0203f00 <etext+0x17a>
ffffffffc0200240:	e97ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	d0460613          	addi	a2,a2,-764 # ffffffffc0203f48 <etext+0x1c2>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	d1c58593          	addi	a1,a1,-740 # ffffffffc0203f68 <etext+0x1e2>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	cac50513          	addi	a0,a0,-852 # ffffffffc0203f00 <etext+0x17a>
ffffffffc020025c:	e7bff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	cea50513          	addi	a0,a0,-790 # ffffffffc0203f78 <etext+0x1f2>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e2bff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	cf050513          	addi	a0,a0,-784 # ffffffffc0203fa0 <etext+0x21a>
ffffffffc02002b8:	e1fff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	3a4000ef          	jal	ra,ffffffffc0200666 <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	d4ac0c13          	addi	s8,s8,-694 # ffffffffc0204010 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	00004917          	auipc	s2,0x4
ffffffffc02002d2:	cfa90913          	addi	s2,s2,-774 # ffffffffc0203fc8 <etext+0x242>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	cfa48493          	addi	s1,s1,-774 # ffffffffc0203fd0 <etext+0x24a>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	cf8b0b13          	addi	s6,s6,-776 # ffffffffc0203fd8 <etext+0x252>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	c10a0a13          	addi	s4,s4,-1008 # ffffffffc0203ef8 <etext+0x172>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	115030ef          	jal	ra,ffffffffc0203c08 <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	d06d0d13          	addi	s10,s10,-762 # ffffffffc0204010 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	211030ef          	jal	ra,ffffffffc0203d28 <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	1fd030ef          	jal	ra,ffffffffc0203d28 <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	1dd030ef          	jal	ra,ffffffffc0203d46 <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	19f030ef          	jal	ra,ffffffffc0203d46 <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d1dff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	c3650513          	addi	a0,a0,-970 # ffffffffc0203ff8 <etext+0x272>
ffffffffc02003ca:	d0dff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003d0:	00009317          	auipc	t1,0x9
ffffffffc02003d4:	11030313          	addi	t1,t1,272 # ffffffffc02094e0 <is_panic>
ffffffffc02003d8:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003dc:	715d                	addi	sp,sp,-80
ffffffffc02003de:	ec06                	sd	ra,24(sp)
ffffffffc02003e0:	e822                	sd	s0,16(sp)
ffffffffc02003e2:	f436                	sd	a3,40(sp)
ffffffffc02003e4:	f83a                	sd	a4,48(sp)
ffffffffc02003e6:	fc3e                	sd	a5,56(sp)
ffffffffc02003e8:	e0c2                	sd	a6,64(sp)
ffffffffc02003ea:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003ec:	020e1a63          	bnez	t3,ffffffffc0200420 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003f0:	4785                	li	a5,1
ffffffffc02003f2:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003f6:	8432                	mv	s0,a2
ffffffffc02003f8:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003fa:	862e                	mv	a2,a1
ffffffffc02003fc:	85aa                	mv	a1,a0
ffffffffc02003fe:	00004517          	auipc	a0,0x4
ffffffffc0200402:	c5a50513          	addi	a0,a0,-934 # ffffffffc0204058 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200406:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200408:	ccfff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020040c:	65a2                	ld	a1,8(sp)
ffffffffc020040e:	8522                	mv	a0,s0
ffffffffc0200410:	ca7ff0ef          	jal	ra,ffffffffc02000b6 <vcprintf>
    cprintf("\n");
ffffffffc0200414:	00004517          	auipc	a0,0x4
ffffffffc0200418:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0203ea0 <etext+0x11a>
ffffffffc020041c:	cbbff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200420:	062000ef          	jal	ra,ffffffffc0200482 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200424:	4501                	li	a0,0
ffffffffc0200426:	e63ff0ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020042a:	bfed                	j	ffffffffc0200424 <__panic+0x54>

ffffffffc020042c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020042c:	1141                	addi	sp,sp,-16
ffffffffc020042e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200430:	02000793          	li	a5,32
ffffffffc0200434:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200438:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043c:	67e1                	lui	a5,0x18
ffffffffc020043e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200442:	953e                	add	a0,a0,a5
ffffffffc0200444:	093030ef          	jal	ra,ffffffffc0203cd6 <sbi_set_timer>
}
ffffffffc0200448:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020044a:	00009797          	auipc	a5,0x9
ffffffffc020044e:	0807bf23          	sd	zero,158(a5) # ffffffffc02094e8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	c2650513          	addi	a0,a0,-986 # ffffffffc0204078 <commands+0x68>
}
ffffffffc020045a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9ad                	j	ffffffffc02000d6 <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	67e1                	lui	a5,0x18
ffffffffc0200464:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200468:	953e                	add	a0,a0,a5
ffffffffc020046a:	06d0306f          	j	ffffffffc0203cd6 <sbi_set_timer>

ffffffffc020046e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020046e:	8082                	ret

ffffffffc0200470 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200470:	0ff57513          	zext.b	a0,a0
ffffffffc0200474:	0490306f          	j	ffffffffc0203cbc <sbi_console_putchar>

ffffffffc0200478 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200478:	0790306f          	j	ffffffffc0203cf0 <sbi_console_getchar>

ffffffffc020047c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020047c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200482:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200486:	8082                	ret

ffffffffc0200488 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200488:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020048c:	00000797          	auipc	a5,0x0
ffffffffc0200490:	2e478793          	addi	a5,a5,740 # ffffffffc0200770 <__alltraps>
ffffffffc0200494:	10579073          	csrw	stvec,a5
}
ffffffffc0200498:	8082                	ret

ffffffffc020049a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020049a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020049c:	1141                	addi	sp,sp,-16
ffffffffc020049e:	e022                	sd	s0,0(sp)
ffffffffc02004a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02004a2:	00004517          	auipc	a0,0x4
ffffffffc02004a6:	bf650513          	addi	a0,a0,-1034 # ffffffffc0204098 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc02004aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02004ac:	c2bff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02004b0:	640c                	ld	a1,8(s0)
ffffffffc02004b2:	00004517          	auipc	a0,0x4
ffffffffc02004b6:	bfe50513          	addi	a0,a0,-1026 # ffffffffc02040b0 <commands+0xa0>
ffffffffc02004ba:	c1dff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004be:	680c                	ld	a1,16(s0)
ffffffffc02004c0:	00004517          	auipc	a0,0x4
ffffffffc02004c4:	c0850513          	addi	a0,a0,-1016 # ffffffffc02040c8 <commands+0xb8>
ffffffffc02004c8:	c0fff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004cc:	6c0c                	ld	a1,24(s0)
ffffffffc02004ce:	00004517          	auipc	a0,0x4
ffffffffc02004d2:	c1250513          	addi	a0,a0,-1006 # ffffffffc02040e0 <commands+0xd0>
ffffffffc02004d6:	c01ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004da:	700c                	ld	a1,32(s0)
ffffffffc02004dc:	00004517          	auipc	a0,0x4
ffffffffc02004e0:	c1c50513          	addi	a0,a0,-996 # ffffffffc02040f8 <commands+0xe8>
ffffffffc02004e4:	bf3ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004e8:	740c                	ld	a1,40(s0)
ffffffffc02004ea:	00004517          	auipc	a0,0x4
ffffffffc02004ee:	c2650513          	addi	a0,a0,-986 # ffffffffc0204110 <commands+0x100>
ffffffffc02004f2:	be5ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004f6:	780c                	ld	a1,48(s0)
ffffffffc02004f8:	00004517          	auipc	a0,0x4
ffffffffc02004fc:	c3050513          	addi	a0,a0,-976 # ffffffffc0204128 <commands+0x118>
ffffffffc0200500:	bd7ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200504:	7c0c                	ld	a1,56(s0)
ffffffffc0200506:	00004517          	auipc	a0,0x4
ffffffffc020050a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0204140 <commands+0x130>
ffffffffc020050e:	bc9ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200512:	602c                	ld	a1,64(s0)
ffffffffc0200514:	00004517          	auipc	a0,0x4
ffffffffc0200518:	c4450513          	addi	a0,a0,-956 # ffffffffc0204158 <commands+0x148>
ffffffffc020051c:	bbbff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200520:	642c                	ld	a1,72(s0)
ffffffffc0200522:	00004517          	auipc	a0,0x4
ffffffffc0200526:	c4e50513          	addi	a0,a0,-946 # ffffffffc0204170 <commands+0x160>
ffffffffc020052a:	badff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020052e:	682c                	ld	a1,80(s0)
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	c5850513          	addi	a0,a0,-936 # ffffffffc0204188 <commands+0x178>
ffffffffc0200538:	b9fff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020053c:	6c2c                	ld	a1,88(s0)
ffffffffc020053e:	00004517          	auipc	a0,0x4
ffffffffc0200542:	c6250513          	addi	a0,a0,-926 # ffffffffc02041a0 <commands+0x190>
ffffffffc0200546:	b91ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020054a:	702c                	ld	a1,96(s0)
ffffffffc020054c:	00004517          	auipc	a0,0x4
ffffffffc0200550:	c6c50513          	addi	a0,a0,-916 # ffffffffc02041b8 <commands+0x1a8>
ffffffffc0200554:	b83ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200558:	742c                	ld	a1,104(s0)
ffffffffc020055a:	00004517          	auipc	a0,0x4
ffffffffc020055e:	c7650513          	addi	a0,a0,-906 # ffffffffc02041d0 <commands+0x1c0>
ffffffffc0200562:	b75ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200566:	782c                	ld	a1,112(s0)
ffffffffc0200568:	00004517          	auipc	a0,0x4
ffffffffc020056c:	c8050513          	addi	a0,a0,-896 # ffffffffc02041e8 <commands+0x1d8>
ffffffffc0200570:	b67ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200574:	7c2c                	ld	a1,120(s0)
ffffffffc0200576:	00004517          	auipc	a0,0x4
ffffffffc020057a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0204200 <commands+0x1f0>
ffffffffc020057e:	b59ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200582:	604c                	ld	a1,128(s0)
ffffffffc0200584:	00004517          	auipc	a0,0x4
ffffffffc0200588:	c9450513          	addi	a0,a0,-876 # ffffffffc0204218 <commands+0x208>
ffffffffc020058c:	b4bff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200590:	644c                	ld	a1,136(s0)
ffffffffc0200592:	00004517          	auipc	a0,0x4
ffffffffc0200596:	c9e50513          	addi	a0,a0,-866 # ffffffffc0204230 <commands+0x220>
ffffffffc020059a:	b3dff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020059e:	684c                	ld	a1,144(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	ca850513          	addi	a0,a0,-856 # ffffffffc0204248 <commands+0x238>
ffffffffc02005a8:	b2fff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02005ac:	6c4c                	ld	a1,152(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	cb250513          	addi	a0,a0,-846 # ffffffffc0204260 <commands+0x250>
ffffffffc02005b6:	b21ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02005ba:	704c                	ld	a1,160(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0204278 <commands+0x268>
ffffffffc02005c4:	b13ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005c8:	744c                	ld	a1,168(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	cc650513          	addi	a0,a0,-826 # ffffffffc0204290 <commands+0x280>
ffffffffc02005d2:	b05ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005d6:	784c                	ld	a1,176(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	cd050513          	addi	a0,a0,-816 # ffffffffc02042a8 <commands+0x298>
ffffffffc02005e0:	af7ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005e4:	7c4c                	ld	a1,184(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	cda50513          	addi	a0,a0,-806 # ffffffffc02042c0 <commands+0x2b0>
ffffffffc02005ee:	ae9ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005f2:	606c                	ld	a1,192(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	ce450513          	addi	a0,a0,-796 # ffffffffc02042d8 <commands+0x2c8>
ffffffffc02005fc:	adbff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200600:	646c                	ld	a1,200(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	cee50513          	addi	a0,a0,-786 # ffffffffc02042f0 <commands+0x2e0>
ffffffffc020060a:	acdff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc020060e:	686c                	ld	a1,208(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	cf850513          	addi	a0,a0,-776 # ffffffffc0204308 <commands+0x2f8>
ffffffffc0200618:	abfff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc020061c:	6c6c                	ld	a1,216(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	d0250513          	addi	a0,a0,-766 # ffffffffc0204320 <commands+0x310>
ffffffffc0200626:	ab1ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020062a:	706c                	ld	a1,224(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	d0c50513          	addi	a0,a0,-756 # ffffffffc0204338 <commands+0x328>
ffffffffc0200634:	aa3ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200638:	746c                	ld	a1,232(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	d1650513          	addi	a0,a0,-746 # ffffffffc0204350 <commands+0x340>
ffffffffc0200642:	a95ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200646:	786c                	ld	a1,240(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204368 <commands+0x358>
ffffffffc0200650:	a87ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200654:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200656:	6402                	ld	s0,0(sp)
ffffffffc0200658:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020065a:	00004517          	auipc	a0,0x4
ffffffffc020065e:	d2650513          	addi	a0,a0,-730 # ffffffffc0204380 <commands+0x370>
}
ffffffffc0200662:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200664:	bc8d                	j	ffffffffc02000d6 <cprintf>

ffffffffc0200666 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200666:	1141                	addi	sp,sp,-16
ffffffffc0200668:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020066a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020066c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020066e:	00004517          	auipc	a0,0x4
ffffffffc0200672:	d2a50513          	addi	a0,a0,-726 # ffffffffc0204398 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200676:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200678:	a5fff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020067c:	8522                	mv	a0,s0
ffffffffc020067e:	e1dff0ef          	jal	ra,ffffffffc020049a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200682:	10043583          	ld	a1,256(s0)
ffffffffc0200686:	00004517          	auipc	a0,0x4
ffffffffc020068a:	d2a50513          	addi	a0,a0,-726 # ffffffffc02043b0 <commands+0x3a0>
ffffffffc020068e:	a49ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200692:	10843583          	ld	a1,264(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	d3250513          	addi	a0,a0,-718 # ffffffffc02043c8 <commands+0x3b8>
ffffffffc020069e:	a39ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc02006a2:	11043583          	ld	a1,272(s0)
ffffffffc02006a6:	00004517          	auipc	a0,0x4
ffffffffc02006aa:	d3a50513          	addi	a0,a0,-710 # ffffffffc02043e0 <commands+0x3d0>
ffffffffc02006ae:	a29ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006b2:	11843583          	ld	a1,280(s0)
}
ffffffffc02006b6:	6402                	ld	s0,0(sp)
ffffffffc02006b8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006ba:	00004517          	auipc	a0,0x4
ffffffffc02006be:	d3e50513          	addi	a0,a0,-706 # ffffffffc02043f8 <commands+0x3e8>
}
ffffffffc02006c2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006c4:	bc09                	j	ffffffffc02000d6 <cprintf>

ffffffffc02006c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006c6:	11853783          	ld	a5,280(a0)
ffffffffc02006ca:	472d                	li	a4,11
ffffffffc02006cc:	0786                	slli	a5,a5,0x1
ffffffffc02006ce:	8385                	srli	a5,a5,0x1
ffffffffc02006d0:	06f76c63          	bltu	a4,a5,ffffffffc0200748 <interrupt_handler+0x82>
ffffffffc02006d4:	00004717          	auipc	a4,0x4
ffffffffc02006d8:	e0470713          	addi	a4,a4,-508 # ffffffffc02044d8 <commands+0x4c8>
ffffffffc02006dc:	078a                	slli	a5,a5,0x2
ffffffffc02006de:	97ba                	add	a5,a5,a4
ffffffffc02006e0:	439c                	lw	a5,0(a5)
ffffffffc02006e2:	97ba                	add	a5,a5,a4
ffffffffc02006e4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006e6:	00004517          	auipc	a0,0x4
ffffffffc02006ea:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204470 <commands+0x460>
ffffffffc02006ee:	b2e5                	j	ffffffffc02000d6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	d6050513          	addi	a0,a0,-672 # ffffffffc0204450 <commands+0x440>
ffffffffc02006f8:	baf9                	j	ffffffffc02000d6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006fa:	00004517          	auipc	a0,0x4
ffffffffc02006fe:	d1650513          	addi	a0,a0,-746 # ffffffffc0204410 <commands+0x400>
ffffffffc0200702:	bad1                	j	ffffffffc02000d6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200704:	00004517          	auipc	a0,0x4
ffffffffc0200708:	d8c50513          	addi	a0,a0,-628 # ffffffffc0204490 <commands+0x480>
ffffffffc020070c:	b2e9                	j	ffffffffc02000d6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020070e:	1141                	addi	sp,sp,-16
ffffffffc0200710:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200712:	d4dff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200716:	00009697          	auipc	a3,0x9
ffffffffc020071a:	dd268693          	addi	a3,a3,-558 # ffffffffc02094e8 <ticks>
ffffffffc020071e:	629c                	ld	a5,0(a3)
ffffffffc0200720:	06400713          	li	a4,100
ffffffffc0200724:	0785                	addi	a5,a5,1
ffffffffc0200726:	02e7f733          	remu	a4,a5,a4
ffffffffc020072a:	e29c                	sd	a5,0(a3)
ffffffffc020072c:	cf19                	beqz	a4,ffffffffc020074a <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020072e:	60a2                	ld	ra,8(sp)
ffffffffc0200730:	0141                	addi	sp,sp,16
ffffffffc0200732:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200734:	00004517          	auipc	a0,0x4
ffffffffc0200738:	d8450513          	addi	a0,a0,-636 # ffffffffc02044b8 <commands+0x4a8>
ffffffffc020073c:	ba69                	j	ffffffffc02000d6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	cf250513          	addi	a0,a0,-782 # ffffffffc0204430 <commands+0x420>
ffffffffc0200746:	ba41                	j	ffffffffc02000d6 <cprintf>
            print_trapframe(tf);
ffffffffc0200748:	bf39                	j	ffffffffc0200666 <print_trapframe>
}
ffffffffc020074a:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020074c:	06400593          	li	a1,100
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	d5850513          	addi	a0,a0,-680 # ffffffffc02044a8 <commands+0x498>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020075a:	bab5                	j	ffffffffc02000d6 <cprintf>

ffffffffc020075c <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075c:	11853783          	ld	a5,280(a0)
ffffffffc0200760:	0007c763          	bltz	a5,ffffffffc020076e <trap+0x12>
    switch (tf->cause) {
ffffffffc0200764:	472d                	li	a4,11
ffffffffc0200766:	00f76363          	bltu	a4,a5,ffffffffc020076c <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020076a:	8082                	ret
            print_trapframe(tf);
ffffffffc020076c:	bded                	j	ffffffffc0200666 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	bfa1                	j	ffffffffc02006c6 <interrupt_handler>

ffffffffc0200770 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200770:	14011073          	csrw	sscratch,sp
ffffffffc0200774:	712d                	addi	sp,sp,-288
ffffffffc0200776:	e002                	sd	zero,0(sp)
ffffffffc0200778:	e406                	sd	ra,8(sp)
ffffffffc020077a:	ec0e                	sd	gp,24(sp)
ffffffffc020077c:	f012                	sd	tp,32(sp)
ffffffffc020077e:	f416                	sd	t0,40(sp)
ffffffffc0200780:	f81a                	sd	t1,48(sp)
ffffffffc0200782:	fc1e                	sd	t2,56(sp)
ffffffffc0200784:	e0a2                	sd	s0,64(sp)
ffffffffc0200786:	e4a6                	sd	s1,72(sp)
ffffffffc0200788:	e8aa                	sd	a0,80(sp)
ffffffffc020078a:	ecae                	sd	a1,88(sp)
ffffffffc020078c:	f0b2                	sd	a2,96(sp)
ffffffffc020078e:	f4b6                	sd	a3,104(sp)
ffffffffc0200790:	f8ba                	sd	a4,112(sp)
ffffffffc0200792:	fcbe                	sd	a5,120(sp)
ffffffffc0200794:	e142                	sd	a6,128(sp)
ffffffffc0200796:	e546                	sd	a7,136(sp)
ffffffffc0200798:	e94a                	sd	s2,144(sp)
ffffffffc020079a:	ed4e                	sd	s3,152(sp)
ffffffffc020079c:	f152                	sd	s4,160(sp)
ffffffffc020079e:	f556                	sd	s5,168(sp)
ffffffffc02007a0:	f95a                	sd	s6,176(sp)
ffffffffc02007a2:	fd5e                	sd	s7,184(sp)
ffffffffc02007a4:	e1e2                	sd	s8,192(sp)
ffffffffc02007a6:	e5e6                	sd	s9,200(sp)
ffffffffc02007a8:	e9ea                	sd	s10,208(sp)
ffffffffc02007aa:	edee                	sd	s11,216(sp)
ffffffffc02007ac:	f1f2                	sd	t3,224(sp)
ffffffffc02007ae:	f5f6                	sd	t4,232(sp)
ffffffffc02007b0:	f9fa                	sd	t5,240(sp)
ffffffffc02007b2:	fdfe                	sd	t6,248(sp)
ffffffffc02007b4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007b8:	100024f3          	csrr	s1,sstatus
ffffffffc02007bc:	14102973          	csrr	s2,sepc
ffffffffc02007c0:	143029f3          	csrr	s3,stval
ffffffffc02007c4:	14202a73          	csrr	s4,scause
ffffffffc02007c8:	e822                	sd	s0,16(sp)
ffffffffc02007ca:	e226                	sd	s1,256(sp)
ffffffffc02007cc:	e64a                	sd	s2,264(sp)
ffffffffc02007ce:	ea4e                	sd	s3,272(sp)
ffffffffc02007d0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d2:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d4:	f89ff0ef          	jal	ra,ffffffffc020075c <trap>

ffffffffc02007d8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007d8:	6492                	ld	s1,256(sp)
ffffffffc02007da:	6932                	ld	s2,264(sp)
ffffffffc02007dc:	10049073          	csrw	sstatus,s1
ffffffffc02007e0:	14191073          	csrw	sepc,s2
ffffffffc02007e4:	60a2                	ld	ra,8(sp)
ffffffffc02007e6:	61e2                	ld	gp,24(sp)
ffffffffc02007e8:	7202                	ld	tp,32(sp)
ffffffffc02007ea:	72a2                	ld	t0,40(sp)
ffffffffc02007ec:	7342                	ld	t1,48(sp)
ffffffffc02007ee:	73e2                	ld	t2,56(sp)
ffffffffc02007f0:	6406                	ld	s0,64(sp)
ffffffffc02007f2:	64a6                	ld	s1,72(sp)
ffffffffc02007f4:	6546                	ld	a0,80(sp)
ffffffffc02007f6:	65e6                	ld	a1,88(sp)
ffffffffc02007f8:	7606                	ld	a2,96(sp)
ffffffffc02007fa:	76a6                	ld	a3,104(sp)
ffffffffc02007fc:	7746                	ld	a4,112(sp)
ffffffffc02007fe:	77e6                	ld	a5,120(sp)
ffffffffc0200800:	680a                	ld	a6,128(sp)
ffffffffc0200802:	68aa                	ld	a7,136(sp)
ffffffffc0200804:	694a                	ld	s2,144(sp)
ffffffffc0200806:	69ea                	ld	s3,152(sp)
ffffffffc0200808:	7a0a                	ld	s4,160(sp)
ffffffffc020080a:	7aaa                	ld	s5,168(sp)
ffffffffc020080c:	7b4a                	ld	s6,176(sp)
ffffffffc020080e:	7bea                	ld	s7,184(sp)
ffffffffc0200810:	6c0e                	ld	s8,192(sp)
ffffffffc0200812:	6cae                	ld	s9,200(sp)
ffffffffc0200814:	6d4e                	ld	s10,208(sp)
ffffffffc0200816:	6dee                	ld	s11,216(sp)
ffffffffc0200818:	7e0e                	ld	t3,224(sp)
ffffffffc020081a:	7eae                	ld	t4,232(sp)
ffffffffc020081c:	7f4e                	ld	t5,240(sp)
ffffffffc020081e:	7fee                	ld	t6,248(sp)
ffffffffc0200820:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200822:	10200073          	sret

ffffffffc0200826 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200826:	00008797          	auipc	a5,0x8
ffffffffc020082a:	7ea78793          	addi	a5,a5,2026 # ffffffffc0209010 <free_area>
ffffffffc020082e:	e79c                	sd	a5,8(a5)
ffffffffc0200830:	e39c                	sd	a5,0(a5)

static void
best_fit_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200832:	0007a823          	sw	zero,16(a5)
    // basic_check();
    // best_fit_check();
}
ffffffffc0200836:	8082                	ret

ffffffffc0200838 <best_fit_nr_free_pages>:

static size_t
best_fit_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200838:	00008517          	auipc	a0,0x8
ffffffffc020083c:	7e856503          	lwu	a0,2024(a0) # ffffffffc0209020 <free_area+0x10>
ffffffffc0200840:	8082                	ret

ffffffffc0200842 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200842:	c14d                	beqz	a0,ffffffffc02008e4 <best_fit_alloc_pages+0xa2>
    if (n > nr_free)
ffffffffc0200844:	00008617          	auipc	a2,0x8
ffffffffc0200848:	7cc60613          	addi	a2,a2,1996 # ffffffffc0209010 <free_area>
ffffffffc020084c:	01062803          	lw	a6,16(a2)
ffffffffc0200850:	86aa                	mv	a3,a0
ffffffffc0200852:	02081793          	slli	a5,a6,0x20
ffffffffc0200856:	9381                	srli	a5,a5,0x20
ffffffffc0200858:	08a7e463          	bltu	a5,a0,ffffffffc02008e0 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020085c:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc020085e:	0018059b          	addiw	a1,a6,1
ffffffffc0200862:	1582                	slli	a1,a1,0x20
ffffffffc0200864:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200866:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list)
ffffffffc0200868:	06c78b63          	beq	a5,a2,ffffffffc02008de <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size)
ffffffffc020086c:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200870:	00d76763          	bltu	a4,a3,ffffffffc020087e <best_fit_alloc_pages+0x3c>
ffffffffc0200874:	00b77563          	bgeu	a4,a1,ffffffffc020087e <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200878:	fe878513          	addi	a0,a5,-24
ffffffffc020087c:	85ba                	mv	a1,a4
ffffffffc020087e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0200880:	fec796e3          	bne	a5,a2,ffffffffc020086c <best_fit_alloc_pages+0x2a>
    if (page != NULL)
ffffffffc0200884:	cd29                	beqz	a0,ffffffffc02008de <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200886:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200888:	6d18                	ld	a4,24(a0)
        if (page->property > n)
ffffffffc020088a:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc020088c:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200890:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200892:	e398                	sd	a4,0(a5)
        if (page->property > n)
ffffffffc0200894:	02059793          	slli	a5,a1,0x20
ffffffffc0200898:	9381                	srli	a5,a5,0x20
ffffffffc020089a:	02f6f863          	bgeu	a3,a5,ffffffffc02008ca <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc020089e:	00269793          	slli	a5,a3,0x2
ffffffffc02008a2:	97b6                	add	a5,a5,a3
ffffffffc02008a4:	078e                	slli	a5,a5,0x3
ffffffffc02008a6:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02008a8:	411585bb          	subw	a1,a1,a7
ffffffffc02008ac:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008ae:	4689                	li	a3,2
ffffffffc02008b0:	00878593          	addi	a1,a5,8
ffffffffc02008b4:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008b8:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc02008ba:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc02008be:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc02008c2:	e28c                	sd	a1,0(a3)
ffffffffc02008c4:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008c6:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008c8:	ef98                	sd	a4,24(a5)
ffffffffc02008ca:	4118083b          	subw	a6,a6,a7
ffffffffc02008ce:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008d2:	57f5                	li	a5,-3
ffffffffc02008d4:	00850713          	addi	a4,a0,8
ffffffffc02008d8:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008dc:	8082                	ret
}
ffffffffc02008de:	8082                	ret
        return NULL;
ffffffffc02008e0:	4501                	li	a0,0
ffffffffc02008e2:	8082                	ret
{
ffffffffc02008e4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008e6:	00004697          	auipc	a3,0x4
ffffffffc02008ea:	c2268693          	addi	a3,a3,-990 # ffffffffc0204508 <commands+0x4f8>
ffffffffc02008ee:	00004617          	auipc	a2,0x4
ffffffffc02008f2:	c2260613          	addi	a2,a2,-990 # ffffffffc0204510 <commands+0x500>
ffffffffc02008f6:	07e00593          	li	a1,126
ffffffffc02008fa:	00004517          	auipc	a0,0x4
ffffffffc02008fe:	c2e50513          	addi	a0,a0,-978 # ffffffffc0204528 <commands+0x518>
{
ffffffffc0200902:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200904:	acdff0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0200908 <best_fit_check>:

// LAB2: below code is used to check the best fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void)
{
ffffffffc0200908:	715d                	addi	sp,sp,-80
ffffffffc020090a:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020090c:	00008417          	auipc	s0,0x8
ffffffffc0200910:	70440413          	addi	s0,s0,1796 # ffffffffc0209010 <free_area>
ffffffffc0200914:	641c                	ld	a5,8(s0)
ffffffffc0200916:	e486                	sd	ra,72(sp)
ffffffffc0200918:	fc26                	sd	s1,56(sp)
ffffffffc020091a:	f84a                	sd	s2,48(sp)
ffffffffc020091c:	f44e                	sd	s3,40(sp)
ffffffffc020091e:	f052                	sd	s4,32(sp)
ffffffffc0200920:	ec56                	sd	s5,24(sp)
ffffffffc0200922:	e85a                	sd	s6,16(sp)
ffffffffc0200924:	e45e                	sd	s7,8(sp)
ffffffffc0200926:	e062                	sd	s8,0(sp)
    int score = 0, sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200928:	28878763          	beq	a5,s0,ffffffffc0200bb6 <best_fit_check+0x2ae>
    int count = 0, total = 0;
ffffffffc020092c:	4481                	li	s1,0
ffffffffc020092e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200930:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200934:	8b09                	andi	a4,a4,2
ffffffffc0200936:	28070463          	beqz	a4,ffffffffc0200bbe <best_fit_check+0x2b6>
        count++, total += p->property;
ffffffffc020093a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020093e:	679c                	ld	a5,8(a5)
ffffffffc0200940:	2905                	addiw	s2,s2,1
ffffffffc0200942:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200944:	fe8796e3          	bne	a5,s0,ffffffffc0200930 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200948:	89a6                	mv	s3,s1
ffffffffc020094a:	19e020ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc020094e:	35351863          	bne	a0,s3,ffffffffc0200c9e <best_fit_check+0x396>
    cprintf("[best fit] basic_check() started\n");
ffffffffc0200952:	00004517          	auipc	a0,0x4
ffffffffc0200956:	c1e50513          	addi	a0,a0,-994 # ffffffffc0204570 <commands+0x560>
ffffffffc020095a:	f7cff0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020095e:	4505                	li	a0,1
ffffffffc0200960:	10a020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200964:	8a2a                	mv	s4,a0
ffffffffc0200966:	36050c63          	beqz	a0,ffffffffc0200cde <best_fit_check+0x3d6>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020096a:	4505                	li	a0,1
ffffffffc020096c:	0fe020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200970:	89aa                	mv	s3,a0
ffffffffc0200972:	34050663          	beqz	a0,ffffffffc0200cbe <best_fit_check+0x3b6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200976:	4505                	li	a0,1
ffffffffc0200978:	0f2020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc020097c:	8aaa                	mv	s5,a0
ffffffffc020097e:	2e050063          	beqz	a0,ffffffffc0200c5e <best_fit_check+0x356>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200982:	253a0e63          	beq	s4,s3,ffffffffc0200bde <best_fit_check+0x2d6>
ffffffffc0200986:	24aa0c63          	beq	s4,a0,ffffffffc0200bde <best_fit_check+0x2d6>
ffffffffc020098a:	24a98a63          	beq	s3,a0,ffffffffc0200bde <best_fit_check+0x2d6>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020098e:	000a2783          	lw	a5,0(s4)
ffffffffc0200992:	26079663          	bnez	a5,ffffffffc0200bfe <best_fit_check+0x2f6>
ffffffffc0200996:	0009a783          	lw	a5,0(s3)
ffffffffc020099a:	26079263          	bnez	a5,ffffffffc0200bfe <best_fit_check+0x2f6>
ffffffffc020099e:	411c                	lw	a5,0(a0)
ffffffffc02009a0:	24079f63          	bnez	a5,ffffffffc0200bfe <best_fit_check+0x2f6>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009a4:	00009797          	auipc	a5,0x9
ffffffffc02009a8:	b8c7b783          	ld	a5,-1140(a5) # ffffffffc0209530 <pages>
ffffffffc02009ac:	40fa0733          	sub	a4,s4,a5
ffffffffc02009b0:	870d                	srai	a4,a4,0x3
ffffffffc02009b2:	00005597          	auipc	a1,0x5
ffffffffc02009b6:	d365b583          	ld	a1,-714(a1) # ffffffffc02056e8 <error_string+0x38>
ffffffffc02009ba:	02b70733          	mul	a4,a4,a1
ffffffffc02009be:	00005617          	auipc	a2,0x5
ffffffffc02009c2:	d3263603          	ld	a2,-718(a2) # ffffffffc02056f0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009c6:	00009697          	auipc	a3,0x9
ffffffffc02009ca:	b626b683          	ld	a3,-1182(a3) # ffffffffc0209528 <npage>
ffffffffc02009ce:	06b2                	slli	a3,a3,0xc
ffffffffc02009d0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009d2:	0732                	slli	a4,a4,0xc
ffffffffc02009d4:	24d77563          	bgeu	a4,a3,ffffffffc0200c1e <best_fit_check+0x316>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009d8:	40f98733          	sub	a4,s3,a5
ffffffffc02009dc:	870d                	srai	a4,a4,0x3
ffffffffc02009de:	02b70733          	mul	a4,a4,a1
ffffffffc02009e2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009e4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009e6:	3ed77c63          	bgeu	a4,a3,ffffffffc0200dde <best_fit_check+0x4d6>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ea:	40f507b3          	sub	a5,a0,a5
ffffffffc02009ee:	878d                	srai	a5,a5,0x3
ffffffffc02009f0:	02b787b3          	mul	a5,a5,a1
ffffffffc02009f4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009f6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009f8:	3cd7f363          	bgeu	a5,a3,ffffffffc0200dbe <best_fit_check+0x4b6>
    assert(alloc_page() == NULL);
ffffffffc02009fc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009fe:	00043c03          	ld	s8,0(s0)
ffffffffc0200a02:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a06:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200a0a:	e400                	sd	s0,8(s0)
ffffffffc0200a0c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200a0e:	00008797          	auipc	a5,0x8
ffffffffc0200a12:	6007a923          	sw	zero,1554(a5) # ffffffffc0209020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a16:	054020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a1a:	38051263          	bnez	a0,ffffffffc0200d9e <best_fit_check+0x496>
    free_page(p0);
ffffffffc0200a1e:	4585                	li	a1,1
ffffffffc0200a20:	8552                	mv	a0,s4
ffffffffc0200a22:	086020ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p1);
ffffffffc0200a26:	4585                	li	a1,1
ffffffffc0200a28:	854e                	mv	a0,s3
ffffffffc0200a2a:	07e020ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0200a2e:	4585                	li	a1,1
ffffffffc0200a30:	8556                	mv	a0,s5
ffffffffc0200a32:	076020ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a36:	4818                	lw	a4,16(s0)
ffffffffc0200a38:	478d                	li	a5,3
ffffffffc0200a3a:	34f71263          	bne	a4,a5,ffffffffc0200d7e <best_fit_check+0x476>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a3e:	4505                	li	a0,1
ffffffffc0200a40:	02a020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a44:	89aa                	mv	s3,a0
ffffffffc0200a46:	30050c63          	beqz	a0,ffffffffc0200d5e <best_fit_check+0x456>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a4a:	4505                	li	a0,1
ffffffffc0200a4c:	01e020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a50:	8aaa                	mv	s5,a0
ffffffffc0200a52:	2e050663          	beqz	a0,ffffffffc0200d3e <best_fit_check+0x436>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a56:	4505                	li	a0,1
ffffffffc0200a58:	012020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a5c:	8a2a                	mv	s4,a0
ffffffffc0200a5e:	2c050063          	beqz	a0,ffffffffc0200d1e <best_fit_check+0x416>
    assert(alloc_page() == NULL);
ffffffffc0200a62:	4505                	li	a0,1
ffffffffc0200a64:	006020ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a68:	28051b63          	bnez	a0,ffffffffc0200cfe <best_fit_check+0x3f6>
    free_page(p0);
ffffffffc0200a6c:	4585                	li	a1,1
ffffffffc0200a6e:	854e                	mv	a0,s3
ffffffffc0200a70:	038020ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a74:	641c                	ld	a5,8(s0)
ffffffffc0200a76:	1c878463          	beq	a5,s0,ffffffffc0200c3e <best_fit_check+0x336>
    assert((p = alloc_page()) == p0);
ffffffffc0200a7a:	4505                	li	a0,1
ffffffffc0200a7c:	7ef010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a80:	52a99f63          	bne	s3,a0,ffffffffc0200fbe <best_fit_check+0x6b6>
    assert(alloc_page() == NULL);
ffffffffc0200a84:	4505                	li	a0,1
ffffffffc0200a86:	7e5010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200a8a:	50051a63          	bnez	a0,ffffffffc0200f9e <best_fit_check+0x696>
    assert(nr_free == 0);
ffffffffc0200a8e:	481c                	lw	a5,16(s0)
ffffffffc0200a90:	4e079763          	bnez	a5,ffffffffc0200f7e <best_fit_check+0x676>
    free_page(p);
ffffffffc0200a94:	854e                	mv	a0,s3
ffffffffc0200a96:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a98:	01843023          	sd	s8,0(s0)
ffffffffc0200a9c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200aa0:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200aa4:	004020ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p1);
ffffffffc0200aa8:	4585                	li	a1,1
ffffffffc0200aaa:	8556                	mv	a0,s5
ffffffffc0200aac:	7fd010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0200ab0:	4585                	li	a1,1
ffffffffc0200ab2:	8552                	mv	a0,s4
ffffffffc0200ab4:	7f5010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    cprintf("[best fit] basic_check() succeeded\n");
ffffffffc0200ab8:	00004517          	auipc	a0,0x4
ffffffffc0200abc:	c7850513          	addi	a0,a0,-904 # ffffffffc0204730 <commands+0x720>
ffffffffc0200ac0:	e16ff0ef          	jal	ra,ffffffffc02000d6 <cprintf>

#ifdef ucore_test
    score += 1;
    cprintf("[best fit] grading: %d / %d points\n", score, sumscore);
#endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ac4:	4515                	li	a0,5
ffffffffc0200ac6:	7a5010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200aca:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200acc:	48050963          	beqz	a0,ffffffffc0200f5e <best_fit_check+0x656>
ffffffffc0200ad0:	651c                	ld	a5,8(a0)
ffffffffc0200ad2:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ad4:	8b85                	andi	a5,a5,1
ffffffffc0200ad6:	46079463          	bnez	a5,ffffffffc0200f3e <best_fit_check+0x636>
    cprintf("[best fit] grading: %d / %d points\n", score, sumscore);
#endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ada:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200adc:	00043a83          	ld	s5,0(s0)
ffffffffc0200ae0:	00843a03          	ld	s4,8(s0)
ffffffffc0200ae4:	e000                	sd	s0,0(s0)
ffffffffc0200ae6:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200ae8:	783010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200aec:	42051963          	bnez	a0,ffffffffc0200f1e <best_fit_check+0x616>
#endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200af0:	4589                	li	a1,2
ffffffffc0200af2:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200af6:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200afa:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200afe:	00008797          	auipc	a5,0x8
ffffffffc0200b02:	5207a123          	sw	zero,1314(a5) # ffffffffc0209020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b06:	7a3010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b0a:	8562                	mv	a0,s8
ffffffffc0200b0c:	4585                	li	a1,1
ffffffffc0200b0e:	79b010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b12:	4511                	li	a0,4
ffffffffc0200b14:	757010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200b18:	3e051363          	bnez	a0,ffffffffc0200efe <best_fit_check+0x5f6>
ffffffffc0200b1c:	0309b783          	ld	a5,48(s3)
ffffffffc0200b20:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b22:	8b85                	andi	a5,a5,1
ffffffffc0200b24:	3a078d63          	beqz	a5,ffffffffc0200ede <best_fit_check+0x5d6>
ffffffffc0200b28:	0389a703          	lw	a4,56(s3)
ffffffffc0200b2c:	4789                	li	a5,2
ffffffffc0200b2e:	3af71863          	bne	a4,a5,ffffffffc0200ede <best_fit_check+0x5d6>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b32:	4505                	li	a0,1
ffffffffc0200b34:	737010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200b38:	8baa                	mv	s7,a0
ffffffffc0200b3a:	38050263          	beqz	a0,ffffffffc0200ebe <best_fit_check+0x5b6>
    assert(alloc_pages(2) != NULL); // best fit feature
ffffffffc0200b3e:	4509                	li	a0,2
ffffffffc0200b40:	72b010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200b44:	34050d63          	beqz	a0,ffffffffc0200e9e <best_fit_check+0x596>
    assert(p0 + 4 == p1);
ffffffffc0200b48:	337c1b63          	bne	s8,s7,ffffffffc0200e7e <best_fit_check+0x576>
#ifdef ucore_test
    score += 1;
    cprintf("[best fit] grading: %d / %d points\n", score, sumscore);
#endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b4c:	854e                	mv	a0,s3
ffffffffc0200b4e:	4595                	li	a1,5
ffffffffc0200b50:	759010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b54:	4515                	li	a0,5
ffffffffc0200b56:	715010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200b5a:	89aa                	mv	s3,a0
ffffffffc0200b5c:	30050163          	beqz	a0,ffffffffc0200e5e <best_fit_check+0x556>
    assert(alloc_page() == NULL);
ffffffffc0200b60:	4505                	li	a0,1
ffffffffc0200b62:	709010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0200b66:	2c051c63          	bnez	a0,ffffffffc0200e3e <best_fit_check+0x536>

#ifdef ucore_test
    score += 1;
    cprintf("[best fit] grading: %d / %d points\n", score, sumscore);
#endif
    assert(nr_free == 0);
ffffffffc0200b6a:	481c                	lw	a5,16(s0)
ffffffffc0200b6c:	2a079963          	bnez	a5,ffffffffc0200e1e <best_fit_check+0x516>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b70:	4595                	li	a1,5
ffffffffc0200b72:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b74:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b78:	01543023          	sd	s5,0(s0)
ffffffffc0200b7c:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b80:	729010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    return listelm->next;
ffffffffc0200b84:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b86:	00878963          	beq	a5,s0,ffffffffc0200b98 <best_fit_check+0x290>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0200b8a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b8e:	679c                	ld	a5,8(a5)
ffffffffc0200b90:	397d                	addiw	s2,s2,-1
ffffffffc0200b92:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b94:	fe879be3          	bne	a5,s0,ffffffffc0200b8a <best_fit_check+0x282>
    }
    assert(count == 0);
ffffffffc0200b98:	26091363          	bnez	s2,ffffffffc0200dfe <best_fit_check+0x4f6>
    assert(total == 0);
ffffffffc0200b9c:	e0ed                	bnez	s1,ffffffffc0200c7e <best_fit_check+0x376>
#ifdef ucore_test
    score += 1;
    cprintf("[best fit] grading: %d / %d points\n", score, sumscore);
#endif
}
ffffffffc0200b9e:	60a6                	ld	ra,72(sp)
ffffffffc0200ba0:	6406                	ld	s0,64(sp)
ffffffffc0200ba2:	74e2                	ld	s1,56(sp)
ffffffffc0200ba4:	7942                	ld	s2,48(sp)
ffffffffc0200ba6:	79a2                	ld	s3,40(sp)
ffffffffc0200ba8:	7a02                	ld	s4,32(sp)
ffffffffc0200baa:	6ae2                	ld	s5,24(sp)
ffffffffc0200bac:	6b42                	ld	s6,16(sp)
ffffffffc0200bae:	6ba2                	ld	s7,8(sp)
ffffffffc0200bb0:	6c02                	ld	s8,0(sp)
ffffffffc0200bb2:	6161                	addi	sp,sp,80
ffffffffc0200bb4:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0200bb6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bb8:	4481                	li	s1,0
ffffffffc0200bba:	4901                	li	s2,0
ffffffffc0200bbc:	b379                	j	ffffffffc020094a <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200bbe:	00004697          	auipc	a3,0x4
ffffffffc0200bc2:	98268693          	addi	a3,a3,-1662 # ffffffffc0204540 <commands+0x530>
ffffffffc0200bc6:	00004617          	auipc	a2,0x4
ffffffffc0200bca:	94a60613          	addi	a2,a2,-1718 # ffffffffc0204510 <commands+0x500>
ffffffffc0200bce:	13600593          	li	a1,310
ffffffffc0200bd2:	00004517          	auipc	a0,0x4
ffffffffc0200bd6:	95650513          	addi	a0,a0,-1706 # ffffffffc0204528 <commands+0x518>
ffffffffc0200bda:	ff6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bde:	00004697          	auipc	a3,0x4
ffffffffc0200be2:	a1a68693          	addi	a3,a3,-1510 # ffffffffc02045f8 <commands+0x5e8>
ffffffffc0200be6:	00004617          	auipc	a2,0x4
ffffffffc0200bea:	92a60613          	addi	a2,a2,-1750 # ffffffffc0204510 <commands+0x500>
ffffffffc0200bee:	0fe00593          	li	a1,254
ffffffffc0200bf2:	00004517          	auipc	a0,0x4
ffffffffc0200bf6:	93650513          	addi	a0,a0,-1738 # ffffffffc0204528 <commands+0x518>
ffffffffc0200bfa:	fd6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bfe:	00004697          	auipc	a3,0x4
ffffffffc0200c02:	a2268693          	addi	a3,a3,-1502 # ffffffffc0204620 <commands+0x610>
ffffffffc0200c06:	00004617          	auipc	a2,0x4
ffffffffc0200c0a:	90a60613          	addi	a2,a2,-1782 # ffffffffc0204510 <commands+0x500>
ffffffffc0200c0e:	0ff00593          	li	a1,255
ffffffffc0200c12:	00004517          	auipc	a0,0x4
ffffffffc0200c16:	91650513          	addi	a0,a0,-1770 # ffffffffc0204528 <commands+0x518>
ffffffffc0200c1a:	fb6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c1e:	00004697          	auipc	a3,0x4
ffffffffc0200c22:	a4268693          	addi	a3,a3,-1470 # ffffffffc0204660 <commands+0x650>
ffffffffc0200c26:	00004617          	auipc	a2,0x4
ffffffffc0200c2a:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0204510 <commands+0x500>
ffffffffc0200c2e:	10100593          	li	a1,257
ffffffffc0200c32:	00004517          	auipc	a0,0x4
ffffffffc0200c36:	8f650513          	addi	a0,a0,-1802 # ffffffffc0204528 <commands+0x518>
ffffffffc0200c3a:	f96ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c3e:	00004697          	auipc	a3,0x4
ffffffffc0200c42:	aaa68693          	addi	a3,a3,-1366 # ffffffffc02046e8 <commands+0x6d8>
ffffffffc0200c46:	00004617          	auipc	a2,0x4
ffffffffc0200c4a:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0204510 <commands+0x500>
ffffffffc0200c4e:	11a00593          	li	a1,282
ffffffffc0200c52:	00004517          	auipc	a0,0x4
ffffffffc0200c56:	8d650513          	addi	a0,a0,-1834 # ffffffffc0204528 <commands+0x518>
ffffffffc0200c5a:	f76ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c5e:	00004697          	auipc	a3,0x4
ffffffffc0200c62:	97a68693          	addi	a3,a3,-1670 # ffffffffc02045d8 <commands+0x5c8>
ffffffffc0200c66:	00004617          	auipc	a2,0x4
ffffffffc0200c6a:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0204510 <commands+0x500>
ffffffffc0200c6e:	0fc00593          	li	a1,252
ffffffffc0200c72:	00004517          	auipc	a0,0x4
ffffffffc0200c76:	8b650513          	addi	a0,a0,-1866 # ffffffffc0204528 <commands+0x518>
ffffffffc0200c7a:	f56ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(total == 0);
ffffffffc0200c7e:	00004697          	auipc	a3,0x4
ffffffffc0200c82:	bc268693          	addi	a3,a3,-1086 # ffffffffc0204840 <commands+0x830>
ffffffffc0200c86:	00004617          	auipc	a2,0x4
ffffffffc0200c8a:	88a60613          	addi	a2,a2,-1910 # ffffffffc0204510 <commands+0x500>
ffffffffc0200c8e:	17900593          	li	a1,377
ffffffffc0200c92:	00004517          	auipc	a0,0x4
ffffffffc0200c96:	89650513          	addi	a0,a0,-1898 # ffffffffc0204528 <commands+0x518>
ffffffffc0200c9a:	f36ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c9e:	00004697          	auipc	a3,0x4
ffffffffc0200ca2:	8b268693          	addi	a3,a3,-1870 # ffffffffc0204550 <commands+0x540>
ffffffffc0200ca6:	00004617          	auipc	a2,0x4
ffffffffc0200caa:	86a60613          	addi	a2,a2,-1942 # ffffffffc0204510 <commands+0x500>
ffffffffc0200cae:	13900593          	li	a1,313
ffffffffc0200cb2:	00004517          	auipc	a0,0x4
ffffffffc0200cb6:	87650513          	addi	a0,a0,-1930 # ffffffffc0204528 <commands+0x518>
ffffffffc0200cba:	f16ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cbe:	00004697          	auipc	a3,0x4
ffffffffc0200cc2:	8fa68693          	addi	a3,a3,-1798 # ffffffffc02045b8 <commands+0x5a8>
ffffffffc0200cc6:	00004617          	auipc	a2,0x4
ffffffffc0200cca:	84a60613          	addi	a2,a2,-1974 # ffffffffc0204510 <commands+0x500>
ffffffffc0200cce:	0fb00593          	li	a1,251
ffffffffc0200cd2:	00004517          	auipc	a0,0x4
ffffffffc0200cd6:	85650513          	addi	a0,a0,-1962 # ffffffffc0204528 <commands+0x518>
ffffffffc0200cda:	ef6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cde:	00004697          	auipc	a3,0x4
ffffffffc0200ce2:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0204598 <commands+0x588>
ffffffffc0200ce6:	00004617          	auipc	a2,0x4
ffffffffc0200cea:	82a60613          	addi	a2,a2,-2006 # ffffffffc0204510 <commands+0x500>
ffffffffc0200cee:	0fa00593          	li	a1,250
ffffffffc0200cf2:	00004517          	auipc	a0,0x4
ffffffffc0200cf6:	83650513          	addi	a0,a0,-1994 # ffffffffc0204528 <commands+0x518>
ffffffffc0200cfa:	ed6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cfe:	00004697          	auipc	a3,0x4
ffffffffc0200d02:	9c268693          	addi	a3,a3,-1598 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0200d06:	00004617          	auipc	a2,0x4
ffffffffc0200d0a:	80a60613          	addi	a2,a2,-2038 # ffffffffc0204510 <commands+0x500>
ffffffffc0200d0e:	11700593          	li	a1,279
ffffffffc0200d12:	00004517          	auipc	a0,0x4
ffffffffc0200d16:	81650513          	addi	a0,a0,-2026 # ffffffffc0204528 <commands+0x518>
ffffffffc0200d1a:	eb6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d1e:	00004697          	auipc	a3,0x4
ffffffffc0200d22:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02045d8 <commands+0x5c8>
ffffffffc0200d26:	00003617          	auipc	a2,0x3
ffffffffc0200d2a:	7ea60613          	addi	a2,a2,2026 # ffffffffc0204510 <commands+0x500>
ffffffffc0200d2e:	11500593          	li	a1,277
ffffffffc0200d32:	00003517          	auipc	a0,0x3
ffffffffc0200d36:	7f650513          	addi	a0,a0,2038 # ffffffffc0204528 <commands+0x518>
ffffffffc0200d3a:	e96ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d3e:	00004697          	auipc	a3,0x4
ffffffffc0200d42:	87a68693          	addi	a3,a3,-1926 # ffffffffc02045b8 <commands+0x5a8>
ffffffffc0200d46:	00003617          	auipc	a2,0x3
ffffffffc0200d4a:	7ca60613          	addi	a2,a2,1994 # ffffffffc0204510 <commands+0x500>
ffffffffc0200d4e:	11400593          	li	a1,276
ffffffffc0200d52:	00003517          	auipc	a0,0x3
ffffffffc0200d56:	7d650513          	addi	a0,a0,2006 # ffffffffc0204528 <commands+0x518>
ffffffffc0200d5a:	e76ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d5e:	00004697          	auipc	a3,0x4
ffffffffc0200d62:	83a68693          	addi	a3,a3,-1990 # ffffffffc0204598 <commands+0x588>
ffffffffc0200d66:	00003617          	auipc	a2,0x3
ffffffffc0200d6a:	7aa60613          	addi	a2,a2,1962 # ffffffffc0204510 <commands+0x500>
ffffffffc0200d6e:	11300593          	li	a1,275
ffffffffc0200d72:	00003517          	auipc	a0,0x3
ffffffffc0200d76:	7b650513          	addi	a0,a0,1974 # ffffffffc0204528 <commands+0x518>
ffffffffc0200d7a:	e56ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 3);
ffffffffc0200d7e:	00004697          	auipc	a3,0x4
ffffffffc0200d82:	95a68693          	addi	a3,a3,-1702 # ffffffffc02046d8 <commands+0x6c8>
ffffffffc0200d86:	00003617          	auipc	a2,0x3
ffffffffc0200d8a:	78a60613          	addi	a2,a2,1930 # ffffffffc0204510 <commands+0x500>
ffffffffc0200d8e:	11100593          	li	a1,273
ffffffffc0200d92:	00003517          	auipc	a0,0x3
ffffffffc0200d96:	79650513          	addi	a0,a0,1942 # ffffffffc0204528 <commands+0x518>
ffffffffc0200d9a:	e36ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d9e:	00004697          	auipc	a3,0x4
ffffffffc0200da2:	92268693          	addi	a3,a3,-1758 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0200da6:	00003617          	auipc	a2,0x3
ffffffffc0200daa:	76a60613          	addi	a2,a2,1898 # ffffffffc0204510 <commands+0x500>
ffffffffc0200dae:	10c00593          	li	a1,268
ffffffffc0200db2:	00003517          	auipc	a0,0x3
ffffffffc0200db6:	77650513          	addi	a0,a0,1910 # ffffffffc0204528 <commands+0x518>
ffffffffc0200dba:	e16ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200dbe:	00004697          	auipc	a3,0x4
ffffffffc0200dc2:	8e268693          	addi	a3,a3,-1822 # ffffffffc02046a0 <commands+0x690>
ffffffffc0200dc6:	00003617          	auipc	a2,0x3
ffffffffc0200dca:	74a60613          	addi	a2,a2,1866 # ffffffffc0204510 <commands+0x500>
ffffffffc0200dce:	10300593          	li	a1,259
ffffffffc0200dd2:	00003517          	auipc	a0,0x3
ffffffffc0200dd6:	75650513          	addi	a0,a0,1878 # ffffffffc0204528 <commands+0x518>
ffffffffc0200dda:	df6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200dde:	00004697          	auipc	a3,0x4
ffffffffc0200de2:	8a268693          	addi	a3,a3,-1886 # ffffffffc0204680 <commands+0x670>
ffffffffc0200de6:	00003617          	auipc	a2,0x3
ffffffffc0200dea:	72a60613          	addi	a2,a2,1834 # ffffffffc0204510 <commands+0x500>
ffffffffc0200dee:	10200593          	li	a1,258
ffffffffc0200df2:	00003517          	auipc	a0,0x3
ffffffffc0200df6:	73650513          	addi	a0,a0,1846 # ffffffffc0204528 <commands+0x518>
ffffffffc0200dfa:	dd6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(count == 0);
ffffffffc0200dfe:	00004697          	auipc	a3,0x4
ffffffffc0200e02:	a3268693          	addi	a3,a3,-1486 # ffffffffc0204830 <commands+0x820>
ffffffffc0200e06:	00003617          	auipc	a2,0x3
ffffffffc0200e0a:	70a60613          	addi	a2,a2,1802 # ffffffffc0204510 <commands+0x500>
ffffffffc0200e0e:	17800593          	li	a1,376
ffffffffc0200e12:	00003517          	auipc	a0,0x3
ffffffffc0200e16:	71650513          	addi	a0,a0,1814 # ffffffffc0204528 <commands+0x518>
ffffffffc0200e1a:	db6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 0);
ffffffffc0200e1e:	00004697          	auipc	a3,0x4
ffffffffc0200e22:	90268693          	addi	a3,a3,-1790 # ffffffffc0204720 <commands+0x710>
ffffffffc0200e26:	00003617          	auipc	a2,0x3
ffffffffc0200e2a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0204510 <commands+0x500>
ffffffffc0200e2e:	16c00593          	li	a1,364
ffffffffc0200e32:	00003517          	auipc	a0,0x3
ffffffffc0200e36:	6f650513          	addi	a0,a0,1782 # ffffffffc0204528 <commands+0x518>
ffffffffc0200e3a:	d96ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e3e:	00004697          	auipc	a3,0x4
ffffffffc0200e42:	88268693          	addi	a3,a3,-1918 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0200e46:	00003617          	auipc	a2,0x3
ffffffffc0200e4a:	6ca60613          	addi	a2,a2,1738 # ffffffffc0204510 <commands+0x500>
ffffffffc0200e4e:	16600593          	li	a1,358
ffffffffc0200e52:	00003517          	auipc	a0,0x3
ffffffffc0200e56:	6d650513          	addi	a0,a0,1750 # ffffffffc0204528 <commands+0x518>
ffffffffc0200e5a:	d76ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e5e:	00004697          	auipc	a3,0x4
ffffffffc0200e62:	9b268693          	addi	a3,a3,-1614 # ffffffffc0204810 <commands+0x800>
ffffffffc0200e66:	00003617          	auipc	a2,0x3
ffffffffc0200e6a:	6aa60613          	addi	a2,a2,1706 # ffffffffc0204510 <commands+0x500>
ffffffffc0200e6e:	16500593          	li	a1,357
ffffffffc0200e72:	00003517          	auipc	a0,0x3
ffffffffc0200e76:	6b650513          	addi	a0,a0,1718 # ffffffffc0204528 <commands+0x518>
ffffffffc0200e7a:	d56ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e7e:	00004697          	auipc	a3,0x4
ffffffffc0200e82:	98268693          	addi	a3,a3,-1662 # ffffffffc0204800 <commands+0x7f0>
ffffffffc0200e86:	00003617          	auipc	a2,0x3
ffffffffc0200e8a:	68a60613          	addi	a2,a2,1674 # ffffffffc0204510 <commands+0x500>
ffffffffc0200e8e:	15d00593          	li	a1,349
ffffffffc0200e92:	00003517          	auipc	a0,0x3
ffffffffc0200e96:	69650513          	addi	a0,a0,1686 # ffffffffc0204528 <commands+0x518>
ffffffffc0200e9a:	d36ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_pages(2) != NULL); // best fit feature
ffffffffc0200e9e:	00004697          	auipc	a3,0x4
ffffffffc0200ea2:	94a68693          	addi	a3,a3,-1718 # ffffffffc02047e8 <commands+0x7d8>
ffffffffc0200ea6:	00003617          	auipc	a2,0x3
ffffffffc0200eaa:	66a60613          	addi	a2,a2,1642 # ffffffffc0204510 <commands+0x500>
ffffffffc0200eae:	15c00593          	li	a1,348
ffffffffc0200eb2:	00003517          	auipc	a0,0x3
ffffffffc0200eb6:	67650513          	addi	a0,a0,1654 # ffffffffc0204528 <commands+0x518>
ffffffffc0200eba:	d16ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200ebe:	00004697          	auipc	a3,0x4
ffffffffc0200ec2:	90a68693          	addi	a3,a3,-1782 # ffffffffc02047c8 <commands+0x7b8>
ffffffffc0200ec6:	00003617          	auipc	a2,0x3
ffffffffc0200eca:	64a60613          	addi	a2,a2,1610 # ffffffffc0204510 <commands+0x500>
ffffffffc0200ece:	15b00593          	li	a1,347
ffffffffc0200ed2:	00003517          	auipc	a0,0x3
ffffffffc0200ed6:	65650513          	addi	a0,a0,1622 # ffffffffc0204528 <commands+0x518>
ffffffffc0200eda:	cf6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ede:	00004697          	auipc	a3,0x4
ffffffffc0200ee2:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0204798 <commands+0x788>
ffffffffc0200ee6:	00003617          	auipc	a2,0x3
ffffffffc0200eea:	62a60613          	addi	a2,a2,1578 # ffffffffc0204510 <commands+0x500>
ffffffffc0200eee:	15900593          	li	a1,345
ffffffffc0200ef2:	00003517          	auipc	a0,0x3
ffffffffc0200ef6:	63650513          	addi	a0,a0,1590 # ffffffffc0204528 <commands+0x518>
ffffffffc0200efa:	cd6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200efe:	00004697          	auipc	a3,0x4
ffffffffc0200f02:	88268693          	addi	a3,a3,-1918 # ffffffffc0204780 <commands+0x770>
ffffffffc0200f06:	00003617          	auipc	a2,0x3
ffffffffc0200f0a:	60a60613          	addi	a2,a2,1546 # ffffffffc0204510 <commands+0x500>
ffffffffc0200f0e:	15800593          	li	a1,344
ffffffffc0200f12:	00003517          	auipc	a0,0x3
ffffffffc0200f16:	61650513          	addi	a0,a0,1558 # ffffffffc0204528 <commands+0x518>
ffffffffc0200f1a:	cb6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f1e:	00003697          	auipc	a3,0x3
ffffffffc0200f22:	7a268693          	addi	a3,a3,1954 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0200f26:	00003617          	auipc	a2,0x3
ffffffffc0200f2a:	5ea60613          	addi	a2,a2,1514 # ffffffffc0204510 <commands+0x500>
ffffffffc0200f2e:	14c00593          	li	a1,332
ffffffffc0200f32:	00003517          	auipc	a0,0x3
ffffffffc0200f36:	5f650513          	addi	a0,a0,1526 # ffffffffc0204528 <commands+0x518>
ffffffffc0200f3a:	c96ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f3e:	00004697          	auipc	a3,0x4
ffffffffc0200f42:	82a68693          	addi	a3,a3,-2006 # ffffffffc0204768 <commands+0x758>
ffffffffc0200f46:	00003617          	auipc	a2,0x3
ffffffffc0200f4a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0204510 <commands+0x500>
ffffffffc0200f4e:	14300593          	li	a1,323
ffffffffc0200f52:	00003517          	auipc	a0,0x3
ffffffffc0200f56:	5d650513          	addi	a0,a0,1494 # ffffffffc0204528 <commands+0x518>
ffffffffc0200f5a:	c76ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(p0 != NULL);
ffffffffc0200f5e:	00003697          	auipc	a3,0x3
ffffffffc0200f62:	7fa68693          	addi	a3,a3,2042 # ffffffffc0204758 <commands+0x748>
ffffffffc0200f66:	00003617          	auipc	a2,0x3
ffffffffc0200f6a:	5aa60613          	addi	a2,a2,1450 # ffffffffc0204510 <commands+0x500>
ffffffffc0200f6e:	14200593          	li	a1,322
ffffffffc0200f72:	00003517          	auipc	a0,0x3
ffffffffc0200f76:	5b650513          	addi	a0,a0,1462 # ffffffffc0204528 <commands+0x518>
ffffffffc0200f7a:	c56ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 0);
ffffffffc0200f7e:	00003697          	auipc	a3,0x3
ffffffffc0200f82:	7a268693          	addi	a3,a3,1954 # ffffffffc0204720 <commands+0x710>
ffffffffc0200f86:	00003617          	auipc	a2,0x3
ffffffffc0200f8a:	58a60613          	addi	a2,a2,1418 # ffffffffc0204510 <commands+0x500>
ffffffffc0200f8e:	12000593          	li	a1,288
ffffffffc0200f92:	00003517          	auipc	a0,0x3
ffffffffc0200f96:	59650513          	addi	a0,a0,1430 # ffffffffc0204528 <commands+0x518>
ffffffffc0200f9a:	c36ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f9e:	00003697          	auipc	a3,0x3
ffffffffc0200fa2:	72268693          	addi	a3,a3,1826 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0200fa6:	00003617          	auipc	a2,0x3
ffffffffc0200faa:	56a60613          	addi	a2,a2,1386 # ffffffffc0204510 <commands+0x500>
ffffffffc0200fae:	11e00593          	li	a1,286
ffffffffc0200fb2:	00003517          	auipc	a0,0x3
ffffffffc0200fb6:	57650513          	addi	a0,a0,1398 # ffffffffc0204528 <commands+0x518>
ffffffffc0200fba:	c16ff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fbe:	00003697          	auipc	a3,0x3
ffffffffc0200fc2:	74268693          	addi	a3,a3,1858 # ffffffffc0204700 <commands+0x6f0>
ffffffffc0200fc6:	00003617          	auipc	a2,0x3
ffffffffc0200fca:	54a60613          	addi	a2,a2,1354 # ffffffffc0204510 <commands+0x500>
ffffffffc0200fce:	11d00593          	li	a1,285
ffffffffc0200fd2:	00003517          	auipc	a0,0x3
ffffffffc0200fd6:	55650513          	addi	a0,a0,1366 # ffffffffc0204528 <commands+0x518>
ffffffffc0200fda:	bf6ff0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0200fde <best_fit_free_pages>:
{
ffffffffc0200fde:	1141                	addi	sp,sp,-16
ffffffffc0200fe0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fe2:	14058a63          	beqz	a1,ffffffffc0201136 <best_fit_free_pages+0x158>
    for (; p != base + n; p++)
ffffffffc0200fe6:	00259693          	slli	a3,a1,0x2
ffffffffc0200fea:	96ae                	add	a3,a3,a1
ffffffffc0200fec:	068e                	slli	a3,a3,0x3
ffffffffc0200fee:	96aa                	add	a3,a3,a0
ffffffffc0200ff0:	87aa                	mv	a5,a0
ffffffffc0200ff2:	02d50263          	beq	a0,a3,ffffffffc0201016 <best_fit_free_pages+0x38>
ffffffffc0200ff6:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ff8:	8b05                	andi	a4,a4,1
ffffffffc0200ffa:	10071e63          	bnez	a4,ffffffffc0201116 <best_fit_free_pages+0x138>
ffffffffc0200ffe:	6798                	ld	a4,8(a5)
ffffffffc0201000:	8b09                	andi	a4,a4,2
ffffffffc0201002:	10071a63          	bnez	a4,ffffffffc0201116 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0201006:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020100a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020100e:	02878793          	addi	a5,a5,40
ffffffffc0201012:	fed792e3          	bne	a5,a3,ffffffffc0200ff6 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0201016:	2581                	sext.w	a1,a1
ffffffffc0201018:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020101a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020101e:	4789                	li	a5,2
ffffffffc0201020:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201024:	00008697          	auipc	a3,0x8
ffffffffc0201028:	fec68693          	addi	a3,a3,-20 # ffffffffc0209010 <free_area>
ffffffffc020102c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020102e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201030:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201034:	9db9                	addw	a1,a1,a4
ffffffffc0201036:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201038:	0ad78863          	beq	a5,a3,ffffffffc02010e8 <best_fit_free_pages+0x10a>
            struct Page *page = le2page(le, page_link);
ffffffffc020103c:	fe878713          	addi	a4,a5,-24
ffffffffc0201040:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201044:	4581                	li	a1,0
            if (base < page)
ffffffffc0201046:	00e56a63          	bltu	a0,a4,ffffffffc020105a <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc020104a:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020104c:	06d70263          	beq	a4,a3,ffffffffc02010b0 <best_fit_free_pages+0xd2>
    for (; p != base + n; p++)
ffffffffc0201050:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201052:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201056:	fee57ae3          	bgeu	a0,a4,ffffffffc020104a <best_fit_free_pages+0x6c>
ffffffffc020105a:	c199                	beqz	a1,ffffffffc0201060 <best_fit_free_pages+0x82>
ffffffffc020105c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201060:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201062:	e390                	sd	a2,0(a5)
ffffffffc0201064:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201066:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201068:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc020106a:	02d70063          	beq	a4,a3,ffffffffc020108a <best_fit_free_pages+0xac>
        if (p + p->property == base)
ffffffffc020106e:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201072:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc0201076:	02081613          	slli	a2,a6,0x20
ffffffffc020107a:	9201                	srli	a2,a2,0x20
ffffffffc020107c:	00261793          	slli	a5,a2,0x2
ffffffffc0201080:	97b2                	add	a5,a5,a2
ffffffffc0201082:	078e                	slli	a5,a5,0x3
ffffffffc0201084:	97ae                	add	a5,a5,a1
ffffffffc0201086:	02f50f63          	beq	a0,a5,ffffffffc02010c4 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc020108a:	7118                	ld	a4,32(a0)
    if (le != &free_list)
ffffffffc020108c:	00d70f63          	beq	a4,a3,ffffffffc02010aa <best_fit_free_pages+0xcc>
        if (base + base->property == p)
ffffffffc0201090:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201092:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p)
ffffffffc0201096:	02059613          	slli	a2,a1,0x20
ffffffffc020109a:	9201                	srli	a2,a2,0x20
ffffffffc020109c:	00261793          	slli	a5,a2,0x2
ffffffffc02010a0:	97b2                	add	a5,a5,a2
ffffffffc02010a2:	078e                	slli	a5,a5,0x3
ffffffffc02010a4:	97aa                	add	a5,a5,a0
ffffffffc02010a6:	04f68863          	beq	a3,a5,ffffffffc02010f6 <best_fit_free_pages+0x118>
}
ffffffffc02010aa:	60a2                	ld	ra,8(sp)
ffffffffc02010ac:	0141                	addi	sp,sp,16
ffffffffc02010ae:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02010b0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010b2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02010b4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010b6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc02010b8:	02d70563          	beq	a4,a3,ffffffffc02010e2 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02010bc:	8832                	mv	a6,a2
ffffffffc02010be:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc02010c0:	87ba                	mv	a5,a4
ffffffffc02010c2:	bf41                	j	ffffffffc0201052 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc02010c4:	491c                	lw	a5,16(a0)
ffffffffc02010c6:	0107883b          	addw	a6,a5,a6
ffffffffc02010ca:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010ce:	57f5                	li	a5,-3
ffffffffc02010d0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010d4:	6d10                	ld	a2,24(a0)
ffffffffc02010d6:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02010d8:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02010da:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010dc:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010de:	e390                	sd	a2,0(a5)
ffffffffc02010e0:	b775                	j	ffffffffc020108c <best_fit_free_pages+0xae>
ffffffffc02010e2:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc02010e4:	873e                	mv	a4,a5
ffffffffc02010e6:	b761                	j	ffffffffc020106e <best_fit_free_pages+0x90>
}
ffffffffc02010e8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02010ea:	e390                	sd	a2,0(a5)
ffffffffc02010ec:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010ee:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010f0:	ed1c                	sd	a5,24(a0)
ffffffffc02010f2:	0141                	addi	sp,sp,16
ffffffffc02010f4:	8082                	ret
            base->property += p->property;
ffffffffc02010f6:	ff872783          	lw	a5,-8(a4)
ffffffffc02010fa:	ff070693          	addi	a3,a4,-16
ffffffffc02010fe:	9dbd                	addw	a1,a1,a5
ffffffffc0201100:	c90c                	sw	a1,16(a0)
ffffffffc0201102:	57f5                	li	a5,-3
ffffffffc0201104:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201108:	6314                	ld	a3,0(a4)
ffffffffc020110a:	671c                	ld	a5,8(a4)
}
ffffffffc020110c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020110e:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201110:	e394                	sd	a3,0(a5)
ffffffffc0201112:	0141                	addi	sp,sp,16
ffffffffc0201114:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201116:	00003697          	auipc	a3,0x3
ffffffffc020111a:	73a68693          	addi	a3,a3,1850 # ffffffffc0204850 <commands+0x840>
ffffffffc020111e:	00003617          	auipc	a2,0x3
ffffffffc0201122:	3f260613          	addi	a2,a2,1010 # ffffffffc0204510 <commands+0x500>
ffffffffc0201126:	0ac00593          	li	a1,172
ffffffffc020112a:	00003517          	auipc	a0,0x3
ffffffffc020112e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204528 <commands+0x518>
ffffffffc0201132:	a9eff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(n > 0);
ffffffffc0201136:	00003697          	auipc	a3,0x3
ffffffffc020113a:	3d268693          	addi	a3,a3,978 # ffffffffc0204508 <commands+0x4f8>
ffffffffc020113e:	00003617          	auipc	a2,0x3
ffffffffc0201142:	3d260613          	addi	a2,a2,978 # ffffffffc0204510 <commands+0x500>
ffffffffc0201146:	0a800593          	li	a1,168
ffffffffc020114a:	00003517          	auipc	a0,0x3
ffffffffc020114e:	3de50513          	addi	a0,a0,990 # ffffffffc0204528 <commands+0x518>
ffffffffc0201152:	a7eff0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0201156 <best_fit_init_memmap>:
{
ffffffffc0201156:	1141                	addi	sp,sp,-16
ffffffffc0201158:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020115a:	c9e1                	beqz	a1,ffffffffc020122a <best_fit_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc020115c:	00259693          	slli	a3,a1,0x2
ffffffffc0201160:	96ae                	add	a3,a3,a1
ffffffffc0201162:	068e                	slli	a3,a3,0x3
ffffffffc0201164:	96aa                	add	a3,a3,a0
ffffffffc0201166:	87aa                	mv	a5,a0
ffffffffc0201168:	00d50f63          	beq	a0,a3,ffffffffc0201186 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020116c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020116e:	8b05                	andi	a4,a4,1
ffffffffc0201170:	cf49                	beqz	a4,ffffffffc020120a <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc0201172:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201176:	0007a823          	sw	zero,16(a5)
ffffffffc020117a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020117e:	02878793          	addi	a5,a5,40
ffffffffc0201182:	fed795e3          	bne	a5,a3,ffffffffc020116c <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201186:	2581                	sext.w	a1,a1
ffffffffc0201188:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020118a:	4789                	li	a5,2
ffffffffc020118c:	00850713          	addi	a4,a0,8
ffffffffc0201190:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201194:	00008697          	auipc	a3,0x8
ffffffffc0201198:	e7c68693          	addi	a3,a3,-388 # ffffffffc0209010 <free_area>
ffffffffc020119c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020119e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02011a0:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02011a4:	9db9                	addw	a1,a1,a4
ffffffffc02011a6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02011a8:	04d78a63          	beq	a5,a3,ffffffffc02011fc <best_fit_init_memmap+0xa6>
            struct Page *page = le2page(le, page_link);
ffffffffc02011ac:	fe878713          	addi	a4,a5,-24
ffffffffc02011b0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02011b4:	4581                	li	a1,0
            if (base < page)
ffffffffc02011b6:	00e56a63          	bltu	a0,a4,ffffffffc02011ca <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc02011ba:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02011bc:	02d70263          	beq	a4,a3,ffffffffc02011e0 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p++)
ffffffffc02011c0:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02011c2:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02011c6:	fee57ae3          	bgeu	a0,a4,ffffffffc02011ba <best_fit_init_memmap+0x64>
ffffffffc02011ca:	c199                	beqz	a1,ffffffffc02011d0 <best_fit_init_memmap+0x7a>
ffffffffc02011cc:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011d0:	6398                	ld	a4,0(a5)
}
ffffffffc02011d2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02011d4:	e390                	sd	a2,0(a5)
ffffffffc02011d6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011d8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011da:	ed18                	sd	a4,24(a0)
ffffffffc02011dc:	0141                	addi	sp,sp,16
ffffffffc02011de:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011e0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011e2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011e4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011e6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc02011e8:	00d70663          	beq	a4,a3,ffffffffc02011f4 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011ec:	8832                	mv	a6,a2
ffffffffc02011ee:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc02011f0:	87ba                	mv	a5,a4
ffffffffc02011f2:	bfc1                	j	ffffffffc02011c2 <best_fit_init_memmap+0x6c>
}
ffffffffc02011f4:	60a2                	ld	ra,8(sp)
ffffffffc02011f6:	e290                	sd	a2,0(a3)
ffffffffc02011f8:	0141                	addi	sp,sp,16
ffffffffc02011fa:	8082                	ret
ffffffffc02011fc:	60a2                	ld	ra,8(sp)
ffffffffc02011fe:	e390                	sd	a2,0(a5)
ffffffffc0201200:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201202:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201204:	ed1c                	sd	a5,24(a0)
ffffffffc0201206:	0141                	addi	sp,sp,16
ffffffffc0201208:	8082                	ret
        assert(PageReserved(p));
ffffffffc020120a:	00003697          	auipc	a3,0x3
ffffffffc020120e:	66e68693          	addi	a3,a3,1646 # ffffffffc0204878 <commands+0x868>
ffffffffc0201212:	00003617          	auipc	a2,0x3
ffffffffc0201216:	2fe60613          	addi	a2,a2,766 # ffffffffc0204510 <commands+0x500>
ffffffffc020121a:	05500593          	li	a1,85
ffffffffc020121e:	00003517          	auipc	a0,0x3
ffffffffc0201222:	30a50513          	addi	a0,a0,778 # ffffffffc0204528 <commands+0x518>
ffffffffc0201226:	9aaff0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(n > 0);
ffffffffc020122a:	00003697          	auipc	a3,0x3
ffffffffc020122e:	2de68693          	addi	a3,a3,734 # ffffffffc0204508 <commands+0x4f8>
ffffffffc0201232:	00003617          	auipc	a2,0x3
ffffffffc0201236:	2de60613          	addi	a2,a2,734 # ffffffffc0204510 <commands+0x500>
ffffffffc020123a:	05100593          	li	a1,81
ffffffffc020123e:	00003517          	auipc	a0,0x3
ffffffffc0201242:	2ea50513          	addi	a0,a0,746 # ffffffffc0204528 <commands+0x518>
ffffffffc0201246:	98aff0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc020124a <buddy_init>:
    elm->prev = elm->next = elm;
ffffffffc020124a:	00008797          	auipc	a5,0x8
ffffffffc020124e:	dc678793          	addi	a5,a5,-570 # ffffffffc0209010 <free_area>
ffffffffc0201252:	e79c                	sd	a5,8(a5)
ffffffffc0201254:	e39c                	sd	a5,0(a5)
#define BUDDY_EMPTY(a) (record_area[(a)] == node_length(full_tree_size, a))

static void buddy_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201256:	0007a823          	sw	zero,16(a5)
}
ffffffffc020125a:	8082                	ret

ffffffffc020125c <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc020125c:	00008517          	auipc	a0,0x8
ffffffffc0201260:	dc456503          	lwu	a0,-572(a0) # ffffffffc0209020 <free_area+0x10>
ffffffffc0201264:	8082                	ret

ffffffffc0201266 <buddy_init_memmap.part.0>:
    for (p = base; p < base + n; p++)
ffffffffc0201266:	00259793          	slli	a5,a1,0x2
ffffffffc020126a:	97ae                	add	a5,a5,a1
static void buddy_init_memmap(struct Page *base, size_t n)
ffffffffc020126c:	7179                	addi	sp,sp,-48
    for (p = base; p < base + n; p++)
ffffffffc020126e:	078e                	slli	a5,a5,0x3
ffffffffc0201270:	00f506b3          	add	a3,a0,a5
static void buddy_init_memmap(struct Page *base, size_t n)
ffffffffc0201274:	f406                	sd	ra,40(sp)
ffffffffc0201276:	f022                	sd	s0,32(sp)
ffffffffc0201278:	ec26                	sd	s1,24(sp)
ffffffffc020127a:	e84a                	sd	s2,16(sp)
ffffffffc020127c:	e44e                	sd	s3,8(sp)
ffffffffc020127e:	e052                	sd	s4,0(sp)
ffffffffc0201280:	882a                	mv	a6,a0
    for (p = base; p < base + n; p++)
ffffffffc0201282:	87aa                	mv	a5,a0
ffffffffc0201284:	00d57e63          	bgeu	a0,a3,ffffffffc02012a0 <buddy_init_memmap.part.0+0x3a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201288:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020128a:	8b05                	andi	a4,a4,1
ffffffffc020128c:	2a070f63          	beqz	a4,ffffffffc020154a <buddy_init_memmap.part.0+0x2e4>
        p->flags = p->property = 0;
ffffffffc0201290:	0007a823          	sw	zero,16(a5)
ffffffffc0201294:	0007b423          	sd	zero,8(a5)
    for (p = base; p < base + n; p++)
ffffffffc0201298:	02878793          	addi	a5,a5,40
ffffffffc020129c:	fed7e6e3          	bltu	a5,a3,ffffffffc0201288 <buddy_init_memmap.part.0+0x22>
    total_size = n;
ffffffffc02012a0:	00008797          	auipc	a5,0x8
ffffffffc02012a4:	28b7b023          	sd	a1,640(a5) # ffffffffc0209520 <total_size>
    if (n < 512)
ffffffffc02012a8:	1ff00793          	li	a5,511
        full_tree_size = power_round_up(n - 1);
ffffffffc02012ac:	fff58713          	addi	a4,a1,-1
    if (n < 512)
ffffffffc02012b0:	24b7e063          	bltu	a5,a1,ffffffffc02014f0 <buddy_init_memmap.part.0+0x28a>
    return (a & (a - 1)) == 0;
ffffffffc02012b4:	15f9                	addi	a1,a1,-2
ffffffffc02012b6:	8df9                	and	a1,a1,a4
        full_tree_size = power_round_up(n - 1);
ffffffffc02012b8:	87ba                	mv	a5,a4
    if (is_power_of_2(a)) return a;
ffffffffc02012ba:	c981                	beqz	a1,ffffffffc02012ca <buddy_init_memmap.part.0+0x64>
    while (res < a) res <<= 1;
ffffffffc02012bc:	4685                	li	a3,1
ffffffffc02012be:	00d70663          	beq	a4,a3,ffffffffc02012ca <buddy_init_memmap.part.0+0x64>
    size_t res = 1;
ffffffffc02012c2:	4785                	li	a5,1
    while (res < a) res <<= 1;
ffffffffc02012c4:	0786                	slli	a5,a5,0x1
ffffffffc02012c6:	fee7efe3          	bltu	a5,a4,ffffffffc02012c4 <buddy_init_memmap.part.0+0x5e>
        record_area_size = 1;
ffffffffc02012ca:	4685                	li	a3,1
        full_tree_size = power_round_up(n - 1);
ffffffffc02012cc:	00008497          	auipc	s1,0x8
ffffffffc02012d0:	22c48493          	addi	s1,s1,556 # ffffffffc02094f8 <full_tree_size>
        record_area_size = 1;
ffffffffc02012d4:	00008617          	auipc	a2,0x8
ffffffffc02012d8:	24d63223          	sd	a3,580(a2) # ffffffffc0209518 <record_area_size>
        full_tree_size = power_round_up(n - 1);
ffffffffc02012dc:	e09c                	sd	a5,0(s1)
        record_area_size = 1;
ffffffffc02012de:	4605                	li	a2,1
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc02012e0:	00008a17          	auipc	s4,0x8
ffffffffc02012e4:	228a0a13          	addi	s4,s4,552 # ffffffffc0209508 <real_tree_size>
ffffffffc02012e8:	20e7e263          	bltu	a5,a4,ffffffffc02014ec <buddy_init_memmap.part.0+0x286>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012ec:	00008697          	auipc	a3,0x8
ffffffffc02012f0:	2446b683          	ld	a3,580(a3) # ffffffffc0209530 <pages>
ffffffffc02012f4:	40d806b3          	sub	a3,a6,a3
ffffffffc02012f8:	00004797          	auipc	a5,0x4
ffffffffc02012fc:	3f07b783          	ld	a5,1008(a5) # ffffffffc02056e8 <error_string+0x38>
ffffffffc0201300:	868d                	srai	a3,a3,0x3
ffffffffc0201302:	02f686b3          	mul	a3,a3,a5
    record_area = KADDR(page2pa(base));
ffffffffc0201306:	59fd                	li	s3,-1
ffffffffc0201308:	00004517          	auipc	a0,0x4
ffffffffc020130c:	3e853503          	ld	a0,1000(a0) # ffffffffc02056f0 <nbase>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0201310:	00ea3023          	sd	a4,0(s4)
    record_area = KADDR(page2pa(base));
ffffffffc0201314:	00c9d793          	srli	a5,s3,0xc
    physical_area = base;
ffffffffc0201318:	00008717          	auipc	a4,0x8
ffffffffc020131c:	1f073423          	sd	a6,488(a4) # ffffffffc0209500 <physical_area>
    record_area = KADDR(page2pa(base));
ffffffffc0201320:	00008717          	auipc	a4,0x8
ffffffffc0201324:	20873703          	ld	a4,520(a4) # ffffffffc0209528 <npage>
ffffffffc0201328:	96aa                	add	a3,a3,a0
ffffffffc020132a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020132c:	06b2                	slli	a3,a3,0xc
ffffffffc020132e:	22e7fe63          	bgeu	a5,a4,ffffffffc020156a <buddy_init_memmap.part.0+0x304>
    allocate_area = base + record_area_size;
ffffffffc0201332:	00261793          	slli	a5,a2,0x2
ffffffffc0201336:	97b2                	add	a5,a5,a2
ffffffffc0201338:	078e                	slli	a5,a5,0x3
    record_area = KADDR(page2pa(base));
ffffffffc020133a:	00008517          	auipc	a0,0x8
ffffffffc020133e:	21653503          	ld	a0,534(a0) # ffffffffc0209550 <va_pa_offset>
    allocate_area = base + record_area_size;
ffffffffc0201342:	983e                	add	a6,a6,a5
    record_area = KADDR(page2pa(base));
ffffffffc0201344:	9536                	add	a0,a0,a3
ffffffffc0201346:	00008417          	auipc	s0,0x8
ffffffffc020134a:	1ca40413          	addi	s0,s0,458 # ffffffffc0209510 <record_area>
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc020134e:	0632                	slli	a2,a2,0xc
    allocate_area = base + record_area_size;
ffffffffc0201350:	00008917          	auipc	s2,0x8
ffffffffc0201354:	1a090913          	addi	s2,s2,416 # ffffffffc02094f0 <allocate_area>
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0201358:	4581                	li	a1,0
    allocate_area = base + record_area_size;
ffffffffc020135a:	01093023          	sd	a6,0(s2)
    record_area = KADDR(page2pa(base));
ffffffffc020135e:	e008                	sd	a0,0(s0)
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0201360:	1fd020ef          	jal	ra,ffffffffc0203d5c <memset>
    nr_free += real_tree_size;
ffffffffc0201364:	00008e17          	auipc	t3,0x8
ffffffffc0201368:	cace0e13          	addi	t3,t3,-852 # ffffffffc0209010 <free_area>
ffffffffc020136c:	000a3603          	ld	a2,0(s4)
ffffffffc0201370:	010e2783          	lw	a5,16(t3)
    record_area[block] = real_subtree_size;
ffffffffc0201374:	6018                	ld	a4,0(s0)
    size_t full_subtree_size = full_tree_size;
ffffffffc0201376:	6094                	ld	a3,0(s1)
    nr_free += real_tree_size;
ffffffffc0201378:	9fb1                	addw	a5,a5,a2
ffffffffc020137a:	00fe2823          	sw	a5,16(t3)
    record_area[block] = real_subtree_size;
ffffffffc020137e:	e710                	sd	a2,8(a4)
    nr_free += real_tree_size;
ffffffffc0201380:	0006081b          	sext.w	a6,a2
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0201384:	ce45                	beqz	a2,ffffffffc020143c <buddy_init_memmap.part.0+0x1d6>
ffffffffc0201386:	1ad67d63          	bgeu	a2,a3,ffffffffc0201540 <buddy_init_memmap.part.0+0x2da>
    size_t block = TREE_ROOT;
ffffffffc020138a:	4785                	li	a5,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020138c:	4f09                	li	t5,2
    while (res < a) res <<= 1;
ffffffffc020138e:	4f85                	li	t6,1
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201390:	0019de93          	srli	t4,s3,0x1
    return a << 1;
ffffffffc0201394:	00179713          	slli	a4,a5,0x1
            record_area[left_child(block)] = full_subtree_size;
ffffffffc0201398:	00479593          	slli	a1,a5,0x4
        full_subtree_size >>= 1;
ffffffffc020139c:	8285                	srli	a3,a3,0x1
    return (a << 1) + 1;
ffffffffc020139e:	00170293          	addi	t0,a4,1
            record_area[right_child(block)] = real_subtree_size;
ffffffffc02013a2:	00858313          	addi	t1,a1,8
        if (real_subtree_size > full_subtree_size)
ffffffffc02013a6:	0ac6e363          	bltu	a3,a2,ffffffffc020144c <buddy_init_memmap.part.0+0x1e6>
            record_area[left_child(block)] = real_subtree_size;
ffffffffc02013aa:	601c                	ld	a5,0(s0)
ffffffffc02013ac:	95be                	add	a1,a1,a5
ffffffffc02013ae:	e190                	sd	a2,0(a1)
            record_area[right_child(block)] = 0;
ffffffffc02013b0:	979a                	add	a5,a5,t1
ffffffffc02013b2:	0007b023          	sd	zero,0(a5)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc02013b6:	c259                	beqz	a2,ffffffffc020143c <buddy_init_memmap.part.0+0x1d6>
            block = left_child(block);
ffffffffc02013b8:	87ba                	mv	a5,a4
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc02013ba:	fcd66de3          	bltu	a2,a3,ffffffffc0201394 <buddy_init_memmap.part.0+0x12e>
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc02013be:	0017d713          	srli	a4,a5,0x1
ffffffffc02013c2:	8f5d                	or	a4,a4,a5
ffffffffc02013c4:	00275593          	srli	a1,a4,0x2
ffffffffc02013c8:	8dd9                	or	a1,a1,a4
ffffffffc02013ca:	0045d713          	srli	a4,a1,0x4
ffffffffc02013ce:	8dd9                	or	a1,a1,a4
ffffffffc02013d0:	0085d713          	srli	a4,a1,0x8
ffffffffc02013d4:	8f4d                	or	a4,a4,a1
ffffffffc02013d6:	01075593          	srli	a1,a4,0x10
ffffffffc02013da:	8dd9                	or	a1,a1,a4
    return (a & (a - 1)) == 0;
ffffffffc02013dc:	fff78713          	addi	a4,a5,-1
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc02013e0:	8185                	srli	a1,a1,0x1
    return (a & (a - 1)) == 0;
ffffffffc02013e2:	8f7d                	and	a4,a4,a5
        struct Page *page = &allocate_area[node_beginning(full_tree_size , block)];
ffffffffc02013e4:	00093683          	ld	a3,0(s2)
ffffffffc02013e8:	6088                	ld	a0,0(s1)
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc02013ea:	8dfd                	and	a1,a1,a5
        page->property = real_subtree_size;
ffffffffc02013ec:	0006081b          	sext.w	a6,a2
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc02013f0:	cb11                	beqz	a4,ffffffffc0201404 <buddy_init_memmap.part.0+0x19e>
    while (res < a) res <<= 1;
ffffffffc02013f2:	4605                	li	a2,1
    size_t res = 1;
ffffffffc02013f4:	4705                	li	a4,1
    while (res < a) res <<= 1;
ffffffffc02013f6:	14c78863          	beq	a5,a2,ffffffffc0201546 <buddy_init_memmap.part.0+0x2e0>
ffffffffc02013fa:	0706                	slli	a4,a4,0x1
ffffffffc02013fc:	fef76fe3          	bltu	a4,a5,ffffffffc02013fa <buddy_init_memmap.part.0+0x194>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201400:	00175793          	srli	a5,a4,0x1
    return full_tree_size / power_round_down(a);
ffffffffc0201404:	02f557b3          	divu	a5,a0,a5
        struct Page *page = &allocate_area[node_beginning(full_tree_size , block)];
ffffffffc0201408:	02b785b3          	mul	a1,a5,a1
ffffffffc020140c:	00259793          	slli	a5,a1,0x2
ffffffffc0201410:	97ae                	add	a5,a5,a1
ffffffffc0201412:	078e                	slli	a5,a5,0x3
ffffffffc0201414:	97b6                	add	a5,a5,a3
        page->property = real_subtree_size;
ffffffffc0201416:	0107a823          	sw	a6,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020141a:	0007a023          	sw	zero,0(a5)
ffffffffc020141e:	4709                	li	a4,2
ffffffffc0201420:	00878693          	addi	a3,a5,8
ffffffffc0201424:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201428:	008e3703          	ld	a4,8(t3)
        list_add(&(free_list), &(page->page_link));
ffffffffc020142c:	01878693          	addi	a3,a5,24
    prev->next = next->prev = elm;
ffffffffc0201430:	e314                	sd	a3,0(a4)
ffffffffc0201432:	00de3423          	sd	a3,8(t3)
    elm->next = next;
ffffffffc0201436:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc0201438:	01c7bc23          	sd	t3,24(a5)
}
ffffffffc020143c:	70a2                	ld	ra,40(sp)
ffffffffc020143e:	7402                	ld	s0,32(sp)
ffffffffc0201440:	64e2                	ld	s1,24(sp)
ffffffffc0201442:	6942                	ld	s2,16(sp)
ffffffffc0201444:	69a2                	ld	s3,8(sp)
ffffffffc0201446:	6a02                	ld	s4,0(sp)
ffffffffc0201448:	6145                	addi	sp,sp,48
ffffffffc020144a:	8082                	ret
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc020144c:	0017d813          	srli	a6,a5,0x1
ffffffffc0201450:	00f86833          	or	a6,a6,a5
ffffffffc0201454:	00285713          	srli	a4,a6,0x2
ffffffffc0201458:	01076833          	or	a6,a4,a6
ffffffffc020145c:	00485713          	srli	a4,a6,0x4
ffffffffc0201460:	01076733          	or	a4,a4,a6
ffffffffc0201464:	00875813          	srli	a6,a4,0x8
ffffffffc0201468:	00e86733          	or	a4,a6,a4
ffffffffc020146c:	01075813          	srli	a6,a4,0x10
ffffffffc0201470:	00e86833          	or	a6,a6,a4
    return (a & (a - 1)) == 0;
ffffffffc0201474:	fff78713          	addi	a4,a5,-1
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201478:	00185813          	srli	a6,a6,0x1
    return (a & (a - 1)) == 0;
ffffffffc020147c:	8f7d                	and	a4,a4,a5
            struct Page *page = &allocate_area[node_beginning(full_tree_size,block)];
ffffffffc020147e:	00093503          	ld	a0,0(s2)
ffffffffc0201482:	0004b883          	ld	a7,0(s1)
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201486:	00f87833          	and	a6,a6,a5
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc020148a:	cb11                	beqz	a4,ffffffffc020149e <buddy_init_memmap.part.0+0x238>
    while (res < a) res <<= 1;
ffffffffc020148c:	0bf78863          	beq	a5,t6,ffffffffc020153c <buddy_init_memmap.part.0+0x2d6>
    size_t res = 1;
ffffffffc0201490:	4705                	li	a4,1
    while (res < a) res <<= 1;
ffffffffc0201492:	83ba                	mv	t2,a4
ffffffffc0201494:	0706                	slli	a4,a4,0x1
ffffffffc0201496:	fef76ee3          	bltu	a4,a5,ffffffffc0201492 <buddy_init_memmap.part.0+0x22c>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc020149a:	01d3f7b3          	and	a5,t2,t4
    return full_tree_size / power_round_down(a);
ffffffffc020149e:	02f8d7b3          	divu	a5,a7,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02014a2:	008e3883          	ld	a7,8(t3)
            struct Page *page = &allocate_area[node_beginning(full_tree_size,block)];
ffffffffc02014a6:	03078833          	mul	a6,a5,a6
ffffffffc02014aa:	00281713          	slli	a4,a6,0x2
ffffffffc02014ae:	983a                	add	a6,a6,a4
ffffffffc02014b0:	00381713          	slli	a4,a6,0x3
ffffffffc02014b4:	972a                	add	a4,a4,a0
            list_add(&(free_list), &(page->page_link));
ffffffffc02014b6:	01870793          	addi	a5,a4,24
            page->property = full_subtree_size;
ffffffffc02014ba:	cb14                	sw	a3,16(a4)
    prev->next = next->prev = elm;
ffffffffc02014bc:	00f8b023          	sd	a5,0(a7)
ffffffffc02014c0:	00fe3423          	sd	a5,8(t3)
    elm->next = next;
ffffffffc02014c4:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc02014c8:	01c73c23          	sd	t3,24(a4)
ffffffffc02014cc:	00072023          	sw	zero,0(a4)
ffffffffc02014d0:	00870793          	addi	a5,a4,8
ffffffffc02014d4:	41e7b02f          	amoor.d	zero,t5,(a5)
            record_area[left_child(block)] = full_subtree_size;
ffffffffc02014d8:	6018                	ld	a4,0(s0)
            real_subtree_size -= full_subtree_size;
ffffffffc02014da:	8e15                	sub	a2,a2,a3
            block = right_child(block);
ffffffffc02014dc:	8796                	mv	a5,t0
            record_area[left_child(block)] = full_subtree_size;
ffffffffc02014de:	95ba                	add	a1,a1,a4
ffffffffc02014e0:	e194                	sd	a3,0(a1)
            record_area[right_child(block)] = real_subtree_size;
ffffffffc02014e2:	971a                	add	a4,a4,t1
ffffffffc02014e4:	e310                	sd	a2,0(a4)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc02014e6:	ead667e3          	bltu	a2,a3,ffffffffc0201394 <buddy_init_memmap.part.0+0x12e>
ffffffffc02014ea:	bdd1                	j	ffffffffc02013be <buddy_init_memmap.part.0+0x158>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc02014ec:	873e                	mv	a4,a5
ffffffffc02014ee:	bbfd                	j	ffffffffc02012ec <buddy_init_memmap.part.0+0x86>
    return (a & (a - 1)) == 0;
ffffffffc02014f0:	8f6d                	and	a4,a4,a1
ffffffffc02014f2:	87ae                	mv	a5,a1
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc02014f4:	c719                	beqz	a4,ffffffffc0201502 <buddy_init_memmap.part.0+0x29c>
    size_t res = 1;
ffffffffc02014f6:	4705                	li	a4,1
    while (res < a) res <<= 1;
ffffffffc02014f8:	0706                	slli	a4,a4,0x1
ffffffffc02014fa:	feb76fe3          	bltu	a4,a1,ffffffffc02014f8 <buddy_init_memmap.part.0+0x292>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc02014fe:	00175793          	srli	a5,a4,0x1
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0201502:	00479693          	slli	a3,a5,0x4
ffffffffc0201506:	82b1                	srli	a3,a3,0xc
        full_tree_size = power_round_down(n);
ffffffffc0201508:	00008497          	auipc	s1,0x8
ffffffffc020150c:	ff048493          	addi	s1,s1,-16 # ffffffffc02094f8 <full_tree_size>
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0201510:	00008717          	auipc	a4,0x8
ffffffffc0201514:	00870713          	addi	a4,a4,8 # ffffffffc0209518 <record_area_size>
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0201518:	00169613          	slli	a2,a3,0x1
        full_tree_size = power_round_down(n);
ffffffffc020151c:	e09c                	sd	a5,0(s1)
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc020151e:	e314                	sd	a3,0(a4)
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0201520:	00f60533          	add	a0,a2,a5
ffffffffc0201524:	00b57863          	bgeu	a0,a1,ffffffffc0201534 <buddy_init_memmap.part.0+0x2ce>
            full_tree_size <<= 1;
ffffffffc0201528:	0786                	slli	a5,a5,0x1
            record_area_size <<= 1;
ffffffffc020152a:	e310                	sd	a2,0(a4)
            full_tree_size <<= 1;
ffffffffc020152c:	e09c                	sd	a5,0(s1)
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc020152e:	40c58733          	sub	a4,a1,a2
ffffffffc0201532:	b37d                	j	ffffffffc02012e0 <buddy_init_memmap.part.0+0x7a>
ffffffffc0201534:	40d58733          	sub	a4,a1,a3
ffffffffc0201538:	8636                	mv	a2,a3
ffffffffc020153a:	b35d                	j	ffffffffc02012e0 <buddy_init_memmap.part.0+0x7a>
    while (res < a) res <<= 1;
ffffffffc020153c:	4781                	li	a5,0
ffffffffc020153e:	b785                	j	ffffffffc020149e <buddy_init_memmap.part.0+0x238>
        struct Page *page = &allocate_area[node_beginning(full_tree_size , block)];
ffffffffc0201540:	00093783          	ld	a5,0(s2)
    return (a & (a - 1)) == 0;
ffffffffc0201544:	bdc9                	j	ffffffffc0201416 <buddy_init_memmap.part.0+0x1b0>
    while (res < a) res <<= 1;
ffffffffc0201546:	4781                	li	a5,0
ffffffffc0201548:	bd75                	j	ffffffffc0201404 <buddy_init_memmap.part.0+0x19e>
        assert(PageReserved(p));
ffffffffc020154a:	00003697          	auipc	a3,0x3
ffffffffc020154e:	32e68693          	addi	a3,a3,814 # ffffffffc0204878 <commands+0x868>
ffffffffc0201552:	00003617          	auipc	a2,0x3
ffffffffc0201556:	fbe60613          	addi	a2,a2,-66 # ffffffffc0204510 <commands+0x500>
ffffffffc020155a:	06300593          	li	a1,99
ffffffffc020155e:	00003517          	auipc	a0,0x3
ffffffffc0201562:	37a50513          	addi	a0,a0,890 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201566:	e6bfe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    record_area = KADDR(page2pa(base));
ffffffffc020156a:	00003617          	auipc	a2,0x3
ffffffffc020156e:	38e60613          	addi	a2,a2,910 # ffffffffc02048f8 <best_fit_pmm_manager+0x58>
ffffffffc0201572:	07a00593          	li	a1,122
ffffffffc0201576:	00003517          	auipc	a0,0x3
ffffffffc020157a:	36250513          	addi	a0,a0,866 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc020157e:	e53fe0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0201582 <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0201582:	c191                	beqz	a1,ffffffffc0201586 <buddy_init_memmap+0x4>
ffffffffc0201584:	b1cd                	j	ffffffffc0201266 <buddy_init_memmap.part.0>
{
ffffffffc0201586:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201588:	00003697          	auipc	a3,0x3
ffffffffc020158c:	f8068693          	addi	a3,a3,-128 # ffffffffc0204508 <commands+0x4f8>
ffffffffc0201590:	00003617          	auipc	a2,0x3
ffffffffc0201594:	f8060613          	addi	a2,a2,-128 # ffffffffc0204510 <commands+0x500>
ffffffffc0201598:	05f00593          	li	a1,95
ffffffffc020159c:	00003517          	auipc	a0,0x3
ffffffffc02015a0:	33c50513          	addi	a0,a0,828 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
{
ffffffffc02015a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a6:	e2bfe0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc02015aa <buddy_allocate_pages>:
{
ffffffffc02015aa:	7139                	addi	sp,sp,-64
ffffffffc02015ac:	fc06                	sd	ra,56(sp)
ffffffffc02015ae:	f822                	sd	s0,48(sp)
ffffffffc02015b0:	f426                	sd	s1,40(sp)
ffffffffc02015b2:	f04a                	sd	s2,32(sp)
ffffffffc02015b4:	ec4e                	sd	s3,24(sp)
ffffffffc02015b6:	e852                	sd	s4,16(sp)
ffffffffc02015b8:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc02015ba:	2a050463          	beqz	a0,ffffffffc0201862 <buddy_allocate_pages+0x2b8>
    return (a & (a - 1)) == 0;
ffffffffc02015be:	fff50793          	addi	a5,a0,-1
ffffffffc02015c2:	8fe9                	and	a5,a5,a0
ffffffffc02015c4:	862a                	mv	a2,a0
    if (is_power_of_2(a)) return a;
ffffffffc02015c6:	cb81                	beqz	a5,ffffffffc02015d6 <buddy_allocate_pages+0x2c>
    while (res < a) res <<= 1;
ffffffffc02015c8:	4785                	li	a5,1
ffffffffc02015ca:	00f50663          	beq	a0,a5,ffffffffc02015d6 <buddy_allocate_pages+0x2c>
    size_t res = 1;
ffffffffc02015ce:	4605                	li	a2,1
    while (res < a) res <<= 1;
ffffffffc02015d0:	0606                	slli	a2,a2,0x1
ffffffffc02015d2:	fea66fe3          	bltu	a2,a0,ffffffffc02015d0 <buddy_allocate_pages+0x26>
    while (length <= record_area[block] && length < node_length(full_tree_size, block))
ffffffffc02015d6:	00008897          	auipc	a7,0x8
ffffffffc02015da:	f3a8b883          	ld	a7,-198(a7) # ffffffffc0209510 <record_area>
ffffffffc02015de:	0088b583          	ld	a1,8(a7)
ffffffffc02015e2:	00888413          	addi	s0,a7,8
ffffffffc02015e6:	1ec5e963          	bltu	a1,a2,ffffffffc02017d8 <buddy_allocate_pages+0x22e>
ffffffffc02015ea:	00008e17          	auipc	t3,0x8
ffffffffc02015ee:	f0ee3e03          	ld	t3,-242(t3) # ffffffffc02094f8 <full_tree_size>
    size_t block = TREE_ROOT;
ffffffffc02015f2:	4705                	li	a4,1
    return full_tree_size / power_round_down(a);
ffffffffc02015f4:	02ee5733          	divu	a4,t3,a4
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc02015f8:	5f7d                	li	t5,-1
            list_del(&(allocate_area[begin].page_link));
ffffffffc02015fa:	00008e97          	auipc	t4,0x8
ffffffffc02015fe:	ef6ebe83          	ld	t4,-266(t4) # ffffffffc02094f0 <allocate_area>
    return (a & (a - 1)) == 0;
ffffffffc0201602:	4801                	li	a6,0
    size_t block = TREE_ROOT;
ffffffffc0201604:	4785                	li	a5,1
    __list_add(elm, listelm, listelm->next);
ffffffffc0201606:	00008297          	auipc	t0,0x8
ffffffffc020160a:	a0a28293          	addi	t0,t0,-1526 # ffffffffc0209010 <free_area>
    while (res < a) res <<= 1;
ffffffffc020160e:	4f85                	li	t6,1
    return full_tree_size / power_round_down(a);
ffffffffc0201610:	4381                	li	t2,0
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201612:	001f5f13          	srli	t5,t5,0x1
    while (length <= record_area[block] && length < node_length(full_tree_size, block))
ffffffffc0201616:	06e67763          	bgeu	a2,a4,ffffffffc0201684 <buddy_allocate_pages+0xda>
            record_area[left] = record_area[block] >> 1;
ffffffffc020161a:	00479513          	slli	a0,a5,0x4
    return a << 1;
ffffffffc020161e:	00179693          	slli	a3,a5,0x1
            record_area[left] = record_area[block] >> 1;
ffffffffc0201622:	00a88333          	add	t1,a7,a0
    return (a << 1) + 1;
ffffffffc0201626:	00168913          	addi	s2,a3,1
            record_area[left] = record_area[block] >> 1;
ffffffffc020162a:	849a                	mv	s1,t1
        if (BUDDY_EMPTY(block)) 
ffffffffc020162c:	0eb70363          	beq	a4,a1,ffffffffc0201712 <buddy_allocate_pages+0x168>
        else if (length & record_area[left])
ffffffffc0201630:	00033583          	ld	a1,0(t1)
ffffffffc0201634:	00c5f733          	and	a4,a1,a2
ffffffffc0201638:	18071e63          	bnez	a4,ffffffffc02017d4 <buddy_allocate_pages+0x22a>
        else if (length & record_area[right])
ffffffffc020163c:	0521                	addi	a0,a0,8
ffffffffc020163e:	9546                	add	a0,a0,a7
ffffffffc0201640:	6118                	ld	a4,0(a0)
ffffffffc0201642:	00c77833          	and	a6,a4,a2
ffffffffc0201646:	1a081363          	bnez	a6,ffffffffc02017ec <buddy_allocate_pages+0x242>
        else if (length <= record_area[left])
ffffffffc020164a:	00c5f763          	bgeu	a1,a2,ffffffffc0201658 <buddy_allocate_pages+0xae>
        else if (length <= record_area[right])
ffffffffc020164e:	1ac76a63          	bltu	a4,a2,ffffffffc0201802 <buddy_allocate_pages+0x258>
ffffffffc0201652:	85ba                	mv	a1,a4
ffffffffc0201654:	832a                	mv	t1,a0
            block = right;
ffffffffc0201656:	86ca                	mv	a3,s2
    return (a & (a - 1)) == 0;
ffffffffc0201658:	fff68813          	addi	a6,a3,-1
ffffffffc020165c:	00d87833          	and	a6,a6,a3
ffffffffc0201660:	8736                	mv	a4,a3
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201662:	00080b63          	beqz	a6,ffffffffc0201678 <buddy_allocate_pages+0xce>
    while (res < a) res <<= 1;
ffffffffc0201666:	1ff68563          	beq	a3,t6,ffffffffc0201850 <buddy_allocate_pages+0x2a6>
    size_t res = 1;
ffffffffc020166a:	4785                	li	a5,1
    while (res < a) res <<= 1;
ffffffffc020166c:	873e                	mv	a4,a5
ffffffffc020166e:	0786                	slli	a5,a5,0x1
ffffffffc0201670:	fed7eee3          	bltu	a5,a3,ffffffffc020166c <buddy_allocate_pages+0xc2>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201674:	01e77733          	and	a4,a4,t5
    return full_tree_size / power_round_down(a);
ffffffffc0201678:	02ee5733          	divu	a4,t3,a4
ffffffffc020167c:	841a                	mv	s0,t1
ffffffffc020167e:	87b6                	mv	a5,a3
    while (length <= record_area[block] && length < node_length(full_tree_size, block))
ffffffffc0201680:	f8e66de3          	bltu	a2,a4,ffffffffc020161a <buddy_allocate_pages+0x70>
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201684:	0017d713          	srli	a4,a5,0x1
ffffffffc0201688:	00f766b3          	or	a3,a4,a5
ffffffffc020168c:	0026d593          	srli	a1,a3,0x2
ffffffffc0201690:	8ecd                	or	a3,a3,a1
ffffffffc0201692:	0046d593          	srli	a1,a3,0x4
ffffffffc0201696:	8dd5                	or	a1,a1,a3
ffffffffc0201698:	0085d693          	srli	a3,a1,0x8
ffffffffc020169c:	8dd5                	or	a1,a1,a3
ffffffffc020169e:	0105d693          	srli	a3,a1,0x10
ffffffffc02016a2:	8ecd                	or	a3,a3,a1
ffffffffc02016a4:	8285                	srli	a3,a3,0x1
ffffffffc02016a6:	00f6f533          	and	a0,a3,a5
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc02016aa:	16080563          	beqz	a6,ffffffffc0201814 <buddy_allocate_pages+0x26a>
    while (res < a) res <<= 1;
ffffffffc02016ae:	4585                	li	a1,1
    size_t res = 1;
ffffffffc02016b0:	4685                	li	a3,1
    while (res < a) res <<= 1;
ffffffffc02016b2:	1af5f663          	bgeu	a1,a5,ffffffffc020185e <buddy_allocate_pages+0x2b4>
ffffffffc02016b6:	0686                	slli	a3,a3,0x1
ffffffffc02016b8:	fef6efe3          	bltu	a3,a5,ffffffffc02016b6 <buddy_allocate_pages+0x10c>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc02016bc:	8285                	srli	a3,a3,0x1
    return full_tree_size / power_round_down(a);
ffffffffc02016be:	02de56b3          	divu	a3,t3,a3
    nr_free -= length;
ffffffffc02016c2:	00008817          	auipc	a6,0x8
ffffffffc02016c6:	94e80813          	addi	a6,a6,-1714 # ffffffffc0209010 <free_area>
ffffffffc02016ca:	01082583          	lw	a1,16(a6)
ffffffffc02016ce:	40c5863b          	subw	a2,a1,a2
    page = &(allocate_area[node_beginning(full_tree_size, block)]);
ffffffffc02016d2:	02a686b3          	mul	a3,a3,a0
ffffffffc02016d6:	00269513          	slli	a0,a3,0x2
ffffffffc02016da:	9536                	add	a0,a0,a3
ffffffffc02016dc:	050e                	slli	a0,a0,0x3
ffffffffc02016de:	9576                	add	a0,a0,t4
    __list_del(listelm->prev, listelm->next);
ffffffffc02016e0:	6d0c                	ld	a1,24(a0)
ffffffffc02016e2:	7114                	ld	a3,32(a0)
    prev->next = next;
ffffffffc02016e4:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc02016e6:	e28c                	sd	a1,0(a3)
    record_area[block] = 0;
ffffffffc02016e8:	00043023          	sd	zero,0(s0)
    nr_free -= length;
ffffffffc02016ec:	00c82823          	sw	a2,16(a6)
    while (block != TREE_ROOT) 
ffffffffc02016f0:	4585                	li	a1,1
ffffffffc02016f2:	a011                	j	ffffffffc02016f6 <buddy_allocate_pages+0x14c>
ffffffffc02016f4:	8305                	srli	a4,a4,0x1
    return a << 1;
ffffffffc02016f6:	9bf9                	andi	a5,a5,-2
        record_area[block] = record_area[left_child(block)] | record_area[right_child(block)];
ffffffffc02016f8:	078e                	slli	a5,a5,0x3
ffffffffc02016fa:	97c6                	add	a5,a5,a7
ffffffffc02016fc:	6390                	ld	a2,0(a5)
ffffffffc02016fe:	6794                	ld	a3,8(a5)
ffffffffc0201700:	00371793          	slli	a5,a4,0x3
ffffffffc0201704:	97c6                	add	a5,a5,a7
ffffffffc0201706:	8ed1                	or	a3,a3,a2
ffffffffc0201708:	e394                	sd	a3,0(a5)
    return a >> 1;
ffffffffc020170a:	87ba                	mv	a5,a4
    while (block != TREE_ROOT) 
ffffffffc020170c:	feb714e3          	bne	a4,a1,ffffffffc02016f4 <buddy_allocate_pages+0x14a>
ffffffffc0201710:	a0e9                	j	ffffffffc02017da <buddy_allocate_pages+0x230>
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201712:	0017d513          	srli	a0,a5,0x1
ffffffffc0201716:	8d5d                	or	a0,a0,a5
ffffffffc0201718:	00255713          	srli	a4,a0,0x2
ffffffffc020171c:	8d59                	or	a0,a0,a4
ffffffffc020171e:	00455713          	srli	a4,a0,0x4
ffffffffc0201722:	8f49                	or	a4,a4,a0
ffffffffc0201724:	00875513          	srli	a0,a4,0x8
ffffffffc0201728:	8f49                	or	a4,a4,a0
ffffffffc020172a:	01075513          	srli	a0,a4,0x10
ffffffffc020172e:	8d59                	or	a0,a0,a4
ffffffffc0201730:	8105                	srli	a0,a0,0x1
ffffffffc0201732:	8d7d                	and	a0,a0,a5
    return (power_remainder(a) + 1) * node_length(full_tree_size, a);
ffffffffc0201734:	00150993          	addi	s3,a0,1
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201738:	0c080063          	beqz	a6,ffffffffc02017f8 <buddy_allocate_pages+0x24e>
    while (res < a) res <<= 1;
ffffffffc020173c:	10fffc63          	bgeu	t6,a5,ffffffffc0201854 <buddy_allocate_pages+0x2aa>
    size_t res = 1;
ffffffffc0201740:	4705                	li	a4,1
    while (res < a) res <<= 1;
ffffffffc0201742:	883a                	mv	a6,a4
ffffffffc0201744:	0706                	slli	a4,a4,0x1
ffffffffc0201746:	fef76ee3          	bltu	a4,a5,ffffffffc0201742 <buddy_allocate_pages+0x198>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc020174a:	01e87833          	and	a6,a6,t5
    return full_tree_size / power_round_down(a);
ffffffffc020174e:	030e5833          	divu	a6,t3,a6
    return power_remainder(a) * node_length(full_tree_size, a);
ffffffffc0201752:	4705                	li	a4,1
ffffffffc0201754:	02a80533          	mul	a0,a6,a0
    while (res < a) res <<= 1;
ffffffffc0201758:	893a                	mv	s2,a4
ffffffffc020175a:	0706                	slli	a4,a4,0x1
ffffffffc020175c:	fef76ee3          	bltu	a4,a5,ffffffffc0201758 <buddy_allocate_pages+0x1ae>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201760:	01e977b3          	and	a5,s2,t5
    return full_tree_size / power_round_down(a);
ffffffffc0201764:	02fe57b3          	divu	a5,t3,a5
            list_del(&(allocate_area[begin].page_link));
ffffffffc0201768:	00251913          	slli	s2,a0,0x2
ffffffffc020176c:	992a                	add	s2,s2,a0
ffffffffc020176e:	090e                	slli	s2,s2,0x3
ffffffffc0201770:	9976                	add	s2,s2,t4
    __list_del(listelm->prev, listelm->next);
ffffffffc0201772:	01893a03          	ld	s4,24(s2)
ffffffffc0201776:	02093703          	ld	a4,32(s2)
            allocate_area[begin].property >>= 1;
ffffffffc020177a:	01092803          	lw	a6,16(s2)
            record_area[left] = record_area[block] >> 1;
ffffffffc020177e:	8185                	srli	a1,a1,0x1
    prev->next = next;
ffffffffc0201780:	00ea3423          	sd	a4,8(s4)
    next->prev = prev;
ffffffffc0201784:	01473023          	sd	s4,0(a4)
            allocate_area[begin].property >>= 1;
ffffffffc0201788:	0018581b          	srliw	a6,a6,0x1
ffffffffc020178c:	01092823          	sw	a6,16(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201790:	0082ba83          	ld	s5,8(t0)
            list_add(&free_list, &(allocate_area[begin].page_link));
ffffffffc0201794:	01890a13          	addi	s4,s2,24
    return (power_remainder(a) + 1) * node_length(full_tree_size, a);
ffffffffc0201798:	02f987b3          	mul	a5,s3,a5
            size_t mid = (begin + node_ending(full_tree_size, block)) >> 1;
ffffffffc020179c:	97aa                	add	a5,a5,a0
ffffffffc020179e:	0017d713          	srli	a4,a5,0x1
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc02017a2:	00271793          	slli	a5,a4,0x2
ffffffffc02017a6:	97ba                	add	a5,a5,a4
ffffffffc02017a8:	078e                	slli	a5,a5,0x3
ffffffffc02017aa:	97f6                	add	a5,a5,t4
ffffffffc02017ac:	0107a823          	sw	a6,16(a5)
            record_area[left] = record_area[block] >> 1;
ffffffffc02017b0:	e08c                	sd	a1,0(s1)
            record_area[right] = record_area[block] >> 1;
ffffffffc02017b2:	6018                	ld	a4,0(s0)
            list_add(&free_list, &(allocate_area[mid].page_link));
ffffffffc02017b4:	01878513          	addi	a0,a5,24
            record_area[right] = record_area[block] >> 1;
ffffffffc02017b8:	8305                	srli	a4,a4,0x1
ffffffffc02017ba:	e498                	sd	a4,8(s1)
    prev->next = next->prev = elm;
ffffffffc02017bc:	014ab023          	sd	s4,0(s5)
    elm->next = next;
ffffffffc02017c0:	03593023          	sd	s5,32(s2)
    prev->next = next->prev = elm;
ffffffffc02017c4:	00a93c23          	sd	a0,24(s2)
ffffffffc02017c8:	00a2b423          	sd	a0,8(t0)
    elm->next = next;
ffffffffc02017cc:	0347b023          	sd	s4,32(a5)
    elm->prev = prev;
ffffffffc02017d0:	0057bc23          	sd	t0,24(a5)
    while (length <= record_area[block] && length < node_length(full_tree_size, block))
ffffffffc02017d4:	e8c5f2e3          	bgeu	a1,a2,ffffffffc0201658 <buddy_allocate_pages+0xae>
        return NULL;
ffffffffc02017d8:	4501                	li	a0,0
}
ffffffffc02017da:	70e2                	ld	ra,56(sp)
ffffffffc02017dc:	7442                	ld	s0,48(sp)
ffffffffc02017de:	74a2                	ld	s1,40(sp)
ffffffffc02017e0:	7902                	ld	s2,32(sp)
ffffffffc02017e2:	69e2                	ld	s3,24(sp)
ffffffffc02017e4:	6a42                	ld	s4,16(sp)
ffffffffc02017e6:	6aa2                	ld	s5,8(sp)
ffffffffc02017e8:	6121                	addi	sp,sp,64
ffffffffc02017ea:	8082                	ret
ffffffffc02017ec:	85ba                	mv	a1,a4
ffffffffc02017ee:	832a                	mv	t1,a0
            block = right;
ffffffffc02017f0:	86ca                	mv	a3,s2
    while (length <= record_area[block] && length < node_length(full_tree_size, block))
ffffffffc02017f2:	e6c5f3e3          	bgeu	a1,a2,ffffffffc0201658 <buddy_allocate_pages+0xae>
ffffffffc02017f6:	b7cd                	j	ffffffffc02017d8 <buddy_allocate_pages+0x22e>
    return full_tree_size / power_round_down(a);
ffffffffc02017f8:	02fe57b3          	divu	a5,t3,a5
    return power_remainder(a) * node_length(full_tree_size, a);
ffffffffc02017fc:	02f50533          	mul	a0,a0,a5
    return (a & (a - 1)) == 0;
ffffffffc0201800:	b7a5                	j	ffffffffc0201768 <buddy_allocate_pages+0x1be>
    while (length <= record_area[block] && length < node_length(full_tree_size, block))
ffffffffc0201802:	00379313          	slli	t1,a5,0x3
ffffffffc0201806:	9346                	add	t1,t1,a7
ffffffffc0201808:	00033583          	ld	a1,0(t1)
ffffffffc020180c:	86be                	mv	a3,a5
ffffffffc020180e:	e4c5f5e3          	bgeu	a1,a2,ffffffffc0201658 <buddy_allocate_pages+0xae>
ffffffffc0201812:	b7d9                	j	ffffffffc02017d8 <buddy_allocate_pages+0x22e>
ffffffffc0201814:	86be                	mv	a3,a5
    return full_tree_size / power_round_down(a);
ffffffffc0201816:	02de56b3          	divu	a3,t3,a3
    nr_free -= length;
ffffffffc020181a:	00007817          	auipc	a6,0x7
ffffffffc020181e:	7f680813          	addi	a6,a6,2038 # ffffffffc0209010 <free_area>
ffffffffc0201822:	01082583          	lw	a1,16(a6)
    while (block != TREE_ROOT) 
ffffffffc0201826:	4305                	li	t1,1
    nr_free -= length;
ffffffffc0201828:	40c5863b          	subw	a2,a1,a2
    page = &(allocate_area[node_beginning(full_tree_size, block)]);
ffffffffc020182c:	02a686b3          	mul	a3,a3,a0
ffffffffc0201830:	00269513          	slli	a0,a3,0x2
ffffffffc0201834:	9536                	add	a0,a0,a3
ffffffffc0201836:	050e                	slli	a0,a0,0x3
ffffffffc0201838:	9576                	add	a0,a0,t4
    __list_del(listelm->prev, listelm->next);
ffffffffc020183a:	6d0c                	ld	a1,24(a0)
ffffffffc020183c:	7114                	ld	a3,32(a0)
    prev->next = next;
ffffffffc020183e:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc0201840:	e28c                	sd	a1,0(a3)
    record_area[block] = 0;
ffffffffc0201842:	00043023          	sd	zero,0(s0)
    nr_free -= length;
ffffffffc0201846:	00c82823          	sw	a2,16(a6)
    while (block != TREE_ROOT) 
ffffffffc020184a:	ea6793e3          	bne	a5,t1,ffffffffc02016f0 <buddy_allocate_pages+0x146>
ffffffffc020184e:	b771                	j	ffffffffc02017da <buddy_allocate_pages+0x230>
    while (res < a) res <<= 1;
ffffffffc0201850:	4701                	li	a4,0
ffffffffc0201852:	b51d                	j	ffffffffc0201678 <buddy_allocate_pages+0xce>
    return full_tree_size / power_round_down(a);
ffffffffc0201854:	027e57b3          	divu	a5,t3,t2
    return power_remainder(a) * node_length(full_tree_size, a);
ffffffffc0201858:	02f50533          	mul	a0,a0,a5
    while (res < a) res <<= 1;
ffffffffc020185c:	b731                	j	ffffffffc0201768 <buddy_allocate_pages+0x1be>
ffffffffc020185e:	4681                	li	a3,0
ffffffffc0201860:	bf5d                	j	ffffffffc0201816 <buddy_allocate_pages+0x26c>
    assert(n > 0);
ffffffffc0201862:	00003697          	auipc	a3,0x3
ffffffffc0201866:	ca668693          	addi	a3,a3,-858 # ffffffffc0204508 <commands+0x4f8>
ffffffffc020186a:	00003617          	auipc	a2,0x3
ffffffffc020186e:	ca660613          	addi	a2,a2,-858 # ffffffffc0204510 <commands+0x500>
ffffffffc0201872:	0a800593          	li	a1,168
ffffffffc0201876:	00003517          	auipc	a0,0x3
ffffffffc020187a:	06250513          	addi	a0,a0,98 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc020187e:	b53fe0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0201882 <alloc_check>:

static void alloc_check(void) {
ffffffffc0201882:	7119                	addi	sp,sp,-128
ffffffffc0201884:	f0ca                	sd	s2,96(sp)
    size_t total_size_store = total_size;  // 保存总内存大小
    struct Page *page;
    size_t num = 1026;
    //1026是运行临界值
    // 标记物理区域为保留
    for (page = physical_area; page < physical_area + num; page++) {
ffffffffc0201886:	00008917          	auipc	s2,0x8
ffffffffc020188a:	c7a90913          	addi	s2,s2,-902 # ffffffffc0209500 <physical_area>
ffffffffc020188e:	00093783          	ld	a5,0(s2)
ffffffffc0201892:	66a9                	lui	a3,0xa
static void alloc_check(void) {
ffffffffc0201894:	ecce                	sd	s3,88(sp)
ffffffffc0201896:	fc86                	sd	ra,120(sp)
ffffffffc0201898:	f8a2                	sd	s0,112(sp)
ffffffffc020189a:	f4a6                	sd	s1,104(sp)
ffffffffc020189c:	e8d2                	sd	s4,80(sp)
ffffffffc020189e:	e4d6                	sd	s5,72(sp)
ffffffffc02018a0:	e0da                	sd	s6,64(sp)
ffffffffc02018a2:	fc5e                	sd	s7,56(sp)
    size_t total_size_store = total_size;  // 保存总内存大小
ffffffffc02018a4:	00008997          	auipc	s3,0x8
ffffffffc02018a8:	c7c9b983          	ld	s3,-900(s3) # ffffffffc0209520 <total_size>
ffffffffc02018ac:	4605                	li	a2,1
    for (page = physical_area; page < physical_area + num; page++) {
ffffffffc02018ae:	05068693          	addi	a3,a3,80 # a050 <kern_entry-0xffffffffc01f5fb0>
ffffffffc02018b2:	00878713          	addi	a4,a5,8
ffffffffc02018b6:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc02018ba:	00093503          	ld	a0,0(s2)
ffffffffc02018be:	02878793          	addi	a5,a5,40
ffffffffc02018c2:	00d50733          	add	a4,a0,a3
ffffffffc02018c6:	fee7e6e3          	bltu	a5,a4,ffffffffc02018b2 <alloc_check+0x30>
    elm->prev = elm->next = elm;
ffffffffc02018ca:	00007497          	auipc	s1,0x7
ffffffffc02018ce:	74648493          	addi	s1,s1,1862 # ffffffffc0209010 <free_area>
ffffffffc02018d2:	40200593          	li	a1,1026
ffffffffc02018d6:	00810a93          	addi	s5,sp,8
ffffffffc02018da:	e484                	sd	s1,8(s1)
ffffffffc02018dc:	e084                	sd	s1,0(s1)
    nr_free = 0;
ffffffffc02018de:	00007797          	auipc	a5,0x7
ffffffffc02018e2:	7407a123          	sw	zero,1858(a5) # ffffffffc0209020 <free_area+0x10>

    // 初始化伙伴系统
    buddy_init();
    buddy_init_memmap(physical_area, num);

    struct Page *pages[5] = { NULL }; // 使用数组存储页面指针
ffffffffc02018e6:	8a56                	mv	s4,s5
ffffffffc02018e8:	97fff0ef          	jal	ra,ffffffffc0201266 <buddy_init_memmap.part.0>
    const int num_pages_to_alloc = sizeof(pages) / sizeof(pages[0]); // 动态计算页面数量

    // 分配四个页面，并确保分配成功
    for (int i = 0; i < num_pages_to_alloc; i++) {
ffffffffc02018ec:	4401                	li	s0,0
    struct Page *pages[5] = { NULL }; // 使用数组存储页面指针
ffffffffc02018ee:	e402                	sd	zero,8(sp)
ffffffffc02018f0:	e802                	sd	zero,16(sp)
ffffffffc02018f2:	ec02                	sd	zero,24(sp)
ffffffffc02018f4:	f002                	sd	zero,32(sp)
ffffffffc02018f6:	f402                	sd	zero,40(sp)
        assert((pages[i] = alloc_page()) != NULL);
        cprintf("[buddy sysetm] allocated page %d at address %p\n", i + 1, pages[i]);
ffffffffc02018f8:	00003b97          	auipc	s7,0x3
ffffffffc02018fc:	050b8b93          	addi	s7,s7,80 # ffffffffc0204948 <best_fit_pmm_manager+0xa8>
    for (int i = 0; i < num_pages_to_alloc; i++) {
ffffffffc0201900:	4b15                	li	s6,5
        assert((pages[i] = alloc_page()) != NULL);
ffffffffc0201902:	4505                	li	a0,1
ffffffffc0201904:	166010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201908:	00aa3023          	sd	a0,0(s4)
ffffffffc020190c:	862a                	mv	a2,a0
ffffffffc020190e:	26050163          	beqz	a0,ffffffffc0201b70 <alloc_check+0x2ee>
        cprintf("[buddy sysetm] allocated page %d at address %p\n", i + 1, pages[i]);
ffffffffc0201912:	2405                	addiw	s0,s0,1
ffffffffc0201914:	85a2                	mv	a1,s0
ffffffffc0201916:	855e                	mv	a0,s7
ffffffffc0201918:	fbefe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    for (int i = 0; i < num_pages_to_alloc; i++) {
ffffffffc020191c:	0a21                	addi	s4,s4,8
ffffffffc020191e:	ff6412e3          	bne	s0,s6,ffffffffc0201902 <alloc_check+0x80>
    }

    // 确保连续分配的页面相邻
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
        assert(pages[i] + 1 == pages[i + 1]);
ffffffffc0201922:	6722                	ld	a4,8(sp)
ffffffffc0201924:	020a8613          	addi	a2,s5,32
ffffffffc0201928:	87d6                	mv	a5,s5
ffffffffc020192a:	02870693          	addi	a3,a4,40
ffffffffc020192e:	6798                	ld	a4,8(a5)
ffffffffc0201930:	28e69063          	bne	a3,a4,ffffffffc0201bb0 <alloc_check+0x32e>
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
ffffffffc0201934:	07a1                	addi	a5,a5,8
ffffffffc0201936:	fec79ae3          	bne	a5,a2,ffffffffc020192a <alloc_check+0xa8>
ffffffffc020193a:	028a8693          	addi	a3,s5,40
ffffffffc020193e:	87d6                	mv	a5,s5
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201940:	6398                	ld	a4,0(a5)
ffffffffc0201942:	00072a03          	lw	s4,0(a4)
    }

    // 确认页面引用计数为0
    for (int i = 0; i < num_pages_to_alloc; i++) {
        assert(page_ref(pages[i]) == 0);
ffffffffc0201946:	240a1563          	bnez	s4,ffffffffc0201b90 <alloc_check+0x30e>
    for (int i = 0; i < num_pages_to_alloc; i++) {
ffffffffc020194a:	07a1                	addi	a5,a5,8
ffffffffc020194c:	fef69ae3          	bne	a3,a5,ffffffffc0201940 <alloc_check+0xbe>
    }

    // 确保页面地址在合法范围内
    for (int i = 0; i < num_pages_to_alloc; i++) {
        assert(page2pa(pages[i]) < npage * PGSIZE);
ffffffffc0201950:	00008617          	auipc	a2,0x8
ffffffffc0201954:	bd863603          	ld	a2,-1064(a2) # ffffffffc0209528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201958:	00008817          	auipc	a6,0x8
ffffffffc020195c:	bd883803          	ld	a6,-1064(a6) # ffffffffc0209530 <pages>
ffffffffc0201960:	00004517          	auipc	a0,0x4
ffffffffc0201964:	d9053503          	ld	a0,-624(a0) # ffffffffc02056f0 <nbase>
ffffffffc0201968:	0632                	slli	a2,a2,0xc
ffffffffc020196a:	8756                	mv	a4,s5
ffffffffc020196c:	00004597          	auipc	a1,0x4
ffffffffc0201970:	d7c5b583          	ld	a1,-644(a1) # ffffffffc02056e8 <error_string+0x38>
ffffffffc0201974:	631c                	ld	a5,0(a4)
ffffffffc0201976:	410787b3          	sub	a5,a5,a6
ffffffffc020197a:	878d                	srai	a5,a5,0x3
ffffffffc020197c:	02b787b3          	mul	a5,a5,a1
ffffffffc0201980:	97aa                	add	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201982:	07b2                	slli	a5,a5,0xc
ffffffffc0201984:	24c7f663          	bgeu	a5,a2,ffffffffc0201bd0 <alloc_check+0x34e>
    for (int i = 0; i < num_pages_to_alloc; i++) {
ffffffffc0201988:	0721                	addi	a4,a4,8
ffffffffc020198a:	fee695e3          	bne	a3,a4,ffffffffc0201974 <alloc_check+0xf2>
    return listelm->next;
ffffffffc020198e:	6480                	ld	s0,8(s1)
    // 检查空闲列表中的页面
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        page = le2page(le, page_link);
        assert(buddy_allocate_pages(page->property) != NULL);
        cprintf("[buddy sysetm] allocated from free list: %p\n", page);
ffffffffc0201990:	00003b97          	auipc	s7,0x3
ffffffffc0201994:	078b8b93          	addi	s7,s7,120 # ffffffffc0204a08 <best_fit_pmm_manager+0x168>
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201998:	02940163          	beq	s0,s1,ffffffffc02019ba <alloc_check+0x138>
        assert(buddy_allocate_pages(page->property) != NULL);
ffffffffc020199c:	ff846503          	lwu	a0,-8(s0)
        page = le2page(le, page_link);
ffffffffc02019a0:	fe840b13          	addi	s6,s0,-24
        assert(buddy_allocate_pages(page->property) != NULL);
ffffffffc02019a4:	c07ff0ef          	jal	ra,ffffffffc02015aa <buddy_allocate_pages>
ffffffffc02019a8:	1a050463          	beqz	a0,ffffffffc0201b50 <alloc_check+0x2ce>
        cprintf("[buddy sysetm] allocated from free list: %p\n", page);
ffffffffc02019ac:	85da                	mv	a1,s6
ffffffffc02019ae:	855e                	mv	a0,s7
ffffffffc02019b0:	f26fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
ffffffffc02019b4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02019b6:	fe9413e3          	bne	s0,s1,ffffffffc020199c <alloc_check+0x11a>
    }

    // 检查分配失败的情况
    assert(alloc_page() == NULL);
ffffffffc02019ba:	4505                	li	a0,1
ffffffffc02019bc:	0ae010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02019c0:	30051863          	bnez	a0,ffffffffc0201cd0 <alloc_check+0x44e>

    // 释放分配的页面
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
        free_page(pages[i]);
        cprintf("[buddy sysetm] freed page %d at address %p\n", i + 1, pages[i]);
ffffffffc02019c4:	00003b97          	auipc	s7,0x3
ffffffffc02019c8:	074b8b93          	addi	s7,s7,116 # ffffffffc0204a38 <best_fit_pmm_manager+0x198>
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
ffffffffc02019cc:	4b11                	li	s6,4
        free_page(pages[i]);
ffffffffc02019ce:	000ab403          	ld	s0,0(s5)
ffffffffc02019d2:	4585                	li	a1,1
        cprintf("[buddy sysetm] freed page %d at address %p\n", i + 1, pages[i]);
ffffffffc02019d4:	2a05                	addiw	s4,s4,1
        free_page(pages[i]);
ffffffffc02019d6:	8522                	mv	a0,s0
ffffffffc02019d8:	0d0010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
        cprintf("[buddy sysetm] freed page %d at address %p\n", i + 1, pages[i]);
ffffffffc02019dc:	8622                	mv	a2,s0
ffffffffc02019de:	85d2                	mv	a1,s4
ffffffffc02019e0:	855e                	mv	a0,s7
ffffffffc02019e2:	ef4fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    for (int i = 0; i < num_pages_to_alloc - 1; i++) {
ffffffffc02019e6:	0aa1                	addi	s5,s5,8
ffffffffc02019e8:	ff6a13e3          	bne	s4,s6,ffffffffc02019ce <alloc_check+0x14c>
    }
    assert(nr_free == 4); // 确保空闲页面数正确
ffffffffc02019ec:	489c                	lw	a5,16(s1)
ffffffffc02019ee:	33479163          	bne	a5,s4,ffffffffc0201d10 <alloc_check+0x48e>
    cprintf("[buddy sysetm] number of free pages: %d\n", nr_free);
ffffffffc02019f2:	4591                	li	a1,4
ffffffffc02019f4:	00003517          	auipc	a0,0x3
ffffffffc02019f8:	08450513          	addi	a0,a0,132 # ffffffffc0204a78 <best_fit_pmm_manager+0x1d8>
ffffffffc02019fc:	edafe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    

    // 重新分配页面
    struct Page *allocated_page;
    assert((allocated_page = alloc_page()) != NULL);
ffffffffc0201a00:	4505                	li	a0,1
ffffffffc0201a02:	068010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201a06:	842a                	mv	s0,a0
ffffffffc0201a08:	22050463          	beqz	a0,ffffffffc0201c30 <alloc_check+0x3ae>
    cprintf("[buddy sysetm] reallocated a single page at %p\n", allocated_page);
ffffffffc0201a0c:	85aa                	mv	a1,a0
ffffffffc0201a0e:	00003517          	auipc	a0,0x3
ffffffffc0201a12:	0c250513          	addi	a0,a0,194 # ffffffffc0204ad0 <best_fit_pmm_manager+0x230>
ffffffffc0201a16:	ec0fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    
    struct Page *double_allocated_page = alloc_pages(2);
ffffffffc0201a1a:	4509                	li	a0,2
ffffffffc0201a1c:	04e010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201a20:	8aaa                	mv	s5,a0
    assert(double_allocated_page != NULL);
ffffffffc0201a22:	1e050763          	beqz	a0,ffffffffc0201c10 <alloc_check+0x38e>
    cprintf("[buddy sysetm] allocated two pages at %p\n", double_allocated_page);
ffffffffc0201a26:	85aa                	mv	a1,a0
ffffffffc0201a28:	00003517          	auipc	a0,0x3
ffffffffc0201a2c:	0f850513          	addi	a0,a0,248 # ffffffffc0204b20 <best_fit_pmm_manager+0x280>
ffffffffc0201a30:	ea6fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>

    // 重新分配页面
    struct Page *allocated_page_second;
    assert((allocated_page_second = alloc_page()) != NULL);
ffffffffc0201a34:	4505                	li	a0,1
ffffffffc0201a36:	034010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201a3a:	8a2a                	mv	s4,a0
ffffffffc0201a3c:	1a050a63          	beqz	a0,ffffffffc0201bf0 <alloc_check+0x36e>
    cprintf("[buddy sysetm] reallocated a single page again at %p\n", allocated_page_second);
ffffffffc0201a40:	85aa                	mv	a1,a0
ffffffffc0201a42:	00003517          	auipc	a0,0x3
ffffffffc0201a46:	13e50513          	addi	a0,a0,318 # ffffffffc0204b80 <best_fit_pmm_manager+0x2e0>
ffffffffc0201a4a:	e8cfe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    
    // 检查再次分配失败
    assert(alloc_page() == NULL);
ffffffffc0201a4e:	4505                	li	a0,1
ffffffffc0201a50:	01a010ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201a54:	22051e63          	bnez	a0,ffffffffc0201c90 <alloc_check+0x40e>
    cprintf("[buddy sysetm] second allocation failed as expected\n");
ffffffffc0201a58:	00003517          	auipc	a0,0x3
ffffffffc0201a5c:	16050513          	addi	a0,a0,352 # ffffffffc0204bb8 <best_fit_pmm_manager+0x318>
ffffffffc0201a60:	e76fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>

    // 释放页面
    free_pages(double_allocated_page, 2);
ffffffffc0201a64:	8556                	mv	a0,s5
ffffffffc0201a66:	4589                	li	a1,2
ffffffffc0201a68:	040010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    cprintf("[buddy sysetm] freed two pages starting at %p\n", double_allocated_page);
ffffffffc0201a6c:	85d6                	mv	a1,s5
ffffffffc0201a6e:	00003517          	auipc	a0,0x3
ffffffffc0201a72:	18250513          	addi	a0,a0,386 # ffffffffc0204bf0 <best_fit_pmm_manager+0x350>
ffffffffc0201a76:	e60fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    free_page(allocated_page);
ffffffffc0201a7a:	8522                	mv	a0,s0
ffffffffc0201a7c:	4585                	li	a1,1
ffffffffc0201a7e:	02a010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    cprintf("[buddy sysetm] freed the reallocated page at %p\n", allocated_page);
ffffffffc0201a82:	85a2                	mv	a1,s0
ffffffffc0201a84:	00003517          	auipc	a0,0x3
ffffffffc0201a88:	19c50513          	addi	a0,a0,412 # ffffffffc0204c20 <best_fit_pmm_manager+0x380>
ffffffffc0201a8c:	e4afe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    free_page(allocated_page_second);
ffffffffc0201a90:	8552                	mv	a0,s4
ffffffffc0201a92:	4585                	li	a1,1
ffffffffc0201a94:	014010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    cprintf("[buddy sysetm] freed the reallocated page again at %p\n", allocated_page_second);
ffffffffc0201a98:	85d2                	mv	a1,s4
ffffffffc0201a9a:	00003517          	auipc	a0,0x3
ffffffffc0201a9e:	1be50513          	addi	a0,a0,446 # ffffffffc0204c58 <best_fit_pmm_manager+0x3b8>
ffffffffc0201aa2:	e34fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>

    // 再次分配页面
    assert((page = alloc_pages(4)) == allocated_page);
ffffffffc0201aa6:	4511                	li	a0,4
ffffffffc0201aa8:	7c3000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201aac:	24a41263          	bne	s0,a0,ffffffffc0201cf0 <alloc_check+0x46e>
    cprintf("[buddy sysetm] allocated four pages starting at %p\n", allocated_page);
ffffffffc0201ab0:	85a2                	mv	a1,s0
ffffffffc0201ab2:	00003517          	auipc	a0,0x3
ffffffffc0201ab6:	20e50513          	addi	a0,a0,526 # ffffffffc0204cc0 <best_fit_pmm_manager+0x420>
ffffffffc0201aba:	e1cfe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    assert(alloc_page() == NULL);
ffffffffc0201abe:	4505                	li	a0,1
ffffffffc0201ac0:	7ab000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201ac4:	18051663          	bnez	a0,ffffffffc0201c50 <alloc_check+0x3ce>
    cprintf("[buddy sysetm] final allocation succeeded as expected\n");
ffffffffc0201ac8:	00003517          	auipc	a0,0x3
ffffffffc0201acc:	23050513          	addi	a0,a0,560 # ffffffffc0204cf8 <best_fit_pmm_manager+0x458>
ffffffffc0201ad0:	e06fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>

    assert(nr_free == 0); // 确保没有空闲页面
ffffffffc0201ad4:	489c                	lw	a5,16(s1)
ffffffffc0201ad6:	1c079d63          	bnez	a5,ffffffffc0201cb0 <alloc_check+0x42e>
    cprintf("[buddy sysetm] no free pages remaining\n");
ffffffffc0201ada:	00003517          	auipc	a0,0x3
ffffffffc0201ade:	25650513          	addi	a0,a0,598 # ffffffffc0204d30 <best_fit_pmm_manager+0x490>
ffffffffc0201ae2:	df4fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>

    // 重新标记物理区域
    for (page = physical_area; page < physical_area + total_size_store; page++) {
ffffffffc0201ae6:	00093783          	ld	a5,0(s2)
ffffffffc0201aea:	00299693          	slli	a3,s3,0x2
ffffffffc0201aee:	96ce                	add	a3,a3,s3
ffffffffc0201af0:	068e                	slli	a3,a3,0x3
ffffffffc0201af2:	00d78733          	add	a4,a5,a3
ffffffffc0201af6:	04e7fb63          	bgeu	a5,a4,ffffffffc0201b4c <alloc_check+0x2ca>
ffffffffc0201afa:	4605                	li	a2,1
ffffffffc0201afc:	00878713          	addi	a4,a5,8
ffffffffc0201b00:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc0201b04:	00093503          	ld	a0,0(s2)
ffffffffc0201b08:	02878793          	addi	a5,a5,40
ffffffffc0201b0c:	00d50733          	add	a4,a0,a3
ffffffffc0201b10:	fee7e6e3          	bltu	a5,a4,ffffffffc0201afc <alloc_check+0x27a>
    elm->prev = elm->next = elm;
ffffffffc0201b14:	e484                	sd	s1,8(s1)
ffffffffc0201b16:	e084                	sd	s1,0(s1)
    nr_free = 0;
ffffffffc0201b18:	00007797          	auipc	a5,0x7
ffffffffc0201b1c:	5007a423          	sw	zero,1288(a5) # ffffffffc0209020 <free_area+0x10>
    assert(n > 0);
ffffffffc0201b20:	14098863          	beqz	s3,ffffffffc0201c70 <alloc_check+0x3ee>
ffffffffc0201b24:	85ce                	mv	a1,s3
ffffffffc0201b26:	f40ff0ef          	jal	ra,ffffffffc0201266 <buddy_init_memmap.part.0>
        SetPageReserved(page);
    }
    buddy_init();
    buddy_init_memmap(physical_area, total_size_store);
    cprintf("[buddy sysetm] memory re-initialized and reserved\n");
ffffffffc0201b2a:	00003517          	auipc	a0,0x3
ffffffffc0201b2e:	22e50513          	addi	a0,a0,558 # ffffffffc0204d58 <best_fit_pmm_manager+0x4b8>
ffffffffc0201b32:	da4fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
}
ffffffffc0201b36:	70e6                	ld	ra,120(sp)
ffffffffc0201b38:	7446                	ld	s0,112(sp)
ffffffffc0201b3a:	74a6                	ld	s1,104(sp)
ffffffffc0201b3c:	7906                	ld	s2,96(sp)
ffffffffc0201b3e:	69e6                	ld	s3,88(sp)
ffffffffc0201b40:	6a46                	ld	s4,80(sp)
ffffffffc0201b42:	6aa6                	ld	s5,72(sp)
ffffffffc0201b44:	6b06                	ld	s6,64(sp)
ffffffffc0201b46:	7be2                	ld	s7,56(sp)
ffffffffc0201b48:	6109                	addi	sp,sp,128
ffffffffc0201b4a:	8082                	ret
    for (page = physical_area; page < physical_area + total_size_store; page++) {
ffffffffc0201b4c:	853e                	mv	a0,a5
ffffffffc0201b4e:	b7d9                	j	ffffffffc0201b14 <alloc_check+0x292>
        assert(buddy_allocate_pages(page->property) != NULL);
ffffffffc0201b50:	00003697          	auipc	a3,0x3
ffffffffc0201b54:	e8868693          	addi	a3,a3,-376 # ffffffffc02049d8 <best_fit_pmm_manager+0x138>
ffffffffc0201b58:	00003617          	auipc	a2,0x3
ffffffffc0201b5c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0204510 <commands+0x500>
ffffffffc0201b60:	13700593          	li	a1,311
ffffffffc0201b64:	00003517          	auipc	a0,0x3
ffffffffc0201b68:	d7450513          	addi	a0,a0,-652 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201b6c:	865fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
        assert((pages[i] = alloc_page()) != NULL);
ffffffffc0201b70:	00003697          	auipc	a3,0x3
ffffffffc0201b74:	db068693          	addi	a3,a3,-592 # ffffffffc0204920 <best_fit_pmm_manager+0x80>
ffffffffc0201b78:	00003617          	auipc	a2,0x3
ffffffffc0201b7c:	99860613          	addi	a2,a2,-1640 # ffffffffc0204510 <commands+0x500>
ffffffffc0201b80:	12000593          	li	a1,288
ffffffffc0201b84:	00003517          	auipc	a0,0x3
ffffffffc0201b88:	d5450513          	addi	a0,a0,-684 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201b8c:	845fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
        assert(page_ref(pages[i]) == 0);
ffffffffc0201b90:	00003697          	auipc	a3,0x3
ffffffffc0201b94:	e0868693          	addi	a3,a3,-504 # ffffffffc0204998 <best_fit_pmm_manager+0xf8>
ffffffffc0201b98:	00003617          	auipc	a2,0x3
ffffffffc0201b9c:	97860613          	addi	a2,a2,-1672 # ffffffffc0204510 <commands+0x500>
ffffffffc0201ba0:	12b00593          	li	a1,299
ffffffffc0201ba4:	00003517          	auipc	a0,0x3
ffffffffc0201ba8:	d3450513          	addi	a0,a0,-716 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201bac:	825fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
        assert(pages[i] + 1 == pages[i + 1]);
ffffffffc0201bb0:	00003697          	auipc	a3,0x3
ffffffffc0201bb4:	dc868693          	addi	a3,a3,-568 # ffffffffc0204978 <best_fit_pmm_manager+0xd8>
ffffffffc0201bb8:	00003617          	auipc	a2,0x3
ffffffffc0201bbc:	95860613          	addi	a2,a2,-1704 # ffffffffc0204510 <commands+0x500>
ffffffffc0201bc0:	12600593          	li	a1,294
ffffffffc0201bc4:	00003517          	auipc	a0,0x3
ffffffffc0201bc8:	d1450513          	addi	a0,a0,-748 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201bcc:	805fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
        assert(page2pa(pages[i]) < npage * PGSIZE);
ffffffffc0201bd0:	00003697          	auipc	a3,0x3
ffffffffc0201bd4:	de068693          	addi	a3,a3,-544 # ffffffffc02049b0 <best_fit_pmm_manager+0x110>
ffffffffc0201bd8:	00003617          	auipc	a2,0x3
ffffffffc0201bdc:	93860613          	addi	a2,a2,-1736 # ffffffffc0204510 <commands+0x500>
ffffffffc0201be0:	13000593          	li	a1,304
ffffffffc0201be4:	00003517          	auipc	a0,0x3
ffffffffc0201be8:	cf450513          	addi	a0,a0,-780 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201bec:	fe4fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((allocated_page_second = alloc_page()) != NULL);
ffffffffc0201bf0:	00003697          	auipc	a3,0x3
ffffffffc0201bf4:	f6068693          	addi	a3,a3,-160 # ffffffffc0204b50 <best_fit_pmm_manager+0x2b0>
ffffffffc0201bf8:	00003617          	auipc	a2,0x3
ffffffffc0201bfc:	91860613          	addi	a2,a2,-1768 # ffffffffc0204510 <commands+0x500>
ffffffffc0201c00:	15200593          	li	a1,338
ffffffffc0201c04:	00003517          	auipc	a0,0x3
ffffffffc0201c08:	cd450513          	addi	a0,a0,-812 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201c0c:	fc4fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(double_allocated_page != NULL);
ffffffffc0201c10:	00003697          	auipc	a3,0x3
ffffffffc0201c14:	ef068693          	addi	a3,a3,-272 # ffffffffc0204b00 <best_fit_pmm_manager+0x260>
ffffffffc0201c18:	00003617          	auipc	a2,0x3
ffffffffc0201c1c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0204510 <commands+0x500>
ffffffffc0201c20:	14d00593          	li	a1,333
ffffffffc0201c24:	00003517          	auipc	a0,0x3
ffffffffc0201c28:	cb450513          	addi	a0,a0,-844 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201c2c:	fa4fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((allocated_page = alloc_page()) != NULL);
ffffffffc0201c30:	00003697          	auipc	a3,0x3
ffffffffc0201c34:	e7868693          	addi	a3,a3,-392 # ffffffffc0204aa8 <best_fit_pmm_manager+0x208>
ffffffffc0201c38:	00003617          	auipc	a2,0x3
ffffffffc0201c3c:	8d860613          	addi	a2,a2,-1832 # ffffffffc0204510 <commands+0x500>
ffffffffc0201c40:	14900593          	li	a1,329
ffffffffc0201c44:	00003517          	auipc	a0,0x3
ffffffffc0201c48:	c9450513          	addi	a0,a0,-876 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201c4c:	f84fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201c50:	00003697          	auipc	a3,0x3
ffffffffc0201c54:	a7068693          	addi	a3,a3,-1424 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0201c58:	00003617          	auipc	a2,0x3
ffffffffc0201c5c:	8b860613          	addi	a2,a2,-1864 # ffffffffc0204510 <commands+0x500>
ffffffffc0201c60:	16400593          	li	a1,356
ffffffffc0201c64:	00003517          	auipc	a0,0x3
ffffffffc0201c68:	c7450513          	addi	a0,a0,-908 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201c6c:	f64fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(n > 0);
ffffffffc0201c70:	00003697          	auipc	a3,0x3
ffffffffc0201c74:	89868693          	addi	a3,a3,-1896 # ffffffffc0204508 <commands+0x4f8>
ffffffffc0201c78:	00003617          	auipc	a2,0x3
ffffffffc0201c7c:	89860613          	addi	a2,a2,-1896 # ffffffffc0204510 <commands+0x500>
ffffffffc0201c80:	05f00593          	li	a1,95
ffffffffc0201c84:	00003517          	auipc	a0,0x3
ffffffffc0201c88:	c5450513          	addi	a0,a0,-940 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201c8c:	f44fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201c90:	00003697          	auipc	a3,0x3
ffffffffc0201c94:	a3068693          	addi	a3,a3,-1488 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0201c98:	00003617          	auipc	a2,0x3
ffffffffc0201c9c:	87860613          	addi	a2,a2,-1928 # ffffffffc0204510 <commands+0x500>
ffffffffc0201ca0:	15600593          	li	a1,342
ffffffffc0201ca4:	00003517          	auipc	a0,0x3
ffffffffc0201ca8:	c3450513          	addi	a0,a0,-972 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201cac:	f24fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 0); // 确保没有空闲页面
ffffffffc0201cb0:	00003697          	auipc	a3,0x3
ffffffffc0201cb4:	a7068693          	addi	a3,a3,-1424 # ffffffffc0204720 <commands+0x710>
ffffffffc0201cb8:	00003617          	auipc	a2,0x3
ffffffffc0201cbc:	85860613          	addi	a2,a2,-1960 # ffffffffc0204510 <commands+0x500>
ffffffffc0201cc0:	16700593          	li	a1,359
ffffffffc0201cc4:	00003517          	auipc	a0,0x3
ffffffffc0201cc8:	c1450513          	addi	a0,a0,-1004 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201ccc:	f04fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201cd0:	00003697          	auipc	a3,0x3
ffffffffc0201cd4:	9f068693          	addi	a3,a3,-1552 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc0201cd8:	00003617          	auipc	a2,0x3
ffffffffc0201cdc:	83860613          	addi	a2,a2,-1992 # ffffffffc0204510 <commands+0x500>
ffffffffc0201ce0:	13c00593          	li	a1,316
ffffffffc0201ce4:	00003517          	auipc	a0,0x3
ffffffffc0201ce8:	bf450513          	addi	a0,a0,-1036 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201cec:	ee4fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((page = alloc_pages(4)) == allocated_page);
ffffffffc0201cf0:	00003697          	auipc	a3,0x3
ffffffffc0201cf4:	fa068693          	addi	a3,a3,-96 # ffffffffc0204c90 <best_fit_pmm_manager+0x3f0>
ffffffffc0201cf8:	00003617          	auipc	a2,0x3
ffffffffc0201cfc:	81860613          	addi	a2,a2,-2024 # ffffffffc0204510 <commands+0x500>
ffffffffc0201d00:	16200593          	li	a1,354
ffffffffc0201d04:	00003517          	auipc	a0,0x3
ffffffffc0201d08:	bd450513          	addi	a0,a0,-1068 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201d0c:	ec4fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 4); // 确保空闲页面数正确
ffffffffc0201d10:	00003697          	auipc	a3,0x3
ffffffffc0201d14:	d5868693          	addi	a3,a3,-680 # ffffffffc0204a68 <best_fit_pmm_manager+0x1c8>
ffffffffc0201d18:	00002617          	auipc	a2,0x2
ffffffffc0201d1c:	7f860613          	addi	a2,a2,2040 # ffffffffc0204510 <commands+0x500>
ffffffffc0201d20:	14300593          	li	a1,323
ffffffffc0201d24:	00003517          	auipc	a0,0x3
ffffffffc0201d28:	bb450513          	addi	a0,a0,-1100 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201d2c:	ea4fe0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0201d30 <buddy_free_pages>:
{
ffffffffc0201d30:	1141                	addi	sp,sp,-16
ffffffffc0201d32:	e406                	sd	ra,8(sp)
ffffffffc0201d34:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0201d36:	22058363          	beqz	a1,ffffffffc0201f5c <buddy_free_pages+0x22c>
    return (a & (a - 1)) == 0;
ffffffffc0201d3a:	fff58793          	addi	a5,a1,-1
ffffffffc0201d3e:	8fed                	and	a5,a5,a1
ffffffffc0201d40:	882e                	mv	a6,a1
    if (is_power_of_2(a)) return a;
ffffffffc0201d42:	cb81                	beqz	a5,ffffffffc0201d52 <buddy_free_pages+0x22>
    while (res < a) res <<= 1;
ffffffffc0201d44:	4785                	li	a5,1
ffffffffc0201d46:	00f58663          	beq	a1,a5,ffffffffc0201d52 <buddy_free_pages+0x22>
    size_t res = 1;
ffffffffc0201d4a:	4805                	li	a6,1
    while (res < a) res <<= 1;
ffffffffc0201d4c:	0806                	slli	a6,a6,0x1
ffffffffc0201d4e:	feb86fe3          	bltu	a6,a1,ffffffffc0201d4c <buddy_free_pages+0x1c>
    size_t begin = (base - allocate_area);
ffffffffc0201d52:	00007317          	auipc	t1,0x7
ffffffffc0201d56:	79e33303          	ld	t1,1950(t1) # ffffffffc02094f0 <allocate_area>
ffffffffc0201d5a:	40650633          	sub	a2,a0,t1
ffffffffc0201d5e:	00004797          	auipc	a5,0x4
ffffffffc0201d62:	98a7b783          	ld	a5,-1654(a5) # ffffffffc02056e8 <error_string+0x38>
ffffffffc0201d66:	860d                	srai	a2,a2,0x3
ffffffffc0201d68:	02f60633          	mul	a2,a2,a5
    size_t block = buddy_block(full_tree_size, begin, end);
ffffffffc0201d6c:	00007897          	auipc	a7,0x7
ffffffffc0201d70:	78c8b883          	ld	a7,1932(a7) # ffffffffc02094f8 <full_tree_size>
    for (; p != base + n; p++)
ffffffffc0201d74:	00259693          	slli	a3,a1,0x2
ffffffffc0201d78:	96ae                	add	a3,a3,a1
ffffffffc0201d7a:	068e                	slli	a3,a3,0x3
ffffffffc0201d7c:	96aa                	add	a3,a3,a0
ffffffffc0201d7e:	87aa                	mv	a5,a0
    return full_tree_size / ((b) - (a)) + (a) / ((b) - (a));
ffffffffc0201d80:	03065633          	divu	a2,a2,a6
ffffffffc0201d84:	0308d733          	divu	a4,a7,a6
ffffffffc0201d88:	963a                	add	a2,a2,a4
    for (; p != base + n; p++)
ffffffffc0201d8a:	00d50e63          	beq	a0,a3,ffffffffc0201da6 <buddy_free_pages+0x76>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201d8e:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p));
ffffffffc0201d90:	8b05                	andi	a4,a4,1
ffffffffc0201d92:	1a071563          	bnez	a4,ffffffffc0201f3c <buddy_free_pages+0x20c>
        p->flags = 0;
ffffffffc0201d96:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201d9a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201d9e:	02878793          	addi	a5,a5,40
ffffffffc0201da2:	fed796e3          	bne	a5,a3,ffffffffc0201d8e <buddy_free_pages+0x5e>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201da6:	00007f97          	auipc	t6,0x7
ffffffffc0201daa:	26af8f93          	addi	t6,t6,618 # ffffffffc0209010 <free_area>
    nr_free += length;
ffffffffc0201dae:	010fa703          	lw	a4,16(t6)
ffffffffc0201db2:	008fb683          	ld	a3,8(t6)
    base->property = length;
ffffffffc0201db6:	0008079b          	sext.w	a5,a6
ffffffffc0201dba:	c91c                	sw	a5,16(a0)
    list_add(&free_list, &(base->page_link));
ffffffffc0201dbc:	01850593          	addi	a1,a0,24
    prev->next = next->prev = elm;
ffffffffc0201dc0:	e28c                	sd	a1,0(a3)
    nr_free += length;
ffffffffc0201dc2:	9f3d                	addw	a4,a4,a5
    record_area[block] = length;
ffffffffc0201dc4:	00007e97          	auipc	t4,0x7
ffffffffc0201dc8:	74cebe83          	ld	t4,1868(t4) # ffffffffc0209510 <record_area>
ffffffffc0201dcc:	00361793          	slli	a5,a2,0x3
ffffffffc0201dd0:	97f6                	add	a5,a5,t4
ffffffffc0201dd2:	00bfb423          	sd	a1,8(t6)
    elm->next = next;
ffffffffc0201dd6:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0201dd8:	01f53c23          	sd	t6,24(a0)
    nr_free += length;
ffffffffc0201ddc:	00efa823          	sw	a4,16(t6)
    record_area[block] = length;
ffffffffc0201de0:	0107b023          	sd	a6,0(a5)
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201de4:	52fd                	li	t0,-1
    while (block != TREE_ROOT)
ffffffffc0201de6:	4785                	li	a5,1
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201de8:	0012d293          	srli	t0,t0,0x1
    while (res < a) res <<= 1;
ffffffffc0201dec:	4f05                	li	t5,1
    while (block != TREE_ROOT)
ffffffffc0201dee:	04f60763          	beq	a2,a5,ffffffffc0201e3c <buddy_free_pages+0x10c>
    return a << 1;
ffffffffc0201df2:	ffe67713          	andi	a4,a2,-2
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0201df6:	00371813          	slli	a6,a4,0x3
    return (a & (a - 1)) == 0;
ffffffffc0201dfa:	fff70593          	addi	a1,a4,-1
ffffffffc0201dfe:	86b2                	mv	a3,a2
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0201e00:	9876                	add	a6,a6,t4
    return (a & (a - 1)) == 0;
ffffffffc0201e02:	8df9                	and	a1,a1,a4
    return (a << 1) + 1;
ffffffffc0201e04:	0016e513          	ori	a0,a3,1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0201e08:	00083e03          	ld	t3,0(a6)
    return a >> 1;
ffffffffc0201e0c:	8205                	srli	a2,a2,0x1
    return a << 1;
ffffffffc0201e0e:	86ba                	mv	a3,a4
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201e10:	c981                	beqz	a1,ffffffffc0201e20 <buddy_free_pages+0xf0>
    size_t res = 1;
ffffffffc0201e12:	4785                	li	a5,1
    while (res < a) res <<= 1;
ffffffffc0201e14:	86be                	mv	a3,a5
ffffffffc0201e16:	0786                	slli	a5,a5,0x1
ffffffffc0201e18:	fee7eee3          	bltu	a5,a4,ffffffffc0201e14 <buddy_free_pages+0xe4>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201e1c:	0056f6b3          	and	a3,a3,t0
    return full_tree_size / power_round_down(a);
ffffffffc0201e20:	02d8d6b3          	divu	a3,a7,a3
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0201e24:	00883783          	ld	a5,8(a6)
ffffffffc0201e28:	00de0e63          	beq	t3,a3,ffffffffc0201e44 <buddy_free_pages+0x114>
            record_area[block] = record_area[left_child(block)] | record_area[right_child(block)];
ffffffffc0201e2c:	00361713          	slli	a4,a2,0x3
ffffffffc0201e30:	9776                	add	a4,a4,t4
ffffffffc0201e32:	00fe67b3          	or	a5,t3,a5
ffffffffc0201e36:	e31c                	sd	a5,0(a4)
    while (block != TREE_ROOT)
ffffffffc0201e38:	fbe61de3          	bne	a2,t5,ffffffffc0201df2 <buddy_free_pages+0xc2>
}
ffffffffc0201e3c:	60a2                	ld	ra,8(sp)
ffffffffc0201e3e:	6402                	ld	s0,0(sp)
ffffffffc0201e40:	0141                	addi	sp,sp,16
ffffffffc0201e42:	8082                	ret
    return (a & (a - 1)) == 0;
ffffffffc0201e44:	00e57433          	and	s0,a0,a4
    return (a << 1) + 1;
ffffffffc0201e48:	83aa                	mv	t2,a0
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201e4a:	c811                	beqz	s0,ffffffffc0201e5e <buddy_free_pages+0x12e>
    while (res < a) res <<= 1;
ffffffffc0201e4c:	0fe50463          	beq	a0,t5,ffffffffc0201f34 <buddy_free_pages+0x204>
    size_t res = 1;
ffffffffc0201e50:	4685                	li	a3,1
    while (res < a) res <<= 1;
ffffffffc0201e52:	83b6                	mv	t2,a3
ffffffffc0201e54:	0686                	slli	a3,a3,0x1
ffffffffc0201e56:	fea6eee3          	bltu	a3,a0,ffffffffc0201e52 <buddy_free_pages+0x122>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201e5a:	0053f3b3          	and	t2,t2,t0
    return full_tree_size / power_round_down(a);
ffffffffc0201e5e:	0278d3b3          	divu	t2,a7,t2
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0201e62:	fcf395e3          	bne	t2,a5,ffffffffc0201e2c <buddy_free_pages+0xfc>
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201e66:	00c766b3          	or	a3,a4,a2
ffffffffc0201e6a:	0026d793          	srli	a5,a3,0x2
ffffffffc0201e6e:	8fd5                	or	a5,a5,a3
ffffffffc0201e70:	0047d693          	srli	a3,a5,0x4
ffffffffc0201e74:	8edd                	or	a3,a3,a5
ffffffffc0201e76:	0086d793          	srli	a5,a3,0x8
ffffffffc0201e7a:	8edd                	or	a3,a3,a5
ffffffffc0201e7c:	0106d793          	srli	a5,a3,0x10
ffffffffc0201e80:	8fd5                	or	a5,a5,a3
ffffffffc0201e82:	8385                	srli	a5,a5,0x1
ffffffffc0201e84:	00e7f3b3          	and	t2,a5,a4
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201e88:	c981                	beqz	a1,ffffffffc0201e98 <buddy_free_pages+0x168>
    size_t res = 1;
ffffffffc0201e8a:	4785                	li	a5,1
    while (res < a) res <<= 1;
ffffffffc0201e8c:	86be                	mv	a3,a5
ffffffffc0201e8e:	0786                	slli	a5,a5,0x1
ffffffffc0201e90:	fee7eee3          	bltu	a5,a4,ffffffffc0201e8c <buddy_free_pages+0x15c>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201e94:	0056f733          	and	a4,a3,t0
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201e98:	00155793          	srli	a5,a0,0x1
ffffffffc0201e9c:	8fc9                	or	a5,a5,a0
ffffffffc0201e9e:	0027d693          	srli	a3,a5,0x2
ffffffffc0201ea2:	8edd                	or	a3,a3,a5
ffffffffc0201ea4:	0046d793          	srli	a5,a3,0x4
ffffffffc0201ea8:	8edd                	or	a3,a3,a5
ffffffffc0201eaa:	0086d793          	srli	a5,a3,0x8
ffffffffc0201eae:	8fd5                	or	a5,a5,a3
ffffffffc0201eb0:	0107d693          	srli	a3,a5,0x10
ffffffffc0201eb4:	8edd                	or	a3,a3,a5
ffffffffc0201eb6:	8285                	srli	a3,a3,0x1
    return full_tree_size / power_round_down(a);
ffffffffc0201eb8:	02e8d7b3          	divu	a5,a7,a4
    return a & (ALL_BIT_TO_ONE(a) >> 1);
ffffffffc0201ebc:	8ee9                	and	a3,a3,a0
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201ebe:	c811                	beqz	s0,ffffffffc0201ed2 <buddy_free_pages+0x1a2>
    while (res < a) res <<= 1;
ffffffffc0201ec0:	07e50c63          	beq	a0,t5,ffffffffc0201f38 <buddy_free_pages+0x208>
    size_t res = 1;
ffffffffc0201ec4:	4705                	li	a4,1
    while (res < a) res <<= 1;
ffffffffc0201ec6:	85ba                	mv	a1,a4
ffffffffc0201ec8:	0706                	slli	a4,a4,0x1
ffffffffc0201eca:	fea76ee3          	bltu	a4,a0,ffffffffc0201ec6 <buddy_free_pages+0x196>
    return is_power_of_2(a) ? a : (power_round_up(a) >> 1);
ffffffffc0201ece:	0055f533          	and	a0,a1,t0
            record_area[block] = record_area[left] << 1;
ffffffffc0201ed2:	0e06                	slli	t3,t3,0x1
    return full_tree_size / power_round_down(a);
ffffffffc0201ed4:	02a8d733          	divu	a4,a7,a0
            record_area[block] = record_area[left] << 1;
ffffffffc0201ed8:	00361513          	slli	a0,a2,0x3
ffffffffc0201edc:	9576                	add	a0,a0,t4
            list_del(&(allocate_area[lbegin].page_link));
ffffffffc0201ede:	027787b3          	mul	a5,a5,t2
            list_del(&(allocate_area[rbegin].page_link));
ffffffffc0201ee2:	02d70733          	mul	a4,a4,a3
            list_del(&(allocate_area[lbegin].page_link));
ffffffffc0201ee6:	00279693          	slli	a3,a5,0x2
ffffffffc0201eea:	96be                	add	a3,a3,a5
ffffffffc0201eec:	068e                	slli	a3,a3,0x3
ffffffffc0201eee:	969a                	add	a3,a3,t1
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ef0:	729c                	ld	a5,32(a3)
ffffffffc0201ef2:	6e80                	ld	s0,24(a3)
            list_add(&free_list, &(allocate_area[lbegin].page_link));
ffffffffc0201ef4:	01868393          	addi	t2,a3,24
    prev->next = next;
ffffffffc0201ef8:	e41c                	sd	a5,8(s0)
            list_del(&(allocate_area[rbegin].page_link));
ffffffffc0201efa:	00271593          	slli	a1,a4,0x2
ffffffffc0201efe:	972e                	add	a4,a4,a1
ffffffffc0201f00:	070e                	slli	a4,a4,0x3
    next->prev = prev;
ffffffffc0201f02:	e380                	sd	s0,0(a5)
ffffffffc0201f04:	971a                	add	a4,a4,t1
    __list_del(listelm->prev, listelm->next);
ffffffffc0201f06:	6f0c                	ld	a1,24(a4)
ffffffffc0201f08:	7318                	ld	a4,32(a4)
    prev->next = next;
ffffffffc0201f0a:	e598                	sd	a4,8(a1)
    next->prev = prev;
ffffffffc0201f0c:	e30c                	sd	a1,0(a4)
            record_area[block] = record_area[left] << 1;
ffffffffc0201f0e:	01c53023          	sd	t3,0(a0)
            allocate_area[lbegin].property = record_area[left] << 1;
ffffffffc0201f12:	00083783          	ld	a5,0(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201f16:	008fb703          	ld	a4,8(t6)
ffffffffc0201f1a:	0017979b          	slliw	a5,a5,0x1
ffffffffc0201f1e:	ca9c                	sw	a5,16(a3)
    prev->next = next->prev = elm;
ffffffffc0201f20:	00773023          	sd	t2,0(a4)
ffffffffc0201f24:	007fb423          	sd	t2,8(t6)
    elm->next = next;
ffffffffc0201f28:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc0201f2a:	01f6bc23          	sd	t6,24(a3)
    while (block != TREE_ROOT)
ffffffffc0201f2e:	ede612e3          	bne	a2,t5,ffffffffc0201df2 <buddy_free_pages+0xc2>
ffffffffc0201f32:	b729                	j	ffffffffc0201e3c <buddy_free_pages+0x10c>
    while (res < a) res <<= 1;
ffffffffc0201f34:	4381                	li	t2,0
ffffffffc0201f36:	b725                	j	ffffffffc0201e5e <buddy_free_pages+0x12e>
ffffffffc0201f38:	4501                	li	a0,0
ffffffffc0201f3a:	bf61                	j	ffffffffc0201ed2 <buddy_free_pages+0x1a2>
        assert(!PageReserved(p));
ffffffffc0201f3c:	00003697          	auipc	a3,0x3
ffffffffc0201f40:	e5468693          	addi	a3,a3,-428 # ffffffffc0204d90 <best_fit_pmm_manager+0x4f0>
ffffffffc0201f44:	00002617          	auipc	a2,0x2
ffffffffc0201f48:	5cc60613          	addi	a2,a2,1484 # ffffffffc0204510 <commands+0x500>
ffffffffc0201f4c:	0ea00593          	li	a1,234
ffffffffc0201f50:	00003517          	auipc	a0,0x3
ffffffffc0201f54:	98850513          	addi	a0,a0,-1656 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201f58:	c78fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(n > 0);
ffffffffc0201f5c:	00002697          	auipc	a3,0x2
ffffffffc0201f60:	5ac68693          	addi	a3,a3,1452 # ffffffffc0204508 <commands+0x4f8>
ffffffffc0201f64:	00002617          	auipc	a2,0x2
ffffffffc0201f68:	5ac60613          	addi	a2,a2,1452 # ffffffffc0204510 <commands+0x500>
ffffffffc0201f6c:	0e100593          	li	a1,225
ffffffffc0201f70:	00003517          	auipc	a0,0x3
ffffffffc0201f74:	96850513          	addi	a0,a0,-1688 # ffffffffc02048d8 <best_fit_pmm_manager+0x38>
ffffffffc0201f78:	c58fe0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0201f7c <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201f7c:	00007797          	auipc	a5,0x7
ffffffffc0201f80:	09478793          	addi	a5,a5,148 # ffffffffc0209010 <free_area>
ffffffffc0201f84:	e79c                	sd	a5,8(a5)
ffffffffc0201f86:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201f88:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201f8c:	8082                	ret

ffffffffc0201f8e <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201f8e:	00007517          	auipc	a0,0x7
ffffffffc0201f92:	09256503          	lwu	a0,146(a0) # ffffffffc0209020 <free_area+0x10>
ffffffffc0201f96:	8082                	ret

ffffffffc0201f98 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201f98:	715d                	addi	sp,sp,-80
    cprintf("[first fit] default_check() started\n");
ffffffffc0201f9a:	00003517          	auipc	a0,0x3
ffffffffc0201f9e:	e5e50513          	addi	a0,a0,-418 # ffffffffc0204df8 <buddy_pmm_manager+0x38>
{
ffffffffc0201fa2:	e0a2                	sd	s0,64(sp)
ffffffffc0201fa4:	e486                	sd	ra,72(sp)
ffffffffc0201fa6:	fc26                	sd	s1,56(sp)
ffffffffc0201fa8:	f84a                	sd	s2,48(sp)
ffffffffc0201faa:	f44e                	sd	s3,40(sp)
ffffffffc0201fac:	f052                	sd	s4,32(sp)
ffffffffc0201fae:	ec56                	sd	s5,24(sp)
ffffffffc0201fb0:	e85a                	sd	s6,16(sp)
ffffffffc0201fb2:	e45e                	sd	s7,8(sp)
ffffffffc0201fb4:	e062                	sd	s8,0(sp)
    return listelm->next;
ffffffffc0201fb6:	00007417          	auipc	s0,0x7
ffffffffc0201fba:	05a40413          	addi	s0,s0,90 # ffffffffc0209010 <free_area>
    cprintf("[first fit] default_check() started\n");
ffffffffc0201fbe:	918fe0ef          	jal	ra,ffffffffc02000d6 <cprintf>
ffffffffc0201fc2:	641c                	ld	a5,8(s0)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fc4:	2c878c63          	beq	a5,s0,ffffffffc020229c <default_check+0x304>
    int count = 0, total = 0;
ffffffffc0201fc8:	4481                	li	s1,0
ffffffffc0201fca:	4901                	li	s2,0
ffffffffc0201fcc:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201fd0:	8b09                	andi	a4,a4,2
ffffffffc0201fd2:	2c070963          	beqz	a4,ffffffffc02022a4 <default_check+0x30c>
        count++, total += p->property;
ffffffffc0201fd6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201fda:	679c                	ld	a5,8(a5)
ffffffffc0201fdc:	2905                	addiw	s2,s2,1
ffffffffc0201fde:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fe0:	fe8796e3          	bne	a5,s0,ffffffffc0201fcc <default_check+0x34>
    }
    assert(total == nr_free_pages());
ffffffffc0201fe4:	89a6                	mv	s3,s1
ffffffffc0201fe6:	303000ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0201fea:	71351d63          	bne	a0,s3,ffffffffc0202704 <default_check+0x76c>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201fee:	4505                	li	a0,1
ffffffffc0201ff0:	27b000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0201ff4:	8a2a                	mv	s4,a0
ffffffffc0201ff6:	44050763          	beqz	a0,ffffffffc0202444 <default_check+0x4ac>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201ffa:	4505                	li	a0,1
ffffffffc0201ffc:	26f000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0202000:	89aa                	mv	s3,a0
ffffffffc0202002:	72050163          	beqz	a0,ffffffffc0202724 <default_check+0x78c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202006:	4505                	li	a0,1
ffffffffc0202008:	263000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc020200c:	8aaa                	mv	s5,a0
ffffffffc020200e:	4a050b63          	beqz	a0,ffffffffc02024c4 <default_check+0x52c>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202012:	2b3a0963          	beq	s4,s3,ffffffffc02022c4 <default_check+0x32c>
ffffffffc0202016:	2aaa0763          	beq	s4,a0,ffffffffc02022c4 <default_check+0x32c>
ffffffffc020201a:	2aa98563          	beq	s3,a0,ffffffffc02022c4 <default_check+0x32c>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020201e:	000a2783          	lw	a5,0(s4)
ffffffffc0202022:	2c079163          	bnez	a5,ffffffffc02022e4 <default_check+0x34c>
ffffffffc0202026:	0009a783          	lw	a5,0(s3)
ffffffffc020202a:	2a079d63          	bnez	a5,ffffffffc02022e4 <default_check+0x34c>
ffffffffc020202e:	411c                	lw	a5,0(a0)
ffffffffc0202030:	2a079a63          	bnez	a5,ffffffffc02022e4 <default_check+0x34c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202034:	00007797          	auipc	a5,0x7
ffffffffc0202038:	4fc7b783          	ld	a5,1276(a5) # ffffffffc0209530 <pages>
ffffffffc020203c:	40fa0733          	sub	a4,s4,a5
ffffffffc0202040:	870d                	srai	a4,a4,0x3
ffffffffc0202042:	00003597          	auipc	a1,0x3
ffffffffc0202046:	6a65b583          	ld	a1,1702(a1) # ffffffffc02056e8 <error_string+0x38>
ffffffffc020204a:	02b70733          	mul	a4,a4,a1
ffffffffc020204e:	00003617          	auipc	a2,0x3
ffffffffc0202052:	6a263603          	ld	a2,1698(a2) # ffffffffc02056f0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202056:	00007697          	auipc	a3,0x7
ffffffffc020205a:	4d26b683          	ld	a3,1234(a3) # ffffffffc0209528 <npage>
ffffffffc020205e:	06b2                	slli	a3,a3,0xc
ffffffffc0202060:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202062:	0732                	slli	a4,a4,0xc
ffffffffc0202064:	2ad77063          	bgeu	a4,a3,ffffffffc0202304 <default_check+0x36c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202068:	40f98733          	sub	a4,s3,a5
ffffffffc020206c:	870d                	srai	a4,a4,0x3
ffffffffc020206e:	02b70733          	mul	a4,a4,a1
ffffffffc0202072:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202074:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202076:	4cd77763          	bgeu	a4,a3,ffffffffc0202544 <default_check+0x5ac>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020207a:	40f507b3          	sub	a5,a0,a5
ffffffffc020207e:	878d                	srai	a5,a5,0x3
ffffffffc0202080:	02b787b3          	mul	a5,a5,a1
ffffffffc0202084:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202086:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202088:	30d7fe63          	bgeu	a5,a3,ffffffffc02023a4 <default_check+0x40c>
    assert(alloc_page() == NULL);
ffffffffc020208c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020208e:	00043c03          	ld	s8,0(s0)
ffffffffc0202092:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202096:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020209a:	e400                	sd	s0,8(s0)
ffffffffc020209c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020209e:	00007797          	auipc	a5,0x7
ffffffffc02020a2:	f807a123          	sw	zero,-126(a5) # ffffffffc0209020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02020a6:	1c5000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02020aa:	2c051d63          	bnez	a0,ffffffffc0202384 <default_check+0x3ec>
    free_page(p0);
ffffffffc02020ae:	4585                	li	a1,1
ffffffffc02020b0:	8552                	mv	a0,s4
ffffffffc02020b2:	1f7000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p1);
ffffffffc02020b6:	4585                	li	a1,1
ffffffffc02020b8:	854e                	mv	a0,s3
ffffffffc02020ba:	1ef000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc02020be:	4585                	li	a1,1
ffffffffc02020c0:	8556                	mv	a0,s5
ffffffffc02020c2:	1e7000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(nr_free == 3);
ffffffffc02020c6:	4818                	lw	a4,16(s0)
ffffffffc02020c8:	478d                	li	a5,3
ffffffffc02020ca:	28f71d63          	bne	a4,a5,ffffffffc0202364 <default_check+0x3cc>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02020ce:	4505                	li	a0,1
ffffffffc02020d0:	19b000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02020d4:	89aa                	mv	s3,a0
ffffffffc02020d6:	26050763          	beqz	a0,ffffffffc0202344 <default_check+0x3ac>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02020da:	4505                	li	a0,1
ffffffffc02020dc:	18f000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02020e0:	8aaa                	mv	s5,a0
ffffffffc02020e2:	3c050163          	beqz	a0,ffffffffc02024a4 <default_check+0x50c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02020e6:	4505                	li	a0,1
ffffffffc02020e8:	183000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02020ec:	8a2a                	mv	s4,a0
ffffffffc02020ee:	38050b63          	beqz	a0,ffffffffc0202484 <default_check+0x4ec>
    assert(alloc_page() == NULL);
ffffffffc02020f2:	4505                	li	a0,1
ffffffffc02020f4:	177000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02020f8:	36051663          	bnez	a0,ffffffffc0202464 <default_check+0x4cc>
    free_page(p0);
ffffffffc02020fc:	4585                	li	a1,1
ffffffffc02020fe:	854e                	mv	a0,s3
ffffffffc0202100:	1a9000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202104:	641c                	ld	a5,8(s0)
ffffffffc0202106:	20878f63          	beq	a5,s0,ffffffffc0202324 <default_check+0x38c>
    assert((p = alloc_page()) == p0);
ffffffffc020210a:	4505                	li	a0,1
ffffffffc020210c:	15f000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0202110:	30a99a63          	bne	s3,a0,ffffffffc0202424 <default_check+0x48c>
    assert(alloc_page() == NULL);
ffffffffc0202114:	4505                	li	a0,1
ffffffffc0202116:	155000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc020211a:	2e051563          	bnez	a0,ffffffffc0202404 <default_check+0x46c>
    assert(nr_free == 0);
ffffffffc020211e:	481c                	lw	a5,16(s0)
ffffffffc0202120:	2c079263          	bnez	a5,ffffffffc02023e4 <default_check+0x44c>
    free_page(p);
ffffffffc0202124:	854e                	mv	a0,s3
ffffffffc0202126:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202128:	01843023          	sd	s8,0(s0)
ffffffffc020212c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202130:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202134:	175000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p1);
ffffffffc0202138:	4585                	li	a1,1
ffffffffc020213a:	8556                	mv	a0,s5
ffffffffc020213c:	16d000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0202140:	4585                	li	a1,1
ffffffffc0202142:	8552                	mv	a0,s4
ffffffffc0202144:	165000ef          	jal	ra,ffffffffc0202aa8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202148:	4515                	li	a0,5
ffffffffc020214a:	121000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc020214e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202150:	26050a63          	beqz	a0,ffffffffc02023c4 <default_check+0x42c>
ffffffffc0202154:	651c                	ld	a5,8(a0)
ffffffffc0202156:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202158:	8b85                	andi	a5,a5,1
ffffffffc020215a:	54079563          	bnez	a5,ffffffffc02026a4 <default_check+0x70c>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020215e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202160:	00043b03          	ld	s6,0(s0)
ffffffffc0202164:	00843a83          	ld	s5,8(s0)
ffffffffc0202168:	e000                	sd	s0,0(s0)
ffffffffc020216a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020216c:	0ff000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0202170:	50051a63          	bnez	a0,ffffffffc0202684 <default_check+0x6ec>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202174:	05098a13          	addi	s4,s3,80
ffffffffc0202178:	8552                	mv	a0,s4
ffffffffc020217a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020217c:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202180:	00007797          	auipc	a5,0x7
ffffffffc0202184:	ea07a023          	sw	zero,-352(a5) # ffffffffc0209020 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202188:	121000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020218c:	4511                	li	a0,4
ffffffffc020218e:	0dd000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0202192:	4c051963          	bnez	a0,ffffffffc0202664 <default_check+0x6cc>
ffffffffc0202196:	0589b783          	ld	a5,88(s3)
ffffffffc020219a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020219c:	8b85                	andi	a5,a5,1
ffffffffc020219e:	4a078363          	beqz	a5,ffffffffc0202644 <default_check+0x6ac>
ffffffffc02021a2:	0609a703          	lw	a4,96(s3)
ffffffffc02021a6:	478d                	li	a5,3
ffffffffc02021a8:	48f71e63          	bne	a4,a5,ffffffffc0202644 <default_check+0x6ac>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02021ac:	450d                	li	a0,3
ffffffffc02021ae:	0bd000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02021b2:	8c2a                	mv	s8,a0
ffffffffc02021b4:	46050863          	beqz	a0,ffffffffc0202624 <default_check+0x68c>
    assert(alloc_page() == NULL);
ffffffffc02021b8:	4505                	li	a0,1
ffffffffc02021ba:	0b1000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc02021be:	44051363          	bnez	a0,ffffffffc0202604 <default_check+0x66c>
    assert(p0 + 2 == p1);
ffffffffc02021c2:	438a1163          	bne	s4,s8,ffffffffc02025e4 <default_check+0x64c>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02021c6:	4585                	li	a1,1
ffffffffc02021c8:	854e                	mv	a0,s3
ffffffffc02021ca:	0df000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_pages(p1, 3);
ffffffffc02021ce:	458d                	li	a1,3
ffffffffc02021d0:	8552                	mv	a0,s4
ffffffffc02021d2:	0d7000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
ffffffffc02021d6:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02021da:	02898c13          	addi	s8,s3,40
ffffffffc02021de:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02021e0:	8b85                	andi	a5,a5,1
ffffffffc02021e2:	3e078163          	beqz	a5,ffffffffc02025c4 <default_check+0x62c>
ffffffffc02021e6:	0109a703          	lw	a4,16(s3)
ffffffffc02021ea:	4785                	li	a5,1
ffffffffc02021ec:	3cf71c63          	bne	a4,a5,ffffffffc02025c4 <default_check+0x62c>
ffffffffc02021f0:	008a3783          	ld	a5,8(s4)
ffffffffc02021f4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02021f6:	8b85                	andi	a5,a5,1
ffffffffc02021f8:	3a078663          	beqz	a5,ffffffffc02025a4 <default_check+0x60c>
ffffffffc02021fc:	010a2703          	lw	a4,16(s4)
ffffffffc0202200:	478d                	li	a5,3
ffffffffc0202202:	3af71163          	bne	a4,a5,ffffffffc02025a4 <default_check+0x60c>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202206:	4505                	li	a0,1
ffffffffc0202208:	063000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc020220c:	36a99c63          	bne	s3,a0,ffffffffc0202584 <default_check+0x5ec>
    free_page(p0);
ffffffffc0202210:	4585                	li	a1,1
ffffffffc0202212:	097000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202216:	4509                	li	a0,2
ffffffffc0202218:	053000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc020221c:	34aa1463          	bne	s4,a0,ffffffffc0202564 <default_check+0x5cc>

    free_pages(p0, 2);
ffffffffc0202220:	4589                	li	a1,2
ffffffffc0202222:	087000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0202226:	4585                	li	a1,1
ffffffffc0202228:	8562                	mv	a0,s8
ffffffffc020222a:	07f000ef          	jal	ra,ffffffffc0202aa8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020222e:	4515                	li	a0,5
ffffffffc0202230:	03b000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0202234:	89aa                	mv	s3,a0
ffffffffc0202236:	48050763          	beqz	a0,ffffffffc02026c4 <default_check+0x72c>
    assert(alloc_page() == NULL);
ffffffffc020223a:	4505                	li	a0,1
ffffffffc020223c:	02f000ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
ffffffffc0202240:	2e051263          	bnez	a0,ffffffffc0202524 <default_check+0x58c>

    assert(nr_free == 0);
ffffffffc0202244:	481c                	lw	a5,16(s0)
ffffffffc0202246:	2a079f63          	bnez	a5,ffffffffc0202504 <default_check+0x56c>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020224a:	4595                	li	a1,5
ffffffffc020224c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020224e:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202252:	01643023          	sd	s6,0(s0)
ffffffffc0202256:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020225a:	04f000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    return listelm->next;
ffffffffc020225e:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0202260:	00878963          	beq	a5,s0,ffffffffc0202272 <default_check+0x2da>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0202264:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202268:	679c                	ld	a5,8(a5)
ffffffffc020226a:	397d                	addiw	s2,s2,-1
ffffffffc020226c:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020226e:	fe879be3          	bne	a5,s0,ffffffffc0202264 <default_check+0x2cc>
    }
    assert(count == 0);
ffffffffc0202272:	26091963          	bnez	s2,ffffffffc02024e4 <default_check+0x54c>
    assert(total == 0);
ffffffffc0202276:	46049763          	bnez	s1,ffffffffc02026e4 <default_check+0x74c>
    cprintf("[first fit] default_check() succeeded\n");
}
ffffffffc020227a:	6406                	ld	s0,64(sp)
ffffffffc020227c:	60a6                	ld	ra,72(sp)
ffffffffc020227e:	74e2                	ld	s1,56(sp)
ffffffffc0202280:	7942                	ld	s2,48(sp)
ffffffffc0202282:	79a2                	ld	s3,40(sp)
ffffffffc0202284:	7a02                	ld	s4,32(sp)
ffffffffc0202286:	6ae2                	ld	s5,24(sp)
ffffffffc0202288:	6b42                	ld	s6,16(sp)
ffffffffc020228a:	6ba2                	ld	s7,8(sp)
ffffffffc020228c:	6c02                	ld	s8,0(sp)
    cprintf("[first fit] default_check() succeeded\n");
ffffffffc020228e:	00003517          	auipc	a0,0x3
ffffffffc0202292:	c9a50513          	addi	a0,a0,-870 # ffffffffc0204f28 <buddy_pmm_manager+0x168>
}
ffffffffc0202296:	6161                	addi	sp,sp,80
    cprintf("[first fit] default_check() succeeded\n");
ffffffffc0202298:	e3ffd06f          	j	ffffffffc02000d6 <cprintf>
    while ((le = list_next(le)) != &free_list)
ffffffffc020229c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020229e:	4481                	li	s1,0
ffffffffc02022a0:	4901                	li	s2,0
ffffffffc02022a2:	b391                	j	ffffffffc0201fe6 <default_check+0x4e>
        assert(PageProperty(p));
ffffffffc02022a4:	00002697          	auipc	a3,0x2
ffffffffc02022a8:	29c68693          	addi	a3,a3,668 # ffffffffc0204540 <commands+0x530>
ffffffffc02022ac:	00002617          	auipc	a2,0x2
ffffffffc02022b0:	26460613          	addi	a2,a2,612 # ffffffffc0204510 <commands+0x500>
ffffffffc02022b4:	11200593          	li	a1,274
ffffffffc02022b8:	00003517          	auipc	a0,0x3
ffffffffc02022bc:	b6850513          	addi	a0,a0,-1176 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02022c0:	910fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02022c4:	00002697          	auipc	a3,0x2
ffffffffc02022c8:	33468693          	addi	a3,a3,820 # ffffffffc02045f8 <commands+0x5e8>
ffffffffc02022cc:	00002617          	auipc	a2,0x2
ffffffffc02022d0:	24460613          	addi	a2,a2,580 # ffffffffc0204510 <commands+0x500>
ffffffffc02022d4:	0dc00593          	li	a1,220
ffffffffc02022d8:	00003517          	auipc	a0,0x3
ffffffffc02022dc:	b4850513          	addi	a0,a0,-1208 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02022e0:	8f0fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02022e4:	00002697          	auipc	a3,0x2
ffffffffc02022e8:	33c68693          	addi	a3,a3,828 # ffffffffc0204620 <commands+0x610>
ffffffffc02022ec:	00002617          	auipc	a2,0x2
ffffffffc02022f0:	22460613          	addi	a2,a2,548 # ffffffffc0204510 <commands+0x500>
ffffffffc02022f4:	0dd00593          	li	a1,221
ffffffffc02022f8:	00003517          	auipc	a0,0x3
ffffffffc02022fc:	b2850513          	addi	a0,a0,-1240 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202300:	8d0fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202304:	00002697          	auipc	a3,0x2
ffffffffc0202308:	35c68693          	addi	a3,a3,860 # ffffffffc0204660 <commands+0x650>
ffffffffc020230c:	00002617          	auipc	a2,0x2
ffffffffc0202310:	20460613          	addi	a2,a2,516 # ffffffffc0204510 <commands+0x500>
ffffffffc0202314:	0df00593          	li	a1,223
ffffffffc0202318:	00003517          	auipc	a0,0x3
ffffffffc020231c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202320:	8b0fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202324:	00002697          	auipc	a3,0x2
ffffffffc0202328:	3c468693          	addi	a3,a3,964 # ffffffffc02046e8 <commands+0x6d8>
ffffffffc020232c:	00002617          	auipc	a2,0x2
ffffffffc0202330:	1e460613          	addi	a2,a2,484 # ffffffffc0204510 <commands+0x500>
ffffffffc0202334:	0f800593          	li	a1,248
ffffffffc0202338:	00003517          	auipc	a0,0x3
ffffffffc020233c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202340:	890fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202344:	00002697          	auipc	a3,0x2
ffffffffc0202348:	25468693          	addi	a3,a3,596 # ffffffffc0204598 <commands+0x588>
ffffffffc020234c:	00002617          	auipc	a2,0x2
ffffffffc0202350:	1c460613          	addi	a2,a2,452 # ffffffffc0204510 <commands+0x500>
ffffffffc0202354:	0f100593          	li	a1,241
ffffffffc0202358:	00003517          	auipc	a0,0x3
ffffffffc020235c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202360:	870fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 3);
ffffffffc0202364:	00002697          	auipc	a3,0x2
ffffffffc0202368:	37468693          	addi	a3,a3,884 # ffffffffc02046d8 <commands+0x6c8>
ffffffffc020236c:	00002617          	auipc	a2,0x2
ffffffffc0202370:	1a460613          	addi	a2,a2,420 # ffffffffc0204510 <commands+0x500>
ffffffffc0202374:	0ef00593          	li	a1,239
ffffffffc0202378:	00003517          	auipc	a0,0x3
ffffffffc020237c:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202380:	850fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202384:	00002697          	auipc	a3,0x2
ffffffffc0202388:	33c68693          	addi	a3,a3,828 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc020238c:	00002617          	auipc	a2,0x2
ffffffffc0202390:	18460613          	addi	a2,a2,388 # ffffffffc0204510 <commands+0x500>
ffffffffc0202394:	0ea00593          	li	a1,234
ffffffffc0202398:	00003517          	auipc	a0,0x3
ffffffffc020239c:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02023a0:	830fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02023a4:	00002697          	auipc	a3,0x2
ffffffffc02023a8:	2fc68693          	addi	a3,a3,764 # ffffffffc02046a0 <commands+0x690>
ffffffffc02023ac:	00002617          	auipc	a2,0x2
ffffffffc02023b0:	16460613          	addi	a2,a2,356 # ffffffffc0204510 <commands+0x500>
ffffffffc02023b4:	0e100593          	li	a1,225
ffffffffc02023b8:	00003517          	auipc	a0,0x3
ffffffffc02023bc:	a6850513          	addi	a0,a0,-1432 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02023c0:	810fe0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(p0 != NULL);
ffffffffc02023c4:	00002697          	auipc	a3,0x2
ffffffffc02023c8:	39468693          	addi	a3,a3,916 # ffffffffc0204758 <commands+0x748>
ffffffffc02023cc:	00002617          	auipc	a2,0x2
ffffffffc02023d0:	14460613          	addi	a2,a2,324 # ffffffffc0204510 <commands+0x500>
ffffffffc02023d4:	11a00593          	li	a1,282
ffffffffc02023d8:	00003517          	auipc	a0,0x3
ffffffffc02023dc:	a4850513          	addi	a0,a0,-1464 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02023e0:	ff1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 0);
ffffffffc02023e4:	00002697          	auipc	a3,0x2
ffffffffc02023e8:	33c68693          	addi	a3,a3,828 # ffffffffc0204720 <commands+0x710>
ffffffffc02023ec:	00002617          	auipc	a2,0x2
ffffffffc02023f0:	12460613          	addi	a2,a2,292 # ffffffffc0204510 <commands+0x500>
ffffffffc02023f4:	0fe00593          	li	a1,254
ffffffffc02023f8:	00003517          	auipc	a0,0x3
ffffffffc02023fc:	a2850513          	addi	a0,a0,-1496 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202400:	fd1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202404:	00002697          	auipc	a3,0x2
ffffffffc0202408:	2bc68693          	addi	a3,a3,700 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc020240c:	00002617          	auipc	a2,0x2
ffffffffc0202410:	10460613          	addi	a2,a2,260 # ffffffffc0204510 <commands+0x500>
ffffffffc0202414:	0fc00593          	li	a1,252
ffffffffc0202418:	00003517          	auipc	a0,0x3
ffffffffc020241c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202420:	fb1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202424:	00002697          	auipc	a3,0x2
ffffffffc0202428:	2dc68693          	addi	a3,a3,732 # ffffffffc0204700 <commands+0x6f0>
ffffffffc020242c:	00002617          	auipc	a2,0x2
ffffffffc0202430:	0e460613          	addi	a2,a2,228 # ffffffffc0204510 <commands+0x500>
ffffffffc0202434:	0fb00593          	li	a1,251
ffffffffc0202438:	00003517          	auipc	a0,0x3
ffffffffc020243c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202440:	f91fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202444:	00002697          	auipc	a3,0x2
ffffffffc0202448:	15468693          	addi	a3,a3,340 # ffffffffc0204598 <commands+0x588>
ffffffffc020244c:	00002617          	auipc	a2,0x2
ffffffffc0202450:	0c460613          	addi	a2,a2,196 # ffffffffc0204510 <commands+0x500>
ffffffffc0202454:	0d800593          	li	a1,216
ffffffffc0202458:	00003517          	auipc	a0,0x3
ffffffffc020245c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202460:	f71fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202464:	00002697          	auipc	a3,0x2
ffffffffc0202468:	25c68693          	addi	a3,a3,604 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc020246c:	00002617          	auipc	a2,0x2
ffffffffc0202470:	0a460613          	addi	a2,a2,164 # ffffffffc0204510 <commands+0x500>
ffffffffc0202474:	0f500593          	li	a1,245
ffffffffc0202478:	00003517          	auipc	a0,0x3
ffffffffc020247c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202480:	f51fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202484:	00002697          	auipc	a3,0x2
ffffffffc0202488:	15468693          	addi	a3,a3,340 # ffffffffc02045d8 <commands+0x5c8>
ffffffffc020248c:	00002617          	auipc	a2,0x2
ffffffffc0202490:	08460613          	addi	a2,a2,132 # ffffffffc0204510 <commands+0x500>
ffffffffc0202494:	0f300593          	li	a1,243
ffffffffc0202498:	00003517          	auipc	a0,0x3
ffffffffc020249c:	98850513          	addi	a0,a0,-1656 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02024a0:	f31fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02024a4:	00002697          	auipc	a3,0x2
ffffffffc02024a8:	11468693          	addi	a3,a3,276 # ffffffffc02045b8 <commands+0x5a8>
ffffffffc02024ac:	00002617          	auipc	a2,0x2
ffffffffc02024b0:	06460613          	addi	a2,a2,100 # ffffffffc0204510 <commands+0x500>
ffffffffc02024b4:	0f200593          	li	a1,242
ffffffffc02024b8:	00003517          	auipc	a0,0x3
ffffffffc02024bc:	96850513          	addi	a0,a0,-1688 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02024c0:	f11fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02024c4:	00002697          	auipc	a3,0x2
ffffffffc02024c8:	11468693          	addi	a3,a3,276 # ffffffffc02045d8 <commands+0x5c8>
ffffffffc02024cc:	00002617          	auipc	a2,0x2
ffffffffc02024d0:	04460613          	addi	a2,a2,68 # ffffffffc0204510 <commands+0x500>
ffffffffc02024d4:	0da00593          	li	a1,218
ffffffffc02024d8:	00003517          	auipc	a0,0x3
ffffffffc02024dc:	94850513          	addi	a0,a0,-1720 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02024e0:	ef1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(count == 0);
ffffffffc02024e4:	00002697          	auipc	a3,0x2
ffffffffc02024e8:	34c68693          	addi	a3,a3,844 # ffffffffc0204830 <commands+0x820>
ffffffffc02024ec:	00002617          	auipc	a2,0x2
ffffffffc02024f0:	02460613          	addi	a2,a2,36 # ffffffffc0204510 <commands+0x500>
ffffffffc02024f4:	14800593          	li	a1,328
ffffffffc02024f8:	00003517          	auipc	a0,0x3
ffffffffc02024fc:	92850513          	addi	a0,a0,-1752 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202500:	ed1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free == 0);
ffffffffc0202504:	00002697          	auipc	a3,0x2
ffffffffc0202508:	21c68693          	addi	a3,a3,540 # ffffffffc0204720 <commands+0x710>
ffffffffc020250c:	00002617          	auipc	a2,0x2
ffffffffc0202510:	00460613          	addi	a2,a2,4 # ffffffffc0204510 <commands+0x500>
ffffffffc0202514:	13c00593          	li	a1,316
ffffffffc0202518:	00003517          	auipc	a0,0x3
ffffffffc020251c:	90850513          	addi	a0,a0,-1784 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202520:	eb1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202524:	00002697          	auipc	a3,0x2
ffffffffc0202528:	19c68693          	addi	a3,a3,412 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc020252c:	00002617          	auipc	a2,0x2
ffffffffc0202530:	fe460613          	addi	a2,a2,-28 # ffffffffc0204510 <commands+0x500>
ffffffffc0202534:	13a00593          	li	a1,314
ffffffffc0202538:	00003517          	auipc	a0,0x3
ffffffffc020253c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202540:	e91fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202544:	00002697          	auipc	a3,0x2
ffffffffc0202548:	13c68693          	addi	a3,a3,316 # ffffffffc0204680 <commands+0x670>
ffffffffc020254c:	00002617          	auipc	a2,0x2
ffffffffc0202550:	fc460613          	addi	a2,a2,-60 # ffffffffc0204510 <commands+0x500>
ffffffffc0202554:	0e000593          	li	a1,224
ffffffffc0202558:	00003517          	auipc	a0,0x3
ffffffffc020255c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202560:	e71fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202564:	00003697          	auipc	a3,0x3
ffffffffc0202568:	9a468693          	addi	a3,a3,-1628 # ffffffffc0204f08 <buddy_pmm_manager+0x148>
ffffffffc020256c:	00002617          	auipc	a2,0x2
ffffffffc0202570:	fa460613          	addi	a2,a2,-92 # ffffffffc0204510 <commands+0x500>
ffffffffc0202574:	13400593          	li	a1,308
ffffffffc0202578:	00003517          	auipc	a0,0x3
ffffffffc020257c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202580:	e51fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202584:	00003697          	auipc	a3,0x3
ffffffffc0202588:	96468693          	addi	a3,a3,-1692 # ffffffffc0204ee8 <buddy_pmm_manager+0x128>
ffffffffc020258c:	00002617          	auipc	a2,0x2
ffffffffc0202590:	f8460613          	addi	a2,a2,-124 # ffffffffc0204510 <commands+0x500>
ffffffffc0202594:	13200593          	li	a1,306
ffffffffc0202598:	00003517          	auipc	a0,0x3
ffffffffc020259c:	88850513          	addi	a0,a0,-1912 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02025a0:	e31fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02025a4:	00003697          	auipc	a3,0x3
ffffffffc02025a8:	91c68693          	addi	a3,a3,-1764 # ffffffffc0204ec0 <buddy_pmm_manager+0x100>
ffffffffc02025ac:	00002617          	auipc	a2,0x2
ffffffffc02025b0:	f6460613          	addi	a2,a2,-156 # ffffffffc0204510 <commands+0x500>
ffffffffc02025b4:	13000593          	li	a1,304
ffffffffc02025b8:	00003517          	auipc	a0,0x3
ffffffffc02025bc:	86850513          	addi	a0,a0,-1944 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02025c0:	e11fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02025c4:	00003697          	auipc	a3,0x3
ffffffffc02025c8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0204e98 <buddy_pmm_manager+0xd8>
ffffffffc02025cc:	00002617          	auipc	a2,0x2
ffffffffc02025d0:	f4460613          	addi	a2,a2,-188 # ffffffffc0204510 <commands+0x500>
ffffffffc02025d4:	12f00593          	li	a1,303
ffffffffc02025d8:	00003517          	auipc	a0,0x3
ffffffffc02025dc:	84850513          	addi	a0,a0,-1976 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02025e0:	df1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02025e4:	00003697          	auipc	a3,0x3
ffffffffc02025e8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0204e88 <buddy_pmm_manager+0xc8>
ffffffffc02025ec:	00002617          	auipc	a2,0x2
ffffffffc02025f0:	f2460613          	addi	a2,a2,-220 # ffffffffc0204510 <commands+0x500>
ffffffffc02025f4:	12a00593          	li	a1,298
ffffffffc02025f8:	00003517          	auipc	a0,0x3
ffffffffc02025fc:	82850513          	addi	a0,a0,-2008 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202600:	dd1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202604:	00002697          	auipc	a3,0x2
ffffffffc0202608:	0bc68693          	addi	a3,a3,188 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc020260c:	00002617          	auipc	a2,0x2
ffffffffc0202610:	f0460613          	addi	a2,a2,-252 # ffffffffc0204510 <commands+0x500>
ffffffffc0202614:	12900593          	li	a1,297
ffffffffc0202618:	00003517          	auipc	a0,0x3
ffffffffc020261c:	80850513          	addi	a0,a0,-2040 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202620:	db1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202624:	00003697          	auipc	a3,0x3
ffffffffc0202628:	84468693          	addi	a3,a3,-1980 # ffffffffc0204e68 <buddy_pmm_manager+0xa8>
ffffffffc020262c:	00002617          	auipc	a2,0x2
ffffffffc0202630:	ee460613          	addi	a2,a2,-284 # ffffffffc0204510 <commands+0x500>
ffffffffc0202634:	12800593          	li	a1,296
ffffffffc0202638:	00002517          	auipc	a0,0x2
ffffffffc020263c:	7e850513          	addi	a0,a0,2024 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202640:	d91fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202644:	00002697          	auipc	a3,0x2
ffffffffc0202648:	7f468693          	addi	a3,a3,2036 # ffffffffc0204e38 <buddy_pmm_manager+0x78>
ffffffffc020264c:	00002617          	auipc	a2,0x2
ffffffffc0202650:	ec460613          	addi	a2,a2,-316 # ffffffffc0204510 <commands+0x500>
ffffffffc0202654:	12700593          	li	a1,295
ffffffffc0202658:	00002517          	auipc	a0,0x2
ffffffffc020265c:	7c850513          	addi	a0,a0,1992 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202660:	d71fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202664:	00002697          	auipc	a3,0x2
ffffffffc0202668:	11c68693          	addi	a3,a3,284 # ffffffffc0204780 <commands+0x770>
ffffffffc020266c:	00002617          	auipc	a2,0x2
ffffffffc0202670:	ea460613          	addi	a2,a2,-348 # ffffffffc0204510 <commands+0x500>
ffffffffc0202674:	12600593          	li	a1,294
ffffffffc0202678:	00002517          	auipc	a0,0x2
ffffffffc020267c:	7a850513          	addi	a0,a0,1960 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202680:	d51fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202684:	00002697          	auipc	a3,0x2
ffffffffc0202688:	03c68693          	addi	a3,a3,60 # ffffffffc02046c0 <commands+0x6b0>
ffffffffc020268c:	00002617          	auipc	a2,0x2
ffffffffc0202690:	e8460613          	addi	a2,a2,-380 # ffffffffc0204510 <commands+0x500>
ffffffffc0202694:	12000593          	li	a1,288
ffffffffc0202698:	00002517          	auipc	a0,0x2
ffffffffc020269c:	78850513          	addi	a0,a0,1928 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02026a0:	d31fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(!PageProperty(p0));
ffffffffc02026a4:	00002697          	auipc	a3,0x2
ffffffffc02026a8:	0c468693          	addi	a3,a3,196 # ffffffffc0204768 <commands+0x758>
ffffffffc02026ac:	00002617          	auipc	a2,0x2
ffffffffc02026b0:	e6460613          	addi	a2,a2,-412 # ffffffffc0204510 <commands+0x500>
ffffffffc02026b4:	11b00593          	li	a1,283
ffffffffc02026b8:	00002517          	auipc	a0,0x2
ffffffffc02026bc:	76850513          	addi	a0,a0,1896 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02026c0:	d11fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02026c4:	00002697          	auipc	a3,0x2
ffffffffc02026c8:	14c68693          	addi	a3,a3,332 # ffffffffc0204810 <commands+0x800>
ffffffffc02026cc:	00002617          	auipc	a2,0x2
ffffffffc02026d0:	e4460613          	addi	a2,a2,-444 # ffffffffc0204510 <commands+0x500>
ffffffffc02026d4:	13900593          	li	a1,313
ffffffffc02026d8:	00002517          	auipc	a0,0x2
ffffffffc02026dc:	74850513          	addi	a0,a0,1864 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02026e0:	cf1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(total == 0);
ffffffffc02026e4:	00002697          	auipc	a3,0x2
ffffffffc02026e8:	15c68693          	addi	a3,a3,348 # ffffffffc0204840 <commands+0x830>
ffffffffc02026ec:	00002617          	auipc	a2,0x2
ffffffffc02026f0:	e2460613          	addi	a2,a2,-476 # ffffffffc0204510 <commands+0x500>
ffffffffc02026f4:	14900593          	li	a1,329
ffffffffc02026f8:	00002517          	auipc	a0,0x2
ffffffffc02026fc:	72850513          	addi	a0,a0,1832 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202700:	cd1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202704:	00002697          	auipc	a3,0x2
ffffffffc0202708:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204550 <commands+0x540>
ffffffffc020270c:	00002617          	auipc	a2,0x2
ffffffffc0202710:	e0460613          	addi	a2,a2,-508 # ffffffffc0204510 <commands+0x500>
ffffffffc0202714:	11500593          	li	a1,277
ffffffffc0202718:	00002517          	auipc	a0,0x2
ffffffffc020271c:	70850513          	addi	a0,a0,1800 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202720:	cb1fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202724:	00002697          	auipc	a3,0x2
ffffffffc0202728:	e9468693          	addi	a3,a3,-364 # ffffffffc02045b8 <commands+0x5a8>
ffffffffc020272c:	00002617          	auipc	a2,0x2
ffffffffc0202730:	de460613          	addi	a2,a2,-540 # ffffffffc0204510 <commands+0x500>
ffffffffc0202734:	0d900593          	li	a1,217
ffffffffc0202738:	00002517          	auipc	a0,0x2
ffffffffc020273c:	6e850513          	addi	a0,a0,1768 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202740:	c91fd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0202744 <default_free_pages>:
{
ffffffffc0202744:	1141                	addi	sp,sp,-16
ffffffffc0202746:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202748:	14058a63          	beqz	a1,ffffffffc020289c <default_free_pages+0x158>
    for (; p != base + n; p++)
ffffffffc020274c:	00259693          	slli	a3,a1,0x2
ffffffffc0202750:	96ae                	add	a3,a3,a1
ffffffffc0202752:	068e                	slli	a3,a3,0x3
ffffffffc0202754:	96aa                	add	a3,a3,a0
ffffffffc0202756:	87aa                	mv	a5,a0
ffffffffc0202758:	02d50263          	beq	a0,a3,ffffffffc020277c <default_free_pages+0x38>
ffffffffc020275c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020275e:	8b05                	andi	a4,a4,1
ffffffffc0202760:	10071e63          	bnez	a4,ffffffffc020287c <default_free_pages+0x138>
ffffffffc0202764:	6798                	ld	a4,8(a5)
ffffffffc0202766:	8b09                	andi	a4,a4,2
ffffffffc0202768:	10071a63          	bnez	a4,ffffffffc020287c <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020276c:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202770:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0202774:	02878793          	addi	a5,a5,40
ffffffffc0202778:	fed792e3          	bne	a5,a3,ffffffffc020275c <default_free_pages+0x18>
    base->property = n;
ffffffffc020277c:	2581                	sext.w	a1,a1
ffffffffc020277e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202780:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202784:	4789                	li	a5,2
ffffffffc0202786:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020278a:	00007697          	auipc	a3,0x7
ffffffffc020278e:	88668693          	addi	a3,a3,-1914 # ffffffffc0209010 <free_area>
ffffffffc0202792:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202794:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202796:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020279a:	9db9                	addw	a1,a1,a4
ffffffffc020279c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc020279e:	0ad78863          	beq	a5,a3,ffffffffc020284e <default_free_pages+0x10a>
            struct Page *page = le2page(le, page_link);
ffffffffc02027a2:	fe878713          	addi	a4,a5,-24
ffffffffc02027a6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02027aa:	4581                	li	a1,0
            if (base < page)
ffffffffc02027ac:	00e56a63          	bltu	a0,a4,ffffffffc02027c0 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02027b0:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02027b2:	06d70263          	beq	a4,a3,ffffffffc0202816 <default_free_pages+0xd2>
    for (; p != base + n; p++)
ffffffffc02027b6:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02027b8:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02027bc:	fee57ae3          	bgeu	a0,a4,ffffffffc02027b0 <default_free_pages+0x6c>
ffffffffc02027c0:	c199                	beqz	a1,ffffffffc02027c6 <default_free_pages+0x82>
ffffffffc02027c2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02027c6:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02027c8:	e390                	sd	a2,0(a5)
ffffffffc02027ca:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02027cc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02027ce:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc02027d0:	02d70063          	beq	a4,a3,ffffffffc02027f0 <default_free_pages+0xac>
        if (p + p->property == base)
ffffffffc02027d4:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02027d8:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc02027dc:	02081613          	slli	a2,a6,0x20
ffffffffc02027e0:	9201                	srli	a2,a2,0x20
ffffffffc02027e2:	00261793          	slli	a5,a2,0x2
ffffffffc02027e6:	97b2                	add	a5,a5,a2
ffffffffc02027e8:	078e                	slli	a5,a5,0x3
ffffffffc02027ea:	97ae                	add	a5,a5,a1
ffffffffc02027ec:	02f50f63          	beq	a0,a5,ffffffffc020282a <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02027f0:	7118                	ld	a4,32(a0)
    if (le != &free_list)
ffffffffc02027f2:	00d70f63          	beq	a4,a3,ffffffffc0202810 <default_free_pages+0xcc>
        if (base + base->property == p)
ffffffffc02027f6:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02027f8:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p)
ffffffffc02027fc:	02059613          	slli	a2,a1,0x20
ffffffffc0202800:	9201                	srli	a2,a2,0x20
ffffffffc0202802:	00261793          	slli	a5,a2,0x2
ffffffffc0202806:	97b2                	add	a5,a5,a2
ffffffffc0202808:	078e                	slli	a5,a5,0x3
ffffffffc020280a:	97aa                	add	a5,a5,a0
ffffffffc020280c:	04f68863          	beq	a3,a5,ffffffffc020285c <default_free_pages+0x118>
}
ffffffffc0202810:	60a2                	ld	ra,8(sp)
ffffffffc0202812:	0141                	addi	sp,sp,16
ffffffffc0202814:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202816:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202818:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020281a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020281c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc020281e:	02d70563          	beq	a4,a3,ffffffffc0202848 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0202822:	8832                	mv	a6,a2
ffffffffc0202824:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0202826:	87ba                	mv	a5,a4
ffffffffc0202828:	bf41                	j	ffffffffc02027b8 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020282a:	491c                	lw	a5,16(a0)
ffffffffc020282c:	0107883b          	addw	a6,a5,a6
ffffffffc0202830:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202834:	57f5                	li	a5,-3
ffffffffc0202836:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020283a:	6d10                	ld	a2,24(a0)
ffffffffc020283c:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020283e:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0202840:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202842:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202844:	e390                	sd	a2,0(a5)
ffffffffc0202846:	b775                	j	ffffffffc02027f2 <default_free_pages+0xae>
ffffffffc0202848:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc020284a:	873e                	mv	a4,a5
ffffffffc020284c:	b761                	j	ffffffffc02027d4 <default_free_pages+0x90>
}
ffffffffc020284e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202850:	e390                	sd	a2,0(a5)
ffffffffc0202852:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202854:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202856:	ed1c                	sd	a5,24(a0)
ffffffffc0202858:	0141                	addi	sp,sp,16
ffffffffc020285a:	8082                	ret
            base->property += p->property;
ffffffffc020285c:	ff872783          	lw	a5,-8(a4)
ffffffffc0202860:	ff070693          	addi	a3,a4,-16
ffffffffc0202864:	9dbd                	addw	a1,a1,a5
ffffffffc0202866:	c90c                	sw	a1,16(a0)
ffffffffc0202868:	57f5                	li	a5,-3
ffffffffc020286a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020286e:	6314                	ld	a3,0(a4)
ffffffffc0202870:	671c                	ld	a5,8(a4)
}
ffffffffc0202872:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202874:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0202876:	e394                	sd	a3,0(a5)
ffffffffc0202878:	0141                	addi	sp,sp,16
ffffffffc020287a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020287c:	00002697          	auipc	a3,0x2
ffffffffc0202880:	fd468693          	addi	a3,a3,-44 # ffffffffc0204850 <commands+0x840>
ffffffffc0202884:	00002617          	auipc	a2,0x2
ffffffffc0202888:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204510 <commands+0x500>
ffffffffc020288c:	09500593          	li	a1,149
ffffffffc0202890:	00002517          	auipc	a0,0x2
ffffffffc0202894:	59050513          	addi	a0,a0,1424 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202898:	b39fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(n > 0);
ffffffffc020289c:	00002697          	auipc	a3,0x2
ffffffffc02028a0:	c6c68693          	addi	a3,a3,-916 # ffffffffc0204508 <commands+0x4f8>
ffffffffc02028a4:	00002617          	auipc	a2,0x2
ffffffffc02028a8:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204510 <commands+0x500>
ffffffffc02028ac:	09100593          	li	a1,145
ffffffffc02028b0:	00002517          	auipc	a0,0x2
ffffffffc02028b4:	57050513          	addi	a0,a0,1392 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc02028b8:	b19fd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc02028bc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02028bc:	c959                	beqz	a0,ffffffffc0202952 <default_alloc_pages+0x96>
    if (n > nr_free)
ffffffffc02028be:	00006597          	auipc	a1,0x6
ffffffffc02028c2:	75258593          	addi	a1,a1,1874 # ffffffffc0209010 <free_area>
ffffffffc02028c6:	0105a803          	lw	a6,16(a1)
ffffffffc02028ca:	862a                	mv	a2,a0
ffffffffc02028cc:	02081793          	slli	a5,a6,0x20
ffffffffc02028d0:	9381                	srli	a5,a5,0x20
ffffffffc02028d2:	00a7ee63          	bltu	a5,a0,ffffffffc02028ee <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02028d6:	87ae                	mv	a5,a1
ffffffffc02028d8:	a801                	j	ffffffffc02028e8 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc02028da:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028de:	02071693          	slli	a3,a4,0x20
ffffffffc02028e2:	9281                	srli	a3,a3,0x20
ffffffffc02028e4:	00c6f763          	bgeu	a3,a2,ffffffffc02028f2 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02028e8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc02028ea:	feb798e3          	bne	a5,a1,ffffffffc02028da <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02028ee:	4501                	li	a0,0
}
ffffffffc02028f0:	8082                	ret
    return listelm->prev;
ffffffffc02028f2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02028f6:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02028fa:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02028fe:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0202902:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202906:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc020290a:	02d67b63          	bgeu	a2,a3,ffffffffc0202940 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020290e:	00261693          	slli	a3,a2,0x2
ffffffffc0202912:	96b2                	add	a3,a3,a2
ffffffffc0202914:	068e                	slli	a3,a3,0x3
ffffffffc0202916:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0202918:	41c7073b          	subw	a4,a4,t3
ffffffffc020291c:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020291e:	00868613          	addi	a2,a3,8
ffffffffc0202922:	4709                	li	a4,2
ffffffffc0202924:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202928:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020292c:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc0202930:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202934:	e310                	sd	a2,0(a4)
ffffffffc0202936:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020293a:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc020293c:	0116bc23          	sd	a7,24(a3)
ffffffffc0202940:	41c8083b          	subw	a6,a6,t3
ffffffffc0202944:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202948:	5775                	li	a4,-3
ffffffffc020294a:	17c1                	addi	a5,a5,-16
ffffffffc020294c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202950:	8082                	ret
{
ffffffffc0202952:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202954:	00002697          	auipc	a3,0x2
ffffffffc0202958:	bb468693          	addi	a3,a3,-1100 # ffffffffc0204508 <commands+0x4f8>
ffffffffc020295c:	00002617          	auipc	a2,0x2
ffffffffc0202960:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204510 <commands+0x500>
ffffffffc0202964:	06d00593          	li	a1,109
ffffffffc0202968:	00002517          	auipc	a0,0x2
ffffffffc020296c:	4b850513          	addi	a0,a0,1208 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
{
ffffffffc0202970:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202972:	a5ffd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0202976 <default_init_memmap>:
{
ffffffffc0202976:	1141                	addi	sp,sp,-16
ffffffffc0202978:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020297a:	c9e1                	beqz	a1,ffffffffc0202a4a <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc020297c:	00259693          	slli	a3,a1,0x2
ffffffffc0202980:	96ae                	add	a3,a3,a1
ffffffffc0202982:	068e                	slli	a3,a3,0x3
ffffffffc0202984:	96aa                	add	a3,a3,a0
ffffffffc0202986:	87aa                	mv	a5,a0
ffffffffc0202988:	00d50f63          	beq	a0,a3,ffffffffc02029a6 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020298c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020298e:	8b05                	andi	a4,a4,1
ffffffffc0202990:	cf49                	beqz	a4,ffffffffc0202a2a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202992:	0007a823          	sw	zero,16(a5)
ffffffffc0202996:	0007b423          	sd	zero,8(a5)
ffffffffc020299a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020299e:	02878793          	addi	a5,a5,40
ffffffffc02029a2:	fed795e3          	bne	a5,a3,ffffffffc020298c <default_init_memmap+0x16>
    base->property = n;
ffffffffc02029a6:	2581                	sext.w	a1,a1
ffffffffc02029a8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02029aa:	4789                	li	a5,2
ffffffffc02029ac:	00850713          	addi	a4,a0,8
ffffffffc02029b0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02029b4:	00006697          	auipc	a3,0x6
ffffffffc02029b8:	65c68693          	addi	a3,a3,1628 # ffffffffc0209010 <free_area>
ffffffffc02029bc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02029be:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02029c0:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02029c4:	9db9                	addw	a1,a1,a4
ffffffffc02029c6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02029c8:	04d78a63          	beq	a5,a3,ffffffffc0202a1c <default_init_memmap+0xa6>
            struct Page *page = le2page(le, page_link);
ffffffffc02029cc:	fe878713          	addi	a4,a5,-24
ffffffffc02029d0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02029d4:	4581                	li	a1,0
            if (base < page)
ffffffffc02029d6:	00e56a63          	bltu	a0,a4,ffffffffc02029ea <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02029da:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02029dc:	02d70263          	beq	a4,a3,ffffffffc0202a00 <default_init_memmap+0x8a>
    for (; p != base + n; p++)
ffffffffc02029e0:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02029e2:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02029e6:	fee57ae3          	bgeu	a0,a4,ffffffffc02029da <default_init_memmap+0x64>
ffffffffc02029ea:	c199                	beqz	a1,ffffffffc02029f0 <default_init_memmap+0x7a>
ffffffffc02029ec:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02029f0:	6398                	ld	a4,0(a5)
}
ffffffffc02029f2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02029f4:	e390                	sd	a2,0(a5)
ffffffffc02029f6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02029f8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02029fa:	ed18                	sd	a4,24(a0)
ffffffffc02029fc:	0141                	addi	sp,sp,16
ffffffffc02029fe:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202a00:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202a02:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202a04:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202a06:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0202a08:	00d70663          	beq	a4,a3,ffffffffc0202a14 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0202a0c:	8832                	mv	a6,a2
ffffffffc0202a0e:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0202a10:	87ba                	mv	a5,a4
ffffffffc0202a12:	bfc1                	j	ffffffffc02029e2 <default_init_memmap+0x6c>
}
ffffffffc0202a14:	60a2                	ld	ra,8(sp)
ffffffffc0202a16:	e290                	sd	a2,0(a3)
ffffffffc0202a18:	0141                	addi	sp,sp,16
ffffffffc0202a1a:	8082                	ret
ffffffffc0202a1c:	60a2                	ld	ra,8(sp)
ffffffffc0202a1e:	e390                	sd	a2,0(a5)
ffffffffc0202a20:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202a22:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202a24:	ed1c                	sd	a5,24(a0)
ffffffffc0202a26:	0141                	addi	sp,sp,16
ffffffffc0202a28:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202a2a:	00002697          	auipc	a3,0x2
ffffffffc0202a2e:	e4e68693          	addi	a3,a3,-434 # ffffffffc0204878 <commands+0x868>
ffffffffc0202a32:	00002617          	auipc	a2,0x2
ffffffffc0202a36:	ade60613          	addi	a2,a2,-1314 # ffffffffc0204510 <commands+0x500>
ffffffffc0202a3a:	04c00593          	li	a1,76
ffffffffc0202a3e:	00002517          	auipc	a0,0x2
ffffffffc0202a42:	3e250513          	addi	a0,a0,994 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202a46:	98bfd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(n > 0);
ffffffffc0202a4a:	00002697          	auipc	a3,0x2
ffffffffc0202a4e:	abe68693          	addi	a3,a3,-1346 # ffffffffc0204508 <commands+0x4f8>
ffffffffc0202a52:	00002617          	auipc	a2,0x2
ffffffffc0202a56:	abe60613          	addi	a2,a2,-1346 # ffffffffc0204510 <commands+0x500>
ffffffffc0202a5a:	04800593          	li	a1,72
ffffffffc0202a5e:	00002517          	auipc	a0,0x2
ffffffffc0202a62:	3c250513          	addi	a0,a0,962 # ffffffffc0204e20 <buddy_pmm_manager+0x60>
ffffffffc0202a66:	96bfd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0202a6a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a6a:	100027f3          	csrr	a5,sstatus
ffffffffc0202a6e:	8b89                	andi	a5,a5,2
ffffffffc0202a70:	e799                	bnez	a5,ffffffffc0202a7e <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a72:	00007797          	auipc	a5,0x7
ffffffffc0202a76:	ac67b783          	ld	a5,-1338(a5) # ffffffffc0209538 <pmm_manager>
ffffffffc0202a7a:	6f9c                	ld	a5,24(a5)
ffffffffc0202a7c:	8782                	jr	a5
{
ffffffffc0202a7e:	1141                	addi	sp,sp,-16
ffffffffc0202a80:	e406                	sd	ra,8(sp)
ffffffffc0202a82:	e022                	sd	s0,0(sp)
ffffffffc0202a84:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0202a86:	9fdfd0ef          	jal	ra,ffffffffc0200482 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a8a:	00007797          	auipc	a5,0x7
ffffffffc0202a8e:	aae7b783          	ld	a5,-1362(a5) # ffffffffc0209538 <pmm_manager>
ffffffffc0202a92:	6f9c                	ld	a5,24(a5)
ffffffffc0202a94:	8522                	mv	a0,s0
ffffffffc0202a96:	9782                	jalr	a5
ffffffffc0202a98:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0202a9a:	9e3fd0ef          	jal	ra,ffffffffc020047c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0202a9e:	60a2                	ld	ra,8(sp)
ffffffffc0202aa0:	8522                	mv	a0,s0
ffffffffc0202aa2:	6402                	ld	s0,0(sp)
ffffffffc0202aa4:	0141                	addi	sp,sp,16
ffffffffc0202aa6:	8082                	ret

ffffffffc0202aa8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aac:	8b89                	andi	a5,a5,2
ffffffffc0202aae:	e799                	bnez	a5,ffffffffc0202abc <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202ab0:	00007797          	auipc	a5,0x7
ffffffffc0202ab4:	a887b783          	ld	a5,-1400(a5) # ffffffffc0209538 <pmm_manager>
ffffffffc0202ab8:	739c                	ld	a5,32(a5)
ffffffffc0202aba:	8782                	jr	a5
{
ffffffffc0202abc:	1101                	addi	sp,sp,-32
ffffffffc0202abe:	ec06                	sd	ra,24(sp)
ffffffffc0202ac0:	e822                	sd	s0,16(sp)
ffffffffc0202ac2:	e426                	sd	s1,8(sp)
ffffffffc0202ac4:	842a                	mv	s0,a0
ffffffffc0202ac6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202ac8:	9bbfd0ef          	jal	ra,ffffffffc0200482 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202acc:	00007797          	auipc	a5,0x7
ffffffffc0202ad0:	a6c7b783          	ld	a5,-1428(a5) # ffffffffc0209538 <pmm_manager>
ffffffffc0202ad4:	739c                	ld	a5,32(a5)
ffffffffc0202ad6:	85a6                	mv	a1,s1
ffffffffc0202ad8:	8522                	mv	a0,s0
ffffffffc0202ada:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202adc:	6442                	ld	s0,16(sp)
ffffffffc0202ade:	60e2                	ld	ra,24(sp)
ffffffffc0202ae0:	64a2                	ld	s1,8(sp)
ffffffffc0202ae2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ae4:	999fd06f          	j	ffffffffc020047c <intr_enable>

ffffffffc0202ae8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ae8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aec:	8b89                	andi	a5,a5,2
ffffffffc0202aee:	e799                	bnez	a5,ffffffffc0202afc <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0202af0:	00007797          	auipc	a5,0x7
ffffffffc0202af4:	a487b783          	ld	a5,-1464(a5) # ffffffffc0209538 <pmm_manager>
ffffffffc0202af8:	779c                	ld	a5,40(a5)
ffffffffc0202afa:	8782                	jr	a5
{
ffffffffc0202afc:	1141                	addi	sp,sp,-16
ffffffffc0202afe:	e406                	sd	ra,8(sp)
ffffffffc0202b00:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202b02:	981fd0ef          	jal	ra,ffffffffc0200482 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b06:	00007797          	auipc	a5,0x7
ffffffffc0202b0a:	a327b783          	ld	a5,-1486(a5) # ffffffffc0209538 <pmm_manager>
ffffffffc0202b0e:	779c                	ld	a5,40(a5)
ffffffffc0202b10:	9782                	jalr	a5
ffffffffc0202b12:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b14:	969fd0ef          	jal	ra,ffffffffc020047c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202b18:	60a2                	ld	ra,8(sp)
ffffffffc0202b1a:	8522                	mv	a0,s0
ffffffffc0202b1c:	6402                	ld	s0,0(sp)
ffffffffc0202b1e:	0141                	addi	sp,sp,16
ffffffffc0202b20:	8082                	ret

ffffffffc0202b22 <pmm_init>:
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(const char *manager_name)
{
ffffffffc0202b22:	1101                	addi	sp,sp,-32
    if (strcmp(manager_name, "first_fit") == 0)
ffffffffc0202b24:	00001597          	auipc	a1,0x1
ffffffffc0202b28:	26458593          	addi	a1,a1,612 # ffffffffc0203d88 <etext+0x2>
{
ffffffffc0202b2c:	e822                	sd	s0,16(sp)
ffffffffc0202b2e:	ec06                	sd	ra,24(sp)
ffffffffc0202b30:	e426                	sd	s1,8(sp)
ffffffffc0202b32:	842a                	mv	s0,a0
    if (strcmp(manager_name, "first_fit") == 0)
ffffffffc0202b34:	1f4010ef          	jal	ra,ffffffffc0203d28 <strcmp>
ffffffffc0202b38:	10051e63          	bnez	a0,ffffffffc0202c54 <pmm_init+0x132>
        pmm_manager = &default_pmm_manager;
ffffffffc0202b3c:	00002797          	auipc	a5,0x2
ffffffffc0202b40:	42c78793          	addi	a5,a5,1068 # ffffffffc0204f68 <default_pmm_manager>
ffffffffc0202b44:	00007497          	auipc	s1,0x7
ffffffffc0202b48:	9f448493          	addi	s1,s1,-1548 # ffffffffc0209538 <pmm_manager>
ffffffffc0202b4c:	e09c                	sd	a5,0(s1)
    cprintf("[pmm] memory management: %s\n", pmm_manager->name);
ffffffffc0202b4e:	638c                	ld	a1,0(a5)
ffffffffc0202b50:	00002517          	auipc	a0,0x2
ffffffffc0202b54:	45050513          	addi	a0,a0,1104 # ffffffffc0204fa0 <default_pmm_manager+0x38>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202b58:	00007417          	auipc	s0,0x7
ffffffffc0202b5c:	9f840413          	addi	s0,s0,-1544 # ffffffffc0209550 <va_pa_offset>
    cprintf("[pmm] memory management: %s\n", pmm_manager->name);
ffffffffc0202b60:	d76fd0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    pmm_manager->init();
ffffffffc0202b64:	609c                	ld	a5,0(s1)
ffffffffc0202b66:	679c                	ld	a5,8(a5)
ffffffffc0202b68:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202b6a:	57f5                	li	a5,-3
ffffffffc0202b6c:	07fa                	slli	a5,a5,0x1e
    cprintf("[pmm] physcial memory map:\n");
ffffffffc0202b6e:	00002517          	auipc	a0,0x2
ffffffffc0202b72:	45250513          	addi	a0,a0,1106 # ffffffffc0204fc0 <default_pmm_manager+0x58>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202b76:	e01c                	sd	a5,0(s0)
    cprintf("[pmm] physcial memory map:\n");
ffffffffc0202b78:	d5efd0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    cprintf("[pmm]   memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0202b7c:	46c5                	li	a3,17
ffffffffc0202b7e:	06ee                	slli	a3,a3,0x1b
ffffffffc0202b80:	40100613          	li	a2,1025
ffffffffc0202b84:	16fd                	addi	a3,a3,-1
ffffffffc0202b86:	07e005b7          	lui	a1,0x7e00
ffffffffc0202b8a:	0656                	slli	a2,a2,0x15
ffffffffc0202b8c:	00002517          	auipc	a0,0x2
ffffffffc0202b90:	45450513          	addi	a0,a0,1108 # ffffffffc0204fe0 <default_pmm_manager+0x78>
ffffffffc0202b94:	d42fd0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202b98:	777d                	lui	a4,0xfffff
ffffffffc0202b9a:	00008797          	auipc	a5,0x8
ffffffffc0202b9e:	9c578793          	addi	a5,a5,-1595 # ffffffffc020a55f <end+0xfff>
ffffffffc0202ba2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202ba4:	00007517          	auipc	a0,0x7
ffffffffc0202ba8:	98450513          	addi	a0,a0,-1660 # ffffffffc0209528 <npage>
ffffffffc0202bac:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202bb0:	00007597          	auipc	a1,0x7
ffffffffc0202bb4:	98058593          	addi	a1,a1,-1664 # ffffffffc0209530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202bb8:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202bba:	e19c                	sd	a5,0(a1)
ffffffffc0202bbc:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202bbe:	4701                	li	a4,0
ffffffffc0202bc0:	4885                	li	a7,1
ffffffffc0202bc2:	fff80837          	lui	a6,0xfff80
ffffffffc0202bc6:	a011                	j	ffffffffc0202bca <pmm_init+0xa8>
        SetPageReserved(pages + i);
ffffffffc0202bc8:	619c                	ld	a5,0(a1)
ffffffffc0202bca:	97b6                	add	a5,a5,a3
ffffffffc0202bcc:	07a1                	addi	a5,a5,8
ffffffffc0202bce:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202bd2:	611c                	ld	a5,0(a0)
ffffffffc0202bd4:	0705                	addi	a4,a4,1
ffffffffc0202bd6:	02868693          	addi	a3,a3,40
ffffffffc0202bda:	01078633          	add	a2,a5,a6
ffffffffc0202bde:	fec765e3          	bltu	a4,a2,ffffffffc0202bc8 <pmm_init+0xa6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202be2:	6190                	ld	a2,0(a1)
ffffffffc0202be4:	00279713          	slli	a4,a5,0x2
ffffffffc0202be8:	973e                	add	a4,a4,a5
ffffffffc0202bea:	fec006b7          	lui	a3,0xfec00
ffffffffc0202bee:	070e                	slli	a4,a4,0x3
ffffffffc0202bf0:	96b2                	add	a3,a3,a2
ffffffffc0202bf2:	96ba                	add	a3,a3,a4
ffffffffc0202bf4:	c0200737          	lui	a4,0xc0200
ffffffffc0202bf8:	0ce6ed63          	bltu	a3,a4,ffffffffc0202cd2 <pmm_init+0x1b0>
ffffffffc0202bfc:	6018                	ld	a4,0(s0)
    if (freemem < mem_end)
ffffffffc0202bfe:	45c5                	li	a1,17
ffffffffc0202c00:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c02:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end)
ffffffffc0202c04:	06b6ea63          	bltu	a3,a1,ffffffffc0202c78 <pmm_init+0x156>
    cprintf("[pmm] satp virtual address: 0x%016lx\n[pmm] satp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202c08:	609c                	ld	a5,0(s1)
ffffffffc0202c0a:	7b9c                	ld	a5,48(a5)
ffffffffc0202c0c:	9782                	jalr	a5
    cprintf("[pmm] check_alloc_page() succeeded!\n");
ffffffffc0202c0e:	00002517          	auipc	a0,0x2
ffffffffc0202c12:	47250513          	addi	a0,a0,1138 # ffffffffc0205080 <default_pmm_manager+0x118>
ffffffffc0202c16:	cc0fd0ef          	jal	ra,ffffffffc02000d6 <cprintf>
    satp_virtual = (pte_t *)boot_page_table_sv39;
ffffffffc0202c1a:	00005597          	auipc	a1,0x5
ffffffffc0202c1e:	3e658593          	addi	a1,a1,998 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0202c22:	00007797          	auipc	a5,0x7
ffffffffc0202c26:	92b7b323          	sd	a1,-1754(a5) # ffffffffc0209548 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0202c2a:	c02007b7          	lui	a5,0xc0200
ffffffffc0202c2e:	0cf5ea63          	bltu	a1,a5,ffffffffc0202d02 <pmm_init+0x1e0>
ffffffffc0202c32:	6010                	ld	a2,0(s0)
}
ffffffffc0202c34:	6442                	ld	s0,16(sp)
ffffffffc0202c36:	60e2                	ld	ra,24(sp)
ffffffffc0202c38:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0202c3a:	40c58633          	sub	a2,a1,a2
ffffffffc0202c3e:	00007797          	auipc	a5,0x7
ffffffffc0202c42:	90c7b123          	sd	a2,-1790(a5) # ffffffffc0209540 <satp_physical>
    cprintf("[pmm] satp virtual address: 0x%016lx\n[pmm] satp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0202c46:	00002517          	auipc	a0,0x2
ffffffffc0202c4a:	46250513          	addi	a0,a0,1122 # ffffffffc02050a8 <default_pmm_manager+0x140>
}
ffffffffc0202c4e:	6105                	addi	sp,sp,32
    cprintf("[pmm] satp virtual address: 0x%016lx\n[pmm] satp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0202c50:	c86fd06f          	j	ffffffffc02000d6 <cprintf>
    else if (strcmp(manager_name, "best_fit") == 0)
ffffffffc0202c54:	00001597          	auipc	a1,0x1
ffffffffc0202c58:	14458593          	addi	a1,a1,324 # ffffffffc0203d98 <etext+0x12>
ffffffffc0202c5c:	8522                	mv	a0,s0
ffffffffc0202c5e:	0ca010ef          	jal	ra,ffffffffc0203d28 <strcmp>
ffffffffc0202c62:	e121                	bnez	a0,ffffffffc0202ca2 <pmm_init+0x180>
        pmm_manager = &best_fit_pmm_manager;
ffffffffc0202c64:	00002797          	auipc	a5,0x2
ffffffffc0202c68:	c3c78793          	addi	a5,a5,-964 # ffffffffc02048a0 <best_fit_pmm_manager>
ffffffffc0202c6c:	00007497          	auipc	s1,0x7
ffffffffc0202c70:	8cc48493          	addi	s1,s1,-1844 # ffffffffc0209538 <pmm_manager>
ffffffffc0202c74:	e09c                	sd	a5,0(s1)
ffffffffc0202c76:	bde1                	j	ffffffffc0202b4e <pmm_init+0x2c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c78:	6705                	lui	a4,0x1
ffffffffc0202c7a:	177d                	addi	a4,a4,-1
ffffffffc0202c7c:	96ba                	add	a3,a3,a4
ffffffffc0202c7e:	777d                	lui	a4,0xfffff
ffffffffc0202c80:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0202c82:	00c6d513          	srli	a0,a3,0xc
ffffffffc0202c86:	06f57263          	bgeu	a0,a5,ffffffffc0202cea <pmm_init+0x1c8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202c8a:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0202c8c:	982a                	add	a6,a6,a0
ffffffffc0202c8e:	00281513          	slli	a0,a6,0x2
ffffffffc0202c92:	9542                	add	a0,a0,a6
ffffffffc0202c94:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c96:	8d95                	sub	a1,a1,a3
ffffffffc0202c98:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202c9a:	81b1                	srli	a1,a1,0xc
ffffffffc0202c9c:	9532                	add	a0,a0,a2
ffffffffc0202c9e:	9782                	jalr	a5
}
ffffffffc0202ca0:	b7a5                	j	ffffffffc0202c08 <pmm_init+0xe6>
    else if (strcmp(manager_name, "buddy_system") == 0)
ffffffffc0202ca2:	00001597          	auipc	a1,0x1
ffffffffc0202ca6:	10658593          	addi	a1,a1,262 # ffffffffc0203da8 <etext+0x22>
ffffffffc0202caa:	8522                	mv	a0,s0
ffffffffc0202cac:	07c010ef          	jal	ra,ffffffffc0203d28 <strcmp>
ffffffffc0202cb0:	c519                	beqz	a0,ffffffffc0202cbe <pmm_init+0x19c>
    cprintf("[pmm] memory management: %s\n", pmm_manager->name);
ffffffffc0202cb2:	00007497          	auipc	s1,0x7
ffffffffc0202cb6:	88648493          	addi	s1,s1,-1914 # ffffffffc0209538 <pmm_manager>
ffffffffc0202cba:	609c                	ld	a5,0(s1)
ffffffffc0202cbc:	bd49                	j	ffffffffc0202b4e <pmm_init+0x2c>
        pmm_manager = &buddy_pmm_manager;
ffffffffc0202cbe:	00002797          	auipc	a5,0x2
ffffffffc0202cc2:	10278793          	addi	a5,a5,258 # ffffffffc0204dc0 <buddy_pmm_manager>
ffffffffc0202cc6:	00007497          	auipc	s1,0x7
ffffffffc0202cca:	87248493          	addi	s1,s1,-1934 # ffffffffc0209538 <pmm_manager>
ffffffffc0202cce:	e09c                	sd	a5,0(s1)
ffffffffc0202cd0:	bdbd                	j	ffffffffc0202b4e <pmm_init+0x2c>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202cd2:	00002617          	auipc	a2,0x2
ffffffffc0202cd6:	34660613          	addi	a2,a2,838 # ffffffffc0205018 <default_pmm_manager+0xb0>
ffffffffc0202cda:	08100593          	li	a1,129
ffffffffc0202cde:	00002517          	auipc	a0,0x2
ffffffffc0202ce2:	36250513          	addi	a0,a0,866 # ffffffffc0205040 <default_pmm_manager+0xd8>
ffffffffc0202ce6:	eeafd0ef          	jal	ra,ffffffffc02003d0 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202cea:	00002617          	auipc	a2,0x2
ffffffffc0202cee:	36660613          	addi	a2,a2,870 # ffffffffc0205050 <default_pmm_manager+0xe8>
ffffffffc0202cf2:	06b00593          	li	a1,107
ffffffffc0202cf6:	00002517          	auipc	a0,0x2
ffffffffc0202cfa:	37a50513          	addi	a0,a0,890 # ffffffffc0205070 <default_pmm_manager+0x108>
ffffffffc0202cfe:	ed2fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0202d02:	86ae                	mv	a3,a1
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	31460613          	addi	a2,a2,788 # ffffffffc0205018 <default_pmm_manager+0xb0>
ffffffffc0202d0c:	09e00593          	li	a1,158
ffffffffc0202d10:	00002517          	auipc	a0,0x2
ffffffffc0202d14:	33050513          	addi	a0,a0,816 # ffffffffc0205040 <default_pmm_manager+0xd8>
ffffffffc0202d18:	eb8fd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0202d1c <kmem_slab_destroy>:
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d1c:	00007797          	auipc	a5,0x7
ffffffffc0202d20:	8147b783          	ld	a5,-2028(a5) # ffffffffc0209530 <pages>
ffffffffc0202d24:	40f587b3          	sub	a5,a1,a5
ffffffffc0202d28:	00003717          	auipc	a4,0x3
ffffffffc0202d2c:	9c073703          	ld	a4,-1600(a4) # ffffffffc02056e8 <error_string+0x38>
ffffffffc0202d30:	878d                	srai	a5,a5,0x3
ffffffffc0202d32:	02e787b3          	mul	a5,a5,a4
ffffffffc0202d36:	00003717          	auipc	a4,0x3
ffffffffc0202d3a:	9ba73703          	ld	a4,-1606(a4) # ffffffffc02056f0 <nbase>
#define le2slab(le, link) ((struct slab_t *)le2page((struct Page *)le, link))
#define slab2kva(slab) (page2kva((struct Page *)slab))

static inline void *page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
ffffffffc0202d3e:	00006617          	auipc	a2,0x6
ffffffffc0202d42:	7ea63603          	ld	a2,2026(a2) # ffffffffc0209528 <npage>
ffffffffc0202d46:	97ba                	add	a5,a5,a4
ffffffffc0202d48:	00c79713          	slli	a4,a5,0xc
ffffffffc0202d4c:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d4e:	00c79693          	slli	a3,a5,0xc
ffffffffc0202d52:	06c77d63          	bgeu	a4,a2,ffffffffc0202dcc <kmem_slab_destroy+0xb0>
/* 释放cachep中的一个slab块对应的页，析构buf中的对象后将page归还 */
static void kmem_slab_destroy(struct kmem_cache_t *cachep, struct slab_t *slab)
{
    struct Page *page = (struct Page *)slab;
    int16_t *bufctl = page2kva(page);
    void *buf = bufctl + cachep->num;
ffffffffc0202d56:	03255603          	lhu	a2,50(a0)
    // slab下所有的obj全部析构为DEFAULT_DTVAL
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202d5a:	03055703          	lhu	a4,48(a0)
    return KADDR(page2pa(page));
ffffffffc0202d5e:	00006797          	auipc	a5,0x6
ffffffffc0202d62:	7f27b783          	ld	a5,2034(a5) # ffffffffc0209550 <va_pa_offset>
ffffffffc0202d66:	97b6                	add	a5,a5,a3
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202d68:	02c706bb          	mulw	a3,a4,a2
    void *buf = bufctl + cachep->num;
ffffffffc0202d6c:	0606                	slli	a2,a2,0x1
ffffffffc0202d6e:	00c78333          	add	t1,a5,a2
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202d72:	8e2e                	mv	t3,a1
ffffffffc0202d74:	861a                	mv	a2,t1
    {
        char *objp = (char *)p;
        for (int i = 0; i < cachep->objsize; i++)
        {

            objp[i] = DEFAULT_DTVAL;
ffffffffc0202d76:	4885                	li	a7,1
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202d78:	00d307b3          	add	a5,t1,a3
ffffffffc0202d7c:	02f37a63          	bgeu	t1,a5,ffffffffc0202db0 <kmem_slab_destroy+0x94>
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc0202d80:	4781                	li	a5,0
ffffffffc0202d82:	4801                	li	a6,0
ffffffffc0202d84:	cf11                	beqz	a4,ffffffffc0202da0 <kmem_slab_destroy+0x84>
            objp[i] = DEFAULT_DTVAL;
ffffffffc0202d86:	00f60733          	add	a4,a2,a5
ffffffffc0202d8a:	01170023          	sb	a7,0(a4)
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc0202d8e:	03055703          	lhu	a4,48(a0)
ffffffffc0202d92:	0785                	addi	a5,a5,1
ffffffffc0202d94:	0007869b          	sext.w	a3,a5
ffffffffc0202d98:	0007081b          	sext.w	a6,a4
ffffffffc0202d9c:	fee6c5e3          	blt	a3,a4,ffffffffc0202d86 <kmem_slab_destroy+0x6a>
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202da0:	03255783          	lhu	a5,50(a0)
ffffffffc0202da4:	963a                	add	a2,a2,a4
ffffffffc0202da6:	0307883b          	mulw	a6,a5,a6
ffffffffc0202daa:	981a                	add	a6,a6,t1
ffffffffc0202dac:	fd066ae3          	bltu	a2,a6,ffffffffc0202d80 <kmem_slab_destroy+0x64>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202db0:	018e3703          	ld	a4,24(t3)
ffffffffc0202db4:	020e3783          	ld	a5,32(t3)
        }
    }
    page->property = page->flags = 0;
ffffffffc0202db8:	000e3423          	sd	zero,8(t3)
ffffffffc0202dbc:	000e2823          	sw	zero,16(t3)
    prev->next = next;
ffffffffc0202dc0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202dc2:	e398                	sd	a4,0(a5)
    list_del(&(page->page_link));
    free_page(page);
ffffffffc0202dc4:	4585                	li	a1,1
ffffffffc0202dc6:	8572                	mv	a0,t3
ffffffffc0202dc8:	ce1ff06f          	j	ffffffffc0202aa8 <free_pages>
{
ffffffffc0202dcc:	1141                	addi	sp,sp,-16
    return KADDR(page2pa(page));
ffffffffc0202dce:	00002617          	auipc	a2,0x2
ffffffffc0202dd2:	b2a60613          	addi	a2,a2,-1238 # ffffffffc02048f8 <best_fit_pmm_manager+0x58>
ffffffffc0202dd6:	45cd                	li	a1,19
ffffffffc0202dd8:	00002517          	auipc	a0,0x2
ffffffffc0202ddc:	32050513          	addi	a0,a0,800 # ffffffffc02050f8 <default_pmm_manager+0x190>
{
ffffffffc0202de0:	e406                	sd	ra,8(sp)
    return KADDR(page2pa(page));
ffffffffc0202de2:	deefd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0202de6 <kmem_cache_alloc>:
}

// 第三层结构
/* 从cachep指向的仓库中分配一个对象，返回指向对象的指针objp */
void *kmem_cache_alloc(struct kmem_cache_t *cachep)
{
ffffffffc0202de6:	7139                	addi	sp,sp,-64
ffffffffc0202de8:	f426                	sd	s1,40(sp)
    return list->next == list;
ffffffffc0202dea:	6d04                	ld	s1,24(a0)
ffffffffc0202dec:	f822                	sd	s0,48(sp)
ffffffffc0202dee:	f04a                	sd	s2,32(sp)
ffffffffc0202df0:	ec4e                	sd	s3,24(sp)
ffffffffc0202df2:	fc06                	sd	ra,56(sp)
ffffffffc0202df4:	e852                	sd	s4,16(sp)
ffffffffc0202df6:	e456                	sd	s5,8(sp)
ffffffffc0202df8:	e05a                	sd	s6,0(sp)
    list_entry_t *le = NULL;
    if (!list_empty(&(cachep->slabs_partial)))
ffffffffc0202dfa:	01050913          	addi	s2,a0,16
{
ffffffffc0202dfe:	842a                	mv	s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e00:	00003997          	auipc	s3,0x3
ffffffffc0202e04:	8f09b983          	ld	s3,-1808(s3) # ffffffffc02056f0 <nbase>
    if (!list_empty(&(cachep->slabs_partial)))
ffffffffc0202e08:	0a990063          	beq	s2,s1,ffffffffc0202ea8 <kmem_cache_alloc+0xc2>
ffffffffc0202e0c:	00006817          	auipc	a6,0x6
ffffffffc0202e10:	72483803          	ld	a6,1828(a6) # ffffffffc0209530 <pages>
    return KADDR(page2pa(page));
ffffffffc0202e14:	00006617          	auipc	a2,0x6
ffffffffc0202e18:	71463603          	ld	a2,1812(a2) # ffffffffc0209528 <npage>
ffffffffc0202e1c:	00003a17          	auipc	s4,0x3
ffffffffc0202e20:	8cca3a03          	ld	s4,-1844(s4) # ffffffffc02056e8 <error_string+0x38>
            return NULL;
        }
        le = list_next(&(cachep->slabs_free));
    }
    list_del(le);
    struct slab_t *slab = le2slab(le, page_link);
ffffffffc0202e24:	fe848693          	addi	a3,s1,-24
ffffffffc0202e28:	410686b3          	sub	a3,a3,a6
ffffffffc0202e2c:	868d                	srai	a3,a3,0x3
ffffffffc0202e2e:	034686b3          	mul	a3,a3,s4
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e32:	649c                	ld	a5,8(s1)
ffffffffc0202e34:	6098                	ld	a4,0(s1)
    prev->next = next;
ffffffffc0202e36:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202e38:	e398                	sd	a4,0(a5)
ffffffffc0202e3a:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0202e3c:	00c69793          	slli	a5,a3,0xc
ffffffffc0202e40:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e42:	06b2                	slli	a3,a3,0xc
ffffffffc0202e44:	16c7fb63          	bgeu	a5,a2,ffffffffc0202fba <kmem_cache_alloc+0x1d4>
    void *kva = slab2kva(slab);
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc0202e48:	ffa49703          	lh	a4,-6(s1)
ffffffffc0202e4c:	03045503          	lhu	a0,48(s0)
    slab->inuse++;
ffffffffc0202e50:	ff84d783          	lhu	a5,-8(s1)
    return KADDR(page2pa(page));
ffffffffc0202e54:	00006617          	auipc	a2,0x6
ffffffffc0202e58:	6fc63603          	ld	a2,1788(a2) # ffffffffc0209550 <va_pa_offset>
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc0202e5c:	02e5053b          	mulw	a0,a0,a4
    slab->inuse++;
ffffffffc0202e60:	2785                	addiw	a5,a5,1
ffffffffc0202e62:	17c2                	slli	a5,a5,0x30
    return KADDR(page2pa(page));
ffffffffc0202e64:	96b2                	add	a3,a3,a2
    slab->inuse++;
ffffffffc0202e66:	93c1                	srli	a5,a5,0x30
    slab->free = bufctl[slab->free];
ffffffffc0202e68:	0706                	slli	a4,a4,0x1
    void *buf = bufctl + cachep->num;
ffffffffc0202e6a:	03245603          	lhu	a2,50(s0)
    slab->free = bufctl[slab->free];
ffffffffc0202e6e:	9736                	add	a4,a4,a3
    slab->inuse++;
ffffffffc0202e70:	fef49c23          	sh	a5,-8(s1)
    slab->free = bufctl[slab->free];
ffffffffc0202e74:	00071703          	lh	a4,0(a4)
    void *buf = bufctl + cachep->num;
ffffffffc0202e78:	00161593          	slli	a1,a2,0x1
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc0202e7c:	952e                	add	a0,a0,a1
    slab->free = bufctl[slab->free];
ffffffffc0202e7e:	fee49d23          	sh	a4,-6(s1)
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc0202e82:	9536                	add	a0,a0,a3
    if (slab->inuse == cachep->num)
ffffffffc0202e84:	12f60563          	beq	a2,a5,ffffffffc0202fae <kmem_cache_alloc+0x1c8>
    __list_add(elm, listelm, listelm->next);
ffffffffc0202e88:	6c1c                	ld	a5,24(s0)
    prev->next = next->prev = elm;
ffffffffc0202e8a:	e384                	sd	s1,0(a5)
ffffffffc0202e8c:	ec04                	sd	s1,24(s0)
    elm->next = next;
ffffffffc0202e8e:	e49c                	sd	a5,8(s1)
    elm->prev = prev;
ffffffffc0202e90:	0124b023          	sd	s2,0(s1)
        list_add(&(cachep->slabs_full), le);
    else
        list_add(&(cachep->slabs_partial), le);
    return objp;
}
ffffffffc0202e94:	70e2                	ld	ra,56(sp)
ffffffffc0202e96:	7442                	ld	s0,48(sp)
ffffffffc0202e98:	74a2                	ld	s1,40(sp)
ffffffffc0202e9a:	7902                	ld	s2,32(sp)
ffffffffc0202e9c:	69e2                	ld	s3,24(sp)
ffffffffc0202e9e:	6a42                	ld	s4,16(sp)
ffffffffc0202ea0:	6aa2                	ld	s5,8(sp)
ffffffffc0202ea2:	6b02                	ld	s6,0(sp)
ffffffffc0202ea4:	6121                	addi	sp,sp,64
ffffffffc0202ea6:	8082                	ret
    return list->next == list;
ffffffffc0202ea8:	7504                	ld	s1,40(a0)
        if (list_empty(&(cachep->slabs_free)) && kmem_cache_grow(cachep) == NULL)
ffffffffc0202eaa:	02050793          	addi	a5,a0,32
ffffffffc0202eae:	f4f49fe3          	bne	s1,a5,ffffffffc0202e0c <kmem_cache_alloc+0x26>
    struct Page *page = alloc_pages(1);
ffffffffc0202eb2:	4505                	li	a0,1
ffffffffc0202eb4:	bb7ff0ef          	jal	ra,ffffffffc0202a6a <alloc_pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202eb8:	00006b17          	auipc	s6,0x6
ffffffffc0202ebc:	678b0b13          	addi	s6,s6,1656 # ffffffffc0209530 <pages>
ffffffffc0202ec0:	000b3783          	ld	a5,0(s6)
ffffffffc0202ec4:	00003a17          	auipc	s4,0x3
ffffffffc0202ec8:	824a3a03          	ld	s4,-2012(s4) # ffffffffc02056e8 <error_string+0x38>
ffffffffc0202ecc:	8aaa                	mv	s5,a0
ffffffffc0202ece:	40f505b3          	sub	a1,a0,a5
ffffffffc0202ed2:	858d                	srai	a1,a1,0x3
ffffffffc0202ed4:	034585b3          	mul	a1,a1,s4
    cprintf("[slub] allocate page for kmem_cache, address: %p\n", page2pa(page));
ffffffffc0202ed8:	00002517          	auipc	a0,0x2
ffffffffc0202edc:	23050513          	addi	a0,a0,560 # ffffffffc0205108 <default_pmm_manager+0x1a0>
ffffffffc0202ee0:	95ce                	add	a1,a1,s3
ffffffffc0202ee2:	05b2                	slli	a1,a1,0xc
ffffffffc0202ee4:	9f2fd0ef          	jal	ra,ffffffffc02000d6 <cprintf>
ffffffffc0202ee8:	000b3803          	ld	a6,0(s6)
    return KADDR(page2pa(page));
ffffffffc0202eec:	00006517          	auipc	a0,0x6
ffffffffc0202ef0:	63c50513          	addi	a0,a0,1596 # ffffffffc0209528 <npage>
ffffffffc0202ef4:	6110                	ld	a2,0(a0)
ffffffffc0202ef6:	410a87b3          	sub	a5,s5,a6
ffffffffc0202efa:	878d                	srai	a5,a5,0x3
ffffffffc0202efc:	034787b3          	mul	a5,a5,s4
ffffffffc0202f00:	97ce                	add	a5,a5,s3
ffffffffc0202f02:	00c79713          	slli	a4,a5,0xc
ffffffffc0202f06:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f08:	07b2                	slli	a5,a5,0xc
ffffffffc0202f0a:	0cc77363          	bgeu	a4,a2,ffffffffc0202fd0 <kmem_cache_alloc+0x1ea>
    slab->inuse = slab->free = 0;
ffffffffc0202f0e:	000aa823          	sw	zero,16(s5)
    for (int i = 1; i < cachep->num; i++)
ffffffffc0202f12:	03245683          	lhu	a3,50(s0)
    return KADDR(page2pa(page));
ffffffffc0202f16:	00006717          	auipc	a4,0x6
ffffffffc0202f1a:	63a73703          	ld	a4,1594(a4) # ffffffffc0209550 <va_pa_offset>
ffffffffc0202f1e:	97ba                	add	a5,a5,a4
    slab->cachep = cachep;
ffffffffc0202f20:	008ab423          	sd	s0,8(s5)
    for (int i = 1; i < cachep->num; i++)
ffffffffc0202f24:	4705                	li	a4,1
    return KADDR(page2pa(page));
ffffffffc0202f26:	85be                	mv	a1,a5
    for (int i = 1; i < cachep->num; i++)
ffffffffc0202f28:	00d77a63          	bgeu	a4,a3,ffffffffc0202f3c <kmem_cache_alloc+0x156>
        bufctl[i - 1] = i; // 链表结构，初始化时都是空闲，因此都指向自己的下一个元素
ffffffffc0202f2c:	00e79023          	sh	a4,0(a5)
    for (int i = 1; i < cachep->num; i++)
ffffffffc0202f30:	03245683          	lhu	a3,50(s0)
ffffffffc0202f34:	2705                	addiw	a4,a4,1
ffffffffc0202f36:	0789                	addi	a5,a5,2
ffffffffc0202f38:	fed74ae3          	blt	a4,a3,ffffffffc0202f2c <kmem_cache_alloc+0x146>
    bufctl[cachep->num - 1] = -1;
ffffffffc0202f3c:	00169793          	slli	a5,a3,0x1
ffffffffc0202f40:	97ae                	add	a5,a5,a1
ffffffffc0202f42:	577d                	li	a4,-1
ffffffffc0202f44:	fee79f23          	sh	a4,-2(a5)
    void *buf = bufctl + cachep->num;
ffffffffc0202f48:	03245783          	lhu	a5,50(s0)
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202f4c:	03045703          	lhu	a4,48(s0)
    void *buf = bufctl + cachep->num;
ffffffffc0202f50:	00179693          	slli	a3,a5,0x1
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202f54:	02f707bb          	mulw	a5,a4,a5
    void *buf = bufctl + cachep->num;
ffffffffc0202f58:	96ae                	add	a3,a3,a1
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202f5a:	85b6                	mv	a1,a3
ffffffffc0202f5c:	97b6                	add	a5,a5,a3
ffffffffc0202f5e:	02f6fd63          	bgeu	a3,a5,ffffffffc0202f98 <kmem_cache_alloc+0x1b2>
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc0202f62:	4781                	li	a5,0
ffffffffc0202f64:	4801                	li	a6,0
ffffffffc0202f66:	cf11                	beqz	a4,ffffffffc0202f82 <kmem_cache_alloc+0x19c>
            objp[i] = DEFAULT_CTVAL;
ffffffffc0202f68:	00f58733          	add	a4,a1,a5
ffffffffc0202f6c:	00070023          	sb	zero,0(a4)
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc0202f70:	03045703          	lhu	a4,48(s0)
ffffffffc0202f74:	0785                	addi	a5,a5,1
ffffffffc0202f76:	0007861b          	sext.w	a2,a5
ffffffffc0202f7a:	0007081b          	sext.w	a6,a4
ffffffffc0202f7e:	fee645e3          	blt	a2,a4,ffffffffc0202f68 <kmem_cache_alloc+0x182>
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0202f82:	03245783          	lhu	a5,50(s0)
ffffffffc0202f86:	95ba                	add	a1,a1,a4
ffffffffc0202f88:	0307883b          	mulw	a6,a5,a6
ffffffffc0202f8c:	9836                	add	a6,a6,a3
ffffffffc0202f8e:	fd05eae3          	bltu	a1,a6,ffffffffc0202f62 <kmem_cache_alloc+0x17c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f92:	000b3803          	ld	a6,0(s6)
    return KADDR(page2pa(page));
ffffffffc0202f96:	6110                	ld	a2,0(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202f98:	741c                	ld	a5,40(s0)
    list_add(&(cachep->slabs_free), &(slab->slab_link));
ffffffffc0202f9a:	018a8713          	addi	a4,s5,24
    prev->next = next->prev = elm;
ffffffffc0202f9e:	e398                	sd	a4,0(a5)
ffffffffc0202fa0:	f418                	sd	a4,40(s0)
    elm->next = next;
ffffffffc0202fa2:	02fab023          	sd	a5,32(s5)
    elm->prev = prev;
ffffffffc0202fa6:	009abc23          	sd	s1,24(s5)
    return listelm->next;
ffffffffc0202faa:	7404                	ld	s1,40(s0)
ffffffffc0202fac:	bda5                	j	ffffffffc0202e24 <kmem_cache_alloc+0x3e>
    __list_add(elm, listelm, listelm->next);
ffffffffc0202fae:	641c                	ld	a5,8(s0)
    prev->next = next->prev = elm;
ffffffffc0202fb0:	e384                	sd	s1,0(a5)
ffffffffc0202fb2:	e404                	sd	s1,8(s0)
    elm->next = next;
ffffffffc0202fb4:	e49c                	sd	a5,8(s1)
    elm->prev = prev;
ffffffffc0202fb6:	e080                	sd	s0,0(s1)
}
ffffffffc0202fb8:	bdf1                	j	ffffffffc0202e94 <kmem_cache_alloc+0xae>
    return KADDR(page2pa(page));
ffffffffc0202fba:	00002617          	auipc	a2,0x2
ffffffffc0202fbe:	93e60613          	addi	a2,a2,-1730 # ffffffffc02048f8 <best_fit_pmm_manager+0x58>
ffffffffc0202fc2:	45cd                	li	a1,19
ffffffffc0202fc4:	00002517          	auipc	a0,0x2
ffffffffc0202fc8:	13450513          	addi	a0,a0,308 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0202fcc:	c04fd0ef          	jal	ra,ffffffffc02003d0 <__panic>
ffffffffc0202fd0:	86be                	mv	a3,a5
ffffffffc0202fd2:	00002617          	auipc	a2,0x2
ffffffffc0202fd6:	92660613          	addi	a2,a2,-1754 # ffffffffc02048f8 <best_fit_pmm_manager+0x58>
ffffffffc0202fda:	45cd                	li	a1,19
ffffffffc0202fdc:	00002517          	auipc	a0,0x2
ffffffffc0202fe0:	11c50513          	addi	a0,a0,284 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0202fe4:	becfd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0202fe8 <kmem_cache_create>:
{
ffffffffc0202fe8:	1101                	addi	sp,sp,-32
ffffffffc0202fea:	e04a                	sd	s2,0(sp)
ffffffffc0202fec:	892a                	mv	s2,a0
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
ffffffffc0202fee:	00006517          	auipc	a0,0x6
ffffffffc0202ff2:	03a50513          	addi	a0,a0,58 # ffffffffc0209028 <cache_cache>
{
ffffffffc0202ff6:	e822                	sd	s0,16(sp)
ffffffffc0202ff8:	e426                	sd	s1,8(sp)
ffffffffc0202ffa:	ec06                	sd	ra,24(sp)
ffffffffc0202ffc:	84ae                	mv	s1,a1
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
ffffffffc0202ffe:	de9ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc0203002:	842a                	mv	s0,a0
    if (cachep != NULL)
ffffffffc0203004:	c531                	beqz	a0,ffffffffc0203050 <kmem_cache_create+0x68>
        cachep->num = PGSIZE / (sizeof(int16_t) + size); // int16_t是空闲链表指针的大小，size是obj的大小
ffffffffc0203006:	00248713          	addi	a4,s1,2
ffffffffc020300a:	6785                	lui	a5,0x1
ffffffffc020300c:	02e7d7b3          	divu	a5,a5,a4
        cachep->objsize = size;                          // 指定这个slab里面存的obj的大小
ffffffffc0203010:	02951823          	sh	s1,48(a0)
        memcpy(cachep->name, name, CACHE_NAMELEN);
ffffffffc0203014:	02000613          	li	a2,32
ffffffffc0203018:	85ca                	mv	a1,s2
ffffffffc020301a:	03450513          	addi	a0,a0,52
        cachep->num = PGSIZE / (sizeof(int16_t) + size); // int16_t是空闲链表指针的大小，size是obj的大小
ffffffffc020301e:	02f41923          	sh	a5,50(s0)
        memcpy(cachep->name, name, CACHE_NAMELEN);
ffffffffc0203022:	54d000ef          	jal	ra,ffffffffc0203d6e <memcpy>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203026:	00006717          	auipc	a4,0x6
ffffffffc020302a:	06a70713          	addi	a4,a4,106 # ffffffffc0209090 <cache_chain>
    elm->prev = elm->next = elm;
ffffffffc020302e:	e400                	sd	s0,8(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203030:	6714                	ld	a3,8(a4)
        list_init(&(cachep->slabs_partial));
ffffffffc0203032:	01040593          	addi	a1,s0,16
        list_init(&(cachep->slabs_free));
ffffffffc0203036:	02040613          	addi	a2,s0,32
    elm->prev = elm->next = elm;
ffffffffc020303a:	e000                	sd	s0,0(s0)
        list_add(&(cache_chain), &(cachep->cache_link));
ffffffffc020303c:	05840793          	addi	a5,s0,88
ffffffffc0203040:	ec0c                	sd	a1,24(s0)
ffffffffc0203042:	e80c                	sd	a1,16(s0)
ffffffffc0203044:	f410                	sd	a2,40(s0)
ffffffffc0203046:	f010                	sd	a2,32(s0)
    prev->next = next->prev = elm;
ffffffffc0203048:	e29c                	sd	a5,0(a3)
ffffffffc020304a:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc020304c:	f034                	sd	a3,96(s0)
    elm->prev = prev;
ffffffffc020304e:	ec38                	sd	a4,88(s0)
}
ffffffffc0203050:	60e2                	ld	ra,24(sp)
ffffffffc0203052:	8522                	mv	a0,s0
ffffffffc0203054:	6442                	ld	s0,16(sp)
ffffffffc0203056:	64a2                	ld	s1,8(sp)
ffffffffc0203058:	6902                	ld	s2,0(sp)
ffffffffc020305a:	6105                	addi	sp,sp,32
ffffffffc020305c:	8082                	ret

ffffffffc020305e <kmem_cache_free>:
ffffffffc020305e:	00002697          	auipc	a3,0x2
ffffffffc0203062:	6926b683          	ld	a3,1682(a3) # ffffffffc02056f0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203066:	00c69793          	slli	a5,a3,0xc
ffffffffc020306a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020306e:	00006617          	auipc	a2,0x6
ffffffffc0203072:	4ba63603          	ld	a2,1210(a2) # ffffffffc0209528 <npage>

/* 将对象objp从cachep中的Slab中释放 */
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp)
{
    void *base = page2kva(pages);
ffffffffc0203076:	00006797          	auipc	a5,0x6
ffffffffc020307a:	4ba7b783          	ld	a5,1210(a5) # ffffffffc0209530 <pages>
    return page2ppn(page) << PGSHIFT;
ffffffffc020307e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203080:	08c77b63          	bgeu	a4,a2,ffffffffc0203116 <kmem_cache_free+0xb8>
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
ffffffffc0203084:	03255703          	lhu	a4,50(a0)
    void *kva = ROUNDDOWN(objp, PGSIZE);
ffffffffc0203088:	767d                	lui	a2,0xfffff
    int offset = (objp - buf) / cachep->objsize;
ffffffffc020308a:	03055803          	lhu	a6,48(a0)
    void *kva = ROUNDDOWN(objp, PGSIZE);
ffffffffc020308e:	8e6d                	and	a2,a2,a1
    void *buf = bufctl + cachep->num;
ffffffffc0203090:	0706                	slli	a4,a4,0x1
ffffffffc0203092:	9732                	add	a4,a4,a2
    int offset = (objp - buf) / cachep->objsize;
ffffffffc0203094:	8d99                	sub	a1,a1,a4
ffffffffc0203096:	0305c5b3          	div	a1,a1,a6
    return KADDR(page2pa(page));
ffffffffc020309a:	00006717          	auipc	a4,0x6
ffffffffc020309e:	4b673703          	ld	a4,1206(a4) # ffffffffc0209550 <va_pa_offset>
ffffffffc02030a2:	96ba                	add	a3,a3,a4
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
ffffffffc02030a4:	40d606b3          	sub	a3,a2,a3
ffffffffc02030a8:	43f6d713          	srai	a4,a3,0x3f
ffffffffc02030ac:	1752                	slli	a4,a4,0x34
ffffffffc02030ae:	9351                	srli	a4,a4,0x34
ffffffffc02030b0:	9736                	add	a4,a4,a3
ffffffffc02030b2:	8731                	srai	a4,a4,0xc
ffffffffc02030b4:	00271693          	slli	a3,a4,0x2
ffffffffc02030b8:	9736                	add	a4,a4,a3
ffffffffc02030ba:	070e                	slli	a4,a4,0x3
ffffffffc02030bc:	97ba                	add	a5,a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc02030be:	7398                	ld	a4,32(a5)
ffffffffc02030c0:	6f94                	ld	a3,24(a5)
    list_del(&(slab->slab_link));
    bufctl[offset] = slab->free;
ffffffffc02030c2:	01279883          	lh	a7,18(a5)
    slab->inuse--;
    slab->free = offset;
    if (slab->inuse == 0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
ffffffffc02030c6:	01878813          	addi	a6,a5,24
    prev->next = next;
ffffffffc02030ca:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02030cc:	e314                	sd	a3,0(a4)
    bufctl[offset] = slab->free;
ffffffffc02030ce:	0005871b          	sext.w	a4,a1
ffffffffc02030d2:	0706                	slli	a4,a4,0x1
ffffffffc02030d4:	963a                	add	a2,a2,a4
ffffffffc02030d6:	01161023          	sh	a7,0(a2) # fffffffffffff000 <end+0x3fdf5aa0>
    slab->inuse--;
ffffffffc02030da:	0107d703          	lhu	a4,16(a5)
    slab->free = offset;
ffffffffc02030de:	00b79923          	sh	a1,18(a5)
    slab->inuse--;
ffffffffc02030e2:	377d                	addiw	a4,a4,-1
ffffffffc02030e4:	1742                	slli	a4,a4,0x30
ffffffffc02030e6:	9341                	srli	a4,a4,0x30
ffffffffc02030e8:	00e79823          	sh	a4,16(a5)
    if (slab->inuse == 0)
ffffffffc02030ec:	eb19                	bnez	a4,ffffffffc0203102 <kmem_cache_free+0xa4>
    __list_add(elm, listelm, listelm->next);
ffffffffc02030ee:	7518                	ld	a4,40(a0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
ffffffffc02030f0:	02050693          	addi	a3,a0,32
    prev->next = next->prev = elm;
ffffffffc02030f4:	01073023          	sd	a6,0(a4)
ffffffffc02030f8:	03053423          	sd	a6,40(a0)
    elm->next = next;
ffffffffc02030fc:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc02030fe:	ef94                	sd	a3,24(a5)
}
ffffffffc0203100:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0203102:	6d18                	ld	a4,24(a0)
    else
        list_add(&(cachep->slabs_partial), &(slab->slab_link));
ffffffffc0203104:	01050693          	addi	a3,a0,16
    prev->next = next->prev = elm;
ffffffffc0203108:	01073023          	sd	a6,0(a4)
ffffffffc020310c:	01053c23          	sd	a6,24(a0)
    elm->next = next;
ffffffffc0203110:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc0203112:	ef94                	sd	a3,24(a5)
ffffffffc0203114:	8082                	ret
{
ffffffffc0203116:	1141                	addi	sp,sp,-16
    return KADDR(page2pa(page));
ffffffffc0203118:	00001617          	auipc	a2,0x1
ffffffffc020311c:	7e060613          	addi	a2,a2,2016 # ffffffffc02048f8 <best_fit_pmm_manager+0x58>
ffffffffc0203120:	45cd                	li	a1,19
ffffffffc0203122:	00002517          	auipc	a0,0x2
ffffffffc0203126:	fd650513          	addi	a0,a0,-42 # ffffffffc02050f8 <default_pmm_manager+0x190>
{
ffffffffc020312a:	e406                	sd	ra,8(sp)
    return KADDR(page2pa(page));
ffffffffc020312c:	aa4fd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0203130 <kmem_cache_destroy>:
{
ffffffffc0203130:	1101                	addi	sp,sp,-32
ffffffffc0203132:	e426                	sd	s1,8(sp)
    return listelm->next;
ffffffffc0203134:	6504                	ld	s1,8(a0)
ffffffffc0203136:	e822                	sd	s0,16(sp)
ffffffffc0203138:	ec06                	sd	ra,24(sp)
ffffffffc020313a:	e04a                	sd	s2,0(sp)
ffffffffc020313c:	842a                	mv	s0,a0
    while (le != head)
ffffffffc020313e:	00950a63          	beq	a0,s1,ffffffffc0203152 <kmem_cache_destroy+0x22>
ffffffffc0203142:	85a6                	mv	a1,s1
ffffffffc0203144:	6484                	ld	s1,8(s1)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc0203146:	15a1                	addi	a1,a1,-24
ffffffffc0203148:	8522                	mv	a0,s0
ffffffffc020314a:	bd3ff0ef          	jal	ra,ffffffffc0202d1c <kmem_slab_destroy>
    while (le != head)
ffffffffc020314e:	fe941ae3          	bne	s0,s1,ffffffffc0203142 <kmem_cache_destroy+0x12>
ffffffffc0203152:	6c04                	ld	s1,24(s0)
    head = &(cachep->slabs_partial);
ffffffffc0203154:	01040913          	addi	s2,s0,16
    while (le != head)
ffffffffc0203158:	00990a63          	beq	s2,s1,ffffffffc020316c <kmem_cache_destroy+0x3c>
ffffffffc020315c:	85a6                	mv	a1,s1
ffffffffc020315e:	6484                	ld	s1,8(s1)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc0203160:	15a1                	addi	a1,a1,-24
ffffffffc0203162:	8522                	mv	a0,s0
ffffffffc0203164:	bb9ff0ef          	jal	ra,ffffffffc0202d1c <kmem_slab_destroy>
    while (le != head)
ffffffffc0203168:	fe991ae3          	bne	s2,s1,ffffffffc020315c <kmem_cache_destroy+0x2c>
ffffffffc020316c:	7404                	ld	s1,40(s0)
    head = &(cachep->slabs_free);
ffffffffc020316e:	02040913          	addi	s2,s0,32
    while (le != head)
ffffffffc0203172:	00990a63          	beq	s2,s1,ffffffffc0203186 <kmem_cache_destroy+0x56>
ffffffffc0203176:	85a6                	mv	a1,s1
ffffffffc0203178:	6484                	ld	s1,8(s1)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc020317a:	15a1                	addi	a1,a1,-24
ffffffffc020317c:	8522                	mv	a0,s0
ffffffffc020317e:	b9fff0ef          	jal	ra,ffffffffc0202d1c <kmem_slab_destroy>
    while (le != head)
ffffffffc0203182:	ff249ae3          	bne	s1,s2,ffffffffc0203176 <kmem_cache_destroy+0x46>
    kmem_cache_free(&(cache_cache), cachep);
ffffffffc0203186:	85a2                	mv	a1,s0
}
ffffffffc0203188:	6442                	ld	s0,16(sp)
ffffffffc020318a:	60e2                	ld	ra,24(sp)
ffffffffc020318c:	64a2                	ld	s1,8(sp)
ffffffffc020318e:	6902                	ld	s2,0(sp)
    kmem_cache_free(&(cache_cache), cachep);
ffffffffc0203190:	00006517          	auipc	a0,0x6
ffffffffc0203194:	e9850513          	addi	a0,a0,-360 # ffffffffc0209028 <cache_cache>
}
ffffffffc0203198:	6105                	addi	sp,sp,32
    kmem_cache_free(&(cache_cache), cachep);
ffffffffc020319a:	b5d1                	j	ffffffffc020305e <kmem_cache_free>

ffffffffc020319c <kfree>:
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020319c:	00002697          	auipc	a3,0x2
ffffffffc02031a0:	5546b683          	ld	a3,1364(a3) # ffffffffc02056f0 <nbase>
    return KADDR(page2pa(page));
ffffffffc02031a4:	00c69793          	slli	a5,a3,0xc
ffffffffc02031a8:	83b1                	srli	a5,a5,0xc
ffffffffc02031aa:	00006717          	auipc	a4,0x6
ffffffffc02031ae:	37e73703          	ld	a4,894(a4) # ffffffffc0209528 <npage>
    void *base = slab2kva(pages);
ffffffffc02031b2:	00006617          	auipc	a2,0x6
ffffffffc02031b6:	37e63603          	ld	a2,894(a2) # ffffffffc0209530 <pages>
    return page2ppn(page) << PGSHIFT;
ffffffffc02031ba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031bc:	02e7f963          	bgeu	a5,a4,ffffffffc02031ee <kfree+0x52>
ffffffffc02031c0:	00006717          	auipc	a4,0x6
ffffffffc02031c4:	39073703          	ld	a4,912(a4) # ffffffffc0209550 <va_pa_offset>
    void *kva = ROUNDDOWN(objp, PGSIZE);
ffffffffc02031c8:	77fd                	lui	a5,0xfffff
ffffffffc02031ca:	8fe9                	and	a5,a5,a0
    return KADDR(page2pa(page));
ffffffffc02031cc:	96ba                	add	a3,a3,a4
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
ffffffffc02031ce:	40d786b3          	sub	a3,a5,a3
ffffffffc02031d2:	43f6d793          	srai	a5,a3,0x3f
ffffffffc02031d6:	17d2                	slli	a5,a5,0x34
ffffffffc02031d8:	93d1                	srli	a5,a5,0x34
ffffffffc02031da:	97b6                	add	a5,a5,a3
ffffffffc02031dc:	87b1                	srai	a5,a5,0xc
    kmem_cache_free(slab->cachep, objp);
ffffffffc02031de:	00279713          	slli	a4,a5,0x2
ffffffffc02031e2:	97ba                	add	a5,a5,a4
ffffffffc02031e4:	078e                	slli	a5,a5,0x3
ffffffffc02031e6:	97b2                	add	a5,a5,a2
ffffffffc02031e8:	85aa                	mv	a1,a0
ffffffffc02031ea:	6788                	ld	a0,8(a5)
ffffffffc02031ec:	bd8d                	j	ffffffffc020305e <kmem_cache_free>
{
ffffffffc02031ee:	1141                	addi	sp,sp,-16
    return KADDR(page2pa(page));
ffffffffc02031f0:	00001617          	auipc	a2,0x1
ffffffffc02031f4:	70860613          	addi	a2,a2,1800 # ffffffffc02048f8 <best_fit_pmm_manager+0x58>
ffffffffc02031f8:	45cd                	li	a1,19
ffffffffc02031fa:	00002517          	auipc	a0,0x2
ffffffffc02031fe:	efe50513          	addi	a0,a0,-258 # ffffffffc02050f8 <default_pmm_manager+0x190>
{
ffffffffc0203202:	e406                	sd	ra,8(sp)
    return KADDR(page2pa(page));
ffffffffc0203204:	9ccfd0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc0203208 <kmem_init>:
}
// ! 测试部分代码结束

// 在init.c中调用的函数
void kmem_init()
{
ffffffffc0203208:	711d                	addi	sp,sp,-96
    // 1. 初始化kmem_cache的cache仓库，简称为cache_cache
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc020320a:	002607b7          	lui	a5,0x260
{
ffffffffc020320e:	e8a2                	sd	s0,80(sp)
ffffffffc0203210:	e4a6                	sd	s1,72(sp)
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc0203212:	00006417          	auipc	s0,0x6
ffffffffc0203216:	e1640413          	addi	s0,s0,-490 # ffffffffc0209028 <cache_cache>
{
ffffffffc020321a:	e0ca                	sd	s2,64(sp)
ffffffffc020321c:	fc4e                	sd	s3,56(sp)
ffffffffc020321e:	f852                	sd	s4,48(sp)
ffffffffc0203220:	f456                	sd	s5,40(sp)
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc0203222:	06878793          	addi	a5,a5,104 # 260068 <kern_entry-0xffffffffbff9ff98>
{
ffffffffc0203226:	ec86                	sd	ra,88(sp)
ffffffffc0203228:	f05a                	sd	s6,32(sp)
ffffffffc020322a:	ec5e                	sd	s7,24(sp)
ffffffffc020322c:	e862                	sd	s8,16(sp)
ffffffffc020322e:	e466                	sd	s9,8(sp)
ffffffffc0203230:	e06a                	sd	s10,0(sp)
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc0203232:	d81c                	sw	a5,48(s0)
    cache_cache.num = PGSIZE / (sizeof(int16_t) + sizeof(struct kmem_cache_t)); // 算num的时候还要考虑前面int16_t的信息
    memcpy(cache_cache.name, cache_cache_name, CACHE_NAMELEN);
ffffffffc0203234:	02000613          	li	a2,32
ffffffffc0203238:	00002597          	auipc	a1,0x2
ffffffffc020323c:	f0858593          	addi	a1,a1,-248 # ffffffffc0205140 <default_pmm_manager+0x1d8>
ffffffffc0203240:	00006517          	auipc	a0,0x6
ffffffffc0203244:	e1c50513          	addi	a0,a0,-484 # ffffffffc020905c <cache_cache+0x34>
ffffffffc0203248:	327000ef          	jal	ra,ffffffffc0203d6e <memcpy>
    prev->next = next->prev = elm;
ffffffffc020324c:	00006917          	auipc	s2,0x6
ffffffffc0203250:	e4490913          	addi	s2,s2,-444 # ffffffffc0209090 <cache_chain>
    elm->prev = elm->next = elm;
ffffffffc0203254:	00006697          	auipc	a3,0x6
ffffffffc0203258:	de468693          	addi	a3,a3,-540 # ffffffffc0209038 <cache_cache+0x10>
ffffffffc020325c:	00006717          	auipc	a4,0x6
ffffffffc0203260:	dec70713          	addi	a4,a4,-532 # ffffffffc0209048 <cache_cache+0x20>
    prev->next = next->prev = elm;
ffffffffc0203264:	00006797          	auipc	a5,0x6
ffffffffc0203268:	e1c78793          	addi	a5,a5,-484 # ffffffffc0209080 <cache_cache+0x58>
ffffffffc020326c:	00006a97          	auipc	s5,0x6
ffffffffc0203270:	e34a8a93          	addi	s5,s5,-460 # ffffffffc02090a0 <sized_caches>
    elm->prev = elm->next = elm;
ffffffffc0203274:	e400                	sd	s0,8(s0)
ffffffffc0203276:	e000                	sd	s0,0(s0)
ffffffffc0203278:	ec14                	sd	a3,24(s0)
ffffffffc020327a:	e814                	sd	a3,16(s0)
ffffffffc020327c:	f418                	sd	a4,40(s0)
ffffffffc020327e:	f018                	sd	a4,32(s0)
    elm->next = next;
ffffffffc0203280:	07243023          	sd	s2,96(s0)
    elm->prev = prev;
ffffffffc0203284:	05243c23          	sd	s2,88(s0)
    prev->next = next->prev = elm;
ffffffffc0203288:	00f93023          	sd	a5,0(s2)
ffffffffc020328c:	00f93423          	sd	a5,8(s2)
    list_init(&(cache_chain));
    // 将第一个kmem_cache_t也就是cache_cache加入到cache_chain对应的链表中
    list_add(&(cache_chain), &(cache_cache.cache_link));

    // 2. 初始化8个固定大小的内置仓库
    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2){
ffffffffc0203290:	84d6                	mv	s1,s5
ffffffffc0203292:	00006a17          	auipc	s4,0x6
ffffffffc0203296:	e4ea0a13          	addi	s4,s4,-434 # ffffffffc02090e0 <buf>
ffffffffc020329a:	4441                	li	s0,16
        sized_caches[i] = kmem_cache_create(sized_cache_name, size);
ffffffffc020329c:	00002997          	auipc	s3,0x2
ffffffffc02032a0:	eac98993          	addi	s3,s3,-340 # ffffffffc0205148 <default_pmm_manager+0x1e0>
ffffffffc02032a4:	85a2                	mv	a1,s0
ffffffffc02032a6:	854e                	mv	a0,s3
ffffffffc02032a8:	d41ff0ef          	jal	ra,ffffffffc0202fe8 <kmem_cache_create>
ffffffffc02032ac:	e088                	sd	a0,0(s1)
    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2){
ffffffffc02032ae:	04a1                	addi	s1,s1,8
ffffffffc02032b0:	0014141b          	slliw	s0,s0,0x1
ffffffffc02032b4:	ff4498e3          	bne	s1,s4,ffffffffc02032a4 <kmem_init+0x9c>
    size_t fp = nr_free_pages();
ffffffffc02032b8:	831ff0ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc02032bc:	89aa                	mv	s3,a0
    struct kmem_cache_t *cp0 = kmem_cache_create(test_object_name, sizeof(struct test_object));
ffffffffc02032be:	40000593          	li	a1,1024
ffffffffc02032c2:	00002517          	auipc	a0,0x2
ffffffffc02032c6:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205150 <default_pmm_manager+0x1e8>
ffffffffc02032ca:	d1fff0ef          	jal	ra,ffffffffc0202fe8 <kmem_cache_create>
ffffffffc02032ce:	8a2a                	mv	s4,a0
    assert(cp0 != NULL);                                         // 创建成功
ffffffffc02032d0:	3e050563          	beqz	a0,ffffffffc02036ba <kmem_init+0x4b2>
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));  // 对象大小一致
ffffffffc02032d4:	03055703          	lhu	a4,48(a0)
ffffffffc02032d8:	40000793          	li	a5,1024
ffffffffc02032dc:	3af71f63          	bne	a4,a5,ffffffffc020369a <kmem_init+0x492>
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0); // 名字一样
ffffffffc02032e0:	00002597          	auipc	a1,0x2
ffffffffc02032e4:	e7058593          	addi	a1,a1,-400 # ffffffffc0205150 <default_pmm_manager+0x1e8>
ffffffffc02032e8:	03450513          	addi	a0,a0,52
ffffffffc02032ec:	23d000ef          	jal	ra,ffffffffc0203d28 <strcmp>
ffffffffc02032f0:	50051563          	bnez	a0,ffffffffc02037fa <kmem_init+0x5f2>
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc02032f4:	8552                	mv	a0,s4
ffffffffc02032f6:	af1ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc02032fa:	8baa                	mv	s7,a0
ffffffffc02032fc:	4c050f63          	beqz	a0,ffffffffc02037da <kmem_init+0x5d2>
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0203300:	8552                	mv	a0,s4
ffffffffc0203302:	ae5ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc0203306:	8b2a                	mv	s6,a0
ffffffffc0203308:	4a050963          	beqz	a0,ffffffffc02037ba <kmem_init+0x5b2>
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc020330c:	8552                	mv	a0,s4
ffffffffc020330e:	ad9ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc0203312:	84aa                	mv	s1,a0
ffffffffc0203314:	48050363          	beqz	a0,ffffffffc020379a <kmem_init+0x592>
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0203318:	8552                	mv	a0,s4
ffffffffc020331a:	acdff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc020331e:	8c2a                	mv	s8,a0
ffffffffc0203320:	44050d63          	beqz	a0,ffffffffc020377a <kmem_init+0x572>
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0203324:	8552                	mv	a0,s4
ffffffffc0203326:	ac1ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc020332a:	842a                	mv	s0,a0
ffffffffc020332c:	2a050763          	beqz	a0,ffffffffc02035da <kmem_init+0x3d2>
    assert((p5 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0203330:	8552                	mv	a0,s4
ffffffffc0203332:	ab5ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc0203336:	8caa                	mv	s9,a0
ffffffffc0203338:	87aa                	mv	a5,a0
ffffffffc020333a:	40050693          	addi	a3,a0,1024
ffffffffc020333e:	26050e63          	beqz	a0,ffffffffc02035ba <kmem_init+0x3b2>
        assert(p[i] == DEFAULT_CTVAL);
ffffffffc0203342:	0007c703          	lbu	a4,0(a5)
ffffffffc0203346:	20071a63          	bnez	a4,ffffffffc020355a <kmem_init+0x352>
    for (int i = 0; i < sizeof(struct test_object); i++)
ffffffffc020334a:	0785                	addi	a5,a5,1
ffffffffc020334c:	fed79be3          	bne	a5,a3,ffffffffc0203342 <kmem_init+0x13a>
    assert(nr_free_pages() + 2 == fp);
ffffffffc0203350:	f98ff0ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0203354:	00250793          	addi	a5,a0,2
ffffffffc0203358:	24f99163          	bne	s3,a5,ffffffffc020359a <kmem_init+0x392>
    return listelm->next;
ffffffffc020335c:	008a3783          	ld	a5,8(s4)
    while ((le = list_next(le)) != listelm){
ffffffffc0203360:	3efa0d63          	beq	s4,a5,ffffffffc020375a <kmem_init+0x552>
    size_t len = 0;
ffffffffc0203364:	4701                	li	a4,0
ffffffffc0203366:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0203368:	0705                	addi	a4,a4,1
    while ((le = list_next(le)) != listelm){
ffffffffc020336a:	fefa1ee3          	bne	s4,a5,ffffffffc0203366 <kmem_init+0x15e>
    assert(list_length(&(cp0->slabs_full)) == 2);
ffffffffc020336e:	4789                	li	a5,2
ffffffffc0203370:	3ef71563          	bne	a4,a5,ffffffffc020375a <kmem_init+0x552>
    assert(list_empty(&(cp0->slabs_partial)) == 1);
ffffffffc0203374:	018a3703          	ld	a4,24(s4)
ffffffffc0203378:	010a0793          	addi	a5,s4,16
ffffffffc020337c:	3af71f63          	bne	a4,a5,ffffffffc020373a <kmem_init+0x532>
    assert(list_empty(&(cp0->slabs_free)) == 1);
ffffffffc0203380:	028a3783          	ld	a5,40(s4)
ffffffffc0203384:	020a0d13          	addi	s10,s4,32
ffffffffc0203388:	38fd1963          	bne	s10,a5,ffffffffc020371a <kmem_init+0x512>
    kmem_cache_free(cp0, p3);
ffffffffc020338c:	85e2                	mv	a1,s8
ffffffffc020338e:	8552                	mv	a0,s4
ffffffffc0203390:	ccfff0ef          	jal	ra,ffffffffc020305e <kmem_cache_free>
    kmem_cache_free(cp0, p4);
ffffffffc0203394:	85a2                	mv	a1,s0
ffffffffc0203396:	8552                	mv	a0,s4
ffffffffc0203398:	cc7ff0ef          	jal	ra,ffffffffc020305e <kmem_cache_free>
    kmem_cache_free(cp0, p5);
ffffffffc020339c:	85e6                	mv	a1,s9
ffffffffc020339e:	8552                	mv	a0,s4
ffffffffc02033a0:	cbfff0ef          	jal	ra,ffffffffc020305e <kmem_cache_free>
ffffffffc02033a4:	028a3c03          	ld	s8,40(s4)
    while ((le = list_next(le)) != listelm){
ffffffffc02033a8:	258d0963          	beq	s10,s8,ffffffffc02035fa <kmem_init+0x3f2>
ffffffffc02033ac:	8ce2                	mv	s9,s8
    size_t len = 0;
ffffffffc02033ae:	4781                	li	a5,0
ffffffffc02033b0:	008cbc83          	ld	s9,8(s9)
        len++;
ffffffffc02033b4:	0785                	addi	a5,a5,1
    while ((le = list_next(le)) != listelm){
ffffffffc02033b6:	ff9d1de3          	bne	s10,s9,ffffffffc02033b0 <kmem_init+0x1a8>
    assert(list_length(&(cp0->slabs_free)) == 1);
ffffffffc02033ba:	4705                	li	a4,1
    int count = 0;
ffffffffc02033bc:	4d01                	li	s10,0
    assert(list_length(&(cp0->slabs_free)) == 1);
ffffffffc02033be:	22e79e63          	bne	a5,a4,ffffffffc02035fa <kmem_init+0x3f2>
ffffffffc02033c2:	85e2                	mv	a1,s8
ffffffffc02033c4:	008c3c03          	ld	s8,8(s8)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc02033c8:	15a1                	addi	a1,a1,-24
ffffffffc02033ca:	8552                	mv	a0,s4
ffffffffc02033cc:	951ff0ef          	jal	ra,ffffffffc0202d1c <kmem_slab_destroy>
        count++;
ffffffffc02033d0:	2d05                	addiw	s10,s10,1
    while (le != &(cachep->slabs_free))
ffffffffc02033d2:	ff8c98e3          	bne	s9,s8,ffffffffc02033c2 <kmem_init+0x1ba>
    assert(kmem_cache_shrink(cp0) == 1);    // 一共释放了1个slab
ffffffffc02033d6:	4785                	li	a5,1
ffffffffc02033d8:	12fd1163          	bne	s10,a5,ffffffffc02034fa <kmem_init+0x2f2>
    assert(nr_free_pages() + 1 == fp);      // 现在多了一个空闲页
ffffffffc02033dc:	f0cff0ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc02033e0:	00150793          	addi	a5,a0,1
ffffffffc02033e4:	24f99b63          	bne	s3,a5,ffffffffc020363a <kmem_init+0x432>
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
ffffffffc02033e8:	028a3783          	ld	a5,40(s4)
ffffffffc02033ec:	85a2                	mv	a1,s0
ffffffffc02033ee:	40040693          	addi	a3,s0,1024
        assert(p[i] == DEFAULT_DTVAL);
ffffffffc02033f2:	4705                	li	a4,1
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
ffffffffc02033f4:	28fc9363          	bne	s9,a5,ffffffffc020367a <kmem_init+0x472>
        assert(p[i] == DEFAULT_DTVAL);
ffffffffc02033f8:	0005c783          	lbu	a5,0(a1)
ffffffffc02033fc:	16e79f63          	bne	a5,a4,ffffffffc020357a <kmem_init+0x372>
    for (int i = 0; i < sizeof(struct test_object); i++){
ffffffffc0203400:	0585                	addi	a1,a1,1
ffffffffc0203402:	fed59be3          	bne	a1,a3,ffffffffc02033f8 <kmem_init+0x1f0>
    kmem_cache_free(cp0, p0);
ffffffffc0203406:	85de                	mv	a1,s7
ffffffffc0203408:	8552                	mv	a0,s4
ffffffffc020340a:	c55ff0ef          	jal	ra,ffffffffc020305e <kmem_cache_free>
    kmem_cache_free(cp0, p1);
ffffffffc020340e:	85da                	mv	a1,s6
ffffffffc0203410:	8552                	mv	a0,s4
ffffffffc0203412:	c4dff0ef          	jal	ra,ffffffffc020305e <kmem_cache_free>
    kmem_cache_free(cp0, p2);
ffffffffc0203416:	85a6                	mv	a1,s1
ffffffffc0203418:	8552                	mv	a0,s4
ffffffffc020341a:	c45ff0ef          	jal	ra,ffffffffc020305e <kmem_cache_free>
ffffffffc020341e:	00893c03          	ld	s8,8(s2)
    int count = 0;
ffffffffc0203422:	4c81                	li	s9,0
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0203424:	0f2c0b63          	beq	s8,s2,ffffffffc020351a <kmem_init+0x312>
ffffffffc0203428:	fd0c3403          	ld	s0,-48(s8)
    while (le != &(cachep->slabs_free))
ffffffffc020342c:	fc8c0b13          	addi	s6,s8,-56
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc0203430:	fa8c0b93          	addi	s7,s8,-88
    while (le != &(cachep->slabs_free))
ffffffffc0203434:	01640e63          	beq	s0,s6,ffffffffc0203450 <kmem_init+0x248>
    int count = 0;
ffffffffc0203438:	4481                	li	s1,0
ffffffffc020343a:	85a2                	mv	a1,s0
ffffffffc020343c:	6400                	ld	s0,8(s0)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc020343e:	15a1                	addi	a1,a1,-24
ffffffffc0203440:	855e                	mv	a0,s7
ffffffffc0203442:	8dbff0ef          	jal	ra,ffffffffc0202d1c <kmem_slab_destroy>
        count++;
ffffffffc0203446:	2485                	addiw	s1,s1,1
    while (le != &(cachep->slabs_free))
ffffffffc0203448:	ff6419e3          	bne	s0,s6,ffffffffc020343a <kmem_init+0x232>
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc020344c:	01948cbb          	addw	s9,s1,s9
ffffffffc0203450:	008c3c03          	ld	s8,8(s8)
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0203454:	fd2c1ae3          	bne	s8,s2,ffffffffc0203428 <kmem_init+0x220>
    assert(kmem_cache_reap() == 1);
ffffffffc0203458:	4785                	li	a5,1
ffffffffc020345a:	0cfc9063          	bne	s9,a5,ffffffffc020351a <kmem_init+0x312>
    assert(nr_free_pages() == fp);
ffffffffc020345e:	e8aff0ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0203462:	1ea99c63          	bne	s3,a0,ffffffffc020365a <kmem_init+0x452>
    kmem_cache_destroy(cp0);
ffffffffc0203466:	8552                	mv	a0,s4
ffffffffc0203468:	cc9ff0ef          	jal	ra,ffffffffc0203130 <kmem_cache_destroy>
    return kmem_cache_alloc(sized_caches[kmem_sized_index(size)]);
ffffffffc020346c:	030ab503          	ld	a0,48(s5)
ffffffffc0203470:	977ff0ef          	jal	ra,ffffffffc0202de6 <kmem_cache_alloc>
ffffffffc0203474:	842a                	mv	s0,a0
    assert((p0 = kmalloc(1024)) != NULL);
ffffffffc0203476:	28050263          	beqz	a0,ffffffffc02036fa <kmem_init+0x4f2>
    assert(nr_free_pages() + 1 == fp);
ffffffffc020347a:	e6eff0ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc020347e:	00150793          	addi	a5,a0,1
ffffffffc0203482:	18f99c63          	bne	s3,a5,ffffffffc020361a <kmem_init+0x412>
    kfree(p0);
ffffffffc0203486:	8522                	mv	a0,s0
ffffffffc0203488:	d15ff0ef          	jal	ra,ffffffffc020319c <kfree>
ffffffffc020348c:	00893b03          	ld	s6,8(s2)
    int count = 0;
ffffffffc0203490:	4b81                	li	s7,0
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0203492:	0b2b0463          	beq	s6,s2,ffffffffc020353a <kmem_init+0x332>
ffffffffc0203496:	fd0b3403          	ld	s0,-48(s6)
    while (le != &(cachep->slabs_free))
ffffffffc020349a:	fc8b0a13          	addi	s4,s6,-56
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc020349e:	fa8b0a93          	addi	s5,s6,-88
    while (le != &(cachep->slabs_free))
ffffffffc02034a2:	01440e63          	beq	s0,s4,ffffffffc02034be <kmem_init+0x2b6>
    int count = 0;
ffffffffc02034a6:	4481                	li	s1,0
ffffffffc02034a8:	85a2                	mv	a1,s0
ffffffffc02034aa:	6400                	ld	s0,8(s0)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc02034ac:	15a1                	addi	a1,a1,-24
ffffffffc02034ae:	8556                	mv	a0,s5
ffffffffc02034b0:	86dff0ef          	jal	ra,ffffffffc0202d1c <kmem_slab_destroy>
        count++;
ffffffffc02034b4:	2485                	addiw	s1,s1,1
    while (le != &(cachep->slabs_free))
ffffffffc02034b6:	ff4419e3          	bne	s0,s4,ffffffffc02034a8 <kmem_init+0x2a0>
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc02034ba:	01748bbb          	addw	s7,s1,s7
ffffffffc02034be:	008b3b03          	ld	s6,8(s6)
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc02034c2:	fd2b1ae3          	bne	s6,s2,ffffffffc0203496 <kmem_init+0x28e>
    assert(kmem_cache_reap() == 1);
ffffffffc02034c6:	4785                	li	a5,1
ffffffffc02034c8:	06fb9963          	bne	s7,a5,ffffffffc020353a <kmem_init+0x332>
    assert(nr_free_pages() == fp);
ffffffffc02034cc:	e1cff0ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc02034d0:	20a99563          	bne	s3,a0,ffffffffc02036da <kmem_init+0x4d2>
    }

    // 3. 进行测试
    check_kmem();
ffffffffc02034d4:	6446                	ld	s0,80(sp)
ffffffffc02034d6:	60e6                	ld	ra,88(sp)
ffffffffc02034d8:	64a6                	ld	s1,72(sp)
ffffffffc02034da:	6906                	ld	s2,64(sp)
ffffffffc02034dc:	79e2                	ld	s3,56(sp)
ffffffffc02034de:	7a42                	ld	s4,48(sp)
ffffffffc02034e0:	7aa2                	ld	s5,40(sp)
ffffffffc02034e2:	7b02                	ld	s6,32(sp)
ffffffffc02034e4:	6be2                	ld	s7,24(sp)
ffffffffc02034e6:	6c42                	ld	s8,16(sp)
ffffffffc02034e8:	6ca2                	ld	s9,8(sp)
ffffffffc02034ea:	6d02                	ld	s10,0(sp)
    cputs("[slub] check_kmem() succeeded, all test passed!\n");
ffffffffc02034ec:	00002517          	auipc	a0,0x2
ffffffffc02034f0:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205468 <default_pmm_manager+0x500>
ffffffffc02034f4:	6125                	addi	sp,sp,96
    cputs("[slub] check_kmem() succeeded, all test passed!\n");
ffffffffc02034f6:	c19fc06f          	j	ffffffffc020010e <cputs>
    assert(kmem_cache_shrink(cp0) == 1);    // 一共释放了1个slab
ffffffffc02034fa:	00002697          	auipc	a3,0x2
ffffffffc02034fe:	ea668693          	addi	a3,a3,-346 # ffffffffc02053a0 <default_pmm_manager+0x438>
ffffffffc0203502:	00001617          	auipc	a2,0x1
ffffffffc0203506:	00e60613          	addi	a2,a2,14 # ffffffffc0204510 <commands+0x500>
ffffffffc020350a:	12700593          	li	a1,295
ffffffffc020350e:	00002517          	auipc	a0,0x2
ffffffffc0203512:	bea50513          	addi	a0,a0,-1046 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203516:	ebbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(kmem_cache_reap() == 1);
ffffffffc020351a:	00002697          	auipc	a3,0x2
ffffffffc020351e:	efe68693          	addi	a3,a3,-258 # ffffffffc0205418 <default_pmm_manager+0x4b0>
ffffffffc0203522:	00001617          	auipc	a2,0x1
ffffffffc0203526:	fee60613          	addi	a2,a2,-18 # ffffffffc0204510 <commands+0x500>
ffffffffc020352a:	13400593          	li	a1,308
ffffffffc020352e:	00002517          	auipc	a0,0x2
ffffffffc0203532:	bca50513          	addi	a0,a0,-1078 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203536:	e9bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(kmem_cache_reap() == 1);
ffffffffc020353a:	00002697          	auipc	a3,0x2
ffffffffc020353e:	ede68693          	addi	a3,a3,-290 # ffffffffc0205418 <default_pmm_manager+0x4b0>
ffffffffc0203542:	00001617          	auipc	a2,0x1
ffffffffc0203546:	fce60613          	addi	a2,a2,-50 # ffffffffc0204510 <commands+0x500>
ffffffffc020354a:	14100593          	li	a1,321
ffffffffc020354e:	00002517          	auipc	a0,0x2
ffffffffc0203552:	baa50513          	addi	a0,a0,-1110 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203556:	e7bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
        assert(p[i] == DEFAULT_CTVAL);
ffffffffc020355a:	00002697          	auipc	a3,0x2
ffffffffc020355e:	d6e68693          	addi	a3,a3,-658 # ffffffffc02052c8 <default_pmm_manager+0x360>
ffffffffc0203562:	00001617          	auipc	a2,0x1
ffffffffc0203566:	fae60613          	addi	a2,a2,-82 # ffffffffc0204510 <commands+0x500>
ffffffffc020356a:	11800593          	li	a1,280
ffffffffc020356e:	00002517          	auipc	a0,0x2
ffffffffc0203572:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203576:	e5bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
        assert(p[i] == DEFAULT_DTVAL);
ffffffffc020357a:	00002697          	auipc	a3,0x2
ffffffffc020357e:	e8668693          	addi	a3,a3,-378 # ffffffffc0205400 <default_pmm_manager+0x498>
ffffffffc0203582:	00001617          	auipc	a2,0x1
ffffffffc0203586:	f8e60613          	addi	a2,a2,-114 # ffffffffc0204510 <commands+0x500>
ffffffffc020358a:	12d00593          	li	a1,301
ffffffffc020358e:	00002517          	auipc	a0,0x2
ffffffffc0203592:	b6a50513          	addi	a0,a0,-1174 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203596:	e3bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free_pages() + 2 == fp);
ffffffffc020359a:	00002697          	auipc	a3,0x2
ffffffffc020359e:	d4668693          	addi	a3,a3,-698 # ffffffffc02052e0 <default_pmm_manager+0x378>
ffffffffc02035a2:	00001617          	auipc	a2,0x1
ffffffffc02035a6:	f6e60613          	addi	a2,a2,-146 # ffffffffc0204510 <commands+0x500>
ffffffffc02035aa:	11b00593          	li	a1,283
ffffffffc02035ae:	00002517          	auipc	a0,0x2
ffffffffc02035b2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02035b6:	e1bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p5 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc02035ba:	00002697          	auipc	a3,0x2
ffffffffc02035be:	ce668693          	addi	a3,a3,-794 # ffffffffc02052a0 <default_pmm_manager+0x338>
ffffffffc02035c2:	00001617          	auipc	a2,0x1
ffffffffc02035c6:	f4e60613          	addi	a2,a2,-178 # ffffffffc0204510 <commands+0x500>
ffffffffc02035ca:	11300593          	li	a1,275
ffffffffc02035ce:	00002517          	auipc	a0,0x2
ffffffffc02035d2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02035d6:	dfbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc02035da:	00002697          	auipc	a3,0x2
ffffffffc02035de:	c9e68693          	addi	a3,a3,-866 # ffffffffc0205278 <default_pmm_manager+0x310>
ffffffffc02035e2:	00001617          	auipc	a2,0x1
ffffffffc02035e6:	f2e60613          	addi	a2,a2,-210 # ffffffffc0204510 <commands+0x500>
ffffffffc02035ea:	11200593          	li	a1,274
ffffffffc02035ee:	00002517          	auipc	a0,0x2
ffffffffc02035f2:	b0a50513          	addi	a0,a0,-1270 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02035f6:	ddbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(list_length(&(cp0->slabs_free)) == 1);
ffffffffc02035fa:	00002697          	auipc	a3,0x2
ffffffffc02035fe:	d7e68693          	addi	a3,a3,-642 # ffffffffc0205378 <default_pmm_manager+0x410>
ffffffffc0203602:	00001617          	auipc	a2,0x1
ffffffffc0203606:	f0e60613          	addi	a2,a2,-242 # ffffffffc0204510 <commands+0x500>
ffffffffc020360a:	12500593          	li	a1,293
ffffffffc020360e:	00002517          	auipc	a0,0x2
ffffffffc0203612:	aea50513          	addi	a0,a0,-1302 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203616:	dbbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free_pages() + 1 == fp);
ffffffffc020361a:	00002697          	auipc	a3,0x2
ffffffffc020361e:	da668693          	addi	a3,a3,-602 # ffffffffc02053c0 <default_pmm_manager+0x458>
ffffffffc0203622:	00001617          	auipc	a2,0x1
ffffffffc0203626:	eee60613          	addi	a2,a2,-274 # ffffffffc0204510 <commands+0x500>
ffffffffc020362a:	13d00593          	li	a1,317
ffffffffc020362e:	00002517          	auipc	a0,0x2
ffffffffc0203632:	aca50513          	addi	a0,a0,-1334 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203636:	d9bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free_pages() + 1 == fp);      // 现在多了一个空闲页
ffffffffc020363a:	00002697          	auipc	a3,0x2
ffffffffc020363e:	d8668693          	addi	a3,a3,-634 # ffffffffc02053c0 <default_pmm_manager+0x458>
ffffffffc0203642:	00001617          	auipc	a2,0x1
ffffffffc0203646:	ece60613          	addi	a2,a2,-306 # ffffffffc0204510 <commands+0x500>
ffffffffc020364a:	12800593          	li	a1,296
ffffffffc020364e:	00002517          	auipc	a0,0x2
ffffffffc0203652:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203656:	d7bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free_pages() == fp);
ffffffffc020365a:	00002697          	auipc	a3,0x2
ffffffffc020365e:	dd668693          	addi	a3,a3,-554 # ffffffffc0205430 <default_pmm_manager+0x4c8>
ffffffffc0203662:	00001617          	auipc	a2,0x1
ffffffffc0203666:	eae60613          	addi	a2,a2,-338 # ffffffffc0204510 <commands+0x500>
ffffffffc020366a:	13600593          	li	a1,310
ffffffffc020366e:	00002517          	auipc	a0,0x2
ffffffffc0203672:	a8a50513          	addi	a0,a0,-1398 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203676:	d5bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
ffffffffc020367a:	00002697          	auipc	a3,0x2
ffffffffc020367e:	d6668693          	addi	a3,a3,-666 # ffffffffc02053e0 <default_pmm_manager+0x478>
ffffffffc0203682:	00001617          	auipc	a2,0x1
ffffffffc0203686:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204510 <commands+0x500>
ffffffffc020368a:	12900593          	li	a1,297
ffffffffc020368e:	00002517          	auipc	a0,0x2
ffffffffc0203692:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203696:	d3bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));  // 对象大小一致
ffffffffc020369a:	00002697          	auipc	a3,0x2
ffffffffc020369e:	ace68693          	addi	a3,a3,-1330 # ffffffffc0205168 <default_pmm_manager+0x200>
ffffffffc02036a2:	00001617          	auipc	a2,0x1
ffffffffc02036a6:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204510 <commands+0x500>
ffffffffc02036aa:	10900593          	li	a1,265
ffffffffc02036ae:	00002517          	auipc	a0,0x2
ffffffffc02036b2:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02036b6:	d1bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(cp0 != NULL);                                         // 创建成功
ffffffffc02036ba:	00002697          	auipc	a3,0x2
ffffffffc02036be:	a9e68693          	addi	a3,a3,-1378 # ffffffffc0205158 <default_pmm_manager+0x1f0>
ffffffffc02036c2:	00001617          	auipc	a2,0x1
ffffffffc02036c6:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204510 <commands+0x500>
ffffffffc02036ca:	10800593          	li	a1,264
ffffffffc02036ce:	00002517          	auipc	a0,0x2
ffffffffc02036d2:	a2a50513          	addi	a0,a0,-1494 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02036d6:	cfbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(nr_free_pages() == fp);
ffffffffc02036da:	00002697          	auipc	a3,0x2
ffffffffc02036de:	d5668693          	addi	a3,a3,-682 # ffffffffc0205430 <default_pmm_manager+0x4c8>
ffffffffc02036e2:	00001617          	auipc	a2,0x1
ffffffffc02036e6:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204510 <commands+0x500>
ffffffffc02036ea:	14300593          	li	a1,323
ffffffffc02036ee:	00002517          	auipc	a0,0x2
ffffffffc02036f2:	a0a50513          	addi	a0,a0,-1526 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02036f6:	cdbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = kmalloc(1024)) != NULL);
ffffffffc02036fa:	00002697          	auipc	a3,0x2
ffffffffc02036fe:	d4e68693          	addi	a3,a3,-690 # ffffffffc0205448 <default_pmm_manager+0x4e0>
ffffffffc0203702:	00001617          	auipc	a2,0x1
ffffffffc0203706:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204510 <commands+0x500>
ffffffffc020370a:	13b00593          	li	a1,315
ffffffffc020370e:	00002517          	auipc	a0,0x2
ffffffffc0203712:	9ea50513          	addi	a0,a0,-1558 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203716:	cbbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(list_empty(&(cp0->slabs_free)) == 1);
ffffffffc020371a:	00002697          	auipc	a3,0x2
ffffffffc020371e:	c3668693          	addi	a3,a3,-970 # ffffffffc0205350 <default_pmm_manager+0x3e8>
ffffffffc0203722:	00001617          	auipc	a2,0x1
ffffffffc0203726:	dee60613          	addi	a2,a2,-530 # ffffffffc0204510 <commands+0x500>
ffffffffc020372a:	12000593          	li	a1,288
ffffffffc020372e:	00002517          	auipc	a0,0x2
ffffffffc0203732:	9ca50513          	addi	a0,a0,-1590 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203736:	c9bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(list_empty(&(cp0->slabs_partial)) == 1);
ffffffffc020373a:	00002697          	auipc	a3,0x2
ffffffffc020373e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0205328 <default_pmm_manager+0x3c0>
ffffffffc0203742:	00001617          	auipc	a2,0x1
ffffffffc0203746:	dce60613          	addi	a2,a2,-562 # ffffffffc0204510 <commands+0x500>
ffffffffc020374a:	11f00593          	li	a1,287
ffffffffc020374e:	00002517          	auipc	a0,0x2
ffffffffc0203752:	9aa50513          	addi	a0,a0,-1622 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203756:	c7bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(list_length(&(cp0->slabs_full)) == 2);
ffffffffc020375a:	00002697          	auipc	a3,0x2
ffffffffc020375e:	ba668693          	addi	a3,a3,-1114 # ffffffffc0205300 <default_pmm_manager+0x398>
ffffffffc0203762:	00001617          	auipc	a2,0x1
ffffffffc0203766:	dae60613          	addi	a2,a2,-594 # ffffffffc0204510 <commands+0x500>
ffffffffc020376a:	11d00593          	li	a1,285
ffffffffc020376e:	00002517          	auipc	a0,0x2
ffffffffc0203772:	98a50513          	addi	a0,a0,-1654 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203776:	c5bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc020377a:	00002697          	auipc	a3,0x2
ffffffffc020377e:	ad668693          	addi	a3,a3,-1322 # ffffffffc0205250 <default_pmm_manager+0x2e8>
ffffffffc0203782:	00001617          	auipc	a2,0x1
ffffffffc0203786:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204510 <commands+0x500>
ffffffffc020378a:	11100593          	li	a1,273
ffffffffc020378e:	00002517          	auipc	a0,0x2
ffffffffc0203792:	96a50513          	addi	a0,a0,-1686 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203796:	c3bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc020379a:	00002697          	auipc	a3,0x2
ffffffffc020379e:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0205228 <default_pmm_manager+0x2c0>
ffffffffc02037a2:	00001617          	auipc	a2,0x1
ffffffffc02037a6:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204510 <commands+0x500>
ffffffffc02037aa:	11000593          	li	a1,272
ffffffffc02037ae:	00002517          	auipc	a0,0x2
ffffffffc02037b2:	94a50513          	addi	a0,a0,-1718 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02037b6:	c1bfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc02037ba:	00002697          	auipc	a3,0x2
ffffffffc02037be:	a4668693          	addi	a3,a3,-1466 # ffffffffc0205200 <default_pmm_manager+0x298>
ffffffffc02037c2:	00001617          	auipc	a2,0x1
ffffffffc02037c6:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204510 <commands+0x500>
ffffffffc02037ca:	10f00593          	li	a1,271
ffffffffc02037ce:	00002517          	auipc	a0,0x2
ffffffffc02037d2:	92a50513          	addi	a0,a0,-1750 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02037d6:	bfbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc02037da:	00002697          	auipc	a3,0x2
ffffffffc02037de:	9fe68693          	addi	a3,a3,-1538 # ffffffffc02051d8 <default_pmm_manager+0x270>
ffffffffc02037e2:	00001617          	auipc	a2,0x1
ffffffffc02037e6:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204510 <commands+0x500>
ffffffffc02037ea:	10e00593          	li	a1,270
ffffffffc02037ee:	00002517          	auipc	a0,0x2
ffffffffc02037f2:	90a50513          	addi	a0,a0,-1782 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc02037f6:	bdbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0); // 名字一样
ffffffffc02037fa:	00002697          	auipc	a3,0x2
ffffffffc02037fe:	9a668693          	addi	a3,a3,-1626 # ffffffffc02051a0 <default_pmm_manager+0x238>
ffffffffc0203802:	00001617          	auipc	a2,0x1
ffffffffc0203806:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204510 <commands+0x500>
ffffffffc020380a:	10a00593          	li	a1,266
ffffffffc020380e:	00002517          	auipc	a0,0x2
ffffffffc0203812:	8ea50513          	addi	a0,a0,-1814 # ffffffffc02050f8 <default_pmm_manager+0x190>
ffffffffc0203816:	bbbfc0ef          	jal	ra,ffffffffc02003d0 <__panic>

ffffffffc020381a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020381a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020381e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203820:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203824:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203826:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020382a:	f022                	sd	s0,32(sp)
ffffffffc020382c:	ec26                	sd	s1,24(sp)
ffffffffc020382e:	e84a                	sd	s2,16(sp)
ffffffffc0203830:	f406                	sd	ra,40(sp)
ffffffffc0203832:	e44e                	sd	s3,8(sp)
ffffffffc0203834:	84aa                	mv	s1,a0
ffffffffc0203836:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203838:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020383c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020383e:	03067e63          	bgeu	a2,a6,ffffffffc020387a <printnum+0x60>
ffffffffc0203842:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203844:	00805763          	blez	s0,ffffffffc0203852 <printnum+0x38>
ffffffffc0203848:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020384a:	85ca                	mv	a1,s2
ffffffffc020384c:	854e                	mv	a0,s3
ffffffffc020384e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203850:	fc65                	bnez	s0,ffffffffc0203848 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203852:	1a02                	slli	s4,s4,0x20
ffffffffc0203854:	00002797          	auipc	a5,0x2
ffffffffc0203858:	c4c78793          	addi	a5,a5,-948 # ffffffffc02054a0 <default_pmm_manager+0x538>
ffffffffc020385c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203860:	9a3e                	add	s4,s4,a5
}
ffffffffc0203862:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203864:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203868:	70a2                	ld	ra,40(sp)
ffffffffc020386a:	69a2                	ld	s3,8(sp)
ffffffffc020386c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020386e:	85ca                	mv	a1,s2
ffffffffc0203870:	87a6                	mv	a5,s1
}
ffffffffc0203872:	6942                	ld	s2,16(sp)
ffffffffc0203874:	64e2                	ld	s1,24(sp)
ffffffffc0203876:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203878:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020387a:	03065633          	divu	a2,a2,a6
ffffffffc020387e:	8722                	mv	a4,s0
ffffffffc0203880:	f9bff0ef          	jal	ra,ffffffffc020381a <printnum>
ffffffffc0203884:	b7f9                	j	ffffffffc0203852 <printnum+0x38>

ffffffffc0203886 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203886:	7119                	addi	sp,sp,-128
ffffffffc0203888:	f4a6                	sd	s1,104(sp)
ffffffffc020388a:	f0ca                	sd	s2,96(sp)
ffffffffc020388c:	ecce                	sd	s3,88(sp)
ffffffffc020388e:	e8d2                	sd	s4,80(sp)
ffffffffc0203890:	e4d6                	sd	s5,72(sp)
ffffffffc0203892:	e0da                	sd	s6,64(sp)
ffffffffc0203894:	fc5e                	sd	s7,56(sp)
ffffffffc0203896:	f06a                	sd	s10,32(sp)
ffffffffc0203898:	fc86                	sd	ra,120(sp)
ffffffffc020389a:	f8a2                	sd	s0,112(sp)
ffffffffc020389c:	f862                	sd	s8,48(sp)
ffffffffc020389e:	f466                	sd	s9,40(sp)
ffffffffc02038a0:	ec6e                	sd	s11,24(sp)
ffffffffc02038a2:	892a                	mv	s2,a0
ffffffffc02038a4:	84ae                	mv	s1,a1
ffffffffc02038a6:	8d32                	mv	s10,a2
ffffffffc02038a8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02038aa:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02038ae:	5b7d                	li	s6,-1
ffffffffc02038b0:	00002a97          	auipc	s5,0x2
ffffffffc02038b4:	c24a8a93          	addi	s5,s5,-988 # ffffffffc02054d4 <default_pmm_manager+0x56c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02038b8:	00002b97          	auipc	s7,0x2
ffffffffc02038bc:	df8b8b93          	addi	s7,s7,-520 # ffffffffc02056b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02038c0:	000d4503          	lbu	a0,0(s10)
ffffffffc02038c4:	001d0413          	addi	s0,s10,1
ffffffffc02038c8:	01350a63          	beq	a0,s3,ffffffffc02038dc <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02038cc:	c121                	beqz	a0,ffffffffc020390c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02038ce:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02038d0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02038d2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02038d4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02038d8:	ff351ae3          	bne	a0,s3,ffffffffc02038cc <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02038dc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02038e0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02038e4:	4c81                	li	s9,0
ffffffffc02038e6:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02038e8:	5c7d                	li	s8,-1
ffffffffc02038ea:	5dfd                	li	s11,-1
ffffffffc02038ec:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02038f0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02038f2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02038f6:	0ff5f593          	zext.b	a1,a1
ffffffffc02038fa:	00140d13          	addi	s10,s0,1
ffffffffc02038fe:	04b56263          	bltu	a0,a1,ffffffffc0203942 <vprintfmt+0xbc>
ffffffffc0203902:	058a                	slli	a1,a1,0x2
ffffffffc0203904:	95d6                	add	a1,a1,s5
ffffffffc0203906:	4194                	lw	a3,0(a1)
ffffffffc0203908:	96d6                	add	a3,a3,s5
ffffffffc020390a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020390c:	70e6                	ld	ra,120(sp)
ffffffffc020390e:	7446                	ld	s0,112(sp)
ffffffffc0203910:	74a6                	ld	s1,104(sp)
ffffffffc0203912:	7906                	ld	s2,96(sp)
ffffffffc0203914:	69e6                	ld	s3,88(sp)
ffffffffc0203916:	6a46                	ld	s4,80(sp)
ffffffffc0203918:	6aa6                	ld	s5,72(sp)
ffffffffc020391a:	6b06                	ld	s6,64(sp)
ffffffffc020391c:	7be2                	ld	s7,56(sp)
ffffffffc020391e:	7c42                	ld	s8,48(sp)
ffffffffc0203920:	7ca2                	ld	s9,40(sp)
ffffffffc0203922:	7d02                	ld	s10,32(sp)
ffffffffc0203924:	6de2                	ld	s11,24(sp)
ffffffffc0203926:	6109                	addi	sp,sp,128
ffffffffc0203928:	8082                	ret
            padc = '0';
ffffffffc020392a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020392c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203930:	846a                	mv	s0,s10
ffffffffc0203932:	00140d13          	addi	s10,s0,1
ffffffffc0203936:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020393a:	0ff5f593          	zext.b	a1,a1
ffffffffc020393e:	fcb572e3          	bgeu	a0,a1,ffffffffc0203902 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203942:	85a6                	mv	a1,s1
ffffffffc0203944:	02500513          	li	a0,37
ffffffffc0203948:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020394a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020394e:	8d22                	mv	s10,s0
ffffffffc0203950:	f73788e3          	beq	a5,s3,ffffffffc02038c0 <vprintfmt+0x3a>
ffffffffc0203954:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203958:	1d7d                	addi	s10,s10,-1
ffffffffc020395a:	ff379de3          	bne	a5,s3,ffffffffc0203954 <vprintfmt+0xce>
ffffffffc020395e:	b78d                	j	ffffffffc02038c0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203960:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203964:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203968:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020396a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020396e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203972:	02d86463          	bltu	a6,a3,ffffffffc020399a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203976:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020397a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020397e:	0186873b          	addw	a4,a3,s8
ffffffffc0203982:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203986:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203988:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020398c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020398e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203992:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203996:	fed870e3          	bgeu	a6,a3,ffffffffc0203976 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020399a:	f40ddce3          	bgez	s11,ffffffffc02038f2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020399e:	8de2                	mv	s11,s8
ffffffffc02039a0:	5c7d                	li	s8,-1
ffffffffc02039a2:	bf81                	j	ffffffffc02038f2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02039a4:	fffdc693          	not	a3,s11
ffffffffc02039a8:	96fd                	srai	a3,a3,0x3f
ffffffffc02039aa:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02039ae:	00144603          	lbu	a2,1(s0)
ffffffffc02039b2:	2d81                	sext.w	s11,s11
ffffffffc02039b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02039b6:	bf35                	j	ffffffffc02038f2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02039b8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02039bc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02039c0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02039c2:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02039c4:	bfd9                	j	ffffffffc020399a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02039c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02039c8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02039cc:	01174463          	blt	a4,a7,ffffffffc02039d4 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02039d0:	1a088e63          	beqz	a7,ffffffffc0203b8c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02039d4:	000a3603          	ld	a2,0(s4)
ffffffffc02039d8:	46c1                	li	a3,16
ffffffffc02039da:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02039dc:	2781                	sext.w	a5,a5
ffffffffc02039de:	876e                	mv	a4,s11
ffffffffc02039e0:	85a6                	mv	a1,s1
ffffffffc02039e2:	854a                	mv	a0,s2
ffffffffc02039e4:	e37ff0ef          	jal	ra,ffffffffc020381a <printnum>
            break;
ffffffffc02039e8:	bde1                	j	ffffffffc02038c0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02039ea:	000a2503          	lw	a0,0(s4)
ffffffffc02039ee:	85a6                	mv	a1,s1
ffffffffc02039f0:	0a21                	addi	s4,s4,8
ffffffffc02039f2:	9902                	jalr	s2
            break;
ffffffffc02039f4:	b5f1                	j	ffffffffc02038c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02039f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02039f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02039fc:	01174463          	blt	a4,a7,ffffffffc0203a04 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203a00:	18088163          	beqz	a7,ffffffffc0203b82 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203a04:	000a3603          	ld	a2,0(s4)
ffffffffc0203a08:	46a9                	li	a3,10
ffffffffc0203a0a:	8a2e                	mv	s4,a1
ffffffffc0203a0c:	bfc1                	j	ffffffffc02039dc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203a0e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203a12:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203a14:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203a16:	bdf1                	j	ffffffffc02038f2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203a18:	85a6                	mv	a1,s1
ffffffffc0203a1a:	02500513          	li	a0,37
ffffffffc0203a1e:	9902                	jalr	s2
            break;
ffffffffc0203a20:	b545                	j	ffffffffc02038c0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203a22:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0203a26:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203a28:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203a2a:	b5e1                	j	ffffffffc02038f2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0203a2c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203a2e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203a32:	01174463          	blt	a4,a7,ffffffffc0203a3a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0203a36:	14088163          	beqz	a7,ffffffffc0203b78 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0203a3a:	000a3603          	ld	a2,0(s4)
ffffffffc0203a3e:	46a1                	li	a3,8
ffffffffc0203a40:	8a2e                	mv	s4,a1
ffffffffc0203a42:	bf69                	j	ffffffffc02039dc <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0203a44:	03000513          	li	a0,48
ffffffffc0203a48:	85a6                	mv	a1,s1
ffffffffc0203a4a:	e03e                	sd	a5,0(sp)
ffffffffc0203a4c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203a4e:	85a6                	mv	a1,s1
ffffffffc0203a50:	07800513          	li	a0,120
ffffffffc0203a54:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203a56:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203a58:	6782                	ld	a5,0(sp)
ffffffffc0203a5a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203a5c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0203a60:	bfb5                	j	ffffffffc02039dc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203a62:	000a3403          	ld	s0,0(s4)
ffffffffc0203a66:	008a0713          	addi	a4,s4,8
ffffffffc0203a6a:	e03a                	sd	a4,0(sp)
ffffffffc0203a6c:	14040263          	beqz	s0,ffffffffc0203bb0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0203a70:	0fb05763          	blez	s11,ffffffffc0203b5e <vprintfmt+0x2d8>
ffffffffc0203a74:	02d00693          	li	a3,45
ffffffffc0203a78:	0cd79163          	bne	a5,a3,ffffffffc0203b3a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203a7c:	00044783          	lbu	a5,0(s0)
ffffffffc0203a80:	0007851b          	sext.w	a0,a5
ffffffffc0203a84:	cf85                	beqz	a5,ffffffffc0203abc <vprintfmt+0x236>
ffffffffc0203a86:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203a8a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203a8e:	000c4563          	bltz	s8,ffffffffc0203a98 <vprintfmt+0x212>
ffffffffc0203a92:	3c7d                	addiw	s8,s8,-1
ffffffffc0203a94:	036c0263          	beq	s8,s6,ffffffffc0203ab8 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0203a98:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203a9a:	0e0c8e63          	beqz	s9,ffffffffc0203b96 <vprintfmt+0x310>
ffffffffc0203a9e:	3781                	addiw	a5,a5,-32
ffffffffc0203aa0:	0ef47b63          	bgeu	s0,a5,ffffffffc0203b96 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0203aa4:	03f00513          	li	a0,63
ffffffffc0203aa8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203aaa:	000a4783          	lbu	a5,0(s4)
ffffffffc0203aae:	3dfd                	addiw	s11,s11,-1
ffffffffc0203ab0:	0a05                	addi	s4,s4,1
ffffffffc0203ab2:	0007851b          	sext.w	a0,a5
ffffffffc0203ab6:	ffe1                	bnez	a5,ffffffffc0203a8e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0203ab8:	01b05963          	blez	s11,ffffffffc0203aca <vprintfmt+0x244>
ffffffffc0203abc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203abe:	85a6                	mv	a1,s1
ffffffffc0203ac0:	02000513          	li	a0,32
ffffffffc0203ac4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ac6:	fe0d9be3          	bnez	s11,ffffffffc0203abc <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203aca:	6a02                	ld	s4,0(sp)
ffffffffc0203acc:	bbd5                	j	ffffffffc02038c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203ace:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203ad0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0203ad4:	01174463          	blt	a4,a7,ffffffffc0203adc <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0203ad8:	08088d63          	beqz	a7,ffffffffc0203b72 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0203adc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203ae0:	0a044d63          	bltz	s0,ffffffffc0203b9a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0203ae4:	8622                	mv	a2,s0
ffffffffc0203ae6:	8a66                	mv	s4,s9
ffffffffc0203ae8:	46a9                	li	a3,10
ffffffffc0203aea:	bdcd                	j	ffffffffc02039dc <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0203aec:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203af0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203af2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203af4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203af8:	8fb5                	xor	a5,a5,a3
ffffffffc0203afa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203afe:	02d74163          	blt	a4,a3,ffffffffc0203b20 <vprintfmt+0x29a>
ffffffffc0203b02:	00369793          	slli	a5,a3,0x3
ffffffffc0203b06:	97de                	add	a5,a5,s7
ffffffffc0203b08:	639c                	ld	a5,0(a5)
ffffffffc0203b0a:	cb99                	beqz	a5,ffffffffc0203b20 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203b0c:	86be                	mv	a3,a5
ffffffffc0203b0e:	00002617          	auipc	a2,0x2
ffffffffc0203b12:	9c260613          	addi	a2,a2,-1598 # ffffffffc02054d0 <default_pmm_manager+0x568>
ffffffffc0203b16:	85a6                	mv	a1,s1
ffffffffc0203b18:	854a                	mv	a0,s2
ffffffffc0203b1a:	0ce000ef          	jal	ra,ffffffffc0203be8 <printfmt>
ffffffffc0203b1e:	b34d                	j	ffffffffc02038c0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203b20:	00002617          	auipc	a2,0x2
ffffffffc0203b24:	9a060613          	addi	a2,a2,-1632 # ffffffffc02054c0 <default_pmm_manager+0x558>
ffffffffc0203b28:	85a6                	mv	a1,s1
ffffffffc0203b2a:	854a                	mv	a0,s2
ffffffffc0203b2c:	0bc000ef          	jal	ra,ffffffffc0203be8 <printfmt>
ffffffffc0203b30:	bb41                	j	ffffffffc02038c0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203b32:	00002417          	auipc	s0,0x2
ffffffffc0203b36:	98640413          	addi	s0,s0,-1658 # ffffffffc02054b8 <default_pmm_manager+0x550>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203b3a:	85e2                	mv	a1,s8
ffffffffc0203b3c:	8522                	mv	a0,s0
ffffffffc0203b3e:	e43e                	sd	a5,8(sp)
ffffffffc0203b40:	1cc000ef          	jal	ra,ffffffffc0203d0c <strnlen>
ffffffffc0203b44:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203b48:	01b05b63          	blez	s11,ffffffffc0203b5e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0203b4c:	67a2                	ld	a5,8(sp)
ffffffffc0203b4e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203b52:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203b54:	85a6                	mv	a1,s1
ffffffffc0203b56:	8552                	mv	a0,s4
ffffffffc0203b58:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203b5a:	fe0d9ce3          	bnez	s11,ffffffffc0203b52 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203b5e:	00044783          	lbu	a5,0(s0)
ffffffffc0203b62:	00140a13          	addi	s4,s0,1
ffffffffc0203b66:	0007851b          	sext.w	a0,a5
ffffffffc0203b6a:	d3a5                	beqz	a5,ffffffffc0203aca <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203b6c:	05e00413          	li	s0,94
ffffffffc0203b70:	bf39                	j	ffffffffc0203a8e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0203b72:	000a2403          	lw	s0,0(s4)
ffffffffc0203b76:	b7ad                	j	ffffffffc0203ae0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0203b78:	000a6603          	lwu	a2,0(s4)
ffffffffc0203b7c:	46a1                	li	a3,8
ffffffffc0203b7e:	8a2e                	mv	s4,a1
ffffffffc0203b80:	bdb1                	j	ffffffffc02039dc <vprintfmt+0x156>
ffffffffc0203b82:	000a6603          	lwu	a2,0(s4)
ffffffffc0203b86:	46a9                	li	a3,10
ffffffffc0203b88:	8a2e                	mv	s4,a1
ffffffffc0203b8a:	bd89                	j	ffffffffc02039dc <vprintfmt+0x156>
ffffffffc0203b8c:	000a6603          	lwu	a2,0(s4)
ffffffffc0203b90:	46c1                	li	a3,16
ffffffffc0203b92:	8a2e                	mv	s4,a1
ffffffffc0203b94:	b5a1                	j	ffffffffc02039dc <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0203b96:	9902                	jalr	s2
ffffffffc0203b98:	bf09                	j	ffffffffc0203aaa <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0203b9a:	85a6                	mv	a1,s1
ffffffffc0203b9c:	02d00513          	li	a0,45
ffffffffc0203ba0:	e03e                	sd	a5,0(sp)
ffffffffc0203ba2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203ba4:	6782                	ld	a5,0(sp)
ffffffffc0203ba6:	8a66                	mv	s4,s9
ffffffffc0203ba8:	40800633          	neg	a2,s0
ffffffffc0203bac:	46a9                	li	a3,10
ffffffffc0203bae:	b53d                	j	ffffffffc02039dc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0203bb0:	03b05163          	blez	s11,ffffffffc0203bd2 <vprintfmt+0x34c>
ffffffffc0203bb4:	02d00693          	li	a3,45
ffffffffc0203bb8:	f6d79de3          	bne	a5,a3,ffffffffc0203b32 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0203bbc:	00002417          	auipc	s0,0x2
ffffffffc0203bc0:	8fc40413          	addi	s0,s0,-1796 # ffffffffc02054b8 <default_pmm_manager+0x550>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203bc4:	02800793          	li	a5,40
ffffffffc0203bc8:	02800513          	li	a0,40
ffffffffc0203bcc:	00140a13          	addi	s4,s0,1
ffffffffc0203bd0:	bd6d                	j	ffffffffc0203a8a <vprintfmt+0x204>
ffffffffc0203bd2:	00002a17          	auipc	s4,0x2
ffffffffc0203bd6:	8e7a0a13          	addi	s4,s4,-1817 # ffffffffc02054b9 <default_pmm_manager+0x551>
ffffffffc0203bda:	02800513          	li	a0,40
ffffffffc0203bde:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203be2:	05e00413          	li	s0,94
ffffffffc0203be6:	b565                	j	ffffffffc0203a8e <vprintfmt+0x208>

ffffffffc0203be8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203be8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203bea:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203bee:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203bf0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203bf2:	ec06                	sd	ra,24(sp)
ffffffffc0203bf4:	f83a                	sd	a4,48(sp)
ffffffffc0203bf6:	fc3e                	sd	a5,56(sp)
ffffffffc0203bf8:	e0c2                	sd	a6,64(sp)
ffffffffc0203bfa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203bfc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203bfe:	c89ff0ef          	jal	ra,ffffffffc0203886 <vprintfmt>
}
ffffffffc0203c02:	60e2                	ld	ra,24(sp)
ffffffffc0203c04:	6161                	addi	sp,sp,80
ffffffffc0203c06:	8082                	ret

ffffffffc0203c08 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0203c08:	715d                	addi	sp,sp,-80
ffffffffc0203c0a:	e486                	sd	ra,72(sp)
ffffffffc0203c0c:	e0a6                	sd	s1,64(sp)
ffffffffc0203c0e:	fc4a                	sd	s2,56(sp)
ffffffffc0203c10:	f84e                	sd	s3,48(sp)
ffffffffc0203c12:	f452                	sd	s4,40(sp)
ffffffffc0203c14:	f056                	sd	s5,32(sp)
ffffffffc0203c16:	ec5a                	sd	s6,24(sp)
ffffffffc0203c18:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0203c1a:	c901                	beqz	a0,ffffffffc0203c2a <readline+0x22>
ffffffffc0203c1c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0203c1e:	00002517          	auipc	a0,0x2
ffffffffc0203c22:	8b250513          	addi	a0,a0,-1870 # ffffffffc02054d0 <default_pmm_manager+0x568>
ffffffffc0203c26:	cb0fc0ef          	jal	ra,ffffffffc02000d6 <cprintf>
readline(const char *prompt) {
ffffffffc0203c2a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203c2c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0203c2e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0203c30:	4aa9                	li	s5,10
ffffffffc0203c32:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0203c34:	00005b97          	auipc	s7,0x5
ffffffffc0203c38:	4acb8b93          	addi	s7,s7,1196 # ffffffffc02090e0 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203c3c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0203c40:	d0efc0ef          	jal	ra,ffffffffc020014e <getchar>
        if (c < 0) {
ffffffffc0203c44:	00054a63          	bltz	a0,ffffffffc0203c58 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203c48:	00a95a63          	bge	s2,a0,ffffffffc0203c5c <readline+0x54>
ffffffffc0203c4c:	029a5263          	bge	s4,s1,ffffffffc0203c70 <readline+0x68>
        c = getchar();
ffffffffc0203c50:	cfefc0ef          	jal	ra,ffffffffc020014e <getchar>
        if (c < 0) {
ffffffffc0203c54:	fe055ae3          	bgez	a0,ffffffffc0203c48 <readline+0x40>
            return NULL;
ffffffffc0203c58:	4501                	li	a0,0
ffffffffc0203c5a:	a091                	j	ffffffffc0203c9e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0203c5c:	03351463          	bne	a0,s3,ffffffffc0203c84 <readline+0x7c>
ffffffffc0203c60:	e8a9                	bnez	s1,ffffffffc0203cb2 <readline+0xaa>
        c = getchar();
ffffffffc0203c62:	cecfc0ef          	jal	ra,ffffffffc020014e <getchar>
        if (c < 0) {
ffffffffc0203c66:	fe0549e3          	bltz	a0,ffffffffc0203c58 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203c6a:	fea959e3          	bge	s2,a0,ffffffffc0203c5c <readline+0x54>
ffffffffc0203c6e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0203c70:	e42a                	sd	a0,8(sp)
ffffffffc0203c72:	c9afc0ef          	jal	ra,ffffffffc020010c <cputchar>
            buf[i ++] = c;
ffffffffc0203c76:	6522                	ld	a0,8(sp)
ffffffffc0203c78:	009b87b3          	add	a5,s7,s1
ffffffffc0203c7c:	2485                	addiw	s1,s1,1
ffffffffc0203c7e:	00a78023          	sb	a0,0(a5)
ffffffffc0203c82:	bf7d                	j	ffffffffc0203c40 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0203c84:	01550463          	beq	a0,s5,ffffffffc0203c8c <readline+0x84>
ffffffffc0203c88:	fb651ce3          	bne	a0,s6,ffffffffc0203c40 <readline+0x38>
            cputchar(c);
ffffffffc0203c8c:	c80fc0ef          	jal	ra,ffffffffc020010c <cputchar>
            buf[i] = '\0';
ffffffffc0203c90:	00005517          	auipc	a0,0x5
ffffffffc0203c94:	45050513          	addi	a0,a0,1104 # ffffffffc02090e0 <buf>
ffffffffc0203c98:	94aa                	add	s1,s1,a0
ffffffffc0203c9a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0203c9e:	60a6                	ld	ra,72(sp)
ffffffffc0203ca0:	6486                	ld	s1,64(sp)
ffffffffc0203ca2:	7962                	ld	s2,56(sp)
ffffffffc0203ca4:	79c2                	ld	s3,48(sp)
ffffffffc0203ca6:	7a22                	ld	s4,40(sp)
ffffffffc0203ca8:	7a82                	ld	s5,32(sp)
ffffffffc0203caa:	6b62                	ld	s6,24(sp)
ffffffffc0203cac:	6bc2                	ld	s7,16(sp)
ffffffffc0203cae:	6161                	addi	sp,sp,80
ffffffffc0203cb0:	8082                	ret
            cputchar(c);
ffffffffc0203cb2:	4521                	li	a0,8
ffffffffc0203cb4:	c58fc0ef          	jal	ra,ffffffffc020010c <cputchar>
            i --;
ffffffffc0203cb8:	34fd                	addiw	s1,s1,-1
ffffffffc0203cba:	b759                	j	ffffffffc0203c40 <readline+0x38>

ffffffffc0203cbc <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0203cbc:	4781                	li	a5,0
ffffffffc0203cbe:	00005717          	auipc	a4,0x5
ffffffffc0203cc2:	34a73703          	ld	a4,842(a4) # ffffffffc0209008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0203cc6:	88ba                	mv	a7,a4
ffffffffc0203cc8:	852a                	mv	a0,a0
ffffffffc0203cca:	85be                	mv	a1,a5
ffffffffc0203ccc:	863e                	mv	a2,a5
ffffffffc0203cce:	00000073          	ecall
ffffffffc0203cd2:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0203cd4:	8082                	ret

ffffffffc0203cd6 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0203cd6:	4781                	li	a5,0
ffffffffc0203cd8:	00006717          	auipc	a4,0x6
ffffffffc0203cdc:	88073703          	ld	a4,-1920(a4) # ffffffffc0209558 <SBI_SET_TIMER>
ffffffffc0203ce0:	88ba                	mv	a7,a4
ffffffffc0203ce2:	852a                	mv	a0,a0
ffffffffc0203ce4:	85be                	mv	a1,a5
ffffffffc0203ce6:	863e                	mv	a2,a5
ffffffffc0203ce8:	00000073          	ecall
ffffffffc0203cec:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0203cee:	8082                	ret

ffffffffc0203cf0 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0203cf0:	4501                	li	a0,0
ffffffffc0203cf2:	00005797          	auipc	a5,0x5
ffffffffc0203cf6:	30e7b783          	ld	a5,782(a5) # ffffffffc0209000 <SBI_CONSOLE_GETCHAR>
ffffffffc0203cfa:	88be                	mv	a7,a5
ffffffffc0203cfc:	852a                	mv	a0,a0
ffffffffc0203cfe:	85aa                	mv	a1,a0
ffffffffc0203d00:	862a                	mv	a2,a0
ffffffffc0203d02:	00000073          	ecall
ffffffffc0203d06:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0203d08:	2501                	sext.w	a0,a0
ffffffffc0203d0a:	8082                	ret

ffffffffc0203d0c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203d0c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d0e:	e589                	bnez	a1,ffffffffc0203d18 <strnlen+0xc>
ffffffffc0203d10:	a811                	j	ffffffffc0203d24 <strnlen+0x18>
        cnt ++;
ffffffffc0203d12:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d14:	00f58863          	beq	a1,a5,ffffffffc0203d24 <strnlen+0x18>
ffffffffc0203d18:	00f50733          	add	a4,a0,a5
ffffffffc0203d1c:	00074703          	lbu	a4,0(a4)
ffffffffc0203d20:	fb6d                	bnez	a4,ffffffffc0203d12 <strnlen+0x6>
ffffffffc0203d22:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203d24:	852e                	mv	a0,a1
ffffffffc0203d26:	8082                	ret

ffffffffc0203d28 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d28:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203d2c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d30:	cb89                	beqz	a5,ffffffffc0203d42 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203d32:	0505                	addi	a0,a0,1
ffffffffc0203d34:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d36:	fee789e3          	beq	a5,a4,ffffffffc0203d28 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203d3a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203d3e:	9d19                	subw	a0,a0,a4
ffffffffc0203d40:	8082                	ret
ffffffffc0203d42:	4501                	li	a0,0
ffffffffc0203d44:	bfed                	j	ffffffffc0203d3e <strcmp+0x16>

ffffffffc0203d46 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203d46:	00054783          	lbu	a5,0(a0)
ffffffffc0203d4a:	c799                	beqz	a5,ffffffffc0203d58 <strchr+0x12>
        if (*s == c) {
ffffffffc0203d4c:	00f58763          	beq	a1,a5,ffffffffc0203d5a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203d50:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203d54:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203d56:	fbfd                	bnez	a5,ffffffffc0203d4c <strchr+0x6>
    }
    return NULL;
ffffffffc0203d58:	4501                	li	a0,0
}
ffffffffc0203d5a:	8082                	ret

ffffffffc0203d5c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203d5c:	ca01                	beqz	a2,ffffffffc0203d6c <memset+0x10>
ffffffffc0203d5e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203d60:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203d62:	0785                	addi	a5,a5,1
ffffffffc0203d64:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203d68:	fec79de3          	bne	a5,a2,ffffffffc0203d62 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203d6c:	8082                	ret

ffffffffc0203d6e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203d6e:	ca19                	beqz	a2,ffffffffc0203d84 <memcpy+0x16>
ffffffffc0203d70:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203d72:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203d74:	0005c703          	lbu	a4,0(a1)
ffffffffc0203d78:	0585                	addi	a1,a1,1
ffffffffc0203d7a:	0785                	addi	a5,a5,1
ffffffffc0203d7c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203d80:	fec59ae3          	bne	a1,a2,ffffffffc0203d74 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203d84:	8082                	ret
