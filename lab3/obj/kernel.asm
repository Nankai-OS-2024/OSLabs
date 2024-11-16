
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53a60613          	addi	a2,a2,1338 # ffffffffc0211574 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	562040ef          	jal	ra,ffffffffc02045ac <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	58a58593          	addi	a1,a1,1418 # ffffffffc02045d8 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	5a250513          	addi	a0,a0,1442 # ffffffffc02045f8 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	281010ef          	jal	ra,ffffffffc0201ae6 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	00f030ef          	jal	ra,ffffffffc020387c <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	0d5020ef          	jal	ra,ffffffffc020294a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	04c040ef          	jal	ra,ffffffffc02040fa <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	016040ef          	jal	ra,ffffffffc02040fa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	4fc50513          	addi	a0,a0,1276 # ffffffffc0204600 <etext+0x2a>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	50650513          	addi	a0,a0,1286 # ffffffffc0204620 <etext+0x4a>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	4b058593          	addi	a1,a1,1200 # ffffffffc02045d6 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	51250513          	addi	a0,a0,1298 # ffffffffc0204640 <etext+0x6a>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	51e50513          	addi	a0,a0,1310 # ffffffffc0204660 <etext+0x8a>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	42658593          	addi	a1,a1,1062 # ffffffffc0211574 <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	52a50513          	addi	a0,a0,1322 # ffffffffc0204680 <etext+0xaa>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	81158593          	addi	a1,a1,-2031 # ffffffffc0211973 <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	51c50513          	addi	a0,a0,1308 # ffffffffc02046a0 <etext+0xca>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	53e60613          	addi	a2,a2,1342 # ffffffffc02046d0 <etext+0xfa>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	54a50513          	addi	a0,a0,1354 # ffffffffc02046e8 <etext+0x112>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	55260613          	addi	a2,a2,1362 # ffffffffc0204700 <etext+0x12a>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	56a58593          	addi	a1,a1,1386 # ffffffffc0204720 <etext+0x14a>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	56a50513          	addi	a0,a0,1386 # ffffffffc0204728 <etext+0x152>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	56c60613          	addi	a2,a2,1388 # ffffffffc0204738 <etext+0x162>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	58c58593          	addi	a1,a1,1420 # ffffffffc0204760 <etext+0x18a>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	54c50513          	addi	a0,a0,1356 # ffffffffc0204728 <etext+0x152>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	58860613          	addi	a2,a2,1416 # ffffffffc0204770 <etext+0x19a>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	5a058593          	addi	a1,a1,1440 # ffffffffc0204790 <etext+0x1ba>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	53050513          	addi	a0,a0,1328 # ffffffffc0204728 <etext+0x152>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	56e50513          	addi	a0,a0,1390 # ffffffffc02047a0 <etext+0x1ca>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	57450513          	addi	a0,a0,1396 # ffffffffc02047c8 <etext+0x1f2>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	5c6c0c13          	addi	s8,s8,1478 # ffffffffc0204830 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	a1690913          	addi	s2,s2,-1514 # ffffffffc0205c88 <default_pmm_manager+0x950>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	57648493          	addi	s1,s1,1398 # ffffffffc02047f0 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	574b0b13          	addi	s6,s6,1396 # ffffffffc02047f8 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	494a0a13          	addi	s4,s4,1172 # ffffffffc0204720 <etext+0x14a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	1e4040ef          	jal	ra,ffffffffc020447c <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	582d0d13          	addi	s10,s10,1410 # ffffffffc0204830 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	2bc040ef          	jal	ra,ffffffffc0204578 <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	2a8040ef          	jal	ra,ffffffffc0204578 <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	288040ef          	jal	ra,ffffffffc0204596 <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	24a040ef          	jal	ra,ffffffffc0204596 <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	4b250513          	addi	a0,a0,1202 # ffffffffc0204818 <etext+0x242>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	18430313          	addi	t1,t1,388 # ffffffffc02114f8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	4d650513          	addi	a0,a0,1238 # ffffffffc0204878 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	3f850513          	addi	a0,a0,1016 # ffffffffc02057b0 <default_pmm_manager+0x478>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12a000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	4a250513          	addi	a0,a0,1186 # ffffffffc0204898 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	106040ef          	jal	ra,ffffffffc02045be <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	0e2040ef          	jal	ra,ffffffffc02045be <memcpy>
    return 0;
}
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf)
{
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf)
{
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
{
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	39450513          	addi	a0,a0,916 # ffffffffc02048b8 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL)
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03853503          	ld	a0,56(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
    {
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	10d0306f          	j	ffffffffc0203e54 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	38c60613          	addi	a2,a2,908 # ffffffffc02048d8 <commands+0xa8>
ffffffffc0200554:	08100593          	li	a1,129
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	39850513          	addi	a0,a0,920 # ffffffffc02048f0 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	4b878793          	addi	a5,a5,1208 # ffffffffc0200a20 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
{
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	37e50513          	addi	a0,a0,894 # ffffffffc0204908 <commands+0xd8>
{
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	38650513          	addi	a0,a0,902 # ffffffffc0204920 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	39050513          	addi	a0,a0,912 # ffffffffc0204938 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	39a50513          	addi	a0,a0,922 # ffffffffc0204950 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	3a450513          	addi	a0,a0,932 # ffffffffc0204968 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	3ae50513          	addi	a0,a0,942 # ffffffffc0204980 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	3b850513          	addi	a0,a0,952 # ffffffffc0204998 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	3c250513          	addi	a0,a0,962 # ffffffffc02049b0 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	3cc50513          	addi	a0,a0,972 # ffffffffc02049c8 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	3d650513          	addi	a0,a0,982 # ffffffffc02049e0 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	3e050513          	addi	a0,a0,992 # ffffffffc02049f8 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204a10 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	3f450513          	addi	a0,a0,1012 # ffffffffc0204a28 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204a40 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	40850513          	addi	a0,a0,1032 # ffffffffc0204a58 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	41250513          	addi	a0,a0,1042 # ffffffffc0204a70 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	41c50513          	addi	a0,a0,1052 # ffffffffc0204a88 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	42650513          	addi	a0,a0,1062 # ffffffffc0204aa0 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	43050513          	addi	a0,a0,1072 # ffffffffc0204ab8 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	43a50513          	addi	a0,a0,1082 # ffffffffc0204ad0 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	44450513          	addi	a0,a0,1092 # ffffffffc0204ae8 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	44e50513          	addi	a0,a0,1102 # ffffffffc0204b00 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	45850513          	addi	a0,a0,1112 # ffffffffc0204b18 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	46250513          	addi	a0,a0,1122 # ffffffffc0204b30 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	46c50513          	addi	a0,a0,1132 # ffffffffc0204b48 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	47650513          	addi	a0,a0,1142 # ffffffffc0204b60 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	48050513          	addi	a0,a0,1152 # ffffffffc0204b78 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	48a50513          	addi	a0,a0,1162 # ffffffffc0204b90 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	49450513          	addi	a0,a0,1172 # ffffffffc0204ba8 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	49e50513          	addi	a0,a0,1182 # ffffffffc0204bc0 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	4a850513          	addi	a0,a0,1192 # ffffffffc0204bd8 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	4ae50513          	addi	a0,a0,1198 # ffffffffc0204bf0 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
{
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
{
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	4b250513          	addi	a0,a0,1202 # ffffffffc0204c08 <commands+0x3d8>
{
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	4b250513          	addi	a0,a0,1202 # ffffffffc0204c20 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	4ba50513          	addi	a0,a0,1210 # ffffffffc0204c38 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	4c250513          	addi	a0,a0,1218 # ffffffffc0204c50 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	4c650513          	addi	a0,a0,1222 # ffffffffc0204c68 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    int ret;
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	59270713          	addi	a4,a4,1426 # ffffffffc0204d50 <commands+0x520>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	51050513          	addi	a0,a0,1296 # ffffffffc0204ce0 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	4e450513          	addi	a0,a0,1252 # ffffffffc0204cc0 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
        cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	49850513          	addi	a0,a0,1176 # ffffffffc0204c80 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204ca0 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
{
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // clear_csr(sip, SIP_STIP);
        clock_set_next_event();
ffffffffc0200804:	c05ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
        if (++ticks % TICK_NUM == 0)
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	50a50513          	addi	a0,a0,1290 # ffffffffc0204d30 <commands+0x500>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
        print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200834:	06400593          	li	a1,100
ffffffffc0200838:	00004517          	auipc	a0,0x4
ffffffffc020083c:	4c850513          	addi	a0,a0,1224 # ffffffffc0204d00 <commands+0x4d0>
ffffffffc0200840:	87bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (sm == NULL)
ffffffffc0200844:	00011717          	auipc	a4,0x11
ffffffffc0200848:	ccc70713          	addi	a4,a4,-820 # ffffffffc0211510 <sm>
ffffffffc020084c:	631c                	ld	a5,0(a4)
ffffffffc020084e:	c78d                	beqz	a5,ffffffffc0200878 <interrupt_handler+0xc8>
    return sm->tick_event(check_mm_struct);
ffffffffc0200850:	6f9c                	ld	a5,24(a5)
ffffffffc0200852:	00011517          	auipc	a0,0x11
ffffffffc0200856:	d1653503          	ld	a0,-746(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc020085a:	9782                	jalr	a5
            if ((ret = tick_event_handler(tf) != 0))
ffffffffc020085c:	d171                	beqz	a0,ffffffffc0200820 <interrupt_handler+0x70>
                panic("handle tick_event failed. %e\n", ret);
ffffffffc020085e:	4685                	li	a3,1
ffffffffc0200860:	00004617          	auipc	a2,0x4
ffffffffc0200864:	4b060613          	addi	a2,a2,1200 # ffffffffc0204d10 <commands+0x4e0>
ffffffffc0200868:	0b900593          	li	a1,185
ffffffffc020086c:	00004517          	auipc	a0,0x4
ffffffffc0200870:	08450513          	addi	a0,a0,132 # ffffffffc02048f0 <commands+0xc0>
ffffffffc0200874:	b01ff0ef          	jal	ra,ffffffffc0200374 <__panic>
        sm = &swap_manager_lru;
ffffffffc0200878:	00009797          	auipc	a5,0x9
ffffffffc020087c:	78878793          	addi	a5,a5,1928 # ffffffffc020a000 <swap_manager_lru>
ffffffffc0200880:	e31c                	sd	a5,0(a4)
ffffffffc0200882:	b7f9                	j	ffffffffc0200850 <interrupt_handler+0xa0>

ffffffffc0200884 <exception_handler>:

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200884:	11853783          	ld	a5,280(a0)
{
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	ec06                	sd	ra,24(sp)
ffffffffc020088e:	e426                	sd	s1,8(sp)
ffffffffc0200890:	473d                	li	a4,15
ffffffffc0200892:	842a                	mv	s0,a0
ffffffffc0200894:	14f76a63          	bltu	a4,a5,ffffffffc02009e8 <exception_handler+0x164>
ffffffffc0200898:	00004717          	auipc	a4,0x4
ffffffffc020089c:	6a070713          	addi	a4,a4,1696 # ffffffffc0204f38 <commands+0x708>
ffffffffc02008a0:	078a                	slli	a5,a5,0x2
ffffffffc02008a2:	97ba                	add	a5,a5,a4
ffffffffc02008a4:	439c                	lw	a5,0(a5)
ffffffffc02008a6:	97ba                	add	a5,a5,a4
ffffffffc02008a8:	8782                	jr	a5
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case CAUSE_STORE_PAGE_FAULT:
        cprintf("Store/AMO page fault\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	67650513          	addi	a0,a0,1654 # ffffffffc0204f20 <commands+0x6f0>
ffffffffc02008b2:	809ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        if ((ret = pgfault_handler(tf)) != 0)
ffffffffc02008b6:	8522                	mv	a0,s0
ffffffffc02008b8:	c3dff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008bc:	84aa                	mv	s1,a0
ffffffffc02008be:	12051b63          	bnez	a0,ffffffffc02009f4 <exception_handler+0x170>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc02008c2:	60e2                	ld	ra,24(sp)
ffffffffc02008c4:	6442                	ld	s0,16(sp)
ffffffffc02008c6:	64a2                	ld	s1,8(sp)
ffffffffc02008c8:	6105                	addi	sp,sp,32
ffffffffc02008ca:	8082                	ret
        cprintf("Instruction address misaligned\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	4b450513          	addi	a0,a0,1204 # ffffffffc0204d80 <commands+0x550>
}
ffffffffc02008d4:	6442                	ld	s0,16(sp)
ffffffffc02008d6:	60e2                	ld	ra,24(sp)
ffffffffc02008d8:	64a2                	ld	s1,8(sp)
ffffffffc02008da:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc02008dc:	fdeff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008e0:	00004517          	auipc	a0,0x4
ffffffffc02008e4:	4c050513          	addi	a0,a0,1216 # ffffffffc0204da0 <commands+0x570>
ffffffffc02008e8:	b7f5                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Illegal instruction\n");
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	4d650513          	addi	a0,a0,1238 # ffffffffc0204dc0 <commands+0x590>
ffffffffc02008f2:	b7cd                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Breakpoint\n");
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	4e450513          	addi	a0,a0,1252 # ffffffffc0204dd8 <commands+0x5a8>
ffffffffc02008fc:	bfe1                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Load address misaligned\n");
ffffffffc02008fe:	00004517          	auipc	a0,0x4
ffffffffc0200902:	4ea50513          	addi	a0,a0,1258 # ffffffffc0204de8 <commands+0x5b8>
ffffffffc0200906:	b7f9                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Load access fault\n");
ffffffffc0200908:	00004517          	auipc	a0,0x4
ffffffffc020090c:	50050513          	addi	a0,a0,1280 # ffffffffc0204e08 <commands+0x5d8>
ffffffffc0200910:	faaff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        if ((ret = pgfault_handler(tf)) != 0)
ffffffffc0200914:	8522                	mv	a0,s0
ffffffffc0200916:	bdfff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091a:	84aa                	mv	s1,a0
ffffffffc020091c:	d15d                	beqz	a0,ffffffffc02008c2 <exception_handler+0x3e>
            print_trapframe(tf);
ffffffffc020091e:	8522                	mv	a0,s0
ffffffffc0200920:	e2fff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc0200924:	86a6                	mv	a3,s1
ffffffffc0200926:	00004617          	auipc	a2,0x4
ffffffffc020092a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0204e20 <commands+0x5f0>
ffffffffc020092e:	0ee00593          	li	a1,238
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	fbe50513          	addi	a0,a0,-66 # ffffffffc02048f0 <commands+0xc0>
ffffffffc020093a:	a3bff0ef          	jal	ra,ffffffffc0200374 <__panic>
        cprintf("AMO address misaligned\n");
ffffffffc020093e:	00004517          	auipc	a0,0x4
ffffffffc0200942:	50250513          	addi	a0,a0,1282 # ffffffffc0204e40 <commands+0x610>
ffffffffc0200946:	b779                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Store/AMO access fault\n");
ffffffffc0200948:	00004517          	auipc	a0,0x4
ffffffffc020094c:	51050513          	addi	a0,a0,1296 # ffffffffc0204e58 <commands+0x628>
ffffffffc0200950:	f6aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        if ((ret = pgfault_handler(tf)) != 0)
ffffffffc0200954:	8522                	mv	a0,s0
ffffffffc0200956:	b9fff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020095a:	84aa                	mv	s1,a0
ffffffffc020095c:	d13d                	beqz	a0,ffffffffc02008c2 <exception_handler+0x3e>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	defff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc0200964:	86a6                	mv	a3,s1
ffffffffc0200966:	00004617          	auipc	a2,0x4
ffffffffc020096a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0204e20 <commands+0x5f0>
ffffffffc020096e:	0f900593          	li	a1,249
ffffffffc0200972:	00004517          	auipc	a0,0x4
ffffffffc0200976:	f7e50513          	addi	a0,a0,-130 # ffffffffc02048f0 <commands+0xc0>
ffffffffc020097a:	9fbff0ef          	jal	ra,ffffffffc0200374 <__panic>
        cprintf("Environment call from U-mode\n");
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	4f250513          	addi	a0,a0,1266 # ffffffffc0204e70 <commands+0x640>
ffffffffc0200986:	b7b9                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Environment call from S-mode\n");
ffffffffc0200988:	00004517          	auipc	a0,0x4
ffffffffc020098c:	50850513          	addi	a0,a0,1288 # ffffffffc0204e90 <commands+0x660>
ffffffffc0200990:	b791                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Environment call from H-mode\n");
ffffffffc0200992:	00004517          	auipc	a0,0x4
ffffffffc0200996:	51e50513          	addi	a0,a0,1310 # ffffffffc0204eb0 <commands+0x680>
ffffffffc020099a:	bf2d                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Environment call from M-mode\n");
ffffffffc020099c:	00004517          	auipc	a0,0x4
ffffffffc02009a0:	53450513          	addi	a0,a0,1332 # ffffffffc0204ed0 <commands+0x6a0>
ffffffffc02009a4:	bf05                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Instruction page fault\n");
ffffffffc02009a6:	00004517          	auipc	a0,0x4
ffffffffc02009aa:	54a50513          	addi	a0,a0,1354 # ffffffffc0204ef0 <commands+0x6c0>
ffffffffc02009ae:	b71d                	j	ffffffffc02008d4 <exception_handler+0x50>
        cprintf("Load page fault\n");
ffffffffc02009b0:	00004517          	auipc	a0,0x4
ffffffffc02009b4:	55850513          	addi	a0,a0,1368 # ffffffffc0204f08 <commands+0x6d8>
ffffffffc02009b8:	f02ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        if ((ret = pgfault_handler(tf)) != 0)
ffffffffc02009bc:	8522                	mv	a0,s0
ffffffffc02009be:	b37ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02009c2:	84aa                	mv	s1,a0
ffffffffc02009c4:	ee050fe3          	beqz	a0,ffffffffc02008c2 <exception_handler+0x3e>
            print_trapframe(tf);
ffffffffc02009c8:	8522                	mv	a0,s0
ffffffffc02009ca:	d85ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ce:	86a6                	mv	a3,s1
ffffffffc02009d0:	00004617          	auipc	a2,0x4
ffffffffc02009d4:	45060613          	addi	a2,a2,1104 # ffffffffc0204e20 <commands+0x5f0>
ffffffffc02009d8:	11000593          	li	a1,272
ffffffffc02009dc:	00004517          	auipc	a0,0x4
ffffffffc02009e0:	f1450513          	addi	a0,a0,-236 # ffffffffc02048f0 <commands+0xc0>
ffffffffc02009e4:	991ff0ef          	jal	ra,ffffffffc0200374 <__panic>
        print_trapframe(tf);
ffffffffc02009e8:	8522                	mv	a0,s0
}
ffffffffc02009ea:	6442                	ld	s0,16(sp)
ffffffffc02009ec:	60e2                	ld	ra,24(sp)
ffffffffc02009ee:	64a2                	ld	s1,8(sp)
ffffffffc02009f0:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc02009f2:	bbb1                	j	ffffffffc020074e <print_trapframe>
            print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	d59ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00004617          	auipc	a2,0x4
ffffffffc0200a00:	42460613          	addi	a2,a2,1060 # ffffffffc0204e20 <commands+0x5f0>
ffffffffc0200a04:	11800593          	li	a1,280
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	ee850513          	addi	a0,a0,-280 # ffffffffc02048f0 <commands+0xc0>
ffffffffc0200a10:	965ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a14 <trap>:
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
ffffffffc0200a14:	11853783          	ld	a5,280(a0)
ffffffffc0200a18:	0007c363          	bltz	a5,ffffffffc0200a1e <trap+0xa>
        interrupt_handler(tf);
    }
    else
    {
        // exceptions
        exception_handler(tf);
ffffffffc0200a1c:	b5a5                	j	ffffffffc0200884 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a1e:	bb49                	j	ffffffffc02007b0 <interrupt_handler>

ffffffffc0200a20 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a20:	14011073          	csrw	sscratch,sp
ffffffffc0200a24:	712d                	addi	sp,sp,-288
ffffffffc0200a26:	e406                	sd	ra,8(sp)
ffffffffc0200a28:	ec0e                	sd	gp,24(sp)
ffffffffc0200a2a:	f012                	sd	tp,32(sp)
ffffffffc0200a2c:	f416                	sd	t0,40(sp)
ffffffffc0200a2e:	f81a                	sd	t1,48(sp)
ffffffffc0200a30:	fc1e                	sd	t2,56(sp)
ffffffffc0200a32:	e0a2                	sd	s0,64(sp)
ffffffffc0200a34:	e4a6                	sd	s1,72(sp)
ffffffffc0200a36:	e8aa                	sd	a0,80(sp)
ffffffffc0200a38:	ecae                	sd	a1,88(sp)
ffffffffc0200a3a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a3c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a3e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a40:	fcbe                	sd	a5,120(sp)
ffffffffc0200a42:	e142                	sd	a6,128(sp)
ffffffffc0200a44:	e546                	sd	a7,136(sp)
ffffffffc0200a46:	e94a                	sd	s2,144(sp)
ffffffffc0200a48:	ed4e                	sd	s3,152(sp)
ffffffffc0200a4a:	f152                	sd	s4,160(sp)
ffffffffc0200a4c:	f556                	sd	s5,168(sp)
ffffffffc0200a4e:	f95a                	sd	s6,176(sp)
ffffffffc0200a50:	fd5e                	sd	s7,184(sp)
ffffffffc0200a52:	e1e2                	sd	s8,192(sp)
ffffffffc0200a54:	e5e6                	sd	s9,200(sp)
ffffffffc0200a56:	e9ea                	sd	s10,208(sp)
ffffffffc0200a58:	edee                	sd	s11,216(sp)
ffffffffc0200a5a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a5c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a5e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a60:	fdfe                	sd	t6,248(sp)
ffffffffc0200a62:	14002473          	csrr	s0,sscratch
ffffffffc0200a66:	100024f3          	csrr	s1,sstatus
ffffffffc0200a6a:	14102973          	csrr	s2,sepc
ffffffffc0200a6e:	143029f3          	csrr	s3,stval
ffffffffc0200a72:	14202a73          	csrr	s4,scause
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	e226                	sd	s1,256(sp)
ffffffffc0200a7a:	e64a                	sd	s2,264(sp)
ffffffffc0200a7c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a7e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a80:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a82:	f93ff0ef          	jal	ra,ffffffffc0200a14 <trap>

ffffffffc0200a86 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a86:	6492                	ld	s1,256(sp)
ffffffffc0200a88:	6932                	ld	s2,264(sp)
ffffffffc0200a8a:	10049073          	csrw	sstatus,s1
ffffffffc0200a8e:	14191073          	csrw	sepc,s2
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	61e2                	ld	gp,24(sp)
ffffffffc0200a96:	7202                	ld	tp,32(sp)
ffffffffc0200a98:	72a2                	ld	t0,40(sp)
ffffffffc0200a9a:	7342                	ld	t1,48(sp)
ffffffffc0200a9c:	73e2                	ld	t2,56(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	64a6                	ld	s1,72(sp)
ffffffffc0200aa2:	6546                	ld	a0,80(sp)
ffffffffc0200aa4:	65e6                	ld	a1,88(sp)
ffffffffc0200aa6:	7606                	ld	a2,96(sp)
ffffffffc0200aa8:	76a6                	ld	a3,104(sp)
ffffffffc0200aaa:	7746                	ld	a4,112(sp)
ffffffffc0200aac:	77e6                	ld	a5,120(sp)
ffffffffc0200aae:	680a                	ld	a6,128(sp)
ffffffffc0200ab0:	68aa                	ld	a7,136(sp)
ffffffffc0200ab2:	694a                	ld	s2,144(sp)
ffffffffc0200ab4:	69ea                	ld	s3,152(sp)
ffffffffc0200ab6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ab8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aba:	7b4a                	ld	s6,176(sp)
ffffffffc0200abc:	7bea                	ld	s7,184(sp)
ffffffffc0200abe:	6c0e                	ld	s8,192(sp)
ffffffffc0200ac0:	6cae                	ld	s9,200(sp)
ffffffffc0200ac2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ac4:	6dee                	ld	s11,216(sp)
ffffffffc0200ac6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ac8:	7eae                	ld	t4,232(sp)
ffffffffc0200aca:	7f4e                	ld	t5,240(sp)
ffffffffc0200acc:	7fee                	ld	t6,248(sp)
ffffffffc0200ace:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ad0:	10200073          	sret
	...

ffffffffc0200ae0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae0:	00010797          	auipc	a5,0x10
ffffffffc0200ae4:	56078793          	addi	a5,a5,1376 # ffffffffc0211040 <free_area>
ffffffffc0200ae8:	e79c                	sd	a5,8(a5)
ffffffffc0200aea:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aec:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200af0:	8082                	ret

ffffffffc0200af2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200af2:	00010517          	auipc	a0,0x10
ffffffffc0200af6:	55e56503          	lwu	a0,1374(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200afa:	8082                	ret

ffffffffc0200afc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200afc:	715d                	addi	sp,sp,-80
ffffffffc0200afe:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b00:	00010417          	auipc	s0,0x10
ffffffffc0200b04:	54040413          	addi	s0,s0,1344 # ffffffffc0211040 <free_area>
ffffffffc0200b08:	641c                	ld	a5,8(s0)
ffffffffc0200b0a:	e486                	sd	ra,72(sp)
ffffffffc0200b0c:	fc26                	sd	s1,56(sp)
ffffffffc0200b0e:	f84a                	sd	s2,48(sp)
ffffffffc0200b10:	f44e                	sd	s3,40(sp)
ffffffffc0200b12:	f052                	sd	s4,32(sp)
ffffffffc0200b14:	ec56                	sd	s5,24(sp)
ffffffffc0200b16:	e85a                	sd	s6,16(sp)
ffffffffc0200b18:	e45e                	sd	s7,8(sp)
ffffffffc0200b1a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b1c:	2c878763          	beq	a5,s0,ffffffffc0200dea <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200b20:	4481                	li	s1,0
ffffffffc0200b22:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b24:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b28:	8b09                	andi	a4,a4,2
ffffffffc0200b2a:	2c070463          	beqz	a4,ffffffffc0200df2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200b2e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b32:	679c                	ld	a5,8(a5)
ffffffffc0200b34:	2905                	addiw	s2,s2,1
ffffffffc0200b36:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b38:	fe8796e3          	bne	a5,s0,ffffffffc0200b24 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b3c:	89a6                	mv	s3,s1
ffffffffc0200b3e:	385000ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0200b42:	71351863          	bne	a0,s3,ffffffffc0201252 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b46:	4505                	li	a0,1
ffffffffc0200b48:	2a9000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200b4c:	8a2a                	mv	s4,a0
ffffffffc0200b4e:	44050263          	beqz	a0,ffffffffc0200f92 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b52:	4505                	li	a0,1
ffffffffc0200b54:	29d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200b58:	89aa                	mv	s3,a0
ffffffffc0200b5a:	70050c63          	beqz	a0,ffffffffc0201272 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b5e:	4505                	li	a0,1
ffffffffc0200b60:	291000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200b64:	8aaa                	mv	s5,a0
ffffffffc0200b66:	4a050663          	beqz	a0,ffffffffc0201012 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b6a:	2b3a0463          	beq	s4,s3,ffffffffc0200e12 <default_check+0x316>
ffffffffc0200b6e:	2aaa0263          	beq	s4,a0,ffffffffc0200e12 <default_check+0x316>
ffffffffc0200b72:	2aa98063          	beq	s3,a0,ffffffffc0200e12 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b76:	000a2783          	lw	a5,0(s4)
ffffffffc0200b7a:	2a079c63          	bnez	a5,ffffffffc0200e32 <default_check+0x336>
ffffffffc0200b7e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b82:	2a079863          	bnez	a5,ffffffffc0200e32 <default_check+0x336>
ffffffffc0200b86:	411c                	lw	a5,0(a0)
ffffffffc0200b88:	2a079563          	bnez	a5,ffffffffc0200e32 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b8c:	00011797          	auipc	a5,0x11
ffffffffc0200b90:	9a47b783          	ld	a5,-1628(a5) # ffffffffc0211530 <pages>
ffffffffc0200b94:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b98:	870d                	srai	a4,a4,0x3
ffffffffc0200b9a:	00006597          	auipc	a1,0x6
ffffffffc0200b9e:	9965b583          	ld	a1,-1642(a1) # ffffffffc0206530 <error_string+0x38>
ffffffffc0200ba2:	02b70733          	mul	a4,a4,a1
ffffffffc0200ba6:	00006617          	auipc	a2,0x6
ffffffffc0200baa:	99263603          	ld	a2,-1646(a2) # ffffffffc0206538 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bae:	00011697          	auipc	a3,0x11
ffffffffc0200bb2:	97a6b683          	ld	a3,-1670(a3) # ffffffffc0211528 <npage>
ffffffffc0200bb6:	06b2                	slli	a3,a3,0xc
ffffffffc0200bb8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bba:	0732                	slli	a4,a4,0xc
ffffffffc0200bbc:	28d77b63          	bgeu	a4,a3,ffffffffc0200e52 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bc0:	40f98733          	sub	a4,s3,a5
ffffffffc0200bc4:	870d                	srai	a4,a4,0x3
ffffffffc0200bc6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bca:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bcc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bce:	4cd77263          	bgeu	a4,a3,ffffffffc0201092 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bd2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bd6:	878d                	srai	a5,a5,0x3
ffffffffc0200bd8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bdc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bde:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200be0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ef2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200be4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200be6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bea:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bee:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bf2:	e400                	sd	s0,8(s0)
ffffffffc0200bf4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bf6:	00010797          	auipc	a5,0x10
ffffffffc0200bfa:	4407ad23          	sw	zero,1114(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bfe:	1f3000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c02:	2c051863          	bnez	a0,ffffffffc0200ed2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200c06:	4585                	li	a1,1
ffffffffc0200c08:	8552                	mv	a0,s4
ffffffffc0200c0a:	279000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p1);
ffffffffc0200c0e:	4585                	li	a1,1
ffffffffc0200c10:	854e                	mv	a0,s3
ffffffffc0200c12:	271000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p2);
ffffffffc0200c16:	4585                	li	a1,1
ffffffffc0200c18:	8556                	mv	a0,s5
ffffffffc0200c1a:	269000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c1e:	4818                	lw	a4,16(s0)
ffffffffc0200c20:	478d                	li	a5,3
ffffffffc0200c22:	28f71863          	bne	a4,a5,ffffffffc0200eb2 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c26:	4505                	li	a0,1
ffffffffc0200c28:	1c9000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c2c:	89aa                	mv	s3,a0
ffffffffc0200c2e:	26050263          	beqz	a0,ffffffffc0200e92 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	1bd000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c38:	8aaa                	mv	s5,a0
ffffffffc0200c3a:	3a050c63          	beqz	a0,ffffffffc0200ff2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c3e:	4505                	li	a0,1
ffffffffc0200c40:	1b1000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c44:	8a2a                	mv	s4,a0
ffffffffc0200c46:	38050663          	beqz	a0,ffffffffc0200fd2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c4a:	4505                	li	a0,1
ffffffffc0200c4c:	1a5000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c50:	36051163          	bnez	a0,ffffffffc0200fb2 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c54:	4585                	li	a1,1
ffffffffc0200c56:	854e                	mv	a0,s3
ffffffffc0200c58:	22b000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c5c:	641c                	ld	a5,8(s0)
ffffffffc0200c5e:	20878a63          	beq	a5,s0,ffffffffc0200e72 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c62:	4505                	li	a0,1
ffffffffc0200c64:	18d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c68:	30a99563          	bne	s3,a0,ffffffffc0200f72 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c6c:	4505                	li	a0,1
ffffffffc0200c6e:	183000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c72:	2e051063          	bnez	a0,ffffffffc0200f52 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c76:	481c                	lw	a5,16(s0)
ffffffffc0200c78:	2a079d63          	bnez	a5,ffffffffc0200f32 <default_check+0x436>
    free_page(p);
ffffffffc0200c7c:	854e                	mv	a0,s3
ffffffffc0200c7e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c80:	01843023          	sd	s8,0(s0)
ffffffffc0200c84:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c88:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c8c:	1f7000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p1);
ffffffffc0200c90:	4585                	li	a1,1
ffffffffc0200c92:	8556                	mv	a0,s5
ffffffffc0200c94:	1ef000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p2);
ffffffffc0200c98:	4585                	li	a1,1
ffffffffc0200c9a:	8552                	mv	a0,s4
ffffffffc0200c9c:	1e7000ef          	jal	ra,ffffffffc0201682 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ca0:	4515                	li	a0,5
ffffffffc0200ca2:	14f000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200ca6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ca8:	26050563          	beqz	a0,ffffffffc0200f12 <default_check+0x416>
ffffffffc0200cac:	651c                	ld	a5,8(a0)
ffffffffc0200cae:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cb0:	8b85                	andi	a5,a5,1
ffffffffc0200cb2:	54079063          	bnez	a5,ffffffffc02011f2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cb6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cb8:	00043b03          	ld	s6,0(s0)
ffffffffc0200cbc:	00843a83          	ld	s5,8(s0)
ffffffffc0200cc0:	e000                	sd	s0,0(s0)
ffffffffc0200cc2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cc4:	12d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200cc8:	50051563          	bnez	a0,ffffffffc02011d2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ccc:	09098a13          	addi	s4,s3,144
ffffffffc0200cd0:	8552                	mv	a0,s4
ffffffffc0200cd2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200cd4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200cd8:	00010797          	auipc	a5,0x10
ffffffffc0200cdc:	3607ac23          	sw	zero,888(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200ce0:	1a3000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ce4:	4511                	li	a0,4
ffffffffc0200ce6:	10b000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200cea:	4c051463          	bnez	a0,ffffffffc02011b2 <default_check+0x6b6>
ffffffffc0200cee:	0989b783          	ld	a5,152(s3)
ffffffffc0200cf2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cf4:	8b85                	andi	a5,a5,1
ffffffffc0200cf6:	48078e63          	beqz	a5,ffffffffc0201192 <default_check+0x696>
ffffffffc0200cfa:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cfe:	478d                	li	a5,3
ffffffffc0200d00:	48f71963          	bne	a4,a5,ffffffffc0201192 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d04:	450d                	li	a0,3
ffffffffc0200d06:	0eb000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d0a:	8c2a                	mv	s8,a0
ffffffffc0200d0c:	46050363          	beqz	a0,ffffffffc0201172 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200d10:	4505                	li	a0,1
ffffffffc0200d12:	0df000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d16:	42051e63          	bnez	a0,ffffffffc0201152 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200d1a:	418a1c63          	bne	s4,s8,ffffffffc0201132 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d1e:	4585                	li	a1,1
ffffffffc0200d20:	854e                	mv	a0,s3
ffffffffc0200d22:	161000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d26:	458d                	li	a1,3
ffffffffc0200d28:	8552                	mv	a0,s4
ffffffffc0200d2a:	159000ef          	jal	ra,ffffffffc0201682 <free_pages>
ffffffffc0200d2e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d32:	04898c13          	addi	s8,s3,72
ffffffffc0200d36:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d38:	8b85                	andi	a5,a5,1
ffffffffc0200d3a:	3c078c63          	beqz	a5,ffffffffc0201112 <default_check+0x616>
ffffffffc0200d3e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d42:	4785                	li	a5,1
ffffffffc0200d44:	3cf71763          	bne	a4,a5,ffffffffc0201112 <default_check+0x616>
ffffffffc0200d48:	008a3783          	ld	a5,8(s4)
ffffffffc0200d4c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d4e:	8b85                	andi	a5,a5,1
ffffffffc0200d50:	3a078163          	beqz	a5,ffffffffc02010f2 <default_check+0x5f6>
ffffffffc0200d54:	018a2703          	lw	a4,24(s4)
ffffffffc0200d58:	478d                	li	a5,3
ffffffffc0200d5a:	38f71c63          	bne	a4,a5,ffffffffc02010f2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d5e:	4505                	li	a0,1
ffffffffc0200d60:	091000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d64:	36a99763          	bne	s3,a0,ffffffffc02010d2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d68:	4585                	li	a1,1
ffffffffc0200d6a:	119000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d6e:	4509                	li	a0,2
ffffffffc0200d70:	081000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d74:	32aa1f63          	bne	s4,a0,ffffffffc02010b2 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d78:	4589                	li	a1,2
ffffffffc0200d7a:	109000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p2);
ffffffffc0200d7e:	4585                	li	a1,1
ffffffffc0200d80:	8562                	mv	a0,s8
ffffffffc0200d82:	101000ef          	jal	ra,ffffffffc0201682 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d86:	4515                	li	a0,5
ffffffffc0200d88:	069000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d8c:	89aa                	mv	s3,a0
ffffffffc0200d8e:	48050263          	beqz	a0,ffffffffc0201212 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d92:	4505                	li	a0,1
ffffffffc0200d94:	05d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d98:	2c051d63          	bnez	a0,ffffffffc0201072 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d9c:	481c                	lw	a5,16(s0)
ffffffffc0200d9e:	2a079a63          	bnez	a5,ffffffffc0201052 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200da2:	4595                	li	a1,5
ffffffffc0200da4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200da6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200daa:	01643023          	sd	s6,0(s0)
ffffffffc0200dae:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200db2:	0d1000ef          	jal	ra,ffffffffc0201682 <free_pages>
    return listelm->next;
ffffffffc0200db6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200db8:	00878963          	beq	a5,s0,ffffffffc0200dca <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dbc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200dc0:	679c                	ld	a5,8(a5)
ffffffffc0200dc2:	397d                	addiw	s2,s2,-1
ffffffffc0200dc4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dc6:	fe879be3          	bne	a5,s0,ffffffffc0200dbc <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200dca:	26091463          	bnez	s2,ffffffffc0201032 <default_check+0x536>
    assert(total == 0);
ffffffffc0200dce:	46049263          	bnez	s1,ffffffffc0201232 <default_check+0x736>
}
ffffffffc0200dd2:	60a6                	ld	ra,72(sp)
ffffffffc0200dd4:	6406                	ld	s0,64(sp)
ffffffffc0200dd6:	74e2                	ld	s1,56(sp)
ffffffffc0200dd8:	7942                	ld	s2,48(sp)
ffffffffc0200dda:	79a2                	ld	s3,40(sp)
ffffffffc0200ddc:	7a02                	ld	s4,32(sp)
ffffffffc0200dde:	6ae2                	ld	s5,24(sp)
ffffffffc0200de0:	6b42                	ld	s6,16(sp)
ffffffffc0200de2:	6ba2                	ld	s7,8(sp)
ffffffffc0200de4:	6c02                	ld	s8,0(sp)
ffffffffc0200de6:	6161                	addi	sp,sp,80
ffffffffc0200de8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dea:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dec:	4481                	li	s1,0
ffffffffc0200dee:	4901                	li	s2,0
ffffffffc0200df0:	b3b9                	j	ffffffffc0200b3e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200df2:	00004697          	auipc	a3,0x4
ffffffffc0200df6:	18668693          	addi	a3,a3,390 # ffffffffc0204f78 <commands+0x748>
ffffffffc0200dfa:	00004617          	auipc	a2,0x4
ffffffffc0200dfe:	18e60613          	addi	a2,a2,398 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200e02:	0f000593          	li	a1,240
ffffffffc0200e06:	00004517          	auipc	a0,0x4
ffffffffc0200e0a:	19a50513          	addi	a0,a0,410 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200e0e:	d66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e12:	00004697          	auipc	a3,0x4
ffffffffc0200e16:	22668693          	addi	a3,a3,550 # ffffffffc0205038 <commands+0x808>
ffffffffc0200e1a:	00004617          	auipc	a2,0x4
ffffffffc0200e1e:	16e60613          	addi	a2,a2,366 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200e22:	0bd00593          	li	a1,189
ffffffffc0200e26:	00004517          	auipc	a0,0x4
ffffffffc0200e2a:	17a50513          	addi	a0,a0,378 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200e2e:	d46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	22e68693          	addi	a3,a3,558 # ffffffffc0205060 <commands+0x830>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	14e60613          	addi	a2,a2,334 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200e42:	0be00593          	li	a1,190
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	15a50513          	addi	a0,a0,346 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200e4e:	d26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e52:	00004697          	auipc	a3,0x4
ffffffffc0200e56:	24e68693          	addi	a3,a3,590 # ffffffffc02050a0 <commands+0x870>
ffffffffc0200e5a:	00004617          	auipc	a2,0x4
ffffffffc0200e5e:	12e60613          	addi	a2,a2,302 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200e62:	0c000593          	li	a1,192
ffffffffc0200e66:	00004517          	auipc	a0,0x4
ffffffffc0200e6a:	13a50513          	addi	a0,a0,314 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200e6e:	d06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e72:	00004697          	auipc	a3,0x4
ffffffffc0200e76:	2b668693          	addi	a3,a3,694 # ffffffffc0205128 <commands+0x8f8>
ffffffffc0200e7a:	00004617          	auipc	a2,0x4
ffffffffc0200e7e:	10e60613          	addi	a2,a2,270 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200e82:	0d900593          	li	a1,217
ffffffffc0200e86:	00004517          	auipc	a0,0x4
ffffffffc0200e8a:	11a50513          	addi	a0,a0,282 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200e8e:	ce6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e92:	00004697          	auipc	a3,0x4
ffffffffc0200e96:	14668693          	addi	a3,a3,326 # ffffffffc0204fd8 <commands+0x7a8>
ffffffffc0200e9a:	00004617          	auipc	a2,0x4
ffffffffc0200e9e:	0ee60613          	addi	a2,a2,238 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200ea2:	0d200593          	li	a1,210
ffffffffc0200ea6:	00004517          	auipc	a0,0x4
ffffffffc0200eaa:	0fa50513          	addi	a0,a0,250 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200eae:	cc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200eb2:	00004697          	auipc	a3,0x4
ffffffffc0200eb6:	26668693          	addi	a3,a3,614 # ffffffffc0205118 <commands+0x8e8>
ffffffffc0200eba:	00004617          	auipc	a2,0x4
ffffffffc0200ebe:	0ce60613          	addi	a2,a2,206 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200ec2:	0d000593          	li	a1,208
ffffffffc0200ec6:	00004517          	auipc	a0,0x4
ffffffffc0200eca:	0da50513          	addi	a0,a0,218 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200ece:	ca6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ed2:	00004697          	auipc	a3,0x4
ffffffffc0200ed6:	22e68693          	addi	a3,a3,558 # ffffffffc0205100 <commands+0x8d0>
ffffffffc0200eda:	00004617          	auipc	a2,0x4
ffffffffc0200ede:	0ae60613          	addi	a2,a2,174 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200ee2:	0cb00593          	li	a1,203
ffffffffc0200ee6:	00004517          	auipc	a0,0x4
ffffffffc0200eea:	0ba50513          	addi	a0,a0,186 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200eee:	c86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ef2:	00004697          	auipc	a3,0x4
ffffffffc0200ef6:	1ee68693          	addi	a3,a3,494 # ffffffffc02050e0 <commands+0x8b0>
ffffffffc0200efa:	00004617          	auipc	a2,0x4
ffffffffc0200efe:	08e60613          	addi	a2,a2,142 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200f02:	0c200593          	li	a1,194
ffffffffc0200f06:	00004517          	auipc	a0,0x4
ffffffffc0200f0a:	09a50513          	addi	a0,a0,154 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200f0e:	c66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f12:	00004697          	auipc	a3,0x4
ffffffffc0200f16:	25e68693          	addi	a3,a3,606 # ffffffffc0205170 <commands+0x940>
ffffffffc0200f1a:	00004617          	auipc	a2,0x4
ffffffffc0200f1e:	06e60613          	addi	a2,a2,110 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200f22:	0f800593          	li	a1,248
ffffffffc0200f26:	00004517          	auipc	a0,0x4
ffffffffc0200f2a:	07a50513          	addi	a0,a0,122 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200f2e:	c46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f32:	00004697          	auipc	a3,0x4
ffffffffc0200f36:	22e68693          	addi	a3,a3,558 # ffffffffc0205160 <commands+0x930>
ffffffffc0200f3a:	00004617          	auipc	a2,0x4
ffffffffc0200f3e:	04e60613          	addi	a2,a2,78 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200f42:	0df00593          	li	a1,223
ffffffffc0200f46:	00004517          	auipc	a0,0x4
ffffffffc0200f4a:	05a50513          	addi	a0,a0,90 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200f4e:	c26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f52:	00004697          	auipc	a3,0x4
ffffffffc0200f56:	1ae68693          	addi	a3,a3,430 # ffffffffc0205100 <commands+0x8d0>
ffffffffc0200f5a:	00004617          	auipc	a2,0x4
ffffffffc0200f5e:	02e60613          	addi	a2,a2,46 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200f62:	0dd00593          	li	a1,221
ffffffffc0200f66:	00004517          	auipc	a0,0x4
ffffffffc0200f6a:	03a50513          	addi	a0,a0,58 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200f6e:	c06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f72:	00004697          	auipc	a3,0x4
ffffffffc0200f76:	1ce68693          	addi	a3,a3,462 # ffffffffc0205140 <commands+0x910>
ffffffffc0200f7a:	00004617          	auipc	a2,0x4
ffffffffc0200f7e:	00e60613          	addi	a2,a2,14 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200f82:	0dc00593          	li	a1,220
ffffffffc0200f86:	00004517          	auipc	a0,0x4
ffffffffc0200f8a:	01a50513          	addi	a0,a0,26 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200f8e:	be6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f92:	00004697          	auipc	a3,0x4
ffffffffc0200f96:	04668693          	addi	a3,a3,70 # ffffffffc0204fd8 <commands+0x7a8>
ffffffffc0200f9a:	00004617          	auipc	a2,0x4
ffffffffc0200f9e:	fee60613          	addi	a2,a2,-18 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200fa2:	0b900593          	li	a1,185
ffffffffc0200fa6:	00004517          	auipc	a0,0x4
ffffffffc0200faa:	ffa50513          	addi	a0,a0,-6 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200fae:	bc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb2:	00004697          	auipc	a3,0x4
ffffffffc0200fb6:	14e68693          	addi	a3,a3,334 # ffffffffc0205100 <commands+0x8d0>
ffffffffc0200fba:	00004617          	auipc	a2,0x4
ffffffffc0200fbe:	fce60613          	addi	a2,a2,-50 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200fc2:	0d600593          	li	a1,214
ffffffffc0200fc6:	00004517          	auipc	a0,0x4
ffffffffc0200fca:	fda50513          	addi	a0,a0,-38 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200fce:	ba6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd2:	00004697          	auipc	a3,0x4
ffffffffc0200fd6:	04668693          	addi	a3,a3,70 # ffffffffc0205018 <commands+0x7e8>
ffffffffc0200fda:	00004617          	auipc	a2,0x4
ffffffffc0200fde:	fae60613          	addi	a2,a2,-82 # ffffffffc0204f88 <commands+0x758>
ffffffffc0200fe2:	0d400593          	li	a1,212
ffffffffc0200fe6:	00004517          	auipc	a0,0x4
ffffffffc0200fea:	fba50513          	addi	a0,a0,-70 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0200fee:	b86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ff2:	00004697          	auipc	a3,0x4
ffffffffc0200ff6:	00668693          	addi	a3,a3,6 # ffffffffc0204ff8 <commands+0x7c8>
ffffffffc0200ffa:	00004617          	auipc	a2,0x4
ffffffffc0200ffe:	f8e60613          	addi	a2,a2,-114 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201002:	0d300593          	li	a1,211
ffffffffc0201006:	00004517          	auipc	a0,0x4
ffffffffc020100a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020100e:	b66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201012:	00004697          	auipc	a3,0x4
ffffffffc0201016:	00668693          	addi	a3,a3,6 # ffffffffc0205018 <commands+0x7e8>
ffffffffc020101a:	00004617          	auipc	a2,0x4
ffffffffc020101e:	f6e60613          	addi	a2,a2,-146 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201022:	0bb00593          	li	a1,187
ffffffffc0201026:	00004517          	auipc	a0,0x4
ffffffffc020102a:	f7a50513          	addi	a0,a0,-134 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020102e:	b46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201032:	00004697          	auipc	a3,0x4
ffffffffc0201036:	28e68693          	addi	a3,a3,654 # ffffffffc02052c0 <commands+0xa90>
ffffffffc020103a:	00004617          	auipc	a2,0x4
ffffffffc020103e:	f4e60613          	addi	a2,a2,-178 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201042:	12500593          	li	a1,293
ffffffffc0201046:	00004517          	auipc	a0,0x4
ffffffffc020104a:	f5a50513          	addi	a0,a0,-166 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020104e:	b26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201052:	00004697          	auipc	a3,0x4
ffffffffc0201056:	10e68693          	addi	a3,a3,270 # ffffffffc0205160 <commands+0x930>
ffffffffc020105a:	00004617          	auipc	a2,0x4
ffffffffc020105e:	f2e60613          	addi	a2,a2,-210 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201062:	11a00593          	li	a1,282
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020106e:	b06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201072:	00004697          	auipc	a3,0x4
ffffffffc0201076:	08e68693          	addi	a3,a3,142 # ffffffffc0205100 <commands+0x8d0>
ffffffffc020107a:	00004617          	auipc	a2,0x4
ffffffffc020107e:	f0e60613          	addi	a2,a2,-242 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201082:	11800593          	li	a1,280
ffffffffc0201086:	00004517          	auipc	a0,0x4
ffffffffc020108a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020108e:	ae6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201092:	00004697          	auipc	a3,0x4
ffffffffc0201096:	02e68693          	addi	a3,a3,46 # ffffffffc02050c0 <commands+0x890>
ffffffffc020109a:	00004617          	auipc	a2,0x4
ffffffffc020109e:	eee60613          	addi	a2,a2,-274 # ffffffffc0204f88 <commands+0x758>
ffffffffc02010a2:	0c100593          	li	a1,193
ffffffffc02010a6:	00004517          	auipc	a0,0x4
ffffffffc02010aa:	efa50513          	addi	a0,a0,-262 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02010ae:	ac6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010b2:	00004697          	auipc	a3,0x4
ffffffffc02010b6:	1ce68693          	addi	a3,a3,462 # ffffffffc0205280 <commands+0xa50>
ffffffffc02010ba:	00004617          	auipc	a2,0x4
ffffffffc02010be:	ece60613          	addi	a2,a2,-306 # ffffffffc0204f88 <commands+0x758>
ffffffffc02010c2:	11200593          	li	a1,274
ffffffffc02010c6:	00004517          	auipc	a0,0x4
ffffffffc02010ca:	eda50513          	addi	a0,a0,-294 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02010ce:	aa6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010d2:	00004697          	auipc	a3,0x4
ffffffffc02010d6:	18e68693          	addi	a3,a3,398 # ffffffffc0205260 <commands+0xa30>
ffffffffc02010da:	00004617          	auipc	a2,0x4
ffffffffc02010de:	eae60613          	addi	a2,a2,-338 # ffffffffc0204f88 <commands+0x758>
ffffffffc02010e2:	11000593          	li	a1,272
ffffffffc02010e6:	00004517          	auipc	a0,0x4
ffffffffc02010ea:	eba50513          	addi	a0,a0,-326 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02010ee:	a86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010f2:	00004697          	auipc	a3,0x4
ffffffffc02010f6:	14668693          	addi	a3,a3,326 # ffffffffc0205238 <commands+0xa08>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201102:	10e00593          	li	a1,270
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	e9a50513          	addi	a0,a0,-358 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020110e:	a66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201112:	00004697          	auipc	a3,0x4
ffffffffc0201116:	0fe68693          	addi	a3,a3,254 # ffffffffc0205210 <commands+0x9e0>
ffffffffc020111a:	00004617          	auipc	a2,0x4
ffffffffc020111e:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201122:	10d00593          	li	a1,269
ffffffffc0201126:	00004517          	auipc	a0,0x4
ffffffffc020112a:	e7a50513          	addi	a0,a0,-390 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020112e:	a46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201132:	00004697          	auipc	a3,0x4
ffffffffc0201136:	0ce68693          	addi	a3,a3,206 # ffffffffc0205200 <commands+0x9d0>
ffffffffc020113a:	00004617          	auipc	a2,0x4
ffffffffc020113e:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201142:	10800593          	li	a1,264
ffffffffc0201146:	00004517          	auipc	a0,0x4
ffffffffc020114a:	e5a50513          	addi	a0,a0,-422 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020114e:	a26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201152:	00004697          	auipc	a3,0x4
ffffffffc0201156:	fae68693          	addi	a3,a3,-82 # ffffffffc0205100 <commands+0x8d0>
ffffffffc020115a:	00004617          	auipc	a2,0x4
ffffffffc020115e:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201162:	10700593          	li	a1,263
ffffffffc0201166:	00004517          	auipc	a0,0x4
ffffffffc020116a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020116e:	a06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201172:	00004697          	auipc	a3,0x4
ffffffffc0201176:	06e68693          	addi	a3,a3,110 # ffffffffc02051e0 <commands+0x9b0>
ffffffffc020117a:	00004617          	auipc	a2,0x4
ffffffffc020117e:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201182:	10600593          	li	a1,262
ffffffffc0201186:	00004517          	auipc	a0,0x4
ffffffffc020118a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020118e:	9e6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201192:	00004697          	auipc	a3,0x4
ffffffffc0201196:	01e68693          	addi	a3,a3,30 # ffffffffc02051b0 <commands+0x980>
ffffffffc020119a:	00004617          	auipc	a2,0x4
ffffffffc020119e:	dee60613          	addi	a2,a2,-530 # ffffffffc0204f88 <commands+0x758>
ffffffffc02011a2:	10500593          	li	a1,261
ffffffffc02011a6:	00004517          	auipc	a0,0x4
ffffffffc02011aa:	dfa50513          	addi	a0,a0,-518 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02011ae:	9c6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011b2:	00004697          	auipc	a3,0x4
ffffffffc02011b6:	fe668693          	addi	a3,a3,-26 # ffffffffc0205198 <commands+0x968>
ffffffffc02011ba:	00004617          	auipc	a2,0x4
ffffffffc02011be:	dce60613          	addi	a2,a2,-562 # ffffffffc0204f88 <commands+0x758>
ffffffffc02011c2:	10400593          	li	a1,260
ffffffffc02011c6:	00004517          	auipc	a0,0x4
ffffffffc02011ca:	dda50513          	addi	a0,a0,-550 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02011ce:	9a6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d2:	00004697          	auipc	a3,0x4
ffffffffc02011d6:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205100 <commands+0x8d0>
ffffffffc02011da:	00004617          	auipc	a2,0x4
ffffffffc02011de:	dae60613          	addi	a2,a2,-594 # ffffffffc0204f88 <commands+0x758>
ffffffffc02011e2:	0fe00593          	li	a1,254
ffffffffc02011e6:	00004517          	auipc	a0,0x4
ffffffffc02011ea:	dba50513          	addi	a0,a0,-582 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02011ee:	986ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011f2:	00004697          	auipc	a3,0x4
ffffffffc02011f6:	f8e68693          	addi	a3,a3,-114 # ffffffffc0205180 <commands+0x950>
ffffffffc02011fa:	00004617          	auipc	a2,0x4
ffffffffc02011fe:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201202:	0f900593          	li	a1,249
ffffffffc0201206:	00004517          	auipc	a0,0x4
ffffffffc020120a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020120e:	966ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201212:	00004697          	auipc	a3,0x4
ffffffffc0201216:	08e68693          	addi	a3,a3,142 # ffffffffc02052a0 <commands+0xa70>
ffffffffc020121a:	00004617          	auipc	a2,0x4
ffffffffc020121e:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201222:	11700593          	li	a1,279
ffffffffc0201226:	00004517          	auipc	a0,0x4
ffffffffc020122a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020122e:	946ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201232:	00004697          	auipc	a3,0x4
ffffffffc0201236:	09e68693          	addi	a3,a3,158 # ffffffffc02052d0 <commands+0xaa0>
ffffffffc020123a:	00004617          	auipc	a2,0x4
ffffffffc020123e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201242:	12600593          	li	a1,294
ffffffffc0201246:	00004517          	auipc	a0,0x4
ffffffffc020124a:	d5a50513          	addi	a0,a0,-678 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020124e:	926ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201252:	00004697          	auipc	a3,0x4
ffffffffc0201256:	d6668693          	addi	a3,a3,-666 # ffffffffc0204fb8 <commands+0x788>
ffffffffc020125a:	00004617          	auipc	a2,0x4
ffffffffc020125e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201262:	0f300593          	li	a1,243
ffffffffc0201266:	00004517          	auipc	a0,0x4
ffffffffc020126a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020126e:	906ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201272:	00004697          	auipc	a3,0x4
ffffffffc0201276:	d8668693          	addi	a3,a3,-634 # ffffffffc0204ff8 <commands+0x7c8>
ffffffffc020127a:	00004617          	auipc	a2,0x4
ffffffffc020127e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201282:	0ba00593          	li	a1,186
ffffffffc0201286:	00004517          	auipc	a0,0x4
ffffffffc020128a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204fa0 <commands+0x770>
ffffffffc020128e:	8e6ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201292 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201292:	1141                	addi	sp,sp,-16
ffffffffc0201294:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201296:	14058a63          	beqz	a1,ffffffffc02013ea <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020129a:	00359693          	slli	a3,a1,0x3
ffffffffc020129e:	96ae                	add	a3,a3,a1
ffffffffc02012a0:	068e                	slli	a3,a3,0x3
ffffffffc02012a2:	96aa                	add	a3,a3,a0
ffffffffc02012a4:	87aa                	mv	a5,a0
ffffffffc02012a6:	02d50263          	beq	a0,a3,ffffffffc02012ca <default_free_pages+0x38>
ffffffffc02012aa:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012ac:	8b05                	andi	a4,a4,1
ffffffffc02012ae:	10071e63          	bnez	a4,ffffffffc02013ca <default_free_pages+0x138>
ffffffffc02012b2:	6798                	ld	a4,8(a5)
ffffffffc02012b4:	8b09                	andi	a4,a4,2
ffffffffc02012b6:	10071a63          	bnez	a4,ffffffffc02013ca <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012ba:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012be:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012c2:	04878793          	addi	a5,a5,72
ffffffffc02012c6:	fed792e3          	bne	a5,a3,ffffffffc02012aa <default_free_pages+0x18>
    base->property = n;
ffffffffc02012ca:	2581                	sext.w	a1,a1
ffffffffc02012cc:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012ce:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012d2:	4789                	li	a5,2
ffffffffc02012d4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012d8:	00010697          	auipc	a3,0x10
ffffffffc02012dc:	d6868693          	addi	a3,a3,-664 # ffffffffc0211040 <free_area>
ffffffffc02012e0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012e2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012e4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012e8:	9db9                	addw	a1,a1,a4
ffffffffc02012ea:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012ec:	0ad78863          	beq	a5,a3,ffffffffc020139c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012f0:	fe078713          	addi	a4,a5,-32
ffffffffc02012f4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012f8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012fa:	00e56a63          	bltu	a0,a4,ffffffffc020130e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012fe:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201300:	06d70263          	beq	a4,a3,ffffffffc0201364 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201304:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201306:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020130a:	fee57ae3          	bgeu	a0,a4,ffffffffc02012fe <default_free_pages+0x6c>
ffffffffc020130e:	c199                	beqz	a1,ffffffffc0201314 <default_free_pages+0x82>
ffffffffc0201310:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201314:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201316:	e390                	sd	a2,0(a5)
ffffffffc0201318:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020131a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020131c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020131e:	02d70063          	beq	a4,a3,ffffffffc020133e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201322:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201326:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020132a:	02081613          	slli	a2,a6,0x20
ffffffffc020132e:	9201                	srli	a2,a2,0x20
ffffffffc0201330:	00361793          	slli	a5,a2,0x3
ffffffffc0201334:	97b2                	add	a5,a5,a2
ffffffffc0201336:	078e                	slli	a5,a5,0x3
ffffffffc0201338:	97ae                	add	a5,a5,a1
ffffffffc020133a:	02f50f63          	beq	a0,a5,ffffffffc0201378 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020133e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201340:	00d70f63          	beq	a4,a3,ffffffffc020135e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201344:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201346:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020134a:	02059613          	slli	a2,a1,0x20
ffffffffc020134e:	9201                	srli	a2,a2,0x20
ffffffffc0201350:	00361793          	slli	a5,a2,0x3
ffffffffc0201354:	97b2                	add	a5,a5,a2
ffffffffc0201356:	078e                	slli	a5,a5,0x3
ffffffffc0201358:	97aa                	add	a5,a5,a0
ffffffffc020135a:	04f68863          	beq	a3,a5,ffffffffc02013aa <default_free_pages+0x118>
}
ffffffffc020135e:	60a2                	ld	ra,8(sp)
ffffffffc0201360:	0141                	addi	sp,sp,16
ffffffffc0201362:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201364:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201366:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201368:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020136a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136c:	02d70563          	beq	a4,a3,ffffffffc0201396 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201370:	8832                	mv	a6,a2
ffffffffc0201372:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201374:	87ba                	mv	a5,a4
ffffffffc0201376:	bf41                	j	ffffffffc0201306 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201378:	4d1c                	lw	a5,24(a0)
ffffffffc020137a:	0107883b          	addw	a6,a5,a6
ffffffffc020137e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201382:	57f5                	li	a5,-3
ffffffffc0201384:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201388:	7110                	ld	a2,32(a0)
ffffffffc020138a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020138c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020138e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201390:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201392:	e390                	sd	a2,0(a5)
ffffffffc0201394:	b775                	j	ffffffffc0201340 <default_free_pages+0xae>
ffffffffc0201396:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201398:	873e                	mv	a4,a5
ffffffffc020139a:	b761                	j	ffffffffc0201322 <default_free_pages+0x90>
}
ffffffffc020139c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020139e:	e390                	sd	a2,0(a5)
ffffffffc02013a0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013a2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013a4:	f11c                	sd	a5,32(a0)
ffffffffc02013a6:	0141                	addi	sp,sp,16
ffffffffc02013a8:	8082                	ret
            base->property += p->property;
ffffffffc02013aa:	ff872783          	lw	a5,-8(a4)
ffffffffc02013ae:	fe870693          	addi	a3,a4,-24
ffffffffc02013b2:	9dbd                	addw	a1,a1,a5
ffffffffc02013b4:	cd0c                	sw	a1,24(a0)
ffffffffc02013b6:	57f5                	li	a5,-3
ffffffffc02013b8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013bc:	6314                	ld	a3,0(a4)
ffffffffc02013be:	671c                	ld	a5,8(a4)
}
ffffffffc02013c0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013c2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013c4:	e394                	sd	a3,0(a5)
ffffffffc02013c6:	0141                	addi	sp,sp,16
ffffffffc02013c8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013ca:	00004697          	auipc	a3,0x4
ffffffffc02013ce:	f1e68693          	addi	a3,a3,-226 # ffffffffc02052e8 <commands+0xab8>
ffffffffc02013d2:	00004617          	auipc	a2,0x4
ffffffffc02013d6:	bb660613          	addi	a2,a2,-1098 # ffffffffc0204f88 <commands+0x758>
ffffffffc02013da:	08300593          	li	a1,131
ffffffffc02013de:	00004517          	auipc	a0,0x4
ffffffffc02013e2:	bc250513          	addi	a0,a0,-1086 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02013e6:	f8ffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013ea:	00004697          	auipc	a3,0x4
ffffffffc02013ee:	ef668693          	addi	a3,a3,-266 # ffffffffc02052e0 <commands+0xab0>
ffffffffc02013f2:	00004617          	auipc	a2,0x4
ffffffffc02013f6:	b9660613          	addi	a2,a2,-1130 # ffffffffc0204f88 <commands+0x758>
ffffffffc02013fa:	08000593          	li	a1,128
ffffffffc02013fe:	00004517          	auipc	a0,0x4
ffffffffc0201402:	ba250513          	addi	a0,a0,-1118 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0201406:	f6ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020140a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020140a:	c959                	beqz	a0,ffffffffc02014a0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020140c:	00010597          	auipc	a1,0x10
ffffffffc0201410:	c3458593          	addi	a1,a1,-972 # ffffffffc0211040 <free_area>
ffffffffc0201414:	0105a803          	lw	a6,16(a1)
ffffffffc0201418:	862a                	mv	a2,a0
ffffffffc020141a:	02081793          	slli	a5,a6,0x20
ffffffffc020141e:	9381                	srli	a5,a5,0x20
ffffffffc0201420:	00a7ee63          	bltu	a5,a0,ffffffffc020143c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201424:	87ae                	mv	a5,a1
ffffffffc0201426:	a801                	j	ffffffffc0201436 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201428:	ff87a703          	lw	a4,-8(a5)
ffffffffc020142c:	02071693          	slli	a3,a4,0x20
ffffffffc0201430:	9281                	srli	a3,a3,0x20
ffffffffc0201432:	00c6f763          	bgeu	a3,a2,ffffffffc0201440 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201436:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201438:	feb798e3          	bne	a5,a1,ffffffffc0201428 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020143c:	4501                	li	a0,0
}
ffffffffc020143e:	8082                	ret
    return listelm->prev;
ffffffffc0201440:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201444:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201448:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020144c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201450:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201454:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201458:	02d67b63          	bgeu	a2,a3,ffffffffc020148e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020145c:	00361693          	slli	a3,a2,0x3
ffffffffc0201460:	96b2                	add	a3,a3,a2
ffffffffc0201462:	068e                	slli	a3,a3,0x3
ffffffffc0201464:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201466:	41c7073b          	subw	a4,a4,t3
ffffffffc020146a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020146c:	00868613          	addi	a2,a3,8
ffffffffc0201470:	4709                	li	a4,2
ffffffffc0201472:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201476:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020147a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020147e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201482:	e310                	sd	a2,0(a4)
ffffffffc0201484:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201488:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020148a:	0316b023          	sd	a7,32(a3)
ffffffffc020148e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201492:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201496:	5775                	li	a4,-3
ffffffffc0201498:	17a1                	addi	a5,a5,-24
ffffffffc020149a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020149e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014a0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014a2:	00004697          	auipc	a3,0x4
ffffffffc02014a6:	e3e68693          	addi	a3,a3,-450 # ffffffffc02052e0 <commands+0xab0>
ffffffffc02014aa:	00004617          	auipc	a2,0x4
ffffffffc02014ae:	ade60613          	addi	a2,a2,-1314 # ffffffffc0204f88 <commands+0x758>
ffffffffc02014b2:	06200593          	li	a1,98
ffffffffc02014b6:	00004517          	auipc	a0,0x4
ffffffffc02014ba:	aea50513          	addi	a0,a0,-1302 # ffffffffc0204fa0 <commands+0x770>
default_alloc_pages(size_t n) {
ffffffffc02014be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014c0:	eb5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014c4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014c4:	1141                	addi	sp,sp,-16
ffffffffc02014c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014c8:	c9e1                	beqz	a1,ffffffffc0201598 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014ca:	00359693          	slli	a3,a1,0x3
ffffffffc02014ce:	96ae                	add	a3,a3,a1
ffffffffc02014d0:	068e                	slli	a3,a3,0x3
ffffffffc02014d2:	96aa                	add	a3,a3,a0
ffffffffc02014d4:	87aa                	mv	a5,a0
ffffffffc02014d6:	00d50f63          	beq	a0,a3,ffffffffc02014f4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014da:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014dc:	8b05                	andi	a4,a4,1
ffffffffc02014de:	cf49                	beqz	a4,ffffffffc0201578 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014e0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014e4:	0007b423          	sd	zero,8(a5)
ffffffffc02014e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014ec:	04878793          	addi	a5,a5,72
ffffffffc02014f0:	fed795e3          	bne	a5,a3,ffffffffc02014da <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014f4:	2581                	sext.w	a1,a1
ffffffffc02014f6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014f8:	4789                	li	a5,2
ffffffffc02014fa:	00850713          	addi	a4,a0,8
ffffffffc02014fe:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201502:	00010697          	auipc	a3,0x10
ffffffffc0201506:	b3e68693          	addi	a3,a3,-1218 # ffffffffc0211040 <free_area>
ffffffffc020150a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020150c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020150e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201512:	9db9                	addw	a1,a1,a4
ffffffffc0201514:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201516:	04d78a63          	beq	a5,a3,ffffffffc020156a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020151a:	fe078713          	addi	a4,a5,-32
ffffffffc020151e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201522:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201524:	00e56a63          	bltu	a0,a4,ffffffffc0201538 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201528:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020152a:	02d70263          	beq	a4,a3,ffffffffc020154e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020152e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201530:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201534:	fee57ae3          	bgeu	a0,a4,ffffffffc0201528 <default_init_memmap+0x64>
ffffffffc0201538:	c199                	beqz	a1,ffffffffc020153e <default_init_memmap+0x7a>
ffffffffc020153a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020153e:	6398                	ld	a4,0(a5)
}
ffffffffc0201540:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201542:	e390                	sd	a2,0(a5)
ffffffffc0201544:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201546:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201548:	f118                	sd	a4,32(a0)
ffffffffc020154a:	0141                	addi	sp,sp,16
ffffffffc020154c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020154e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201550:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201552:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201554:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201556:	00d70663          	beq	a4,a3,ffffffffc0201562 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020155a:	8832                	mv	a6,a2
ffffffffc020155c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020155e:	87ba                	mv	a5,a4
ffffffffc0201560:	bfc1                	j	ffffffffc0201530 <default_init_memmap+0x6c>
}
ffffffffc0201562:	60a2                	ld	ra,8(sp)
ffffffffc0201564:	e290                	sd	a2,0(a3)
ffffffffc0201566:	0141                	addi	sp,sp,16
ffffffffc0201568:	8082                	ret
ffffffffc020156a:	60a2                	ld	ra,8(sp)
ffffffffc020156c:	e390                	sd	a2,0(a5)
ffffffffc020156e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201570:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201572:	f11c                	sd	a5,32(a0)
ffffffffc0201574:	0141                	addi	sp,sp,16
ffffffffc0201576:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201578:	00004697          	auipc	a3,0x4
ffffffffc020157c:	d9868693          	addi	a3,a3,-616 # ffffffffc0205310 <commands+0xae0>
ffffffffc0201580:	00004617          	auipc	a2,0x4
ffffffffc0201584:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204f88 <commands+0x758>
ffffffffc0201588:	04900593          	li	a1,73
ffffffffc020158c:	00004517          	auipc	a0,0x4
ffffffffc0201590:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204fa0 <commands+0x770>
ffffffffc0201594:	de1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201598:	00004697          	auipc	a3,0x4
ffffffffc020159c:	d4868693          	addi	a3,a3,-696 # ffffffffc02052e0 <commands+0xab0>
ffffffffc02015a0:	00004617          	auipc	a2,0x4
ffffffffc02015a4:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204f88 <commands+0x758>
ffffffffc02015a8:	04600593          	li	a1,70
ffffffffc02015ac:	00004517          	auipc	a0,0x4
ffffffffc02015b0:	9f450513          	addi	a0,a0,-1548 # ffffffffc0204fa0 <commands+0x770>
ffffffffc02015b4:	dc1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015b8 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015b8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015ba:	00004617          	auipc	a2,0x4
ffffffffc02015be:	db660613          	addi	a2,a2,-586 # ffffffffc0205370 <default_pmm_manager+0x38>
ffffffffc02015c2:	06500593          	li	a1,101
ffffffffc02015c6:	00004517          	auipc	a0,0x4
ffffffffc02015ca:	dca50513          	addi	a0,a0,-566 # ffffffffc0205390 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015ce:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015d0:	da5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015d4 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015d4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015d6:	00004617          	auipc	a2,0x4
ffffffffc02015da:	dca60613          	addi	a2,a2,-566 # ffffffffc02053a0 <default_pmm_manager+0x68>
ffffffffc02015de:	07000593          	li	a1,112
ffffffffc02015e2:	00004517          	auipc	a0,0x4
ffffffffc02015e6:	dae50513          	addi	a0,a0,-594 # ffffffffc0205390 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015ea:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015ec:	d89fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015f0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015f0:	7139                	addi	sp,sp,-64
ffffffffc02015f2:	f426                	sd	s1,40(sp)
ffffffffc02015f4:	f04a                	sd	s2,32(sp)
ffffffffc02015f6:	ec4e                	sd	s3,24(sp)
ffffffffc02015f8:	e852                	sd	s4,16(sp)
ffffffffc02015fa:	e456                	sd	s5,8(sp)
ffffffffc02015fc:	e05a                	sd	s6,0(sp)
ffffffffc02015fe:	fc06                	sd	ra,56(sp)
ffffffffc0201600:	f822                	sd	s0,48(sp)
ffffffffc0201602:	84aa                	mv	s1,a0
ffffffffc0201604:	00010917          	auipc	s2,0x10
ffffffffc0201608:	f3490913          	addi	s2,s2,-204 # ffffffffc0211538 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020160c:	4a05                	li	s4,1
ffffffffc020160e:	00010a97          	auipc	s5,0x10
ffffffffc0201612:	f4aa8a93          	addi	s5,s5,-182 # ffffffffc0211558 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201616:	0005099b          	sext.w	s3,a0
ffffffffc020161a:	00010b17          	auipc	s6,0x10
ffffffffc020161e:	f4eb0b13          	addi	s6,s6,-178 # ffffffffc0211568 <check_mm_struct>
ffffffffc0201622:	a01d                	j	ffffffffc0201648 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201624:	00093783          	ld	a5,0(s2)
ffffffffc0201628:	6f9c                	ld	a5,24(a5)
ffffffffc020162a:	9782                	jalr	a5
ffffffffc020162c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020162e:	4601                	li	a2,0
ffffffffc0201630:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201632:	ec0d                	bnez	s0,ffffffffc020166c <alloc_pages+0x7c>
ffffffffc0201634:	029a6c63          	bltu	s4,s1,ffffffffc020166c <alloc_pages+0x7c>
ffffffffc0201638:	000aa783          	lw	a5,0(s5)
ffffffffc020163c:	2781                	sext.w	a5,a5
ffffffffc020163e:	c79d                	beqz	a5,ffffffffc020166c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201640:	000b3503          	ld	a0,0(s6)
ffffffffc0201644:	189010ef          	jal	ra,ffffffffc0202fcc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201648:	100027f3          	csrr	a5,sstatus
ffffffffc020164c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020164e:	8526                	mv	a0,s1
ffffffffc0201650:	dbf1                	beqz	a5,ffffffffc0201624 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201652:	e9dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201656:	00093783          	ld	a5,0(s2)
ffffffffc020165a:	8526                	mv	a0,s1
ffffffffc020165c:	6f9c                	ld	a5,24(a5)
ffffffffc020165e:	9782                	jalr	a5
ffffffffc0201660:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201662:	e87fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201666:	4601                	li	a2,0
ffffffffc0201668:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020166a:	d469                	beqz	s0,ffffffffc0201634 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020166c:	70e2                	ld	ra,56(sp)
ffffffffc020166e:	8522                	mv	a0,s0
ffffffffc0201670:	7442                	ld	s0,48(sp)
ffffffffc0201672:	74a2                	ld	s1,40(sp)
ffffffffc0201674:	7902                	ld	s2,32(sp)
ffffffffc0201676:	69e2                	ld	s3,24(sp)
ffffffffc0201678:	6a42                	ld	s4,16(sp)
ffffffffc020167a:	6aa2                	ld	s5,8(sp)
ffffffffc020167c:	6b02                	ld	s6,0(sp)
ffffffffc020167e:	6121                	addi	sp,sp,64
ffffffffc0201680:	8082                	ret

ffffffffc0201682 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201682:	100027f3          	csrr	a5,sstatus
ffffffffc0201686:	8b89                	andi	a5,a5,2
ffffffffc0201688:	e799                	bnez	a5,ffffffffc0201696 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020168a:	00010797          	auipc	a5,0x10
ffffffffc020168e:	eae7b783          	ld	a5,-338(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201692:	739c                	ld	a5,32(a5)
ffffffffc0201694:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201696:	1101                	addi	sp,sp,-32
ffffffffc0201698:	ec06                	sd	ra,24(sp)
ffffffffc020169a:	e822                	sd	s0,16(sp)
ffffffffc020169c:	e426                	sd	s1,8(sp)
ffffffffc020169e:	842a                	mv	s0,a0
ffffffffc02016a0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016a2:	e4dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016a6:	00010797          	auipc	a5,0x10
ffffffffc02016aa:	e927b783          	ld	a5,-366(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016ae:	739c                	ld	a5,32(a5)
ffffffffc02016b0:	85a6                	mv	a1,s1
ffffffffc02016b2:	8522                	mv	a0,s0
ffffffffc02016b4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016b6:	6442                	ld	s0,16(sp)
ffffffffc02016b8:	60e2                	ld	ra,24(sp)
ffffffffc02016ba:	64a2                	ld	s1,8(sp)
ffffffffc02016bc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016be:	e2bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc02016c2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c2:	100027f3          	csrr	a5,sstatus
ffffffffc02016c6:	8b89                	andi	a5,a5,2
ffffffffc02016c8:	e799                	bnez	a5,ffffffffc02016d6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016ca:	00010797          	auipc	a5,0x10
ffffffffc02016ce:	e6e7b783          	ld	a5,-402(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016d2:	779c                	ld	a5,40(a5)
ffffffffc02016d4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016d6:	1141                	addi	sp,sp,-16
ffffffffc02016d8:	e406                	sd	ra,8(sp)
ffffffffc02016da:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016dc:	e13fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016e0:	00010797          	auipc	a5,0x10
ffffffffc02016e4:	e587b783          	ld	a5,-424(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016e8:	779c                	ld	a5,40(a5)
ffffffffc02016ea:	9782                	jalr	a5
ffffffffc02016ec:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016ee:	dfbfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016f2:	60a2                	ld	ra,8(sp)
ffffffffc02016f4:	8522                	mv	a0,s0
ffffffffc02016f6:	6402                	ld	s0,0(sp)
ffffffffc02016f8:	0141                	addi	sp,sp,16
ffffffffc02016fa:	8082                	ret

ffffffffc02016fc <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016fc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201700:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201704:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201706:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201708:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020170a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020170e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201710:	f84a                	sd	s2,48(sp)
ffffffffc0201712:	f44e                	sd	s3,40(sp)
ffffffffc0201714:	f052                	sd	s4,32(sp)
ffffffffc0201716:	e486                	sd	ra,72(sp)
ffffffffc0201718:	e0a2                	sd	s0,64(sp)
ffffffffc020171a:	ec56                	sd	s5,24(sp)
ffffffffc020171c:	e85a                	sd	s6,16(sp)
ffffffffc020171e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201720:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201724:	892e                	mv	s2,a1
ffffffffc0201726:	8a32                	mv	s4,a2
ffffffffc0201728:	00010997          	auipc	s3,0x10
ffffffffc020172c:	e0098993          	addi	s3,s3,-512 # ffffffffc0211528 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201730:	efb5                	bnez	a5,ffffffffc02017ac <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201732:	14060c63          	beqz	a2,ffffffffc020188a <get_pte+0x18e>
ffffffffc0201736:	4505                	li	a0,1
ffffffffc0201738:	eb9ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc020173c:	842a                	mv	s0,a0
ffffffffc020173e:	14050663          	beqz	a0,ffffffffc020188a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201742:	00010b97          	auipc	s7,0x10
ffffffffc0201746:	deeb8b93          	addi	s7,s7,-530 # ffffffffc0211530 <pages>
ffffffffc020174a:	000bb503          	ld	a0,0(s7)
ffffffffc020174e:	00005b17          	auipc	s6,0x5
ffffffffc0201752:	de2b3b03          	ld	s6,-542(s6) # ffffffffc0206530 <error_string+0x38>
ffffffffc0201756:	00080ab7          	lui	s5,0x80
ffffffffc020175a:	40a40533          	sub	a0,s0,a0
ffffffffc020175e:	850d                	srai	a0,a0,0x3
ffffffffc0201760:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201764:	00010997          	auipc	s3,0x10
ffffffffc0201768:	dc498993          	addi	s3,s3,-572 # ffffffffc0211528 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020176c:	4785                	li	a5,1
ffffffffc020176e:	0009b703          	ld	a4,0(s3)
ffffffffc0201772:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201774:	9556                	add	a0,a0,s5
ffffffffc0201776:	00c51793          	slli	a5,a0,0xc
ffffffffc020177a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020177c:	0532                	slli	a0,a0,0xc
ffffffffc020177e:	14e7fd63          	bgeu	a5,a4,ffffffffc02018d8 <get_pte+0x1dc>
ffffffffc0201782:	00010797          	auipc	a5,0x10
ffffffffc0201786:	dbe7b783          	ld	a5,-578(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc020178a:	6605                	lui	a2,0x1
ffffffffc020178c:	4581                	li	a1,0
ffffffffc020178e:	953e                	add	a0,a0,a5
ffffffffc0201790:	61d020ef          	jal	ra,ffffffffc02045ac <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201794:	000bb683          	ld	a3,0(s7)
ffffffffc0201798:	40d406b3          	sub	a3,s0,a3
ffffffffc020179c:	868d                	srai	a3,a3,0x3
ffffffffc020179e:	036686b3          	mul	a3,a3,s6
ffffffffc02017a2:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017a4:	06aa                	slli	a3,a3,0xa
ffffffffc02017a6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017aa:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02017ac:	77fd                	lui	a5,0xfffff
ffffffffc02017ae:	068a                	slli	a3,a3,0x2
ffffffffc02017b0:	0009b703          	ld	a4,0(s3)
ffffffffc02017b4:	8efd                	and	a3,a3,a5
ffffffffc02017b6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ba:	0ce7fa63          	bgeu	a5,a4,ffffffffc020188e <get_pte+0x192>
ffffffffc02017be:	00010a97          	auipc	s5,0x10
ffffffffc02017c2:	d82a8a93          	addi	s5,s5,-638 # ffffffffc0211540 <va_pa_offset>
ffffffffc02017c6:	000ab403          	ld	s0,0(s5)
ffffffffc02017ca:	01595793          	srli	a5,s2,0x15
ffffffffc02017ce:	1ff7f793          	andi	a5,a5,511
ffffffffc02017d2:	96a2                	add	a3,a3,s0
ffffffffc02017d4:	00379413          	slli	s0,a5,0x3
ffffffffc02017d8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017da:	6014                	ld	a3,0(s0)
ffffffffc02017dc:	0016f793          	andi	a5,a3,1
ffffffffc02017e0:	ebad                	bnez	a5,ffffffffc0201852 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017e2:	0a0a0463          	beqz	s4,ffffffffc020188a <get_pte+0x18e>
ffffffffc02017e6:	4505                	li	a0,1
ffffffffc02017e8:	e09ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc02017ec:	84aa                	mv	s1,a0
ffffffffc02017ee:	cd51                	beqz	a0,ffffffffc020188a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017f0:	00010b97          	auipc	s7,0x10
ffffffffc02017f4:	d40b8b93          	addi	s7,s7,-704 # ffffffffc0211530 <pages>
ffffffffc02017f8:	000bb503          	ld	a0,0(s7)
ffffffffc02017fc:	00005b17          	auipc	s6,0x5
ffffffffc0201800:	d34b3b03          	ld	s6,-716(s6) # ffffffffc0206530 <error_string+0x38>
ffffffffc0201804:	00080a37          	lui	s4,0x80
ffffffffc0201808:	40a48533          	sub	a0,s1,a0
ffffffffc020180c:	850d                	srai	a0,a0,0x3
ffffffffc020180e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201812:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201814:	0009b703          	ld	a4,0(s3)
ffffffffc0201818:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181a:	9552                	add	a0,a0,s4
ffffffffc020181c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201820:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201822:	0532                	slli	a0,a0,0xc
ffffffffc0201824:	08e7fd63          	bgeu	a5,a4,ffffffffc02018be <get_pte+0x1c2>
ffffffffc0201828:	000ab783          	ld	a5,0(s5)
ffffffffc020182c:	6605                	lui	a2,0x1
ffffffffc020182e:	4581                	li	a1,0
ffffffffc0201830:	953e                	add	a0,a0,a5
ffffffffc0201832:	57b020ef          	jal	ra,ffffffffc02045ac <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201836:	000bb683          	ld	a3,0(s7)
ffffffffc020183a:	40d486b3          	sub	a3,s1,a3
ffffffffc020183e:	868d                	srai	a3,a3,0x3
ffffffffc0201840:	036686b3          	mul	a3,a3,s6
ffffffffc0201844:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201846:	06aa                	slli	a3,a3,0xa
ffffffffc0201848:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020184c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020184e:	0009b703          	ld	a4,0(s3)
ffffffffc0201852:	068a                	slli	a3,a3,0x2
ffffffffc0201854:	757d                	lui	a0,0xfffff
ffffffffc0201856:	8ee9                	and	a3,a3,a0
ffffffffc0201858:	00c6d793          	srli	a5,a3,0xc
ffffffffc020185c:	04e7f563          	bgeu	a5,a4,ffffffffc02018a6 <get_pte+0x1aa>
ffffffffc0201860:	000ab503          	ld	a0,0(s5)
ffffffffc0201864:	00c95913          	srli	s2,s2,0xc
ffffffffc0201868:	1ff97913          	andi	s2,s2,511
ffffffffc020186c:	96aa                	add	a3,a3,a0
ffffffffc020186e:	00391513          	slli	a0,s2,0x3
ffffffffc0201872:	9536                	add	a0,a0,a3
}
ffffffffc0201874:	60a6                	ld	ra,72(sp)
ffffffffc0201876:	6406                	ld	s0,64(sp)
ffffffffc0201878:	74e2                	ld	s1,56(sp)
ffffffffc020187a:	7942                	ld	s2,48(sp)
ffffffffc020187c:	79a2                	ld	s3,40(sp)
ffffffffc020187e:	7a02                	ld	s4,32(sp)
ffffffffc0201880:	6ae2                	ld	s5,24(sp)
ffffffffc0201882:	6b42                	ld	s6,16(sp)
ffffffffc0201884:	6ba2                	ld	s7,8(sp)
ffffffffc0201886:	6161                	addi	sp,sp,80
ffffffffc0201888:	8082                	ret
            return NULL;
ffffffffc020188a:	4501                	li	a0,0
ffffffffc020188c:	b7e5                	j	ffffffffc0201874 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020188e:	00004617          	auipc	a2,0x4
ffffffffc0201892:	b3a60613          	addi	a2,a2,-1222 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc0201896:	10200593          	li	a1,258
ffffffffc020189a:	00004517          	auipc	a0,0x4
ffffffffc020189e:	b5650513          	addi	a0,a0,-1194 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02018a2:	ad3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018a6:	00004617          	auipc	a2,0x4
ffffffffc02018aa:	b2260613          	addi	a2,a2,-1246 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc02018ae:	10f00593          	li	a1,271
ffffffffc02018b2:	00004517          	auipc	a0,0x4
ffffffffc02018b6:	b3e50513          	addi	a0,a0,-1218 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02018ba:	abbfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018be:	86aa                	mv	a3,a0
ffffffffc02018c0:	00004617          	auipc	a2,0x4
ffffffffc02018c4:	b0860613          	addi	a2,a2,-1272 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc02018c8:	10b00593          	li	a1,267
ffffffffc02018cc:	00004517          	auipc	a0,0x4
ffffffffc02018d0:	b2450513          	addi	a0,a0,-1244 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02018d4:	aa1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018d8:	86aa                	mv	a3,a0
ffffffffc02018da:	00004617          	auipc	a2,0x4
ffffffffc02018de:	aee60613          	addi	a2,a2,-1298 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc02018e2:	0ff00593          	li	a1,255
ffffffffc02018e6:	00004517          	auipc	a0,0x4
ffffffffc02018ea:	b0a50513          	addi	a0,a0,-1270 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02018ee:	a87fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02018f2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018f2:	1141                	addi	sp,sp,-16
ffffffffc02018f4:	e022                	sd	s0,0(sp)
ffffffffc02018f6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018f8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018fa:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018fc:	e01ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201900:	c011                	beqz	s0,ffffffffc0201904 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201902:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201904:	c511                	beqz	a0,ffffffffc0201910 <get_page+0x1e>
ffffffffc0201906:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201908:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020190a:	0017f713          	andi	a4,a5,1
ffffffffc020190e:	e709                	bnez	a4,ffffffffc0201918 <get_page+0x26>
}
ffffffffc0201910:	60a2                	ld	ra,8(sp)
ffffffffc0201912:	6402                	ld	s0,0(sp)
ffffffffc0201914:	0141                	addi	sp,sp,16
ffffffffc0201916:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201918:	078a                	slli	a5,a5,0x2
ffffffffc020191a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020191c:	00010717          	auipc	a4,0x10
ffffffffc0201920:	c0c73703          	ld	a4,-1012(a4) # ffffffffc0211528 <npage>
ffffffffc0201924:	02e7f263          	bgeu	a5,a4,ffffffffc0201948 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201928:	fff80537          	lui	a0,0xfff80
ffffffffc020192c:	97aa                	add	a5,a5,a0
ffffffffc020192e:	60a2                	ld	ra,8(sp)
ffffffffc0201930:	6402                	ld	s0,0(sp)
ffffffffc0201932:	00379513          	slli	a0,a5,0x3
ffffffffc0201936:	97aa                	add	a5,a5,a0
ffffffffc0201938:	078e                	slli	a5,a5,0x3
ffffffffc020193a:	00010517          	auipc	a0,0x10
ffffffffc020193e:	bf653503          	ld	a0,-1034(a0) # ffffffffc0211530 <pages>
ffffffffc0201942:	953e                	add	a0,a0,a5
ffffffffc0201944:	0141                	addi	sp,sp,16
ffffffffc0201946:	8082                	ret
ffffffffc0201948:	c71ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>

ffffffffc020194c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020194c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020194e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201950:	ec06                	sd	ra,24(sp)
ffffffffc0201952:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201954:	da9ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    if (ptep != NULL) {
ffffffffc0201958:	c511                	beqz	a0,ffffffffc0201964 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020195a:	611c                	ld	a5,0(a0)
ffffffffc020195c:	842a                	mv	s0,a0
ffffffffc020195e:	0017f713          	andi	a4,a5,1
ffffffffc0201962:	e709                	bnez	a4,ffffffffc020196c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201964:	60e2                	ld	ra,24(sp)
ffffffffc0201966:	6442                	ld	s0,16(sp)
ffffffffc0201968:	6105                	addi	sp,sp,32
ffffffffc020196a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020196c:	078a                	slli	a5,a5,0x2
ffffffffc020196e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201970:	00010717          	auipc	a4,0x10
ffffffffc0201974:	bb873703          	ld	a4,-1096(a4) # ffffffffc0211528 <npage>
ffffffffc0201978:	06e7f563          	bgeu	a5,a4,ffffffffc02019e2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020197c:	fff80737          	lui	a4,0xfff80
ffffffffc0201980:	97ba                	add	a5,a5,a4
ffffffffc0201982:	00379513          	slli	a0,a5,0x3
ffffffffc0201986:	97aa                	add	a5,a5,a0
ffffffffc0201988:	078e                	slli	a5,a5,0x3
ffffffffc020198a:	00010517          	auipc	a0,0x10
ffffffffc020198e:	ba653503          	ld	a0,-1114(a0) # ffffffffc0211530 <pages>
ffffffffc0201992:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201994:	411c                	lw	a5,0(a0)
ffffffffc0201996:	fff7871b          	addiw	a4,a5,-1
ffffffffc020199a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020199c:	cb09                	beqz	a4,ffffffffc02019ae <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020199e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019a2:	12000073          	sfence.vma
}
ffffffffc02019a6:	60e2                	ld	ra,24(sp)
ffffffffc02019a8:	6442                	ld	s0,16(sp)
ffffffffc02019aa:	6105                	addi	sp,sp,32
ffffffffc02019ac:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019ae:	100027f3          	csrr	a5,sstatus
ffffffffc02019b2:	8b89                	andi	a5,a5,2
ffffffffc02019b4:	eb89                	bnez	a5,ffffffffc02019c6 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019b6:	00010797          	auipc	a5,0x10
ffffffffc02019ba:	b827b783          	ld	a5,-1150(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019be:	739c                	ld	a5,32(a5)
ffffffffc02019c0:	4585                	li	a1,1
ffffffffc02019c2:	9782                	jalr	a5
    if (flag) {
ffffffffc02019c4:	bfe9                	j	ffffffffc020199e <page_remove+0x52>
        intr_disable();
ffffffffc02019c6:	e42a                	sd	a0,8(sp)
ffffffffc02019c8:	b27fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02019cc:	00010797          	auipc	a5,0x10
ffffffffc02019d0:	b6c7b783          	ld	a5,-1172(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019d4:	739c                	ld	a5,32(a5)
ffffffffc02019d6:	6522                	ld	a0,8(sp)
ffffffffc02019d8:	4585                	li	a1,1
ffffffffc02019da:	9782                	jalr	a5
        intr_enable();
ffffffffc02019dc:	b0dfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019e0:	bf7d                	j	ffffffffc020199e <page_remove+0x52>
ffffffffc02019e2:	bd7ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>

ffffffffc02019e6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019e6:	7179                	addi	sp,sp,-48
ffffffffc02019e8:	87b2                	mv	a5,a2
ffffffffc02019ea:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019ec:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019ee:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019f0:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019f2:	ec26                	sd	s1,24(sp)
ffffffffc02019f4:	f406                	sd	ra,40(sp)
ffffffffc02019f6:	e84a                	sd	s2,16(sp)
ffffffffc02019f8:	e44e                	sd	s3,8(sp)
ffffffffc02019fa:	e052                	sd	s4,0(sp)
ffffffffc02019fc:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019fe:	cffff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    if (ptep == NULL) {
ffffffffc0201a02:	cd71                	beqz	a0,ffffffffc0201ade <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201a04:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a06:	611c                	ld	a5,0(a0)
ffffffffc0201a08:	89aa                	mv	s3,a0
ffffffffc0201a0a:	0016871b          	addiw	a4,a3,1
ffffffffc0201a0e:	c018                	sw	a4,0(s0)
ffffffffc0201a10:	0017f713          	andi	a4,a5,1
ffffffffc0201a14:	e331                	bnez	a4,ffffffffc0201a58 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a16:	00010797          	auipc	a5,0x10
ffffffffc0201a1a:	b1a7b783          	ld	a5,-1254(a5) # ffffffffc0211530 <pages>
ffffffffc0201a1e:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a22:	878d                	srai	a5,a5,0x3
ffffffffc0201a24:	00005417          	auipc	s0,0x5
ffffffffc0201a28:	b0c43403          	ld	s0,-1268(s0) # ffffffffc0206530 <error_string+0x38>
ffffffffc0201a2c:	028787b3          	mul	a5,a5,s0
ffffffffc0201a30:	00080437          	lui	s0,0x80
ffffffffc0201a34:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a36:	07aa                	slli	a5,a5,0xa
ffffffffc0201a38:	8cdd                	or	s1,s1,a5
ffffffffc0201a3a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a3e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a42:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a46:	4501                	li	a0,0
}
ffffffffc0201a48:	70a2                	ld	ra,40(sp)
ffffffffc0201a4a:	7402                	ld	s0,32(sp)
ffffffffc0201a4c:	64e2                	ld	s1,24(sp)
ffffffffc0201a4e:	6942                	ld	s2,16(sp)
ffffffffc0201a50:	69a2                	ld	s3,8(sp)
ffffffffc0201a52:	6a02                	ld	s4,0(sp)
ffffffffc0201a54:	6145                	addi	sp,sp,48
ffffffffc0201a56:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a58:	00279713          	slli	a4,a5,0x2
ffffffffc0201a5c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a5e:	00010797          	auipc	a5,0x10
ffffffffc0201a62:	aca7b783          	ld	a5,-1334(a5) # ffffffffc0211528 <npage>
ffffffffc0201a66:	06f77e63          	bgeu	a4,a5,ffffffffc0201ae2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a6a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a6e:	973e                	add	a4,a4,a5
ffffffffc0201a70:	00010a17          	auipc	s4,0x10
ffffffffc0201a74:	ac0a0a13          	addi	s4,s4,-1344 # ffffffffc0211530 <pages>
ffffffffc0201a78:	000a3783          	ld	a5,0(s4)
ffffffffc0201a7c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a80:	993a                	add	s2,s2,a4
ffffffffc0201a82:	090e                	slli	s2,s2,0x3
ffffffffc0201a84:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a86:	03240063          	beq	s0,s2,ffffffffc0201aa6 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a8a:	00092783          	lw	a5,0(s2)
ffffffffc0201a8e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a92:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a96:	cb11                	beqz	a4,ffffffffc0201aaa <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a98:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a9c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201aa0:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201aa4:	bfad                	j	ffffffffc0201a1e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201aa6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201aa8:	bf9d                	j	ffffffffc0201a1e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201aaa:	100027f3          	csrr	a5,sstatus
ffffffffc0201aae:	8b89                	andi	a5,a5,2
ffffffffc0201ab0:	eb91                	bnez	a5,ffffffffc0201ac4 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201ab2:	00010797          	auipc	a5,0x10
ffffffffc0201ab6:	a867b783          	ld	a5,-1402(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201aba:	739c                	ld	a5,32(a5)
ffffffffc0201abc:	4585                	li	a1,1
ffffffffc0201abe:	854a                	mv	a0,s2
ffffffffc0201ac0:	9782                	jalr	a5
    if (flag) {
ffffffffc0201ac2:	bfd9                	j	ffffffffc0201a98 <page_insert+0xb2>
        intr_disable();
ffffffffc0201ac4:	a2bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201ac8:	00010797          	auipc	a5,0x10
ffffffffc0201acc:	a707b783          	ld	a5,-1424(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201ad0:	739c                	ld	a5,32(a5)
ffffffffc0201ad2:	4585                	li	a1,1
ffffffffc0201ad4:	854a                	mv	a0,s2
ffffffffc0201ad6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ad8:	a11fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201adc:	bf75                	j	ffffffffc0201a98 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201ade:	5571                	li	a0,-4
ffffffffc0201ae0:	b7a5                	j	ffffffffc0201a48 <page_insert+0x62>
ffffffffc0201ae2:	ad7ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>

ffffffffc0201ae6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201ae6:	00004797          	auipc	a5,0x4
ffffffffc0201aea:	85278793          	addi	a5,a5,-1966 # ffffffffc0205338 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201aee:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201af0:	7159                	addi	sp,sp,-112
ffffffffc0201af2:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201af4:	00004517          	auipc	a0,0x4
ffffffffc0201af8:	90c50513          	addi	a0,a0,-1780 # ffffffffc0205400 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201afc:	00010b97          	auipc	s7,0x10
ffffffffc0201b00:	a3cb8b93          	addi	s7,s7,-1476 # ffffffffc0211538 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b04:	f486                	sd	ra,104(sp)
ffffffffc0201b06:	f0a2                	sd	s0,96(sp)
ffffffffc0201b08:	eca6                	sd	s1,88(sp)
ffffffffc0201b0a:	e8ca                	sd	s2,80(sp)
ffffffffc0201b0c:	e4ce                	sd	s3,72(sp)
ffffffffc0201b0e:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b10:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201b14:	e0d2                	sd	s4,64(sp)
ffffffffc0201b16:	fc56                	sd	s5,56(sp)
ffffffffc0201b18:	f062                	sd	s8,32(sp)
ffffffffc0201b1a:	ec66                	sd	s9,24(sp)
ffffffffc0201b1c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b1e:	d9cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b22:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b26:	4445                	li	s0,17
ffffffffc0201b28:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201b2c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b2e:	00010997          	auipc	s3,0x10
ffffffffc0201b32:	a1298993          	addi	s3,s3,-1518 # ffffffffc0211540 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b36:	00010497          	auipc	s1,0x10
ffffffffc0201b3a:	9f248493          	addi	s1,s1,-1550 # ffffffffc0211528 <npage>
    pmm_manager->init();
ffffffffc0201b3e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b40:	57f5                	li	a5,-3
ffffffffc0201b42:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b44:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b48:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b4c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b50:	00004517          	auipc	a0,0x4
ffffffffc0201b54:	8c850513          	addi	a0,a0,-1848 # ffffffffc0205418 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b58:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b5c:	d5efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b60:	00004517          	auipc	a0,0x4
ffffffffc0201b64:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205448 <default_pmm_manager+0x110>
ffffffffc0201b68:	d52fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b6c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b70:	16fd                	addi	a3,a3,-1
ffffffffc0201b72:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b76:	01591613          	slli	a2,s2,0x15
ffffffffc0201b7a:	00004517          	auipc	a0,0x4
ffffffffc0201b7e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0205460 <default_pmm_manager+0x128>
ffffffffc0201b82:	d38fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b86:	777d                	lui	a4,0xfffff
ffffffffc0201b88:	00011797          	auipc	a5,0x11
ffffffffc0201b8c:	9eb78793          	addi	a5,a5,-1557 # ffffffffc0212573 <end+0xfff>
ffffffffc0201b90:	8ff9                	and	a5,a5,a4
ffffffffc0201b92:	00010b17          	auipc	s6,0x10
ffffffffc0201b96:	99eb0b13          	addi	s6,s6,-1634 # ffffffffc0211530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b9a:	00088737          	lui	a4,0x88
ffffffffc0201b9e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201ba0:	00fb3023          	sd	a5,0(s6)
ffffffffc0201ba4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201ba6:	4701                	li	a4,0
ffffffffc0201ba8:	4505                	li	a0,1
ffffffffc0201baa:	fff805b7          	lui	a1,0xfff80
ffffffffc0201bae:	a019                	j	ffffffffc0201bb4 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201bb0:	000b3783          	ld	a5,0(s6)
ffffffffc0201bb4:	97b6                	add	a5,a5,a3
ffffffffc0201bb6:	07a1                	addi	a5,a5,8
ffffffffc0201bb8:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bbc:	609c                	ld	a5,0(s1)
ffffffffc0201bbe:	0705                	addi	a4,a4,1
ffffffffc0201bc0:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bc4:	00b78633          	add	a2,a5,a1
ffffffffc0201bc8:	fec764e3          	bltu	a4,a2,ffffffffc0201bb0 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bcc:	000b3503          	ld	a0,0(s6)
ffffffffc0201bd0:	00379693          	slli	a3,a5,0x3
ffffffffc0201bd4:	96be                	add	a3,a3,a5
ffffffffc0201bd6:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bda:	972a                	add	a4,a4,a0
ffffffffc0201bdc:	068e                	slli	a3,a3,0x3
ffffffffc0201bde:	96ba                	add	a3,a3,a4
ffffffffc0201be0:	c0200737          	lui	a4,0xc0200
ffffffffc0201be4:	64e6e463          	bltu	a3,a4,ffffffffc020222c <pmm_init+0x746>
ffffffffc0201be8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bec:	4645                	li	a2,17
ffffffffc0201bee:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bf0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201bf2:	4ec6e263          	bltu	a3,a2,ffffffffc02020d6 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bf6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bfa:	00010917          	auipc	s2,0x10
ffffffffc0201bfe:	92690913          	addi	s2,s2,-1754 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c02:	7b9c                	ld	a5,48(a5)
ffffffffc0201c04:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c06:	00004517          	auipc	a0,0x4
ffffffffc0201c0a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc02054b0 <default_pmm_manager+0x178>
ffffffffc0201c0e:	cacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c12:	00007697          	auipc	a3,0x7
ffffffffc0201c16:	3ee68693          	addi	a3,a3,1006 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c1a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c1e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c22:	62f6e163          	bltu	a3,a5,ffffffffc0202244 <pmm_init+0x75e>
ffffffffc0201c26:	0009b783          	ld	a5,0(s3)
ffffffffc0201c2a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c2c:	00010797          	auipc	a5,0x10
ffffffffc0201c30:	8ed7b623          	sd	a3,-1812(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c34:	100027f3          	csrr	a5,sstatus
ffffffffc0201c38:	8b89                	andi	a5,a5,2
ffffffffc0201c3a:	4c079763          	bnez	a5,ffffffffc0202108 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c3e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c42:	779c                	ld	a5,40(a5)
ffffffffc0201c44:	9782                	jalr	a5
ffffffffc0201c46:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c48:	6098                	ld	a4,0(s1)
ffffffffc0201c4a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c4e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c50:	62e7e663          	bltu	a5,a4,ffffffffc020227c <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c54:	00093503          	ld	a0,0(s2)
ffffffffc0201c58:	60050263          	beqz	a0,ffffffffc020225c <pmm_init+0x776>
ffffffffc0201c5c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c60:	5e079e63          	bnez	a5,ffffffffc020225c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c64:	4601                	li	a2,0
ffffffffc0201c66:	4581                	li	a1,0
ffffffffc0201c68:	c8bff0ef          	jal	ra,ffffffffc02018f2 <get_page>
ffffffffc0201c6c:	66051a63          	bnez	a0,ffffffffc02022e0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c70:	4505                	li	a0,1
ffffffffc0201c72:	97fff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0201c76:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c78:	00093503          	ld	a0,0(s2)
ffffffffc0201c7c:	4681                	li	a3,0
ffffffffc0201c7e:	4601                	li	a2,0
ffffffffc0201c80:	85d2                	mv	a1,s4
ffffffffc0201c82:	d65ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201c86:	62051d63          	bnez	a0,ffffffffc02022c0 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c8a:	00093503          	ld	a0,0(s2)
ffffffffc0201c8e:	4601                	li	a2,0
ffffffffc0201c90:	4581                	li	a1,0
ffffffffc0201c92:	a6bff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201c96:	60050563          	beqz	a0,ffffffffc02022a0 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c9a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c9c:	0017f713          	andi	a4,a5,1
ffffffffc0201ca0:	5e070e63          	beqz	a4,ffffffffc020229c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201ca4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ca6:	078a                	slli	a5,a5,0x2
ffffffffc0201ca8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201caa:	56c7ff63          	bgeu	a5,a2,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cae:	fff80737          	lui	a4,0xfff80
ffffffffc0201cb2:	97ba                	add	a5,a5,a4
ffffffffc0201cb4:	000b3683          	ld	a3,0(s6)
ffffffffc0201cb8:	00379713          	slli	a4,a5,0x3
ffffffffc0201cbc:	97ba                	add	a5,a5,a4
ffffffffc0201cbe:	078e                	slli	a5,a5,0x3
ffffffffc0201cc0:	97b6                	add	a5,a5,a3
ffffffffc0201cc2:	14fa18e3          	bne	s4,a5,ffffffffc0202612 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201cc6:	000a2703          	lw	a4,0(s4)
ffffffffc0201cca:	4785                	li	a5,1
ffffffffc0201ccc:	16f71fe3          	bne	a4,a5,ffffffffc020264a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201cd0:	00093503          	ld	a0,0(s2)
ffffffffc0201cd4:	77fd                	lui	a5,0xfffff
ffffffffc0201cd6:	6114                	ld	a3,0(a0)
ffffffffc0201cd8:	068a                	slli	a3,a3,0x2
ffffffffc0201cda:	8efd                	and	a3,a3,a5
ffffffffc0201cdc:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201ce0:	14c779e3          	bgeu	a4,a2,ffffffffc0202632 <pmm_init+0xb4c>
ffffffffc0201ce4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ce8:	96e2                	add	a3,a3,s8
ffffffffc0201cea:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cee:	0a8a                	slli	s5,s5,0x2
ffffffffc0201cf0:	00fafab3          	and	s5,s5,a5
ffffffffc0201cf4:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cf8:	66c7f463          	bgeu	a5,a2,ffffffffc0202360 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cfc:	4601                	li	a2,0
ffffffffc0201cfe:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d00:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d02:	9fbff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d06:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d08:	63551c63          	bne	a0,s5,ffffffffc0202340 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201d0c:	4505                	li	a0,1
ffffffffc0201d0e:	8e3ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0201d12:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d14:	00093503          	ld	a0,0(s2)
ffffffffc0201d18:	46d1                	li	a3,20
ffffffffc0201d1a:	6605                	lui	a2,0x1
ffffffffc0201d1c:	85d6                	mv	a1,s5
ffffffffc0201d1e:	cc9ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201d22:	5c051f63          	bnez	a0,ffffffffc0202300 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d26:	00093503          	ld	a0,0(s2)
ffffffffc0201d2a:	4601                	li	a2,0
ffffffffc0201d2c:	6585                	lui	a1,0x1
ffffffffc0201d2e:	9cfff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201d32:	12050ce3          	beqz	a0,ffffffffc020266a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201d36:	611c                	ld	a5,0(a0)
ffffffffc0201d38:	0107f713          	andi	a4,a5,16
ffffffffc0201d3c:	72070f63          	beqz	a4,ffffffffc020247a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d40:	8b91                	andi	a5,a5,4
ffffffffc0201d42:	6e078c63          	beqz	a5,ffffffffc020243a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d46:	00093503          	ld	a0,0(s2)
ffffffffc0201d4a:	611c                	ld	a5,0(a0)
ffffffffc0201d4c:	8bc1                	andi	a5,a5,16
ffffffffc0201d4e:	6c078663          	beqz	a5,ffffffffc020241a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d52:	000aa703          	lw	a4,0(s5)
ffffffffc0201d56:	4785                	li	a5,1
ffffffffc0201d58:	5cf71463          	bne	a4,a5,ffffffffc0202320 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d5c:	4681                	li	a3,0
ffffffffc0201d5e:	6605                	lui	a2,0x1
ffffffffc0201d60:	85d2                	mv	a1,s4
ffffffffc0201d62:	c85ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201d66:	66051a63          	bnez	a0,ffffffffc02023da <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d6a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d6e:	4789                	li	a5,2
ffffffffc0201d70:	64f71563          	bne	a4,a5,ffffffffc02023ba <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201d74:	000aa783          	lw	a5,0(s5)
ffffffffc0201d78:	62079163          	bnez	a5,ffffffffc020239a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d7c:	00093503          	ld	a0,0(s2)
ffffffffc0201d80:	4601                	li	a2,0
ffffffffc0201d82:	6585                	lui	a1,0x1
ffffffffc0201d84:	979ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201d88:	5e050963          	beqz	a0,ffffffffc020237a <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d8c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d8e:	00177793          	andi	a5,a4,1
ffffffffc0201d92:	50078563          	beqz	a5,ffffffffc020229c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d96:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d98:	00271793          	slli	a5,a4,0x2
ffffffffc0201d9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d9e:	48d7f563          	bgeu	a5,a3,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201da2:	fff806b7          	lui	a3,0xfff80
ffffffffc0201da6:	97b6                	add	a5,a5,a3
ffffffffc0201da8:	000b3603          	ld	a2,0(s6)
ffffffffc0201dac:	00379693          	slli	a3,a5,0x3
ffffffffc0201db0:	97b6                	add	a5,a5,a3
ffffffffc0201db2:	078e                	slli	a5,a5,0x3
ffffffffc0201db4:	97b2                	add	a5,a5,a2
ffffffffc0201db6:	72fa1263          	bne	s4,a5,ffffffffc02024da <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dba:	8b41                	andi	a4,a4,16
ffffffffc0201dbc:	6e071f63          	bnez	a4,ffffffffc02024ba <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201dc0:	00093503          	ld	a0,0(s2)
ffffffffc0201dc4:	4581                	li	a1,0
ffffffffc0201dc6:	b87ff0ef          	jal	ra,ffffffffc020194c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dca:	000a2703          	lw	a4,0(s4)
ffffffffc0201dce:	4785                	li	a5,1
ffffffffc0201dd0:	6cf71563          	bne	a4,a5,ffffffffc020249a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201dd4:	000aa783          	lw	a5,0(s5)
ffffffffc0201dd8:	78079d63          	bnez	a5,ffffffffc0202572 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201ddc:	00093503          	ld	a0,0(s2)
ffffffffc0201de0:	6585                	lui	a1,0x1
ffffffffc0201de2:	b6bff0ef          	jal	ra,ffffffffc020194c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201de6:	000a2783          	lw	a5,0(s4)
ffffffffc0201dea:	76079463          	bnez	a5,ffffffffc0202552 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201dee:	000aa783          	lw	a5,0(s5)
ffffffffc0201df2:	74079063          	bnez	a5,ffffffffc0202532 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201df6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201dfa:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dfc:	000a3783          	ld	a5,0(s4)
ffffffffc0201e00:	078a                	slli	a5,a5,0x2
ffffffffc0201e02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e04:	42c7f263          	bgeu	a5,a2,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e08:	fff80737          	lui	a4,0xfff80
ffffffffc0201e0c:	973e                	add	a4,a4,a5
ffffffffc0201e0e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e12:	000b3503          	ld	a0,0(s6)
ffffffffc0201e16:	97ba                	add	a5,a5,a4
ffffffffc0201e18:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e1a:	00f50733          	add	a4,a0,a5
ffffffffc0201e1e:	4314                	lw	a3,0(a4)
ffffffffc0201e20:	4705                	li	a4,1
ffffffffc0201e22:	6ee69863          	bne	a3,a4,ffffffffc0202512 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e26:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e2a:	00004c97          	auipc	s9,0x4
ffffffffc0201e2e:	706cbc83          	ld	s9,1798(s9) # ffffffffc0206530 <error_string+0x38>
ffffffffc0201e32:	039686b3          	mul	a3,a3,s9
ffffffffc0201e36:	000805b7          	lui	a1,0x80
ffffffffc0201e3a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e3c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e40:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e42:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e44:	6ac77b63          	bgeu	a4,a2,ffffffffc02024fa <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e48:	0009b703          	ld	a4,0(s3)
ffffffffc0201e4c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4e:	629c                	ld	a5,0(a3)
ffffffffc0201e50:	078a                	slli	a5,a5,0x2
ffffffffc0201e52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e54:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e58:	8f8d                	sub	a5,a5,a1
ffffffffc0201e5a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e5e:	97ba                	add	a5,a5,a4
ffffffffc0201e60:	078e                	slli	a5,a5,0x3
ffffffffc0201e62:	953e                	add	a0,a0,a5
ffffffffc0201e64:	100027f3          	csrr	a5,sstatus
ffffffffc0201e68:	8b89                	andi	a5,a5,2
ffffffffc0201e6a:	2e079963          	bnez	a5,ffffffffc020215c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e6e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e72:	4585                	li	a1,1
ffffffffc0201e74:	739c                	ld	a5,32(a5)
ffffffffc0201e76:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e78:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e7c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7e:	078a                	slli	a5,a5,0x2
ffffffffc0201e80:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e82:	3ae7f363          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e86:	fff80737          	lui	a4,0xfff80
ffffffffc0201e8a:	97ba                	add	a5,a5,a4
ffffffffc0201e8c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e90:	00379713          	slli	a4,a5,0x3
ffffffffc0201e94:	97ba                	add	a5,a5,a4
ffffffffc0201e96:	078e                	slli	a5,a5,0x3
ffffffffc0201e98:	953e                	add	a0,a0,a5
ffffffffc0201e9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e9e:	8b89                	andi	a5,a5,2
ffffffffc0201ea0:	2a079263          	bnez	a5,ffffffffc0202144 <pmm_init+0x65e>
ffffffffc0201ea4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ea8:	4585                	li	a1,1
ffffffffc0201eaa:	739c                	ld	a5,32(a5)
ffffffffc0201eac:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201eae:	00093783          	ld	a5,0(s2)
ffffffffc0201eb2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201eb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eba:	8b89                	andi	a5,a5,2
ffffffffc0201ebc:	26079a63          	bnez	a5,ffffffffc0202130 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ec0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ec4:	779c                	ld	a5,40(a5)
ffffffffc0201ec6:	9782                	jalr	a5
ffffffffc0201ec8:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201eca:	73441463          	bne	s0,s4,ffffffffc02025f2 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ece:	00004517          	auipc	a0,0x4
ffffffffc0201ed2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0205798 <default_pmm_manager+0x460>
ffffffffc0201ed6:	9e4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eda:	100027f3          	csrr	a5,sstatus
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	22079e63          	bnez	a5,ffffffffc020211c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ee4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ee8:	779c                	ld	a5,40(a5)
ffffffffc0201eea:	9782                	jalr	a5
ffffffffc0201eec:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eee:	6098                	ld	a4,0(s1)
ffffffffc0201ef0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ef4:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ef6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201efa:	6a05                	lui	s4,0x1
ffffffffc0201efc:	02f47c63          	bgeu	s0,a5,ffffffffc0201f34 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f00:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f04:	00093503          	ld	a0,0(s2)
ffffffffc0201f08:	30e7f363          	bgeu	a5,a4,ffffffffc020220e <pmm_init+0x728>
ffffffffc0201f0c:	0009b583          	ld	a1,0(s3)
ffffffffc0201f10:	4601                	li	a2,0
ffffffffc0201f12:	95a2                	add	a1,a1,s0
ffffffffc0201f14:	fe8ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201f18:	2c050b63          	beqz	a0,ffffffffc02021ee <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f1c:	611c                	ld	a5,0(a0)
ffffffffc0201f1e:	078a                	slli	a5,a5,0x2
ffffffffc0201f20:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f24:	2a879563          	bne	a5,s0,ffffffffc02021ce <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f28:	6098                	ld	a4,0(s1)
ffffffffc0201f2a:	9452                	add	s0,s0,s4
ffffffffc0201f2c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f30:	fcf468e3          	bltu	s0,a5,ffffffffc0201f00 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f34:	00093783          	ld	a5,0(s2)
ffffffffc0201f38:	639c                	ld	a5,0(a5)
ffffffffc0201f3a:	68079c63          	bnez	a5,ffffffffc02025d2 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f3e:	4505                	li	a0,1
ffffffffc0201f40:	eb0ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0201f44:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f46:	00093503          	ld	a0,0(s2)
ffffffffc0201f4a:	4699                	li	a3,6
ffffffffc0201f4c:	10000613          	li	a2,256
ffffffffc0201f50:	85d6                	mv	a1,s5
ffffffffc0201f52:	a95ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201f56:	64051e63          	bnez	a0,ffffffffc02025b2 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f5a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201f5e:	4785                	li	a5,1
ffffffffc0201f60:	62f71963          	bne	a4,a5,ffffffffc0202592 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f64:	00093503          	ld	a0,0(s2)
ffffffffc0201f68:	6405                	lui	s0,0x1
ffffffffc0201f6a:	4699                	li	a3,6
ffffffffc0201f6c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f70:	85d6                	mv	a1,s5
ffffffffc0201f72:	a75ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201f76:	48051263          	bnez	a0,ffffffffc02023fa <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f7a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f7e:	4789                	li	a5,2
ffffffffc0201f80:	74f71563          	bne	a4,a5,ffffffffc02026ca <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f84:	00004597          	auipc	a1,0x4
ffffffffc0201f88:	94c58593          	addi	a1,a1,-1716 # ffffffffc02058d0 <default_pmm_manager+0x598>
ffffffffc0201f8c:	10000513          	li	a0,256
ffffffffc0201f90:	5d6020ef          	jal	ra,ffffffffc0204566 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f94:	10040593          	addi	a1,s0,256
ffffffffc0201f98:	10000513          	li	a0,256
ffffffffc0201f9c:	5dc020ef          	jal	ra,ffffffffc0204578 <strcmp>
ffffffffc0201fa0:	70051563          	bnez	a0,ffffffffc02026aa <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa4:	000b3683          	ld	a3,0(s6)
ffffffffc0201fa8:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fac:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fae:	40da86b3          	sub	a3,s5,a3
ffffffffc0201fb2:	868d                	srai	a3,a3,0x3
ffffffffc0201fb4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fb8:	609c                	ld	a5,0(s1)
ffffffffc0201fba:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fbc:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fbe:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc4:	52f77b63          	bgeu	a4,a5,ffffffffc02024fa <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fc8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fcc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fd0:	96be                	add	a3,a3,a5
ffffffffc0201fd2:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb8c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fd6:	55a020ef          	jal	ra,ffffffffc0204530 <strlen>
ffffffffc0201fda:	6a051863          	bnez	a0,ffffffffc020268a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fde:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fe2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fe8:	078a                	slli	a5,a5,0x2
ffffffffc0201fea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fec:	22e7fe63          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff0:	41a787b3          	sub	a5,a5,s10
ffffffffc0201ff4:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ff8:	96be                	add	a3,a3,a5
ffffffffc0201ffa:	03968cb3          	mul	s9,a3,s9
ffffffffc0201ffe:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202002:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202004:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202006:	4ee47a63          	bgeu	s0,a4,ffffffffc02024fa <pmm_init+0xa14>
ffffffffc020200a:	0009b403          	ld	s0,0(s3)
ffffffffc020200e:	9436                	add	s0,s0,a3
ffffffffc0202010:	100027f3          	csrr	a5,sstatus
ffffffffc0202014:	8b89                	andi	a5,a5,2
ffffffffc0202016:	1a079163          	bnez	a5,ffffffffc02021b8 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020201a:	000bb783          	ld	a5,0(s7)
ffffffffc020201e:	4585                	li	a1,1
ffffffffc0202020:	8556                	mv	a0,s5
ffffffffc0202022:	739c                	ld	a5,32(a5)
ffffffffc0202024:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202026:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202028:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020202a:	078a                	slli	a5,a5,0x2
ffffffffc020202c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020202e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202032:	fff80737          	lui	a4,0xfff80
ffffffffc0202036:	97ba                	add	a5,a5,a4
ffffffffc0202038:	000b3503          	ld	a0,0(s6)
ffffffffc020203c:	00379713          	slli	a4,a5,0x3
ffffffffc0202040:	97ba                	add	a5,a5,a4
ffffffffc0202042:	078e                	slli	a5,a5,0x3
ffffffffc0202044:	953e                	add	a0,a0,a5
ffffffffc0202046:	100027f3          	csrr	a5,sstatus
ffffffffc020204a:	8b89                	andi	a5,a5,2
ffffffffc020204c:	14079a63          	bnez	a5,ffffffffc02021a0 <pmm_init+0x6ba>
ffffffffc0202050:	000bb783          	ld	a5,0(s7)
ffffffffc0202054:	4585                	li	a1,1
ffffffffc0202056:	739c                	ld	a5,32(a5)
ffffffffc0202058:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020205a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020205e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202060:	078a                	slli	a5,a5,0x2
ffffffffc0202062:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202064:	1ce7f263          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202068:	fff80737          	lui	a4,0xfff80
ffffffffc020206c:	97ba                	add	a5,a5,a4
ffffffffc020206e:	000b3503          	ld	a0,0(s6)
ffffffffc0202072:	00379713          	slli	a4,a5,0x3
ffffffffc0202076:	97ba                	add	a5,a5,a4
ffffffffc0202078:	078e                	slli	a5,a5,0x3
ffffffffc020207a:	953e                	add	a0,a0,a5
ffffffffc020207c:	100027f3          	csrr	a5,sstatus
ffffffffc0202080:	8b89                	andi	a5,a5,2
ffffffffc0202082:	10079363          	bnez	a5,ffffffffc0202188 <pmm_init+0x6a2>
ffffffffc0202086:	000bb783          	ld	a5,0(s7)
ffffffffc020208a:	4585                	li	a1,1
ffffffffc020208c:	739c                	ld	a5,32(a5)
ffffffffc020208e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202090:	00093783          	ld	a5,0(s2)
ffffffffc0202094:	0007b023          	sd	zero,0(a5)
ffffffffc0202098:	100027f3          	csrr	a5,sstatus
ffffffffc020209c:	8b89                	andi	a5,a5,2
ffffffffc020209e:	0c079b63          	bnez	a5,ffffffffc0202174 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020a2:	000bb783          	ld	a5,0(s7)
ffffffffc02020a6:	779c                	ld	a5,40(a5)
ffffffffc02020a8:	9782                	jalr	a5
ffffffffc02020aa:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020ac:	3a8c1763          	bne	s8,s0,ffffffffc020245a <pmm_init+0x974>
}
ffffffffc02020b0:	7406                	ld	s0,96(sp)
ffffffffc02020b2:	70a6                	ld	ra,104(sp)
ffffffffc02020b4:	64e6                	ld	s1,88(sp)
ffffffffc02020b6:	6946                	ld	s2,80(sp)
ffffffffc02020b8:	69a6                	ld	s3,72(sp)
ffffffffc02020ba:	6a06                	ld	s4,64(sp)
ffffffffc02020bc:	7ae2                	ld	s5,56(sp)
ffffffffc02020be:	7b42                	ld	s6,48(sp)
ffffffffc02020c0:	7ba2                	ld	s7,40(sp)
ffffffffc02020c2:	7c02                	ld	s8,32(sp)
ffffffffc02020c4:	6ce2                	ld	s9,24(sp)
ffffffffc02020c6:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020c8:	00004517          	auipc	a0,0x4
ffffffffc02020cc:	88050513          	addi	a0,a0,-1920 # ffffffffc0205948 <default_pmm_manager+0x610>
}
ffffffffc02020d0:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020d2:	fe9fd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020d6:	6705                	lui	a4,0x1
ffffffffc02020d8:	177d                	addi	a4,a4,-1
ffffffffc02020da:	96ba                	add	a3,a3,a4
ffffffffc02020dc:	777d                	lui	a4,0xfffff
ffffffffc02020de:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020e0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020e4:	14f6f263          	bgeu	a3,a5,ffffffffc0202228 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020e8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020ec:	95b6                	add	a1,a1,a3
ffffffffc02020ee:	00359793          	slli	a5,a1,0x3
ffffffffc02020f2:	97ae                	add	a5,a5,a1
ffffffffc02020f4:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f8:	40e60733          	sub	a4,a2,a4
ffffffffc02020fc:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020fe:	00c75593          	srli	a1,a4,0xc
ffffffffc0202102:	953e                	add	a0,a0,a5
ffffffffc0202104:	9682                	jalr	a3
}
ffffffffc0202106:	bcc5                	j	ffffffffc0201bf6 <pmm_init+0x110>
        intr_disable();
ffffffffc0202108:	be6fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020210c:	000bb783          	ld	a5,0(s7)
ffffffffc0202110:	779c                	ld	a5,40(a5)
ffffffffc0202112:	9782                	jalr	a5
ffffffffc0202114:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202116:	bd2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020211a:	b63d                	j	ffffffffc0201c48 <pmm_init+0x162>
        intr_disable();
ffffffffc020211c:	bd2fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202120:	000bb783          	ld	a5,0(s7)
ffffffffc0202124:	779c                	ld	a5,40(a5)
ffffffffc0202126:	9782                	jalr	a5
ffffffffc0202128:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020212a:	bbefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020212e:	b3c1                	j	ffffffffc0201eee <pmm_init+0x408>
        intr_disable();
ffffffffc0202130:	bbefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202134:	000bb783          	ld	a5,0(s7)
ffffffffc0202138:	779c                	ld	a5,40(a5)
ffffffffc020213a:	9782                	jalr	a5
ffffffffc020213c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020213e:	baafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202142:	b361                	j	ffffffffc0201eca <pmm_init+0x3e4>
ffffffffc0202144:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202146:	ba8fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020214a:	000bb783          	ld	a5,0(s7)
ffffffffc020214e:	6522                	ld	a0,8(sp)
ffffffffc0202150:	4585                	li	a1,1
ffffffffc0202152:	739c                	ld	a5,32(a5)
ffffffffc0202154:	9782                	jalr	a5
        intr_enable();
ffffffffc0202156:	b92fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020215a:	bb91                	j	ffffffffc0201eae <pmm_init+0x3c8>
ffffffffc020215c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020215e:	b90fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202162:	000bb783          	ld	a5,0(s7)
ffffffffc0202166:	6522                	ld	a0,8(sp)
ffffffffc0202168:	4585                	li	a1,1
ffffffffc020216a:	739c                	ld	a5,32(a5)
ffffffffc020216c:	9782                	jalr	a5
        intr_enable();
ffffffffc020216e:	b7afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202172:	b319                	j	ffffffffc0201e78 <pmm_init+0x392>
        intr_disable();
ffffffffc0202174:	b7afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202178:	000bb783          	ld	a5,0(s7)
ffffffffc020217c:	779c                	ld	a5,40(a5)
ffffffffc020217e:	9782                	jalr	a5
ffffffffc0202180:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202182:	b66fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202186:	b71d                	j	ffffffffc02020ac <pmm_init+0x5c6>
ffffffffc0202188:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020218a:	b64fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020218e:	000bb783          	ld	a5,0(s7)
ffffffffc0202192:	6522                	ld	a0,8(sp)
ffffffffc0202194:	4585                	li	a1,1
ffffffffc0202196:	739c                	ld	a5,32(a5)
ffffffffc0202198:	9782                	jalr	a5
        intr_enable();
ffffffffc020219a:	b4efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020219e:	bdcd                	j	ffffffffc0202090 <pmm_init+0x5aa>
ffffffffc02021a0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021a2:	b4cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021a6:	000bb783          	ld	a5,0(s7)
ffffffffc02021aa:	6522                	ld	a0,8(sp)
ffffffffc02021ac:	4585                	li	a1,1
ffffffffc02021ae:	739c                	ld	a5,32(a5)
ffffffffc02021b0:	9782                	jalr	a5
        intr_enable();
ffffffffc02021b2:	b36fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021b6:	b555                	j	ffffffffc020205a <pmm_init+0x574>
        intr_disable();
ffffffffc02021b8:	b36fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021bc:	000bb783          	ld	a5,0(s7)
ffffffffc02021c0:	4585                	li	a1,1
ffffffffc02021c2:	8556                	mv	a0,s5
ffffffffc02021c4:	739c                	ld	a5,32(a5)
ffffffffc02021c6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021c8:	b20fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021cc:	bda9                	j	ffffffffc0202026 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021ce:	00003697          	auipc	a3,0x3
ffffffffc02021d2:	62a68693          	addi	a3,a3,1578 # ffffffffc02057f8 <default_pmm_manager+0x4c0>
ffffffffc02021d6:	00003617          	auipc	a2,0x3
ffffffffc02021da:	db260613          	addi	a2,a2,-590 # ffffffffc0204f88 <commands+0x758>
ffffffffc02021de:	1ce00593          	li	a1,462
ffffffffc02021e2:	00003517          	auipc	a0,0x3
ffffffffc02021e6:	20e50513          	addi	a0,a0,526 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02021ea:	98afe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021ee:	00003697          	auipc	a3,0x3
ffffffffc02021f2:	5ca68693          	addi	a3,a3,1482 # ffffffffc02057b8 <default_pmm_manager+0x480>
ffffffffc02021f6:	00003617          	auipc	a2,0x3
ffffffffc02021fa:	d9260613          	addi	a2,a2,-622 # ffffffffc0204f88 <commands+0x758>
ffffffffc02021fe:	1cd00593          	li	a1,461
ffffffffc0202202:	00003517          	auipc	a0,0x3
ffffffffc0202206:	1ee50513          	addi	a0,a0,494 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020220a:	96afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020220e:	86a2                	mv	a3,s0
ffffffffc0202210:	00003617          	auipc	a2,0x3
ffffffffc0202214:	1b860613          	addi	a2,a2,440 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc0202218:	1cd00593          	li	a1,461
ffffffffc020221c:	00003517          	auipc	a0,0x3
ffffffffc0202220:	1d450513          	addi	a0,a0,468 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202224:	950fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202228:	b90ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020222c:	00003617          	auipc	a2,0x3
ffffffffc0202230:	25c60613          	addi	a2,a2,604 # ffffffffc0205488 <default_pmm_manager+0x150>
ffffffffc0202234:	07700593          	li	a1,119
ffffffffc0202238:	00003517          	auipc	a0,0x3
ffffffffc020223c:	1b850513          	addi	a0,a0,440 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202240:	934fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202244:	00003617          	auipc	a2,0x3
ffffffffc0202248:	24460613          	addi	a2,a2,580 # ffffffffc0205488 <default_pmm_manager+0x150>
ffffffffc020224c:	0bd00593          	li	a1,189
ffffffffc0202250:	00003517          	auipc	a0,0x3
ffffffffc0202254:	1a050513          	addi	a0,a0,416 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202258:	91cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020225c:	00003697          	auipc	a3,0x3
ffffffffc0202260:	29468693          	addi	a3,a3,660 # ffffffffc02054f0 <default_pmm_manager+0x1b8>
ffffffffc0202264:	00003617          	auipc	a2,0x3
ffffffffc0202268:	d2460613          	addi	a2,a2,-732 # ffffffffc0204f88 <commands+0x758>
ffffffffc020226c:	19300593          	li	a1,403
ffffffffc0202270:	00003517          	auipc	a0,0x3
ffffffffc0202274:	18050513          	addi	a0,a0,384 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202278:	8fcfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020227c:	00003697          	auipc	a3,0x3
ffffffffc0202280:	25468693          	addi	a3,a3,596 # ffffffffc02054d0 <default_pmm_manager+0x198>
ffffffffc0202284:	00003617          	auipc	a2,0x3
ffffffffc0202288:	d0460613          	addi	a2,a2,-764 # ffffffffc0204f88 <commands+0x758>
ffffffffc020228c:	19200593          	li	a1,402
ffffffffc0202290:	00003517          	auipc	a0,0x3
ffffffffc0202294:	16050513          	addi	a0,a0,352 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202298:	8dcfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020229c:	b38ff0ef          	jal	ra,ffffffffc02015d4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	2e068693          	addi	a3,a3,736 # ffffffffc0205580 <default_pmm_manager+0x248>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	ce060613          	addi	a2,a2,-800 # ffffffffc0204f88 <commands+0x758>
ffffffffc02022b0:	19a00593          	li	a1,410
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	13c50513          	addi	a0,a0,316 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02022bc:	8b8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	29068693          	addi	a3,a3,656 # ffffffffc0205550 <default_pmm_manager+0x218>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	cc060613          	addi	a2,a2,-832 # ffffffffc0204f88 <commands+0x758>
ffffffffc02022d0:	19800593          	li	a1,408
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	11c50513          	addi	a0,a0,284 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02022dc:	898fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	24868693          	addi	a3,a3,584 # ffffffffc0205528 <default_pmm_manager+0x1f0>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	ca060613          	addi	a2,a2,-864 # ffffffffc0204f88 <commands+0x758>
ffffffffc02022f0:	19400593          	li	a1,404
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	0fc50513          	addi	a0,a0,252 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02022fc:	878fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	30868693          	addi	a3,a3,776 # ffffffffc0205608 <default_pmm_manager+0x2d0>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	c8060613          	addi	a2,a2,-896 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202310:	1a300593          	li	a1,419
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	0dc50513          	addi	a0,a0,220 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020231c:	858fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202320:	00003697          	auipc	a3,0x3
ffffffffc0202324:	38868693          	addi	a3,a3,904 # ffffffffc02056a8 <default_pmm_manager+0x370>
ffffffffc0202328:	00003617          	auipc	a2,0x3
ffffffffc020232c:	c6060613          	addi	a2,a2,-928 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202330:	1a800593          	li	a1,424
ffffffffc0202334:	00003517          	auipc	a0,0x3
ffffffffc0202338:	0bc50513          	addi	a0,a0,188 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020233c:	838fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202340:	00003697          	auipc	a3,0x3
ffffffffc0202344:	2a068693          	addi	a3,a3,672 # ffffffffc02055e0 <default_pmm_manager+0x2a8>
ffffffffc0202348:	00003617          	auipc	a2,0x3
ffffffffc020234c:	c4060613          	addi	a2,a2,-960 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202350:	1a000593          	li	a1,416
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	09c50513          	addi	a0,a0,156 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020235c:	818fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202360:	86d6                	mv	a3,s5
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	06660613          	addi	a2,a2,102 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc020236a:	19f00593          	li	a1,415
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	08250513          	addi	a0,a0,130 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202376:	ffffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	2c668693          	addi	a3,a3,710 # ffffffffc0205640 <default_pmm_manager+0x308>
ffffffffc0202382:	00003617          	auipc	a2,0x3
ffffffffc0202386:	c0660613          	addi	a2,a2,-1018 # ffffffffc0204f88 <commands+0x758>
ffffffffc020238a:	1ad00593          	li	a1,429
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	06250513          	addi	a0,a0,98 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202396:	fdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	36e68693          	addi	a3,a3,878 # ffffffffc0205708 <default_pmm_manager+0x3d0>
ffffffffc02023a2:	00003617          	auipc	a2,0x3
ffffffffc02023a6:	be660613          	addi	a2,a2,-1050 # ffffffffc0204f88 <commands+0x758>
ffffffffc02023aa:	1ac00593          	li	a1,428
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	04250513          	addi	a0,a0,66 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02023b6:	fbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	33668693          	addi	a3,a3,822 # ffffffffc02056f0 <default_pmm_manager+0x3b8>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	bc660613          	addi	a2,a2,-1082 # ffffffffc0204f88 <commands+0x758>
ffffffffc02023ca:	1ab00593          	li	a1,427
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	02250513          	addi	a0,a0,34 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02023d6:	f9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	2e668693          	addi	a3,a3,742 # ffffffffc02056c0 <default_pmm_manager+0x388>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	ba660613          	addi	a2,a2,-1114 # ffffffffc0204f88 <commands+0x758>
ffffffffc02023ea:	1aa00593          	li	a1,426
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	00250513          	addi	a0,a0,2 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02023f6:	f7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	47e68693          	addi	a3,a3,1150 # ffffffffc0205878 <default_pmm_manager+0x540>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	b8660613          	addi	a2,a2,-1146 # ffffffffc0204f88 <commands+0x758>
ffffffffc020240a:	1d800593          	li	a1,472
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	fe250513          	addi	a0,a0,-30 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202416:	f5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	27668693          	addi	a3,a3,630 # ffffffffc0205690 <default_pmm_manager+0x358>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	b6660613          	addi	a2,a2,-1178 # ffffffffc0204f88 <commands+0x758>
ffffffffc020242a:	1a700593          	li	a1,423
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	fc250513          	addi	a0,a0,-62 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202436:	f3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	24668693          	addi	a3,a3,582 # ffffffffc0205680 <default_pmm_manager+0x348>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	b4660613          	addi	a2,a2,-1210 # ffffffffc0204f88 <commands+0x758>
ffffffffc020244a:	1a600593          	li	a1,422
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	fa250513          	addi	a0,a0,-94 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202456:	f1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	31e68693          	addi	a3,a3,798 # ffffffffc0205778 <default_pmm_manager+0x440>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	b2660613          	addi	a2,a2,-1242 # ffffffffc0204f88 <commands+0x758>
ffffffffc020246a:	1e800593          	li	a1,488
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	f8250513          	addi	a0,a0,-126 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202476:	efffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	1f668693          	addi	a3,a3,502 # ffffffffc0205670 <default_pmm_manager+0x338>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	b0660613          	addi	a2,a2,-1274 # ffffffffc0204f88 <commands+0x758>
ffffffffc020248a:	1a500593          	li	a1,421
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	f6250513          	addi	a0,a0,-158 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202496:	edffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	12e68693          	addi	a3,a3,302 # ffffffffc02055c8 <default_pmm_manager+0x290>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	ae660613          	addi	a2,a2,-1306 # ffffffffc0204f88 <commands+0x758>
ffffffffc02024aa:	1b200593          	li	a1,434
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	f4250513          	addi	a0,a0,-190 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02024b6:	ebffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ba:	00003697          	auipc	a3,0x3
ffffffffc02024be:	26668693          	addi	a3,a3,614 # ffffffffc0205720 <default_pmm_manager+0x3e8>
ffffffffc02024c2:	00003617          	auipc	a2,0x3
ffffffffc02024c6:	ac660613          	addi	a2,a2,-1338 # ffffffffc0204f88 <commands+0x758>
ffffffffc02024ca:	1af00593          	li	a1,431
ffffffffc02024ce:	00003517          	auipc	a0,0x3
ffffffffc02024d2:	f2250513          	addi	a0,a0,-222 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02024d6:	e9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02024da:	00003697          	auipc	a3,0x3
ffffffffc02024de:	0d668693          	addi	a3,a3,214 # ffffffffc02055b0 <default_pmm_manager+0x278>
ffffffffc02024e2:	00003617          	auipc	a2,0x3
ffffffffc02024e6:	aa660613          	addi	a2,a2,-1370 # ffffffffc0204f88 <commands+0x758>
ffffffffc02024ea:	1ae00593          	li	a1,430
ffffffffc02024ee:	00003517          	auipc	a0,0x3
ffffffffc02024f2:	f0250513          	addi	a0,a0,-254 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02024f6:	e7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02024fa:	00003617          	auipc	a2,0x3
ffffffffc02024fe:	ece60613          	addi	a2,a2,-306 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc0202502:	06a00593          	li	a1,106
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	e8a50513          	addi	a0,a0,-374 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc020250e:	e67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202512:	00003697          	auipc	a3,0x3
ffffffffc0202516:	23e68693          	addi	a3,a3,574 # ffffffffc0205750 <default_pmm_manager+0x418>
ffffffffc020251a:	00003617          	auipc	a2,0x3
ffffffffc020251e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202522:	1b900593          	li	a1,441
ffffffffc0202526:	00003517          	auipc	a0,0x3
ffffffffc020252a:	eca50513          	addi	a0,a0,-310 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020252e:	e47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202532:	00003697          	auipc	a3,0x3
ffffffffc0202536:	1d668693          	addi	a3,a3,470 # ffffffffc0205708 <default_pmm_manager+0x3d0>
ffffffffc020253a:	00003617          	auipc	a2,0x3
ffffffffc020253e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202542:	1b700593          	li	a1,439
ffffffffc0202546:	00003517          	auipc	a0,0x3
ffffffffc020254a:	eaa50513          	addi	a0,a0,-342 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020254e:	e27fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202552:	00003697          	auipc	a3,0x3
ffffffffc0202556:	1e668693          	addi	a3,a3,486 # ffffffffc0205738 <default_pmm_manager+0x400>
ffffffffc020255a:	00003617          	auipc	a2,0x3
ffffffffc020255e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202562:	1b600593          	li	a1,438
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	e8a50513          	addi	a0,a0,-374 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020256e:	e07fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202572:	00003697          	auipc	a3,0x3
ffffffffc0202576:	19668693          	addi	a3,a3,406 # ffffffffc0205708 <default_pmm_manager+0x3d0>
ffffffffc020257a:	00003617          	auipc	a2,0x3
ffffffffc020257e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202582:	1b300593          	li	a1,435
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	e6a50513          	addi	a0,a0,-406 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020258e:	de7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	2ce68693          	addi	a3,a3,718 # ffffffffc0205860 <default_pmm_manager+0x528>
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204f88 <commands+0x758>
ffffffffc02025a2:	1d700593          	li	a1,471
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	e4a50513          	addi	a0,a0,-438 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02025ae:	dc7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	27668693          	addi	a3,a3,630 # ffffffffc0205828 <default_pmm_manager+0x4f0>
ffffffffc02025ba:	00003617          	auipc	a2,0x3
ffffffffc02025be:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204f88 <commands+0x758>
ffffffffc02025c2:	1d600593          	li	a1,470
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	e2a50513          	addi	a0,a0,-470 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02025ce:	da7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	23e68693          	addi	a3,a3,574 # ffffffffc0205810 <default_pmm_manager+0x4d8>
ffffffffc02025da:	00003617          	auipc	a2,0x3
ffffffffc02025de:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204f88 <commands+0x758>
ffffffffc02025e2:	1d200593          	li	a1,466
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	e0a50513          	addi	a0,a0,-502 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02025ee:	d87fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	18668693          	addi	a3,a3,390 # ffffffffc0205778 <default_pmm_manager+0x440>
ffffffffc02025fa:	00003617          	auipc	a2,0x3
ffffffffc02025fe:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202602:	1c000593          	li	a1,448
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	dea50513          	addi	a0,a0,-534 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020260e:	d67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202612:	00003697          	auipc	a3,0x3
ffffffffc0202616:	f9e68693          	addi	a3,a3,-98 # ffffffffc02055b0 <default_pmm_manager+0x278>
ffffffffc020261a:	00003617          	auipc	a2,0x3
ffffffffc020261e:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202622:	19b00593          	li	a1,411
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	dca50513          	addi	a0,a0,-566 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020262e:	d47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202632:	00003617          	auipc	a2,0x3
ffffffffc0202636:	d9660613          	addi	a2,a2,-618 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc020263a:	19e00593          	li	a1,414
ffffffffc020263e:	00003517          	auipc	a0,0x3
ffffffffc0202642:	db250513          	addi	a0,a0,-590 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202646:	d2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020264a:	00003697          	auipc	a3,0x3
ffffffffc020264e:	f7e68693          	addi	a3,a3,-130 # ffffffffc02055c8 <default_pmm_manager+0x290>
ffffffffc0202652:	00003617          	auipc	a2,0x3
ffffffffc0202656:	93660613          	addi	a2,a2,-1738 # ffffffffc0204f88 <commands+0x758>
ffffffffc020265a:	19c00593          	li	a1,412
ffffffffc020265e:	00003517          	auipc	a0,0x3
ffffffffc0202662:	d9250513          	addi	a0,a0,-622 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202666:	d0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020266a:	00003697          	auipc	a3,0x3
ffffffffc020266e:	fd668693          	addi	a3,a3,-42 # ffffffffc0205640 <default_pmm_manager+0x308>
ffffffffc0202672:	00003617          	auipc	a2,0x3
ffffffffc0202676:	91660613          	addi	a2,a2,-1770 # ffffffffc0204f88 <commands+0x758>
ffffffffc020267a:	1a400593          	li	a1,420
ffffffffc020267e:	00003517          	auipc	a0,0x3
ffffffffc0202682:	d7250513          	addi	a0,a0,-654 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202686:	ceffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020268a:	00003697          	auipc	a3,0x3
ffffffffc020268e:	29668693          	addi	a3,a3,662 # ffffffffc0205920 <default_pmm_manager+0x5e8>
ffffffffc0202692:	00003617          	auipc	a2,0x3
ffffffffc0202696:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204f88 <commands+0x758>
ffffffffc020269a:	1e000593          	li	a1,480
ffffffffc020269e:	00003517          	auipc	a0,0x3
ffffffffc02026a2:	d5250513          	addi	a0,a0,-686 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02026a6:	ccffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026aa:	00003697          	auipc	a3,0x3
ffffffffc02026ae:	23e68693          	addi	a3,a3,574 # ffffffffc02058e8 <default_pmm_manager+0x5b0>
ffffffffc02026b2:	00003617          	auipc	a2,0x3
ffffffffc02026b6:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204f88 <commands+0x758>
ffffffffc02026ba:	1dd00593          	li	a1,477
ffffffffc02026be:	00003517          	auipc	a0,0x3
ffffffffc02026c2:	d3250513          	addi	a0,a0,-718 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02026c6:	caffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026ca:	00003697          	auipc	a3,0x3
ffffffffc02026ce:	1ee68693          	addi	a3,a3,494 # ffffffffc02058b8 <default_pmm_manager+0x580>
ffffffffc02026d2:	00003617          	auipc	a2,0x3
ffffffffc02026d6:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204f88 <commands+0x758>
ffffffffc02026da:	1d900593          	li	a1,473
ffffffffc02026de:	00003517          	auipc	a0,0x3
ffffffffc02026e2:	d1250513          	addi	a0,a0,-750 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc02026e6:	c8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02026ea <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026ea:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026ee:	8082                	ret

ffffffffc02026f0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026f0:	7179                	addi	sp,sp,-48
ffffffffc02026f2:	e84a                	sd	s2,16(sp)
ffffffffc02026f4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02026f6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026f8:	f022                	sd	s0,32(sp)
ffffffffc02026fa:	ec26                	sd	s1,24(sp)
ffffffffc02026fc:	e44e                	sd	s3,8(sp)
ffffffffc02026fe:	f406                	sd	ra,40(sp)
ffffffffc0202700:	84ae                	mv	s1,a1
ffffffffc0202702:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202704:	eedfe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0202708:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020270a:	cd09                	beqz	a0,ffffffffc0202724 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020270c:	85aa                	mv	a1,a0
ffffffffc020270e:	86ce                	mv	a3,s3
ffffffffc0202710:	8626                	mv	a2,s1
ffffffffc0202712:	854a                	mv	a0,s2
ffffffffc0202714:	ad2ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0202718:	ed21                	bnez	a0,ffffffffc0202770 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020271a:	0000f797          	auipc	a5,0xf
ffffffffc020271e:	e3e7a783          	lw	a5,-450(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0202722:	eb89                	bnez	a5,ffffffffc0202734 <pgdir_alloc_page+0x44>
}
ffffffffc0202724:	70a2                	ld	ra,40(sp)
ffffffffc0202726:	8522                	mv	a0,s0
ffffffffc0202728:	7402                	ld	s0,32(sp)
ffffffffc020272a:	64e2                	ld	s1,24(sp)
ffffffffc020272c:	6942                	ld	s2,16(sp)
ffffffffc020272e:	69a2                	ld	s3,8(sp)
ffffffffc0202730:	6145                	addi	sp,sp,48
ffffffffc0202732:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202734:	4681                	li	a3,0
ffffffffc0202736:	8622                	mv	a2,s0
ffffffffc0202738:	85a6                	mv	a1,s1
ffffffffc020273a:	0000f517          	auipc	a0,0xf
ffffffffc020273e:	e2e53503          	ld	a0,-466(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0202742:	07f000ef          	jal	ra,ffffffffc0202fc0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202746:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202748:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020274a:	4785                	li	a5,1
ffffffffc020274c:	fcf70ce3          	beq	a4,a5,ffffffffc0202724 <pgdir_alloc_page+0x34>
ffffffffc0202750:	00003697          	auipc	a3,0x3
ffffffffc0202754:	21868693          	addi	a3,a3,536 # ffffffffc0205968 <default_pmm_manager+0x630>
ffffffffc0202758:	00003617          	auipc	a2,0x3
ffffffffc020275c:	83060613          	addi	a2,a2,-2000 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202760:	17a00593          	li	a1,378
ffffffffc0202764:	00003517          	auipc	a0,0x3
ffffffffc0202768:	c8c50513          	addi	a0,a0,-884 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020276c:	c09fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202770:	100027f3          	csrr	a5,sstatus
ffffffffc0202774:	8b89                	andi	a5,a5,2
ffffffffc0202776:	eb99                	bnez	a5,ffffffffc020278c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202778:	0000f797          	auipc	a5,0xf
ffffffffc020277c:	dc07b783          	ld	a5,-576(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202780:	739c                	ld	a5,32(a5)
ffffffffc0202782:	8522                	mv	a0,s0
ffffffffc0202784:	4585                	li	a1,1
ffffffffc0202786:	9782                	jalr	a5
            return NULL;
ffffffffc0202788:	4401                	li	s0,0
ffffffffc020278a:	bf69                	j	ffffffffc0202724 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020278c:	d63fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202790:	0000f797          	auipc	a5,0xf
ffffffffc0202794:	da87b783          	ld	a5,-600(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202798:	739c                	ld	a5,32(a5)
ffffffffc020279a:	8522                	mv	a0,s0
ffffffffc020279c:	4585                	li	a1,1
ffffffffc020279e:	9782                	jalr	a5
            return NULL;
ffffffffc02027a0:	4401                	li	s0,0
        intr_enable();
ffffffffc02027a2:	d47fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02027a6:	bfbd                	j	ffffffffc0202724 <pgdir_alloc_page+0x34>

ffffffffc02027a8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027a8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027aa:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027ac:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ae:	fff50713          	addi	a4,a0,-1
ffffffffc02027b2:	17f9                	addi	a5,a5,-2
ffffffffc02027b4:	04e7ea63          	bltu	a5,a4,ffffffffc0202808 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027b8:	6785                	lui	a5,0x1
ffffffffc02027ba:	17fd                	addi	a5,a5,-1
ffffffffc02027bc:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027be:	8131                	srli	a0,a0,0xc
ffffffffc02027c0:	e31fe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
    assert(base != NULL);
ffffffffc02027c4:	cd3d                	beqz	a0,ffffffffc0202842 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027c6:	0000f797          	auipc	a5,0xf
ffffffffc02027ca:	d6a7b783          	ld	a5,-662(a5) # ffffffffc0211530 <pages>
ffffffffc02027ce:	8d1d                	sub	a0,a0,a5
ffffffffc02027d0:	00004697          	auipc	a3,0x4
ffffffffc02027d4:	d606b683          	ld	a3,-672(a3) # ffffffffc0206530 <error_string+0x38>
ffffffffc02027d8:	850d                	srai	a0,a0,0x3
ffffffffc02027da:	02d50533          	mul	a0,a0,a3
ffffffffc02027de:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027e2:	0000f717          	auipc	a4,0xf
ffffffffc02027e6:	d4673703          	ld	a4,-698(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027ea:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027ec:	00c51793          	slli	a5,a0,0xc
ffffffffc02027f0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02027f2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027f4:	02e7fa63          	bgeu	a5,a4,ffffffffc0202828 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02027f8:	60a2                	ld	ra,8(sp)
ffffffffc02027fa:	0000f797          	auipc	a5,0xf
ffffffffc02027fe:	d467b783          	ld	a5,-698(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0202802:	953e                	add	a0,a0,a5
ffffffffc0202804:	0141                	addi	sp,sp,16
ffffffffc0202806:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202808:	00003697          	auipc	a3,0x3
ffffffffc020280c:	17868693          	addi	a3,a3,376 # ffffffffc0205980 <default_pmm_manager+0x648>
ffffffffc0202810:	00002617          	auipc	a2,0x2
ffffffffc0202814:	77860613          	addi	a2,a2,1912 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202818:	1f000593          	li	a1,496
ffffffffc020281c:	00003517          	auipc	a0,0x3
ffffffffc0202820:	bd450513          	addi	a0,a0,-1068 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202824:	b51fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202828:	86aa                	mv	a3,a0
ffffffffc020282a:	00003617          	auipc	a2,0x3
ffffffffc020282e:	b9e60613          	addi	a2,a2,-1122 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc0202832:	06a00593          	li	a1,106
ffffffffc0202836:	00003517          	auipc	a0,0x3
ffffffffc020283a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc020283e:	b37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202842:	00003697          	auipc	a3,0x3
ffffffffc0202846:	15e68693          	addi	a3,a3,350 # ffffffffc02059a0 <default_pmm_manager+0x668>
ffffffffc020284a:	00002617          	auipc	a2,0x2
ffffffffc020284e:	73e60613          	addi	a2,a2,1854 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202852:	1f300593          	li	a1,499
ffffffffc0202856:	00003517          	auipc	a0,0x3
ffffffffc020285a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc020285e:	b17fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202862 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202862:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202864:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202866:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202868:	fff58713          	addi	a4,a1,-1
ffffffffc020286c:	17f9                	addi	a5,a5,-2
ffffffffc020286e:	0ae7ee63          	bltu	a5,a4,ffffffffc020292a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202872:	cd41                	beqz	a0,ffffffffc020290a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202874:	6785                	lui	a5,0x1
ffffffffc0202876:	17fd                	addi	a5,a5,-1
ffffffffc0202878:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020287a:	c02007b7          	lui	a5,0xc0200
ffffffffc020287e:	81b1                	srli	a1,a1,0xc
ffffffffc0202880:	06f56863          	bltu	a0,a5,ffffffffc02028f0 <kfree+0x8e>
ffffffffc0202884:	0000f697          	auipc	a3,0xf
ffffffffc0202888:	cbc6b683          	ld	a3,-836(a3) # ffffffffc0211540 <va_pa_offset>
ffffffffc020288c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020288e:	8131                	srli	a0,a0,0xc
ffffffffc0202890:	0000f797          	auipc	a5,0xf
ffffffffc0202894:	c987b783          	ld	a5,-872(a5) # ffffffffc0211528 <npage>
ffffffffc0202898:	04f57a63          	bgeu	a0,a5,ffffffffc02028ec <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020289c:	fff806b7          	lui	a3,0xfff80
ffffffffc02028a0:	9536                	add	a0,a0,a3
ffffffffc02028a2:	00351793          	slli	a5,a0,0x3
ffffffffc02028a6:	953e                	add	a0,a0,a5
ffffffffc02028a8:	050e                	slli	a0,a0,0x3
ffffffffc02028aa:	0000f797          	auipc	a5,0xf
ffffffffc02028ae:	c867b783          	ld	a5,-890(a5) # ffffffffc0211530 <pages>
ffffffffc02028b2:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028b4:	100027f3          	csrr	a5,sstatus
ffffffffc02028b8:	8b89                	andi	a5,a5,2
ffffffffc02028ba:	eb89                	bnez	a5,ffffffffc02028cc <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028bc:	0000f797          	auipc	a5,0xf
ffffffffc02028c0:	c7c7b783          	ld	a5,-900(a5) # ffffffffc0211538 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028c4:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028c6:	739c                	ld	a5,32(a5)
}
ffffffffc02028c8:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028ca:	8782                	jr	a5
        intr_disable();
ffffffffc02028cc:	e42a                	sd	a0,8(sp)
ffffffffc02028ce:	e02e                	sd	a1,0(sp)
ffffffffc02028d0:	c1ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02028d4:	0000f797          	auipc	a5,0xf
ffffffffc02028d8:	c647b783          	ld	a5,-924(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02028dc:	6582                	ld	a1,0(sp)
ffffffffc02028de:	6522                	ld	a0,8(sp)
ffffffffc02028e0:	739c                	ld	a5,32(a5)
ffffffffc02028e2:	9782                	jalr	a5
}
ffffffffc02028e4:	60e2                	ld	ra,24(sp)
ffffffffc02028e6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028e8:	c01fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028ec:	ccdfe0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028f0:	86aa                	mv	a3,a0
ffffffffc02028f2:	00003617          	auipc	a2,0x3
ffffffffc02028f6:	b9660613          	addi	a2,a2,-1130 # ffffffffc0205488 <default_pmm_manager+0x150>
ffffffffc02028fa:	06c00593          	li	a1,108
ffffffffc02028fe:	00003517          	auipc	a0,0x3
ffffffffc0202902:	a9250513          	addi	a0,a0,-1390 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc0202906:	a6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020290a:	00003697          	auipc	a3,0x3
ffffffffc020290e:	0a668693          	addi	a3,a3,166 # ffffffffc02059b0 <default_pmm_manager+0x678>
ffffffffc0202912:	00002617          	auipc	a2,0x2
ffffffffc0202916:	67660613          	addi	a2,a2,1654 # ffffffffc0204f88 <commands+0x758>
ffffffffc020291a:	1fa00593          	li	a1,506
ffffffffc020291e:	00003517          	auipc	a0,0x3
ffffffffc0202922:	ad250513          	addi	a0,a0,-1326 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202926:	a4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020292a:	00003697          	auipc	a3,0x3
ffffffffc020292e:	05668693          	addi	a3,a3,86 # ffffffffc0205980 <default_pmm_manager+0x648>
ffffffffc0202932:	00002617          	auipc	a2,0x2
ffffffffc0202936:	65660613          	addi	a2,a2,1622 # ffffffffc0204f88 <commands+0x758>
ffffffffc020293a:	1f900593          	li	a1,505
ffffffffc020293e:	00003517          	auipc	a0,0x3
ffffffffc0202942:	ab250513          	addi	a0,a0,-1358 # ffffffffc02053f0 <default_pmm_manager+0xb8>
ffffffffc0202946:	a2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020294a <swap_init>:
unsigned int swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

static void check_swap(void);

int swap_init(void)
{
ffffffffc020294a:	7135                	addi	sp,sp,-160
ffffffffc020294c:	ed06                	sd	ra,152(sp)
ffffffffc020294e:	e922                	sd	s0,144(sp)
ffffffffc0202950:	e526                	sd	s1,136(sp)
ffffffffc0202952:	e14a                	sd	s2,128(sp)
ffffffffc0202954:	fcce                	sd	s3,120(sp)
ffffffffc0202956:	f8d2                	sd	s4,112(sp)
ffffffffc0202958:	f4d6                	sd	s5,104(sp)
ffffffffc020295a:	f0da                	sd	s6,96(sp)
ffffffffc020295c:	ecde                	sd	s7,88(sp)
ffffffffc020295e:	e8e2                	sd	s8,80(sp)
ffffffffc0202960:	e4e6                	sd	s9,72(sp)
ffffffffc0202962:	e0ea                	sd	s10,64(sp)
ffffffffc0202964:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202966:	5bc010ef          	jal	ra,ffffffffc0203f22 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020296a:	0000f697          	auipc	a3,0xf
ffffffffc020296e:	bde6b683          	ld	a3,-1058(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc0202972:	010007b7          	lui	a5,0x1000
ffffffffc0202976:	ff968713          	addi	a4,a3,-7
ffffffffc020297a:	17e1                	addi	a5,a5,-8
ffffffffc020297c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d5c <swap_init+0x412>
           max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru; // use lru Page Replacement Algorithm
ffffffffc0202980:	00007797          	auipc	a5,0x7
ffffffffc0202984:	68078793          	addi	a5,a5,1664 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc0202988:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru; // use lru Page Replacement Algorithm
ffffffffc020298a:	0000fb17          	auipc	s6,0xf
ffffffffc020298e:	bc6b0b13          	addi	s6,s6,-1082 # ffffffffc0211550 <sm>
ffffffffc0202992:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202996:	9702                	jalr	a4
ffffffffc0202998:	89aa                	mv	s3,a0

     if (r == 0)
ffffffffc020299a:	c10d                	beqz	a0,ffffffffc02029bc <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020299c:	60ea                	ld	ra,152(sp)
ffffffffc020299e:	644a                	ld	s0,144(sp)
ffffffffc02029a0:	64aa                	ld	s1,136(sp)
ffffffffc02029a2:	690a                	ld	s2,128(sp)
ffffffffc02029a4:	7a46                	ld	s4,112(sp)
ffffffffc02029a6:	7aa6                	ld	s5,104(sp)
ffffffffc02029a8:	7b06                	ld	s6,96(sp)
ffffffffc02029aa:	6be6                	ld	s7,88(sp)
ffffffffc02029ac:	6c46                	ld	s8,80(sp)
ffffffffc02029ae:	6ca6                	ld	s9,72(sp)
ffffffffc02029b0:	6d06                	ld	s10,64(sp)
ffffffffc02029b2:	7de2                	ld	s11,56(sp)
ffffffffc02029b4:	854e                	mv	a0,s3
ffffffffc02029b6:	79e6                	ld	s3,120(sp)
ffffffffc02029b8:	610d                	addi	sp,sp,160
ffffffffc02029ba:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029bc:	000b3783          	ld	a5,0(s6)
ffffffffc02029c0:	00003517          	auipc	a0,0x3
ffffffffc02029c4:	03050513          	addi	a0,a0,48 # ffffffffc02059f0 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc02029c8:	0000e497          	auipc	s1,0xe
ffffffffc02029cc:	67848493          	addi	s1,s1,1656 # ffffffffc0211040 <free_area>
ffffffffc02029d0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029d2:	4785                	li	a5,1
ffffffffc02029d4:	0000f717          	auipc	a4,0xf
ffffffffc02029d8:	b8f72223          	sw	a5,-1148(a4) # ffffffffc0211558 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029dc:	edefd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029e0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
     // backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029e2:	4401                	li	s0,0
ffffffffc02029e4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc02029e6:	2c978163          	beq	a5,s1,ffffffffc0202ca8 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029ea:	fe87b703          	ld	a4,-24(a5)
     {
          struct Page *p = le2page(le, page_link);
          assert(PageProperty(p));
ffffffffc02029ee:	8b09                	andi	a4,a4,2
ffffffffc02029f0:	2a070e63          	beqz	a4,ffffffffc0202cac <swap_init+0x362>
          count++, total += p->property;
ffffffffc02029f4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029f8:	679c                	ld	a5,8(a5)
ffffffffc02029fa:	2d05                	addiw	s10,s10,1
ffffffffc02029fc:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list)
ffffffffc02029fe:	fe9796e3          	bne	a5,s1,ffffffffc02029ea <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202a02:	8922                	mv	s2,s0
ffffffffc0202a04:	cbffe0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0202a08:	47251663          	bne	a0,s2,ffffffffc0202e74 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n", count, total);
ffffffffc0202a0c:	8622                	mv	a2,s0
ffffffffc0202a0e:	85ea                	mv	a1,s10
ffffffffc0202a10:	00003517          	auipc	a0,0x3
ffffffffc0202a14:	ff850513          	addi	a0,a0,-8 # ffffffffc0205a08 <default_pmm_manager+0x6d0>
ffffffffc0202a18:	ea2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     // now we set the phy pages env
     struct mm_struct *mm = mm_create();
ffffffffc0202a1c:	4a5000ef          	jal	ra,ffffffffc02036c0 <mm_create>
ffffffffc0202a20:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202a22:	52050963          	beqz	a0,ffffffffc0202f54 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a26:	0000f797          	auipc	a5,0xf
ffffffffc0202a2a:	b4278793          	addi	a5,a5,-1214 # ffffffffc0211568 <check_mm_struct>
ffffffffc0202a2e:	6398                	ld	a4,0(a5)
ffffffffc0202a30:	54071263          	bnez	a4,ffffffffc0202f74 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a34:	0000fb97          	auipc	s7,0xf
ffffffffc0202a38:	aecbbb83          	ld	s7,-1300(s7) # ffffffffc0211520 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a3c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a40:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a42:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a46:	3c071763          	bnez	a4,ffffffffc0202e14 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a4a:	6599                	lui	a1,0x6
ffffffffc0202a4c:	460d                	li	a2,3
ffffffffc0202a4e:	6505                	lui	a0,0x1
ffffffffc0202a50:	4b9000ef          	jal	ra,ffffffffc0203708 <vma_create>
ffffffffc0202a54:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a56:	3c050f63          	beqz	a0,ffffffffc0202e34 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a5a:	8556                	mv	a0,s5
ffffffffc0202a5c:	51b000ef          	jal	ra,ffffffffc0203776 <insert_vma_struct>

     // setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a60:	00003517          	auipc	a0,0x3
ffffffffc0202a64:	01850513          	addi	a0,a0,24 # ffffffffc0205a78 <default_pmm_manager+0x740>
ffffffffc0202a68:	e52fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep = NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a6c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a70:	4605                	li	a2,1
ffffffffc0202a72:	6585                	lui	a1,0x1
ffffffffc0202a74:	c89fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
     assert(temp_ptep != NULL);
ffffffffc0202a78:	3c050e63          	beqz	a0,ffffffffc0202e54 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a7c:	00003517          	auipc	a0,0x3
ffffffffc0202a80:	04c50513          	addi	a0,a0,76 # ffffffffc0205ac8 <default_pmm_manager+0x790>
ffffffffc0202a84:	0000e917          	auipc	s2,0xe
ffffffffc0202a88:	5f490913          	addi	s2,s2,1524 # ffffffffc0211078 <check_rp>
ffffffffc0202a8c:	e2efd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202a90:	0000ea17          	auipc	s4,0xe
ffffffffc0202a94:	608a0a13          	addi	s4,s4,1544 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a98:	8c4a                	mv	s8,s2
     {
          check_rp[i] = alloc_page();
ffffffffc0202a9a:	4505                	li	a0,1
ffffffffc0202a9c:	b55fe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0202aa0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL);
ffffffffc0202aa4:	28050c63          	beqz	a0,ffffffffc0202d3c <swap_init+0x3f2>
ffffffffc0202aa8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202aaa:	8b89                	andi	a5,a5,2
ffffffffc0202aac:	26079863          	bnez	a5,ffffffffc0202d1c <swap_init+0x3d2>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202ab0:	0c21                	addi	s8,s8,8
ffffffffc0202ab2:	ff4c14e3          	bne	s8,s4,ffffffffc0202a9a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ab6:	609c                	ld	a5,0(s1)
ffffffffc0202ab8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202abc:	e084                	sd	s1,0(s1)
ffffffffc0202abe:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));

     // assert(alloc_page() == NULL);

     unsigned int nr_free_store = nr_free;
ffffffffc0202ac0:	489c                	lw	a5,16(s1)
ffffffffc0202ac2:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202ac4:	0000ec17          	auipc	s8,0xe
ffffffffc0202ac8:	5b4c0c13          	addi	s8,s8,1460 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202acc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202ace:	0000e797          	auipc	a5,0xe
ffffffffc0202ad2:	5807a123          	sw	zero,1410(a5) # ffffffffc0211050 <free_area+0x10>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202ad6:	000c3503          	ld	a0,0(s8)
ffffffffc0202ada:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202adc:	0c21                	addi	s8,s8,8
          free_pages(check_rp[i], 1);
ffffffffc0202ade:	ba5fe0ef          	jal	ra,ffffffffc0201682 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202ae2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ad6 <swap_init+0x18c>
     }
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ae6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202aea:	4791                	li	a5,4
ffffffffc0202aec:	4afc1463          	bne	s8,a5,ffffffffc0202f94 <swap_init+0x64a>

     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202af0:	00003517          	auipc	a0,0x3
ffffffffc0202af4:	06050513          	addi	a0,a0,96 # ffffffffc0205b50 <default_pmm_manager+0x818>
ffffffffc0202af8:	dc2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202afc:	6605                	lui	a2,0x1
     // setup initial vir_page<->phy_page environment for page relpacement algorithm

     pgfault_num = 0;
ffffffffc0202afe:	0000f797          	auipc	a5,0xf
ffffffffc0202b02:	a607a923          	sw	zero,-1422(a5) # ffffffffc0211570 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b06:	4529                	li	a0,10
ffffffffc0202b08:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num == 1);
ffffffffc0202b0c:	0000f597          	auipc	a1,0xf
ffffffffc0202b10:	a645a583          	lw	a1,-1436(a1) # ffffffffc0211570 <pgfault_num>
ffffffffc0202b14:	4805                	li	a6,1
ffffffffc0202b16:	0000f797          	auipc	a5,0xf
ffffffffc0202b1a:	a5a78793          	addi	a5,a5,-1446 # ffffffffc0211570 <pgfault_num>
ffffffffc0202b1e:	3f059b63          	bne	a1,a6,ffffffffc0202f14 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b22:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num == 1);
ffffffffc0202b26:	4390                	lw	a2,0(a5)
ffffffffc0202b28:	2601                	sext.w	a2,a2
ffffffffc0202b2a:	40b61563          	bne	a2,a1,ffffffffc0202f34 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b2e:	6589                	lui	a1,0x2
ffffffffc0202b30:	452d                	li	a0,11
ffffffffc0202b32:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num == 2);
ffffffffc0202b36:	4390                	lw	a2,0(a5)
ffffffffc0202b38:	4809                	li	a6,2
ffffffffc0202b3a:	2601                	sext.w	a2,a2
ffffffffc0202b3c:	35061c63          	bne	a2,a6,ffffffffc0202e94 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b40:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 2);
ffffffffc0202b44:	438c                	lw	a1,0(a5)
ffffffffc0202b46:	2581                	sext.w	a1,a1
ffffffffc0202b48:	36c59663          	bne	a1,a2,ffffffffc0202eb4 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b4c:	658d                	lui	a1,0x3
ffffffffc0202b4e:	4531                	li	a0,12
ffffffffc0202b50:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num == 3);
ffffffffc0202b54:	4390                	lw	a2,0(a5)
ffffffffc0202b56:	480d                	li	a6,3
ffffffffc0202b58:	2601                	sext.w	a2,a2
ffffffffc0202b5a:	37061d63          	bne	a2,a6,ffffffffc0202ed4 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b5e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 3);
ffffffffc0202b62:	438c                	lw	a1,0(a5)
ffffffffc0202b64:	2581                	sext.w	a1,a1
ffffffffc0202b66:	38c59763          	bne	a1,a2,ffffffffc0202ef4 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b6a:	6591                	lui	a1,0x4
ffffffffc0202b6c:	4535                	li	a0,13
ffffffffc0202b6e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num == 4);
ffffffffc0202b72:	4390                	lw	a2,0(a5)
ffffffffc0202b74:	2601                	sext.w	a2,a2
ffffffffc0202b76:	21861f63          	bne	a2,s8,ffffffffc0202d94 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b7a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 4);
ffffffffc0202b7e:	439c                	lw	a5,0(a5)
ffffffffc0202b80:	2781                	sext.w	a5,a5
ffffffffc0202b82:	22c79963          	bne	a5,a2,ffffffffc0202db4 <swap_init+0x46a>

     check_content_set();
     assert(nr_free == 0);
ffffffffc0202b86:	489c                	lw	a5,16(s1)
ffffffffc0202b88:	24079663          	bnez	a5,ffffffffc0202dd4 <swap_init+0x48a>
ffffffffc0202b8c:	0000e797          	auipc	a5,0xe
ffffffffc0202b90:	50c78793          	addi	a5,a5,1292 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202b94:	0000e617          	auipc	a2,0xe
ffffffffc0202b98:	52c60613          	addi	a2,a2,1324 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202b9c:	0000e517          	auipc	a0,0xe
ffffffffc0202ba0:	52450513          	addi	a0,a0,1316 # ffffffffc02110c0 <swap_out_seq_no>
     for (i = 0; i < MAX_SEQ_NO; i++)
          swap_out_seq_no[i] = swap_in_seq_no[i] = -1;
ffffffffc0202ba4:	55fd                	li	a1,-1
ffffffffc0202ba6:	c38c                	sw	a1,0(a5)
ffffffffc0202ba8:	c20c                	sw	a1,0(a2)
     for (i = 0; i < MAX_SEQ_NO; i++)
ffffffffc0202baa:	0791                	addi	a5,a5,4
ffffffffc0202bac:	0611                	addi	a2,a2,4
ffffffffc0202bae:	fef51ce3          	bne	a0,a5,ffffffffc0202ba6 <swap_init+0x25c>
ffffffffc0202bb2:	0000e817          	auipc	a6,0xe
ffffffffc0202bb6:	4a680813          	addi	a6,a6,1190 # ffffffffc0211058 <check_ptep>
ffffffffc0202bba:	0000e897          	auipc	a7,0xe
ffffffffc0202bbe:	4be88893          	addi	a7,a7,1214 # ffffffffc0211078 <check_rp>
ffffffffc0202bc2:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202bc4:	0000fc97          	auipc	s9,0xf
ffffffffc0202bc8:	96cc8c93          	addi	s9,s9,-1684 # ffffffffc0211530 <pages>
ffffffffc0202bcc:	00004c17          	auipc	s8,0x4
ffffffffc0202bd0:	96cc0c13          	addi	s8,s8,-1684 # ffffffffc0206538 <nbase>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          check_ptep[i] = 0;
ffffffffc0202bd4:	00083023          	sd	zero,0(a6)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bd8:	4601                	li	a2,0
ffffffffc0202bda:	855e                	mv	a0,s7
ffffffffc0202bdc:	ec46                	sd	a7,24(sp)
ffffffffc0202bde:	e82e                	sd	a1,16(sp)
          check_ptep[i] = 0;
ffffffffc0202be0:	e442                	sd	a6,8(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202be2:	b1bfe0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0202be6:	6822                	ld	a6,8(sp)
          // cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
          assert(check_ptep[i] != NULL);
ffffffffc0202be8:	65c2                	ld	a1,16(sp)
ffffffffc0202bea:	68e2                	ld	a7,24(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bec:	00a83023          	sd	a0,0(a6)
          assert(check_ptep[i] != NULL);
ffffffffc0202bf0:	0000f317          	auipc	t1,0xf
ffffffffc0202bf4:	93830313          	addi	t1,t1,-1736 # ffffffffc0211528 <npage>
ffffffffc0202bf8:	16050e63          	beqz	a0,ffffffffc0202d74 <swap_init+0x42a>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bfc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202bfe:	0017f613          	andi	a2,a5,1
ffffffffc0202c02:	0e060563          	beqz	a2,ffffffffc0202cec <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202c06:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c0a:	078a                	slli	a5,a5,0x2
ffffffffc0202c0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c0e:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202d04 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c12:	000c3603          	ld	a2,0(s8)
ffffffffc0202c16:	000cb503          	ld	a0,0(s9)
ffffffffc0202c1a:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c1e:	8f91                	sub	a5,a5,a2
ffffffffc0202c20:	00379613          	slli	a2,a5,0x3
ffffffffc0202c24:	97b2                	add	a5,a5,a2
ffffffffc0202c26:	078e                	slli	a5,a5,0x3
ffffffffc0202c28:	97aa                	add	a5,a5,a0
ffffffffc0202c2a:	0aff1163          	bne	t5,a5,ffffffffc0202ccc <swap_init+0x382>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c2e:	6785                	lui	a5,0x1
ffffffffc0202c30:	95be                	add	a1,a1,a5
ffffffffc0202c32:	6795                	lui	a5,0x5
ffffffffc0202c34:	0821                	addi	a6,a6,8
ffffffffc0202c36:	08a1                	addi	a7,a7,8
ffffffffc0202c38:	f8f59ee3          	bne	a1,a5,ffffffffc0202bd4 <swap_init+0x28a>
          assert((*check_ptep[i] & PTE_V));
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c3c:	00003517          	auipc	a0,0x3
ffffffffc0202c40:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205c18 <default_pmm_manager+0x8e0>
ffffffffc0202c44:	c76fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     int ret = sm->check_swap();
ffffffffc0202c48:	000b3783          	ld	a5,0(s6)
ffffffffc0202c4c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c4e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm
     ret = check_content_access();
     assert(ret == 0);
ffffffffc0202c50:	1a051263          	bnez	a0,ffffffffc0202df4 <swap_init+0x4aa>

     // restore kernel mem env
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202c54:	00093503          	ld	a0,0(s2)
ffffffffc0202c58:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c5a:	0921                	addi	s2,s2,8
          free_pages(check_rp[i], 1);
ffffffffc0202c5c:	a27fe0ef          	jal	ra,ffffffffc0201682 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c60:	ff491ae3          	bne	s2,s4,ffffffffc0202c54 <swap_init+0x30a>
     }

     // free_page(pte2page(*temp_ptep));

     mm_destroy(mm);
ffffffffc0202c64:	8556                	mv	a0,s5
ffffffffc0202c66:	3e1000ef          	jal	ra,ffffffffc0203846 <mm_destroy>

     nr_free = nr_free_store;
ffffffffc0202c6a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c6c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c70:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c72:	7782                	ld	a5,32(sp)
ffffffffc0202c74:	e09c                	sd	a5,0(s1)

     le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c76:	009d8a63          	beq	s11,s1,ffffffffc0202c8a <swap_init+0x340>
     {
          struct Page *p = le2page(le, page_link);
          count--, total -= p->property;
ffffffffc0202c7a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c7e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c82:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c84:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c86:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c7a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n", count, total);
ffffffffc0202c8a:	8622                	mv	a2,s0
ffffffffc0202c8c:	85ea                	mv	a1,s10
ffffffffc0202c8e:	00003517          	auipc	a0,0x3
ffffffffc0202c92:	fc250513          	addi	a0,a0,-62 # ffffffffc0205c50 <default_pmm_manager+0x918>
ffffffffc0202c96:	c24fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     // assert(count == 0);

     cprintf("check_swap() succeeded!\n");
ffffffffc0202c9a:	00003517          	auipc	a0,0x3
ffffffffc0202c9e:	fd650513          	addi	a0,a0,-42 # ffffffffc0205c70 <default_pmm_manager+0x938>
ffffffffc0202ca2:	c18fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202ca6:	b9dd                	j	ffffffffc020299c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list)
ffffffffc0202ca8:	4901                	li	s2,0
ffffffffc0202caa:	bba9                	j	ffffffffc0202a04 <swap_init+0xba>
          assert(PageProperty(p));
ffffffffc0202cac:	00002697          	auipc	a3,0x2
ffffffffc0202cb0:	2cc68693          	addi	a3,a3,716 # ffffffffc0204f78 <commands+0x748>
ffffffffc0202cb4:	00002617          	auipc	a2,0x2
ffffffffc0202cb8:	2d460613          	addi	a2,a2,724 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202cbc:	0b600593          	li	a1,182
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	d2050513          	addi	a0,a0,-736 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202cc8:	eacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202ccc:	00003697          	auipc	a3,0x3
ffffffffc0202cd0:	f2468693          	addi	a3,a3,-220 # ffffffffc0205bf0 <default_pmm_manager+0x8b8>
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	2b460613          	addi	a2,a2,692 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202cdc:	0f800593          	li	a1,248
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	d0050513          	addi	a0,a0,-768 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cec:	00002617          	auipc	a2,0x2
ffffffffc0202cf0:	6b460613          	addi	a2,a2,1716 # ffffffffc02053a0 <default_pmm_manager+0x68>
ffffffffc0202cf4:	07000593          	li	a1,112
ffffffffc0202cf8:	00002517          	auipc	a0,0x2
ffffffffc0202cfc:	69850513          	addi	a0,a0,1688 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc0202d00:	e74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	66c60613          	addi	a2,a2,1644 # ffffffffc0205370 <default_pmm_manager+0x38>
ffffffffc0202d0c:	06500593          	li	a1,101
ffffffffc0202d10:	00002517          	auipc	a0,0x2
ffffffffc0202d14:	68050513          	addi	a0,a0,1664 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	dec68693          	addi	a3,a3,-532 # ffffffffc0205b08 <default_pmm_manager+0x7d0>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	26460613          	addi	a2,a2,612 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202d2c:	0d800593          	li	a1,216
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	cb050513          	addi	a0,a0,-848 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	db468693          	addi	a3,a3,-588 # ffffffffc0205af0 <default_pmm_manager+0x7b8>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	24460613          	addi	a2,a2,580 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202d4c:	0d700593          	li	a1,215
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	c9050513          	addi	a0,a0,-880 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d5c:	00003617          	auipc	a2,0x3
ffffffffc0202d60:	c6460613          	addi	a2,a2,-924 # ffffffffc02059c0 <default_pmm_manager+0x688>
ffffffffc0202d64:	02700593          	li	a1,39
ffffffffc0202d68:	00003517          	auipc	a0,0x3
ffffffffc0202d6c:	c7850513          	addi	a0,a0,-904 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202d70:	e04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_ptep[i] != NULL);
ffffffffc0202d74:	00003697          	auipc	a3,0x3
ffffffffc0202d78:	e6468693          	addi	a3,a3,-412 # ffffffffc0205bd8 <default_pmm_manager+0x8a0>
ffffffffc0202d7c:	00002617          	auipc	a2,0x2
ffffffffc0202d80:	20c60613          	addi	a2,a2,524 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202d84:	0f700593          	li	a1,247
ffffffffc0202d88:	00003517          	auipc	a0,0x3
ffffffffc0202d8c:	c5850513          	addi	a0,a0,-936 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202d90:	de4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202d94:	00003697          	auipc	a3,0x3
ffffffffc0202d98:	e2c68693          	addi	a3,a3,-468 # ffffffffc0205bc0 <default_pmm_manager+0x888>
ffffffffc0202d9c:	00002617          	auipc	a2,0x2
ffffffffc0202da0:	1ec60613          	addi	a2,a2,492 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202da4:	09800593          	li	a1,152
ffffffffc0202da8:	00003517          	auipc	a0,0x3
ffffffffc0202dac:	c3850513          	addi	a0,a0,-968 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202db0:	dc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202db4:	00003697          	auipc	a3,0x3
ffffffffc0202db8:	e0c68693          	addi	a3,a3,-500 # ffffffffc0205bc0 <default_pmm_manager+0x888>
ffffffffc0202dbc:	00002617          	auipc	a2,0x2
ffffffffc0202dc0:	1cc60613          	addi	a2,a2,460 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202dc4:	09a00593          	li	a1,154
ffffffffc0202dc8:	00003517          	auipc	a0,0x3
ffffffffc0202dcc:	c1850513          	addi	a0,a0,-1000 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202dd0:	da4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == 0);
ffffffffc0202dd4:	00002697          	auipc	a3,0x2
ffffffffc0202dd8:	38c68693          	addi	a3,a3,908 # ffffffffc0205160 <commands+0x930>
ffffffffc0202ddc:	00002617          	auipc	a2,0x2
ffffffffc0202de0:	1ac60613          	addi	a2,a2,428 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202de4:	0ee00593          	li	a1,238
ffffffffc0202de8:	00003517          	auipc	a0,0x3
ffffffffc0202dec:	bf850513          	addi	a0,a0,-1032 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202df0:	d84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret == 0);
ffffffffc0202df4:	00003697          	auipc	a3,0x3
ffffffffc0202df8:	e4c68693          	addi	a3,a3,-436 # ffffffffc0205c40 <default_pmm_manager+0x908>
ffffffffc0202dfc:	00002617          	auipc	a2,0x2
ffffffffc0202e00:	18c60613          	addi	a2,a2,396 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202e04:	0fe00593          	li	a1,254
ffffffffc0202e08:	00003517          	auipc	a0,0x3
ffffffffc0202e0c:	bd850513          	addi	a0,a0,-1064 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202e10:	d64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e14:	00003697          	auipc	a3,0x3
ffffffffc0202e18:	c4468693          	addi	a3,a3,-956 # ffffffffc0205a58 <default_pmm_manager+0x720>
ffffffffc0202e1c:	00002617          	auipc	a2,0x2
ffffffffc0202e20:	16c60613          	addi	a2,a2,364 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202e24:	0c600593          	li	a1,198
ffffffffc0202e28:	00003517          	auipc	a0,0x3
ffffffffc0202e2c:	bb850513          	addi	a0,a0,-1096 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202e30:	d44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e34:	00003697          	auipc	a3,0x3
ffffffffc0202e38:	c3468693          	addi	a3,a3,-972 # ffffffffc0205a68 <default_pmm_manager+0x730>
ffffffffc0202e3c:	00002617          	auipc	a2,0x2
ffffffffc0202e40:	14c60613          	addi	a2,a2,332 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202e44:	0c900593          	li	a1,201
ffffffffc0202e48:	00003517          	auipc	a0,0x3
ffffffffc0202e4c:	b9850513          	addi	a0,a0,-1128 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202e50:	d24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep != NULL);
ffffffffc0202e54:	00003697          	auipc	a3,0x3
ffffffffc0202e58:	c5c68693          	addi	a3,a3,-932 # ffffffffc0205ab0 <default_pmm_manager+0x778>
ffffffffc0202e5c:	00002617          	auipc	a2,0x2
ffffffffc0202e60:	12c60613          	addi	a2,a2,300 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202e64:	0d100593          	li	a1,209
ffffffffc0202e68:	00003517          	auipc	a0,0x3
ffffffffc0202e6c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202e70:	d04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e74:	00002697          	auipc	a3,0x2
ffffffffc0202e78:	14468693          	addi	a3,a3,324 # ffffffffc0204fb8 <commands+0x788>
ffffffffc0202e7c:	00002617          	auipc	a2,0x2
ffffffffc0202e80:	10c60613          	addi	a2,a2,268 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202e84:	0b900593          	li	a1,185
ffffffffc0202e88:	00003517          	auipc	a0,0x3
ffffffffc0202e8c:	b5850513          	addi	a0,a0,-1192 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202e90:	ce4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202e94:	00003697          	auipc	a3,0x3
ffffffffc0202e98:	cfc68693          	addi	a3,a3,-772 # ffffffffc0205b90 <default_pmm_manager+0x858>
ffffffffc0202e9c:	00002617          	auipc	a2,0x2
ffffffffc0202ea0:	0ec60613          	addi	a2,a2,236 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202ea4:	09000593          	li	a1,144
ffffffffc0202ea8:	00003517          	auipc	a0,0x3
ffffffffc0202eac:	b3850513          	addi	a0,a0,-1224 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202eb0:	cc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202eb4:	00003697          	auipc	a3,0x3
ffffffffc0202eb8:	cdc68693          	addi	a3,a3,-804 # ffffffffc0205b90 <default_pmm_manager+0x858>
ffffffffc0202ebc:	00002617          	auipc	a2,0x2
ffffffffc0202ec0:	0cc60613          	addi	a2,a2,204 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202ec4:	09200593          	li	a1,146
ffffffffc0202ec8:	00003517          	auipc	a0,0x3
ffffffffc0202ecc:	b1850513          	addi	a0,a0,-1256 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202ed0:	ca4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ed4:	00003697          	auipc	a3,0x3
ffffffffc0202ed8:	cd468693          	addi	a3,a3,-812 # ffffffffc0205ba8 <default_pmm_manager+0x870>
ffffffffc0202edc:	00002617          	auipc	a2,0x2
ffffffffc0202ee0:	0ac60613          	addi	a2,a2,172 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202ee4:	09400593          	li	a1,148
ffffffffc0202ee8:	00003517          	auipc	a0,0x3
ffffffffc0202eec:	af850513          	addi	a0,a0,-1288 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202ef0:	c84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ef4:	00003697          	auipc	a3,0x3
ffffffffc0202ef8:	cb468693          	addi	a3,a3,-844 # ffffffffc0205ba8 <default_pmm_manager+0x870>
ffffffffc0202efc:	00002617          	auipc	a2,0x2
ffffffffc0202f00:	08c60613          	addi	a2,a2,140 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202f04:	09600593          	li	a1,150
ffffffffc0202f08:	00003517          	auipc	a0,0x3
ffffffffc0202f0c:	ad850513          	addi	a0,a0,-1320 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202f10:	c64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202f14:	00003697          	auipc	a3,0x3
ffffffffc0202f18:	c6468693          	addi	a3,a3,-924 # ffffffffc0205b78 <default_pmm_manager+0x840>
ffffffffc0202f1c:	00002617          	auipc	a2,0x2
ffffffffc0202f20:	06c60613          	addi	a2,a2,108 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202f24:	08c00593          	li	a1,140
ffffffffc0202f28:	00003517          	auipc	a0,0x3
ffffffffc0202f2c:	ab850513          	addi	a0,a0,-1352 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202f30:	c44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202f34:	00003697          	auipc	a3,0x3
ffffffffc0202f38:	c4468693          	addi	a3,a3,-956 # ffffffffc0205b78 <default_pmm_manager+0x840>
ffffffffc0202f3c:	00002617          	auipc	a2,0x2
ffffffffc0202f40:	04c60613          	addi	a2,a2,76 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202f44:	08e00593          	li	a1,142
ffffffffc0202f48:	00003517          	auipc	a0,0x3
ffffffffc0202f4c:	a9850513          	addi	a0,a0,-1384 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202f50:	c24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f54:	00003697          	auipc	a3,0x3
ffffffffc0202f58:	adc68693          	addi	a3,a3,-1316 # ffffffffc0205a30 <default_pmm_manager+0x6f8>
ffffffffc0202f5c:	00002617          	auipc	a2,0x2
ffffffffc0202f60:	02c60613          	addi	a2,a2,44 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202f64:	0be00593          	li	a1,190
ffffffffc0202f68:	00003517          	auipc	a0,0x3
ffffffffc0202f6c:	a7850513          	addi	a0,a0,-1416 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202f70:	c04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f74:	00003697          	auipc	a3,0x3
ffffffffc0202f78:	acc68693          	addi	a3,a3,-1332 # ffffffffc0205a40 <default_pmm_manager+0x708>
ffffffffc0202f7c:	00002617          	auipc	a2,0x2
ffffffffc0202f80:	00c60613          	addi	a2,a2,12 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202f84:	0c100593          	li	a1,193
ffffffffc0202f88:	00003517          	auipc	a0,0x3
ffffffffc0202f8c:	a5850513          	addi	a0,a0,-1448 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202f90:	be4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f94:	00003697          	auipc	a3,0x3
ffffffffc0202f98:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205b28 <default_pmm_manager+0x7f0>
ffffffffc0202f9c:	00002617          	auipc	a2,0x2
ffffffffc0202fa0:	fec60613          	addi	a2,a2,-20 # ffffffffc0204f88 <commands+0x758>
ffffffffc0202fa4:	0e600593          	li	a1,230
ffffffffc0202fa8:	00003517          	auipc	a0,0x3
ffffffffc0202fac:	a3850513          	addi	a0,a0,-1480 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0202fb0:	bc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202fb4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202fb4:	0000e797          	auipc	a5,0xe
ffffffffc0202fb8:	59c7b783          	ld	a5,1436(a5) # ffffffffc0211550 <sm>
ffffffffc0202fbc:	6b9c                	ld	a5,16(a5)
ffffffffc0202fbe:	8782                	jr	a5

ffffffffc0202fc0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202fc0:	0000e797          	auipc	a5,0xe
ffffffffc0202fc4:	5907b783          	ld	a5,1424(a5) # ffffffffc0211550 <sm>
ffffffffc0202fc8:	739c                	ld	a5,32(a5)
ffffffffc0202fca:	8782                	jr	a5

ffffffffc0202fcc <swap_out>:
{
ffffffffc0202fcc:	711d                	addi	sp,sp,-96
ffffffffc0202fce:	ec86                	sd	ra,88(sp)
ffffffffc0202fd0:	e8a2                	sd	s0,80(sp)
ffffffffc0202fd2:	e4a6                	sd	s1,72(sp)
ffffffffc0202fd4:	e0ca                	sd	s2,64(sp)
ffffffffc0202fd6:	fc4e                	sd	s3,56(sp)
ffffffffc0202fd8:	f852                	sd	s4,48(sp)
ffffffffc0202fda:	f456                	sd	s5,40(sp)
ffffffffc0202fdc:	f05a                	sd	s6,32(sp)
ffffffffc0202fde:	ec5e                	sd	s7,24(sp)
ffffffffc0202fe0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++i)
ffffffffc0202fe2:	cde9                	beqz	a1,ffffffffc02030bc <swap_out+0xf0>
ffffffffc0202fe4:	8a2e                	mv	s4,a1
ffffffffc0202fe6:	892a                	mv	s2,a0
ffffffffc0202fe8:	8ab2                	mv	s5,a2
ffffffffc0202fea:	4401                	li	s0,0
ffffffffc0202fec:	0000e997          	auipc	s3,0xe
ffffffffc0202ff0:	56498993          	addi	s3,s3,1380 # ffffffffc0211550 <sm>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202ff4:	00003b17          	auipc	s6,0x3
ffffffffc0202ff8:	cfcb0b13          	addi	s6,s6,-772 # ffffffffc0205cf0 <default_pmm_manager+0x9b8>
               cprintf("SWAP: failed to save\n");
ffffffffc0202ffc:	00003b97          	auipc	s7,0x3
ffffffffc0203000:	cdcb8b93          	addi	s7,s7,-804 # ffffffffc0205cd8 <default_pmm_manager+0x9a0>
ffffffffc0203004:	a825                	j	ffffffffc020303c <swap_out+0x70>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203006:	67a2                	ld	a5,8(sp)
ffffffffc0203008:	8626                	mv	a2,s1
ffffffffc020300a:	85a2                	mv	a1,s0
ffffffffc020300c:	63b4                	ld	a3,64(a5)
ffffffffc020300e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++i)
ffffffffc0203010:	2405                	addiw	s0,s0,1
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203012:	82b1                	srli	a3,a3,0xc
ffffffffc0203014:	0685                	addi	a3,a3,1
ffffffffc0203016:	8a4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc020301a:	6522                	ld	a0,8(sp)
               free_page(page);
ffffffffc020301c:	4585                	li	a1,1
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc020301e:	613c                	ld	a5,64(a0)
ffffffffc0203020:	83b1                	srli	a5,a5,0xc
ffffffffc0203022:	0785                	addi	a5,a5,1
ffffffffc0203024:	07a2                	slli	a5,a5,0x8
ffffffffc0203026:	00fc3023          	sd	a5,0(s8)
               free_page(page);
ffffffffc020302a:	e58fe0ef          	jal	ra,ffffffffc0201682 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020302e:	01893503          	ld	a0,24(s2)
ffffffffc0203032:	85a6                	mv	a1,s1
ffffffffc0203034:	eb6ff0ef          	jal	ra,ffffffffc02026ea <tlb_invalidate>
     for (i = 0; i != n; ++i)
ffffffffc0203038:	048a0d63          	beq	s4,s0,ffffffffc0203092 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020303c:	0009b783          	ld	a5,0(s3)
ffffffffc0203040:	8656                	mv	a2,s5
ffffffffc0203042:	002c                	addi	a1,sp,8
ffffffffc0203044:	7b9c                	ld	a5,48(a5)
ffffffffc0203046:	854a                	mv	a0,s2
ffffffffc0203048:	9782                	jalr	a5
          if (r != 0)
ffffffffc020304a:	e12d                	bnez	a0,ffffffffc02030ac <swap_out+0xe0>
          v = page->pra_vaddr;
ffffffffc020304c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020304e:	01893503          	ld	a0,24(s2)
ffffffffc0203052:	4601                	li	a2,0
          v = page->pra_vaddr;
ffffffffc0203054:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203056:	85a6                	mv	a1,s1
ffffffffc0203058:	ea4fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020305c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020305e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203060:	8b85                	andi	a5,a5,1
ffffffffc0203062:	cfb9                	beqz	a5,ffffffffc02030c0 <swap_out+0xf4>
          if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0)
ffffffffc0203064:	65a2                	ld	a1,8(sp)
ffffffffc0203066:	61bc                	ld	a5,64(a1)
ffffffffc0203068:	83b1                	srli	a5,a5,0xc
ffffffffc020306a:	0785                	addi	a5,a5,1
ffffffffc020306c:	00879513          	slli	a0,a5,0x8
ffffffffc0203070:	785000ef          	jal	ra,ffffffffc0203ff4 <swapfs_write>
ffffffffc0203074:	d949                	beqz	a0,ffffffffc0203006 <swap_out+0x3a>
               cprintf("SWAP: failed to save\n");
ffffffffc0203076:	855e                	mv	a0,s7
ffffffffc0203078:	842fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               sm->map_swappable(mm, v, page, 0);
ffffffffc020307c:	0009b783          	ld	a5,0(s3)
ffffffffc0203080:	6622                	ld	a2,8(sp)
ffffffffc0203082:	4681                	li	a3,0
ffffffffc0203084:	739c                	ld	a5,32(a5)
ffffffffc0203086:	85a6                	mv	a1,s1
ffffffffc0203088:	854a                	mv	a0,s2
     for (i = 0; i != n; ++i)
ffffffffc020308a:	2405                	addiw	s0,s0,1
               sm->map_swappable(mm, v, page, 0);
ffffffffc020308c:	9782                	jalr	a5
     for (i = 0; i != n; ++i)
ffffffffc020308e:	fa8a17e3          	bne	s4,s0,ffffffffc020303c <swap_out+0x70>
}
ffffffffc0203092:	60e6                	ld	ra,88(sp)
ffffffffc0203094:	8522                	mv	a0,s0
ffffffffc0203096:	6446                	ld	s0,80(sp)
ffffffffc0203098:	64a6                	ld	s1,72(sp)
ffffffffc020309a:	6906                	ld	s2,64(sp)
ffffffffc020309c:	79e2                	ld	s3,56(sp)
ffffffffc020309e:	7a42                	ld	s4,48(sp)
ffffffffc02030a0:	7aa2                	ld	s5,40(sp)
ffffffffc02030a2:	7b02                	ld	s6,32(sp)
ffffffffc02030a4:	6be2                	ld	s7,24(sp)
ffffffffc02030a6:	6c42                	ld	s8,16(sp)
ffffffffc02030a8:	6125                	addi	sp,sp,96
ffffffffc02030aa:	8082                	ret
               cprintf("i %d, swap_out: call swap_out_victim failed\n", i);
ffffffffc02030ac:	85a2                	mv	a1,s0
ffffffffc02030ae:	00003517          	auipc	a0,0x3
ffffffffc02030b2:	be250513          	addi	a0,a0,-1054 # ffffffffc0205c90 <default_pmm_manager+0x958>
ffffffffc02030b6:	804fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               break;
ffffffffc02030ba:	bfe1                	j	ffffffffc0203092 <swap_out+0xc6>
     for (i = 0; i != n; ++i)
ffffffffc02030bc:	4401                	li	s0,0
ffffffffc02030be:	bfd1                	j	ffffffffc0203092 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030c0:	00003697          	auipc	a3,0x3
ffffffffc02030c4:	c0068693          	addi	a3,a3,-1024 # ffffffffc0205cc0 <default_pmm_manager+0x988>
ffffffffc02030c8:	00002617          	auipc	a2,0x2
ffffffffc02030cc:	ec060613          	addi	a2,a2,-320 # ffffffffc0204f88 <commands+0x758>
ffffffffc02030d0:	06200593          	li	a1,98
ffffffffc02030d4:	00003517          	auipc	a0,0x3
ffffffffc02030d8:	90c50513          	addi	a0,a0,-1780 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc02030dc:	a98fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030e0 <swap_in>:
{
ffffffffc02030e0:	7179                	addi	sp,sp,-48
ffffffffc02030e2:	e84a                	sd	s2,16(sp)
ffffffffc02030e4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030e6:	4505                	li	a0,1
{
ffffffffc02030e8:	ec26                	sd	s1,24(sp)
ffffffffc02030ea:	e44e                	sd	s3,8(sp)
ffffffffc02030ec:	f406                	sd	ra,40(sp)
ffffffffc02030ee:	f022                	sd	s0,32(sp)
ffffffffc02030f0:	84ae                	mv	s1,a1
ffffffffc02030f2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02030f4:	cfcfe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
     assert(result != NULL);
ffffffffc02030f8:	c129                	beqz	a0,ffffffffc020313a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02030fa:	842a                	mv	s0,a0
ffffffffc02030fc:	01893503          	ld	a0,24(s2)
ffffffffc0203100:	4601                	li	a2,0
ffffffffc0203102:	85a6                	mv	a1,s1
ffffffffc0203104:	df8fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0203108:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020310a:	6108                	ld	a0,0(a0)
ffffffffc020310c:	85a2                	mv	a1,s0
ffffffffc020310e:	64d000ef          	jal	ra,ffffffffc0203f5a <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep) >> 8, addr);
ffffffffc0203112:	00093583          	ld	a1,0(s2)
ffffffffc0203116:	8626                	mv	a2,s1
ffffffffc0203118:	00003517          	auipc	a0,0x3
ffffffffc020311c:	c2850513          	addi	a0,a0,-984 # ffffffffc0205d40 <default_pmm_manager+0xa08>
ffffffffc0203120:	81a1                	srli	a1,a1,0x8
ffffffffc0203122:	f99fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203126:	70a2                	ld	ra,40(sp)
     *ptr_result = result;
ffffffffc0203128:	0089b023          	sd	s0,0(s3)
}
ffffffffc020312c:	7402                	ld	s0,32(sp)
ffffffffc020312e:	64e2                	ld	s1,24(sp)
ffffffffc0203130:	6942                	ld	s2,16(sp)
ffffffffc0203132:	69a2                	ld	s3,8(sp)
ffffffffc0203134:	4501                	li	a0,0
ffffffffc0203136:	6145                	addi	sp,sp,48
ffffffffc0203138:	8082                	ret
     assert(result != NULL);
ffffffffc020313a:	00003697          	auipc	a3,0x3
ffffffffc020313e:	bf668693          	addi	a3,a3,-1034 # ffffffffc0205d30 <default_pmm_manager+0x9f8>
ffffffffc0203142:	00002617          	auipc	a2,0x2
ffffffffc0203146:	e4660613          	addi	a2,a2,-442 # ffffffffc0204f88 <commands+0x758>
ffffffffc020314a:	07900593          	li	a1,121
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	89250513          	addi	a0,a0,-1902 # ffffffffc02059e0 <default_pmm_manager+0x6a8>
ffffffffc0203156:	a1efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020315a <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020315a:	0000e797          	auipc	a5,0xe
ffffffffc020315e:	f8e78793          	addi	a5,a5,-114 # ffffffffc02110e8 <pra_list_head>
static int
_lru_init_mm(struct mm_struct *mm)
{

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0203162:	f51c                	sd	a5,40(a0)
ffffffffc0203164:	e79c                	sd	a5,8(a5)
ffffffffc0203166:	e39c                	sd	a5,0(a5)
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203168:	4501                	li	a0,0
ffffffffc020316a:	8082                	ret

ffffffffc020316c <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc020316c:	4501                	li	a0,0
ffffffffc020316e:	8082                	ret

ffffffffc0203170 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203170:	4501                	li	a0,0
ffffffffc0203172:	8082                	ret

ffffffffc0203174 <_lru_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0203174:	751c                	ld	a5,40(a0)
{
ffffffffc0203176:	1101                	addi	sp,sp,-32
ffffffffc0203178:	ec06                	sd	ra,24(sp)
ffffffffc020317a:	e822                	sd	s0,16(sp)
ffffffffc020317c:	e426                	sd	s1,8(sp)
    assert(head != NULL);
ffffffffc020317e:	c7bd                	beqz	a5,ffffffffc02031ec <_lru_swap_out_victim+0x78>
    assert(in_tick == 0);
ffffffffc0203180:	e631                	bnez	a2,ffffffffc02031cc <_lru_swap_out_victim+0x58>
ffffffffc0203182:	842e                	mv	s0,a1
    return listelm->prev;
ffffffffc0203184:	638c                	ld	a1,0(a5)
    curr_ptr = list_prev(head);
ffffffffc0203186:	0000e497          	auipc	s1,0xe
ffffffffc020318a:	3da48493          	addi	s1,s1,986 # ffffffffc0211560 <curr_ptr>
ffffffffc020318e:	e08c                	sd	a1,0(s1)
    if (curr_ptr != head)
ffffffffc0203190:	02b78663          	beq	a5,a1,ffffffffc02031bc <_lru_swap_out_victim+0x48>
        cprintf("curr_ptr 0xffffffff%08x\n", curr_ptr);
ffffffffc0203194:	00003517          	auipc	a0,0x3
ffffffffc0203198:	c2450513          	addi	a0,a0,-988 # ffffffffc0205db8 <default_pmm_manager+0xa80>
ffffffffc020319c:	f1ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        list_del(curr_ptr);
ffffffffc02031a0:	609c                	ld	a5,0(s1)
}
ffffffffc02031a2:	60e2                	ld	ra,24(sp)
ffffffffc02031a4:	64a2                	ld	s1,8(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc02031a6:	6394                	ld	a3,0(a5)
ffffffffc02031a8:	6798                	ld	a4,8(a5)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc02031aa:	fd078793          	addi	a5,a5,-48
}
ffffffffc02031ae:	4501                	li	a0,0
    prev->next = next;
ffffffffc02031b0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02031b2:	e314                	sd	a3,0(a4)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc02031b4:	e01c                	sd	a5,0(s0)
}
ffffffffc02031b6:	6442                	ld	s0,16(sp)
ffffffffc02031b8:	6105                	addi	sp,sp,32
ffffffffc02031ba:	8082                	ret
ffffffffc02031bc:	60e2                	ld	ra,24(sp)
        *ptr_page = NULL;
ffffffffc02031be:	00043023          	sd	zero,0(s0)
}
ffffffffc02031c2:	6442                	ld	s0,16(sp)
ffffffffc02031c4:	64a2                	ld	s1,8(sp)
ffffffffc02031c6:	4501                	li	a0,0
ffffffffc02031c8:	6105                	addi	sp,sp,32
ffffffffc02031ca:	8082                	ret
    assert(in_tick == 0);
ffffffffc02031cc:	00003697          	auipc	a3,0x3
ffffffffc02031d0:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0205da8 <default_pmm_manager+0xa70>
ffffffffc02031d4:	00002617          	auipc	a2,0x2
ffffffffc02031d8:	db460613          	addi	a2,a2,-588 # ffffffffc0204f88 <commands+0x758>
ffffffffc02031dc:	02500593          	li	a1,37
ffffffffc02031e0:	00003517          	auipc	a0,0x3
ffffffffc02031e4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0205d90 <default_pmm_manager+0xa58>
ffffffffc02031e8:	98cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(head != NULL);
ffffffffc02031ec:	00003697          	auipc	a3,0x3
ffffffffc02031f0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205d80 <default_pmm_manager+0xa48>
ffffffffc02031f4:	00002617          	auipc	a2,0x2
ffffffffc02031f8:	d9460613          	addi	a2,a2,-620 # ffffffffc0204f88 <commands+0x758>
ffffffffc02031fc:	02400593          	li	a1,36
ffffffffc0203200:	00003517          	auipc	a0,0x3
ffffffffc0203204:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205d90 <default_pmm_manager+0xa58>
ffffffffc0203208:	96cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020320c <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{
ffffffffc020320c:	7179                	addi	sp,sp,-48
ffffffffc020320e:	e84a                	sd	s2,16(sp)
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0203210:	02853903          	ld	s2,40(a0)
{
ffffffffc0203214:	f406                	sd	ra,40(sp)
ffffffffc0203216:	f022                	sd	s0,32(sp)
ffffffffc0203218:	ec26                	sd	s1,24(sp)
ffffffffc020321a:	e44e                	sd	s3,8(sp)
    assert(head != NULL);
ffffffffc020321c:	08090863          	beqz	s2,ffffffffc02032ac <_lru_tick_event+0xa0>
    return listelm->next;
ffffffffc0203220:	00893403          	ld	s0,8(s2)
    curr_ptr = list_next(head); // 当前指针初始化为链表的下一个元素
ffffffffc0203224:	0000e497          	auipc	s1,0xe
ffffffffc0203228:	33c48493          	addi	s1,s1,828 # ffffffffc0211560 <curr_ptr>
ffffffffc020322c:	89aa                	mv	s3,a0
ffffffffc020322e:	e080                	sd	s0,0(s1)

    while (curr_ptr != head)
ffffffffc0203230:	00891863          	bne	s2,s0,ffffffffc0203240 <_lru_tick_event+0x34>
ffffffffc0203234:	a8b1                	j	ffffffffc0203290 <_lru_tick_event+0x84>
ffffffffc0203236:	609c                	ld	a5,0(s1)
ffffffffc0203238:	6780                	ld	s0,8(a5)
            *ptep &= ~PTE_A;                            // 清除访问位
            tlb_invalidate(mm->pgdir, page->pra_vaddr); // 使TLB失效
        }

        // 使用临时指针更新 curr_ptr
        curr_ptr = list_next(curr_ptr); // 更新 curr_ptr 为下一个节点
ffffffffc020323a:	e080                	sd	s0,0(s1)
    while (curr_ptr != head)
ffffffffc020323c:	04890a63          	beq	s2,s0,ffffffffc0203290 <_lru_tick_event+0x84>
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc0203240:	680c                	ld	a1,16(s0)
ffffffffc0203242:	0189b503          	ld	a0,24(s3)
ffffffffc0203246:	4601                	li	a2,0
ffffffffc0203248:	cb4fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
        if (*ptep & PTE_A)
ffffffffc020324c:	6118                	ld	a4,0(a0)
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc020324e:	87aa                	mv	a5,a0
        if (*ptep & PTE_A)
ffffffffc0203250:	04077693          	andi	a3,a4,64
ffffffffc0203254:	d2ed                	beqz	a3,ffffffffc0203236 <_lru_tick_event+0x2a>
            list_del(curr_ptr);                         // 从链表中删除当前节点
ffffffffc0203256:	6094                	ld	a3,0(s1)
            tlb_invalidate(mm->pgdir, page->pra_vaddr); // 使TLB失效
ffffffffc0203258:	0189b503          	ld	a0,24(s3)
            *ptep &= ~PTE_A;                            // 清除访问位
ffffffffc020325c:	fbf77713          	andi	a4,a4,-65
    __list_del(listelm->prev, listelm->next);
ffffffffc0203260:	668c                	ld	a1,8(a3)
ffffffffc0203262:	0006b803          	ld	a6,0(a3)
    prev->next = next;
ffffffffc0203266:	00b83423          	sd	a1,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc020326a:	00893603          	ld	a2,8(s2)
    next->prev = prev;
ffffffffc020326e:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
    prev->next = next->prev = elm;
ffffffffc0203272:	e214                	sd	a3,0(a2)
ffffffffc0203274:	00d93423          	sd	a3,8(s2)
    elm->next = next;
ffffffffc0203278:	e690                	sd	a2,8(a3)
    elm->prev = prev;
ffffffffc020327a:	0126b023          	sd	s2,0(a3)
ffffffffc020327e:	e398                	sd	a4,0(a5)
            tlb_invalidate(mm->pgdir, page->pra_vaddr); // 使TLB失效
ffffffffc0203280:	680c                	ld	a1,16(s0)
ffffffffc0203282:	c68ff0ef          	jal	ra,ffffffffc02026ea <tlb_invalidate>
    return listelm->next;
ffffffffc0203286:	609c                	ld	a5,0(s1)
ffffffffc0203288:	6780                	ld	s0,8(a5)
        curr_ptr = list_next(curr_ptr); // 更新 curr_ptr 为下一个节点
ffffffffc020328a:	e080                	sd	s0,0(s1)
    while (curr_ptr != head)
ffffffffc020328c:	fa891ae3          	bne	s2,s0,ffffffffc0203240 <_lru_tick_event+0x34>
    }

    cprintf("_lru_tick_event is called!\n");
ffffffffc0203290:	00003517          	auipc	a0,0x3
ffffffffc0203294:	b4850513          	addi	a0,a0,-1208 # ffffffffc0205dd8 <default_pmm_manager+0xaa0>
ffffffffc0203298:	e23fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
}
ffffffffc020329c:	70a2                	ld	ra,40(sp)
ffffffffc020329e:	7402                	ld	s0,32(sp)
ffffffffc02032a0:	64e2                	ld	s1,24(sp)
ffffffffc02032a2:	6942                	ld	s2,16(sp)
ffffffffc02032a4:	69a2                	ld	s3,8(sp)
ffffffffc02032a6:	4501                	li	a0,0
ffffffffc02032a8:	6145                	addi	sp,sp,48
ffffffffc02032aa:	8082                	ret
    assert(head != NULL);
ffffffffc02032ac:	00003697          	auipc	a3,0x3
ffffffffc02032b0:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205d80 <default_pmm_manager+0xa48>
ffffffffc02032b4:	00002617          	auipc	a2,0x2
ffffffffc02032b8:	cd460613          	addi	a2,a2,-812 # ffffffffc0204f88 <commands+0x758>
ffffffffc02032bc:	07a00593          	li	a1,122
ffffffffc02032c0:	00003517          	auipc	a0,0x3
ffffffffc02032c4:	ad050513          	addi	a0,a0,-1328 # ffffffffc0205d90 <default_pmm_manager+0xa58>
ffffffffc02032c8:	8acfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032cc <_lru_map_swappable>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc02032cc:	751c                	ld	a5,40(a0)
    curr_ptr = &(page->pra_page_link);
ffffffffc02032ce:	03060713          	addi	a4,a2,48
ffffffffc02032d2:	0000e697          	auipc	a3,0xe
ffffffffc02032d6:	28e6b723          	sd	a4,654(a3) # ffffffffc0211560 <curr_ptr>
    assert(curr_ptr != NULL && head != NULL);
ffffffffc02032da:	cb81                	beqz	a5,ffffffffc02032ea <_lru_map_swappable+0x1e>
    __list_add(elm, listelm, listelm->next);
ffffffffc02032dc:	6794                	ld	a3,8(a5)
}
ffffffffc02032de:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc02032e0:	e298                	sd	a4,0(a3)
ffffffffc02032e2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02032e4:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc02032e6:	fa1c                	sd	a5,48(a2)
ffffffffc02032e8:	8082                	ret
{
ffffffffc02032ea:	1141                	addi	sp,sp,-16
    assert(curr_ptr != NULL && head != NULL);
ffffffffc02032ec:	00003697          	auipc	a3,0x3
ffffffffc02032f0:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205df8 <default_pmm_manager+0xac0>
ffffffffc02032f4:	00002617          	auipc	a2,0x2
ffffffffc02032f8:	c9460613          	addi	a2,a2,-876 # ffffffffc0204f88 <commands+0x758>
ffffffffc02032fc:	45ed                	li	a1,27
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	a9250513          	addi	a0,a0,-1390 # ffffffffc0205d90 <default_pmm_manager+0xa58>
{
ffffffffc0203306:	e406                	sd	ra,8(sp)
    assert(curr_ptr != NULL && head != NULL);
ffffffffc0203308:	86cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020330c <_lru_check_swap>:
{
ffffffffc020330c:	1101                	addi	sp,sp,-32
ffffffffc020330e:	e822                	sd	s0,16(sp)
    cprintf("--------begin----------\n");
ffffffffc0203310:	00003517          	auipc	a0,0x3
ffffffffc0203314:	b1050513          	addi	a0,a0,-1264 # ffffffffc0205e20 <default_pmm_manager+0xae8>
    return listelm->next;
ffffffffc0203318:	0000e417          	auipc	s0,0xe
ffffffffc020331c:	dd040413          	addi	s0,s0,-560 # ffffffffc02110e8 <pra_list_head>
{
ffffffffc0203320:	e426                	sd	s1,8(sp)
ffffffffc0203322:	ec06                	sd	ra,24(sp)
ffffffffc0203324:	e04a                	sd	s2,0(sp)
    cprintf("--------begin----------\n");
ffffffffc0203326:	d95fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020332a:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc020332c:	00848d63          	beq	s1,s0,ffffffffc0203346 <_lru_check_swap+0x3a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203330:	00003917          	auipc	s2,0x3
ffffffffc0203334:	b1090913          	addi	s2,s2,-1264 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203338:	688c                	ld	a1,16(s1)
ffffffffc020333a:	854a                	mv	a0,s2
ffffffffc020333c:	d7ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203340:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203342:	fe849be3          	bne	s1,s0,ffffffffc0203338 <_lru_check_swap+0x2c>
    cprintf("---------end-----------\n");
ffffffffc0203346:	00003517          	auipc	a0,0x3
ffffffffc020334a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc020334e:	d6dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203352:	00003517          	auipc	a0,0x3
ffffffffc0203356:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0205e70 <default_pmm_manager+0xb38>
ffffffffc020335a:	d61fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020335e:	678d                	lui	a5,0x3
ffffffffc0203360:	4731                	li	a4,12
ffffffffc0203362:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    cprintf("--------begin----------\n");
ffffffffc0203366:	00003517          	auipc	a0,0x3
ffffffffc020336a:	aba50513          	addi	a0,a0,-1350 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc020336e:	d4dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203372:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203374:	00848d63          	beq	s1,s0,ffffffffc020338e <_lru_check_swap+0x82>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203378:	00003917          	auipc	s2,0x3
ffffffffc020337c:	ac890913          	addi	s2,s2,-1336 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203380:	688c                	ld	a1,16(s1)
ffffffffc0203382:	854a                	mv	a0,s2
ffffffffc0203384:	d37fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203388:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020338a:	fe849be3          	bne	s1,s0,ffffffffc0203380 <_lru_check_swap+0x74>
    cprintf("---------end-----------\n");
ffffffffc020338e:	00003517          	auipc	a0,0x3
ffffffffc0203392:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc0203396:	d25fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc020339a:	00003517          	auipc	a0,0x3
ffffffffc020339e:	afe50513          	addi	a0,a0,-1282 # ffffffffc0205e98 <default_pmm_manager+0xb60>
ffffffffc02033a2:	d19fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02033a6:	6785                	lui	a5,0x1
ffffffffc02033a8:	4729                	li	a4,10
ffffffffc02033aa:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    cprintf("--------begin----------\n");
ffffffffc02033ae:	00003517          	auipc	a0,0x3
ffffffffc02033b2:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc02033b6:	d05fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02033ba:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02033bc:	00848d63          	beq	s1,s0,ffffffffc02033d6 <_lru_check_swap+0xca>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02033c0:	00003917          	auipc	s2,0x3
ffffffffc02033c4:	a8090913          	addi	s2,s2,-1408 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc02033c8:	688c                	ld	a1,16(s1)
ffffffffc02033ca:	854a                	mv	a0,s2
ffffffffc02033cc:	ceffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02033d0:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02033d2:	fe849be3          	bne	s1,s0,ffffffffc02033c8 <_lru_check_swap+0xbc>
    cprintf("---------end-----------\n");
ffffffffc02033d6:	00003517          	auipc	a0,0x3
ffffffffc02033da:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc02033de:	cddfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc02033e2:	00003517          	auipc	a0,0x3
ffffffffc02033e6:	ade50513          	addi	a0,a0,-1314 # ffffffffc0205ec0 <default_pmm_manager+0xb88>
ffffffffc02033ea:	cd1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02033ee:	6789                	lui	a5,0x2
ffffffffc02033f0:	472d                	li	a4,11
ffffffffc02033f2:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc02033f6:	00003517          	auipc	a0,0x3
ffffffffc02033fa:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc02033fe:	cbdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203402:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203404:	00848d63          	beq	s1,s0,ffffffffc020341e <_lru_check_swap+0x112>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203408:	00003917          	auipc	s2,0x3
ffffffffc020340c:	a3890913          	addi	s2,s2,-1480 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203410:	688c                	ld	a1,16(s1)
ffffffffc0203412:	854a                	mv	a0,s2
ffffffffc0203414:	ca7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203418:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020341a:	fe849be3          	bne	s1,s0,ffffffffc0203410 <_lru_check_swap+0x104>
    cprintf("---------end-----------\n");
ffffffffc020341e:	00003517          	auipc	a0,0x3
ffffffffc0203422:	a3250513          	addi	a0,a0,-1486 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc0203426:	c95fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc020342a:	00003517          	auipc	a0,0x3
ffffffffc020342e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205ee8 <default_pmm_manager+0xbb0>
ffffffffc0203432:	c89fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203436:	6795                	lui	a5,0x5
ffffffffc0203438:	4739                	li	a4,14
ffffffffc020343a:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    cprintf("--------begin----------\n");
ffffffffc020343e:	00003517          	auipc	a0,0x3
ffffffffc0203442:	9e250513          	addi	a0,a0,-1566 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc0203446:	c75fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020344a:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc020344c:	00848d63          	beq	s1,s0,ffffffffc0203466 <_lru_check_swap+0x15a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203450:	00003917          	auipc	s2,0x3
ffffffffc0203454:	9f090913          	addi	s2,s2,-1552 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203458:	688c                	ld	a1,16(s1)
ffffffffc020345a:	854a                	mv	a0,s2
ffffffffc020345c:	c5ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203460:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203462:	fe849be3          	bne	s1,s0,ffffffffc0203458 <_lru_check_swap+0x14c>
    cprintf("---------end-----------\n");
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc020346e:	c4dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203472:	00003517          	auipc	a0,0x3
ffffffffc0203476:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0205ec0 <default_pmm_manager+0xb88>
ffffffffc020347a:	c41fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020347e:	6789                	lui	a5,0x2
ffffffffc0203480:	472d                	li	a4,11
ffffffffc0203482:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc0203486:	00003517          	auipc	a0,0x3
ffffffffc020348a:	99a50513          	addi	a0,a0,-1638 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc020348e:	c2dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203492:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203494:	00848d63          	beq	s1,s0,ffffffffc02034ae <_lru_check_swap+0x1a2>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203498:	00003917          	auipc	s2,0x3
ffffffffc020349c:	9a890913          	addi	s2,s2,-1624 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc02034a0:	688c                	ld	a1,16(s1)
ffffffffc02034a2:	854a                	mv	a0,s2
ffffffffc02034a4:	c17fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02034a8:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02034aa:	fe849be3          	bne	s1,s0,ffffffffc02034a0 <_lru_check_swap+0x194>
    cprintf("---------end-----------\n");
ffffffffc02034ae:	00003517          	auipc	a0,0x3
ffffffffc02034b2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc02034b6:	c05fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02034ba:	00003517          	auipc	a0,0x3
ffffffffc02034be:	9de50513          	addi	a0,a0,-1570 # ffffffffc0205e98 <default_pmm_manager+0xb60>
ffffffffc02034c2:	bf9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034c6:	6785                	lui	a5,0x1
ffffffffc02034c8:	4729                	li	a4,10
ffffffffc02034ca:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    cprintf("--------begin----------\n");
ffffffffc02034ce:	00003517          	auipc	a0,0x3
ffffffffc02034d2:	95250513          	addi	a0,a0,-1710 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc02034d6:	be5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02034da:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02034dc:	00848d63          	beq	s1,s0,ffffffffc02034f6 <_lru_check_swap+0x1ea>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02034e0:	00003917          	auipc	s2,0x3
ffffffffc02034e4:	96090913          	addi	s2,s2,-1696 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc02034e8:	688c                	ld	a1,16(s1)
ffffffffc02034ea:	854a                	mv	a0,s2
ffffffffc02034ec:	bcffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02034f0:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02034f2:	fe849be3          	bne	s1,s0,ffffffffc02034e8 <_lru_check_swap+0x1dc>
    cprintf("---------end-----------\n");
ffffffffc02034f6:	00003517          	auipc	a0,0x3
ffffffffc02034fa:	95a50513          	addi	a0,a0,-1702 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc02034fe:	bbdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203502:	00003517          	auipc	a0,0x3
ffffffffc0203506:	9be50513          	addi	a0,a0,-1602 # ffffffffc0205ec0 <default_pmm_manager+0xb88>
ffffffffc020350a:	bb1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020350e:	6789                	lui	a5,0x2
ffffffffc0203510:	472d                	li	a4,11
ffffffffc0203512:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc0203516:	00003517          	auipc	a0,0x3
ffffffffc020351a:	90a50513          	addi	a0,a0,-1782 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc020351e:	b9dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203522:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203524:	00848d63          	beq	s1,s0,ffffffffc020353e <_lru_check_swap+0x232>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203528:	00003917          	auipc	s2,0x3
ffffffffc020352c:	91890913          	addi	s2,s2,-1768 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203530:	688c                	ld	a1,16(s1)
ffffffffc0203532:	854a                	mv	a0,s2
ffffffffc0203534:	b87fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203538:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020353a:	fe849be3          	bne	s1,s0,ffffffffc0203530 <_lru_check_swap+0x224>
    cprintf("---------end-----------\n");
ffffffffc020353e:	00003517          	auipc	a0,0x3
ffffffffc0203542:	91250513          	addi	a0,a0,-1774 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc0203546:	b75fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc020354a:	00003517          	auipc	a0,0x3
ffffffffc020354e:	92650513          	addi	a0,a0,-1754 # ffffffffc0205e70 <default_pmm_manager+0xb38>
ffffffffc0203552:	b69fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203556:	678d                	lui	a5,0x3
ffffffffc0203558:	4731                	li	a4,12
ffffffffc020355a:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    cprintf("--------begin----------\n");
ffffffffc020355e:	00003517          	auipc	a0,0x3
ffffffffc0203562:	8c250513          	addi	a0,a0,-1854 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc0203566:	b55fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020356a:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc020356c:	00848d63          	beq	s1,s0,ffffffffc0203586 <_lru_check_swap+0x27a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203570:	00003917          	auipc	s2,0x3
ffffffffc0203574:	8d090913          	addi	s2,s2,-1840 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203578:	688c                	ld	a1,16(s1)
ffffffffc020357a:	854a                	mv	a0,s2
ffffffffc020357c:	b3ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203580:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203582:	fe849be3          	bne	s1,s0,ffffffffc0203578 <_lru_check_swap+0x26c>
    cprintf("---------end-----------\n");
ffffffffc0203586:	00003517          	auipc	a0,0x3
ffffffffc020358a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc020358e:	b2dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203592:	00003517          	auipc	a0,0x3
ffffffffc0203596:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205f10 <default_pmm_manager+0xbd8>
ffffffffc020359a:	b21fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020359e:	6791                	lui	a5,0x4
ffffffffc02035a0:	4735                	li	a4,13
ffffffffc02035a2:	00e78023          	sb	a4,0(a5) # 4000 <kern_entry-0xffffffffc01fc000>
    cprintf("--------begin----------\n");
ffffffffc02035a6:	00003517          	auipc	a0,0x3
ffffffffc02035aa:	87a50513          	addi	a0,a0,-1926 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc02035ae:	b0dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02035b2:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02035b4:	00848d63          	beq	s1,s0,ffffffffc02035ce <_lru_check_swap+0x2c2>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02035b8:	00003917          	auipc	s2,0x3
ffffffffc02035bc:	88890913          	addi	s2,s2,-1912 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc02035c0:	688c                	ld	a1,16(s1)
ffffffffc02035c2:	854a                	mv	a0,s2
ffffffffc02035c4:	af7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02035c8:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02035ca:	fe849be3          	bne	s1,s0,ffffffffc02035c0 <_lru_check_swap+0x2b4>
    cprintf("---------end-----------\n");
ffffffffc02035ce:	00003517          	auipc	a0,0x3
ffffffffc02035d2:	88250513          	addi	a0,a0,-1918 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc02035d6:	ae5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc02035da:	00003517          	auipc	a0,0x3
ffffffffc02035de:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205ee8 <default_pmm_manager+0xbb0>
ffffffffc02035e2:	ad9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02035e6:	6795                	lui	a5,0x5
ffffffffc02035e8:	4739                	li	a4,14
ffffffffc02035ea:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    cprintf("--------begin----------\n");
ffffffffc02035ee:	00003517          	auipc	a0,0x3
ffffffffc02035f2:	83250513          	addi	a0,a0,-1998 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc02035f6:	ac5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02035fa:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02035fc:	00848d63          	beq	s1,s0,ffffffffc0203616 <_lru_check_swap+0x30a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203600:	00003917          	auipc	s2,0x3
ffffffffc0203604:	84090913          	addi	s2,s2,-1984 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203608:	688c                	ld	a1,16(s1)
ffffffffc020360a:	854a                	mv	a0,s2
ffffffffc020360c:	aaffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203610:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203612:	fe849be3          	bne	s1,s0,ffffffffc0203608 <_lru_check_swap+0x2fc>
    cprintf("---------end-----------\n");
ffffffffc0203616:	00003517          	auipc	a0,0x3
ffffffffc020361a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc020361e:	a9dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203622:	00003517          	auipc	a0,0x3
ffffffffc0203626:	87650513          	addi	a0,a0,-1930 # ffffffffc0205e98 <default_pmm_manager+0xb60>
ffffffffc020362a:	a91fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020362e:	6785                	lui	a5,0x1
ffffffffc0203630:	0007c703          	lbu	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203634:	47a9                	li	a5,10
ffffffffc0203636:	04f71363          	bne	a4,a5,ffffffffc020367c <_lru_check_swap+0x370>
    cprintf("--------begin----------\n");
ffffffffc020363a:	00002517          	auipc	a0,0x2
ffffffffc020363e:	7e650513          	addi	a0,a0,2022 # ffffffffc0205e20 <default_pmm_manager+0xae8>
ffffffffc0203642:	a79fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203646:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203648:	00848d63          	beq	s1,s0,ffffffffc0203662 <_lru_check_swap+0x356>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc020364c:	00002917          	auipc	s2,0x2
ffffffffc0203650:	7f490913          	addi	s2,s2,2036 # ffffffffc0205e40 <default_pmm_manager+0xb08>
ffffffffc0203654:	688c                	ld	a1,16(s1)
ffffffffc0203656:	854a                	mv	a0,s2
ffffffffc0203658:	a63fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020365c:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020365e:	fe849be3          	bne	s1,s0,ffffffffc0203654 <_lru_check_swap+0x348>
    cprintf("---------end-----------\n");
ffffffffc0203662:	00002517          	auipc	a0,0x2
ffffffffc0203666:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205e50 <default_pmm_manager+0xb18>
ffffffffc020366a:	a51fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc020366e:	60e2                	ld	ra,24(sp)
ffffffffc0203670:	6442                	ld	s0,16(sp)
ffffffffc0203672:	64a2                	ld	s1,8(sp)
ffffffffc0203674:	6902                	ld	s2,0(sp)
ffffffffc0203676:	4501                	li	a0,0
ffffffffc0203678:	6105                	addi	sp,sp,32
ffffffffc020367a:	8082                	ret
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020367c:	00003697          	auipc	a3,0x3
ffffffffc0203680:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0205f38 <default_pmm_manager+0xc00>
ffffffffc0203684:	00002617          	auipc	a2,0x2
ffffffffc0203688:	90460613          	addi	a2,a2,-1788 # ffffffffc0204f88 <commands+0x758>
ffffffffc020368c:	06400593          	li	a1,100
ffffffffc0203690:	00002517          	auipc	a0,0x2
ffffffffc0203694:	70050513          	addi	a0,a0,1792 # ffffffffc0205d90 <default_pmm_manager+0xa58>
ffffffffc0203698:	cddfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020369c <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020369c:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020369e:	00003697          	auipc	a3,0x3
ffffffffc02036a2:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205f78 <default_pmm_manager+0xc40>
ffffffffc02036a6:	00002617          	auipc	a2,0x2
ffffffffc02036aa:	8e260613          	addi	a2,a2,-1822 # ffffffffc0204f88 <commands+0x758>
ffffffffc02036ae:	07d00593          	li	a1,125
ffffffffc02036b2:	00003517          	auipc	a0,0x3
ffffffffc02036b6:	8e650513          	addi	a0,a0,-1818 # ffffffffc0205f98 <default_pmm_manager+0xc60>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02036ba:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02036bc:	cb9fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02036c0 <mm_create>:
mm_create(void) {
ffffffffc02036c0:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02036c2:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02036c6:	e022                	sd	s0,0(sp)
ffffffffc02036c8:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02036ca:	8deff0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc02036ce:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02036d0:	c105                	beqz	a0,ffffffffc02036f0 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02036d2:	e408                	sd	a0,8(s0)
ffffffffc02036d4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02036d6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02036da:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02036de:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02036e2:	0000e797          	auipc	a5,0xe
ffffffffc02036e6:	e767a783          	lw	a5,-394(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02036ea:	eb81                	bnez	a5,ffffffffc02036fa <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02036ec:	02053423          	sd	zero,40(a0)
}
ffffffffc02036f0:	60a2                	ld	ra,8(sp)
ffffffffc02036f2:	8522                	mv	a0,s0
ffffffffc02036f4:	6402                	ld	s0,0(sp)
ffffffffc02036f6:	0141                	addi	sp,sp,16
ffffffffc02036f8:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02036fa:	8bbff0ef          	jal	ra,ffffffffc0202fb4 <swap_init_mm>
}
ffffffffc02036fe:	60a2                	ld	ra,8(sp)
ffffffffc0203700:	8522                	mv	a0,s0
ffffffffc0203702:	6402                	ld	s0,0(sp)
ffffffffc0203704:	0141                	addi	sp,sp,16
ffffffffc0203706:	8082                	ret

ffffffffc0203708 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203708:	1101                	addi	sp,sp,-32
ffffffffc020370a:	e04a                	sd	s2,0(sp)
ffffffffc020370c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020370e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203712:	e822                	sd	s0,16(sp)
ffffffffc0203714:	e426                	sd	s1,8(sp)
ffffffffc0203716:	ec06                	sd	ra,24(sp)
ffffffffc0203718:	84ae                	mv	s1,a1
ffffffffc020371a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020371c:	88cff0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
    if (vma != NULL) {
ffffffffc0203720:	c509                	beqz	a0,ffffffffc020372a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203722:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203726:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203728:	ed00                	sd	s0,24(a0)
}
ffffffffc020372a:	60e2                	ld	ra,24(sp)
ffffffffc020372c:	6442                	ld	s0,16(sp)
ffffffffc020372e:	64a2                	ld	s1,8(sp)
ffffffffc0203730:	6902                	ld	s2,0(sp)
ffffffffc0203732:	6105                	addi	sp,sp,32
ffffffffc0203734:	8082                	ret

ffffffffc0203736 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203736:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203738:	c505                	beqz	a0,ffffffffc0203760 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020373a:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020373c:	c501                	beqz	a0,ffffffffc0203744 <find_vma+0xe>
ffffffffc020373e:	651c                	ld	a5,8(a0)
ffffffffc0203740:	02f5f263          	bgeu	a1,a5,ffffffffc0203764 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203744:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203746:	00f68d63          	beq	a3,a5,ffffffffc0203760 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020374a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020374e:	00e5e663          	bltu	a1,a4,ffffffffc020375a <find_vma+0x24>
ffffffffc0203752:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203756:	00e5ec63          	bltu	a1,a4,ffffffffc020376e <find_vma+0x38>
ffffffffc020375a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020375c:	fef697e3          	bne	a3,a5,ffffffffc020374a <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203760:	4501                	li	a0,0
}
ffffffffc0203762:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203764:	691c                	ld	a5,16(a0)
ffffffffc0203766:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203744 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020376a:	ea88                	sd	a0,16(a3)
ffffffffc020376c:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020376e:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203772:	ea88                	sd	a0,16(a3)
ffffffffc0203774:	8082                	ret

ffffffffc0203776 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203776:	6590                	ld	a2,8(a1)
ffffffffc0203778:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020377c:	1141                	addi	sp,sp,-16
ffffffffc020377e:	e406                	sd	ra,8(sp)
ffffffffc0203780:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203782:	01066763          	bltu	a2,a6,ffffffffc0203790 <insert_vma_struct+0x1a>
ffffffffc0203786:	a085                	j	ffffffffc02037e6 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203788:	fe87b703          	ld	a4,-24(a5)
ffffffffc020378c:	04e66863          	bltu	a2,a4,ffffffffc02037dc <insert_vma_struct+0x66>
ffffffffc0203790:	86be                	mv	a3,a5
ffffffffc0203792:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203794:	fef51ae3          	bne	a0,a5,ffffffffc0203788 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203798:	02a68463          	beq	a3,a0,ffffffffc02037c0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020379c:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02037a0:	fe86b883          	ld	a7,-24(a3)
ffffffffc02037a4:	08e8f163          	bgeu	a7,a4,ffffffffc0203826 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037a8:	04e66f63          	bltu	a2,a4,ffffffffc0203806 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02037ac:	00f50a63          	beq	a0,a5,ffffffffc02037c0 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02037b0:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037b4:	05076963          	bltu	a4,a6,ffffffffc0203806 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02037b8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02037bc:	02c77363          	bgeu	a4,a2,ffffffffc02037e2 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02037c0:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02037c2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02037c4:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02037c8:	e390                	sd	a2,0(a5)
ffffffffc02037ca:	e690                	sd	a2,8(a3)
}
ffffffffc02037cc:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02037ce:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02037d0:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02037d2:	0017079b          	addiw	a5,a4,1
ffffffffc02037d6:	d11c                	sw	a5,32(a0)
}
ffffffffc02037d8:	0141                	addi	sp,sp,16
ffffffffc02037da:	8082                	ret
    if (le_prev != list) {
ffffffffc02037dc:	fca690e3          	bne	a3,a0,ffffffffc020379c <insert_vma_struct+0x26>
ffffffffc02037e0:	bfd1                	j	ffffffffc02037b4 <insert_vma_struct+0x3e>
ffffffffc02037e2:	ebbff0ef          	jal	ra,ffffffffc020369c <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02037e6:	00002697          	auipc	a3,0x2
ffffffffc02037ea:	7c268693          	addi	a3,a3,1986 # ffffffffc0205fa8 <default_pmm_manager+0xc70>
ffffffffc02037ee:	00001617          	auipc	a2,0x1
ffffffffc02037f2:	79a60613          	addi	a2,a2,1946 # ffffffffc0204f88 <commands+0x758>
ffffffffc02037f6:	08400593          	li	a1,132
ffffffffc02037fa:	00002517          	auipc	a0,0x2
ffffffffc02037fe:	79e50513          	addi	a0,a0,1950 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203802:	b73fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203806:	00002697          	auipc	a3,0x2
ffffffffc020380a:	7e268693          	addi	a3,a3,2018 # ffffffffc0205fe8 <default_pmm_manager+0xcb0>
ffffffffc020380e:	00001617          	auipc	a2,0x1
ffffffffc0203812:	77a60613          	addi	a2,a2,1914 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203816:	07c00593          	li	a1,124
ffffffffc020381a:	00002517          	auipc	a0,0x2
ffffffffc020381e:	77e50513          	addi	a0,a0,1918 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203822:	b53fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203826:	00002697          	auipc	a3,0x2
ffffffffc020382a:	7a268693          	addi	a3,a3,1954 # ffffffffc0205fc8 <default_pmm_manager+0xc90>
ffffffffc020382e:	00001617          	auipc	a2,0x1
ffffffffc0203832:	75a60613          	addi	a2,a2,1882 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203836:	07b00593          	li	a1,123
ffffffffc020383a:	00002517          	auipc	a0,0x2
ffffffffc020383e:	75e50513          	addi	a0,a0,1886 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203842:	b33fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203846 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203846:	1141                	addi	sp,sp,-16
ffffffffc0203848:	e022                	sd	s0,0(sp)
ffffffffc020384a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020384c:	6508                	ld	a0,8(a0)
ffffffffc020384e:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203850:	00a40e63          	beq	s0,a0,ffffffffc020386c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203854:	6118                	ld	a4,0(a0)
ffffffffc0203856:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203858:	03000593          	li	a1,48
ffffffffc020385c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020385e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203860:	e398                	sd	a4,0(a5)
ffffffffc0203862:	800ff0ef          	jal	ra,ffffffffc0202862 <kfree>
    return listelm->next;
ffffffffc0203866:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203868:	fea416e3          	bne	s0,a0,ffffffffc0203854 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020386c:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020386e:	6402                	ld	s0,0(sp)
ffffffffc0203870:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203872:	03000593          	li	a1,48
}
ffffffffc0203876:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203878:	febfe06f          	j	ffffffffc0202862 <kfree>

ffffffffc020387c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020387c:	715d                	addi	sp,sp,-80
ffffffffc020387e:	e486                	sd	ra,72(sp)
ffffffffc0203880:	f44e                	sd	s3,40(sp)
ffffffffc0203882:	f052                	sd	s4,32(sp)
ffffffffc0203884:	e0a2                	sd	s0,64(sp)
ffffffffc0203886:	fc26                	sd	s1,56(sp)
ffffffffc0203888:	f84a                	sd	s2,48(sp)
ffffffffc020388a:	ec56                	sd	s5,24(sp)
ffffffffc020388c:	e85a                	sd	s6,16(sp)
ffffffffc020388e:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203890:	e33fd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203894:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203896:	e2dfd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc020389a:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020389c:	03000513          	li	a0,48
ffffffffc02038a0:	f09fe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
    if (mm != NULL) {
ffffffffc02038a4:	56050863          	beqz	a0,ffffffffc0203e14 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc02038a8:	e508                	sd	a0,8(a0)
ffffffffc02038aa:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02038ac:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02038b0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02038b4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038b8:	0000e797          	auipc	a5,0xe
ffffffffc02038bc:	ca07a783          	lw	a5,-864(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02038c0:	84aa                	mv	s1,a0
ffffffffc02038c2:	e7b9                	bnez	a5,ffffffffc0203910 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc02038c4:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02038c8:	03200413          	li	s0,50
ffffffffc02038cc:	a811                	j	ffffffffc02038e0 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02038ce:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02038d0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02038d2:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02038d6:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02038d8:	8526                	mv	a0,s1
ffffffffc02038da:	e9dff0ef          	jal	ra,ffffffffc0203776 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02038de:	cc05                	beqz	s0,ffffffffc0203916 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038e0:	03000513          	li	a0,48
ffffffffc02038e4:	ec5fe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc02038e8:	85aa                	mv	a1,a0
ffffffffc02038ea:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02038ee:	f165                	bnez	a0,ffffffffc02038ce <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02038f0:	00002697          	auipc	a3,0x2
ffffffffc02038f4:	17868693          	addi	a3,a3,376 # ffffffffc0205a68 <default_pmm_manager+0x730>
ffffffffc02038f8:	00001617          	auipc	a2,0x1
ffffffffc02038fc:	69060613          	addi	a2,a2,1680 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203900:	0ce00593          	li	a1,206
ffffffffc0203904:	00002517          	auipc	a0,0x2
ffffffffc0203908:	69450513          	addi	a0,a0,1684 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc020390c:	a69fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203910:	ea4ff0ef          	jal	ra,ffffffffc0202fb4 <swap_init_mm>
ffffffffc0203914:	bf55                	j	ffffffffc02038c8 <vmm_init+0x4c>
ffffffffc0203916:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020391a:	1f900913          	li	s2,505
ffffffffc020391e:	a819                	j	ffffffffc0203934 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0203920:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203922:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203924:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203928:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020392a:	8526                	mv	a0,s1
ffffffffc020392c:	e4bff0ef          	jal	ra,ffffffffc0203776 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203930:	03240a63          	beq	s0,s2,ffffffffc0203964 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203934:	03000513          	li	a0,48
ffffffffc0203938:	e71fe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc020393c:	85aa                	mv	a1,a0
ffffffffc020393e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203942:	fd79                	bnez	a0,ffffffffc0203920 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0203944:	00002697          	auipc	a3,0x2
ffffffffc0203948:	12468693          	addi	a3,a3,292 # ffffffffc0205a68 <default_pmm_manager+0x730>
ffffffffc020394c:	00001617          	auipc	a2,0x1
ffffffffc0203950:	63c60613          	addi	a2,a2,1596 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203954:	0d400593          	li	a1,212
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	64050513          	addi	a0,a0,1600 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203960:	a15fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc0203964:	649c                	ld	a5,8(s1)
ffffffffc0203966:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203968:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020396c:	2ef48463          	beq	s1,a5,ffffffffc0203c54 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203970:	fe87b603          	ld	a2,-24(a5)
ffffffffc0203974:	ffe70693          	addi	a3,a4,-2
ffffffffc0203978:	26d61e63          	bne	a2,a3,ffffffffc0203bf4 <vmm_init+0x378>
ffffffffc020397c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203980:	26e69a63          	bne	a3,a4,ffffffffc0203bf4 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203984:	0715                	addi	a4,a4,5
ffffffffc0203986:	679c                	ld	a5,8(a5)
ffffffffc0203988:	feb712e3          	bne	a4,a1,ffffffffc020396c <vmm_init+0xf0>
ffffffffc020398c:	4b1d                	li	s6,7
ffffffffc020398e:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203990:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203994:	85a2                	mv	a1,s0
ffffffffc0203996:	8526                	mv	a0,s1
ffffffffc0203998:	d9fff0ef          	jal	ra,ffffffffc0203736 <find_vma>
ffffffffc020399c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020399e:	2c050b63          	beqz	a0,ffffffffc0203c74 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02039a2:	00140593          	addi	a1,s0,1
ffffffffc02039a6:	8526                	mv	a0,s1
ffffffffc02039a8:	d8fff0ef          	jal	ra,ffffffffc0203736 <find_vma>
ffffffffc02039ac:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02039ae:	2e050363          	beqz	a0,ffffffffc0203c94 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02039b2:	85da                	mv	a1,s6
ffffffffc02039b4:	8526                	mv	a0,s1
ffffffffc02039b6:	d81ff0ef          	jal	ra,ffffffffc0203736 <find_vma>
        assert(vma3 == NULL);
ffffffffc02039ba:	2e051d63          	bnez	a0,ffffffffc0203cb4 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02039be:	00340593          	addi	a1,s0,3
ffffffffc02039c2:	8526                	mv	a0,s1
ffffffffc02039c4:	d73ff0ef          	jal	ra,ffffffffc0203736 <find_vma>
        assert(vma4 == NULL);
ffffffffc02039c8:	30051663          	bnez	a0,ffffffffc0203cd4 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02039cc:	00440593          	addi	a1,s0,4
ffffffffc02039d0:	8526                	mv	a0,s1
ffffffffc02039d2:	d65ff0ef          	jal	ra,ffffffffc0203736 <find_vma>
        assert(vma5 == NULL);
ffffffffc02039d6:	30051f63          	bnez	a0,ffffffffc0203cf4 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02039da:	00893783          	ld	a5,8(s2)
ffffffffc02039de:	24879b63          	bne	a5,s0,ffffffffc0203c34 <vmm_init+0x3b8>
ffffffffc02039e2:	01093783          	ld	a5,16(s2)
ffffffffc02039e6:	25679763          	bne	a5,s6,ffffffffc0203c34 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02039ea:	008ab783          	ld	a5,8(s5)
ffffffffc02039ee:	22879363          	bne	a5,s0,ffffffffc0203c14 <vmm_init+0x398>
ffffffffc02039f2:	010ab783          	ld	a5,16(s5)
ffffffffc02039f6:	21679f63          	bne	a5,s6,ffffffffc0203c14 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02039fa:	0415                	addi	s0,s0,5
ffffffffc02039fc:	0b15                	addi	s6,s6,5
ffffffffc02039fe:	f9741be3          	bne	s0,s7,ffffffffc0203994 <vmm_init+0x118>
ffffffffc0203a02:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203a04:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203a06:	85a2                	mv	a1,s0
ffffffffc0203a08:	8526                	mv	a0,s1
ffffffffc0203a0a:	d2dff0ef          	jal	ra,ffffffffc0203736 <find_vma>
ffffffffc0203a0e:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203a12:	c90d                	beqz	a0,ffffffffc0203a44 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203a14:	6914                	ld	a3,16(a0)
ffffffffc0203a16:	6510                	ld	a2,8(a0)
ffffffffc0203a18:	00002517          	auipc	a0,0x2
ffffffffc0203a1c:	6f050513          	addi	a0,a0,1776 # ffffffffc0206108 <default_pmm_manager+0xdd0>
ffffffffc0203a20:	e9afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203a24:	00002697          	auipc	a3,0x2
ffffffffc0203a28:	70c68693          	addi	a3,a3,1804 # ffffffffc0206130 <default_pmm_manager+0xdf8>
ffffffffc0203a2c:	00001617          	auipc	a2,0x1
ffffffffc0203a30:	55c60613          	addi	a2,a2,1372 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203a34:	0f600593          	li	a1,246
ffffffffc0203a38:	00002517          	auipc	a0,0x2
ffffffffc0203a3c:	56050513          	addi	a0,a0,1376 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203a40:	935fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203a44:	147d                	addi	s0,s0,-1
ffffffffc0203a46:	fd2410e3          	bne	s0,s2,ffffffffc0203a06 <vmm_init+0x18a>
ffffffffc0203a4a:	a811                	j	ffffffffc0203a5e <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a4c:	6118                	ld	a4,0(a0)
ffffffffc0203a4e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203a50:	03000593          	li	a1,48
ffffffffc0203a54:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a56:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a58:	e398                	sd	a4,0(a5)
ffffffffc0203a5a:	e09fe0ef          	jal	ra,ffffffffc0202862 <kfree>
    return listelm->next;
ffffffffc0203a5e:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203a60:	fea496e3          	bne	s1,a0,ffffffffc0203a4c <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203a64:	03000593          	li	a1,48
ffffffffc0203a68:	8526                	mv	a0,s1
ffffffffc0203a6a:	df9fe0ef          	jal	ra,ffffffffc0202862 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a6e:	c55fd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203a72:	3caa1163          	bne	s4,a0,ffffffffc0203e34 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203a76:	00002517          	auipc	a0,0x2
ffffffffc0203a7a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0206170 <default_pmm_manager+0xe38>
ffffffffc0203a7e:	e3cfc0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203a82:	c41fd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203a86:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a88:	03000513          	li	a0,48
ffffffffc0203a8c:	d1dfe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc0203a90:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203a92:	2a050163          	beqz	a0,ffffffffc0203d34 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a96:	0000e797          	auipc	a5,0xe
ffffffffc0203a9a:	ac27a783          	lw	a5,-1342(a5) # ffffffffc0211558 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203a9e:	e508                	sd	a0,8(a0)
ffffffffc0203aa0:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203aa2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203aa6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203aaa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203aae:	14079063          	bnez	a5,ffffffffc0203bee <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0203ab2:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203ab6:	0000e917          	auipc	s2,0xe
ffffffffc0203aba:	a6a93903          	ld	s2,-1430(s2) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203abe:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203ac2:	0000e717          	auipc	a4,0xe
ffffffffc0203ac6:	aa873323          	sd	s0,-1370(a4) # ffffffffc0211568 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203aca:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203ace:	24079363          	bnez	a5,ffffffffc0203d14 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ad2:	03000513          	li	a0,48
ffffffffc0203ad6:	cd3fe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc0203ada:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203adc:	28050063          	beqz	a0,ffffffffc0203d5c <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0203ae0:	002007b7          	lui	a5,0x200
ffffffffc0203ae4:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203ae8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203aea:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203aec:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203af0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203af2:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203af6:	c81ff0ef          	jal	ra,ffffffffc0203776 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203afa:	10000593          	li	a1,256
ffffffffc0203afe:	8522                	mv	a0,s0
ffffffffc0203b00:	c37ff0ef          	jal	ra,ffffffffc0203736 <find_vma>
ffffffffc0203b04:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203b08:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b0c:	26aa1863          	bne	s4,a0,ffffffffc0203d7c <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203b10:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203b14:	0785                	addi	a5,a5,1
ffffffffc0203b16:	fee79de3          	bne	a5,a4,ffffffffc0203b10 <vmm_init+0x294>
        sum += i;
ffffffffc0203b1a:	6705                	lui	a4,0x1
ffffffffc0203b1c:	10000793          	li	a5,256
ffffffffc0203b20:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203b24:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203b28:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203b2c:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203b2e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203b30:	fec79ce3          	bne	a5,a2,ffffffffc0203b28 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0203b34:	26071463          	bnez	a4,ffffffffc0203d9c <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203b38:	4581                	li	a1,0
ffffffffc0203b3a:	854a                	mv	a0,s2
ffffffffc0203b3c:	e11fd0ef          	jal	ra,ffffffffc020194c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b40:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203b44:	0000e717          	auipc	a4,0xe
ffffffffc0203b48:	9e473703          	ld	a4,-1564(a4) # ffffffffc0211528 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b4c:	078a                	slli	a5,a5,0x2
ffffffffc0203b4e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b50:	26e7f663          	bgeu	a5,a4,ffffffffc0203dbc <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b54:	00003717          	auipc	a4,0x3
ffffffffc0203b58:	9e473703          	ld	a4,-1564(a4) # ffffffffc0206538 <nbase>
ffffffffc0203b5c:	8f99                	sub	a5,a5,a4
ffffffffc0203b5e:	00379713          	slli	a4,a5,0x3
ffffffffc0203b62:	97ba                	add	a5,a5,a4
ffffffffc0203b64:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203b66:	0000e517          	auipc	a0,0xe
ffffffffc0203b6a:	9ca53503          	ld	a0,-1590(a0) # ffffffffc0211530 <pages>
ffffffffc0203b6e:	953e                	add	a0,a0,a5
ffffffffc0203b70:	4585                	li	a1,1
ffffffffc0203b72:	b11fd0ef          	jal	ra,ffffffffc0201682 <free_pages>
    return listelm->next;
ffffffffc0203b76:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203b78:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203b7c:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203b80:	00a40e63          	beq	s0,a0,ffffffffc0203b9c <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b84:	6118                	ld	a4,0(a0)
ffffffffc0203b86:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203b88:	03000593          	li	a1,48
ffffffffc0203b8c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203b8e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b90:	e398                	sd	a4,0(a5)
ffffffffc0203b92:	cd1fe0ef          	jal	ra,ffffffffc0202862 <kfree>
    return listelm->next;
ffffffffc0203b96:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203b98:	fea416e3          	bne	s0,a0,ffffffffc0203b84 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203b9c:	03000593          	li	a1,48
ffffffffc0203ba0:	8522                	mv	a0,s0
ffffffffc0203ba2:	cc1fe0ef          	jal	ra,ffffffffc0202862 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203ba6:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203ba8:	0000e797          	auipc	a5,0xe
ffffffffc0203bac:	9c07b023          	sd	zero,-1600(a5) # ffffffffc0211568 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203bb0:	b13fd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203bb4:	22a49063          	bne	s1,a0,ffffffffc0203dd4 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203bb8:	00002517          	auipc	a0,0x2
ffffffffc0203bbc:	60850513          	addi	a0,a0,1544 # ffffffffc02061c0 <default_pmm_manager+0xe88>
ffffffffc0203bc0:	cfafc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203bc4:	afffd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203bc8:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203bca:	22a99563          	bne	s3,a0,ffffffffc0203df4 <vmm_init+0x578>
}
ffffffffc0203bce:	6406                	ld	s0,64(sp)
ffffffffc0203bd0:	60a6                	ld	ra,72(sp)
ffffffffc0203bd2:	74e2                	ld	s1,56(sp)
ffffffffc0203bd4:	7942                	ld	s2,48(sp)
ffffffffc0203bd6:	79a2                	ld	s3,40(sp)
ffffffffc0203bd8:	7a02                	ld	s4,32(sp)
ffffffffc0203bda:	6ae2                	ld	s5,24(sp)
ffffffffc0203bdc:	6b42                	ld	s6,16(sp)
ffffffffc0203bde:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203be0:	00002517          	auipc	a0,0x2
ffffffffc0203be4:	60050513          	addi	a0,a0,1536 # ffffffffc02061e0 <default_pmm_manager+0xea8>
}
ffffffffc0203be8:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203bea:	cd0fc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203bee:	bc6ff0ef          	jal	ra,ffffffffc0202fb4 <swap_init_mm>
ffffffffc0203bf2:	b5d1                	j	ffffffffc0203ab6 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203bf4:	00002697          	auipc	a3,0x2
ffffffffc0203bf8:	42c68693          	addi	a3,a3,1068 # ffffffffc0206020 <default_pmm_manager+0xce8>
ffffffffc0203bfc:	00001617          	auipc	a2,0x1
ffffffffc0203c00:	38c60613          	addi	a2,a2,908 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203c04:	0dd00593          	li	a1,221
ffffffffc0203c08:	00002517          	auipc	a0,0x2
ffffffffc0203c0c:	39050513          	addi	a0,a0,912 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203c10:	f64fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203c14:	00002697          	auipc	a3,0x2
ffffffffc0203c18:	4c468693          	addi	a3,a3,1220 # ffffffffc02060d8 <default_pmm_manager+0xda0>
ffffffffc0203c1c:	00001617          	auipc	a2,0x1
ffffffffc0203c20:	36c60613          	addi	a2,a2,876 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203c24:	0ee00593          	li	a1,238
ffffffffc0203c28:	00002517          	auipc	a0,0x2
ffffffffc0203c2c:	37050513          	addi	a0,a0,880 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203c30:	f44fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203c34:	00002697          	auipc	a3,0x2
ffffffffc0203c38:	47468693          	addi	a3,a3,1140 # ffffffffc02060a8 <default_pmm_manager+0xd70>
ffffffffc0203c3c:	00001617          	auipc	a2,0x1
ffffffffc0203c40:	34c60613          	addi	a2,a2,844 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203c44:	0ed00593          	li	a1,237
ffffffffc0203c48:	00002517          	auipc	a0,0x2
ffffffffc0203c4c:	35050513          	addi	a0,a0,848 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203c50:	f24fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203c54:	00002697          	auipc	a3,0x2
ffffffffc0203c58:	3b468693          	addi	a3,a3,948 # ffffffffc0206008 <default_pmm_manager+0xcd0>
ffffffffc0203c5c:	00001617          	auipc	a2,0x1
ffffffffc0203c60:	32c60613          	addi	a2,a2,812 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203c64:	0db00593          	li	a1,219
ffffffffc0203c68:	00002517          	auipc	a0,0x2
ffffffffc0203c6c:	33050513          	addi	a0,a0,816 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203c70:	f04fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203c74:	00002697          	auipc	a3,0x2
ffffffffc0203c78:	3e468693          	addi	a3,a3,996 # ffffffffc0206058 <default_pmm_manager+0xd20>
ffffffffc0203c7c:	00001617          	auipc	a2,0x1
ffffffffc0203c80:	30c60613          	addi	a2,a2,780 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203c84:	0e300593          	li	a1,227
ffffffffc0203c88:	00002517          	auipc	a0,0x2
ffffffffc0203c8c:	31050513          	addi	a0,a0,784 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203c90:	ee4fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203c94:	00002697          	auipc	a3,0x2
ffffffffc0203c98:	3d468693          	addi	a3,a3,980 # ffffffffc0206068 <default_pmm_manager+0xd30>
ffffffffc0203c9c:	00001617          	auipc	a2,0x1
ffffffffc0203ca0:	2ec60613          	addi	a2,a2,748 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203ca4:	0e500593          	li	a1,229
ffffffffc0203ca8:	00002517          	auipc	a0,0x2
ffffffffc0203cac:	2f050513          	addi	a0,a0,752 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203cb0:	ec4fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203cb4:	00002697          	auipc	a3,0x2
ffffffffc0203cb8:	3c468693          	addi	a3,a3,964 # ffffffffc0206078 <default_pmm_manager+0xd40>
ffffffffc0203cbc:	00001617          	auipc	a2,0x1
ffffffffc0203cc0:	2cc60613          	addi	a2,a2,716 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203cc4:	0e700593          	li	a1,231
ffffffffc0203cc8:	00002517          	auipc	a0,0x2
ffffffffc0203ccc:	2d050513          	addi	a0,a0,720 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203cd0:	ea4fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203cd4:	00002697          	auipc	a3,0x2
ffffffffc0203cd8:	3b468693          	addi	a3,a3,948 # ffffffffc0206088 <default_pmm_manager+0xd50>
ffffffffc0203cdc:	00001617          	auipc	a2,0x1
ffffffffc0203ce0:	2ac60613          	addi	a2,a2,684 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203ce4:	0e900593          	li	a1,233
ffffffffc0203ce8:	00002517          	auipc	a0,0x2
ffffffffc0203cec:	2b050513          	addi	a0,a0,688 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203cf0:	e84fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203cf4:	00002697          	auipc	a3,0x2
ffffffffc0203cf8:	3a468693          	addi	a3,a3,932 # ffffffffc0206098 <default_pmm_manager+0xd60>
ffffffffc0203cfc:	00001617          	auipc	a2,0x1
ffffffffc0203d00:	28c60613          	addi	a2,a2,652 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203d04:	0eb00593          	li	a1,235
ffffffffc0203d08:	00002517          	auipc	a0,0x2
ffffffffc0203d0c:	29050513          	addi	a0,a0,656 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203d10:	e64fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203d14:	00002697          	auipc	a3,0x2
ffffffffc0203d18:	d4468693          	addi	a3,a3,-700 # ffffffffc0205a58 <default_pmm_manager+0x720>
ffffffffc0203d1c:	00001617          	auipc	a2,0x1
ffffffffc0203d20:	26c60613          	addi	a2,a2,620 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203d24:	10d00593          	li	a1,269
ffffffffc0203d28:	00002517          	auipc	a0,0x2
ffffffffc0203d2c:	27050513          	addi	a0,a0,624 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203d30:	e44fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203d34:	00002697          	auipc	a3,0x2
ffffffffc0203d38:	4c468693          	addi	a3,a3,1220 # ffffffffc02061f8 <default_pmm_manager+0xec0>
ffffffffc0203d3c:	00001617          	auipc	a2,0x1
ffffffffc0203d40:	24c60613          	addi	a2,a2,588 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203d44:	10a00593          	li	a1,266
ffffffffc0203d48:	00002517          	auipc	a0,0x2
ffffffffc0203d4c:	25050513          	addi	a0,a0,592 # ffffffffc0205f98 <default_pmm_manager+0xc60>
    check_mm_struct = mm_create();
ffffffffc0203d50:	0000e797          	auipc	a5,0xe
ffffffffc0203d54:	8007bc23          	sd	zero,-2024(a5) # ffffffffc0211568 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203d58:	e1cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203d5c:	00002697          	auipc	a3,0x2
ffffffffc0203d60:	d0c68693          	addi	a3,a3,-756 # ffffffffc0205a68 <default_pmm_manager+0x730>
ffffffffc0203d64:	00001617          	auipc	a2,0x1
ffffffffc0203d68:	22460613          	addi	a2,a2,548 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203d6c:	11100593          	li	a1,273
ffffffffc0203d70:	00002517          	auipc	a0,0x2
ffffffffc0203d74:	22850513          	addi	a0,a0,552 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203d78:	dfcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203d7c:	00002697          	auipc	a3,0x2
ffffffffc0203d80:	41468693          	addi	a3,a3,1044 # ffffffffc0206190 <default_pmm_manager+0xe58>
ffffffffc0203d84:	00001617          	auipc	a2,0x1
ffffffffc0203d88:	20460613          	addi	a2,a2,516 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203d8c:	11600593          	li	a1,278
ffffffffc0203d90:	00002517          	auipc	a0,0x2
ffffffffc0203d94:	20850513          	addi	a0,a0,520 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203d98:	ddcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203d9c:	00002697          	auipc	a3,0x2
ffffffffc0203da0:	41468693          	addi	a3,a3,1044 # ffffffffc02061b0 <default_pmm_manager+0xe78>
ffffffffc0203da4:	00001617          	auipc	a2,0x1
ffffffffc0203da8:	1e460613          	addi	a2,a2,484 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203dac:	12000593          	li	a1,288
ffffffffc0203db0:	00002517          	auipc	a0,0x2
ffffffffc0203db4:	1e850513          	addi	a0,a0,488 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203db8:	dbcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203dbc:	00001617          	auipc	a2,0x1
ffffffffc0203dc0:	5b460613          	addi	a2,a2,1460 # ffffffffc0205370 <default_pmm_manager+0x38>
ffffffffc0203dc4:	06500593          	li	a1,101
ffffffffc0203dc8:	00001517          	auipc	a0,0x1
ffffffffc0203dcc:	5c850513          	addi	a0,a0,1480 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc0203dd0:	da4fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203dd4:	00002697          	auipc	a3,0x2
ffffffffc0203dd8:	37468693          	addi	a3,a3,884 # ffffffffc0206148 <default_pmm_manager+0xe10>
ffffffffc0203ddc:	00001617          	auipc	a2,0x1
ffffffffc0203de0:	1ac60613          	addi	a2,a2,428 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203de4:	12e00593          	li	a1,302
ffffffffc0203de8:	00002517          	auipc	a0,0x2
ffffffffc0203dec:	1b050513          	addi	a0,a0,432 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203df0:	d84fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203df4:	00002697          	auipc	a3,0x2
ffffffffc0203df8:	35468693          	addi	a3,a3,852 # ffffffffc0206148 <default_pmm_manager+0xe10>
ffffffffc0203dfc:	00001617          	auipc	a2,0x1
ffffffffc0203e00:	18c60613          	addi	a2,a2,396 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203e04:	0bd00593          	li	a1,189
ffffffffc0203e08:	00002517          	auipc	a0,0x2
ffffffffc0203e0c:	19050513          	addi	a0,a0,400 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203e10:	d64fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203e14:	00002697          	auipc	a3,0x2
ffffffffc0203e18:	c1c68693          	addi	a3,a3,-996 # ffffffffc0205a30 <default_pmm_manager+0x6f8>
ffffffffc0203e1c:	00001617          	auipc	a2,0x1
ffffffffc0203e20:	16c60613          	addi	a2,a2,364 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203e24:	0c700593          	li	a1,199
ffffffffc0203e28:	00002517          	auipc	a0,0x2
ffffffffc0203e2c:	17050513          	addi	a0,a0,368 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203e30:	d44fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203e34:	00002697          	auipc	a3,0x2
ffffffffc0203e38:	31468693          	addi	a3,a3,788 # ffffffffc0206148 <default_pmm_manager+0xe10>
ffffffffc0203e3c:	00001617          	auipc	a2,0x1
ffffffffc0203e40:	14c60613          	addi	a2,a2,332 # ffffffffc0204f88 <commands+0x758>
ffffffffc0203e44:	0fb00593          	li	a1,251
ffffffffc0203e48:	00002517          	auipc	a0,0x2
ffffffffc0203e4c:	15050513          	addi	a0,a0,336 # ffffffffc0205f98 <default_pmm_manager+0xc60>
ffffffffc0203e50:	d24fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e54 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203e54:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203e56:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203e58:	f022                	sd	s0,32(sp)
ffffffffc0203e5a:	ec26                	sd	s1,24(sp)
ffffffffc0203e5c:	f406                	sd	ra,40(sp)
ffffffffc0203e5e:	e84a                	sd	s2,16(sp)
ffffffffc0203e60:	8432                	mv	s0,a2
ffffffffc0203e62:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203e64:	8d3ff0ef          	jal	ra,ffffffffc0203736 <find_vma>

    pgfault_num++;
ffffffffc0203e68:	0000d797          	auipc	a5,0xd
ffffffffc0203e6c:	7087a783          	lw	a5,1800(a5) # ffffffffc0211570 <pgfault_num>
ffffffffc0203e70:	2785                	addiw	a5,a5,1
ffffffffc0203e72:	0000d717          	auipc	a4,0xd
ffffffffc0203e76:	6ef72f23          	sw	a5,1790(a4) # ffffffffc0211570 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203e7a:	c159                	beqz	a0,ffffffffc0203f00 <do_pgfault+0xac>
ffffffffc0203e7c:	651c                	ld	a5,8(a0)
ffffffffc0203e7e:	08f46163          	bltu	s0,a5,ffffffffc0203f00 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203e82:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203e84:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203e86:	8b89                	andi	a5,a5,2
ffffffffc0203e88:	ebb1                	bnez	a5,ffffffffc0203edc <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203e8a:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203e8c:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203e8e:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203e90:	85a2                	mv	a1,s0
ffffffffc0203e92:	4605                	li	a2,1
ffffffffc0203e94:	869fd0ef          	jal	ra,ffffffffc02016fc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203e98:	610c                	ld	a1,0(a0)
ffffffffc0203e9a:	c1b9                	beqz	a1,ffffffffc0203ee0 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203e9c:	0000d797          	auipc	a5,0xd
ffffffffc0203ea0:	6bc7a783          	lw	a5,1724(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203ea4:	c7bd                	beqz	a5,ffffffffc0203f12 <do_pgfault+0xbe>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0203ea6:	85a2                	mv	a1,s0
ffffffffc0203ea8:	0030                	addi	a2,sp,8
ffffffffc0203eaa:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203eac:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203eae:	a32ff0ef          	jal	ra,ffffffffc02030e0 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203eb2:	65a2                	ld	a1,8(sp)
ffffffffc0203eb4:	6c88                	ld	a0,24(s1)
ffffffffc0203eb6:	86ca                	mv	a3,s2
ffffffffc0203eb8:	8622                	mv	a2,s0
ffffffffc0203eba:	b2dfd0ef          	jal	ra,ffffffffc02019e6 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203ebe:	6622                	ld	a2,8(sp)
ffffffffc0203ec0:	4685                	li	a3,1
ffffffffc0203ec2:	85a2                	mv	a1,s0
ffffffffc0203ec4:	8526                	mv	a0,s1
ffffffffc0203ec6:	8faff0ef          	jal	ra,ffffffffc0202fc0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203eca:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203ecc:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0203ece:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0203ed0:	70a2                	ld	ra,40(sp)
ffffffffc0203ed2:	7402                	ld	s0,32(sp)
ffffffffc0203ed4:	64e2                	ld	s1,24(sp)
ffffffffc0203ed6:	6942                	ld	s2,16(sp)
ffffffffc0203ed8:	6145                	addi	sp,sp,48
ffffffffc0203eda:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203edc:	4959                	li	s2,22
ffffffffc0203ede:	b775                	j	ffffffffc0203e8a <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203ee0:	6c88                	ld	a0,24(s1)
ffffffffc0203ee2:	864a                	mv	a2,s2
ffffffffc0203ee4:	85a2                	mv	a1,s0
ffffffffc0203ee6:	80bfe0ef          	jal	ra,ffffffffc02026f0 <pgdir_alloc_page>
ffffffffc0203eea:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0203eec:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203eee:	f3ed                	bnez	a5,ffffffffc0203ed0 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203ef0:	00002517          	auipc	a0,0x2
ffffffffc0203ef4:	35050513          	addi	a0,a0,848 # ffffffffc0206240 <default_pmm_manager+0xf08>
ffffffffc0203ef8:	9c2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203efc:	5571                	li	a0,-4
            goto failed;
ffffffffc0203efe:	bfc9                	j	ffffffffc0203ed0 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203f00:	85a2                	mv	a1,s0
ffffffffc0203f02:	00002517          	auipc	a0,0x2
ffffffffc0203f06:	30e50513          	addi	a0,a0,782 # ffffffffc0206210 <default_pmm_manager+0xed8>
ffffffffc0203f0a:	9b0fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203f0e:	5575                	li	a0,-3
        goto failed;
ffffffffc0203f10:	b7c1                	j	ffffffffc0203ed0 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203f12:	00002517          	auipc	a0,0x2
ffffffffc0203f16:	35650513          	addi	a0,a0,854 # ffffffffc0206268 <default_pmm_manager+0xf30>
ffffffffc0203f1a:	9a0fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f1e:	5571                	li	a0,-4
            goto failed;
ffffffffc0203f20:	bf45                	j	ffffffffc0203ed0 <do_pgfault+0x7c>

ffffffffc0203f22 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f22:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f24:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f26:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f28:	d6cfc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203f2c:	cd01                	beqz	a0,ffffffffc0203f44 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f2e:	4505                	li	a0,1
ffffffffc0203f30:	d6afc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203f34:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f36:	810d                	srli	a0,a0,0x3
ffffffffc0203f38:	0000d797          	auipc	a5,0xd
ffffffffc0203f3c:	60a7b823          	sd	a0,1552(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203f40:	0141                	addi	sp,sp,16
ffffffffc0203f42:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203f44:	00002617          	auipc	a2,0x2
ffffffffc0203f48:	34c60613          	addi	a2,a2,844 # ffffffffc0206290 <default_pmm_manager+0xf58>
ffffffffc0203f4c:	45b5                	li	a1,13
ffffffffc0203f4e:	00002517          	auipc	a0,0x2
ffffffffc0203f52:	36250513          	addi	a0,a0,866 # ffffffffc02062b0 <default_pmm_manager+0xf78>
ffffffffc0203f56:	c1efc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f5a <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203f5a:	1141                	addi	sp,sp,-16
ffffffffc0203f5c:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f5e:	00855793          	srli	a5,a0,0x8
ffffffffc0203f62:	c3a5                	beqz	a5,ffffffffc0203fc2 <swapfs_read+0x68>
ffffffffc0203f64:	0000d717          	auipc	a4,0xd
ffffffffc0203f68:	5e473703          	ld	a4,1508(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203f6c:	04e7fb63          	bgeu	a5,a4,ffffffffc0203fc2 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f70:	0000d617          	auipc	a2,0xd
ffffffffc0203f74:	5c063603          	ld	a2,1472(a2) # ffffffffc0211530 <pages>
ffffffffc0203f78:	8d91                	sub	a1,a1,a2
ffffffffc0203f7a:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f7e:	00002597          	auipc	a1,0x2
ffffffffc0203f82:	5b25b583          	ld	a1,1458(a1) # ffffffffc0206530 <error_string+0x38>
ffffffffc0203f86:	02b60633          	mul	a2,a2,a1
ffffffffc0203f8a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f8e:	00002797          	auipc	a5,0x2
ffffffffc0203f92:	5aa7b783          	ld	a5,1450(a5) # ffffffffc0206538 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f96:	0000d717          	auipc	a4,0xd
ffffffffc0203f9a:	59273703          	ld	a4,1426(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f9e:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fa0:	00c61793          	slli	a5,a2,0xc
ffffffffc0203fa4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fa6:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fa8:	02e7f963          	bgeu	a5,a4,ffffffffc0203fda <swapfs_read+0x80>
}
ffffffffc0203fac:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fae:	0000d797          	auipc	a5,0xd
ffffffffc0203fb2:	5927b783          	ld	a5,1426(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203fb6:	46a1                	li	a3,8
ffffffffc0203fb8:	963e                	add	a2,a2,a5
ffffffffc0203fba:	4505                	li	a0,1
}
ffffffffc0203fbc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fbe:	ce2fc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203fc2:	86aa                	mv	a3,a0
ffffffffc0203fc4:	00002617          	auipc	a2,0x2
ffffffffc0203fc8:	30460613          	addi	a2,a2,772 # ffffffffc02062c8 <default_pmm_manager+0xf90>
ffffffffc0203fcc:	45d1                	li	a1,20
ffffffffc0203fce:	00002517          	auipc	a0,0x2
ffffffffc0203fd2:	2e250513          	addi	a0,a0,738 # ffffffffc02062b0 <default_pmm_manager+0xf78>
ffffffffc0203fd6:	b9efc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203fda:	86b2                	mv	a3,a2
ffffffffc0203fdc:	06a00593          	li	a1,106
ffffffffc0203fe0:	00001617          	auipc	a2,0x1
ffffffffc0203fe4:	3e860613          	addi	a2,a2,1000 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc0203fe8:	00001517          	auipc	a0,0x1
ffffffffc0203fec:	3a850513          	addi	a0,a0,936 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc0203ff0:	b84fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ff4 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ff4:	1141                	addi	sp,sp,-16
ffffffffc0203ff6:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ff8:	00855793          	srli	a5,a0,0x8
ffffffffc0203ffc:	c3a5                	beqz	a5,ffffffffc020405c <swapfs_write+0x68>
ffffffffc0203ffe:	0000d717          	auipc	a4,0xd
ffffffffc0204002:	54a73703          	ld	a4,1354(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0204006:	04e7fb63          	bgeu	a5,a4,ffffffffc020405c <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020400a:	0000d617          	auipc	a2,0xd
ffffffffc020400e:	52663603          	ld	a2,1318(a2) # ffffffffc0211530 <pages>
ffffffffc0204012:	8d91                	sub	a1,a1,a2
ffffffffc0204014:	4035d613          	srai	a2,a1,0x3
ffffffffc0204018:	00002597          	auipc	a1,0x2
ffffffffc020401c:	5185b583          	ld	a1,1304(a1) # ffffffffc0206530 <error_string+0x38>
ffffffffc0204020:	02b60633          	mul	a2,a2,a1
ffffffffc0204024:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204028:	00002797          	auipc	a5,0x2
ffffffffc020402c:	5107b783          	ld	a5,1296(a5) # ffffffffc0206538 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204030:	0000d717          	auipc	a4,0xd
ffffffffc0204034:	4f873703          	ld	a4,1272(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0204038:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020403a:	00c61793          	slli	a5,a2,0xc
ffffffffc020403e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204040:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204042:	02e7f963          	bgeu	a5,a4,ffffffffc0204074 <swapfs_write+0x80>
}
ffffffffc0204046:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204048:	0000d797          	auipc	a5,0xd
ffffffffc020404c:	4f87b783          	ld	a5,1272(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0204050:	46a1                	li	a3,8
ffffffffc0204052:	963e                	add	a2,a2,a5
ffffffffc0204054:	4505                	li	a0,1
}
ffffffffc0204056:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204058:	c6cfc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc020405c:	86aa                	mv	a3,a0
ffffffffc020405e:	00002617          	auipc	a2,0x2
ffffffffc0204062:	26a60613          	addi	a2,a2,618 # ffffffffc02062c8 <default_pmm_manager+0xf90>
ffffffffc0204066:	45e5                	li	a1,25
ffffffffc0204068:	00002517          	auipc	a0,0x2
ffffffffc020406c:	24850513          	addi	a0,a0,584 # ffffffffc02062b0 <default_pmm_manager+0xf78>
ffffffffc0204070:	b04fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0204074:	86b2                	mv	a3,a2
ffffffffc0204076:	06a00593          	li	a1,106
ffffffffc020407a:	00001617          	auipc	a2,0x1
ffffffffc020407e:	34e60613          	addi	a2,a2,846 # ffffffffc02053c8 <default_pmm_manager+0x90>
ffffffffc0204082:	00001517          	auipc	a0,0x1
ffffffffc0204086:	30e50513          	addi	a0,a0,782 # ffffffffc0205390 <default_pmm_manager+0x58>
ffffffffc020408a:	aeafc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020408e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020408e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204092:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204094:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204098:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020409a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020409e:	f022                	sd	s0,32(sp)
ffffffffc02040a0:	ec26                	sd	s1,24(sp)
ffffffffc02040a2:	e84a                	sd	s2,16(sp)
ffffffffc02040a4:	f406                	sd	ra,40(sp)
ffffffffc02040a6:	e44e                	sd	s3,8(sp)
ffffffffc02040a8:	84aa                	mv	s1,a0
ffffffffc02040aa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02040ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02040b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02040b2:	03067e63          	bgeu	a2,a6,ffffffffc02040ee <printnum+0x60>
ffffffffc02040b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02040b8:	00805763          	blez	s0,ffffffffc02040c6 <printnum+0x38>
ffffffffc02040bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02040be:	85ca                	mv	a1,s2
ffffffffc02040c0:	854e                	mv	a0,s3
ffffffffc02040c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02040c4:	fc65                	bnez	s0,ffffffffc02040bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040c6:	1a02                	slli	s4,s4,0x20
ffffffffc02040c8:	00002797          	auipc	a5,0x2
ffffffffc02040cc:	22078793          	addi	a5,a5,544 # ffffffffc02062e8 <default_pmm_manager+0xfb0>
ffffffffc02040d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02040d4:	9a3e                	add	s4,s4,a5
}
ffffffffc02040d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02040dc:	70a2                	ld	ra,40(sp)
ffffffffc02040de:	69a2                	ld	s3,8(sp)
ffffffffc02040e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040e2:	85ca                	mv	a1,s2
ffffffffc02040e4:	87a6                	mv	a5,s1
}
ffffffffc02040e6:	6942                	ld	s2,16(sp)
ffffffffc02040e8:	64e2                	ld	s1,24(sp)
ffffffffc02040ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040ec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02040ee:	03065633          	divu	a2,a2,a6
ffffffffc02040f2:	8722                	mv	a4,s0
ffffffffc02040f4:	f9bff0ef          	jal	ra,ffffffffc020408e <printnum>
ffffffffc02040f8:	b7f9                	j	ffffffffc02040c6 <printnum+0x38>

ffffffffc02040fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02040fa:	7119                	addi	sp,sp,-128
ffffffffc02040fc:	f4a6                	sd	s1,104(sp)
ffffffffc02040fe:	f0ca                	sd	s2,96(sp)
ffffffffc0204100:	ecce                	sd	s3,88(sp)
ffffffffc0204102:	e8d2                	sd	s4,80(sp)
ffffffffc0204104:	e4d6                	sd	s5,72(sp)
ffffffffc0204106:	e0da                	sd	s6,64(sp)
ffffffffc0204108:	fc5e                	sd	s7,56(sp)
ffffffffc020410a:	f06a                	sd	s10,32(sp)
ffffffffc020410c:	fc86                	sd	ra,120(sp)
ffffffffc020410e:	f8a2                	sd	s0,112(sp)
ffffffffc0204110:	f862                	sd	s8,48(sp)
ffffffffc0204112:	f466                	sd	s9,40(sp)
ffffffffc0204114:	ec6e                	sd	s11,24(sp)
ffffffffc0204116:	892a                	mv	s2,a0
ffffffffc0204118:	84ae                	mv	s1,a1
ffffffffc020411a:	8d32                	mv	s10,a2
ffffffffc020411c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020411e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204122:	5b7d                	li	s6,-1
ffffffffc0204124:	00002a97          	auipc	s5,0x2
ffffffffc0204128:	1f8a8a93          	addi	s5,s5,504 # ffffffffc020631c <default_pmm_manager+0xfe4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020412c:	00002b97          	auipc	s7,0x2
ffffffffc0204130:	3ccb8b93          	addi	s7,s7,972 # ffffffffc02064f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204134:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204138:	001d0413          	addi	s0,s10,1
ffffffffc020413c:	01350a63          	beq	a0,s3,ffffffffc0204150 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204140:	c121                	beqz	a0,ffffffffc0204180 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204142:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204144:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204146:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204148:	fff44503          	lbu	a0,-1(s0)
ffffffffc020414c:	ff351ae3          	bne	a0,s3,ffffffffc0204140 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204150:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204154:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204158:	4c81                	li	s9,0
ffffffffc020415a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020415c:	5c7d                	li	s8,-1
ffffffffc020415e:	5dfd                	li	s11,-1
ffffffffc0204160:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204164:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204166:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020416a:	0ff5f593          	zext.b	a1,a1
ffffffffc020416e:	00140d13          	addi	s10,s0,1
ffffffffc0204172:	04b56263          	bltu	a0,a1,ffffffffc02041b6 <vprintfmt+0xbc>
ffffffffc0204176:	058a                	slli	a1,a1,0x2
ffffffffc0204178:	95d6                	add	a1,a1,s5
ffffffffc020417a:	4194                	lw	a3,0(a1)
ffffffffc020417c:	96d6                	add	a3,a3,s5
ffffffffc020417e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204180:	70e6                	ld	ra,120(sp)
ffffffffc0204182:	7446                	ld	s0,112(sp)
ffffffffc0204184:	74a6                	ld	s1,104(sp)
ffffffffc0204186:	7906                	ld	s2,96(sp)
ffffffffc0204188:	69e6                	ld	s3,88(sp)
ffffffffc020418a:	6a46                	ld	s4,80(sp)
ffffffffc020418c:	6aa6                	ld	s5,72(sp)
ffffffffc020418e:	6b06                	ld	s6,64(sp)
ffffffffc0204190:	7be2                	ld	s7,56(sp)
ffffffffc0204192:	7c42                	ld	s8,48(sp)
ffffffffc0204194:	7ca2                	ld	s9,40(sp)
ffffffffc0204196:	7d02                	ld	s10,32(sp)
ffffffffc0204198:	6de2                	ld	s11,24(sp)
ffffffffc020419a:	6109                	addi	sp,sp,128
ffffffffc020419c:	8082                	ret
            padc = '0';
ffffffffc020419e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02041a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041a4:	846a                	mv	s0,s10
ffffffffc02041a6:	00140d13          	addi	s10,s0,1
ffffffffc02041aa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02041ae:	0ff5f593          	zext.b	a1,a1
ffffffffc02041b2:	fcb572e3          	bgeu	a0,a1,ffffffffc0204176 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02041b6:	85a6                	mv	a1,s1
ffffffffc02041b8:	02500513          	li	a0,37
ffffffffc02041bc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02041be:	fff44783          	lbu	a5,-1(s0)
ffffffffc02041c2:	8d22                	mv	s10,s0
ffffffffc02041c4:	f73788e3          	beq	a5,s3,ffffffffc0204134 <vprintfmt+0x3a>
ffffffffc02041c8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02041cc:	1d7d                	addi	s10,s10,-1
ffffffffc02041ce:	ff379de3          	bne	a5,s3,ffffffffc02041c8 <vprintfmt+0xce>
ffffffffc02041d2:	b78d                	j	ffffffffc0204134 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02041d4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02041d8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041dc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02041de:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02041e2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02041e6:	02d86463          	bltu	a6,a3,ffffffffc020420e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02041ea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02041ee:	002c169b          	slliw	a3,s8,0x2
ffffffffc02041f2:	0186873b          	addw	a4,a3,s8
ffffffffc02041f6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02041fa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02041fc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204200:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204202:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204206:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020420a:	fed870e3          	bgeu	a6,a3,ffffffffc02041ea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020420e:	f40ddce3          	bgez	s11,ffffffffc0204166 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204212:	8de2                	mv	s11,s8
ffffffffc0204214:	5c7d                	li	s8,-1
ffffffffc0204216:	bf81                	j	ffffffffc0204166 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204218:	fffdc693          	not	a3,s11
ffffffffc020421c:	96fd                	srai	a3,a3,0x3f
ffffffffc020421e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204222:	00144603          	lbu	a2,1(s0)
ffffffffc0204226:	2d81                	sext.w	s11,s11
ffffffffc0204228:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020422a:	bf35                	j	ffffffffc0204166 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020422c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204230:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204234:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204236:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204238:	bfd9                	j	ffffffffc020420e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020423a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020423c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204240:	01174463          	blt	a4,a7,ffffffffc0204248 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204244:	1a088e63          	beqz	a7,ffffffffc0204400 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204248:	000a3603          	ld	a2,0(s4)
ffffffffc020424c:	46c1                	li	a3,16
ffffffffc020424e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204250:	2781                	sext.w	a5,a5
ffffffffc0204252:	876e                	mv	a4,s11
ffffffffc0204254:	85a6                	mv	a1,s1
ffffffffc0204256:	854a                	mv	a0,s2
ffffffffc0204258:	e37ff0ef          	jal	ra,ffffffffc020408e <printnum>
            break;
ffffffffc020425c:	bde1                	j	ffffffffc0204134 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020425e:	000a2503          	lw	a0,0(s4)
ffffffffc0204262:	85a6                	mv	a1,s1
ffffffffc0204264:	0a21                	addi	s4,s4,8
ffffffffc0204266:	9902                	jalr	s2
            break;
ffffffffc0204268:	b5f1                	j	ffffffffc0204134 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020426a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020426c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204270:	01174463          	blt	a4,a7,ffffffffc0204278 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204274:	18088163          	beqz	a7,ffffffffc02043f6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204278:	000a3603          	ld	a2,0(s4)
ffffffffc020427c:	46a9                	li	a3,10
ffffffffc020427e:	8a2e                	mv	s4,a1
ffffffffc0204280:	bfc1                	j	ffffffffc0204250 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204282:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204286:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204288:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020428a:	bdf1                	j	ffffffffc0204166 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020428c:	85a6                	mv	a1,s1
ffffffffc020428e:	02500513          	li	a0,37
ffffffffc0204292:	9902                	jalr	s2
            break;
ffffffffc0204294:	b545                	j	ffffffffc0204134 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204296:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020429a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020429c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020429e:	b5e1                	j	ffffffffc0204166 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02042a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02042a6:	01174463          	blt	a4,a7,ffffffffc02042ae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02042aa:	14088163          	beqz	a7,ffffffffc02043ec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02042ae:	000a3603          	ld	a2,0(s4)
ffffffffc02042b2:	46a1                	li	a3,8
ffffffffc02042b4:	8a2e                	mv	s4,a1
ffffffffc02042b6:	bf69                	j	ffffffffc0204250 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02042b8:	03000513          	li	a0,48
ffffffffc02042bc:	85a6                	mv	a1,s1
ffffffffc02042be:	e03e                	sd	a5,0(sp)
ffffffffc02042c0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02042c2:	85a6                	mv	a1,s1
ffffffffc02042c4:	07800513          	li	a0,120
ffffffffc02042c8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02042ca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02042cc:	6782                	ld	a5,0(sp)
ffffffffc02042ce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02042d0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02042d4:	bfb5                	j	ffffffffc0204250 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02042d6:	000a3403          	ld	s0,0(s4)
ffffffffc02042da:	008a0713          	addi	a4,s4,8
ffffffffc02042de:	e03a                	sd	a4,0(sp)
ffffffffc02042e0:	14040263          	beqz	s0,ffffffffc0204424 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02042e4:	0fb05763          	blez	s11,ffffffffc02043d2 <vprintfmt+0x2d8>
ffffffffc02042e8:	02d00693          	li	a3,45
ffffffffc02042ec:	0cd79163          	bne	a5,a3,ffffffffc02043ae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042f0:	00044783          	lbu	a5,0(s0)
ffffffffc02042f4:	0007851b          	sext.w	a0,a5
ffffffffc02042f8:	cf85                	beqz	a5,ffffffffc0204330 <vprintfmt+0x236>
ffffffffc02042fa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042fe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204302:	000c4563          	bltz	s8,ffffffffc020430c <vprintfmt+0x212>
ffffffffc0204306:	3c7d                	addiw	s8,s8,-1
ffffffffc0204308:	036c0263          	beq	s8,s6,ffffffffc020432c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020430c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020430e:	0e0c8e63          	beqz	s9,ffffffffc020440a <vprintfmt+0x310>
ffffffffc0204312:	3781                	addiw	a5,a5,-32
ffffffffc0204314:	0ef47b63          	bgeu	s0,a5,ffffffffc020440a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204318:	03f00513          	li	a0,63
ffffffffc020431c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020431e:	000a4783          	lbu	a5,0(s4)
ffffffffc0204322:	3dfd                	addiw	s11,s11,-1
ffffffffc0204324:	0a05                	addi	s4,s4,1
ffffffffc0204326:	0007851b          	sext.w	a0,a5
ffffffffc020432a:	ffe1                	bnez	a5,ffffffffc0204302 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020432c:	01b05963          	blez	s11,ffffffffc020433e <vprintfmt+0x244>
ffffffffc0204330:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204332:	85a6                	mv	a1,s1
ffffffffc0204334:	02000513          	li	a0,32
ffffffffc0204338:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020433a:	fe0d9be3          	bnez	s11,ffffffffc0204330 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020433e:	6a02                	ld	s4,0(sp)
ffffffffc0204340:	bbd5                	j	ffffffffc0204134 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204342:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204344:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204348:	01174463          	blt	a4,a7,ffffffffc0204350 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020434c:	08088d63          	beqz	a7,ffffffffc02043e6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204350:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204354:	0a044d63          	bltz	s0,ffffffffc020440e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204358:	8622                	mv	a2,s0
ffffffffc020435a:	8a66                	mv	s4,s9
ffffffffc020435c:	46a9                	li	a3,10
ffffffffc020435e:	bdcd                	j	ffffffffc0204250 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204360:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204364:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204366:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204368:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020436c:	8fb5                	xor	a5,a5,a3
ffffffffc020436e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204372:	02d74163          	blt	a4,a3,ffffffffc0204394 <vprintfmt+0x29a>
ffffffffc0204376:	00369793          	slli	a5,a3,0x3
ffffffffc020437a:	97de                	add	a5,a5,s7
ffffffffc020437c:	639c                	ld	a5,0(a5)
ffffffffc020437e:	cb99                	beqz	a5,ffffffffc0204394 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204380:	86be                	mv	a3,a5
ffffffffc0204382:	00002617          	auipc	a2,0x2
ffffffffc0204386:	f9660613          	addi	a2,a2,-106 # ffffffffc0206318 <default_pmm_manager+0xfe0>
ffffffffc020438a:	85a6                	mv	a1,s1
ffffffffc020438c:	854a                	mv	a0,s2
ffffffffc020438e:	0ce000ef          	jal	ra,ffffffffc020445c <printfmt>
ffffffffc0204392:	b34d                	j	ffffffffc0204134 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204394:	00002617          	auipc	a2,0x2
ffffffffc0204398:	f7460613          	addi	a2,a2,-140 # ffffffffc0206308 <default_pmm_manager+0xfd0>
ffffffffc020439c:	85a6                	mv	a1,s1
ffffffffc020439e:	854a                	mv	a0,s2
ffffffffc02043a0:	0bc000ef          	jal	ra,ffffffffc020445c <printfmt>
ffffffffc02043a4:	bb41                	j	ffffffffc0204134 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02043a6:	00002417          	auipc	s0,0x2
ffffffffc02043aa:	f5a40413          	addi	s0,s0,-166 # ffffffffc0206300 <default_pmm_manager+0xfc8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043ae:	85e2                	mv	a1,s8
ffffffffc02043b0:	8522                	mv	a0,s0
ffffffffc02043b2:	e43e                	sd	a5,8(sp)
ffffffffc02043b4:	196000ef          	jal	ra,ffffffffc020454a <strnlen>
ffffffffc02043b8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02043bc:	01b05b63          	blez	s11,ffffffffc02043d2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02043c0:	67a2                	ld	a5,8(sp)
ffffffffc02043c2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043c6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02043c8:	85a6                	mv	a1,s1
ffffffffc02043ca:	8552                	mv	a0,s4
ffffffffc02043cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043ce:	fe0d9ce3          	bnez	s11,ffffffffc02043c6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043d2:	00044783          	lbu	a5,0(s0)
ffffffffc02043d6:	00140a13          	addi	s4,s0,1
ffffffffc02043da:	0007851b          	sext.w	a0,a5
ffffffffc02043de:	d3a5                	beqz	a5,ffffffffc020433e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043e0:	05e00413          	li	s0,94
ffffffffc02043e4:	bf39                	j	ffffffffc0204302 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02043e6:	000a2403          	lw	s0,0(s4)
ffffffffc02043ea:	b7ad                	j	ffffffffc0204354 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02043ec:	000a6603          	lwu	a2,0(s4)
ffffffffc02043f0:	46a1                	li	a3,8
ffffffffc02043f2:	8a2e                	mv	s4,a1
ffffffffc02043f4:	bdb1                	j	ffffffffc0204250 <vprintfmt+0x156>
ffffffffc02043f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02043fa:	46a9                	li	a3,10
ffffffffc02043fc:	8a2e                	mv	s4,a1
ffffffffc02043fe:	bd89                	j	ffffffffc0204250 <vprintfmt+0x156>
ffffffffc0204400:	000a6603          	lwu	a2,0(s4)
ffffffffc0204404:	46c1                	li	a3,16
ffffffffc0204406:	8a2e                	mv	s4,a1
ffffffffc0204408:	b5a1                	j	ffffffffc0204250 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020440a:	9902                	jalr	s2
ffffffffc020440c:	bf09                	j	ffffffffc020431e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020440e:	85a6                	mv	a1,s1
ffffffffc0204410:	02d00513          	li	a0,45
ffffffffc0204414:	e03e                	sd	a5,0(sp)
ffffffffc0204416:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204418:	6782                	ld	a5,0(sp)
ffffffffc020441a:	8a66                	mv	s4,s9
ffffffffc020441c:	40800633          	neg	a2,s0
ffffffffc0204420:	46a9                	li	a3,10
ffffffffc0204422:	b53d                	j	ffffffffc0204250 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204424:	03b05163          	blez	s11,ffffffffc0204446 <vprintfmt+0x34c>
ffffffffc0204428:	02d00693          	li	a3,45
ffffffffc020442c:	f6d79de3          	bne	a5,a3,ffffffffc02043a6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204430:	00002417          	auipc	s0,0x2
ffffffffc0204434:	ed040413          	addi	s0,s0,-304 # ffffffffc0206300 <default_pmm_manager+0xfc8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204438:	02800793          	li	a5,40
ffffffffc020443c:	02800513          	li	a0,40
ffffffffc0204440:	00140a13          	addi	s4,s0,1
ffffffffc0204444:	bd6d                	j	ffffffffc02042fe <vprintfmt+0x204>
ffffffffc0204446:	00002a17          	auipc	s4,0x2
ffffffffc020444a:	ebba0a13          	addi	s4,s4,-325 # ffffffffc0206301 <default_pmm_manager+0xfc9>
ffffffffc020444e:	02800513          	li	a0,40
ffffffffc0204452:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204456:	05e00413          	li	s0,94
ffffffffc020445a:	b565                	j	ffffffffc0204302 <vprintfmt+0x208>

ffffffffc020445c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020445c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020445e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204462:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204464:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204466:	ec06                	sd	ra,24(sp)
ffffffffc0204468:	f83a                	sd	a4,48(sp)
ffffffffc020446a:	fc3e                	sd	a5,56(sp)
ffffffffc020446c:	e0c2                	sd	a6,64(sp)
ffffffffc020446e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204470:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204472:	c89ff0ef          	jal	ra,ffffffffc02040fa <vprintfmt>
}
ffffffffc0204476:	60e2                	ld	ra,24(sp)
ffffffffc0204478:	6161                	addi	sp,sp,80
ffffffffc020447a:	8082                	ret

ffffffffc020447c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020447c:	715d                	addi	sp,sp,-80
ffffffffc020447e:	e486                	sd	ra,72(sp)
ffffffffc0204480:	e0a6                	sd	s1,64(sp)
ffffffffc0204482:	fc4a                	sd	s2,56(sp)
ffffffffc0204484:	f84e                	sd	s3,48(sp)
ffffffffc0204486:	f452                	sd	s4,40(sp)
ffffffffc0204488:	f056                	sd	s5,32(sp)
ffffffffc020448a:	ec5a                	sd	s6,24(sp)
ffffffffc020448c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020448e:	c901                	beqz	a0,ffffffffc020449e <readline+0x22>
ffffffffc0204490:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204492:	00002517          	auipc	a0,0x2
ffffffffc0204496:	e8650513          	addi	a0,a0,-378 # ffffffffc0206318 <default_pmm_manager+0xfe0>
ffffffffc020449a:	c21fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc020449e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044a0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02044a2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02044a4:	4aa9                	li	s5,10
ffffffffc02044a6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02044a8:	0000db97          	auipc	s7,0xd
ffffffffc02044ac:	c50b8b93          	addi	s7,s7,-944 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044b0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02044b4:	c3ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044b8:	00054a63          	bltz	a0,ffffffffc02044cc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044bc:	00a95a63          	bge	s2,a0,ffffffffc02044d0 <readline+0x54>
ffffffffc02044c0:	029a5263          	bge	s4,s1,ffffffffc02044e4 <readline+0x68>
        c = getchar();
ffffffffc02044c4:	c2ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044c8:	fe055ae3          	bgez	a0,ffffffffc02044bc <readline+0x40>
            return NULL;
ffffffffc02044cc:	4501                	li	a0,0
ffffffffc02044ce:	a091                	j	ffffffffc0204512 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02044d0:	03351463          	bne	a0,s3,ffffffffc02044f8 <readline+0x7c>
ffffffffc02044d4:	e8a9                	bnez	s1,ffffffffc0204526 <readline+0xaa>
        c = getchar();
ffffffffc02044d6:	c1dfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044da:	fe0549e3          	bltz	a0,ffffffffc02044cc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044de:	fea959e3          	bge	s2,a0,ffffffffc02044d0 <readline+0x54>
ffffffffc02044e2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02044e4:	e42a                	sd	a0,8(sp)
ffffffffc02044e6:	c0bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02044ea:	6522                	ld	a0,8(sp)
ffffffffc02044ec:	009b87b3          	add	a5,s7,s1
ffffffffc02044f0:	2485                	addiw	s1,s1,1
ffffffffc02044f2:	00a78023          	sb	a0,0(a5)
ffffffffc02044f6:	bf7d                	j	ffffffffc02044b4 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02044f8:	01550463          	beq	a0,s5,ffffffffc0204500 <readline+0x84>
ffffffffc02044fc:	fb651ce3          	bne	a0,s6,ffffffffc02044b4 <readline+0x38>
            cputchar(c);
ffffffffc0204500:	bf1fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204504:	0000d517          	auipc	a0,0xd
ffffffffc0204508:	bf450513          	addi	a0,a0,-1036 # ffffffffc02110f8 <buf>
ffffffffc020450c:	94aa                	add	s1,s1,a0
ffffffffc020450e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204512:	60a6                	ld	ra,72(sp)
ffffffffc0204514:	6486                	ld	s1,64(sp)
ffffffffc0204516:	7962                	ld	s2,56(sp)
ffffffffc0204518:	79c2                	ld	s3,48(sp)
ffffffffc020451a:	7a22                	ld	s4,40(sp)
ffffffffc020451c:	7a82                	ld	s5,32(sp)
ffffffffc020451e:	6b62                	ld	s6,24(sp)
ffffffffc0204520:	6bc2                	ld	s7,16(sp)
ffffffffc0204522:	6161                	addi	sp,sp,80
ffffffffc0204524:	8082                	ret
            cputchar(c);
ffffffffc0204526:	4521                	li	a0,8
ffffffffc0204528:	bc9fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc020452c:	34fd                	addiw	s1,s1,-1
ffffffffc020452e:	b759                	j	ffffffffc02044b4 <readline+0x38>

ffffffffc0204530 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204530:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204534:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204536:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204538:	cb81                	beqz	a5,ffffffffc0204548 <strlen+0x18>
        cnt ++;
ffffffffc020453a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020453c:	00a707b3          	add	a5,a4,a0
ffffffffc0204540:	0007c783          	lbu	a5,0(a5)
ffffffffc0204544:	fbfd                	bnez	a5,ffffffffc020453a <strlen+0xa>
ffffffffc0204546:	8082                	ret
    }
    return cnt;
}
ffffffffc0204548:	8082                	ret

ffffffffc020454a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020454a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020454c:	e589                	bnez	a1,ffffffffc0204556 <strnlen+0xc>
ffffffffc020454e:	a811                	j	ffffffffc0204562 <strnlen+0x18>
        cnt ++;
ffffffffc0204550:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204552:	00f58863          	beq	a1,a5,ffffffffc0204562 <strnlen+0x18>
ffffffffc0204556:	00f50733          	add	a4,a0,a5
ffffffffc020455a:	00074703          	lbu	a4,0(a4)
ffffffffc020455e:	fb6d                	bnez	a4,ffffffffc0204550 <strnlen+0x6>
ffffffffc0204560:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204562:	852e                	mv	a0,a1
ffffffffc0204564:	8082                	ret

ffffffffc0204566 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204566:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204568:	0005c703          	lbu	a4,0(a1)
ffffffffc020456c:	0785                	addi	a5,a5,1
ffffffffc020456e:	0585                	addi	a1,a1,1
ffffffffc0204570:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204574:	fb75                	bnez	a4,ffffffffc0204568 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204576:	8082                	ret

ffffffffc0204578 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204578:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020457c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204580:	cb89                	beqz	a5,ffffffffc0204592 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204582:	0505                	addi	a0,a0,1
ffffffffc0204584:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204586:	fee789e3          	beq	a5,a4,ffffffffc0204578 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020458a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020458e:	9d19                	subw	a0,a0,a4
ffffffffc0204590:	8082                	ret
ffffffffc0204592:	4501                	li	a0,0
ffffffffc0204594:	bfed                	j	ffffffffc020458e <strcmp+0x16>

ffffffffc0204596 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204596:	00054783          	lbu	a5,0(a0)
ffffffffc020459a:	c799                	beqz	a5,ffffffffc02045a8 <strchr+0x12>
        if (*s == c) {
ffffffffc020459c:	00f58763          	beq	a1,a5,ffffffffc02045aa <strchr+0x14>
    while (*s != '\0') {
ffffffffc02045a0:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02045a4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02045a6:	fbfd                	bnez	a5,ffffffffc020459c <strchr+0x6>
    }
    return NULL;
ffffffffc02045a8:	4501                	li	a0,0
}
ffffffffc02045aa:	8082                	ret

ffffffffc02045ac <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02045ac:	ca01                	beqz	a2,ffffffffc02045bc <memset+0x10>
ffffffffc02045ae:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02045b0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02045b2:	0785                	addi	a5,a5,1
ffffffffc02045b4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02045b8:	fec79de3          	bne	a5,a2,ffffffffc02045b2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02045bc:	8082                	ret

ffffffffc02045be <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02045be:	ca19                	beqz	a2,ffffffffc02045d4 <memcpy+0x16>
ffffffffc02045c0:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02045c2:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02045c4:	0005c703          	lbu	a4,0(a1)
ffffffffc02045c8:	0585                	addi	a1,a1,1
ffffffffc02045ca:	0785                	addi	a5,a5,1
ffffffffc02045cc:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02045d0:	fec59ae3          	bne	a1,a2,ffffffffc02045c4 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02045d4:	8082                	ret
