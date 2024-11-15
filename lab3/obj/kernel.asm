
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
ffffffffc020003e:	53260613          	addi	a2,a2,1330 # ffffffffc021156c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	52a040ef          	jal	ra,ffffffffc0204574 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	55258593          	addi	a1,a1,1362 # ffffffffc02045a0 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	56a50513          	addi	a0,a0,1386 # ffffffffc02045c0 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	251010ef          	jal	ra,ffffffffc0201ab6 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	7d6030ef          	jal	ra,ffffffffc0203844 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	0a5020ef          	jal	ra,ffffffffc020291a <swap_init>

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
ffffffffc02000ae:	014040ef          	jal	ra,ffffffffc02040c2 <vprintfmt>
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
ffffffffc02000e4:	7df030ef          	jal	ra,ffffffffc02040c2 <vprintfmt>
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
ffffffffc0200108:	4c450513          	addi	a0,a0,1220 # ffffffffc02045c8 <etext+0x2a>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	4ce50513          	addi	a0,a0,1230 # ffffffffc02045e8 <etext+0x4a>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	47858593          	addi	a1,a1,1144 # ffffffffc020459e <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	4da50513          	addi	a0,a0,1242 # ffffffffc0204608 <etext+0x6a>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	4e650513          	addi	a0,a0,1254 # ffffffffc0204628 <etext+0x8a>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	41e58593          	addi	a1,a1,1054 # ffffffffc021156c <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	4f250513          	addi	a0,a0,1266 # ffffffffc0204648 <etext+0xaa>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	80958593          	addi	a1,a1,-2039 # ffffffffc021196b <end+0x3ff>
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
ffffffffc0200188:	4e450513          	addi	a0,a0,1252 # ffffffffc0204668 <etext+0xca>
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
ffffffffc0200196:	50660613          	addi	a2,a2,1286 # ffffffffc0204698 <etext+0xfa>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	51250513          	addi	a0,a0,1298 # ffffffffc02046b0 <etext+0x112>
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
ffffffffc02001b2:	51a60613          	addi	a2,a2,1306 # ffffffffc02046c8 <etext+0x12a>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	53258593          	addi	a1,a1,1330 # ffffffffc02046e8 <etext+0x14a>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	53250513          	addi	a0,a0,1330 # ffffffffc02046f0 <etext+0x152>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	53460613          	addi	a2,a2,1332 # ffffffffc0204700 <etext+0x162>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	55458593          	addi	a1,a1,1364 # ffffffffc0204728 <etext+0x18a>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	51450513          	addi	a0,a0,1300 # ffffffffc02046f0 <etext+0x152>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	55060613          	addi	a2,a2,1360 # ffffffffc0204738 <etext+0x19a>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	56858593          	addi	a1,a1,1384 # ffffffffc0204758 <etext+0x1ba>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	4f850513          	addi	a0,a0,1272 # ffffffffc02046f0 <etext+0x152>
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
ffffffffc0200236:	53650513          	addi	a0,a0,1334 # ffffffffc0204768 <etext+0x1ca>
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
ffffffffc0200258:	53c50513          	addi	a0,a0,1340 # ffffffffc0204790 <etext+0x1f2>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	58ec0c13          	addi	s8,s8,1422 # ffffffffc02047f8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	9be90913          	addi	s2,s2,-1602 # ffffffffc0205c30 <default_pmm_manager+0x950>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	53e48493          	addi	s1,s1,1342 # ffffffffc02047b8 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	53cb0b13          	addi	s6,s6,1340 # ffffffffc02047c0 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	45ca0a13          	addi	s4,s4,1116 # ffffffffc02046e8 <etext+0x14a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	1ac040ef          	jal	ra,ffffffffc0204444 <readline>
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
ffffffffc02002b2:	54ad0d13          	addi	s10,s10,1354 # ffffffffc02047f8 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	284040ef          	jal	ra,ffffffffc0204540 <strcmp>
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
ffffffffc02002d0:	270040ef          	jal	ra,ffffffffc0204540 <strcmp>
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
ffffffffc020030e:	250040ef          	jal	ra,ffffffffc020455e <strchr>
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
ffffffffc020034c:	212040ef          	jal	ra,ffffffffc020455e <strchr>
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
ffffffffc020036a:	47a50513          	addi	a0,a0,1146 # ffffffffc02047e0 <etext+0x242>
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
ffffffffc02003a6:	49e50513          	addi	a0,a0,1182 # ffffffffc0204840 <commands+0x48>
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
ffffffffc02003bc:	3a050513          	addi	a0,a0,928 # ffffffffc0205758 <default_pmm_manager+0x478>
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
ffffffffc02003fa:	46a50513          	addi	a0,a0,1130 # ffffffffc0204860 <commands+0x68>
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
ffffffffc02004b8:	0ce040ef          	jal	ra,ffffffffc0204586 <memcpy>
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
ffffffffc02004dc:	0aa040ef          	jal	ra,ffffffffc0204586 <memcpy>
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
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
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
ffffffffc0200528:	35c50513          	addi	a0,a0,860 # ffffffffc0204880 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03053503          	ld	a0,48(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
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
ffffffffc0200548:	0d50306f          	j	ffffffffc0203e1c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	35460613          	addi	a2,a2,852 # ffffffffc02048a0 <commands+0xa8>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	36050513          	addi	a0,a0,864 # ffffffffc02048b8 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
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
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	34650513          	addi	a0,a0,838 # ffffffffc02048d0 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	34e50513          	addi	a0,a0,846 # ffffffffc02048e8 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	35850513          	addi	a0,a0,856 # ffffffffc0204900 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	36250513          	addi	a0,a0,866 # ffffffffc0204918 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	36c50513          	addi	a0,a0,876 # ffffffffc0204930 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	37650513          	addi	a0,a0,886 # ffffffffc0204948 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	38050513          	addi	a0,a0,896 # ffffffffc0204960 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	38a50513          	addi	a0,a0,906 # ffffffffc0204978 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	39450513          	addi	a0,a0,916 # ffffffffc0204990 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	39e50513          	addi	a0,a0,926 # ffffffffc02049a8 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	3a850513          	addi	a0,a0,936 # ffffffffc02049c0 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	3b250513          	addi	a0,a0,946 # ffffffffc02049d8 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	3bc50513          	addi	a0,a0,956 # ffffffffc02049f0 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	3c650513          	addi	a0,a0,966 # ffffffffc0204a08 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	3d050513          	addi	a0,a0,976 # ffffffffc0204a20 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	3da50513          	addi	a0,a0,986 # ffffffffc0204a38 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	3e450513          	addi	a0,a0,996 # ffffffffc0204a50 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204a68 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	3f850513          	addi	a0,a0,1016 # ffffffffc0204a80 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	40250513          	addi	a0,a0,1026 # ffffffffc0204a98 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	40c50513          	addi	a0,a0,1036 # ffffffffc0204ab0 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	41650513          	addi	a0,a0,1046 # ffffffffc0204ac8 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	42050513          	addi	a0,a0,1056 # ffffffffc0204ae0 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	42a50513          	addi	a0,a0,1066 # ffffffffc0204af8 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	43450513          	addi	a0,a0,1076 # ffffffffc0204b10 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	43e50513          	addi	a0,a0,1086 # ffffffffc0204b28 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	44850513          	addi	a0,a0,1096 # ffffffffc0204b40 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	45250513          	addi	a0,a0,1106 # ffffffffc0204b58 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	45c50513          	addi	a0,a0,1116 # ffffffffc0204b70 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	46650513          	addi	a0,a0,1126 # ffffffffc0204b88 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	47050513          	addi	a0,a0,1136 # ffffffffc0204ba0 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	47650513          	addi	a0,a0,1142 # ffffffffc0204bb8 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	47a50513          	addi	a0,a0,1146 # ffffffffc0204bd0 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	47a50513          	addi	a0,a0,1146 # ffffffffc0204be8 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	48250513          	addi	a0,a0,1154 # ffffffffc0204c00 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	48a50513          	addi	a0,a0,1162 # ffffffffc0204c18 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	48e50513          	addi	a0,a0,1166 # ffffffffc0204c30 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	53a70713          	addi	a4,a4,1338 # ffffffffc0204cf8 <commands+0x500>
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
ffffffffc02007d4:	4d850513          	addi	a0,a0,1240 # ffffffffc0204ca8 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204c88 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	46050513          	addi	a0,a0,1120 # ffffffffc0204c48 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	47450513          	addi	a0,a0,1140 # ffffffffc0204c68 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c05ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
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
ffffffffc020082a:	4b250513          	addi	a0,a0,1202 # ffffffffc0204cd8 <commands+0x4e0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	48e50513          	addi	a0,a0,1166 # ffffffffc0204cc8 <commands+0x4d0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	68470713          	addi	a4,a4,1668 # ffffffffc0204ee0 <commands+0x6e8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	65a50513          	addi	a0,a0,1626 # ffffffffc0204ec8 <commands+0x6d0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	49850513          	addi	a0,a0,1176 # ffffffffc0204d28 <commands+0x530>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	4a450513          	addi	a0,a0,1188 # ffffffffc0204d48 <commands+0x550>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	4ba50513          	addi	a0,a0,1210 # ffffffffc0204d68 <commands+0x570>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	4c850513          	addi	a0,a0,1224 # ffffffffc0204d80 <commands+0x588>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0204d90 <commands+0x598>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	4e450513          	addi	a0,a0,1252 # ffffffffc0204db0 <commands+0x5b8>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	4de60613          	addi	a2,a2,1246 # ffffffffc0204dc8 <commands+0x5d0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	fc250513          	addi	a0,a0,-62 # ffffffffc02048b8 <commands+0xc0>
ffffffffc02008fe:	a77ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	4e650513          	addi	a0,a0,1254 # ffffffffc0204de8 <commands+0x5f0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	4f450513          	addi	a0,a0,1268 # ffffffffc0204e00 <commands+0x608>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	49e60613          	addi	a2,a2,1182 # ffffffffc0204dc8 <commands+0x5d0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	f8250513          	addi	a0,a0,-126 # ffffffffc02048b8 <commands+0xc0>
ffffffffc020093e:	a37ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	4d650513          	addi	a0,a0,1238 # ffffffffc0204e18 <commands+0x620>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204e38 <commands+0x640>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	50250513          	addi	a0,a0,1282 # ffffffffc0204e58 <commands+0x660>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	51850513          	addi	a0,a0,1304 # ffffffffc0204e78 <commands+0x680>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	52e50513          	addi	a0,a0,1326 # ffffffffc0204e98 <commands+0x6a0>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	53c50513          	addi	a0,a0,1340 # ffffffffc0204eb0 <commands+0x6b8>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	43460613          	addi	a2,a2,1076 # ffffffffc0204dc8 <commands+0x5d0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	f1850513          	addi	a0,a0,-232 # ffffffffc02048b8 <commands+0xc0>
ffffffffc02009a8:	9cdff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	40860613          	addi	a2,a2,1032 # ffffffffc0204dc8 <commands+0x5d0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	eec50513          	addi	a0,a0,-276 # ffffffffc02048b8 <commands+0xc0>
ffffffffc02009d4:	9a1ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab0:	00010797          	auipc	a5,0x10
ffffffffc0200ab4:	59078793          	addi	a5,a5,1424 # ffffffffc0211040 <free_area>
ffffffffc0200ab8:	e79c                	sd	a5,8(a5)
ffffffffc0200aba:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200abc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ac0:	8082                	ret

ffffffffc0200ac2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ac2:	00010517          	auipc	a0,0x10
ffffffffc0200ac6:	58e56503          	lwu	a0,1422(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aca:	8082                	ret

ffffffffc0200acc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200acc:	715d                	addi	sp,sp,-80
ffffffffc0200ace:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ad0:	00010417          	auipc	s0,0x10
ffffffffc0200ad4:	57040413          	addi	s0,s0,1392 # ffffffffc0211040 <free_area>
ffffffffc0200ad8:	641c                	ld	a5,8(s0)
ffffffffc0200ada:	e486                	sd	ra,72(sp)
ffffffffc0200adc:	fc26                	sd	s1,56(sp)
ffffffffc0200ade:	f84a                	sd	s2,48(sp)
ffffffffc0200ae0:	f44e                	sd	s3,40(sp)
ffffffffc0200ae2:	f052                	sd	s4,32(sp)
ffffffffc0200ae4:	ec56                	sd	s5,24(sp)
ffffffffc0200ae6:	e85a                	sd	s6,16(sp)
ffffffffc0200ae8:	e45e                	sd	s7,8(sp)
ffffffffc0200aea:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aec:	2c878763          	beq	a5,s0,ffffffffc0200dba <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200af0:	4481                	li	s1,0
ffffffffc0200af2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200af4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200af8:	8b09                	andi	a4,a4,2
ffffffffc0200afa:	2c070463          	beqz	a4,ffffffffc0200dc2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200afe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b02:	679c                	ld	a5,8(a5)
ffffffffc0200b04:	2905                	addiw	s2,s2,1
ffffffffc0200b06:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b08:	fe8796e3          	bne	a5,s0,ffffffffc0200af4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b0c:	89a6                	mv	s3,s1
ffffffffc0200b0e:	385000ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0200b12:	71351863          	bne	a0,s3,ffffffffc0201222 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b16:	4505                	li	a0,1
ffffffffc0200b18:	2a9000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200b1c:	8a2a                	mv	s4,a0
ffffffffc0200b1e:	44050263          	beqz	a0,ffffffffc0200f62 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b22:	4505                	li	a0,1
ffffffffc0200b24:	29d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200b28:	89aa                	mv	s3,a0
ffffffffc0200b2a:	70050c63          	beqz	a0,ffffffffc0201242 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b2e:	4505                	li	a0,1
ffffffffc0200b30:	291000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200b34:	8aaa                	mv	s5,a0
ffffffffc0200b36:	4a050663          	beqz	a0,ffffffffc0200fe2 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b3a:	2b3a0463          	beq	s4,s3,ffffffffc0200de2 <default_check+0x316>
ffffffffc0200b3e:	2aaa0263          	beq	s4,a0,ffffffffc0200de2 <default_check+0x316>
ffffffffc0200b42:	2aa98063          	beq	s3,a0,ffffffffc0200de2 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b46:	000a2783          	lw	a5,0(s4)
ffffffffc0200b4a:	2a079c63          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
ffffffffc0200b4e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b52:	2a079863          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
ffffffffc0200b56:	411c                	lw	a5,0(a0)
ffffffffc0200b58:	2a079563          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b5c:	00011797          	auipc	a5,0x11
ffffffffc0200b60:	9cc7b783          	ld	a5,-1588(a5) # ffffffffc0211528 <pages>
ffffffffc0200b64:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b68:	870d                	srai	a4,a4,0x3
ffffffffc0200b6a:	00006597          	auipc	a1,0x6
ffffffffc0200b6e:	96e5b583          	ld	a1,-1682(a1) # ffffffffc02064d8 <error_string+0x38>
ffffffffc0200b72:	02b70733          	mul	a4,a4,a1
ffffffffc0200b76:	00006617          	auipc	a2,0x6
ffffffffc0200b7a:	96a63603          	ld	a2,-1686(a2) # ffffffffc02064e0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b7e:	00011697          	auipc	a3,0x11
ffffffffc0200b82:	9a26b683          	ld	a3,-1630(a3) # ffffffffc0211520 <npage>
ffffffffc0200b86:	06b2                	slli	a3,a3,0xc
ffffffffc0200b88:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b8a:	0732                	slli	a4,a4,0xc
ffffffffc0200b8c:	28d77b63          	bgeu	a4,a3,ffffffffc0200e22 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b90:	40f98733          	sub	a4,s3,a5
ffffffffc0200b94:	870d                	srai	a4,a4,0x3
ffffffffc0200b96:	02b70733          	mul	a4,a4,a1
ffffffffc0200b9a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b9e:	4cd77263          	bgeu	a4,a3,ffffffffc0201062 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ba6:	878d                	srai	a5,a5,0x3
ffffffffc0200ba8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bac:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bae:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bb0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ec2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200bb4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bb6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bba:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bbe:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bc2:	e400                	sd	s0,8(s0)
ffffffffc0200bc4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bc6:	00010797          	auipc	a5,0x10
ffffffffc0200bca:	4807a523          	sw	zero,1162(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bce:	1f3000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200bd2:	2c051863          	bnez	a0,ffffffffc0200ea2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200bd6:	4585                	li	a1,1
ffffffffc0200bd8:	8552                	mv	a0,s4
ffffffffc0200bda:	279000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p1);
ffffffffc0200bde:	4585                	li	a1,1
ffffffffc0200be0:	854e                	mv	a0,s3
ffffffffc0200be2:	271000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200be6:	4585                	li	a1,1
ffffffffc0200be8:	8556                	mv	a0,s5
ffffffffc0200bea:	269000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bee:	4818                	lw	a4,16(s0)
ffffffffc0200bf0:	478d                	li	a5,3
ffffffffc0200bf2:	28f71863          	bne	a4,a5,ffffffffc0200e82 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bf6:	4505                	li	a0,1
ffffffffc0200bf8:	1c9000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200bfc:	89aa                	mv	s3,a0
ffffffffc0200bfe:	26050263          	beqz	a0,ffffffffc0200e62 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c02:	4505                	li	a0,1
ffffffffc0200c04:	1bd000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c08:	8aaa                	mv	s5,a0
ffffffffc0200c0a:	3a050c63          	beqz	a0,ffffffffc0200fc2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c0e:	4505                	li	a0,1
ffffffffc0200c10:	1b1000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c14:	8a2a                	mv	s4,a0
ffffffffc0200c16:	38050663          	beqz	a0,ffffffffc0200fa2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c1a:	4505                	li	a0,1
ffffffffc0200c1c:	1a5000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c20:	36051163          	bnez	a0,ffffffffc0200f82 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c24:	4585                	li	a1,1
ffffffffc0200c26:	854e                	mv	a0,s3
ffffffffc0200c28:	22b000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c2c:	641c                	ld	a5,8(s0)
ffffffffc0200c2e:	20878a63          	beq	a5,s0,ffffffffc0200e42 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	18d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c38:	30a99563          	bne	s3,a0,ffffffffc0200f42 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	183000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c42:	2e051063          	bnez	a0,ffffffffc0200f22 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c46:	481c                	lw	a5,16(s0)
ffffffffc0200c48:	2a079d63          	bnez	a5,ffffffffc0200f02 <default_check+0x436>
    free_page(p);
ffffffffc0200c4c:	854e                	mv	a0,s3
ffffffffc0200c4e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c50:	01843023          	sd	s8,0(s0)
ffffffffc0200c54:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c58:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c5c:	1f7000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p1);
ffffffffc0200c60:	4585                	li	a1,1
ffffffffc0200c62:	8556                	mv	a0,s5
ffffffffc0200c64:	1ef000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200c68:	4585                	li	a1,1
ffffffffc0200c6a:	8552                	mv	a0,s4
ffffffffc0200c6c:	1e7000ef          	jal	ra,ffffffffc0201652 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c70:	4515                	li	a0,5
ffffffffc0200c72:	14f000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c76:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c78:	26050563          	beqz	a0,ffffffffc0200ee2 <default_check+0x416>
ffffffffc0200c7c:	651c                	ld	a5,8(a0)
ffffffffc0200c7e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c80:	8b85                	andi	a5,a5,1
ffffffffc0200c82:	54079063          	bnez	a5,ffffffffc02011c2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c86:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c88:	00043b03          	ld	s6,0(s0)
ffffffffc0200c8c:	00843a83          	ld	s5,8(s0)
ffffffffc0200c90:	e000                	sd	s0,0(s0)
ffffffffc0200c92:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c94:	12d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c98:	50051563          	bnez	a0,ffffffffc02011a2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c9c:	09098a13          	addi	s4,s3,144
ffffffffc0200ca0:	8552                	mv	a0,s4
ffffffffc0200ca2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ca4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200ca8:	00010797          	auipc	a5,0x10
ffffffffc0200cac:	3a07a423          	sw	zero,936(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cb0:	1a3000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cb4:	4511                	li	a0,4
ffffffffc0200cb6:	10b000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200cba:	4c051463          	bnez	a0,ffffffffc0201182 <default_check+0x6b6>
ffffffffc0200cbe:	0989b783          	ld	a5,152(s3)
ffffffffc0200cc2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cc4:	8b85                	andi	a5,a5,1
ffffffffc0200cc6:	48078e63          	beqz	a5,ffffffffc0201162 <default_check+0x696>
ffffffffc0200cca:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cce:	478d                	li	a5,3
ffffffffc0200cd0:	48f71963          	bne	a4,a5,ffffffffc0201162 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cd4:	450d                	li	a0,3
ffffffffc0200cd6:	0eb000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200cda:	8c2a                	mv	s8,a0
ffffffffc0200cdc:	46050363          	beqz	a0,ffffffffc0201142 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200ce0:	4505                	li	a0,1
ffffffffc0200ce2:	0df000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200ce6:	42051e63          	bnez	a0,ffffffffc0201122 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200cea:	418a1c63          	bne	s4,s8,ffffffffc0201102 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200cee:	4585                	li	a1,1
ffffffffc0200cf0:	854e                	mv	a0,s3
ffffffffc0200cf2:	161000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_pages(p1, 3);
ffffffffc0200cf6:	458d                	li	a1,3
ffffffffc0200cf8:	8552                	mv	a0,s4
ffffffffc0200cfa:	159000ef          	jal	ra,ffffffffc0201652 <free_pages>
ffffffffc0200cfe:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d02:	04898c13          	addi	s8,s3,72
ffffffffc0200d06:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d08:	8b85                	andi	a5,a5,1
ffffffffc0200d0a:	3c078c63          	beqz	a5,ffffffffc02010e2 <default_check+0x616>
ffffffffc0200d0e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d12:	4785                	li	a5,1
ffffffffc0200d14:	3cf71763          	bne	a4,a5,ffffffffc02010e2 <default_check+0x616>
ffffffffc0200d18:	008a3783          	ld	a5,8(s4)
ffffffffc0200d1c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d1e:	8b85                	andi	a5,a5,1
ffffffffc0200d20:	3a078163          	beqz	a5,ffffffffc02010c2 <default_check+0x5f6>
ffffffffc0200d24:	018a2703          	lw	a4,24(s4)
ffffffffc0200d28:	478d                	li	a5,3
ffffffffc0200d2a:	38f71c63          	bne	a4,a5,ffffffffc02010c2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d2e:	4505                	li	a0,1
ffffffffc0200d30:	091000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d34:	36a99763          	bne	s3,a0,ffffffffc02010a2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d38:	4585                	li	a1,1
ffffffffc0200d3a:	119000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d3e:	4509                	li	a0,2
ffffffffc0200d40:	081000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d44:	32aa1f63          	bne	s4,a0,ffffffffc0201082 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d48:	4589                	li	a1,2
ffffffffc0200d4a:	109000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	8562                	mv	a0,s8
ffffffffc0200d52:	101000ef          	jal	ra,ffffffffc0201652 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d56:	4515                	li	a0,5
ffffffffc0200d58:	069000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d5c:	89aa                	mv	s3,a0
ffffffffc0200d5e:	48050263          	beqz	a0,ffffffffc02011e2 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d62:	4505                	li	a0,1
ffffffffc0200d64:	05d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d68:	2c051d63          	bnez	a0,ffffffffc0201042 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d6c:	481c                	lw	a5,16(s0)
ffffffffc0200d6e:	2a079a63          	bnez	a5,ffffffffc0201022 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d72:	4595                	li	a1,5
ffffffffc0200d74:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d76:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d7a:	01643023          	sd	s6,0(s0)
ffffffffc0200d7e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d82:	0d1000ef          	jal	ra,ffffffffc0201652 <free_pages>
    return listelm->next;
ffffffffc0200d86:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d88:	00878963          	beq	a5,s0,ffffffffc0200d9a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d8c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d90:	679c                	ld	a5,8(a5)
ffffffffc0200d92:	397d                	addiw	s2,s2,-1
ffffffffc0200d94:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d96:	fe879be3          	bne	a5,s0,ffffffffc0200d8c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200d9a:	26091463          	bnez	s2,ffffffffc0201002 <default_check+0x536>
    assert(total == 0);
ffffffffc0200d9e:	46049263          	bnez	s1,ffffffffc0201202 <default_check+0x736>
}
ffffffffc0200da2:	60a6                	ld	ra,72(sp)
ffffffffc0200da4:	6406                	ld	s0,64(sp)
ffffffffc0200da6:	74e2                	ld	s1,56(sp)
ffffffffc0200da8:	7942                	ld	s2,48(sp)
ffffffffc0200daa:	79a2                	ld	s3,40(sp)
ffffffffc0200dac:	7a02                	ld	s4,32(sp)
ffffffffc0200dae:	6ae2                	ld	s5,24(sp)
ffffffffc0200db0:	6b42                	ld	s6,16(sp)
ffffffffc0200db2:	6ba2                	ld	s7,8(sp)
ffffffffc0200db4:	6c02                	ld	s8,0(sp)
ffffffffc0200db6:	6161                	addi	sp,sp,80
ffffffffc0200db8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dba:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dbc:	4481                	li	s1,0
ffffffffc0200dbe:	4901                	li	s2,0
ffffffffc0200dc0:	b3b9                	j	ffffffffc0200b0e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200dc2:	00004697          	auipc	a3,0x4
ffffffffc0200dc6:	15e68693          	addi	a3,a3,350 # ffffffffc0204f20 <commands+0x728>
ffffffffc0200dca:	00004617          	auipc	a2,0x4
ffffffffc0200dce:	16660613          	addi	a2,a2,358 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200dd2:	0f000593          	li	a1,240
ffffffffc0200dd6:	00004517          	auipc	a0,0x4
ffffffffc0200dda:	17250513          	addi	a0,a0,370 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200dde:	d96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200de2:	00004697          	auipc	a3,0x4
ffffffffc0200de6:	1fe68693          	addi	a3,a3,510 # ffffffffc0204fe0 <commands+0x7e8>
ffffffffc0200dea:	00004617          	auipc	a2,0x4
ffffffffc0200dee:	14660613          	addi	a2,a2,326 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200df2:	0bd00593          	li	a1,189
ffffffffc0200df6:	00004517          	auipc	a0,0x4
ffffffffc0200dfa:	15250513          	addi	a0,a0,338 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200dfe:	d76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e02:	00004697          	auipc	a3,0x4
ffffffffc0200e06:	20668693          	addi	a3,a3,518 # ffffffffc0205008 <commands+0x810>
ffffffffc0200e0a:	00004617          	auipc	a2,0x4
ffffffffc0200e0e:	12660613          	addi	a2,a2,294 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200e12:	0be00593          	li	a1,190
ffffffffc0200e16:	00004517          	auipc	a0,0x4
ffffffffc0200e1a:	13250513          	addi	a0,a0,306 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200e1e:	d56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	22668693          	addi	a3,a3,550 # ffffffffc0205048 <commands+0x850>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	10660613          	addi	a2,a2,262 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200e32:	0c000593          	li	a1,192
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	11250513          	addi	a0,a0,274 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200e3e:	d36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	28e68693          	addi	a3,a3,654 # ffffffffc02050d0 <commands+0x8d8>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	0e660613          	addi	a2,a2,230 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200e52:	0d900593          	li	a1,217
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	0f250513          	addi	a0,a0,242 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200e5e:	d16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	11e68693          	addi	a3,a3,286 # ffffffffc0204f80 <commands+0x788>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	0c660613          	addi	a2,a2,198 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200e72:	0d200593          	li	a1,210
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	0d250513          	addi	a0,a0,210 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200e7e:	cf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	23e68693          	addi	a3,a3,574 # ffffffffc02050c0 <commands+0x8c8>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	0a660613          	addi	a2,a2,166 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200e92:	0d000593          	li	a1,208
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	0b250513          	addi	a0,a0,178 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200e9e:	cd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	20668693          	addi	a3,a3,518 # ffffffffc02050a8 <commands+0x8b0>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	08660613          	addi	a2,a2,134 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200eb2:	0cb00593          	li	a1,203
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	09250513          	addi	a0,a0,146 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200ebe:	cb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	1c668693          	addi	a3,a3,454 # ffffffffc0205088 <commands+0x890>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	06660613          	addi	a2,a2,102 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200ed2:	0c200593          	li	a1,194
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	07250513          	addi	a0,a0,114 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200ede:	c96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	23668693          	addi	a3,a3,566 # ffffffffc0205118 <commands+0x920>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	04660613          	addi	a2,a2,70 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200ef2:	0f800593          	li	a1,248
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	05250513          	addi	a0,a0,82 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200efe:	c76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	20668693          	addi	a3,a3,518 # ffffffffc0205108 <commands+0x910>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	02660613          	addi	a2,a2,38 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200f12:	0df00593          	li	a1,223
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	03250513          	addi	a0,a0,50 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200f1e:	c56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	18668693          	addi	a3,a3,390 # ffffffffc02050a8 <commands+0x8b0>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	00660613          	addi	a2,a2,6 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200f32:	0dd00593          	li	a1,221
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	01250513          	addi	a0,a0,18 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200f3e:	c36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	1a668693          	addi	a3,a3,422 # ffffffffc02050e8 <commands+0x8f0>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	fe660613          	addi	a2,a2,-26 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200f52:	0dc00593          	li	a1,220
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	ff250513          	addi	a0,a0,-14 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200f5e:	c16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	01e68693          	addi	a3,a3,30 # ffffffffc0204f80 <commands+0x788>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	fc660613          	addi	a2,a2,-58 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200f72:	0b900593          	li	a1,185
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	fd250513          	addi	a0,a0,-46 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200f7e:	bf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	12668693          	addi	a3,a3,294 # ffffffffc02050a8 <commands+0x8b0>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	fa660613          	addi	a2,a2,-90 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200f92:	0d600593          	li	a1,214
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	fb250513          	addi	a0,a0,-78 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200f9e:	bd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	01e68693          	addi	a3,a3,30 # ffffffffc0204fc0 <commands+0x7c8>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	f8660613          	addi	a2,a2,-122 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200fb2:	0d400593          	li	a1,212
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	f9250513          	addi	a0,a0,-110 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200fbe:	bb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	fde68693          	addi	a3,a3,-34 # ffffffffc0204fa0 <commands+0x7a8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	f6660613          	addi	a2,a2,-154 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200fd2:	0d300593          	li	a1,211
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	f7250513          	addi	a0,a0,-142 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200fde:	b96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	fde68693          	addi	a3,a3,-34 # ffffffffc0204fc0 <commands+0x7c8>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	f4660613          	addi	a2,a2,-186 # ffffffffc0204f30 <commands+0x738>
ffffffffc0200ff2:	0bb00593          	li	a1,187
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	f5250513          	addi	a0,a0,-174 # ffffffffc0204f48 <commands+0x750>
ffffffffc0200ffe:	b76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	26668693          	addi	a3,a3,614 # ffffffffc0205268 <commands+0xa70>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	f2660613          	addi	a2,a2,-218 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201012:	12500593          	li	a1,293
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	f3250513          	addi	a0,a0,-206 # ffffffffc0204f48 <commands+0x750>
ffffffffc020101e:	b56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	0e668693          	addi	a3,a3,230 # ffffffffc0205108 <commands+0x910>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	f0660613          	addi	a2,a2,-250 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201032:	11a00593          	li	a1,282
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	f1250513          	addi	a0,a0,-238 # ffffffffc0204f48 <commands+0x750>
ffffffffc020103e:	b36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	06668693          	addi	a3,a3,102 # ffffffffc02050a8 <commands+0x8b0>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	ee660613          	addi	a2,a2,-282 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201052:	11800593          	li	a1,280
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	ef250513          	addi	a0,a0,-270 # ffffffffc0204f48 <commands+0x750>
ffffffffc020105e:	b16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	00668693          	addi	a3,a3,6 # ffffffffc0205068 <commands+0x870>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	ec660613          	addi	a2,a2,-314 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201072:	0c100593          	li	a1,193
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	ed250513          	addi	a0,a0,-302 # ffffffffc0204f48 <commands+0x750>
ffffffffc020107e:	af6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	1a668693          	addi	a3,a3,422 # ffffffffc0205228 <commands+0xa30>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	ea660613          	addi	a2,a2,-346 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201092:	11200593          	li	a1,274
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	eb250513          	addi	a0,a0,-334 # ffffffffc0204f48 <commands+0x750>
ffffffffc020109e:	ad6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	16668693          	addi	a3,a3,358 # ffffffffc0205208 <commands+0xa10>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	e8660613          	addi	a2,a2,-378 # ffffffffc0204f30 <commands+0x738>
ffffffffc02010b2:	11000593          	li	a1,272
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	e9250513          	addi	a0,a0,-366 # ffffffffc0204f48 <commands+0x750>
ffffffffc02010be:	ab6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	11e68693          	addi	a3,a3,286 # ffffffffc02051e0 <commands+0x9e8>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	e6660613          	addi	a2,a2,-410 # ffffffffc0204f30 <commands+0x738>
ffffffffc02010d2:	10e00593          	li	a1,270
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	e7250513          	addi	a0,a0,-398 # ffffffffc0204f48 <commands+0x750>
ffffffffc02010de:	a96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	0d668693          	addi	a3,a3,214 # ffffffffc02051b8 <commands+0x9c0>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	e4660613          	addi	a2,a2,-442 # ffffffffc0204f30 <commands+0x738>
ffffffffc02010f2:	10d00593          	li	a1,269
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	e5250513          	addi	a0,a0,-430 # ffffffffc0204f48 <commands+0x750>
ffffffffc02010fe:	a76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	0a668693          	addi	a3,a3,166 # ffffffffc02051a8 <commands+0x9b0>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	e2660613          	addi	a2,a2,-474 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201112:	10800593          	li	a1,264
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	e3250513          	addi	a0,a0,-462 # ffffffffc0204f48 <commands+0x750>
ffffffffc020111e:	a56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	f8668693          	addi	a3,a3,-122 # ffffffffc02050a8 <commands+0x8b0>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	e0660613          	addi	a2,a2,-506 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201132:	10700593          	li	a1,263
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	e1250513          	addi	a0,a0,-494 # ffffffffc0204f48 <commands+0x750>
ffffffffc020113e:	a36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	04668693          	addi	a3,a3,70 # ffffffffc0205188 <commands+0x990>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	de660613          	addi	a2,a2,-538 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201152:	10600593          	li	a1,262
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	df250513          	addi	a0,a0,-526 # ffffffffc0204f48 <commands+0x750>
ffffffffc020115e:	a16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	ff668693          	addi	a3,a3,-10 # ffffffffc0205158 <commands+0x960>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	dc660613          	addi	a2,a2,-570 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201172:	10500593          	li	a1,261
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	dd250513          	addi	a0,a0,-558 # ffffffffc0204f48 <commands+0x750>
ffffffffc020117e:	9f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205140 <commands+0x948>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	da660613          	addi	a2,a2,-602 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201192:	10400593          	li	a1,260
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	db250513          	addi	a0,a0,-590 # ffffffffc0204f48 <commands+0x750>
ffffffffc020119e:	9d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	f0668693          	addi	a3,a3,-250 # ffffffffc02050a8 <commands+0x8b0>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	d8660613          	addi	a2,a2,-634 # ffffffffc0204f30 <commands+0x738>
ffffffffc02011b2:	0fe00593          	li	a1,254
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	d9250513          	addi	a0,a0,-622 # ffffffffc0204f48 <commands+0x750>
ffffffffc02011be:	9b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	f6668693          	addi	a3,a3,-154 # ffffffffc0205128 <commands+0x930>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	d6660613          	addi	a2,a2,-666 # ffffffffc0204f30 <commands+0x738>
ffffffffc02011d2:	0f900593          	li	a1,249
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	d7250513          	addi	a0,a0,-654 # ffffffffc0204f48 <commands+0x750>
ffffffffc02011de:	996ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	06668693          	addi	a3,a3,102 # ffffffffc0205248 <commands+0xa50>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	d4660613          	addi	a2,a2,-698 # ffffffffc0204f30 <commands+0x738>
ffffffffc02011f2:	11700593          	li	a1,279
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	d5250513          	addi	a0,a0,-686 # ffffffffc0204f48 <commands+0x750>
ffffffffc02011fe:	976ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	07668693          	addi	a3,a3,118 # ffffffffc0205278 <commands+0xa80>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	d2660613          	addi	a2,a2,-730 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201212:	12600593          	li	a1,294
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	d3250513          	addi	a0,a0,-718 # ffffffffc0204f48 <commands+0x750>
ffffffffc020121e:	956ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	d3e68693          	addi	a3,a3,-706 # ffffffffc0204f60 <commands+0x768>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	d0660613          	addi	a2,a2,-762 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201232:	0f300593          	li	a1,243
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	d1250513          	addi	a0,a0,-750 # ffffffffc0204f48 <commands+0x750>
ffffffffc020123e:	936ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	d5e68693          	addi	a3,a3,-674 # ffffffffc0204fa0 <commands+0x7a8>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	ce660613          	addi	a2,a2,-794 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201252:	0ba00593          	li	a1,186
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	cf250513          	addi	a0,a0,-782 # ffffffffc0204f48 <commands+0x750>
ffffffffc020125e:	916ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201262 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201262:	1141                	addi	sp,sp,-16
ffffffffc0201264:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201266:	14058a63          	beqz	a1,ffffffffc02013ba <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020126a:	00359693          	slli	a3,a1,0x3
ffffffffc020126e:	96ae                	add	a3,a3,a1
ffffffffc0201270:	068e                	slli	a3,a3,0x3
ffffffffc0201272:	96aa                	add	a3,a3,a0
ffffffffc0201274:	87aa                	mv	a5,a0
ffffffffc0201276:	02d50263          	beq	a0,a3,ffffffffc020129a <default_free_pages+0x38>
ffffffffc020127a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020127c:	8b05                	andi	a4,a4,1
ffffffffc020127e:	10071e63          	bnez	a4,ffffffffc020139a <default_free_pages+0x138>
ffffffffc0201282:	6798                	ld	a4,8(a5)
ffffffffc0201284:	8b09                	andi	a4,a4,2
ffffffffc0201286:	10071a63          	bnez	a4,ffffffffc020139a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020128a:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020128e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201292:	04878793          	addi	a5,a5,72
ffffffffc0201296:	fed792e3          	bne	a5,a3,ffffffffc020127a <default_free_pages+0x18>
    base->property = n;
ffffffffc020129a:	2581                	sext.w	a1,a1
ffffffffc020129c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020129e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012a2:	4789                	li	a5,2
ffffffffc02012a4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012a8:	00010697          	auipc	a3,0x10
ffffffffc02012ac:	d9868693          	addi	a3,a3,-616 # ffffffffc0211040 <free_area>
ffffffffc02012b0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012b2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012b4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012b8:	9db9                	addw	a1,a1,a4
ffffffffc02012ba:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012bc:	0ad78863          	beq	a5,a3,ffffffffc020136c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012c0:	fe078713          	addi	a4,a5,-32
ffffffffc02012c4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012c8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012ca:	00e56a63          	bltu	a0,a4,ffffffffc02012de <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012ce:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012d0:	06d70263          	beq	a4,a3,ffffffffc0201334 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02012d4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012d6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012da:	fee57ae3          	bgeu	a0,a4,ffffffffc02012ce <default_free_pages+0x6c>
ffffffffc02012de:	c199                	beqz	a1,ffffffffc02012e4 <default_free_pages+0x82>
ffffffffc02012e0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012e4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012e6:	e390                	sd	a2,0(a5)
ffffffffc02012e8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012ea:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02012ec:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012ee:	02d70063          	beq	a4,a3,ffffffffc020130e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02012f2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02012f6:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02012fa:	02081613          	slli	a2,a6,0x20
ffffffffc02012fe:	9201                	srli	a2,a2,0x20
ffffffffc0201300:	00361793          	slli	a5,a2,0x3
ffffffffc0201304:	97b2                	add	a5,a5,a2
ffffffffc0201306:	078e                	slli	a5,a5,0x3
ffffffffc0201308:	97ae                	add	a5,a5,a1
ffffffffc020130a:	02f50f63          	beq	a0,a5,ffffffffc0201348 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020130e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201310:	00d70f63          	beq	a4,a3,ffffffffc020132e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201314:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201316:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020131a:	02059613          	slli	a2,a1,0x20
ffffffffc020131e:	9201                	srli	a2,a2,0x20
ffffffffc0201320:	00361793          	slli	a5,a2,0x3
ffffffffc0201324:	97b2                	add	a5,a5,a2
ffffffffc0201326:	078e                	slli	a5,a5,0x3
ffffffffc0201328:	97aa                	add	a5,a5,a0
ffffffffc020132a:	04f68863          	beq	a3,a5,ffffffffc020137a <default_free_pages+0x118>
}
ffffffffc020132e:	60a2                	ld	ra,8(sp)
ffffffffc0201330:	0141                	addi	sp,sp,16
ffffffffc0201332:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201334:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201336:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201338:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020133a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133c:	02d70563          	beq	a4,a3,ffffffffc0201366 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201340:	8832                	mv	a6,a2
ffffffffc0201342:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201344:	87ba                	mv	a5,a4
ffffffffc0201346:	bf41                	j	ffffffffc02012d6 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201348:	4d1c                	lw	a5,24(a0)
ffffffffc020134a:	0107883b          	addw	a6,a5,a6
ffffffffc020134e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201352:	57f5                	li	a5,-3
ffffffffc0201354:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201358:	7110                	ld	a2,32(a0)
ffffffffc020135a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020135c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020135e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201360:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201362:	e390                	sd	a2,0(a5)
ffffffffc0201364:	b775                	j	ffffffffc0201310 <default_free_pages+0xae>
ffffffffc0201366:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201368:	873e                	mv	a4,a5
ffffffffc020136a:	b761                	j	ffffffffc02012f2 <default_free_pages+0x90>
}
ffffffffc020136c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020136e:	e390                	sd	a2,0(a5)
ffffffffc0201370:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201372:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201374:	f11c                	sd	a5,32(a0)
ffffffffc0201376:	0141                	addi	sp,sp,16
ffffffffc0201378:	8082                	ret
            base->property += p->property;
ffffffffc020137a:	ff872783          	lw	a5,-8(a4)
ffffffffc020137e:	fe870693          	addi	a3,a4,-24
ffffffffc0201382:	9dbd                	addw	a1,a1,a5
ffffffffc0201384:	cd0c                	sw	a1,24(a0)
ffffffffc0201386:	57f5                	li	a5,-3
ffffffffc0201388:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020138c:	6314                	ld	a3,0(a4)
ffffffffc020138e:	671c                	ld	a5,8(a4)
}
ffffffffc0201390:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201392:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201394:	e394                	sd	a3,0(a5)
ffffffffc0201396:	0141                	addi	sp,sp,16
ffffffffc0201398:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020139a:	00004697          	auipc	a3,0x4
ffffffffc020139e:	ef668693          	addi	a3,a3,-266 # ffffffffc0205290 <commands+0xa98>
ffffffffc02013a2:	00004617          	auipc	a2,0x4
ffffffffc02013a6:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204f30 <commands+0x738>
ffffffffc02013aa:	08300593          	li	a1,131
ffffffffc02013ae:	00004517          	auipc	a0,0x4
ffffffffc02013b2:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0204f48 <commands+0x750>
ffffffffc02013b6:	fbffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013ba:	00004697          	auipc	a3,0x4
ffffffffc02013be:	ece68693          	addi	a3,a3,-306 # ffffffffc0205288 <commands+0xa90>
ffffffffc02013c2:	00004617          	auipc	a2,0x4
ffffffffc02013c6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204f30 <commands+0x738>
ffffffffc02013ca:	08000593          	li	a1,128
ffffffffc02013ce:	00004517          	auipc	a0,0x4
ffffffffc02013d2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0204f48 <commands+0x750>
ffffffffc02013d6:	f9ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02013da <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013da:	c959                	beqz	a0,ffffffffc0201470 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013dc:	00010597          	auipc	a1,0x10
ffffffffc02013e0:	c6458593          	addi	a1,a1,-924 # ffffffffc0211040 <free_area>
ffffffffc02013e4:	0105a803          	lw	a6,16(a1)
ffffffffc02013e8:	862a                	mv	a2,a0
ffffffffc02013ea:	02081793          	slli	a5,a6,0x20
ffffffffc02013ee:	9381                	srli	a5,a5,0x20
ffffffffc02013f0:	00a7ee63          	bltu	a5,a0,ffffffffc020140c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02013f4:	87ae                	mv	a5,a1
ffffffffc02013f6:	a801                	j	ffffffffc0201406 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	02071693          	slli	a3,a4,0x20
ffffffffc0201400:	9281                	srli	a3,a3,0x20
ffffffffc0201402:	00c6f763          	bgeu	a3,a2,ffffffffc0201410 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201406:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201408:	feb798e3          	bne	a5,a1,ffffffffc02013f8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020140c:	4501                	li	a0,0
}
ffffffffc020140e:	8082                	ret
    return listelm->prev;
ffffffffc0201410:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201414:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201418:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020141c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201420:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201424:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201428:	02d67b63          	bgeu	a2,a3,ffffffffc020145e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020142c:	00361693          	slli	a3,a2,0x3
ffffffffc0201430:	96b2                	add	a3,a3,a2
ffffffffc0201432:	068e                	slli	a3,a3,0x3
ffffffffc0201434:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201436:	41c7073b          	subw	a4,a4,t3
ffffffffc020143a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020143c:	00868613          	addi	a2,a3,8
ffffffffc0201440:	4709                	li	a4,2
ffffffffc0201442:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201446:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020144a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020144e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201452:	e310                	sd	a2,0(a4)
ffffffffc0201454:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201458:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020145a:	0316b023          	sd	a7,32(a3)
ffffffffc020145e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201462:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201466:	5775                	li	a4,-3
ffffffffc0201468:	17a1                	addi	a5,a5,-24
ffffffffc020146a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020146e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201470:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201472:	00004697          	auipc	a3,0x4
ffffffffc0201476:	e1668693          	addi	a3,a3,-490 # ffffffffc0205288 <commands+0xa90>
ffffffffc020147a:	00004617          	auipc	a2,0x4
ffffffffc020147e:	ab660613          	addi	a2,a2,-1354 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201482:	06200593          	li	a1,98
ffffffffc0201486:	00004517          	auipc	a0,0x4
ffffffffc020148a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0204f48 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc020148e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201490:	ee5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201494 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201494:	1141                	addi	sp,sp,-16
ffffffffc0201496:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201498:	c9e1                	beqz	a1,ffffffffc0201568 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020149a:	00359693          	slli	a3,a1,0x3
ffffffffc020149e:	96ae                	add	a3,a3,a1
ffffffffc02014a0:	068e                	slli	a3,a3,0x3
ffffffffc02014a2:	96aa                	add	a3,a3,a0
ffffffffc02014a4:	87aa                	mv	a5,a0
ffffffffc02014a6:	00d50f63          	beq	a0,a3,ffffffffc02014c4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014aa:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014ac:	8b05                	andi	a4,a4,1
ffffffffc02014ae:	cf49                	beqz	a4,ffffffffc0201548 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014b0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014b4:	0007b423          	sd	zero,8(a5)
ffffffffc02014b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014bc:	04878793          	addi	a5,a5,72
ffffffffc02014c0:	fed795e3          	bne	a5,a3,ffffffffc02014aa <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014c4:	2581                	sext.w	a1,a1
ffffffffc02014c6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014c8:	4789                	li	a5,2
ffffffffc02014ca:	00850713          	addi	a4,a0,8
ffffffffc02014ce:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014d2:	00010697          	auipc	a3,0x10
ffffffffc02014d6:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0211040 <free_area>
ffffffffc02014da:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014dc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014de:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02014e2:	9db9                	addw	a1,a1,a4
ffffffffc02014e4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014e6:	04d78a63          	beq	a5,a3,ffffffffc020153a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02014ea:	fe078713          	addi	a4,a5,-32
ffffffffc02014ee:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014f2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02014f4:	00e56a63          	bltu	a0,a4,ffffffffc0201508 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02014f8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014fa:	02d70263          	beq	a4,a3,ffffffffc020151e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02014fe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201500:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201504:	fee57ae3          	bgeu	a0,a4,ffffffffc02014f8 <default_init_memmap+0x64>
ffffffffc0201508:	c199                	beqz	a1,ffffffffc020150e <default_init_memmap+0x7a>
ffffffffc020150a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020150e:	6398                	ld	a4,0(a5)
}
ffffffffc0201510:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201512:	e390                	sd	a2,0(a5)
ffffffffc0201514:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201516:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201518:	f118                	sd	a4,32(a0)
ffffffffc020151a:	0141                	addi	sp,sp,16
ffffffffc020151c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020151e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201520:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201522:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201524:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201526:	00d70663          	beq	a4,a3,ffffffffc0201532 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020152a:	8832                	mv	a6,a2
ffffffffc020152c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020152e:	87ba                	mv	a5,a4
ffffffffc0201530:	bfc1                	j	ffffffffc0201500 <default_init_memmap+0x6c>
}
ffffffffc0201532:	60a2                	ld	ra,8(sp)
ffffffffc0201534:	e290                	sd	a2,0(a3)
ffffffffc0201536:	0141                	addi	sp,sp,16
ffffffffc0201538:	8082                	ret
ffffffffc020153a:	60a2                	ld	ra,8(sp)
ffffffffc020153c:	e390                	sd	a2,0(a5)
ffffffffc020153e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201540:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201542:	f11c                	sd	a5,32(a0)
ffffffffc0201544:	0141                	addi	sp,sp,16
ffffffffc0201546:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201548:	00004697          	auipc	a3,0x4
ffffffffc020154c:	d7068693          	addi	a3,a3,-656 # ffffffffc02052b8 <commands+0xac0>
ffffffffc0201550:	00004617          	auipc	a2,0x4
ffffffffc0201554:	9e060613          	addi	a2,a2,-1568 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201558:	04900593          	li	a1,73
ffffffffc020155c:	00004517          	auipc	a0,0x4
ffffffffc0201560:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0204f48 <commands+0x750>
ffffffffc0201564:	e11fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	d2068693          	addi	a3,a3,-736 # ffffffffc0205288 <commands+0xa90>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	9c060613          	addi	a2,a2,-1600 # ffffffffc0204f30 <commands+0x738>
ffffffffc0201578:	04600593          	li	a1,70
ffffffffc020157c:	00004517          	auipc	a0,0x4
ffffffffc0201580:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0204f48 <commands+0x750>
ffffffffc0201584:	df1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201588 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201588:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020158a:	00004617          	auipc	a2,0x4
ffffffffc020158e:	d8e60613          	addi	a2,a2,-626 # ffffffffc0205318 <default_pmm_manager+0x38>
ffffffffc0201592:	06500593          	li	a1,101
ffffffffc0201596:	00004517          	auipc	a0,0x4
ffffffffc020159a:	da250513          	addi	a0,a0,-606 # ffffffffc0205338 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020159e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015a0:	dd5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015a4 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015a4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015a6:	00004617          	auipc	a2,0x4
ffffffffc02015aa:	da260613          	addi	a2,a2,-606 # ffffffffc0205348 <default_pmm_manager+0x68>
ffffffffc02015ae:	07000593          	li	a1,112
ffffffffc02015b2:	00004517          	auipc	a0,0x4
ffffffffc02015b6:	d8650513          	addi	a0,a0,-634 # ffffffffc0205338 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015ba:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015bc:	db9fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015c0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015c0:	7139                	addi	sp,sp,-64
ffffffffc02015c2:	f426                	sd	s1,40(sp)
ffffffffc02015c4:	f04a                	sd	s2,32(sp)
ffffffffc02015c6:	ec4e                	sd	s3,24(sp)
ffffffffc02015c8:	e852                	sd	s4,16(sp)
ffffffffc02015ca:	e456                	sd	s5,8(sp)
ffffffffc02015cc:	e05a                	sd	s6,0(sp)
ffffffffc02015ce:	fc06                	sd	ra,56(sp)
ffffffffc02015d0:	f822                	sd	s0,48(sp)
ffffffffc02015d2:	84aa                	mv	s1,a0
ffffffffc02015d4:	00010917          	auipc	s2,0x10
ffffffffc02015d8:	f5c90913          	addi	s2,s2,-164 # ffffffffc0211530 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015dc:	4a05                	li	s4,1
ffffffffc02015de:	00010a97          	auipc	s5,0x10
ffffffffc02015e2:	f72a8a93          	addi	s5,s5,-142 # ffffffffc0211550 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02015e6:	0005099b          	sext.w	s3,a0
ffffffffc02015ea:	00010b17          	auipc	s6,0x10
ffffffffc02015ee:	f76b0b13          	addi	s6,s6,-138 # ffffffffc0211560 <check_mm_struct>
ffffffffc02015f2:	a01d                	j	ffffffffc0201618 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02015f4:	00093783          	ld	a5,0(s2)
ffffffffc02015f8:	6f9c                	ld	a5,24(a5)
ffffffffc02015fa:	9782                	jalr	a5
ffffffffc02015fc:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02015fe:	4601                	li	a2,0
ffffffffc0201600:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201602:	ec0d                	bnez	s0,ffffffffc020163c <alloc_pages+0x7c>
ffffffffc0201604:	029a6c63          	bltu	s4,s1,ffffffffc020163c <alloc_pages+0x7c>
ffffffffc0201608:	000aa783          	lw	a5,0(s5)
ffffffffc020160c:	2781                	sext.w	a5,a5
ffffffffc020160e:	c79d                	beqz	a5,ffffffffc020163c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201610:	000b3503          	ld	a0,0(s6)
ffffffffc0201614:	189010ef          	jal	ra,ffffffffc0202f9c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201618:	100027f3          	csrr	a5,sstatus
ffffffffc020161c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020161e:	8526                	mv	a0,s1
ffffffffc0201620:	dbf1                	beqz	a5,ffffffffc02015f4 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201622:	ecdfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201626:	00093783          	ld	a5,0(s2)
ffffffffc020162a:	8526                	mv	a0,s1
ffffffffc020162c:	6f9c                	ld	a5,24(a5)
ffffffffc020162e:	9782                	jalr	a5
ffffffffc0201630:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201632:	eb7fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201636:	4601                	li	a2,0
ffffffffc0201638:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020163a:	d469                	beqz	s0,ffffffffc0201604 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020163c:	70e2                	ld	ra,56(sp)
ffffffffc020163e:	8522                	mv	a0,s0
ffffffffc0201640:	7442                	ld	s0,48(sp)
ffffffffc0201642:	74a2                	ld	s1,40(sp)
ffffffffc0201644:	7902                	ld	s2,32(sp)
ffffffffc0201646:	69e2                	ld	s3,24(sp)
ffffffffc0201648:	6a42                	ld	s4,16(sp)
ffffffffc020164a:	6aa2                	ld	s5,8(sp)
ffffffffc020164c:	6b02                	ld	s6,0(sp)
ffffffffc020164e:	6121                	addi	sp,sp,64
ffffffffc0201650:	8082                	ret

ffffffffc0201652 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201652:	100027f3          	csrr	a5,sstatus
ffffffffc0201656:	8b89                	andi	a5,a5,2
ffffffffc0201658:	e799                	bnez	a5,ffffffffc0201666 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020165a:	00010797          	auipc	a5,0x10
ffffffffc020165e:	ed67b783          	ld	a5,-298(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201662:	739c                	ld	a5,32(a5)
ffffffffc0201664:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201666:	1101                	addi	sp,sp,-32
ffffffffc0201668:	ec06                	sd	ra,24(sp)
ffffffffc020166a:	e822                	sd	s0,16(sp)
ffffffffc020166c:	e426                	sd	s1,8(sp)
ffffffffc020166e:	842a                	mv	s0,a0
ffffffffc0201670:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201672:	e7dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201676:	00010797          	auipc	a5,0x10
ffffffffc020167a:	eba7b783          	ld	a5,-326(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020167e:	739c                	ld	a5,32(a5)
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	8522                	mv	a0,s0
ffffffffc0201684:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201686:	6442                	ld	s0,16(sp)
ffffffffc0201688:	60e2                	ld	ra,24(sp)
ffffffffc020168a:	64a2                	ld	s1,8(sp)
ffffffffc020168c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020168e:	e5bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0201692 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201692:	100027f3          	csrr	a5,sstatus
ffffffffc0201696:	8b89                	andi	a5,a5,2
ffffffffc0201698:	e799                	bnez	a5,ffffffffc02016a6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020169a:	00010797          	auipc	a5,0x10
ffffffffc020169e:	e967b783          	ld	a5,-362(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02016a2:	779c                	ld	a5,40(a5)
ffffffffc02016a4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016a6:	1141                	addi	sp,sp,-16
ffffffffc02016a8:	e406                	sd	ra,8(sp)
ffffffffc02016aa:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016ac:	e43fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016b0:	00010797          	auipc	a5,0x10
ffffffffc02016b4:	e807b783          	ld	a5,-384(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02016b8:	779c                	ld	a5,40(a5)
ffffffffc02016ba:	9782                	jalr	a5
ffffffffc02016bc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016be:	e2bfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016c2:	60a2                	ld	ra,8(sp)
ffffffffc02016c4:	8522                	mv	a0,s0
ffffffffc02016c6:	6402                	ld	s0,0(sp)
ffffffffc02016c8:	0141                	addi	sp,sp,16
ffffffffc02016ca:	8082                	ret

ffffffffc02016cc <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016cc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016d0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016d6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d8:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016da:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016de:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016e0:	f84a                	sd	s2,48(sp)
ffffffffc02016e2:	f44e                	sd	s3,40(sp)
ffffffffc02016e4:	f052                	sd	s4,32(sp)
ffffffffc02016e6:	e486                	sd	ra,72(sp)
ffffffffc02016e8:	e0a2                	sd	s0,64(sp)
ffffffffc02016ea:	ec56                	sd	s5,24(sp)
ffffffffc02016ec:	e85a                	sd	s6,16(sp)
ffffffffc02016ee:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016f0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f4:	892e                	mv	s2,a1
ffffffffc02016f6:	8a32                	mv	s4,a2
ffffffffc02016f8:	00010997          	auipc	s3,0x10
ffffffffc02016fc:	e2898993          	addi	s3,s3,-472 # ffffffffc0211520 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201700:	efb5                	bnez	a5,ffffffffc020177c <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201702:	14060c63          	beqz	a2,ffffffffc020185a <get_pte+0x18e>
ffffffffc0201706:	4505                	li	a0,1
ffffffffc0201708:	eb9ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc020170c:	842a                	mv	s0,a0
ffffffffc020170e:	14050663          	beqz	a0,ffffffffc020185a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201712:	00010b97          	auipc	s7,0x10
ffffffffc0201716:	e16b8b93          	addi	s7,s7,-490 # ffffffffc0211528 <pages>
ffffffffc020171a:	000bb503          	ld	a0,0(s7)
ffffffffc020171e:	00005b17          	auipc	s6,0x5
ffffffffc0201722:	dbab3b03          	ld	s6,-582(s6) # ffffffffc02064d8 <error_string+0x38>
ffffffffc0201726:	00080ab7          	lui	s5,0x80
ffffffffc020172a:	40a40533          	sub	a0,s0,a0
ffffffffc020172e:	850d                	srai	a0,a0,0x3
ffffffffc0201730:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201734:	00010997          	auipc	s3,0x10
ffffffffc0201738:	dec98993          	addi	s3,s3,-532 # ffffffffc0211520 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020173c:	4785                	li	a5,1
ffffffffc020173e:	0009b703          	ld	a4,0(s3)
ffffffffc0201742:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201744:	9556                	add	a0,a0,s5
ffffffffc0201746:	00c51793          	slli	a5,a0,0xc
ffffffffc020174a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020174c:	0532                	slli	a0,a0,0xc
ffffffffc020174e:	14e7fd63          	bgeu	a5,a4,ffffffffc02018a8 <get_pte+0x1dc>
ffffffffc0201752:	00010797          	auipc	a5,0x10
ffffffffc0201756:	de67b783          	ld	a5,-538(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc020175a:	6605                	lui	a2,0x1
ffffffffc020175c:	4581                	li	a1,0
ffffffffc020175e:	953e                	add	a0,a0,a5
ffffffffc0201760:	615020ef          	jal	ra,ffffffffc0204574 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201764:	000bb683          	ld	a3,0(s7)
ffffffffc0201768:	40d406b3          	sub	a3,s0,a3
ffffffffc020176c:	868d                	srai	a3,a3,0x3
ffffffffc020176e:	036686b3          	mul	a3,a3,s6
ffffffffc0201772:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201774:	06aa                	slli	a3,a3,0xa
ffffffffc0201776:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020177a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020177c:	77fd                	lui	a5,0xfffff
ffffffffc020177e:	068a                	slli	a3,a3,0x2
ffffffffc0201780:	0009b703          	ld	a4,0(s3)
ffffffffc0201784:	8efd                	and	a3,a3,a5
ffffffffc0201786:	00c6d793          	srli	a5,a3,0xc
ffffffffc020178a:	0ce7fa63          	bgeu	a5,a4,ffffffffc020185e <get_pte+0x192>
ffffffffc020178e:	00010a97          	auipc	s5,0x10
ffffffffc0201792:	daaa8a93          	addi	s5,s5,-598 # ffffffffc0211538 <va_pa_offset>
ffffffffc0201796:	000ab403          	ld	s0,0(s5)
ffffffffc020179a:	01595793          	srli	a5,s2,0x15
ffffffffc020179e:	1ff7f793          	andi	a5,a5,511
ffffffffc02017a2:	96a2                	add	a3,a3,s0
ffffffffc02017a4:	00379413          	slli	s0,a5,0x3
ffffffffc02017a8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017aa:	6014                	ld	a3,0(s0)
ffffffffc02017ac:	0016f793          	andi	a5,a3,1
ffffffffc02017b0:	ebad                	bnez	a5,ffffffffc0201822 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017b2:	0a0a0463          	beqz	s4,ffffffffc020185a <get_pte+0x18e>
ffffffffc02017b6:	4505                	li	a0,1
ffffffffc02017b8:	e09ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc02017bc:	84aa                	mv	s1,a0
ffffffffc02017be:	cd51                	beqz	a0,ffffffffc020185a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c0:	00010b97          	auipc	s7,0x10
ffffffffc02017c4:	d68b8b93          	addi	s7,s7,-664 # ffffffffc0211528 <pages>
ffffffffc02017c8:	000bb503          	ld	a0,0(s7)
ffffffffc02017cc:	00005b17          	auipc	s6,0x5
ffffffffc02017d0:	d0cb3b03          	ld	s6,-756(s6) # ffffffffc02064d8 <error_string+0x38>
ffffffffc02017d4:	00080a37          	lui	s4,0x80
ffffffffc02017d8:	40a48533          	sub	a0,s1,a0
ffffffffc02017dc:	850d                	srai	a0,a0,0x3
ffffffffc02017de:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017e2:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017e4:	0009b703          	ld	a4,0(s3)
ffffffffc02017e8:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017ea:	9552                	add	a0,a0,s4
ffffffffc02017ec:	00c51793          	slli	a5,a0,0xc
ffffffffc02017f0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017f2:	0532                	slli	a0,a0,0xc
ffffffffc02017f4:	08e7fd63          	bgeu	a5,a4,ffffffffc020188e <get_pte+0x1c2>
ffffffffc02017f8:	000ab783          	ld	a5,0(s5)
ffffffffc02017fc:	6605                	lui	a2,0x1
ffffffffc02017fe:	4581                	li	a1,0
ffffffffc0201800:	953e                	add	a0,a0,a5
ffffffffc0201802:	573020ef          	jal	ra,ffffffffc0204574 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201806:	000bb683          	ld	a3,0(s7)
ffffffffc020180a:	40d486b3          	sub	a3,s1,a3
ffffffffc020180e:	868d                	srai	a3,a3,0x3
ffffffffc0201810:	036686b3          	mul	a3,a3,s6
ffffffffc0201814:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201816:	06aa                	slli	a3,a3,0xa
ffffffffc0201818:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020181c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020181e:	0009b703          	ld	a4,0(s3)
ffffffffc0201822:	068a                	slli	a3,a3,0x2
ffffffffc0201824:	757d                	lui	a0,0xfffff
ffffffffc0201826:	8ee9                	and	a3,a3,a0
ffffffffc0201828:	00c6d793          	srli	a5,a3,0xc
ffffffffc020182c:	04e7f563          	bgeu	a5,a4,ffffffffc0201876 <get_pte+0x1aa>
ffffffffc0201830:	000ab503          	ld	a0,0(s5)
ffffffffc0201834:	00c95913          	srli	s2,s2,0xc
ffffffffc0201838:	1ff97913          	andi	s2,s2,511
ffffffffc020183c:	96aa                	add	a3,a3,a0
ffffffffc020183e:	00391513          	slli	a0,s2,0x3
ffffffffc0201842:	9536                	add	a0,a0,a3
}
ffffffffc0201844:	60a6                	ld	ra,72(sp)
ffffffffc0201846:	6406                	ld	s0,64(sp)
ffffffffc0201848:	74e2                	ld	s1,56(sp)
ffffffffc020184a:	7942                	ld	s2,48(sp)
ffffffffc020184c:	79a2                	ld	s3,40(sp)
ffffffffc020184e:	7a02                	ld	s4,32(sp)
ffffffffc0201850:	6ae2                	ld	s5,24(sp)
ffffffffc0201852:	6b42                	ld	s6,16(sp)
ffffffffc0201854:	6ba2                	ld	s7,8(sp)
ffffffffc0201856:	6161                	addi	sp,sp,80
ffffffffc0201858:	8082                	ret
            return NULL;
ffffffffc020185a:	4501                	li	a0,0
ffffffffc020185c:	b7e5                	j	ffffffffc0201844 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020185e:	00004617          	auipc	a2,0x4
ffffffffc0201862:	b1260613          	addi	a2,a2,-1262 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc0201866:	10200593          	li	a1,258
ffffffffc020186a:	00004517          	auipc	a0,0x4
ffffffffc020186e:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0201872:	b03fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201876:	00004617          	auipc	a2,0x4
ffffffffc020187a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc020187e:	10f00593          	li	a1,271
ffffffffc0201882:	00004517          	auipc	a0,0x4
ffffffffc0201886:	b1650513          	addi	a0,a0,-1258 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020188a:	aebfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020188e:	86aa                	mv	a3,a0
ffffffffc0201890:	00004617          	auipc	a2,0x4
ffffffffc0201894:	ae060613          	addi	a2,a2,-1312 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc0201898:	10b00593          	li	a1,267
ffffffffc020189c:	00004517          	auipc	a0,0x4
ffffffffc02018a0:	afc50513          	addi	a0,a0,-1284 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02018a4:	ad1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018a8:	86aa                	mv	a3,a0
ffffffffc02018aa:	00004617          	auipc	a2,0x4
ffffffffc02018ae:	ac660613          	addi	a2,a2,-1338 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc02018b2:	0ff00593          	li	a1,255
ffffffffc02018b6:	00004517          	auipc	a0,0x4
ffffffffc02018ba:	ae250513          	addi	a0,a0,-1310 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02018be:	ab7fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02018c2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018c2:	1141                	addi	sp,sp,-16
ffffffffc02018c4:	e022                	sd	s0,0(sp)
ffffffffc02018c6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018c8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018ca:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018cc:	e01ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02018d0:	c011                	beqz	s0,ffffffffc02018d4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02018d2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018d4:	c511                	beqz	a0,ffffffffc02018e0 <get_page+0x1e>
ffffffffc02018d6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02018d8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018da:	0017f713          	andi	a4,a5,1
ffffffffc02018de:	e709                	bnez	a4,ffffffffc02018e8 <get_page+0x26>
}
ffffffffc02018e0:	60a2                	ld	ra,8(sp)
ffffffffc02018e2:	6402                	ld	s0,0(sp)
ffffffffc02018e4:	0141                	addi	sp,sp,16
ffffffffc02018e6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02018e8:	078a                	slli	a5,a5,0x2
ffffffffc02018ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018ec:	00010717          	auipc	a4,0x10
ffffffffc02018f0:	c3473703          	ld	a4,-972(a4) # ffffffffc0211520 <npage>
ffffffffc02018f4:	02e7f263          	bgeu	a5,a4,ffffffffc0201918 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc02018f8:	fff80537          	lui	a0,0xfff80
ffffffffc02018fc:	97aa                	add	a5,a5,a0
ffffffffc02018fe:	60a2                	ld	ra,8(sp)
ffffffffc0201900:	6402                	ld	s0,0(sp)
ffffffffc0201902:	00379513          	slli	a0,a5,0x3
ffffffffc0201906:	97aa                	add	a5,a5,a0
ffffffffc0201908:	078e                	slli	a5,a5,0x3
ffffffffc020190a:	00010517          	auipc	a0,0x10
ffffffffc020190e:	c1e53503          	ld	a0,-994(a0) # ffffffffc0211528 <pages>
ffffffffc0201912:	953e                	add	a0,a0,a5
ffffffffc0201914:	0141                	addi	sp,sp,16
ffffffffc0201916:	8082                	ret
ffffffffc0201918:	c71ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>

ffffffffc020191c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020191c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020191e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201920:	ec06                	sd	ra,24(sp)
ffffffffc0201922:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201924:	da9ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    if (ptep != NULL) {
ffffffffc0201928:	c511                	beqz	a0,ffffffffc0201934 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020192a:	611c                	ld	a5,0(a0)
ffffffffc020192c:	842a                	mv	s0,a0
ffffffffc020192e:	0017f713          	andi	a4,a5,1
ffffffffc0201932:	e709                	bnez	a4,ffffffffc020193c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201934:	60e2                	ld	ra,24(sp)
ffffffffc0201936:	6442                	ld	s0,16(sp)
ffffffffc0201938:	6105                	addi	sp,sp,32
ffffffffc020193a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020193c:	078a                	slli	a5,a5,0x2
ffffffffc020193e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201940:	00010717          	auipc	a4,0x10
ffffffffc0201944:	be073703          	ld	a4,-1056(a4) # ffffffffc0211520 <npage>
ffffffffc0201948:	06e7f563          	bgeu	a5,a4,ffffffffc02019b2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020194c:	fff80737          	lui	a4,0xfff80
ffffffffc0201950:	97ba                	add	a5,a5,a4
ffffffffc0201952:	00379513          	slli	a0,a5,0x3
ffffffffc0201956:	97aa                	add	a5,a5,a0
ffffffffc0201958:	078e                	slli	a5,a5,0x3
ffffffffc020195a:	00010517          	auipc	a0,0x10
ffffffffc020195e:	bce53503          	ld	a0,-1074(a0) # ffffffffc0211528 <pages>
ffffffffc0201962:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201964:	411c                	lw	a5,0(a0)
ffffffffc0201966:	fff7871b          	addiw	a4,a5,-1
ffffffffc020196a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020196c:	cb09                	beqz	a4,ffffffffc020197e <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020196e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201972:	12000073          	sfence.vma
}
ffffffffc0201976:	60e2                	ld	ra,24(sp)
ffffffffc0201978:	6442                	ld	s0,16(sp)
ffffffffc020197a:	6105                	addi	sp,sp,32
ffffffffc020197c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020197e:	100027f3          	csrr	a5,sstatus
ffffffffc0201982:	8b89                	andi	a5,a5,2
ffffffffc0201984:	eb89                	bnez	a5,ffffffffc0201996 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201986:	00010797          	auipc	a5,0x10
ffffffffc020198a:	baa7b783          	ld	a5,-1110(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020198e:	739c                	ld	a5,32(a5)
ffffffffc0201990:	4585                	li	a1,1
ffffffffc0201992:	9782                	jalr	a5
    if (flag) {
ffffffffc0201994:	bfe9                	j	ffffffffc020196e <page_remove+0x52>
        intr_disable();
ffffffffc0201996:	e42a                	sd	a0,8(sp)
ffffffffc0201998:	b57fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020199c:	00010797          	auipc	a5,0x10
ffffffffc02019a0:	b947b783          	ld	a5,-1132(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02019a4:	739c                	ld	a5,32(a5)
ffffffffc02019a6:	6522                	ld	a0,8(sp)
ffffffffc02019a8:	4585                	li	a1,1
ffffffffc02019aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02019ac:	b3dfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019b0:	bf7d                	j	ffffffffc020196e <page_remove+0x52>
ffffffffc02019b2:	bd7ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>

ffffffffc02019b6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019b6:	7179                	addi	sp,sp,-48
ffffffffc02019b8:	87b2                	mv	a5,a2
ffffffffc02019ba:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019bc:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019be:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019c0:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019c2:	ec26                	sd	s1,24(sp)
ffffffffc02019c4:	f406                	sd	ra,40(sp)
ffffffffc02019c6:	e84a                	sd	s2,16(sp)
ffffffffc02019c8:	e44e                	sd	s3,8(sp)
ffffffffc02019ca:	e052                	sd	s4,0(sp)
ffffffffc02019cc:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019ce:	cffff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    if (ptep == NULL) {
ffffffffc02019d2:	cd71                	beqz	a0,ffffffffc0201aae <page_insert+0xf8>
    page->ref += 1;
ffffffffc02019d4:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc02019d6:	611c                	ld	a5,0(a0)
ffffffffc02019d8:	89aa                	mv	s3,a0
ffffffffc02019da:	0016871b          	addiw	a4,a3,1
ffffffffc02019de:	c018                	sw	a4,0(s0)
ffffffffc02019e0:	0017f713          	andi	a4,a5,1
ffffffffc02019e4:	e331                	bnez	a4,ffffffffc0201a28 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02019e6:	00010797          	auipc	a5,0x10
ffffffffc02019ea:	b427b783          	ld	a5,-1214(a5) # ffffffffc0211528 <pages>
ffffffffc02019ee:	40f407b3          	sub	a5,s0,a5
ffffffffc02019f2:	878d                	srai	a5,a5,0x3
ffffffffc02019f4:	00005417          	auipc	s0,0x5
ffffffffc02019f8:	ae443403          	ld	s0,-1308(s0) # ffffffffc02064d8 <error_string+0x38>
ffffffffc02019fc:	028787b3          	mul	a5,a5,s0
ffffffffc0201a00:	00080437          	lui	s0,0x80
ffffffffc0201a04:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a06:	07aa                	slli	a5,a5,0xa
ffffffffc0201a08:	8cdd                	or	s1,s1,a5
ffffffffc0201a0a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a0e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a12:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a16:	4501                	li	a0,0
}
ffffffffc0201a18:	70a2                	ld	ra,40(sp)
ffffffffc0201a1a:	7402                	ld	s0,32(sp)
ffffffffc0201a1c:	64e2                	ld	s1,24(sp)
ffffffffc0201a1e:	6942                	ld	s2,16(sp)
ffffffffc0201a20:	69a2                	ld	s3,8(sp)
ffffffffc0201a22:	6a02                	ld	s4,0(sp)
ffffffffc0201a24:	6145                	addi	sp,sp,48
ffffffffc0201a26:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a28:	00279713          	slli	a4,a5,0x2
ffffffffc0201a2c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a2e:	00010797          	auipc	a5,0x10
ffffffffc0201a32:	af27b783          	ld	a5,-1294(a5) # ffffffffc0211520 <npage>
ffffffffc0201a36:	06f77e63          	bgeu	a4,a5,ffffffffc0201ab2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a3a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a3e:	973e                	add	a4,a4,a5
ffffffffc0201a40:	00010a17          	auipc	s4,0x10
ffffffffc0201a44:	ae8a0a13          	addi	s4,s4,-1304 # ffffffffc0211528 <pages>
ffffffffc0201a48:	000a3783          	ld	a5,0(s4)
ffffffffc0201a4c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a50:	993a                	add	s2,s2,a4
ffffffffc0201a52:	090e                	slli	s2,s2,0x3
ffffffffc0201a54:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a56:	03240063          	beq	s0,s2,ffffffffc0201a76 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a5a:	00092783          	lw	a5,0(s2)
ffffffffc0201a5e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a62:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a66:	cb11                	beqz	a4,ffffffffc0201a7a <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a68:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a6c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a70:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201a74:	bfad                	j	ffffffffc02019ee <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201a76:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201a78:	bf9d                	j	ffffffffc02019ee <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a7a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a7e:	8b89                	andi	a5,a5,2
ffffffffc0201a80:	eb91                	bnez	a5,ffffffffc0201a94 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201a82:	00010797          	auipc	a5,0x10
ffffffffc0201a86:	aae7b783          	ld	a5,-1362(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201a8a:	739c                	ld	a5,32(a5)
ffffffffc0201a8c:	4585                	li	a1,1
ffffffffc0201a8e:	854a                	mv	a0,s2
ffffffffc0201a90:	9782                	jalr	a5
    if (flag) {
ffffffffc0201a92:	bfd9                	j	ffffffffc0201a68 <page_insert+0xb2>
        intr_disable();
ffffffffc0201a94:	a5bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201a98:	00010797          	auipc	a5,0x10
ffffffffc0201a9c:	a987b783          	ld	a5,-1384(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201aa0:	739c                	ld	a5,32(a5)
ffffffffc0201aa2:	4585                	li	a1,1
ffffffffc0201aa4:	854a                	mv	a0,s2
ffffffffc0201aa6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201aa8:	a41fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201aac:	bf75                	j	ffffffffc0201a68 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201aae:	5571                	li	a0,-4
ffffffffc0201ab0:	b7a5                	j	ffffffffc0201a18 <page_insert+0x62>
ffffffffc0201ab2:	ad7ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>

ffffffffc0201ab6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201ab6:	00004797          	auipc	a5,0x4
ffffffffc0201aba:	82a78793          	addi	a5,a5,-2006 # ffffffffc02052e0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201abe:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ac0:	7159                	addi	sp,sp,-112
ffffffffc0201ac2:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ac4:	00004517          	auipc	a0,0x4
ffffffffc0201ac8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02053a8 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201acc:	00010b97          	auipc	s7,0x10
ffffffffc0201ad0:	a64b8b93          	addi	s7,s7,-1436 # ffffffffc0211530 <pmm_manager>
void pmm_init(void) {
ffffffffc0201ad4:	f486                	sd	ra,104(sp)
ffffffffc0201ad6:	f0a2                	sd	s0,96(sp)
ffffffffc0201ad8:	eca6                	sd	s1,88(sp)
ffffffffc0201ada:	e8ca                	sd	s2,80(sp)
ffffffffc0201adc:	e4ce                	sd	s3,72(sp)
ffffffffc0201ade:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ae0:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201ae4:	e0d2                	sd	s4,64(sp)
ffffffffc0201ae6:	fc56                	sd	s5,56(sp)
ffffffffc0201ae8:	f062                	sd	s8,32(sp)
ffffffffc0201aea:	ec66                	sd	s9,24(sp)
ffffffffc0201aec:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201aee:	dccfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201af2:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201af6:	4445                	li	s0,17
ffffffffc0201af8:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201afc:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201afe:	00010997          	auipc	s3,0x10
ffffffffc0201b02:	a3a98993          	addi	s3,s3,-1478 # ffffffffc0211538 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b06:	00010497          	auipc	s1,0x10
ffffffffc0201b0a:	a1a48493          	addi	s1,s1,-1510 # ffffffffc0211520 <npage>
    pmm_manager->init();
ffffffffc0201b0e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b10:	57f5                	li	a5,-3
ffffffffc0201b12:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b14:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b18:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b1c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b20:	00004517          	auipc	a0,0x4
ffffffffc0201b24:	8a050513          	addi	a0,a0,-1888 # ffffffffc02053c0 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b28:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b2c:	d8efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b30:	00004517          	auipc	a0,0x4
ffffffffc0201b34:	8c050513          	addi	a0,a0,-1856 # ffffffffc02053f0 <default_pmm_manager+0x110>
ffffffffc0201b38:	d82fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b3c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b40:	16fd                	addi	a3,a3,-1
ffffffffc0201b42:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b46:	01591613          	slli	a2,s2,0x15
ffffffffc0201b4a:	00004517          	auipc	a0,0x4
ffffffffc0201b4e:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205408 <default_pmm_manager+0x128>
ffffffffc0201b52:	d68fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b56:	777d                	lui	a4,0xfffff
ffffffffc0201b58:	00011797          	auipc	a5,0x11
ffffffffc0201b5c:	a1378793          	addi	a5,a5,-1517 # ffffffffc021256b <end+0xfff>
ffffffffc0201b60:	8ff9                	and	a5,a5,a4
ffffffffc0201b62:	00010b17          	auipc	s6,0x10
ffffffffc0201b66:	9c6b0b13          	addi	s6,s6,-1594 # ffffffffc0211528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b6a:	00088737          	lui	a4,0x88
ffffffffc0201b6e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b70:	00fb3023          	sd	a5,0(s6)
ffffffffc0201b74:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b76:	4701                	li	a4,0
ffffffffc0201b78:	4505                	li	a0,1
ffffffffc0201b7a:	fff805b7          	lui	a1,0xfff80
ffffffffc0201b7e:	a019                	j	ffffffffc0201b84 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201b80:	000b3783          	ld	a5,0(s6)
ffffffffc0201b84:	97b6                	add	a5,a5,a3
ffffffffc0201b86:	07a1                	addi	a5,a5,8
ffffffffc0201b88:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b8c:	609c                	ld	a5,0(s1)
ffffffffc0201b8e:	0705                	addi	a4,a4,1
ffffffffc0201b90:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201b94:	00b78633          	add	a2,a5,a1
ffffffffc0201b98:	fec764e3          	bltu	a4,a2,ffffffffc0201b80 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201b9c:	000b3503          	ld	a0,0(s6)
ffffffffc0201ba0:	00379693          	slli	a3,a5,0x3
ffffffffc0201ba4:	96be                	add	a3,a3,a5
ffffffffc0201ba6:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201baa:	972a                	add	a4,a4,a0
ffffffffc0201bac:	068e                	slli	a3,a3,0x3
ffffffffc0201bae:	96ba                	add	a3,a3,a4
ffffffffc0201bb0:	c0200737          	lui	a4,0xc0200
ffffffffc0201bb4:	64e6e463          	bltu	a3,a4,ffffffffc02021fc <pmm_init+0x746>
ffffffffc0201bb8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bbc:	4645                	li	a2,17
ffffffffc0201bbe:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bc0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201bc2:	4ec6e263          	bltu	a3,a2,ffffffffc02020a6 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bc6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bca:	00010917          	auipc	s2,0x10
ffffffffc0201bce:	94e90913          	addi	s2,s2,-1714 # ffffffffc0211518 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201bd2:	7b9c                	ld	a5,48(a5)
ffffffffc0201bd4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201bd6:	00004517          	auipc	a0,0x4
ffffffffc0201bda:	88250513          	addi	a0,a0,-1918 # ffffffffc0205458 <default_pmm_manager+0x178>
ffffffffc0201bde:	cdcfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201be2:	00007697          	auipc	a3,0x7
ffffffffc0201be6:	41e68693          	addi	a3,a3,1054 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201bea:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201bee:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bf2:	62f6e163          	bltu	a3,a5,ffffffffc0202214 <pmm_init+0x75e>
ffffffffc0201bf6:	0009b783          	ld	a5,0(s3)
ffffffffc0201bfa:	8e9d                	sub	a3,a3,a5
ffffffffc0201bfc:	00010797          	auipc	a5,0x10
ffffffffc0201c00:	90d7ba23          	sd	a3,-1772(a5) # ffffffffc0211510 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c04:	100027f3          	csrr	a5,sstatus
ffffffffc0201c08:	8b89                	andi	a5,a5,2
ffffffffc0201c0a:	4c079763          	bnez	a5,ffffffffc02020d8 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c0e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c12:	779c                	ld	a5,40(a5)
ffffffffc0201c14:	9782                	jalr	a5
ffffffffc0201c16:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c18:	6098                	ld	a4,0(s1)
ffffffffc0201c1a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c1e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c20:	62e7e663          	bltu	a5,a4,ffffffffc020224c <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c24:	00093503          	ld	a0,0(s2)
ffffffffc0201c28:	60050263          	beqz	a0,ffffffffc020222c <pmm_init+0x776>
ffffffffc0201c2c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c30:	5e079e63          	bnez	a5,ffffffffc020222c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c34:	4601                	li	a2,0
ffffffffc0201c36:	4581                	li	a1,0
ffffffffc0201c38:	c8bff0ef          	jal	ra,ffffffffc02018c2 <get_page>
ffffffffc0201c3c:	66051a63          	bnez	a0,ffffffffc02022b0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c40:	4505                	li	a0,1
ffffffffc0201c42:	97fff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0201c46:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c48:	00093503          	ld	a0,0(s2)
ffffffffc0201c4c:	4681                	li	a3,0
ffffffffc0201c4e:	4601                	li	a2,0
ffffffffc0201c50:	85d2                	mv	a1,s4
ffffffffc0201c52:	d65ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201c56:	62051d63          	bnez	a0,ffffffffc0202290 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c5a:	00093503          	ld	a0,0(s2)
ffffffffc0201c5e:	4601                	li	a2,0
ffffffffc0201c60:	4581                	li	a1,0
ffffffffc0201c62:	a6bff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201c66:	60050563          	beqz	a0,ffffffffc0202270 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c6a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c6c:	0017f713          	andi	a4,a5,1
ffffffffc0201c70:	5e070e63          	beqz	a4,ffffffffc020226c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201c74:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c76:	078a                	slli	a5,a5,0x2
ffffffffc0201c78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c7a:	56c7ff63          	bgeu	a5,a2,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c7e:	fff80737          	lui	a4,0xfff80
ffffffffc0201c82:	97ba                	add	a5,a5,a4
ffffffffc0201c84:	000b3683          	ld	a3,0(s6)
ffffffffc0201c88:	00379713          	slli	a4,a5,0x3
ffffffffc0201c8c:	97ba                	add	a5,a5,a4
ffffffffc0201c8e:	078e                	slli	a5,a5,0x3
ffffffffc0201c90:	97b6                	add	a5,a5,a3
ffffffffc0201c92:	14fa18e3          	bne	s4,a5,ffffffffc02025e2 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201c96:	000a2703          	lw	a4,0(s4)
ffffffffc0201c9a:	4785                	li	a5,1
ffffffffc0201c9c:	16f71fe3          	bne	a4,a5,ffffffffc020261a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ca0:	00093503          	ld	a0,0(s2)
ffffffffc0201ca4:	77fd                	lui	a5,0xfffff
ffffffffc0201ca6:	6114                	ld	a3,0(a0)
ffffffffc0201ca8:	068a                	slli	a3,a3,0x2
ffffffffc0201caa:	8efd                	and	a3,a3,a5
ffffffffc0201cac:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cb0:	14c779e3          	bgeu	a4,a2,ffffffffc0202602 <pmm_init+0xb4c>
ffffffffc0201cb4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cb8:	96e2                	add	a3,a3,s8
ffffffffc0201cba:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cbe:	0a8a                	slli	s5,s5,0x2
ffffffffc0201cc0:	00fafab3          	and	s5,s5,a5
ffffffffc0201cc4:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cc8:	66c7f463          	bgeu	a5,a2,ffffffffc0202330 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ccc:	4601                	li	a2,0
ffffffffc0201cce:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cd0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cd2:	9fbff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cd6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cd8:	63551c63          	bne	a0,s5,ffffffffc0202310 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201cdc:	4505                	li	a0,1
ffffffffc0201cde:	8e3ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0201ce2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201ce4:	00093503          	ld	a0,0(s2)
ffffffffc0201ce8:	46d1                	li	a3,20
ffffffffc0201cea:	6605                	lui	a2,0x1
ffffffffc0201cec:	85d6                	mv	a1,s5
ffffffffc0201cee:	cc9ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201cf2:	5c051f63          	bnez	a0,ffffffffc02022d0 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201cf6:	00093503          	ld	a0,0(s2)
ffffffffc0201cfa:	4601                	li	a2,0
ffffffffc0201cfc:	6585                	lui	a1,0x1
ffffffffc0201cfe:	9cfff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201d02:	12050ce3          	beqz	a0,ffffffffc020263a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201d06:	611c                	ld	a5,0(a0)
ffffffffc0201d08:	0107f713          	andi	a4,a5,16
ffffffffc0201d0c:	72070f63          	beqz	a4,ffffffffc020244a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d10:	8b91                	andi	a5,a5,4
ffffffffc0201d12:	6e078c63          	beqz	a5,ffffffffc020240a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d16:	00093503          	ld	a0,0(s2)
ffffffffc0201d1a:	611c                	ld	a5,0(a0)
ffffffffc0201d1c:	8bc1                	andi	a5,a5,16
ffffffffc0201d1e:	6c078663          	beqz	a5,ffffffffc02023ea <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d22:	000aa703          	lw	a4,0(s5)
ffffffffc0201d26:	4785                	li	a5,1
ffffffffc0201d28:	5cf71463          	bne	a4,a5,ffffffffc02022f0 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d2c:	4681                	li	a3,0
ffffffffc0201d2e:	6605                	lui	a2,0x1
ffffffffc0201d30:	85d2                	mv	a1,s4
ffffffffc0201d32:	c85ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201d36:	66051a63          	bnez	a0,ffffffffc02023aa <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d3a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d3e:	4789                	li	a5,2
ffffffffc0201d40:	64f71563          	bne	a4,a5,ffffffffc020238a <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201d44:	000aa783          	lw	a5,0(s5)
ffffffffc0201d48:	62079163          	bnez	a5,ffffffffc020236a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d4c:	00093503          	ld	a0,0(s2)
ffffffffc0201d50:	4601                	li	a2,0
ffffffffc0201d52:	6585                	lui	a1,0x1
ffffffffc0201d54:	979ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201d58:	5e050963          	beqz	a0,ffffffffc020234a <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d5c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d5e:	00177793          	andi	a5,a4,1
ffffffffc0201d62:	50078563          	beqz	a5,ffffffffc020226c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d66:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d68:	00271793          	slli	a5,a4,0x2
ffffffffc0201d6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d6e:	48d7f563          	bgeu	a5,a3,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d72:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d76:	97b6                	add	a5,a5,a3
ffffffffc0201d78:	000b3603          	ld	a2,0(s6)
ffffffffc0201d7c:	00379693          	slli	a3,a5,0x3
ffffffffc0201d80:	97b6                	add	a5,a5,a3
ffffffffc0201d82:	078e                	slli	a5,a5,0x3
ffffffffc0201d84:	97b2                	add	a5,a5,a2
ffffffffc0201d86:	72fa1263          	bne	s4,a5,ffffffffc02024aa <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201d8a:	8b41                	andi	a4,a4,16
ffffffffc0201d8c:	6e071f63          	bnez	a4,ffffffffc020248a <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201d90:	00093503          	ld	a0,0(s2)
ffffffffc0201d94:	4581                	li	a1,0
ffffffffc0201d96:	b87ff0ef          	jal	ra,ffffffffc020191c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201d9a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d9e:	4785                	li	a5,1
ffffffffc0201da0:	6cf71563          	bne	a4,a5,ffffffffc020246a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201da4:	000aa783          	lw	a5,0(s5)
ffffffffc0201da8:	78079d63          	bnez	a5,ffffffffc0202542 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dac:	00093503          	ld	a0,0(s2)
ffffffffc0201db0:	6585                	lui	a1,0x1
ffffffffc0201db2:	b6bff0ef          	jal	ra,ffffffffc020191c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201db6:	000a2783          	lw	a5,0(s4)
ffffffffc0201dba:	76079463          	bnez	a5,ffffffffc0202522 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201dbe:	000aa783          	lw	a5,0(s5)
ffffffffc0201dc2:	74079063          	bnez	a5,ffffffffc0202502 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dc6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201dca:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dcc:	000a3783          	ld	a5,0(s4)
ffffffffc0201dd0:	078a                	slli	a5,a5,0x2
ffffffffc0201dd2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dd4:	42c7f263          	bgeu	a5,a2,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dd8:	fff80737          	lui	a4,0xfff80
ffffffffc0201ddc:	973e                	add	a4,a4,a5
ffffffffc0201dde:	00371793          	slli	a5,a4,0x3
ffffffffc0201de2:	000b3503          	ld	a0,0(s6)
ffffffffc0201de6:	97ba                	add	a5,a5,a4
ffffffffc0201de8:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201dea:	00f50733          	add	a4,a0,a5
ffffffffc0201dee:	4314                	lw	a3,0(a4)
ffffffffc0201df0:	4705                	li	a4,1
ffffffffc0201df2:	6ee69863          	bne	a3,a4,ffffffffc02024e2 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201df6:	4037d693          	srai	a3,a5,0x3
ffffffffc0201dfa:	00004c97          	auipc	s9,0x4
ffffffffc0201dfe:	6decbc83          	ld	s9,1758(s9) # ffffffffc02064d8 <error_string+0x38>
ffffffffc0201e02:	039686b3          	mul	a3,a3,s9
ffffffffc0201e06:	000805b7          	lui	a1,0x80
ffffffffc0201e0a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e0c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e10:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e12:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e14:	6ac77b63          	bgeu	a4,a2,ffffffffc02024ca <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e18:	0009b703          	ld	a4,0(s3)
ffffffffc0201e1c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e1e:	629c                	ld	a5,0(a3)
ffffffffc0201e20:	078a                	slli	a5,a5,0x2
ffffffffc0201e22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e24:	3cc7fa63          	bgeu	a5,a2,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e28:	8f8d                	sub	a5,a5,a1
ffffffffc0201e2a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e2e:	97ba                	add	a5,a5,a4
ffffffffc0201e30:	078e                	slli	a5,a5,0x3
ffffffffc0201e32:	953e                	add	a0,a0,a5
ffffffffc0201e34:	100027f3          	csrr	a5,sstatus
ffffffffc0201e38:	8b89                	andi	a5,a5,2
ffffffffc0201e3a:	2e079963          	bnez	a5,ffffffffc020212c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e3e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e42:	4585                	li	a1,1
ffffffffc0201e44:	739c                	ld	a5,32(a5)
ffffffffc0201e46:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e48:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e4c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4e:	078a                	slli	a5,a5,0x2
ffffffffc0201e50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e52:	3ae7f363          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e56:	fff80737          	lui	a4,0xfff80
ffffffffc0201e5a:	97ba                	add	a5,a5,a4
ffffffffc0201e5c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e60:	00379713          	slli	a4,a5,0x3
ffffffffc0201e64:	97ba                	add	a5,a5,a4
ffffffffc0201e66:	078e                	slli	a5,a5,0x3
ffffffffc0201e68:	953e                	add	a0,a0,a5
ffffffffc0201e6a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e6e:	8b89                	andi	a5,a5,2
ffffffffc0201e70:	2a079263          	bnez	a5,ffffffffc0202114 <pmm_init+0x65e>
ffffffffc0201e74:	000bb783          	ld	a5,0(s7)
ffffffffc0201e78:	4585                	li	a1,1
ffffffffc0201e7a:	739c                	ld	a5,32(a5)
ffffffffc0201e7c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201e7e:	00093783          	ld	a5,0(s2)
ffffffffc0201e82:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201e86:	100027f3          	csrr	a5,sstatus
ffffffffc0201e8a:	8b89                	andi	a5,a5,2
ffffffffc0201e8c:	26079a63          	bnez	a5,ffffffffc0202100 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201e90:	000bb783          	ld	a5,0(s7)
ffffffffc0201e94:	779c                	ld	a5,40(a5)
ffffffffc0201e96:	9782                	jalr	a5
ffffffffc0201e98:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201e9a:	73441463          	bne	s0,s4,ffffffffc02025c2 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201e9e:	00004517          	auipc	a0,0x4
ffffffffc0201ea2:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205740 <default_pmm_manager+0x460>
ffffffffc0201ea6:	a14fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eaa:	100027f3          	csrr	a5,sstatus
ffffffffc0201eae:	8b89                	andi	a5,a5,2
ffffffffc0201eb0:	22079e63          	bnez	a5,ffffffffc02020ec <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201eb4:	000bb783          	ld	a5,0(s7)
ffffffffc0201eb8:	779c                	ld	a5,40(a5)
ffffffffc0201eba:	9782                	jalr	a5
ffffffffc0201ebc:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ebe:	6098                	ld	a4,0(s1)
ffffffffc0201ec0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ec4:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ec6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201eca:	6a05                	lui	s4,0x1
ffffffffc0201ecc:	02f47c63          	bgeu	s0,a5,ffffffffc0201f04 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ed0:	00c45793          	srli	a5,s0,0xc
ffffffffc0201ed4:	00093503          	ld	a0,0(s2)
ffffffffc0201ed8:	30e7f363          	bgeu	a5,a4,ffffffffc02021de <pmm_init+0x728>
ffffffffc0201edc:	0009b583          	ld	a1,0(s3)
ffffffffc0201ee0:	4601                	li	a2,0
ffffffffc0201ee2:	95a2                	add	a1,a1,s0
ffffffffc0201ee4:	fe8ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201ee8:	2c050b63          	beqz	a0,ffffffffc02021be <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201eec:	611c                	ld	a5,0(a0)
ffffffffc0201eee:	078a                	slli	a5,a5,0x2
ffffffffc0201ef0:	0157f7b3          	and	a5,a5,s5
ffffffffc0201ef4:	2a879563          	bne	a5,s0,ffffffffc020219e <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ef8:	6098                	ld	a4,0(s1)
ffffffffc0201efa:	9452                	add	s0,s0,s4
ffffffffc0201efc:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f00:	fcf468e3          	bltu	s0,a5,ffffffffc0201ed0 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f04:	00093783          	ld	a5,0(s2)
ffffffffc0201f08:	639c                	ld	a5,0(a5)
ffffffffc0201f0a:	68079c63          	bnez	a5,ffffffffc02025a2 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f0e:	4505                	li	a0,1
ffffffffc0201f10:	eb0ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0201f14:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f16:	00093503          	ld	a0,0(s2)
ffffffffc0201f1a:	4699                	li	a3,6
ffffffffc0201f1c:	10000613          	li	a2,256
ffffffffc0201f20:	85d6                	mv	a1,s5
ffffffffc0201f22:	a95ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201f26:	64051e63          	bnez	a0,ffffffffc0202582 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f2a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201f2e:	4785                	li	a5,1
ffffffffc0201f30:	62f71963          	bne	a4,a5,ffffffffc0202562 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f34:	00093503          	ld	a0,0(s2)
ffffffffc0201f38:	6405                	lui	s0,0x1
ffffffffc0201f3a:	4699                	li	a3,6
ffffffffc0201f3c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f40:	85d6                	mv	a1,s5
ffffffffc0201f42:	a75ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201f46:	48051263          	bnez	a0,ffffffffc02023ca <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f4a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f4e:	4789                	li	a5,2
ffffffffc0201f50:	74f71563          	bne	a4,a5,ffffffffc020269a <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f54:	00004597          	auipc	a1,0x4
ffffffffc0201f58:	92458593          	addi	a1,a1,-1756 # ffffffffc0205878 <default_pmm_manager+0x598>
ffffffffc0201f5c:	10000513          	li	a0,256
ffffffffc0201f60:	5ce020ef          	jal	ra,ffffffffc020452e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f64:	10040593          	addi	a1,s0,256
ffffffffc0201f68:	10000513          	li	a0,256
ffffffffc0201f6c:	5d4020ef          	jal	ra,ffffffffc0204540 <strcmp>
ffffffffc0201f70:	70051563          	bnez	a0,ffffffffc020267a <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f74:	000b3683          	ld	a3,0(s6)
ffffffffc0201f78:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f7c:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f7e:	40da86b3          	sub	a3,s5,a3
ffffffffc0201f82:	868d                	srai	a3,a3,0x3
ffffffffc0201f84:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f88:	609c                	ld	a5,0(s1)
ffffffffc0201f8a:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f8c:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f8e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f92:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f94:	52f77b63          	bgeu	a4,a5,ffffffffc02024ca <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f98:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f9c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fa0:	96be                	add	a3,a3,a5
ffffffffc0201fa2:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb94>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fa6:	552020ef          	jal	ra,ffffffffc02044f8 <strlen>
ffffffffc0201faa:	6a051863          	bnez	a0,ffffffffc020265a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fae:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fb2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fb4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fb8:	078a                	slli	a5,a5,0x2
ffffffffc0201fba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fbc:	22e7fe63          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc0:	41a787b3          	sub	a5,a5,s10
ffffffffc0201fc4:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fc8:	96be                	add	a3,a3,a5
ffffffffc0201fca:	03968cb3          	mul	s9,a3,s9
ffffffffc0201fce:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd6:	4ee47a63          	bgeu	s0,a4,ffffffffc02024ca <pmm_init+0xa14>
ffffffffc0201fda:	0009b403          	ld	s0,0(s3)
ffffffffc0201fde:	9436                	add	s0,s0,a3
ffffffffc0201fe0:	100027f3          	csrr	a5,sstatus
ffffffffc0201fe4:	8b89                	andi	a5,a5,2
ffffffffc0201fe6:	1a079163          	bnez	a5,ffffffffc0202188 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201fea:	000bb783          	ld	a5,0(s7)
ffffffffc0201fee:	4585                	li	a1,1
ffffffffc0201ff0:	8556                	mv	a0,s5
ffffffffc0201ff2:	739c                	ld	a5,32(a5)
ffffffffc0201ff4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ff6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201ff8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ffa:	078a                	slli	a5,a5,0x2
ffffffffc0201ffc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ffe:	1ee7fd63          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202002:	fff80737          	lui	a4,0xfff80
ffffffffc0202006:	97ba                	add	a5,a5,a4
ffffffffc0202008:	000b3503          	ld	a0,0(s6)
ffffffffc020200c:	00379713          	slli	a4,a5,0x3
ffffffffc0202010:	97ba                	add	a5,a5,a4
ffffffffc0202012:	078e                	slli	a5,a5,0x3
ffffffffc0202014:	953e                	add	a0,a0,a5
ffffffffc0202016:	100027f3          	csrr	a5,sstatus
ffffffffc020201a:	8b89                	andi	a5,a5,2
ffffffffc020201c:	14079a63          	bnez	a5,ffffffffc0202170 <pmm_init+0x6ba>
ffffffffc0202020:	000bb783          	ld	a5,0(s7)
ffffffffc0202024:	4585                	li	a1,1
ffffffffc0202026:	739c                	ld	a5,32(a5)
ffffffffc0202028:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020202a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020202e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202030:	078a                	slli	a5,a5,0x2
ffffffffc0202032:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202034:	1ce7f263          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202038:	fff80737          	lui	a4,0xfff80
ffffffffc020203c:	97ba                	add	a5,a5,a4
ffffffffc020203e:	000b3503          	ld	a0,0(s6)
ffffffffc0202042:	00379713          	slli	a4,a5,0x3
ffffffffc0202046:	97ba                	add	a5,a5,a4
ffffffffc0202048:	078e                	slli	a5,a5,0x3
ffffffffc020204a:	953e                	add	a0,a0,a5
ffffffffc020204c:	100027f3          	csrr	a5,sstatus
ffffffffc0202050:	8b89                	andi	a5,a5,2
ffffffffc0202052:	10079363          	bnez	a5,ffffffffc0202158 <pmm_init+0x6a2>
ffffffffc0202056:	000bb783          	ld	a5,0(s7)
ffffffffc020205a:	4585                	li	a1,1
ffffffffc020205c:	739c                	ld	a5,32(a5)
ffffffffc020205e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202060:	00093783          	ld	a5,0(s2)
ffffffffc0202064:	0007b023          	sd	zero,0(a5)
ffffffffc0202068:	100027f3          	csrr	a5,sstatus
ffffffffc020206c:	8b89                	andi	a5,a5,2
ffffffffc020206e:	0c079b63          	bnez	a5,ffffffffc0202144 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202072:	000bb783          	ld	a5,0(s7)
ffffffffc0202076:	779c                	ld	a5,40(a5)
ffffffffc0202078:	9782                	jalr	a5
ffffffffc020207a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020207c:	3a8c1763          	bne	s8,s0,ffffffffc020242a <pmm_init+0x974>
}
ffffffffc0202080:	7406                	ld	s0,96(sp)
ffffffffc0202082:	70a6                	ld	ra,104(sp)
ffffffffc0202084:	64e6                	ld	s1,88(sp)
ffffffffc0202086:	6946                	ld	s2,80(sp)
ffffffffc0202088:	69a6                	ld	s3,72(sp)
ffffffffc020208a:	6a06                	ld	s4,64(sp)
ffffffffc020208c:	7ae2                	ld	s5,56(sp)
ffffffffc020208e:	7b42                	ld	s6,48(sp)
ffffffffc0202090:	7ba2                	ld	s7,40(sp)
ffffffffc0202092:	7c02                	ld	s8,32(sp)
ffffffffc0202094:	6ce2                	ld	s9,24(sp)
ffffffffc0202096:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202098:	00004517          	auipc	a0,0x4
ffffffffc020209c:	85850513          	addi	a0,a0,-1960 # ffffffffc02058f0 <default_pmm_manager+0x610>
}
ffffffffc02020a0:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020a2:	818fe06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020a6:	6705                	lui	a4,0x1
ffffffffc02020a8:	177d                	addi	a4,a4,-1
ffffffffc02020aa:	96ba                	add	a3,a3,a4
ffffffffc02020ac:	777d                	lui	a4,0xfffff
ffffffffc02020ae:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020b0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020b4:	14f6f263          	bgeu	a3,a5,ffffffffc02021f8 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020b8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020bc:	95b6                	add	a1,a1,a3
ffffffffc02020be:	00359793          	slli	a5,a1,0x3
ffffffffc02020c2:	97ae                	add	a5,a5,a1
ffffffffc02020c4:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020c8:	40e60733          	sub	a4,a2,a4
ffffffffc02020cc:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020ce:	00c75593          	srli	a1,a4,0xc
ffffffffc02020d2:	953e                	add	a0,a0,a5
ffffffffc02020d4:	9682                	jalr	a3
}
ffffffffc02020d6:	bcc5                	j	ffffffffc0201bc6 <pmm_init+0x110>
        intr_disable();
ffffffffc02020d8:	c16fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020dc:	000bb783          	ld	a5,0(s7)
ffffffffc02020e0:	779c                	ld	a5,40(a5)
ffffffffc02020e2:	9782                	jalr	a5
ffffffffc02020e4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02020e6:	c02fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02020ea:	b63d                	j	ffffffffc0201c18 <pmm_init+0x162>
        intr_disable();
ffffffffc02020ec:	c02fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02020f0:	000bb783          	ld	a5,0(s7)
ffffffffc02020f4:	779c                	ld	a5,40(a5)
ffffffffc02020f6:	9782                	jalr	a5
ffffffffc02020f8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02020fa:	beefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02020fe:	b3c1                	j	ffffffffc0201ebe <pmm_init+0x408>
        intr_disable();
ffffffffc0202100:	beefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202104:	000bb783          	ld	a5,0(s7)
ffffffffc0202108:	779c                	ld	a5,40(a5)
ffffffffc020210a:	9782                	jalr	a5
ffffffffc020210c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020210e:	bdafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202112:	b361                	j	ffffffffc0201e9a <pmm_init+0x3e4>
ffffffffc0202114:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202116:	bd8fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020211a:	000bb783          	ld	a5,0(s7)
ffffffffc020211e:	6522                	ld	a0,8(sp)
ffffffffc0202120:	4585                	li	a1,1
ffffffffc0202122:	739c                	ld	a5,32(a5)
ffffffffc0202124:	9782                	jalr	a5
        intr_enable();
ffffffffc0202126:	bc2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020212a:	bb91                	j	ffffffffc0201e7e <pmm_init+0x3c8>
ffffffffc020212c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020212e:	bc0fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202132:	000bb783          	ld	a5,0(s7)
ffffffffc0202136:	6522                	ld	a0,8(sp)
ffffffffc0202138:	4585                	li	a1,1
ffffffffc020213a:	739c                	ld	a5,32(a5)
ffffffffc020213c:	9782                	jalr	a5
        intr_enable();
ffffffffc020213e:	baafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202142:	b319                	j	ffffffffc0201e48 <pmm_init+0x392>
        intr_disable();
ffffffffc0202144:	baafe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202148:	000bb783          	ld	a5,0(s7)
ffffffffc020214c:	779c                	ld	a5,40(a5)
ffffffffc020214e:	9782                	jalr	a5
ffffffffc0202150:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202152:	b96fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202156:	b71d                	j	ffffffffc020207c <pmm_init+0x5c6>
ffffffffc0202158:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020215a:	b94fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020215e:	000bb783          	ld	a5,0(s7)
ffffffffc0202162:	6522                	ld	a0,8(sp)
ffffffffc0202164:	4585                	li	a1,1
ffffffffc0202166:	739c                	ld	a5,32(a5)
ffffffffc0202168:	9782                	jalr	a5
        intr_enable();
ffffffffc020216a:	b7efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020216e:	bdcd                	j	ffffffffc0202060 <pmm_init+0x5aa>
ffffffffc0202170:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202172:	b7cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202176:	000bb783          	ld	a5,0(s7)
ffffffffc020217a:	6522                	ld	a0,8(sp)
ffffffffc020217c:	4585                	li	a1,1
ffffffffc020217e:	739c                	ld	a5,32(a5)
ffffffffc0202180:	9782                	jalr	a5
        intr_enable();
ffffffffc0202182:	b66fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202186:	b555                	j	ffffffffc020202a <pmm_init+0x574>
        intr_disable();
ffffffffc0202188:	b66fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020218c:	000bb783          	ld	a5,0(s7)
ffffffffc0202190:	4585                	li	a1,1
ffffffffc0202192:	8556                	mv	a0,s5
ffffffffc0202194:	739c                	ld	a5,32(a5)
ffffffffc0202196:	9782                	jalr	a5
        intr_enable();
ffffffffc0202198:	b50fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020219c:	bda9                	j	ffffffffc0201ff6 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020219e:	00003697          	auipc	a3,0x3
ffffffffc02021a2:	60268693          	addi	a3,a3,1538 # ffffffffc02057a0 <default_pmm_manager+0x4c0>
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	d8a60613          	addi	a2,a2,-630 # ffffffffc0204f30 <commands+0x738>
ffffffffc02021ae:	1ce00593          	li	a1,462
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	1e650513          	addi	a0,a0,486 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	5a268693          	addi	a3,a3,1442 # ffffffffc0205760 <default_pmm_manager+0x480>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	d6a60613          	addi	a2,a2,-662 # ffffffffc0204f30 <commands+0x738>
ffffffffc02021ce:	1cd00593          	li	a1,461
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	1c650513          	addi	a0,a0,454 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02021da:	99afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021de:	86a2                	mv	a3,s0
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	19060613          	addi	a2,a2,400 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc02021e8:	1cd00593          	li	a1,461
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	1ac50513          	addi	a0,a0,428 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02021f4:	980fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021f8:	b90ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021fc:	00003617          	auipc	a2,0x3
ffffffffc0202200:	23460613          	addi	a2,a2,564 # ffffffffc0205430 <default_pmm_manager+0x150>
ffffffffc0202204:	07700593          	li	a1,119
ffffffffc0202208:	00003517          	auipc	a0,0x3
ffffffffc020220c:	19050513          	addi	a0,a0,400 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202210:	964fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202214:	00003617          	auipc	a2,0x3
ffffffffc0202218:	21c60613          	addi	a2,a2,540 # ffffffffc0205430 <default_pmm_manager+0x150>
ffffffffc020221c:	0bd00593          	li	a1,189
ffffffffc0202220:	00003517          	auipc	a0,0x3
ffffffffc0202224:	17850513          	addi	a0,a0,376 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202228:	94cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020222c:	00003697          	auipc	a3,0x3
ffffffffc0202230:	26c68693          	addi	a3,a3,620 # ffffffffc0205498 <default_pmm_manager+0x1b8>
ffffffffc0202234:	00003617          	auipc	a2,0x3
ffffffffc0202238:	cfc60613          	addi	a2,a2,-772 # ffffffffc0204f30 <commands+0x738>
ffffffffc020223c:	19300593          	li	a1,403
ffffffffc0202240:	00003517          	auipc	a0,0x3
ffffffffc0202244:	15850513          	addi	a0,a0,344 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202248:	92cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020224c:	00003697          	auipc	a3,0x3
ffffffffc0202250:	22c68693          	addi	a3,a3,556 # ffffffffc0205478 <default_pmm_manager+0x198>
ffffffffc0202254:	00003617          	auipc	a2,0x3
ffffffffc0202258:	cdc60613          	addi	a2,a2,-804 # ffffffffc0204f30 <commands+0x738>
ffffffffc020225c:	19200593          	li	a1,402
ffffffffc0202260:	00003517          	auipc	a0,0x3
ffffffffc0202264:	13850513          	addi	a0,a0,312 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202268:	90cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020226c:	b38ff0ef          	jal	ra,ffffffffc02015a4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202270:	00003697          	auipc	a3,0x3
ffffffffc0202274:	2b868693          	addi	a3,a3,696 # ffffffffc0205528 <default_pmm_manager+0x248>
ffffffffc0202278:	00003617          	auipc	a2,0x3
ffffffffc020227c:	cb860613          	addi	a2,a2,-840 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202280:	19a00593          	li	a1,410
ffffffffc0202284:	00003517          	auipc	a0,0x3
ffffffffc0202288:	11450513          	addi	a0,a0,276 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020228c:	8e8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202290:	00003697          	auipc	a3,0x3
ffffffffc0202294:	26868693          	addi	a3,a3,616 # ffffffffc02054f8 <default_pmm_manager+0x218>
ffffffffc0202298:	00003617          	auipc	a2,0x3
ffffffffc020229c:	c9860613          	addi	a2,a2,-872 # ffffffffc0204f30 <commands+0x738>
ffffffffc02022a0:	19800593          	li	a1,408
ffffffffc02022a4:	00003517          	auipc	a0,0x3
ffffffffc02022a8:	0f450513          	addi	a0,a0,244 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02022ac:	8c8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022b0:	00003697          	auipc	a3,0x3
ffffffffc02022b4:	22068693          	addi	a3,a3,544 # ffffffffc02054d0 <default_pmm_manager+0x1f0>
ffffffffc02022b8:	00003617          	auipc	a2,0x3
ffffffffc02022bc:	c7860613          	addi	a2,a2,-904 # ffffffffc0204f30 <commands+0x738>
ffffffffc02022c0:	19400593          	li	a1,404
ffffffffc02022c4:	00003517          	auipc	a0,0x3
ffffffffc02022c8:	0d450513          	addi	a0,a0,212 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02022cc:	8a8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	2e068693          	addi	a3,a3,736 # ffffffffc02055b0 <default_pmm_manager+0x2d0>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	c5860613          	addi	a2,a2,-936 # ffffffffc0204f30 <commands+0x738>
ffffffffc02022e0:	1a300593          	li	a1,419
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	0b450513          	addi	a0,a0,180 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02022ec:	888fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	36068693          	addi	a3,a3,864 # ffffffffc0205650 <default_pmm_manager+0x370>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	c3860613          	addi	a2,a2,-968 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202300:	1a800593          	li	a1,424
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	09450513          	addi	a0,a0,148 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	27868693          	addi	a3,a3,632 # ffffffffc0205588 <default_pmm_manager+0x2a8>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	c1860613          	addi	a2,a2,-1000 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202320:	1a000593          	li	a1,416
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	07450513          	addi	a0,a0,116 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020232c:	848fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202330:	86d6                	mv	a3,s5
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	03e60613          	addi	a2,a2,62 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc020233a:	19f00593          	li	a1,415
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	05a50513          	addi	a0,a0,90 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	29e68693          	addi	a3,a3,670 # ffffffffc02055e8 <default_pmm_manager+0x308>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	bde60613          	addi	a2,a2,-1058 # ffffffffc0204f30 <commands+0x738>
ffffffffc020235a:	1ad00593          	li	a1,429
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	03a50513          	addi	a0,a0,58 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	34668693          	addi	a3,a3,838 # ffffffffc02056b0 <default_pmm_manager+0x3d0>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0204f30 <commands+0x738>
ffffffffc020237a:	1ac00593          	li	a1,428
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	01a50513          	addi	a0,a0,26 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	30e68693          	addi	a3,a3,782 # ffffffffc0205698 <default_pmm_manager+0x3b8>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0204f30 <commands+0x738>
ffffffffc020239a:	1ab00593          	li	a1,427
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	ffa50513          	addi	a0,a0,-6 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	2be68693          	addi	a3,a3,702 # ffffffffc0205668 <default_pmm_manager+0x388>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0204f30 <commands+0x738>
ffffffffc02023ba:	1aa00593          	li	a1,426
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	fda50513          	addi	a0,a0,-38 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	45668693          	addi	a3,a3,1110 # ffffffffc0205820 <default_pmm_manager+0x540>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0204f30 <commands+0x738>
ffffffffc02023da:	1d800593          	li	a1,472
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	fba50513          	addi	a0,a0,-70 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	24e68693          	addi	a3,a3,590 # ffffffffc0205638 <default_pmm_manager+0x358>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0204f30 <commands+0x738>
ffffffffc02023fa:	1a700593          	li	a1,423
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	f9a50513          	addi	a0,a0,-102 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	21e68693          	addi	a3,a3,542 # ffffffffc0205628 <default_pmm_manager+0x348>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0204f30 <commands+0x738>
ffffffffc020241a:	1a600593          	li	a1,422
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	f7a50513          	addi	a0,a0,-134 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	2f668693          	addi	a3,a3,758 # ffffffffc0205720 <default_pmm_manager+0x440>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	afe60613          	addi	a2,a2,-1282 # ffffffffc0204f30 <commands+0x738>
ffffffffc020243a:	1e800593          	li	a1,488
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	f5a50513          	addi	a0,a0,-166 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	1ce68693          	addi	a3,a3,462 # ffffffffc0205618 <default_pmm_manager+0x338>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	ade60613          	addi	a2,a2,-1314 # ffffffffc0204f30 <commands+0x738>
ffffffffc020245a:	1a500593          	li	a1,421
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	f3a50513          	addi	a0,a0,-198 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	10668693          	addi	a3,a3,262 # ffffffffc0205570 <default_pmm_manager+0x290>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	abe60613          	addi	a2,a2,-1346 # ffffffffc0204f30 <commands+0x738>
ffffffffc020247a:	1b200593          	li	a1,434
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	f1a50513          	addi	a0,a0,-230 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	23e68693          	addi	a3,a3,574 # ffffffffc02056c8 <default_pmm_manager+0x3e8>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0204f30 <commands+0x738>
ffffffffc020249a:	1af00593          	li	a1,431
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	efa50513          	addi	a0,a0,-262 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	0ae68693          	addi	a3,a3,174 # ffffffffc0205558 <default_pmm_manager+0x278>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204f30 <commands+0x738>
ffffffffc02024ba:	1ae00593          	li	a1,430
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	eda50513          	addi	a0,a0,-294 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02024ca:	00003617          	auipc	a2,0x3
ffffffffc02024ce:	ea660613          	addi	a2,a2,-346 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc02024d2:	06a00593          	li	a1,106
ffffffffc02024d6:	00003517          	auipc	a0,0x3
ffffffffc02024da:	e6250513          	addi	a0,a0,-414 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc02024de:	e97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024e2:	00003697          	auipc	a3,0x3
ffffffffc02024e6:	21668693          	addi	a3,a3,534 # ffffffffc02056f8 <default_pmm_manager+0x418>
ffffffffc02024ea:	00003617          	auipc	a2,0x3
ffffffffc02024ee:	a4660613          	addi	a2,a2,-1466 # ffffffffc0204f30 <commands+0x738>
ffffffffc02024f2:	1b900593          	li	a1,441
ffffffffc02024f6:	00003517          	auipc	a0,0x3
ffffffffc02024fa:	ea250513          	addi	a0,a0,-350 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02024fe:	e77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202502:	00003697          	auipc	a3,0x3
ffffffffc0202506:	1ae68693          	addi	a3,a3,430 # ffffffffc02056b0 <default_pmm_manager+0x3d0>
ffffffffc020250a:	00003617          	auipc	a2,0x3
ffffffffc020250e:	a2660613          	addi	a2,a2,-1498 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202512:	1b700593          	li	a1,439
ffffffffc0202516:	00003517          	auipc	a0,0x3
ffffffffc020251a:	e8250513          	addi	a0,a0,-382 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020251e:	e57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202522:	00003697          	auipc	a3,0x3
ffffffffc0202526:	1be68693          	addi	a3,a3,446 # ffffffffc02056e0 <default_pmm_manager+0x400>
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	a0660613          	addi	a2,a2,-1530 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202532:	1b600593          	li	a1,438
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	e6250513          	addi	a0,a0,-414 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020253e:	e37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	16e68693          	addi	a3,a3,366 # ffffffffc02056b0 <default_pmm_manager+0x3d0>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	9e660613          	addi	a2,a2,-1562 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202552:	1b300593          	li	a1,435
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	e4250513          	addi	a0,a0,-446 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020255e:	e17fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	2a668693          	addi	a3,a3,678 # ffffffffc0205808 <default_pmm_manager+0x528>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202572:	1d700593          	li	a1,471
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	e2250513          	addi	a0,a0,-478 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	24e68693          	addi	a3,a3,590 # ffffffffc02057d0 <default_pmm_manager+0x4f0>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202592:	1d600593          	li	a1,470
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	e0250513          	addi	a0,a0,-510 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	21668693          	addi	a3,a3,534 # ffffffffc02057b8 <default_pmm_manager+0x4d8>
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	98660613          	addi	a2,a2,-1658 # ffffffffc0204f30 <commands+0x738>
ffffffffc02025b2:	1d200593          	li	a1,466
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	de250513          	addi	a0,a0,-542 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	15e68693          	addi	a3,a3,350 # ffffffffc0205720 <default_pmm_manager+0x440>
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	96660613          	addi	a2,a2,-1690 # ffffffffc0204f30 <commands+0x738>
ffffffffc02025d2:	1c000593          	li	a1,448
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	dc250513          	addi	a0,a0,-574 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	f7668693          	addi	a3,a3,-138 # ffffffffc0205558 <default_pmm_manager+0x278>
ffffffffc02025ea:	00003617          	auipc	a2,0x3
ffffffffc02025ee:	94660613          	addi	a2,a2,-1722 # ffffffffc0204f30 <commands+0x738>
ffffffffc02025f2:	19b00593          	li	a1,411
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	da250513          	addi	a0,a0,-606 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202602:	00003617          	auipc	a2,0x3
ffffffffc0202606:	d6e60613          	addi	a2,a2,-658 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc020260a:	19e00593          	li	a1,414
ffffffffc020260e:	00003517          	auipc	a0,0x3
ffffffffc0202612:	d8a50513          	addi	a0,a0,-630 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202616:	d5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020261a:	00003697          	auipc	a3,0x3
ffffffffc020261e:	f5668693          	addi	a3,a3,-170 # ffffffffc0205570 <default_pmm_manager+0x290>
ffffffffc0202622:	00003617          	auipc	a2,0x3
ffffffffc0202626:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204f30 <commands+0x738>
ffffffffc020262a:	19c00593          	li	a1,412
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202636:	d3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020263a:	00003697          	auipc	a3,0x3
ffffffffc020263e:	fae68693          	addi	a3,a3,-82 # ffffffffc02055e8 <default_pmm_manager+0x308>
ffffffffc0202642:	00003617          	auipc	a2,0x3
ffffffffc0202646:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204f30 <commands+0x738>
ffffffffc020264a:	1a400593          	li	a1,420
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	d4a50513          	addi	a0,a0,-694 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202656:	d1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020265a:	00003697          	auipc	a3,0x3
ffffffffc020265e:	26e68693          	addi	a3,a3,622 # ffffffffc02058c8 <default_pmm_manager+0x5e8>
ffffffffc0202662:	00003617          	auipc	a2,0x3
ffffffffc0202666:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204f30 <commands+0x738>
ffffffffc020266a:	1e000593          	li	a1,480
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	d2a50513          	addi	a0,a0,-726 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202676:	cfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	21668693          	addi	a3,a3,534 # ffffffffc0205890 <default_pmm_manager+0x5b0>
ffffffffc0202682:	00003617          	auipc	a2,0x3
ffffffffc0202686:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204f30 <commands+0x738>
ffffffffc020268a:	1dd00593          	li	a1,477
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	d0a50513          	addi	a0,a0,-758 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202696:	cdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020269a:	00003697          	auipc	a3,0x3
ffffffffc020269e:	1c668693          	addi	a3,a3,454 # ffffffffc0205860 <default_pmm_manager+0x580>
ffffffffc02026a2:	00003617          	auipc	a2,0x3
ffffffffc02026a6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204f30 <commands+0x738>
ffffffffc02026aa:	1d900593          	li	a1,473
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	cea50513          	addi	a0,a0,-790 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02026b6:	cbffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02026ba <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026ba:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026be:	8082                	ret

ffffffffc02026c0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026c0:	7179                	addi	sp,sp,-48
ffffffffc02026c2:	e84a                	sd	s2,16(sp)
ffffffffc02026c4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02026c6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026c8:	f022                	sd	s0,32(sp)
ffffffffc02026ca:	ec26                	sd	s1,24(sp)
ffffffffc02026cc:	e44e                	sd	s3,8(sp)
ffffffffc02026ce:	f406                	sd	ra,40(sp)
ffffffffc02026d0:	84ae                	mv	s1,a1
ffffffffc02026d2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02026d4:	eedfe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc02026d8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02026da:	cd09                	beqz	a0,ffffffffc02026f4 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02026dc:	85aa                	mv	a1,a0
ffffffffc02026de:	86ce                	mv	a3,s3
ffffffffc02026e0:	8626                	mv	a2,s1
ffffffffc02026e2:	854a                	mv	a0,s2
ffffffffc02026e4:	ad2ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc02026e8:	ed21                	bnez	a0,ffffffffc0202740 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc02026ea:	0000f797          	auipc	a5,0xf
ffffffffc02026ee:	e667a783          	lw	a5,-410(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02026f2:	eb89                	bnez	a5,ffffffffc0202704 <pgdir_alloc_page+0x44>
}
ffffffffc02026f4:	70a2                	ld	ra,40(sp)
ffffffffc02026f6:	8522                	mv	a0,s0
ffffffffc02026f8:	7402                	ld	s0,32(sp)
ffffffffc02026fa:	64e2                	ld	s1,24(sp)
ffffffffc02026fc:	6942                	ld	s2,16(sp)
ffffffffc02026fe:	69a2                	ld	s3,8(sp)
ffffffffc0202700:	6145                	addi	sp,sp,48
ffffffffc0202702:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202704:	4681                	li	a3,0
ffffffffc0202706:	8622                	mv	a2,s0
ffffffffc0202708:	85a6                	mv	a1,s1
ffffffffc020270a:	0000f517          	auipc	a0,0xf
ffffffffc020270e:	e5653503          	ld	a0,-426(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0202712:	07f000ef          	jal	ra,ffffffffc0202f90 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202716:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202718:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020271a:	4785                	li	a5,1
ffffffffc020271c:	fcf70ce3          	beq	a4,a5,ffffffffc02026f4 <pgdir_alloc_page+0x34>
ffffffffc0202720:	00003697          	auipc	a3,0x3
ffffffffc0202724:	1f068693          	addi	a3,a3,496 # ffffffffc0205910 <default_pmm_manager+0x630>
ffffffffc0202728:	00003617          	auipc	a2,0x3
ffffffffc020272c:	80860613          	addi	a2,a2,-2040 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202730:	17a00593          	li	a1,378
ffffffffc0202734:	00003517          	auipc	a0,0x3
ffffffffc0202738:	c6450513          	addi	a0,a0,-924 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020273c:	c39fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202740:	100027f3          	csrr	a5,sstatus
ffffffffc0202744:	8b89                	andi	a5,a5,2
ffffffffc0202746:	eb99                	bnez	a5,ffffffffc020275c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202748:	0000f797          	auipc	a5,0xf
ffffffffc020274c:	de87b783          	ld	a5,-536(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202750:	739c                	ld	a5,32(a5)
ffffffffc0202752:	8522                	mv	a0,s0
ffffffffc0202754:	4585                	li	a1,1
ffffffffc0202756:	9782                	jalr	a5
            return NULL;
ffffffffc0202758:	4401                	li	s0,0
ffffffffc020275a:	bf69                	j	ffffffffc02026f4 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020275c:	d93fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202760:	0000f797          	auipc	a5,0xf
ffffffffc0202764:	dd07b783          	ld	a5,-560(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202768:	739c                	ld	a5,32(a5)
ffffffffc020276a:	8522                	mv	a0,s0
ffffffffc020276c:	4585                	li	a1,1
ffffffffc020276e:	9782                	jalr	a5
            return NULL;
ffffffffc0202770:	4401                	li	s0,0
        intr_enable();
ffffffffc0202772:	d77fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202776:	bfbd                	j	ffffffffc02026f4 <pgdir_alloc_page+0x34>

ffffffffc0202778 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0202778:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020277a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020277c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020277e:	fff50713          	addi	a4,a0,-1
ffffffffc0202782:	17f9                	addi	a5,a5,-2
ffffffffc0202784:	04e7ea63          	bltu	a5,a4,ffffffffc02027d8 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202788:	6785                	lui	a5,0x1
ffffffffc020278a:	17fd                	addi	a5,a5,-1
ffffffffc020278c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc020278e:	8131                	srli	a0,a0,0xc
ffffffffc0202790:	e31fe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
    assert(base != NULL);
ffffffffc0202794:	cd3d                	beqz	a0,ffffffffc0202812 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202796:	0000f797          	auipc	a5,0xf
ffffffffc020279a:	d927b783          	ld	a5,-622(a5) # ffffffffc0211528 <pages>
ffffffffc020279e:	8d1d                	sub	a0,a0,a5
ffffffffc02027a0:	00004697          	auipc	a3,0x4
ffffffffc02027a4:	d386b683          	ld	a3,-712(a3) # ffffffffc02064d8 <error_string+0x38>
ffffffffc02027a8:	850d                	srai	a0,a0,0x3
ffffffffc02027aa:	02d50533          	mul	a0,a0,a3
ffffffffc02027ae:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027b2:	0000f717          	auipc	a4,0xf
ffffffffc02027b6:	d6e73703          	ld	a4,-658(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027ba:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027bc:	00c51793          	slli	a5,a0,0xc
ffffffffc02027c0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02027c2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027c4:	02e7fa63          	bgeu	a5,a4,ffffffffc02027f8 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02027c8:	60a2                	ld	ra,8(sp)
ffffffffc02027ca:	0000f797          	auipc	a5,0xf
ffffffffc02027ce:	d6e7b783          	ld	a5,-658(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc02027d2:	953e                	add	a0,a0,a5
ffffffffc02027d4:	0141                	addi	sp,sp,16
ffffffffc02027d6:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027d8:	00003697          	auipc	a3,0x3
ffffffffc02027dc:	15068693          	addi	a3,a3,336 # ffffffffc0205928 <default_pmm_manager+0x648>
ffffffffc02027e0:	00002617          	auipc	a2,0x2
ffffffffc02027e4:	75060613          	addi	a2,a2,1872 # ffffffffc0204f30 <commands+0x738>
ffffffffc02027e8:	1f000593          	li	a1,496
ffffffffc02027ec:	00003517          	auipc	a0,0x3
ffffffffc02027f0:	bac50513          	addi	a0,a0,-1108 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02027f4:	b81fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027f8:	86aa                	mv	a3,a0
ffffffffc02027fa:	00003617          	auipc	a2,0x3
ffffffffc02027fe:	b7660613          	addi	a2,a2,-1162 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc0202802:	06a00593          	li	a1,106
ffffffffc0202806:	00003517          	auipc	a0,0x3
ffffffffc020280a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc020280e:	b67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202812:	00003697          	auipc	a3,0x3
ffffffffc0202816:	13668693          	addi	a3,a3,310 # ffffffffc0205948 <default_pmm_manager+0x668>
ffffffffc020281a:	00002617          	auipc	a2,0x2
ffffffffc020281e:	71660613          	addi	a2,a2,1814 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202822:	1f300593          	li	a1,499
ffffffffc0202826:	00003517          	auipc	a0,0x3
ffffffffc020282a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc020282e:	b47fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202832 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202832:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202834:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202836:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202838:	fff58713          	addi	a4,a1,-1
ffffffffc020283c:	17f9                	addi	a5,a5,-2
ffffffffc020283e:	0ae7ee63          	bltu	a5,a4,ffffffffc02028fa <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202842:	cd41                	beqz	a0,ffffffffc02028da <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202844:	6785                	lui	a5,0x1
ffffffffc0202846:	17fd                	addi	a5,a5,-1
ffffffffc0202848:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020284a:	c02007b7          	lui	a5,0xc0200
ffffffffc020284e:	81b1                	srli	a1,a1,0xc
ffffffffc0202850:	06f56863          	bltu	a0,a5,ffffffffc02028c0 <kfree+0x8e>
ffffffffc0202854:	0000f697          	auipc	a3,0xf
ffffffffc0202858:	ce46b683          	ld	a3,-796(a3) # ffffffffc0211538 <va_pa_offset>
ffffffffc020285c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020285e:	8131                	srli	a0,a0,0xc
ffffffffc0202860:	0000f797          	auipc	a5,0xf
ffffffffc0202864:	cc07b783          	ld	a5,-832(a5) # ffffffffc0211520 <npage>
ffffffffc0202868:	04f57a63          	bgeu	a0,a5,ffffffffc02028bc <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020286c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202870:	9536                	add	a0,a0,a3
ffffffffc0202872:	00351793          	slli	a5,a0,0x3
ffffffffc0202876:	953e                	add	a0,a0,a5
ffffffffc0202878:	050e                	slli	a0,a0,0x3
ffffffffc020287a:	0000f797          	auipc	a5,0xf
ffffffffc020287e:	cae7b783          	ld	a5,-850(a5) # ffffffffc0211528 <pages>
ffffffffc0202882:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202884:	100027f3          	csrr	a5,sstatus
ffffffffc0202888:	8b89                	andi	a5,a5,2
ffffffffc020288a:	eb89                	bnez	a5,ffffffffc020289c <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc020288c:	0000f797          	auipc	a5,0xf
ffffffffc0202890:	ca47b783          	ld	a5,-860(a5) # ffffffffc0211530 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202894:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0202896:	739c                	ld	a5,32(a5)
}
ffffffffc0202898:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc020289a:	8782                	jr	a5
        intr_disable();
ffffffffc020289c:	e42a                	sd	a0,8(sp)
ffffffffc020289e:	e02e                	sd	a1,0(sp)
ffffffffc02028a0:	c4ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02028a4:	0000f797          	auipc	a5,0xf
ffffffffc02028a8:	c8c7b783          	ld	a5,-884(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02028ac:	6582                	ld	a1,0(sp)
ffffffffc02028ae:	6522                	ld	a0,8(sp)
ffffffffc02028b0:	739c                	ld	a5,32(a5)
ffffffffc02028b2:	9782                	jalr	a5
}
ffffffffc02028b4:	60e2                	ld	ra,24(sp)
ffffffffc02028b6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028b8:	c31fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028bc:	ccdfe0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028c0:	86aa                	mv	a3,a0
ffffffffc02028c2:	00003617          	auipc	a2,0x3
ffffffffc02028c6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0205430 <default_pmm_manager+0x150>
ffffffffc02028ca:	06c00593          	li	a1,108
ffffffffc02028ce:	00003517          	auipc	a0,0x3
ffffffffc02028d2:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc02028d6:	a9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02028da:	00003697          	auipc	a3,0x3
ffffffffc02028de:	07e68693          	addi	a3,a3,126 # ffffffffc0205958 <default_pmm_manager+0x678>
ffffffffc02028e2:	00002617          	auipc	a2,0x2
ffffffffc02028e6:	64e60613          	addi	a2,a2,1614 # ffffffffc0204f30 <commands+0x738>
ffffffffc02028ea:	1fa00593          	li	a1,506
ffffffffc02028ee:	00003517          	auipc	a0,0x3
ffffffffc02028f2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc02028f6:	a7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028fa:	00003697          	auipc	a3,0x3
ffffffffc02028fe:	02e68693          	addi	a3,a3,46 # ffffffffc0205928 <default_pmm_manager+0x648>
ffffffffc0202902:	00002617          	auipc	a2,0x2
ffffffffc0202906:	62e60613          	addi	a2,a2,1582 # ffffffffc0204f30 <commands+0x738>
ffffffffc020290a:	1f900593          	li	a1,505
ffffffffc020290e:	00003517          	auipc	a0,0x3
ffffffffc0202912:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0205398 <default_pmm_manager+0xb8>
ffffffffc0202916:	a5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020291a <swap_init>:
unsigned int swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

static void check_swap(void);

int swap_init(void)
{
ffffffffc020291a:	7135                	addi	sp,sp,-160
ffffffffc020291c:	ed06                	sd	ra,152(sp)
ffffffffc020291e:	e922                	sd	s0,144(sp)
ffffffffc0202920:	e526                	sd	s1,136(sp)
ffffffffc0202922:	e14a                	sd	s2,128(sp)
ffffffffc0202924:	fcce                	sd	s3,120(sp)
ffffffffc0202926:	f8d2                	sd	s4,112(sp)
ffffffffc0202928:	f4d6                	sd	s5,104(sp)
ffffffffc020292a:	f0da                	sd	s6,96(sp)
ffffffffc020292c:	ecde                	sd	s7,88(sp)
ffffffffc020292e:	e8e2                	sd	s8,80(sp)
ffffffffc0202930:	e4e6                	sd	s9,72(sp)
ffffffffc0202932:	e0ea                	sd	s10,64(sp)
ffffffffc0202934:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202936:	5b4010ef          	jal	ra,ffffffffc0203eea <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020293a:	0000f697          	auipc	a3,0xf
ffffffffc020293e:	c066b683          	ld	a3,-1018(a3) # ffffffffc0211540 <max_swap_offset>
ffffffffc0202942:	010007b7          	lui	a5,0x1000
ffffffffc0202946:	ff968713          	addi	a4,a3,-7
ffffffffc020294a:	17e1                	addi	a5,a5,-8
ffffffffc020294c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d2c <swap_init+0x412>
           max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru; // use lru Page Replacement Algorithm
ffffffffc0202950:	00007797          	auipc	a5,0x7
ffffffffc0202954:	6b078793          	addi	a5,a5,1712 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc0202958:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru; // use lru Page Replacement Algorithm
ffffffffc020295a:	0000fb17          	auipc	s6,0xf
ffffffffc020295e:	beeb0b13          	addi	s6,s6,-1042 # ffffffffc0211548 <sm>
ffffffffc0202962:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202966:	9702                	jalr	a4
ffffffffc0202968:	89aa                	mv	s3,a0

     if (r == 0)
ffffffffc020296a:	c10d                	beqz	a0,ffffffffc020298c <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020296c:	60ea                	ld	ra,152(sp)
ffffffffc020296e:	644a                	ld	s0,144(sp)
ffffffffc0202970:	64aa                	ld	s1,136(sp)
ffffffffc0202972:	690a                	ld	s2,128(sp)
ffffffffc0202974:	7a46                	ld	s4,112(sp)
ffffffffc0202976:	7aa6                	ld	s5,104(sp)
ffffffffc0202978:	7b06                	ld	s6,96(sp)
ffffffffc020297a:	6be6                	ld	s7,88(sp)
ffffffffc020297c:	6c46                	ld	s8,80(sp)
ffffffffc020297e:	6ca6                	ld	s9,72(sp)
ffffffffc0202980:	6d06                	ld	s10,64(sp)
ffffffffc0202982:	7de2                	ld	s11,56(sp)
ffffffffc0202984:	854e                	mv	a0,s3
ffffffffc0202986:	79e6                	ld	s3,120(sp)
ffffffffc0202988:	610d                	addi	sp,sp,160
ffffffffc020298a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020298c:	000b3783          	ld	a5,0(s6)
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	00850513          	addi	a0,a0,8 # ffffffffc0205998 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc0202998:	0000e497          	auipc	s1,0xe
ffffffffc020299c:	6a848493          	addi	s1,s1,1704 # ffffffffc0211040 <free_area>
ffffffffc02029a0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029a2:	4785                	li	a5,1
ffffffffc02029a4:	0000f717          	auipc	a4,0xf
ffffffffc02029a8:	baf72623          	sw	a5,-1108(a4) # ffffffffc0211550 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ac:	f0efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029b0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
     // backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029b2:	4401                	li	s0,0
ffffffffc02029b4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc02029b6:	2c978163          	beq	a5,s1,ffffffffc0202c78 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029ba:	fe87b703          	ld	a4,-24(a5)
     {
          struct Page *p = le2page(le, page_link);
          assert(PageProperty(p));
ffffffffc02029be:	8b09                	andi	a4,a4,2
ffffffffc02029c0:	2a070e63          	beqz	a4,ffffffffc0202c7c <swap_init+0x362>
          count++, total += p->property;
ffffffffc02029c4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029c8:	679c                	ld	a5,8(a5)
ffffffffc02029ca:	2d05                	addiw	s10,s10,1
ffffffffc02029cc:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list)
ffffffffc02029ce:	fe9796e3          	bne	a5,s1,ffffffffc02029ba <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02029d2:	8922                	mv	s2,s0
ffffffffc02029d4:	cbffe0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc02029d8:	47251663          	bne	a0,s2,ffffffffc0202e44 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n", count, total);
ffffffffc02029dc:	8622                	mv	a2,s0
ffffffffc02029de:	85ea                	mv	a1,s10
ffffffffc02029e0:	00003517          	auipc	a0,0x3
ffffffffc02029e4:	fd050513          	addi	a0,a0,-48 # ffffffffc02059b0 <default_pmm_manager+0x6d0>
ffffffffc02029e8:	ed2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     // now we set the phy pages env
     struct mm_struct *mm = mm_create();
ffffffffc02029ec:	49d000ef          	jal	ra,ffffffffc0203688 <mm_create>
ffffffffc02029f0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02029f2:	52050963          	beqz	a0,ffffffffc0202f24 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02029f6:	0000f797          	auipc	a5,0xf
ffffffffc02029fa:	b6a78793          	addi	a5,a5,-1174 # ffffffffc0211560 <check_mm_struct>
ffffffffc02029fe:	6398                	ld	a4,0(a5)
ffffffffc0202a00:	54071263          	bnez	a4,ffffffffc0202f44 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a04:	0000fb97          	auipc	s7,0xf
ffffffffc0202a08:	b14bbb83          	ld	s7,-1260(s7) # ffffffffc0211518 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a0c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a10:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a12:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a16:	3c071763          	bnez	a4,ffffffffc0202de4 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a1a:	6599                	lui	a1,0x6
ffffffffc0202a1c:	460d                	li	a2,3
ffffffffc0202a1e:	6505                	lui	a0,0x1
ffffffffc0202a20:	4b1000ef          	jal	ra,ffffffffc02036d0 <vma_create>
ffffffffc0202a24:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a26:	3c050f63          	beqz	a0,ffffffffc0202e04 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a2a:	8556                	mv	a0,s5
ffffffffc0202a2c:	513000ef          	jal	ra,ffffffffc020373e <insert_vma_struct>

     // setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a30:	00003517          	auipc	a0,0x3
ffffffffc0202a34:	ff050513          	addi	a0,a0,-16 # ffffffffc0205a20 <default_pmm_manager+0x740>
ffffffffc0202a38:	e82fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep = NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a3c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a40:	4605                	li	a2,1
ffffffffc0202a42:	6585                	lui	a1,0x1
ffffffffc0202a44:	c89fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
     assert(temp_ptep != NULL);
ffffffffc0202a48:	3c050e63          	beqz	a0,ffffffffc0202e24 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	02450513          	addi	a0,a0,36 # ffffffffc0205a70 <default_pmm_manager+0x790>
ffffffffc0202a54:	0000e917          	auipc	s2,0xe
ffffffffc0202a58:	62490913          	addi	s2,s2,1572 # ffffffffc0211078 <check_rp>
ffffffffc0202a5c:	e5efd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202a60:	0000ea17          	auipc	s4,0xe
ffffffffc0202a64:	638a0a13          	addi	s4,s4,1592 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a68:	8c4a                	mv	s8,s2
     {
          check_rp[i] = alloc_page();
ffffffffc0202a6a:	4505                	li	a0,1
ffffffffc0202a6c:	b55fe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0202a70:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL);
ffffffffc0202a74:	28050c63          	beqz	a0,ffffffffc0202d0c <swap_init+0x3f2>
ffffffffc0202a78:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a7a:	8b89                	andi	a5,a5,2
ffffffffc0202a7c:	26079863          	bnez	a5,ffffffffc0202cec <swap_init+0x3d2>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202a80:	0c21                	addi	s8,s8,8
ffffffffc0202a82:	ff4c14e3          	bne	s8,s4,ffffffffc0202a6a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a86:	609c                	ld	a5,0(s1)
ffffffffc0202a88:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202a8c:	e084                	sd	s1,0(s1)
ffffffffc0202a8e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));

     // assert(alloc_page() == NULL);

     unsigned int nr_free_store = nr_free;
ffffffffc0202a90:	489c                	lw	a5,16(s1)
ffffffffc0202a92:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202a94:	0000ec17          	auipc	s8,0xe
ffffffffc0202a98:	5e4c0c13          	addi	s8,s8,1508 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202a9c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202a9e:	0000e797          	auipc	a5,0xe
ffffffffc0202aa2:	5a07a923          	sw	zero,1458(a5) # ffffffffc0211050 <free_area+0x10>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202aa6:	000c3503          	ld	a0,0(s8)
ffffffffc0202aaa:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202aac:	0c21                	addi	s8,s8,8
          free_pages(check_rp[i], 1);
ffffffffc0202aae:	ba5fe0ef          	jal	ra,ffffffffc0201652 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202ab2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202aa6 <swap_init+0x18c>
     }
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ab6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202aba:	4791                	li	a5,4
ffffffffc0202abc:	4afc1463          	bne	s8,a5,ffffffffc0202f64 <swap_init+0x64a>

     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ac0:	00003517          	auipc	a0,0x3
ffffffffc0202ac4:	03850513          	addi	a0,a0,56 # ffffffffc0205af8 <default_pmm_manager+0x818>
ffffffffc0202ac8:	df2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202acc:	6605                	lui	a2,0x1
     // setup initial vir_page<->phy_page environment for page relpacement algorithm

     pgfault_num = 0;
ffffffffc0202ace:	0000f797          	auipc	a5,0xf
ffffffffc0202ad2:	a807ad23          	sw	zero,-1382(a5) # ffffffffc0211568 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202ad6:	4529                	li	a0,10
ffffffffc0202ad8:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num == 1);
ffffffffc0202adc:	0000f597          	auipc	a1,0xf
ffffffffc0202ae0:	a8c5a583          	lw	a1,-1396(a1) # ffffffffc0211568 <pgfault_num>
ffffffffc0202ae4:	4805                	li	a6,1
ffffffffc0202ae6:	0000f797          	auipc	a5,0xf
ffffffffc0202aea:	a8278793          	addi	a5,a5,-1406 # ffffffffc0211568 <pgfault_num>
ffffffffc0202aee:	3f059b63          	bne	a1,a6,ffffffffc0202ee4 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202af2:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num == 1);
ffffffffc0202af6:	4390                	lw	a2,0(a5)
ffffffffc0202af8:	2601                	sext.w	a2,a2
ffffffffc0202afa:	40b61563          	bne	a2,a1,ffffffffc0202f04 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202afe:	6589                	lui	a1,0x2
ffffffffc0202b00:	452d                	li	a0,11
ffffffffc0202b02:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num == 2);
ffffffffc0202b06:	4390                	lw	a2,0(a5)
ffffffffc0202b08:	4809                	li	a6,2
ffffffffc0202b0a:	2601                	sext.w	a2,a2
ffffffffc0202b0c:	35061c63          	bne	a2,a6,ffffffffc0202e64 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b10:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 2);
ffffffffc0202b14:	438c                	lw	a1,0(a5)
ffffffffc0202b16:	2581                	sext.w	a1,a1
ffffffffc0202b18:	36c59663          	bne	a1,a2,ffffffffc0202e84 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b1c:	658d                	lui	a1,0x3
ffffffffc0202b1e:	4531                	li	a0,12
ffffffffc0202b20:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num == 3);
ffffffffc0202b24:	4390                	lw	a2,0(a5)
ffffffffc0202b26:	480d                	li	a6,3
ffffffffc0202b28:	2601                	sext.w	a2,a2
ffffffffc0202b2a:	37061d63          	bne	a2,a6,ffffffffc0202ea4 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b2e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 3);
ffffffffc0202b32:	438c                	lw	a1,0(a5)
ffffffffc0202b34:	2581                	sext.w	a1,a1
ffffffffc0202b36:	38c59763          	bne	a1,a2,ffffffffc0202ec4 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b3a:	6591                	lui	a1,0x4
ffffffffc0202b3c:	4535                	li	a0,13
ffffffffc0202b3e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num == 4);
ffffffffc0202b42:	4390                	lw	a2,0(a5)
ffffffffc0202b44:	2601                	sext.w	a2,a2
ffffffffc0202b46:	21861f63          	bne	a2,s8,ffffffffc0202d64 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b4a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 4);
ffffffffc0202b4e:	439c                	lw	a5,0(a5)
ffffffffc0202b50:	2781                	sext.w	a5,a5
ffffffffc0202b52:	22c79963          	bne	a5,a2,ffffffffc0202d84 <swap_init+0x46a>

     check_content_set();
     assert(nr_free == 0);
ffffffffc0202b56:	489c                	lw	a5,16(s1)
ffffffffc0202b58:	24079663          	bnez	a5,ffffffffc0202da4 <swap_init+0x48a>
ffffffffc0202b5c:	0000e797          	auipc	a5,0xe
ffffffffc0202b60:	53c78793          	addi	a5,a5,1340 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202b64:	0000e617          	auipc	a2,0xe
ffffffffc0202b68:	55c60613          	addi	a2,a2,1372 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202b6c:	0000e517          	auipc	a0,0xe
ffffffffc0202b70:	55450513          	addi	a0,a0,1364 # ffffffffc02110c0 <swap_out_seq_no>
     for (i = 0; i < MAX_SEQ_NO; i++)
          swap_out_seq_no[i] = swap_in_seq_no[i] = -1;
ffffffffc0202b74:	55fd                	li	a1,-1
ffffffffc0202b76:	c38c                	sw	a1,0(a5)
ffffffffc0202b78:	c20c                	sw	a1,0(a2)
     for (i = 0; i < MAX_SEQ_NO; i++)
ffffffffc0202b7a:	0791                	addi	a5,a5,4
ffffffffc0202b7c:	0611                	addi	a2,a2,4
ffffffffc0202b7e:	fef51ce3          	bne	a0,a5,ffffffffc0202b76 <swap_init+0x25c>
ffffffffc0202b82:	0000e817          	auipc	a6,0xe
ffffffffc0202b86:	4d680813          	addi	a6,a6,1238 # ffffffffc0211058 <check_ptep>
ffffffffc0202b8a:	0000e897          	auipc	a7,0xe
ffffffffc0202b8e:	4ee88893          	addi	a7,a7,1262 # ffffffffc0211078 <check_rp>
ffffffffc0202b92:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202b94:	0000fc97          	auipc	s9,0xf
ffffffffc0202b98:	994c8c93          	addi	s9,s9,-1644 # ffffffffc0211528 <pages>
ffffffffc0202b9c:	00004c17          	auipc	s8,0x4
ffffffffc0202ba0:	944c0c13          	addi	s8,s8,-1724 # ffffffffc02064e0 <nbase>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          check_ptep[i] = 0;
ffffffffc0202ba4:	00083023          	sd	zero,0(a6)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202ba8:	4601                	li	a2,0
ffffffffc0202baa:	855e                	mv	a0,s7
ffffffffc0202bac:	ec46                	sd	a7,24(sp)
ffffffffc0202bae:	e82e                	sd	a1,16(sp)
          check_ptep[i] = 0;
ffffffffc0202bb0:	e442                	sd	a6,8(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bb2:	b1bfe0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0202bb6:	6822                	ld	a6,8(sp)
          // cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
          assert(check_ptep[i] != NULL);
ffffffffc0202bb8:	65c2                	ld	a1,16(sp)
ffffffffc0202bba:	68e2                	ld	a7,24(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bbc:	00a83023          	sd	a0,0(a6)
          assert(check_ptep[i] != NULL);
ffffffffc0202bc0:	0000f317          	auipc	t1,0xf
ffffffffc0202bc4:	96030313          	addi	t1,t1,-1696 # ffffffffc0211520 <npage>
ffffffffc0202bc8:	16050e63          	beqz	a0,ffffffffc0202d44 <swap_init+0x42a>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bcc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202bce:	0017f613          	andi	a2,a5,1
ffffffffc0202bd2:	0e060563          	beqz	a2,ffffffffc0202cbc <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202bd6:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bda:	078a                	slli	a5,a5,0x2
ffffffffc0202bdc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bde:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202cd4 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202be2:	000c3603          	ld	a2,0(s8)
ffffffffc0202be6:	000cb503          	ld	a0,0(s9)
ffffffffc0202bea:	0008bf03          	ld	t5,0(a7)
ffffffffc0202bee:	8f91                	sub	a5,a5,a2
ffffffffc0202bf0:	00379613          	slli	a2,a5,0x3
ffffffffc0202bf4:	97b2                	add	a5,a5,a2
ffffffffc0202bf6:	078e                	slli	a5,a5,0x3
ffffffffc0202bf8:	97aa                	add	a5,a5,a0
ffffffffc0202bfa:	0aff1163          	bne	t5,a5,ffffffffc0202c9c <swap_init+0x382>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202bfe:	6785                	lui	a5,0x1
ffffffffc0202c00:	95be                	add	a1,a1,a5
ffffffffc0202c02:	6795                	lui	a5,0x5
ffffffffc0202c04:	0821                	addi	a6,a6,8
ffffffffc0202c06:	08a1                	addi	a7,a7,8
ffffffffc0202c08:	f8f59ee3          	bne	a1,a5,ffffffffc0202ba4 <swap_init+0x28a>
          assert((*check_ptep[i] & PTE_V));
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c0c:	00003517          	auipc	a0,0x3
ffffffffc0202c10:	fb450513          	addi	a0,a0,-76 # ffffffffc0205bc0 <default_pmm_manager+0x8e0>
ffffffffc0202c14:	ca6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     int ret = sm->check_swap();
ffffffffc0202c18:	000b3783          	ld	a5,0(s6)
ffffffffc0202c1c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c1e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm
     ret = check_content_access();
     assert(ret == 0);
ffffffffc0202c20:	1a051263          	bnez	a0,ffffffffc0202dc4 <swap_init+0x4aa>

     // restore kernel mem env
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202c24:	00093503          	ld	a0,0(s2)
ffffffffc0202c28:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c2a:	0921                	addi	s2,s2,8
          free_pages(check_rp[i], 1);
ffffffffc0202c2c:	a27fe0ef          	jal	ra,ffffffffc0201652 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c30:	ff491ae3          	bne	s2,s4,ffffffffc0202c24 <swap_init+0x30a>
     }

     // free_page(pte2page(*temp_ptep));

     mm_destroy(mm);
ffffffffc0202c34:	8556                	mv	a0,s5
ffffffffc0202c36:	3d9000ef          	jal	ra,ffffffffc020380e <mm_destroy>

     nr_free = nr_free_store;
ffffffffc0202c3a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c3c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c40:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c42:	7782                	ld	a5,32(sp)
ffffffffc0202c44:	e09c                	sd	a5,0(s1)

     le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c46:	009d8a63          	beq	s11,s1,ffffffffc0202c5a <swap_init+0x340>
     {
          struct Page *p = le2page(le, page_link);
          count--, total -= p->property;
ffffffffc0202c4a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c4e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c52:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c54:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c56:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c4a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n", count, total);
ffffffffc0202c5a:	8622                	mv	a2,s0
ffffffffc0202c5c:	85ea                	mv	a1,s10
ffffffffc0202c5e:	00003517          	auipc	a0,0x3
ffffffffc0202c62:	f9a50513          	addi	a0,a0,-102 # ffffffffc0205bf8 <default_pmm_manager+0x918>
ffffffffc0202c66:	c54fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     // assert(count == 0);

     cprintf("check_swap() succeeded!\n");
ffffffffc0202c6a:	00003517          	auipc	a0,0x3
ffffffffc0202c6e:	fae50513          	addi	a0,a0,-82 # ffffffffc0205c18 <default_pmm_manager+0x938>
ffffffffc0202c72:	c48fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202c76:	b9dd                	j	ffffffffc020296c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c78:	4901                	li	s2,0
ffffffffc0202c7a:	bba9                	j	ffffffffc02029d4 <swap_init+0xba>
          assert(PageProperty(p));
ffffffffc0202c7c:	00002697          	auipc	a3,0x2
ffffffffc0202c80:	2a468693          	addi	a3,a3,676 # ffffffffc0204f20 <commands+0x728>
ffffffffc0202c84:	00002617          	auipc	a2,0x2
ffffffffc0202c88:	2ac60613          	addi	a2,a2,684 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202c8c:	0b700593          	li	a1,183
ffffffffc0202c90:	00003517          	auipc	a0,0x3
ffffffffc0202c94:	cf850513          	addi	a0,a0,-776 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202c98:	edcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c9c:	00003697          	auipc	a3,0x3
ffffffffc0202ca0:	efc68693          	addi	a3,a3,-260 # ffffffffc0205b98 <default_pmm_manager+0x8b8>
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	28c60613          	addi	a2,a2,652 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202cac:	0f900593          	li	a1,249
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	cd850513          	addi	a0,a0,-808 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cbc:	00002617          	auipc	a2,0x2
ffffffffc0202cc0:	68c60613          	addi	a2,a2,1676 # ffffffffc0205348 <default_pmm_manager+0x68>
ffffffffc0202cc4:	07000593          	li	a1,112
ffffffffc0202cc8:	00002517          	auipc	a0,0x2
ffffffffc0202ccc:	67050513          	addi	a0,a0,1648 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc0202cd0:	ea4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	64460613          	addi	a2,a2,1604 # ffffffffc0205318 <default_pmm_manager+0x38>
ffffffffc0202cdc:	06500593          	li	a1,101
ffffffffc0202ce0:	00002517          	auipc	a0,0x2
ffffffffc0202ce4:	65850513          	addi	a0,a0,1624 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202cec:	00003697          	auipc	a3,0x3
ffffffffc0202cf0:	dc468693          	addi	a3,a3,-572 # ffffffffc0205ab0 <default_pmm_manager+0x7d0>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	23c60613          	addi	a2,a2,572 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202cfc:	0d900593          	li	a1,217
ffffffffc0202d00:	00003517          	auipc	a0,0x3
ffffffffc0202d04:	c8850513          	addi	a0,a0,-888 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202d08:	e6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL);
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	d8c68693          	addi	a3,a3,-628 # ffffffffc0205a98 <default_pmm_manager+0x7b8>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	21c60613          	addi	a2,a2,540 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202d1c:	0d800593          	li	a1,216
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	c6850513          	addi	a0,a0,-920 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d2c:	00003617          	auipc	a2,0x3
ffffffffc0202d30:	c3c60613          	addi	a2,a2,-964 # ffffffffc0205968 <default_pmm_manager+0x688>
ffffffffc0202d34:	02800593          	li	a1,40
ffffffffc0202d38:	00003517          	auipc	a0,0x3
ffffffffc0202d3c:	c5050513          	addi	a0,a0,-944 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202d40:	e34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_ptep[i] != NULL);
ffffffffc0202d44:	00003697          	auipc	a3,0x3
ffffffffc0202d48:	e3c68693          	addi	a3,a3,-452 # ffffffffc0205b80 <default_pmm_manager+0x8a0>
ffffffffc0202d4c:	00002617          	auipc	a2,0x2
ffffffffc0202d50:	1e460613          	addi	a2,a2,484 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202d54:	0f800593          	li	a1,248
ffffffffc0202d58:	00003517          	auipc	a0,0x3
ffffffffc0202d5c:	c3050513          	addi	a0,a0,-976 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202d60:	e14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202d64:	00003697          	auipc	a3,0x3
ffffffffc0202d68:	e0468693          	addi	a3,a3,-508 # ffffffffc0205b68 <default_pmm_manager+0x888>
ffffffffc0202d6c:	00002617          	auipc	a2,0x2
ffffffffc0202d70:	1c460613          	addi	a2,a2,452 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202d74:	09900593          	li	a1,153
ffffffffc0202d78:	00003517          	auipc	a0,0x3
ffffffffc0202d7c:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202d80:	df4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202d84:	00003697          	auipc	a3,0x3
ffffffffc0202d88:	de468693          	addi	a3,a3,-540 # ffffffffc0205b68 <default_pmm_manager+0x888>
ffffffffc0202d8c:	00002617          	auipc	a2,0x2
ffffffffc0202d90:	1a460613          	addi	a2,a2,420 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202d94:	09b00593          	li	a1,155
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202da0:	dd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == 0);
ffffffffc0202da4:	00002697          	auipc	a3,0x2
ffffffffc0202da8:	36468693          	addi	a3,a3,868 # ffffffffc0205108 <commands+0x910>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	18460613          	addi	a2,a2,388 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202db4:	0ef00593          	li	a1,239
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	bd050513          	addi	a0,a0,-1072 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202dc0:	db4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret == 0);
ffffffffc0202dc4:	00003697          	auipc	a3,0x3
ffffffffc0202dc8:	e2468693          	addi	a3,a3,-476 # ffffffffc0205be8 <default_pmm_manager+0x908>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	16460613          	addi	a2,a2,356 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202dd4:	0ff00593          	li	a1,255
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	bb050513          	addi	a0,a0,-1104 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202de0:	d94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202de4:	00003697          	auipc	a3,0x3
ffffffffc0202de8:	c1c68693          	addi	a3,a3,-996 # ffffffffc0205a00 <default_pmm_manager+0x720>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	14460613          	addi	a2,a2,324 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202df4:	0c700593          	li	a1,199
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202e00:	d74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e04:	00003697          	auipc	a3,0x3
ffffffffc0202e08:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0205a10 <default_pmm_manager+0x730>
ffffffffc0202e0c:	00002617          	auipc	a2,0x2
ffffffffc0202e10:	12460613          	addi	a2,a2,292 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202e14:	0ca00593          	li	a1,202
ffffffffc0202e18:	00003517          	auipc	a0,0x3
ffffffffc0202e1c:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202e20:	d54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep != NULL);
ffffffffc0202e24:	00003697          	auipc	a3,0x3
ffffffffc0202e28:	c3468693          	addi	a3,a3,-972 # ffffffffc0205a58 <default_pmm_manager+0x778>
ffffffffc0202e2c:	00002617          	auipc	a2,0x2
ffffffffc0202e30:	10460613          	addi	a2,a2,260 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202e34:	0d200593          	li	a1,210
ffffffffc0202e38:	00003517          	auipc	a0,0x3
ffffffffc0202e3c:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	d34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e44:	00002697          	auipc	a3,0x2
ffffffffc0202e48:	11c68693          	addi	a3,a3,284 # ffffffffc0204f60 <commands+0x768>
ffffffffc0202e4c:	00002617          	auipc	a2,0x2
ffffffffc0202e50:	0e460613          	addi	a2,a2,228 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202e54:	0ba00593          	li	a1,186
ffffffffc0202e58:	00003517          	auipc	a0,0x3
ffffffffc0202e5c:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202e60:	d14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202e64:	00003697          	auipc	a3,0x3
ffffffffc0202e68:	cd468693          	addi	a3,a3,-812 # ffffffffc0205b38 <default_pmm_manager+0x858>
ffffffffc0202e6c:	00002617          	auipc	a2,0x2
ffffffffc0202e70:	0c460613          	addi	a2,a2,196 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202e74:	09100593          	li	a1,145
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202e80:	cf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202e84:	00003697          	auipc	a3,0x3
ffffffffc0202e88:	cb468693          	addi	a3,a3,-844 # ffffffffc0205b38 <default_pmm_manager+0x858>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	0a460613          	addi	a2,a2,164 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202e94:	09300593          	li	a1,147
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	af050513          	addi	a0,a0,-1296 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202ea0:	cd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ea4:	00003697          	auipc	a3,0x3
ffffffffc0202ea8:	cac68693          	addi	a3,a3,-852 # ffffffffc0205b50 <default_pmm_manager+0x870>
ffffffffc0202eac:	00002617          	auipc	a2,0x2
ffffffffc0202eb0:	08460613          	addi	a2,a2,132 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202eb4:	09500593          	li	a1,149
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	ad050513          	addi	a0,a0,-1328 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202ec0:	cb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ec4:	00003697          	auipc	a3,0x3
ffffffffc0202ec8:	c8c68693          	addi	a3,a3,-884 # ffffffffc0205b50 <default_pmm_manager+0x870>
ffffffffc0202ecc:	00002617          	auipc	a2,0x2
ffffffffc0202ed0:	06460613          	addi	a2,a2,100 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202ed4:	09700593          	li	a1,151
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202ee0:	c94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202ee4:	00003697          	auipc	a3,0x3
ffffffffc0202ee8:	c3c68693          	addi	a3,a3,-964 # ffffffffc0205b20 <default_pmm_manager+0x840>
ffffffffc0202eec:	00002617          	auipc	a2,0x2
ffffffffc0202ef0:	04460613          	addi	a2,a2,68 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202ef4:	08d00593          	li	a1,141
ffffffffc0202ef8:	00003517          	auipc	a0,0x3
ffffffffc0202efc:	a9050513          	addi	a0,a0,-1392 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202f00:	c74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	c1c68693          	addi	a3,a3,-996 # ffffffffc0205b20 <default_pmm_manager+0x840>
ffffffffc0202f0c:	00002617          	auipc	a2,0x2
ffffffffc0202f10:	02460613          	addi	a2,a2,36 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202f14:	08f00593          	li	a1,143
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202f20:	c54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f24:	00003697          	auipc	a3,0x3
ffffffffc0202f28:	ab468693          	addi	a3,a3,-1356 # ffffffffc02059d8 <default_pmm_manager+0x6f8>
ffffffffc0202f2c:	00002617          	auipc	a2,0x2
ffffffffc0202f30:	00460613          	addi	a2,a2,4 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202f34:	0bf00593          	li	a1,191
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	a5050513          	addi	a0,a0,-1456 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202f40:	c34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f44:	00003697          	auipc	a3,0x3
ffffffffc0202f48:	aa468693          	addi	a3,a3,-1372 # ffffffffc02059e8 <default_pmm_manager+0x708>
ffffffffc0202f4c:	00002617          	auipc	a2,0x2
ffffffffc0202f50:	fe460613          	addi	a2,a2,-28 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202f54:	0c200593          	li	a1,194
ffffffffc0202f58:	00003517          	auipc	a0,0x3
ffffffffc0202f5c:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202f60:	c14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205ad0 <default_pmm_manager+0x7f0>
ffffffffc0202f6c:	00002617          	auipc	a2,0x2
ffffffffc0202f70:	fc460613          	addi	a2,a2,-60 # ffffffffc0204f30 <commands+0x738>
ffffffffc0202f74:	0e700593          	li	a1,231
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	a1050513          	addi	a0,a0,-1520 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0202f80:	bf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202f84 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f84:	0000e797          	auipc	a5,0xe
ffffffffc0202f88:	5c47b783          	ld	a5,1476(a5) # ffffffffc0211548 <sm>
ffffffffc0202f8c:	6b9c                	ld	a5,16(a5)
ffffffffc0202f8e:	8782                	jr	a5

ffffffffc0202f90 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f90:	0000e797          	auipc	a5,0xe
ffffffffc0202f94:	5b87b783          	ld	a5,1464(a5) # ffffffffc0211548 <sm>
ffffffffc0202f98:	739c                	ld	a5,32(a5)
ffffffffc0202f9a:	8782                	jr	a5

ffffffffc0202f9c <swap_out>:
{
ffffffffc0202f9c:	711d                	addi	sp,sp,-96
ffffffffc0202f9e:	ec86                	sd	ra,88(sp)
ffffffffc0202fa0:	e8a2                	sd	s0,80(sp)
ffffffffc0202fa2:	e4a6                	sd	s1,72(sp)
ffffffffc0202fa4:	e0ca                	sd	s2,64(sp)
ffffffffc0202fa6:	fc4e                	sd	s3,56(sp)
ffffffffc0202fa8:	f852                	sd	s4,48(sp)
ffffffffc0202faa:	f456                	sd	s5,40(sp)
ffffffffc0202fac:	f05a                	sd	s6,32(sp)
ffffffffc0202fae:	ec5e                	sd	s7,24(sp)
ffffffffc0202fb0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++i)
ffffffffc0202fb2:	cde9                	beqz	a1,ffffffffc020308c <swap_out+0xf0>
ffffffffc0202fb4:	8a2e                	mv	s4,a1
ffffffffc0202fb6:	892a                	mv	s2,a0
ffffffffc0202fb8:	8ab2                	mv	s5,a2
ffffffffc0202fba:	4401                	li	s0,0
ffffffffc0202fbc:	0000e997          	auipc	s3,0xe
ffffffffc0202fc0:	58c98993          	addi	s3,s3,1420 # ffffffffc0211548 <sm>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202fc4:	00003b17          	auipc	s6,0x3
ffffffffc0202fc8:	cd4b0b13          	addi	s6,s6,-812 # ffffffffc0205c98 <default_pmm_manager+0x9b8>
               cprintf("SWAP: failed to save\n");
ffffffffc0202fcc:	00003b97          	auipc	s7,0x3
ffffffffc0202fd0:	cb4b8b93          	addi	s7,s7,-844 # ffffffffc0205c80 <default_pmm_manager+0x9a0>
ffffffffc0202fd4:	a825                	j	ffffffffc020300c <swap_out+0x70>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202fd6:	67a2                	ld	a5,8(sp)
ffffffffc0202fd8:	8626                	mv	a2,s1
ffffffffc0202fda:	85a2                	mv	a1,s0
ffffffffc0202fdc:	63b4                	ld	a3,64(a5)
ffffffffc0202fde:	855a                	mv	a0,s6
     for (i = 0; i != n; ++i)
ffffffffc0202fe0:	2405                	addiw	s0,s0,1
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202fe2:	82b1                	srli	a3,a3,0xc
ffffffffc0202fe4:	0685                	addi	a3,a3,1
ffffffffc0202fe6:	8d4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc0202fea:	6522                	ld	a0,8(sp)
               free_page(page);
ffffffffc0202fec:	4585                	li	a1,1
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc0202fee:	613c                	ld	a5,64(a0)
ffffffffc0202ff0:	83b1                	srli	a5,a5,0xc
ffffffffc0202ff2:	0785                	addi	a5,a5,1
ffffffffc0202ff4:	07a2                	slli	a5,a5,0x8
ffffffffc0202ff6:	00fc3023          	sd	a5,0(s8)
               free_page(page);
ffffffffc0202ffa:	e58fe0ef          	jal	ra,ffffffffc0201652 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202ffe:	01893503          	ld	a0,24(s2)
ffffffffc0203002:	85a6                	mv	a1,s1
ffffffffc0203004:	eb6ff0ef          	jal	ra,ffffffffc02026ba <tlb_invalidate>
     for (i = 0; i != n; ++i)
ffffffffc0203008:	048a0d63          	beq	s4,s0,ffffffffc0203062 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020300c:	0009b783          	ld	a5,0(s3)
ffffffffc0203010:	8656                	mv	a2,s5
ffffffffc0203012:	002c                	addi	a1,sp,8
ffffffffc0203014:	7b9c                	ld	a5,48(a5)
ffffffffc0203016:	854a                	mv	a0,s2
ffffffffc0203018:	9782                	jalr	a5
          if (r != 0)
ffffffffc020301a:	e12d                	bnez	a0,ffffffffc020307c <swap_out+0xe0>
          v = page->pra_vaddr;
ffffffffc020301c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020301e:	01893503          	ld	a0,24(s2)
ffffffffc0203022:	4601                	li	a2,0
          v = page->pra_vaddr;
ffffffffc0203024:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203026:	85a6                	mv	a1,s1
ffffffffc0203028:	ea4fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020302c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020302e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203030:	8b85                	andi	a5,a5,1
ffffffffc0203032:	cfb9                	beqz	a5,ffffffffc0203090 <swap_out+0xf4>
          if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0)
ffffffffc0203034:	65a2                	ld	a1,8(sp)
ffffffffc0203036:	61bc                	ld	a5,64(a1)
ffffffffc0203038:	83b1                	srli	a5,a5,0xc
ffffffffc020303a:	0785                	addi	a5,a5,1
ffffffffc020303c:	00879513          	slli	a0,a5,0x8
ffffffffc0203040:	77d000ef          	jal	ra,ffffffffc0203fbc <swapfs_write>
ffffffffc0203044:	d949                	beqz	a0,ffffffffc0202fd6 <swap_out+0x3a>
               cprintf("SWAP: failed to save\n");
ffffffffc0203046:	855e                	mv	a0,s7
ffffffffc0203048:	872fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               sm->map_swappable(mm, v, page, 0);
ffffffffc020304c:	0009b783          	ld	a5,0(s3)
ffffffffc0203050:	6622                	ld	a2,8(sp)
ffffffffc0203052:	4681                	li	a3,0
ffffffffc0203054:	739c                	ld	a5,32(a5)
ffffffffc0203056:	85a6                	mv	a1,s1
ffffffffc0203058:	854a                	mv	a0,s2
     for (i = 0; i != n; ++i)
ffffffffc020305a:	2405                	addiw	s0,s0,1
               sm->map_swappable(mm, v, page, 0);
ffffffffc020305c:	9782                	jalr	a5
     for (i = 0; i != n; ++i)
ffffffffc020305e:	fa8a17e3          	bne	s4,s0,ffffffffc020300c <swap_out+0x70>
}
ffffffffc0203062:	60e6                	ld	ra,88(sp)
ffffffffc0203064:	8522                	mv	a0,s0
ffffffffc0203066:	6446                	ld	s0,80(sp)
ffffffffc0203068:	64a6                	ld	s1,72(sp)
ffffffffc020306a:	6906                	ld	s2,64(sp)
ffffffffc020306c:	79e2                	ld	s3,56(sp)
ffffffffc020306e:	7a42                	ld	s4,48(sp)
ffffffffc0203070:	7aa2                	ld	s5,40(sp)
ffffffffc0203072:	7b02                	ld	s6,32(sp)
ffffffffc0203074:	6be2                	ld	s7,24(sp)
ffffffffc0203076:	6c42                	ld	s8,16(sp)
ffffffffc0203078:	6125                	addi	sp,sp,96
ffffffffc020307a:	8082                	ret
               cprintf("i %d, swap_out: call swap_out_victim failed\n", i);
ffffffffc020307c:	85a2                	mv	a1,s0
ffffffffc020307e:	00003517          	auipc	a0,0x3
ffffffffc0203082:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205c38 <default_pmm_manager+0x958>
ffffffffc0203086:	834fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               break;
ffffffffc020308a:	bfe1                	j	ffffffffc0203062 <swap_out+0xc6>
     for (i = 0; i != n; ++i)
ffffffffc020308c:	4401                	li	s0,0
ffffffffc020308e:	bfd1                	j	ffffffffc0203062 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203090:	00003697          	auipc	a3,0x3
ffffffffc0203094:	bd868693          	addi	a3,a3,-1064 # ffffffffc0205c68 <default_pmm_manager+0x988>
ffffffffc0203098:	00002617          	auipc	a2,0x2
ffffffffc020309c:	e9860613          	addi	a2,a2,-360 # ffffffffc0204f30 <commands+0x738>
ffffffffc02030a0:	06300593          	li	a1,99
ffffffffc02030a4:	00003517          	auipc	a0,0x3
ffffffffc02030a8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc02030ac:	ac8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030b0 <swap_in>:
{
ffffffffc02030b0:	7179                	addi	sp,sp,-48
ffffffffc02030b2:	e84a                	sd	s2,16(sp)
ffffffffc02030b4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030b6:	4505                	li	a0,1
{
ffffffffc02030b8:	ec26                	sd	s1,24(sp)
ffffffffc02030ba:	e44e                	sd	s3,8(sp)
ffffffffc02030bc:	f406                	sd	ra,40(sp)
ffffffffc02030be:	f022                	sd	s0,32(sp)
ffffffffc02030c0:	84ae                	mv	s1,a1
ffffffffc02030c2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02030c4:	cfcfe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
     assert(result != NULL);
ffffffffc02030c8:	c129                	beqz	a0,ffffffffc020310a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02030ca:	842a                	mv	s0,a0
ffffffffc02030cc:	01893503          	ld	a0,24(s2)
ffffffffc02030d0:	4601                	li	a2,0
ffffffffc02030d2:	85a6                	mv	a1,s1
ffffffffc02030d4:	df8fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc02030d8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02030da:	6108                	ld	a0,0(a0)
ffffffffc02030dc:	85a2                	mv	a1,s0
ffffffffc02030de:	645000ef          	jal	ra,ffffffffc0203f22 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep) >> 8, addr);
ffffffffc02030e2:	00093583          	ld	a1,0(s2)
ffffffffc02030e6:	8626                	mv	a2,s1
ffffffffc02030e8:	00003517          	auipc	a0,0x3
ffffffffc02030ec:	c0050513          	addi	a0,a0,-1024 # ffffffffc0205ce8 <default_pmm_manager+0xa08>
ffffffffc02030f0:	81a1                	srli	a1,a1,0x8
ffffffffc02030f2:	fc9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc02030f6:	70a2                	ld	ra,40(sp)
     *ptr_result = result;
ffffffffc02030f8:	0089b023          	sd	s0,0(s3)
}
ffffffffc02030fc:	7402                	ld	s0,32(sp)
ffffffffc02030fe:	64e2                	ld	s1,24(sp)
ffffffffc0203100:	6942                	ld	s2,16(sp)
ffffffffc0203102:	69a2                	ld	s3,8(sp)
ffffffffc0203104:	4501                	li	a0,0
ffffffffc0203106:	6145                	addi	sp,sp,48
ffffffffc0203108:	8082                	ret
     assert(result != NULL);
ffffffffc020310a:	00003697          	auipc	a3,0x3
ffffffffc020310e:	bce68693          	addi	a3,a3,-1074 # ffffffffc0205cd8 <default_pmm_manager+0x9f8>
ffffffffc0203112:	00002617          	auipc	a2,0x2
ffffffffc0203116:	e1e60613          	addi	a2,a2,-482 # ffffffffc0204f30 <commands+0x738>
ffffffffc020311a:	07a00593          	li	a1,122
ffffffffc020311e:	00003517          	auipc	a0,0x3
ffffffffc0203122:	86a50513          	addi	a0,a0,-1942 # ffffffffc0205988 <default_pmm_manager+0x6a8>
ffffffffc0203126:	a4efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020312a <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020312a:	0000e797          	auipc	a5,0xe
ffffffffc020312e:	fbe78793          	addi	a5,a5,-66 # ffffffffc02110e8 <pra_list_head>
static int
_lru_init_mm(struct mm_struct *mm)
{

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0203132:	f51c                	sd	a5,40(a0)
ffffffffc0203134:	e79c                	sd	a5,8(a5)
ffffffffc0203136:	e39c                	sd	a5,0(a5)
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203138:	4501                	li	a0,0
ffffffffc020313a:	8082                	ret

ffffffffc020313c <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc020313c:	4501                	li	a0,0
ffffffffc020313e:	8082                	ret

ffffffffc0203140 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203140:	4501                	li	a0,0
ffffffffc0203142:	8082                	ret

ffffffffc0203144 <_lru_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0203144:	751c                	ld	a5,40(a0)
{
ffffffffc0203146:	1101                	addi	sp,sp,-32
ffffffffc0203148:	ec06                	sd	ra,24(sp)
ffffffffc020314a:	e822                	sd	s0,16(sp)
ffffffffc020314c:	e426                	sd	s1,8(sp)
    assert(head != NULL);
ffffffffc020314e:	c7bd                	beqz	a5,ffffffffc02031bc <_lru_swap_out_victim+0x78>
    assert(in_tick == 0);
ffffffffc0203150:	e631                	bnez	a2,ffffffffc020319c <_lru_swap_out_victim+0x58>
ffffffffc0203152:	842e                	mv	s0,a1
    return listelm->prev;
ffffffffc0203154:	638c                	ld	a1,0(a5)
    curr_ptr = list_prev(head);
ffffffffc0203156:	0000e497          	auipc	s1,0xe
ffffffffc020315a:	40248493          	addi	s1,s1,1026 # ffffffffc0211558 <curr_ptr>
ffffffffc020315e:	e08c                	sd	a1,0(s1)
    if (curr_ptr != head)
ffffffffc0203160:	02b78663          	beq	a5,a1,ffffffffc020318c <_lru_swap_out_victim+0x48>
        cprintf("curr_ptr 0xffffffff%08x\n", curr_ptr);
ffffffffc0203164:	00003517          	auipc	a0,0x3
ffffffffc0203168:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0205d60 <default_pmm_manager+0xa80>
ffffffffc020316c:	f4ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        list_del(curr_ptr);
ffffffffc0203170:	609c                	ld	a5,0(s1)
}
ffffffffc0203172:	60e2                	ld	ra,24(sp)
ffffffffc0203174:	64a2                	ld	s1,8(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203176:	6394                	ld	a3,0(a5)
ffffffffc0203178:	6798                	ld	a4,8(a5)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc020317a:	fd078793          	addi	a5,a5,-48
}
ffffffffc020317e:	4501                	li	a0,0
    prev->next = next;
ffffffffc0203180:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203182:	e314                	sd	a3,0(a4)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc0203184:	e01c                	sd	a5,0(s0)
}
ffffffffc0203186:	6442                	ld	s0,16(sp)
ffffffffc0203188:	6105                	addi	sp,sp,32
ffffffffc020318a:	8082                	ret
ffffffffc020318c:	60e2                	ld	ra,24(sp)
        *ptr_page = NULL;
ffffffffc020318e:	00043023          	sd	zero,0(s0)
}
ffffffffc0203192:	6442                	ld	s0,16(sp)
ffffffffc0203194:	64a2                	ld	s1,8(sp)
ffffffffc0203196:	4501                	li	a0,0
ffffffffc0203198:	6105                	addi	sp,sp,32
ffffffffc020319a:	8082                	ret
    assert(in_tick == 0);
ffffffffc020319c:	00003697          	auipc	a3,0x3
ffffffffc02031a0:	bb468693          	addi	a3,a3,-1100 # ffffffffc0205d50 <default_pmm_manager+0xa70>
ffffffffc02031a4:	00002617          	auipc	a2,0x2
ffffffffc02031a8:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204f30 <commands+0x738>
ffffffffc02031ac:	02500593          	li	a1,37
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	b8850513          	addi	a0,a0,-1144 # ffffffffc0205d38 <default_pmm_manager+0xa58>
ffffffffc02031b8:	9bcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(head != NULL);
ffffffffc02031bc:	00003697          	auipc	a3,0x3
ffffffffc02031c0:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205d28 <default_pmm_manager+0xa48>
ffffffffc02031c4:	00002617          	auipc	a2,0x2
ffffffffc02031c8:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204f30 <commands+0x738>
ffffffffc02031cc:	02400593          	li	a1,36
ffffffffc02031d0:	00003517          	auipc	a0,0x3
ffffffffc02031d4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0205d38 <default_pmm_manager+0xa58>
ffffffffc02031d8:	99cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02031dc <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{
ffffffffc02031dc:	7179                	addi	sp,sp,-48
ffffffffc02031de:	ec26                	sd	s1,24(sp)
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc02031e0:	7504                	ld	s1,40(a0)
{
ffffffffc02031e2:	f406                	sd	ra,40(sp)
ffffffffc02031e4:	f022                	sd	s0,32(sp)
ffffffffc02031e6:	e84a                	sd	s2,16(sp)
ffffffffc02031e8:	e44e                	sd	s3,8(sp)
    assert(head != NULL);
ffffffffc02031ea:	c4c9                	beqz	s1,ffffffffc0203274 <_lru_tick_event+0x98>
    return listelm->next;
ffffffffc02031ec:	6480                	ld	s0,8(s1)
    curr_ptr = list_next(head);
ffffffffc02031ee:	0000e997          	auipc	s3,0xe
ffffffffc02031f2:	36a98993          	addi	s3,s3,874 # ffffffffc0211558 <curr_ptr>
ffffffffc02031f6:	892a                	mv	s2,a0
ffffffffc02031f8:	0089b023          	sd	s0,0(s3)
    while (curr_ptr != head)
ffffffffc02031fc:	00849863          	bne	s1,s0,ffffffffc020320c <_lru_tick_event+0x30>
ffffffffc0203200:	a8a1                	j	ffffffffc0203258 <_lru_tick_event+0x7c>
    return listelm->prev;
ffffffffc0203202:	6080                	ld	s0,0(s1)
            list_del(curr_ptr);
            list_add(head, curr_ptr);
            *ptep &= ~PTE_A;
            tlb_invalidate(mm->pgdir, page->pra_vaddr);
        }
        curr_ptr = list_prev(head);
ffffffffc0203204:	0089b023          	sd	s0,0(s3)
    while (curr_ptr != head)
ffffffffc0203208:	04848863          	beq	s1,s0,ffffffffc0203258 <_lru_tick_event+0x7c>
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc020320c:	680c                	ld	a1,16(s0)
ffffffffc020320e:	01893503          	ld	a0,24(s2)
ffffffffc0203212:	4601                	li	a2,0
ffffffffc0203214:	cb8fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
        if (*ptep & PTE_A)
ffffffffc0203218:	6118                	ld	a4,0(a0)
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc020321a:	87aa                	mv	a5,a0
        if (*ptep & PTE_A)
ffffffffc020321c:	04077693          	andi	a3,a4,64
ffffffffc0203220:	d2ed                	beqz	a3,ffffffffc0203202 <_lru_tick_event+0x26>
            list_del(curr_ptr);
ffffffffc0203222:	0009b683          	ld	a3,0(s3)
            tlb_invalidate(mm->pgdir, page->pra_vaddr);
ffffffffc0203226:	01893503          	ld	a0,24(s2)
            *ptep &= ~PTE_A;
ffffffffc020322a:	fbf77713          	andi	a4,a4,-65
    __list_del(listelm->prev, listelm->next);
ffffffffc020322e:	668c                	ld	a1,8(a3)
ffffffffc0203230:	0006b803          	ld	a6,0(a3)
    prev->next = next;
ffffffffc0203234:	00b83423          	sd	a1,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203238:	6490                	ld	a2,8(s1)
    next->prev = prev;
ffffffffc020323a:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
    prev->next = next->prev = elm;
ffffffffc020323e:	e214                	sd	a3,0(a2)
ffffffffc0203240:	e494                	sd	a3,8(s1)
    elm->next = next;
ffffffffc0203242:	e690                	sd	a2,8(a3)
    elm->prev = prev;
ffffffffc0203244:	e284                	sd	s1,0(a3)
ffffffffc0203246:	e398                	sd	a4,0(a5)
            tlb_invalidate(mm->pgdir, page->pra_vaddr);
ffffffffc0203248:	680c                	ld	a1,16(s0)
ffffffffc020324a:	c70ff0ef          	jal	ra,ffffffffc02026ba <tlb_invalidate>
    return listelm->prev;
ffffffffc020324e:	6080                	ld	s0,0(s1)
        curr_ptr = list_prev(head);
ffffffffc0203250:	0089b023          	sd	s0,0(s3)
    while (curr_ptr != head)
ffffffffc0203254:	fa849ce3          	bne	s1,s0,ffffffffc020320c <_lru_tick_event+0x30>
    }
    cprintf("_lru_tick_event is called!\n");
ffffffffc0203258:	00003517          	auipc	a0,0x3
ffffffffc020325c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0205d80 <default_pmm_manager+0xaa0>
ffffffffc0203260:	e5bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
}
ffffffffc0203264:	70a2                	ld	ra,40(sp)
ffffffffc0203266:	7402                	ld	s0,32(sp)
ffffffffc0203268:	64e2                	ld	s1,24(sp)
ffffffffc020326a:	6942                	ld	s2,16(sp)
ffffffffc020326c:	69a2                	ld	s3,8(sp)
ffffffffc020326e:	4501                	li	a0,0
ffffffffc0203270:	6145                	addi	sp,sp,48
ffffffffc0203272:	8082                	ret
    assert(head != NULL);
ffffffffc0203274:	00003697          	auipc	a3,0x3
ffffffffc0203278:	ab468693          	addi	a3,a3,-1356 # ffffffffc0205d28 <default_pmm_manager+0xa48>
ffffffffc020327c:	00002617          	auipc	a2,0x2
ffffffffc0203280:	cb460613          	addi	a2,a2,-844 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203284:	07a00593          	li	a1,122
ffffffffc0203288:	00003517          	auipc	a0,0x3
ffffffffc020328c:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205d38 <default_pmm_manager+0xa58>
ffffffffc0203290:	8e4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203294 <_lru_map_swappable>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0203294:	751c                	ld	a5,40(a0)
    curr_ptr = &(page->pra_page_link);
ffffffffc0203296:	03060713          	addi	a4,a2,48
ffffffffc020329a:	0000e697          	auipc	a3,0xe
ffffffffc020329e:	2ae6bf23          	sd	a4,702(a3) # ffffffffc0211558 <curr_ptr>
    assert(curr_ptr != NULL && head != NULL);
ffffffffc02032a2:	cb81                	beqz	a5,ffffffffc02032b2 <_lru_map_swappable+0x1e>
    __list_add(elm, listelm, listelm->next);
ffffffffc02032a4:	6794                	ld	a3,8(a5)
}
ffffffffc02032a6:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc02032a8:	e298                	sd	a4,0(a3)
ffffffffc02032aa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02032ac:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc02032ae:	fa1c                	sd	a5,48(a2)
ffffffffc02032b0:	8082                	ret
{
ffffffffc02032b2:	1141                	addi	sp,sp,-16
    assert(curr_ptr != NULL && head != NULL);
ffffffffc02032b4:	00003697          	auipc	a3,0x3
ffffffffc02032b8:	aec68693          	addi	a3,a3,-1300 # ffffffffc0205da0 <default_pmm_manager+0xac0>
ffffffffc02032bc:	00002617          	auipc	a2,0x2
ffffffffc02032c0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204f30 <commands+0x738>
ffffffffc02032c4:	45ed                	li	a1,27
ffffffffc02032c6:	00003517          	auipc	a0,0x3
ffffffffc02032ca:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205d38 <default_pmm_manager+0xa58>
{
ffffffffc02032ce:	e406                	sd	ra,8(sp)
    assert(curr_ptr != NULL && head != NULL);
ffffffffc02032d0:	8a4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032d4 <_lru_check_swap>:
{
ffffffffc02032d4:	1101                	addi	sp,sp,-32
ffffffffc02032d6:	e822                	sd	s0,16(sp)
    cprintf("--------begin----------\n");
ffffffffc02032d8:	00003517          	auipc	a0,0x3
ffffffffc02032dc:	af050513          	addi	a0,a0,-1296 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
    return listelm->next;
ffffffffc02032e0:	0000e417          	auipc	s0,0xe
ffffffffc02032e4:	e0840413          	addi	s0,s0,-504 # ffffffffc02110e8 <pra_list_head>
{
ffffffffc02032e8:	e426                	sd	s1,8(sp)
ffffffffc02032ea:	ec06                	sd	ra,24(sp)
ffffffffc02032ec:	e04a                	sd	s2,0(sp)
    cprintf("--------begin----------\n");
ffffffffc02032ee:	dcdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02032f2:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02032f4:	00848d63          	beq	s1,s0,ffffffffc020330e <_lru_check_swap+0x3a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02032f8:	00003917          	auipc	s2,0x3
ffffffffc02032fc:	af090913          	addi	s2,s2,-1296 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203300:	688c                	ld	a1,16(s1)
ffffffffc0203302:	854a                	mv	a0,s2
ffffffffc0203304:	db7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203308:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020330a:	fe849be3          	bne	s1,s0,ffffffffc0203300 <_lru_check_swap+0x2c>
    cprintf("---------end-----------\n");
ffffffffc020330e:	00003517          	auipc	a0,0x3
ffffffffc0203312:	aea50513          	addi	a0,a0,-1302 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc0203316:	da5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc020331a:	00003517          	auipc	a0,0x3
ffffffffc020331e:	afe50513          	addi	a0,a0,-1282 # ffffffffc0205e18 <default_pmm_manager+0xb38>
ffffffffc0203322:	d99fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203326:	678d                	lui	a5,0x3
ffffffffc0203328:	4731                	li	a4,12
ffffffffc020332a:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    cprintf("--------begin----------\n");
ffffffffc020332e:	00003517          	auipc	a0,0x3
ffffffffc0203332:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc0203336:	d85fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020333a:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc020333c:	00848d63          	beq	s1,s0,ffffffffc0203356 <_lru_check_swap+0x82>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203340:	00003917          	auipc	s2,0x3
ffffffffc0203344:	aa890913          	addi	s2,s2,-1368 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203348:	688c                	ld	a1,16(s1)
ffffffffc020334a:	854a                	mv	a0,s2
ffffffffc020334c:	d6ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203350:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203352:	fe849be3          	bne	s1,s0,ffffffffc0203348 <_lru_check_swap+0x74>
    cprintf("---------end-----------\n");
ffffffffc0203356:	00003517          	auipc	a0,0x3
ffffffffc020335a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc020335e:	d5dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203362:	00003517          	auipc	a0,0x3
ffffffffc0203366:	ade50513          	addi	a0,a0,-1314 # ffffffffc0205e40 <default_pmm_manager+0xb60>
ffffffffc020336a:	d51fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020336e:	6785                	lui	a5,0x1
ffffffffc0203370:	4729                	li	a4,10
ffffffffc0203372:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    cprintf("--------begin----------\n");
ffffffffc0203376:	00003517          	auipc	a0,0x3
ffffffffc020337a:	a5250513          	addi	a0,a0,-1454 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc020337e:	d3dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203382:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203384:	00848d63          	beq	s1,s0,ffffffffc020339e <_lru_check_swap+0xca>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203388:	00003917          	auipc	s2,0x3
ffffffffc020338c:	a6090913          	addi	s2,s2,-1440 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203390:	688c                	ld	a1,16(s1)
ffffffffc0203392:	854a                	mv	a0,s2
ffffffffc0203394:	d27fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203398:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020339a:	fe849be3          	bne	s1,s0,ffffffffc0203390 <_lru_check_swap+0xbc>
    cprintf("---------end-----------\n");
ffffffffc020339e:	00003517          	auipc	a0,0x3
ffffffffc02033a2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc02033a6:	d15fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc02033aa:	00003517          	auipc	a0,0x3
ffffffffc02033ae:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205e68 <default_pmm_manager+0xb88>
ffffffffc02033b2:	d09fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02033b6:	6789                	lui	a5,0x2
ffffffffc02033b8:	472d                	li	a4,11
ffffffffc02033ba:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc02033be:	00003517          	auipc	a0,0x3
ffffffffc02033c2:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc02033c6:	cf5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02033ca:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02033cc:	00848d63          	beq	s1,s0,ffffffffc02033e6 <_lru_check_swap+0x112>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02033d0:	00003917          	auipc	s2,0x3
ffffffffc02033d4:	a1890913          	addi	s2,s2,-1512 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc02033d8:	688c                	ld	a1,16(s1)
ffffffffc02033da:	854a                	mv	a0,s2
ffffffffc02033dc:	cdffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02033e0:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02033e2:	fe849be3          	bne	s1,s0,ffffffffc02033d8 <_lru_check_swap+0x104>
    cprintf("---------end-----------\n");
ffffffffc02033e6:	00003517          	auipc	a0,0x3
ffffffffc02033ea:	a1250513          	addi	a0,a0,-1518 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc02033ee:	ccdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc02033f2:	00003517          	auipc	a0,0x3
ffffffffc02033f6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0205e90 <default_pmm_manager+0xbb0>
ffffffffc02033fa:	cc1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02033fe:	6795                	lui	a5,0x5
ffffffffc0203400:	4739                	li	a4,14
ffffffffc0203402:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    cprintf("--------begin----------\n");
ffffffffc0203406:	00003517          	auipc	a0,0x3
ffffffffc020340a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc020340e:	cadfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203412:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203414:	00848d63          	beq	s1,s0,ffffffffc020342e <_lru_check_swap+0x15a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203418:	00003917          	auipc	s2,0x3
ffffffffc020341c:	9d090913          	addi	s2,s2,-1584 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203420:	688c                	ld	a1,16(s1)
ffffffffc0203422:	854a                	mv	a0,s2
ffffffffc0203424:	c97fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203428:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020342a:	fe849be3          	bne	s1,s0,ffffffffc0203420 <_lru_check_swap+0x14c>
    cprintf("---------end-----------\n");
ffffffffc020342e:	00003517          	auipc	a0,0x3
ffffffffc0203432:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc0203436:	c85fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc020343a:	00003517          	auipc	a0,0x3
ffffffffc020343e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0205e68 <default_pmm_manager+0xb88>
ffffffffc0203442:	c79fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203446:	6789                	lui	a5,0x2
ffffffffc0203448:	472d                	li	a4,11
ffffffffc020344a:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc020344e:	00003517          	auipc	a0,0x3
ffffffffc0203452:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc0203456:	c65fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020345a:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc020345c:	00848d63          	beq	s1,s0,ffffffffc0203476 <_lru_check_swap+0x1a2>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203460:	00003917          	auipc	s2,0x3
ffffffffc0203464:	98890913          	addi	s2,s2,-1656 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203468:	688c                	ld	a1,16(s1)
ffffffffc020346a:	854a                	mv	a0,s2
ffffffffc020346c:	c4ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203470:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203472:	fe849be3          	bne	s1,s0,ffffffffc0203468 <_lru_check_swap+0x194>
    cprintf("---------end-----------\n");
ffffffffc0203476:	00003517          	auipc	a0,0x3
ffffffffc020347a:	98250513          	addi	a0,a0,-1662 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc020347e:	c3dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203482:	00003517          	auipc	a0,0x3
ffffffffc0203486:	9be50513          	addi	a0,a0,-1602 # ffffffffc0205e40 <default_pmm_manager+0xb60>
ffffffffc020348a:	c31fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020348e:	6785                	lui	a5,0x1
ffffffffc0203490:	4729                	li	a4,10
ffffffffc0203492:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    cprintf("--------begin----------\n");
ffffffffc0203496:	00003517          	auipc	a0,0x3
ffffffffc020349a:	93250513          	addi	a0,a0,-1742 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc020349e:	c1dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02034a2:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02034a4:	00848d63          	beq	s1,s0,ffffffffc02034be <_lru_check_swap+0x1ea>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02034a8:	00003917          	auipc	s2,0x3
ffffffffc02034ac:	94090913          	addi	s2,s2,-1728 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc02034b0:	688c                	ld	a1,16(s1)
ffffffffc02034b2:	854a                	mv	a0,s2
ffffffffc02034b4:	c07fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02034b8:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02034ba:	fe849be3          	bne	s1,s0,ffffffffc02034b0 <_lru_check_swap+0x1dc>
    cprintf("---------end-----------\n");
ffffffffc02034be:	00003517          	auipc	a0,0x3
ffffffffc02034c2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc02034c6:	bf5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc02034ca:	00003517          	auipc	a0,0x3
ffffffffc02034ce:	99e50513          	addi	a0,a0,-1634 # ffffffffc0205e68 <default_pmm_manager+0xb88>
ffffffffc02034d2:	be9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034d6:	6789                	lui	a5,0x2
ffffffffc02034d8:	472d                	li	a4,11
ffffffffc02034da:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc02034de:	00003517          	auipc	a0,0x3
ffffffffc02034e2:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc02034e6:	bd5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02034ea:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02034ec:	00848d63          	beq	s1,s0,ffffffffc0203506 <_lru_check_swap+0x232>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02034f0:	00003917          	auipc	s2,0x3
ffffffffc02034f4:	8f890913          	addi	s2,s2,-1800 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc02034f8:	688c                	ld	a1,16(s1)
ffffffffc02034fa:	854a                	mv	a0,s2
ffffffffc02034fc:	bbffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203500:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203502:	fe849be3          	bne	s1,s0,ffffffffc02034f8 <_lru_check_swap+0x224>
    cprintf("---------end-----------\n");
ffffffffc0203506:	00003517          	auipc	a0,0x3
ffffffffc020350a:	8f250513          	addi	a0,a0,-1806 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc020350e:	badfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203512:	00003517          	auipc	a0,0x3
ffffffffc0203516:	90650513          	addi	a0,a0,-1786 # ffffffffc0205e18 <default_pmm_manager+0xb38>
ffffffffc020351a:	ba1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020351e:	678d                	lui	a5,0x3
ffffffffc0203520:	4731                	li	a4,12
ffffffffc0203522:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    cprintf("--------begin----------\n");
ffffffffc0203526:	00003517          	auipc	a0,0x3
ffffffffc020352a:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc020352e:	b8dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203532:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203534:	00848d63          	beq	s1,s0,ffffffffc020354e <_lru_check_swap+0x27a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203538:	00003917          	auipc	s2,0x3
ffffffffc020353c:	8b090913          	addi	s2,s2,-1872 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203540:	688c                	ld	a1,16(s1)
ffffffffc0203542:	854a                	mv	a0,s2
ffffffffc0203544:	b77fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203548:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc020354a:	fe849be3          	bne	s1,s0,ffffffffc0203540 <_lru_check_swap+0x26c>
    cprintf("---------end-----------\n");
ffffffffc020354e:	00003517          	auipc	a0,0x3
ffffffffc0203552:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc0203556:	b65fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc020355a:	00003517          	auipc	a0,0x3
ffffffffc020355e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205eb8 <default_pmm_manager+0xbd8>
ffffffffc0203562:	b59fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203566:	6791                	lui	a5,0x4
ffffffffc0203568:	4735                	li	a4,13
ffffffffc020356a:	00e78023          	sb	a4,0(a5) # 4000 <kern_entry-0xffffffffc01fc000>
    cprintf("--------begin----------\n");
ffffffffc020356e:	00003517          	auipc	a0,0x3
ffffffffc0203572:	85a50513          	addi	a0,a0,-1958 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc0203576:	b45fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020357a:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc020357c:	00848d63          	beq	s1,s0,ffffffffc0203596 <_lru_check_swap+0x2c2>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203580:	00003917          	auipc	s2,0x3
ffffffffc0203584:	86890913          	addi	s2,s2,-1944 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc0203588:	688c                	ld	a1,16(s1)
ffffffffc020358a:	854a                	mv	a0,s2
ffffffffc020358c:	b2ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203590:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203592:	fe849be3          	bne	s1,s0,ffffffffc0203588 <_lru_check_swap+0x2b4>
    cprintf("---------end-----------\n");
ffffffffc0203596:	00003517          	auipc	a0,0x3
ffffffffc020359a:	86250513          	addi	a0,a0,-1950 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc020359e:	b1dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc02035a2:	00003517          	auipc	a0,0x3
ffffffffc02035a6:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0205e90 <default_pmm_manager+0xbb0>
ffffffffc02035aa:	b11fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02035ae:	6795                	lui	a5,0x5
ffffffffc02035b0:	4739                	li	a4,14
ffffffffc02035b2:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    cprintf("--------begin----------\n");
ffffffffc02035b6:	00003517          	auipc	a0,0x3
ffffffffc02035ba:	81250513          	addi	a0,a0,-2030 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc02035be:	afdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02035c2:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc02035c4:	00848d63          	beq	s1,s0,ffffffffc02035de <_lru_check_swap+0x30a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc02035c8:	00003917          	auipc	s2,0x3
ffffffffc02035cc:	82090913          	addi	s2,s2,-2016 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc02035d0:	688c                	ld	a1,16(s1)
ffffffffc02035d2:	854a                	mv	a0,s2
ffffffffc02035d4:	ae7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02035d8:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc02035da:	fe849be3          	bne	s1,s0,ffffffffc02035d0 <_lru_check_swap+0x2fc>
    cprintf("---------end-----------\n");
ffffffffc02035de:	00003517          	auipc	a0,0x3
ffffffffc02035e2:	81a50513          	addi	a0,a0,-2022 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc02035e6:	ad5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02035ea:	00003517          	auipc	a0,0x3
ffffffffc02035ee:	85650513          	addi	a0,a0,-1962 # ffffffffc0205e40 <default_pmm_manager+0xb60>
ffffffffc02035f2:	ac9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035f6:	6785                	lui	a5,0x1
ffffffffc02035f8:	0007c703          	lbu	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02035fc:	47a9                	li	a5,10
ffffffffc02035fe:	04f71363          	bne	a4,a5,ffffffffc0203644 <_lru_check_swap+0x370>
    cprintf("--------begin----------\n");
ffffffffc0203602:	00002517          	auipc	a0,0x2
ffffffffc0203606:	7c650513          	addi	a0,a0,1990 # ffffffffc0205dc8 <default_pmm_manager+0xae8>
ffffffffc020360a:	ab1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020360e:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203610:	00848d63          	beq	s1,s0,ffffffffc020362a <_lru_check_swap+0x356>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203614:	00002917          	auipc	s2,0x2
ffffffffc0203618:	7d490913          	addi	s2,s2,2004 # ffffffffc0205de8 <default_pmm_manager+0xb08>
ffffffffc020361c:	688c                	ld	a1,16(s1)
ffffffffc020361e:	854a                	mv	a0,s2
ffffffffc0203620:	a9bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203624:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203626:	fe849be3          	bne	s1,s0,ffffffffc020361c <_lru_check_swap+0x348>
    cprintf("---------end-----------\n");
ffffffffc020362a:	00002517          	auipc	a0,0x2
ffffffffc020362e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205df8 <default_pmm_manager+0xb18>
ffffffffc0203632:	a89fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203636:	60e2                	ld	ra,24(sp)
ffffffffc0203638:	6442                	ld	s0,16(sp)
ffffffffc020363a:	64a2                	ld	s1,8(sp)
ffffffffc020363c:	6902                	ld	s2,0(sp)
ffffffffc020363e:	4501                	li	a0,0
ffffffffc0203640:	6105                	addi	sp,sp,32
ffffffffc0203642:	8082                	ret
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203644:	00003697          	auipc	a3,0x3
ffffffffc0203648:	89c68693          	addi	a3,a3,-1892 # ffffffffc0205ee0 <default_pmm_manager+0xc00>
ffffffffc020364c:	00002617          	auipc	a2,0x2
ffffffffc0203650:	8e460613          	addi	a2,a2,-1820 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203654:	06400593          	li	a1,100
ffffffffc0203658:	00002517          	auipc	a0,0x2
ffffffffc020365c:	6e050513          	addi	a0,a0,1760 # ffffffffc0205d38 <default_pmm_manager+0xa58>
ffffffffc0203660:	d15fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203664 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203664:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203666:	00003697          	auipc	a3,0x3
ffffffffc020366a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205f20 <default_pmm_manager+0xc40>
ffffffffc020366e:	00002617          	auipc	a2,0x2
ffffffffc0203672:	8c260613          	addi	a2,a2,-1854 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203676:	07d00593          	li	a1,125
ffffffffc020367a:	00003517          	auipc	a0,0x3
ffffffffc020367e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205f40 <default_pmm_manager+0xc60>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203682:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203684:	cf1fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203688 <mm_create>:
mm_create(void) {
ffffffffc0203688:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020368a:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020368e:	e022                	sd	s0,0(sp)
ffffffffc0203690:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203692:	8e6ff0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc0203696:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203698:	c105                	beqz	a0,ffffffffc02036b8 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc020369a:	e408                	sd	a0,8(s0)
ffffffffc020369c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020369e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02036a2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02036a6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02036aa:	0000e797          	auipc	a5,0xe
ffffffffc02036ae:	ea67a783          	lw	a5,-346(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02036b2:	eb81                	bnez	a5,ffffffffc02036c2 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02036b4:	02053423          	sd	zero,40(a0)
}
ffffffffc02036b8:	60a2                	ld	ra,8(sp)
ffffffffc02036ba:	8522                	mv	a0,s0
ffffffffc02036bc:	6402                	ld	s0,0(sp)
ffffffffc02036be:	0141                	addi	sp,sp,16
ffffffffc02036c0:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02036c2:	8c3ff0ef          	jal	ra,ffffffffc0202f84 <swap_init_mm>
}
ffffffffc02036c6:	60a2                	ld	ra,8(sp)
ffffffffc02036c8:	8522                	mv	a0,s0
ffffffffc02036ca:	6402                	ld	s0,0(sp)
ffffffffc02036cc:	0141                	addi	sp,sp,16
ffffffffc02036ce:	8082                	ret

ffffffffc02036d0 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02036d0:	1101                	addi	sp,sp,-32
ffffffffc02036d2:	e04a                	sd	s2,0(sp)
ffffffffc02036d4:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036d6:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02036da:	e822                	sd	s0,16(sp)
ffffffffc02036dc:	e426                	sd	s1,8(sp)
ffffffffc02036de:	ec06                	sd	ra,24(sp)
ffffffffc02036e0:	84ae                	mv	s1,a1
ffffffffc02036e2:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036e4:	894ff0ef          	jal	ra,ffffffffc0202778 <kmalloc>
    if (vma != NULL) {
ffffffffc02036e8:	c509                	beqz	a0,ffffffffc02036f2 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02036ea:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02036ee:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02036f0:	ed00                	sd	s0,24(a0)
}
ffffffffc02036f2:	60e2                	ld	ra,24(sp)
ffffffffc02036f4:	6442                	ld	s0,16(sp)
ffffffffc02036f6:	64a2                	ld	s1,8(sp)
ffffffffc02036f8:	6902                	ld	s2,0(sp)
ffffffffc02036fa:	6105                	addi	sp,sp,32
ffffffffc02036fc:	8082                	ret

ffffffffc02036fe <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02036fe:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203700:	c505                	beqz	a0,ffffffffc0203728 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203702:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203704:	c501                	beqz	a0,ffffffffc020370c <find_vma+0xe>
ffffffffc0203706:	651c                	ld	a5,8(a0)
ffffffffc0203708:	02f5f263          	bgeu	a1,a5,ffffffffc020372c <find_vma+0x2e>
    return listelm->next;
ffffffffc020370c:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020370e:	00f68d63          	beq	a3,a5,ffffffffc0203728 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203712:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203716:	00e5e663          	bltu	a1,a4,ffffffffc0203722 <find_vma+0x24>
ffffffffc020371a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020371e:	00e5ec63          	bltu	a1,a4,ffffffffc0203736 <find_vma+0x38>
ffffffffc0203722:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203724:	fef697e3          	bne	a3,a5,ffffffffc0203712 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203728:	4501                	li	a0,0
}
ffffffffc020372a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020372c:	691c                	ld	a5,16(a0)
ffffffffc020372e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020370c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203732:	ea88                	sd	a0,16(a3)
ffffffffc0203734:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203736:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020373a:	ea88                	sd	a0,16(a3)
ffffffffc020373c:	8082                	ret

ffffffffc020373e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020373e:	6590                	ld	a2,8(a1)
ffffffffc0203740:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203744:	1141                	addi	sp,sp,-16
ffffffffc0203746:	e406                	sd	ra,8(sp)
ffffffffc0203748:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020374a:	01066763          	bltu	a2,a6,ffffffffc0203758 <insert_vma_struct+0x1a>
ffffffffc020374e:	a085                	j	ffffffffc02037ae <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203750:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203754:	04e66863          	bltu	a2,a4,ffffffffc02037a4 <insert_vma_struct+0x66>
ffffffffc0203758:	86be                	mv	a3,a5
ffffffffc020375a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020375c:	fef51ae3          	bne	a0,a5,ffffffffc0203750 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203760:	02a68463          	beq	a3,a0,ffffffffc0203788 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203764:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203768:	fe86b883          	ld	a7,-24(a3)
ffffffffc020376c:	08e8f163          	bgeu	a7,a4,ffffffffc02037ee <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203770:	04e66f63          	bltu	a2,a4,ffffffffc02037ce <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0203774:	00f50a63          	beq	a0,a5,ffffffffc0203788 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203778:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020377c:	05076963          	bltu	a4,a6,ffffffffc02037ce <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203780:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203784:	02c77363          	bgeu	a4,a2,ffffffffc02037aa <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203788:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020378a:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020378c:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203790:	e390                	sd	a2,0(a5)
ffffffffc0203792:	e690                	sd	a2,8(a3)
}
ffffffffc0203794:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203796:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203798:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc020379a:	0017079b          	addiw	a5,a4,1
ffffffffc020379e:	d11c                	sw	a5,32(a0)
}
ffffffffc02037a0:	0141                	addi	sp,sp,16
ffffffffc02037a2:	8082                	ret
    if (le_prev != list) {
ffffffffc02037a4:	fca690e3          	bne	a3,a0,ffffffffc0203764 <insert_vma_struct+0x26>
ffffffffc02037a8:	bfd1                	j	ffffffffc020377c <insert_vma_struct+0x3e>
ffffffffc02037aa:	ebbff0ef          	jal	ra,ffffffffc0203664 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02037ae:	00002697          	auipc	a3,0x2
ffffffffc02037b2:	7a268693          	addi	a3,a3,1954 # ffffffffc0205f50 <default_pmm_manager+0xc70>
ffffffffc02037b6:	00001617          	auipc	a2,0x1
ffffffffc02037ba:	77a60613          	addi	a2,a2,1914 # ffffffffc0204f30 <commands+0x738>
ffffffffc02037be:	08400593          	li	a1,132
ffffffffc02037c2:	00002517          	auipc	a0,0x2
ffffffffc02037c6:	77e50513          	addi	a0,a0,1918 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc02037ca:	babfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02037ce:	00002697          	auipc	a3,0x2
ffffffffc02037d2:	7c268693          	addi	a3,a3,1986 # ffffffffc0205f90 <default_pmm_manager+0xcb0>
ffffffffc02037d6:	00001617          	auipc	a2,0x1
ffffffffc02037da:	75a60613          	addi	a2,a2,1882 # ffffffffc0204f30 <commands+0x738>
ffffffffc02037de:	07c00593          	li	a1,124
ffffffffc02037e2:	00002517          	auipc	a0,0x2
ffffffffc02037e6:	75e50513          	addi	a0,a0,1886 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc02037ea:	b8bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02037ee:	00002697          	auipc	a3,0x2
ffffffffc02037f2:	78268693          	addi	a3,a3,1922 # ffffffffc0205f70 <default_pmm_manager+0xc90>
ffffffffc02037f6:	00001617          	auipc	a2,0x1
ffffffffc02037fa:	73a60613          	addi	a2,a2,1850 # ffffffffc0204f30 <commands+0x738>
ffffffffc02037fe:	07b00593          	li	a1,123
ffffffffc0203802:	00002517          	auipc	a0,0x2
ffffffffc0203806:	73e50513          	addi	a0,a0,1854 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc020380a:	b6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020380e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020380e:	1141                	addi	sp,sp,-16
ffffffffc0203810:	e022                	sd	s0,0(sp)
ffffffffc0203812:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203814:	6508                	ld	a0,8(a0)
ffffffffc0203816:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203818:	00a40e63          	beq	s0,a0,ffffffffc0203834 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020381c:	6118                	ld	a4,0(a0)
ffffffffc020381e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203820:	03000593          	li	a1,48
ffffffffc0203824:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203826:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203828:	e398                	sd	a4,0(a5)
ffffffffc020382a:	808ff0ef          	jal	ra,ffffffffc0202832 <kfree>
    return listelm->next;
ffffffffc020382e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203830:	fea416e3          	bne	s0,a0,ffffffffc020381c <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203834:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203836:	6402                	ld	s0,0(sp)
ffffffffc0203838:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020383a:	03000593          	li	a1,48
}
ffffffffc020383e:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203840:	ff3fe06f          	j	ffffffffc0202832 <kfree>

ffffffffc0203844 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203844:	715d                	addi	sp,sp,-80
ffffffffc0203846:	e486                	sd	ra,72(sp)
ffffffffc0203848:	f44e                	sd	s3,40(sp)
ffffffffc020384a:	f052                	sd	s4,32(sp)
ffffffffc020384c:	e0a2                	sd	s0,64(sp)
ffffffffc020384e:	fc26                	sd	s1,56(sp)
ffffffffc0203850:	f84a                	sd	s2,48(sp)
ffffffffc0203852:	ec56                	sd	s5,24(sp)
ffffffffc0203854:	e85a                	sd	s6,16(sp)
ffffffffc0203856:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203858:	e3bfd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc020385c:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020385e:	e35fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203862:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203864:	03000513          	li	a0,48
ffffffffc0203868:	f11fe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
    if (mm != NULL) {
ffffffffc020386c:	56050863          	beqz	a0,ffffffffc0203ddc <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0203870:	e508                	sd	a0,8(a0)
ffffffffc0203872:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203874:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203878:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020387c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203880:	0000e797          	auipc	a5,0xe
ffffffffc0203884:	cd07a783          	lw	a5,-816(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc0203888:	84aa                	mv	s1,a0
ffffffffc020388a:	e7b9                	bnez	a5,ffffffffc02038d8 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc020388c:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0203890:	03200413          	li	s0,50
ffffffffc0203894:	a811                	j	ffffffffc02038a8 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0203896:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203898:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020389a:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020389e:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02038a0:	8526                	mv	a0,s1
ffffffffc02038a2:	e9dff0ef          	jal	ra,ffffffffc020373e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02038a6:	cc05                	beqz	s0,ffffffffc02038de <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038a8:	03000513          	li	a0,48
ffffffffc02038ac:	ecdfe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc02038b0:	85aa                	mv	a1,a0
ffffffffc02038b2:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02038b6:	f165                	bnez	a0,ffffffffc0203896 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02038b8:	00002697          	auipc	a3,0x2
ffffffffc02038bc:	15868693          	addi	a3,a3,344 # ffffffffc0205a10 <default_pmm_manager+0x730>
ffffffffc02038c0:	00001617          	auipc	a2,0x1
ffffffffc02038c4:	67060613          	addi	a2,a2,1648 # ffffffffc0204f30 <commands+0x738>
ffffffffc02038c8:	0ce00593          	li	a1,206
ffffffffc02038cc:	00002517          	auipc	a0,0x2
ffffffffc02038d0:	67450513          	addi	a0,a0,1652 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc02038d4:	aa1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038d8:	eacff0ef          	jal	ra,ffffffffc0202f84 <swap_init_mm>
ffffffffc02038dc:	bf55                	j	ffffffffc0203890 <vmm_init+0x4c>
ffffffffc02038de:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02038e2:	1f900913          	li	s2,505
ffffffffc02038e6:	a819                	j	ffffffffc02038fc <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc02038e8:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02038ea:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02038ec:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02038f0:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02038f2:	8526                	mv	a0,s1
ffffffffc02038f4:	e4bff0ef          	jal	ra,ffffffffc020373e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02038f8:	03240a63          	beq	s0,s2,ffffffffc020392c <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038fc:	03000513          	li	a0,48
ffffffffc0203900:	e79fe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc0203904:	85aa                	mv	a1,a0
ffffffffc0203906:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020390a:	fd79                	bnez	a0,ffffffffc02038e8 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc020390c:	00002697          	auipc	a3,0x2
ffffffffc0203910:	10468693          	addi	a3,a3,260 # ffffffffc0205a10 <default_pmm_manager+0x730>
ffffffffc0203914:	00001617          	auipc	a2,0x1
ffffffffc0203918:	61c60613          	addi	a2,a2,1564 # ffffffffc0204f30 <commands+0x738>
ffffffffc020391c:	0d400593          	li	a1,212
ffffffffc0203920:	00002517          	auipc	a0,0x2
ffffffffc0203924:	62050513          	addi	a0,a0,1568 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203928:	a4dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc020392c:	649c                	ld	a5,8(s1)
ffffffffc020392e:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203930:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203934:	2ef48463          	beq	s1,a5,ffffffffc0203c1c <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203938:	fe87b603          	ld	a2,-24(a5)
ffffffffc020393c:	ffe70693          	addi	a3,a4,-2
ffffffffc0203940:	26d61e63          	bne	a2,a3,ffffffffc0203bbc <vmm_init+0x378>
ffffffffc0203944:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203948:	26e69a63          	bne	a3,a4,ffffffffc0203bbc <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc020394c:	0715                	addi	a4,a4,5
ffffffffc020394e:	679c                	ld	a5,8(a5)
ffffffffc0203950:	feb712e3          	bne	a4,a1,ffffffffc0203934 <vmm_init+0xf0>
ffffffffc0203954:	4b1d                	li	s6,7
ffffffffc0203956:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203958:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020395c:	85a2                	mv	a1,s0
ffffffffc020395e:	8526                	mv	a0,s1
ffffffffc0203960:	d9fff0ef          	jal	ra,ffffffffc02036fe <find_vma>
ffffffffc0203964:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203966:	2c050b63          	beqz	a0,ffffffffc0203c3c <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020396a:	00140593          	addi	a1,s0,1
ffffffffc020396e:	8526                	mv	a0,s1
ffffffffc0203970:	d8fff0ef          	jal	ra,ffffffffc02036fe <find_vma>
ffffffffc0203974:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203976:	2e050363          	beqz	a0,ffffffffc0203c5c <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020397a:	85da                	mv	a1,s6
ffffffffc020397c:	8526                	mv	a0,s1
ffffffffc020397e:	d81ff0ef          	jal	ra,ffffffffc02036fe <find_vma>
        assert(vma3 == NULL);
ffffffffc0203982:	2e051d63          	bnez	a0,ffffffffc0203c7c <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203986:	00340593          	addi	a1,s0,3
ffffffffc020398a:	8526                	mv	a0,s1
ffffffffc020398c:	d73ff0ef          	jal	ra,ffffffffc02036fe <find_vma>
        assert(vma4 == NULL);
ffffffffc0203990:	30051663          	bnez	a0,ffffffffc0203c9c <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203994:	00440593          	addi	a1,s0,4
ffffffffc0203998:	8526                	mv	a0,s1
ffffffffc020399a:	d65ff0ef          	jal	ra,ffffffffc02036fe <find_vma>
        assert(vma5 == NULL);
ffffffffc020399e:	30051f63          	bnez	a0,ffffffffc0203cbc <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02039a2:	00893783          	ld	a5,8(s2)
ffffffffc02039a6:	24879b63          	bne	a5,s0,ffffffffc0203bfc <vmm_init+0x3b8>
ffffffffc02039aa:	01093783          	ld	a5,16(s2)
ffffffffc02039ae:	25679763          	bne	a5,s6,ffffffffc0203bfc <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02039b2:	008ab783          	ld	a5,8(s5)
ffffffffc02039b6:	22879363          	bne	a5,s0,ffffffffc0203bdc <vmm_init+0x398>
ffffffffc02039ba:	010ab783          	ld	a5,16(s5)
ffffffffc02039be:	21679f63          	bne	a5,s6,ffffffffc0203bdc <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02039c2:	0415                	addi	s0,s0,5
ffffffffc02039c4:	0b15                	addi	s6,s6,5
ffffffffc02039c6:	f9741be3          	bne	s0,s7,ffffffffc020395c <vmm_init+0x118>
ffffffffc02039ca:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02039cc:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02039ce:	85a2                	mv	a1,s0
ffffffffc02039d0:	8526                	mv	a0,s1
ffffffffc02039d2:	d2dff0ef          	jal	ra,ffffffffc02036fe <find_vma>
ffffffffc02039d6:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02039da:	c90d                	beqz	a0,ffffffffc0203a0c <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02039dc:	6914                	ld	a3,16(a0)
ffffffffc02039de:	6510                	ld	a2,8(a0)
ffffffffc02039e0:	00002517          	auipc	a0,0x2
ffffffffc02039e4:	6d050513          	addi	a0,a0,1744 # ffffffffc02060b0 <default_pmm_manager+0xdd0>
ffffffffc02039e8:	ed2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02039ec:	00002697          	auipc	a3,0x2
ffffffffc02039f0:	6ec68693          	addi	a3,a3,1772 # ffffffffc02060d8 <default_pmm_manager+0xdf8>
ffffffffc02039f4:	00001617          	auipc	a2,0x1
ffffffffc02039f8:	53c60613          	addi	a2,a2,1340 # ffffffffc0204f30 <commands+0x738>
ffffffffc02039fc:	0f600593          	li	a1,246
ffffffffc0203a00:	00002517          	auipc	a0,0x2
ffffffffc0203a04:	54050513          	addi	a0,a0,1344 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203a08:	96dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203a0c:	147d                	addi	s0,s0,-1
ffffffffc0203a0e:	fd2410e3          	bne	s0,s2,ffffffffc02039ce <vmm_init+0x18a>
ffffffffc0203a12:	a811                	j	ffffffffc0203a26 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a14:	6118                	ld	a4,0(a0)
ffffffffc0203a16:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203a18:	03000593          	li	a1,48
ffffffffc0203a1c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a1e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a20:	e398                	sd	a4,0(a5)
ffffffffc0203a22:	e11fe0ef          	jal	ra,ffffffffc0202832 <kfree>
    return listelm->next;
ffffffffc0203a26:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203a28:	fea496e3          	bne	s1,a0,ffffffffc0203a14 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203a2c:	03000593          	li	a1,48
ffffffffc0203a30:	8526                	mv	a0,s1
ffffffffc0203a32:	e01fe0ef          	jal	ra,ffffffffc0202832 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a36:	c5dfd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203a3a:	3caa1163          	bne	s4,a0,ffffffffc0203dfc <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203a3e:	00002517          	auipc	a0,0x2
ffffffffc0203a42:	6da50513          	addi	a0,a0,1754 # ffffffffc0206118 <default_pmm_manager+0xe38>
ffffffffc0203a46:	e74fc0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203a4a:	c49fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203a4e:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a50:	03000513          	li	a0,48
ffffffffc0203a54:	d25fe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc0203a58:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203a5a:	2a050163          	beqz	a0,ffffffffc0203cfc <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a5e:	0000e797          	auipc	a5,0xe
ffffffffc0203a62:	af27a783          	lw	a5,-1294(a5) # ffffffffc0211550 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203a66:	e508                	sd	a0,8(a0)
ffffffffc0203a68:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a6a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a6e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a72:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a76:	14079063          	bnez	a5,ffffffffc0203bb6 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0203a7a:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203a7e:	0000e917          	auipc	s2,0xe
ffffffffc0203a82:	a9a93903          	ld	s2,-1382(s2) # ffffffffc0211518 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203a86:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203a8a:	0000e717          	auipc	a4,0xe
ffffffffc0203a8e:	ac873b23          	sd	s0,-1322(a4) # ffffffffc0211560 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203a92:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203a96:	24079363          	bnez	a5,ffffffffc0203cdc <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a9a:	03000513          	li	a0,48
ffffffffc0203a9e:	cdbfe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc0203aa2:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203aa4:	28050063          	beqz	a0,ffffffffc0203d24 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0203aa8:	002007b7          	lui	a5,0x200
ffffffffc0203aac:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203ab0:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203ab2:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203ab4:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203ab8:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203aba:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203abe:	c81ff0ef          	jal	ra,ffffffffc020373e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ac2:	10000593          	li	a1,256
ffffffffc0203ac6:	8522                	mv	a0,s0
ffffffffc0203ac8:	c37ff0ef          	jal	ra,ffffffffc02036fe <find_vma>
ffffffffc0203acc:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203ad0:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ad4:	26aa1863          	bne	s4,a0,ffffffffc0203d44 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203ad8:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203adc:	0785                	addi	a5,a5,1
ffffffffc0203ade:	fee79de3          	bne	a5,a4,ffffffffc0203ad8 <vmm_init+0x294>
        sum += i;
ffffffffc0203ae2:	6705                	lui	a4,0x1
ffffffffc0203ae4:	10000793          	li	a5,256
ffffffffc0203ae8:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203aec:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203af0:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203af4:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203af6:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203af8:	fec79ce3          	bne	a5,a2,ffffffffc0203af0 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0203afc:	26071463          	bnez	a4,ffffffffc0203d64 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203b00:	4581                	li	a1,0
ffffffffc0203b02:	854a                	mv	a0,s2
ffffffffc0203b04:	e19fd0ef          	jal	ra,ffffffffc020191c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b08:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203b0c:	0000e717          	auipc	a4,0xe
ffffffffc0203b10:	a1473703          	ld	a4,-1516(a4) # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b14:	078a                	slli	a5,a5,0x2
ffffffffc0203b16:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b18:	26e7f663          	bgeu	a5,a4,ffffffffc0203d84 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b1c:	00003717          	auipc	a4,0x3
ffffffffc0203b20:	9c473703          	ld	a4,-1596(a4) # ffffffffc02064e0 <nbase>
ffffffffc0203b24:	8f99                	sub	a5,a5,a4
ffffffffc0203b26:	00379713          	slli	a4,a5,0x3
ffffffffc0203b2a:	97ba                	add	a5,a5,a4
ffffffffc0203b2c:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203b2e:	0000e517          	auipc	a0,0xe
ffffffffc0203b32:	9fa53503          	ld	a0,-1542(a0) # ffffffffc0211528 <pages>
ffffffffc0203b36:	953e                	add	a0,a0,a5
ffffffffc0203b38:	4585                	li	a1,1
ffffffffc0203b3a:	b19fd0ef          	jal	ra,ffffffffc0201652 <free_pages>
    return listelm->next;
ffffffffc0203b3e:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203b40:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203b44:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203b48:	00a40e63          	beq	s0,a0,ffffffffc0203b64 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b4c:	6118                	ld	a4,0(a0)
ffffffffc0203b4e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203b50:	03000593          	li	a1,48
ffffffffc0203b54:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203b56:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b58:	e398                	sd	a4,0(a5)
ffffffffc0203b5a:	cd9fe0ef          	jal	ra,ffffffffc0202832 <kfree>
    return listelm->next;
ffffffffc0203b5e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203b60:	fea416e3          	bne	s0,a0,ffffffffc0203b4c <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203b64:	03000593          	li	a1,48
ffffffffc0203b68:	8522                	mv	a0,s0
ffffffffc0203b6a:	cc9fe0ef          	jal	ra,ffffffffc0202832 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203b6e:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203b70:	0000e797          	auipc	a5,0xe
ffffffffc0203b74:	9e07b823          	sd	zero,-1552(a5) # ffffffffc0211560 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203b78:	b1bfd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203b7c:	22a49063          	bne	s1,a0,ffffffffc0203d9c <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203b80:	00002517          	auipc	a0,0x2
ffffffffc0203b84:	5e850513          	addi	a0,a0,1512 # ffffffffc0206168 <default_pmm_manager+0xe88>
ffffffffc0203b88:	d32fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203b8c:	b07fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203b90:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203b92:	22a99563          	bne	s3,a0,ffffffffc0203dbc <vmm_init+0x578>
}
ffffffffc0203b96:	6406                	ld	s0,64(sp)
ffffffffc0203b98:	60a6                	ld	ra,72(sp)
ffffffffc0203b9a:	74e2                	ld	s1,56(sp)
ffffffffc0203b9c:	7942                	ld	s2,48(sp)
ffffffffc0203b9e:	79a2                	ld	s3,40(sp)
ffffffffc0203ba0:	7a02                	ld	s4,32(sp)
ffffffffc0203ba2:	6ae2                	ld	s5,24(sp)
ffffffffc0203ba4:	6b42                	ld	s6,16(sp)
ffffffffc0203ba6:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203ba8:	00002517          	auipc	a0,0x2
ffffffffc0203bac:	5e050513          	addi	a0,a0,1504 # ffffffffc0206188 <default_pmm_manager+0xea8>
}
ffffffffc0203bb0:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203bb2:	d08fc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203bb6:	bceff0ef          	jal	ra,ffffffffc0202f84 <swap_init_mm>
ffffffffc0203bba:	b5d1                	j	ffffffffc0203a7e <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203bbc:	00002697          	auipc	a3,0x2
ffffffffc0203bc0:	40c68693          	addi	a3,a3,1036 # ffffffffc0205fc8 <default_pmm_manager+0xce8>
ffffffffc0203bc4:	00001617          	auipc	a2,0x1
ffffffffc0203bc8:	36c60613          	addi	a2,a2,876 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203bcc:	0dd00593          	li	a1,221
ffffffffc0203bd0:	00002517          	auipc	a0,0x2
ffffffffc0203bd4:	37050513          	addi	a0,a0,880 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203bd8:	f9cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203bdc:	00002697          	auipc	a3,0x2
ffffffffc0203be0:	4a468693          	addi	a3,a3,1188 # ffffffffc0206080 <default_pmm_manager+0xda0>
ffffffffc0203be4:	00001617          	auipc	a2,0x1
ffffffffc0203be8:	34c60613          	addi	a2,a2,844 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203bec:	0ee00593          	li	a1,238
ffffffffc0203bf0:	00002517          	auipc	a0,0x2
ffffffffc0203bf4:	35050513          	addi	a0,a0,848 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203bf8:	f7cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203bfc:	00002697          	auipc	a3,0x2
ffffffffc0203c00:	45468693          	addi	a3,a3,1108 # ffffffffc0206050 <default_pmm_manager+0xd70>
ffffffffc0203c04:	00001617          	auipc	a2,0x1
ffffffffc0203c08:	32c60613          	addi	a2,a2,812 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203c0c:	0ed00593          	li	a1,237
ffffffffc0203c10:	00002517          	auipc	a0,0x2
ffffffffc0203c14:	33050513          	addi	a0,a0,816 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203c18:	f5cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203c1c:	00002697          	auipc	a3,0x2
ffffffffc0203c20:	39468693          	addi	a3,a3,916 # ffffffffc0205fb0 <default_pmm_manager+0xcd0>
ffffffffc0203c24:	00001617          	auipc	a2,0x1
ffffffffc0203c28:	30c60613          	addi	a2,a2,780 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203c2c:	0db00593          	li	a1,219
ffffffffc0203c30:	00002517          	auipc	a0,0x2
ffffffffc0203c34:	31050513          	addi	a0,a0,784 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203c38:	f3cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203c3c:	00002697          	auipc	a3,0x2
ffffffffc0203c40:	3c468693          	addi	a3,a3,964 # ffffffffc0206000 <default_pmm_manager+0xd20>
ffffffffc0203c44:	00001617          	auipc	a2,0x1
ffffffffc0203c48:	2ec60613          	addi	a2,a2,748 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203c4c:	0e300593          	li	a1,227
ffffffffc0203c50:	00002517          	auipc	a0,0x2
ffffffffc0203c54:	2f050513          	addi	a0,a0,752 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203c58:	f1cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203c5c:	00002697          	auipc	a3,0x2
ffffffffc0203c60:	3b468693          	addi	a3,a3,948 # ffffffffc0206010 <default_pmm_manager+0xd30>
ffffffffc0203c64:	00001617          	auipc	a2,0x1
ffffffffc0203c68:	2cc60613          	addi	a2,a2,716 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203c6c:	0e500593          	li	a1,229
ffffffffc0203c70:	00002517          	auipc	a0,0x2
ffffffffc0203c74:	2d050513          	addi	a0,a0,720 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203c78:	efcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203c7c:	00002697          	auipc	a3,0x2
ffffffffc0203c80:	3a468693          	addi	a3,a3,932 # ffffffffc0206020 <default_pmm_manager+0xd40>
ffffffffc0203c84:	00001617          	auipc	a2,0x1
ffffffffc0203c88:	2ac60613          	addi	a2,a2,684 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203c8c:	0e700593          	li	a1,231
ffffffffc0203c90:	00002517          	auipc	a0,0x2
ffffffffc0203c94:	2b050513          	addi	a0,a0,688 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203c98:	edcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203c9c:	00002697          	auipc	a3,0x2
ffffffffc0203ca0:	39468693          	addi	a3,a3,916 # ffffffffc0206030 <default_pmm_manager+0xd50>
ffffffffc0203ca4:	00001617          	auipc	a2,0x1
ffffffffc0203ca8:	28c60613          	addi	a2,a2,652 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203cac:	0e900593          	li	a1,233
ffffffffc0203cb0:	00002517          	auipc	a0,0x2
ffffffffc0203cb4:	29050513          	addi	a0,a0,656 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203cb8:	ebcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203cbc:	00002697          	auipc	a3,0x2
ffffffffc0203cc0:	38468693          	addi	a3,a3,900 # ffffffffc0206040 <default_pmm_manager+0xd60>
ffffffffc0203cc4:	00001617          	auipc	a2,0x1
ffffffffc0203cc8:	26c60613          	addi	a2,a2,620 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203ccc:	0eb00593          	li	a1,235
ffffffffc0203cd0:	00002517          	auipc	a0,0x2
ffffffffc0203cd4:	27050513          	addi	a0,a0,624 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203cd8:	e9cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203cdc:	00002697          	auipc	a3,0x2
ffffffffc0203ce0:	d2468693          	addi	a3,a3,-732 # ffffffffc0205a00 <default_pmm_manager+0x720>
ffffffffc0203ce4:	00001617          	auipc	a2,0x1
ffffffffc0203ce8:	24c60613          	addi	a2,a2,588 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203cec:	10d00593          	li	a1,269
ffffffffc0203cf0:	00002517          	auipc	a0,0x2
ffffffffc0203cf4:	25050513          	addi	a0,a0,592 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203cf8:	e7cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203cfc:	00002697          	auipc	a3,0x2
ffffffffc0203d00:	4a468693          	addi	a3,a3,1188 # ffffffffc02061a0 <default_pmm_manager+0xec0>
ffffffffc0203d04:	00001617          	auipc	a2,0x1
ffffffffc0203d08:	22c60613          	addi	a2,a2,556 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203d0c:	10a00593          	li	a1,266
ffffffffc0203d10:	00002517          	auipc	a0,0x2
ffffffffc0203d14:	23050513          	addi	a0,a0,560 # ffffffffc0205f40 <default_pmm_manager+0xc60>
    check_mm_struct = mm_create();
ffffffffc0203d18:	0000e797          	auipc	a5,0xe
ffffffffc0203d1c:	8407b423          	sd	zero,-1976(a5) # ffffffffc0211560 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203d20:	e54fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203d24:	00002697          	auipc	a3,0x2
ffffffffc0203d28:	cec68693          	addi	a3,a3,-788 # ffffffffc0205a10 <default_pmm_manager+0x730>
ffffffffc0203d2c:	00001617          	auipc	a2,0x1
ffffffffc0203d30:	20460613          	addi	a2,a2,516 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203d34:	11100593          	li	a1,273
ffffffffc0203d38:	00002517          	auipc	a0,0x2
ffffffffc0203d3c:	20850513          	addi	a0,a0,520 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203d40:	e34fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203d44:	00002697          	auipc	a3,0x2
ffffffffc0203d48:	3f468693          	addi	a3,a3,1012 # ffffffffc0206138 <default_pmm_manager+0xe58>
ffffffffc0203d4c:	00001617          	auipc	a2,0x1
ffffffffc0203d50:	1e460613          	addi	a2,a2,484 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203d54:	11600593          	li	a1,278
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	1e850513          	addi	a0,a0,488 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203d60:	e14fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203d64:	00002697          	auipc	a3,0x2
ffffffffc0203d68:	3f468693          	addi	a3,a3,1012 # ffffffffc0206158 <default_pmm_manager+0xe78>
ffffffffc0203d6c:	00001617          	auipc	a2,0x1
ffffffffc0203d70:	1c460613          	addi	a2,a2,452 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203d74:	12000593          	li	a1,288
ffffffffc0203d78:	00002517          	auipc	a0,0x2
ffffffffc0203d7c:	1c850513          	addi	a0,a0,456 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203d80:	df4fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203d84:	00001617          	auipc	a2,0x1
ffffffffc0203d88:	59460613          	addi	a2,a2,1428 # ffffffffc0205318 <default_pmm_manager+0x38>
ffffffffc0203d8c:	06500593          	li	a1,101
ffffffffc0203d90:	00001517          	auipc	a0,0x1
ffffffffc0203d94:	5a850513          	addi	a0,a0,1448 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc0203d98:	ddcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d9c:	00002697          	auipc	a3,0x2
ffffffffc0203da0:	35468693          	addi	a3,a3,852 # ffffffffc02060f0 <default_pmm_manager+0xe10>
ffffffffc0203da4:	00001617          	auipc	a2,0x1
ffffffffc0203da8:	18c60613          	addi	a2,a2,396 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203dac:	12e00593          	li	a1,302
ffffffffc0203db0:	00002517          	auipc	a0,0x2
ffffffffc0203db4:	19050513          	addi	a0,a0,400 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203db8:	dbcfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203dbc:	00002697          	auipc	a3,0x2
ffffffffc0203dc0:	33468693          	addi	a3,a3,820 # ffffffffc02060f0 <default_pmm_manager+0xe10>
ffffffffc0203dc4:	00001617          	auipc	a2,0x1
ffffffffc0203dc8:	16c60613          	addi	a2,a2,364 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203dcc:	0bd00593          	li	a1,189
ffffffffc0203dd0:	00002517          	auipc	a0,0x2
ffffffffc0203dd4:	17050513          	addi	a0,a0,368 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203dd8:	d9cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203ddc:	00002697          	auipc	a3,0x2
ffffffffc0203de0:	bfc68693          	addi	a3,a3,-1028 # ffffffffc02059d8 <default_pmm_manager+0x6f8>
ffffffffc0203de4:	00001617          	auipc	a2,0x1
ffffffffc0203de8:	14c60613          	addi	a2,a2,332 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203dec:	0c700593          	li	a1,199
ffffffffc0203df0:	00002517          	auipc	a0,0x2
ffffffffc0203df4:	15050513          	addi	a0,a0,336 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203df8:	d7cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203dfc:	00002697          	auipc	a3,0x2
ffffffffc0203e00:	2f468693          	addi	a3,a3,756 # ffffffffc02060f0 <default_pmm_manager+0xe10>
ffffffffc0203e04:	00001617          	auipc	a2,0x1
ffffffffc0203e08:	12c60613          	addi	a2,a2,300 # ffffffffc0204f30 <commands+0x738>
ffffffffc0203e0c:	0fb00593          	li	a1,251
ffffffffc0203e10:	00002517          	auipc	a0,0x2
ffffffffc0203e14:	13050513          	addi	a0,a0,304 # ffffffffc0205f40 <default_pmm_manager+0xc60>
ffffffffc0203e18:	d5cfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e1c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203e1c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203e1e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203e20:	f022                	sd	s0,32(sp)
ffffffffc0203e22:	ec26                	sd	s1,24(sp)
ffffffffc0203e24:	f406                	sd	ra,40(sp)
ffffffffc0203e26:	e84a                	sd	s2,16(sp)
ffffffffc0203e28:	8432                	mv	s0,a2
ffffffffc0203e2a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203e2c:	8d3ff0ef          	jal	ra,ffffffffc02036fe <find_vma>

    pgfault_num++;
ffffffffc0203e30:	0000d797          	auipc	a5,0xd
ffffffffc0203e34:	7387a783          	lw	a5,1848(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203e38:	2785                	addiw	a5,a5,1
ffffffffc0203e3a:	0000d717          	auipc	a4,0xd
ffffffffc0203e3e:	72f72723          	sw	a5,1838(a4) # ffffffffc0211568 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203e42:	c159                	beqz	a0,ffffffffc0203ec8 <do_pgfault+0xac>
ffffffffc0203e44:	651c                	ld	a5,8(a0)
ffffffffc0203e46:	08f46163          	bltu	s0,a5,ffffffffc0203ec8 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203e4a:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203e4c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203e4e:	8b89                	andi	a5,a5,2
ffffffffc0203e50:	ebb1                	bnez	a5,ffffffffc0203ea4 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203e52:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203e54:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203e56:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203e58:	85a2                	mv	a1,s0
ffffffffc0203e5a:	4605                	li	a2,1
ffffffffc0203e5c:	871fd0ef          	jal	ra,ffffffffc02016cc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203e60:	610c                	ld	a1,0(a0)
ffffffffc0203e62:	c1b9                	beqz	a1,ffffffffc0203ea8 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203e64:	0000d797          	auipc	a5,0xd
ffffffffc0203e68:	6ec7a783          	lw	a5,1772(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc0203e6c:	c7bd                	beqz	a5,ffffffffc0203eda <do_pgfault+0xbe>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0203e6e:	85a2                	mv	a1,s0
ffffffffc0203e70:	0030                	addi	a2,sp,8
ffffffffc0203e72:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203e74:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203e76:	a3aff0ef          	jal	ra,ffffffffc02030b0 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203e7a:	65a2                	ld	a1,8(sp)
ffffffffc0203e7c:	6c88                	ld	a0,24(s1)
ffffffffc0203e7e:	86ca                	mv	a3,s2
ffffffffc0203e80:	8622                	mv	a2,s0
ffffffffc0203e82:	b35fd0ef          	jal	ra,ffffffffc02019b6 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203e86:	6622                	ld	a2,8(sp)
ffffffffc0203e88:	4685                	li	a3,1
ffffffffc0203e8a:	85a2                	mv	a1,s0
ffffffffc0203e8c:	8526                	mv	a0,s1
ffffffffc0203e8e:	902ff0ef          	jal	ra,ffffffffc0202f90 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203e92:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203e94:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0203e96:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0203e98:	70a2                	ld	ra,40(sp)
ffffffffc0203e9a:	7402                	ld	s0,32(sp)
ffffffffc0203e9c:	64e2                	ld	s1,24(sp)
ffffffffc0203e9e:	6942                	ld	s2,16(sp)
ffffffffc0203ea0:	6145                	addi	sp,sp,48
ffffffffc0203ea2:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203ea4:	4959                	li	s2,22
ffffffffc0203ea6:	b775                	j	ffffffffc0203e52 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203ea8:	6c88                	ld	a0,24(s1)
ffffffffc0203eaa:	864a                	mv	a2,s2
ffffffffc0203eac:	85a2                	mv	a1,s0
ffffffffc0203eae:	813fe0ef          	jal	ra,ffffffffc02026c0 <pgdir_alloc_page>
ffffffffc0203eb2:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0203eb4:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203eb6:	f3ed                	bnez	a5,ffffffffc0203e98 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203eb8:	00002517          	auipc	a0,0x2
ffffffffc0203ebc:	33050513          	addi	a0,a0,816 # ffffffffc02061e8 <default_pmm_manager+0xf08>
ffffffffc0203ec0:	9fafc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ec4:	5571                	li	a0,-4
            goto failed;
ffffffffc0203ec6:	bfc9                	j	ffffffffc0203e98 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203ec8:	85a2                	mv	a1,s0
ffffffffc0203eca:	00002517          	auipc	a0,0x2
ffffffffc0203ece:	2ee50513          	addi	a0,a0,750 # ffffffffc02061b8 <default_pmm_manager+0xed8>
ffffffffc0203ed2:	9e8fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203ed6:	5575                	li	a0,-3
        goto failed;
ffffffffc0203ed8:	b7c1                	j	ffffffffc0203e98 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203eda:	00002517          	auipc	a0,0x2
ffffffffc0203ede:	33650513          	addi	a0,a0,822 # ffffffffc0206210 <default_pmm_manager+0xf30>
ffffffffc0203ee2:	9d8fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ee6:	5571                	li	a0,-4
            goto failed;
ffffffffc0203ee8:	bf45                	j	ffffffffc0203e98 <do_pgfault+0x7c>

ffffffffc0203eea <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203eea:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203eec:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203eee:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ef0:	da4fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203ef4:	cd01                	beqz	a0,ffffffffc0203f0c <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ef6:	4505                	li	a0,1
ffffffffc0203ef8:	da2fc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203efc:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203efe:	810d                	srli	a0,a0,0x3
ffffffffc0203f00:	0000d797          	auipc	a5,0xd
ffffffffc0203f04:	64a7b023          	sd	a0,1600(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203f08:	0141                	addi	sp,sp,16
ffffffffc0203f0a:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203f0c:	00002617          	auipc	a2,0x2
ffffffffc0203f10:	32c60613          	addi	a2,a2,812 # ffffffffc0206238 <default_pmm_manager+0xf58>
ffffffffc0203f14:	45b5                	li	a1,13
ffffffffc0203f16:	00002517          	auipc	a0,0x2
ffffffffc0203f1a:	34250513          	addi	a0,a0,834 # ffffffffc0206258 <default_pmm_manager+0xf78>
ffffffffc0203f1e:	c56fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f22 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203f22:	1141                	addi	sp,sp,-16
ffffffffc0203f24:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f26:	00855793          	srli	a5,a0,0x8
ffffffffc0203f2a:	c3a5                	beqz	a5,ffffffffc0203f8a <swapfs_read+0x68>
ffffffffc0203f2c:	0000d717          	auipc	a4,0xd
ffffffffc0203f30:	61473703          	ld	a4,1556(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203f34:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f8a <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f38:	0000d617          	auipc	a2,0xd
ffffffffc0203f3c:	5f063603          	ld	a2,1520(a2) # ffffffffc0211528 <pages>
ffffffffc0203f40:	8d91                	sub	a1,a1,a2
ffffffffc0203f42:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f46:	00002597          	auipc	a1,0x2
ffffffffc0203f4a:	5925b583          	ld	a1,1426(a1) # ffffffffc02064d8 <error_string+0x38>
ffffffffc0203f4e:	02b60633          	mul	a2,a2,a1
ffffffffc0203f52:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f56:	00002797          	auipc	a5,0x2
ffffffffc0203f5a:	58a7b783          	ld	a5,1418(a5) # ffffffffc02064e0 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f5e:	0000d717          	auipc	a4,0xd
ffffffffc0203f62:	5c273703          	ld	a4,1474(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f66:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f68:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f6c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f6e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f70:	02e7f963          	bgeu	a5,a4,ffffffffc0203fa2 <swapfs_read+0x80>
}
ffffffffc0203f74:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f76:	0000d797          	auipc	a5,0xd
ffffffffc0203f7a:	5c27b783          	ld	a5,1474(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203f7e:	46a1                	li	a3,8
ffffffffc0203f80:	963e                	add	a2,a2,a5
ffffffffc0203f82:	4505                	li	a0,1
}
ffffffffc0203f84:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f86:	d1afc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203f8a:	86aa                	mv	a3,a0
ffffffffc0203f8c:	00002617          	auipc	a2,0x2
ffffffffc0203f90:	2e460613          	addi	a2,a2,740 # ffffffffc0206270 <default_pmm_manager+0xf90>
ffffffffc0203f94:	45d1                	li	a1,20
ffffffffc0203f96:	00002517          	auipc	a0,0x2
ffffffffc0203f9a:	2c250513          	addi	a0,a0,706 # ffffffffc0206258 <default_pmm_manager+0xf78>
ffffffffc0203f9e:	bd6fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203fa2:	86b2                	mv	a3,a2
ffffffffc0203fa4:	06a00593          	li	a1,106
ffffffffc0203fa8:	00001617          	auipc	a2,0x1
ffffffffc0203fac:	3c860613          	addi	a2,a2,968 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc0203fb0:	00001517          	auipc	a0,0x1
ffffffffc0203fb4:	38850513          	addi	a0,a0,904 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc0203fb8:	bbcfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203fbc <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203fbc:	1141                	addi	sp,sp,-16
ffffffffc0203fbe:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fc0:	00855793          	srli	a5,a0,0x8
ffffffffc0203fc4:	c3a5                	beqz	a5,ffffffffc0204024 <swapfs_write+0x68>
ffffffffc0203fc6:	0000d717          	auipc	a4,0xd
ffffffffc0203fca:	57a73703          	ld	a4,1402(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203fce:	04e7fb63          	bgeu	a5,a4,ffffffffc0204024 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fd2:	0000d617          	auipc	a2,0xd
ffffffffc0203fd6:	55663603          	ld	a2,1366(a2) # ffffffffc0211528 <pages>
ffffffffc0203fda:	8d91                	sub	a1,a1,a2
ffffffffc0203fdc:	4035d613          	srai	a2,a1,0x3
ffffffffc0203fe0:	00002597          	auipc	a1,0x2
ffffffffc0203fe4:	4f85b583          	ld	a1,1272(a1) # ffffffffc02064d8 <error_string+0x38>
ffffffffc0203fe8:	02b60633          	mul	a2,a2,a1
ffffffffc0203fec:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ff0:	00002797          	auipc	a5,0x2
ffffffffc0203ff4:	4f07b783          	ld	a5,1264(a5) # ffffffffc02064e0 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ff8:	0000d717          	auipc	a4,0xd
ffffffffc0203ffc:	52873703          	ld	a4,1320(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0204000:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204002:	00c61793          	slli	a5,a2,0xc
ffffffffc0204006:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204008:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020400a:	02e7f963          	bgeu	a5,a4,ffffffffc020403c <swapfs_write+0x80>
}
ffffffffc020400e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204010:	0000d797          	auipc	a5,0xd
ffffffffc0204014:	5287b783          	ld	a5,1320(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0204018:	46a1                	li	a3,8
ffffffffc020401a:	963e                	add	a2,a2,a5
ffffffffc020401c:	4505                	li	a0,1
}
ffffffffc020401e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204020:	ca4fc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0204024:	86aa                	mv	a3,a0
ffffffffc0204026:	00002617          	auipc	a2,0x2
ffffffffc020402a:	24a60613          	addi	a2,a2,586 # ffffffffc0206270 <default_pmm_manager+0xf90>
ffffffffc020402e:	45e5                	li	a1,25
ffffffffc0204030:	00002517          	auipc	a0,0x2
ffffffffc0204034:	22850513          	addi	a0,a0,552 # ffffffffc0206258 <default_pmm_manager+0xf78>
ffffffffc0204038:	b3cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020403c:	86b2                	mv	a3,a2
ffffffffc020403e:	06a00593          	li	a1,106
ffffffffc0204042:	00001617          	auipc	a2,0x1
ffffffffc0204046:	32e60613          	addi	a2,a2,814 # ffffffffc0205370 <default_pmm_manager+0x90>
ffffffffc020404a:	00001517          	auipc	a0,0x1
ffffffffc020404e:	2ee50513          	addi	a0,a0,750 # ffffffffc0205338 <default_pmm_manager+0x58>
ffffffffc0204052:	b22fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0204056 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204056:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020405a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020405c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204060:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204062:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204066:	f022                	sd	s0,32(sp)
ffffffffc0204068:	ec26                	sd	s1,24(sp)
ffffffffc020406a:	e84a                	sd	s2,16(sp)
ffffffffc020406c:	f406                	sd	ra,40(sp)
ffffffffc020406e:	e44e                	sd	s3,8(sp)
ffffffffc0204070:	84aa                	mv	s1,a0
ffffffffc0204072:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204074:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204078:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020407a:	03067e63          	bgeu	a2,a6,ffffffffc02040b6 <printnum+0x60>
ffffffffc020407e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204080:	00805763          	blez	s0,ffffffffc020408e <printnum+0x38>
ffffffffc0204084:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204086:	85ca                	mv	a1,s2
ffffffffc0204088:	854e                	mv	a0,s3
ffffffffc020408a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020408c:	fc65                	bnez	s0,ffffffffc0204084 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020408e:	1a02                	slli	s4,s4,0x20
ffffffffc0204090:	00002797          	auipc	a5,0x2
ffffffffc0204094:	20078793          	addi	a5,a5,512 # ffffffffc0206290 <default_pmm_manager+0xfb0>
ffffffffc0204098:	020a5a13          	srli	s4,s4,0x20
ffffffffc020409c:	9a3e                	add	s4,s4,a5
}
ffffffffc020409e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040a0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02040a4:	70a2                	ld	ra,40(sp)
ffffffffc02040a6:	69a2                	ld	s3,8(sp)
ffffffffc02040a8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040aa:	85ca                	mv	a1,s2
ffffffffc02040ac:	87a6                	mv	a5,s1
}
ffffffffc02040ae:	6942                	ld	s2,16(sp)
ffffffffc02040b0:	64e2                	ld	s1,24(sp)
ffffffffc02040b2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040b4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02040b6:	03065633          	divu	a2,a2,a6
ffffffffc02040ba:	8722                	mv	a4,s0
ffffffffc02040bc:	f9bff0ef          	jal	ra,ffffffffc0204056 <printnum>
ffffffffc02040c0:	b7f9                	j	ffffffffc020408e <printnum+0x38>

ffffffffc02040c2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02040c2:	7119                	addi	sp,sp,-128
ffffffffc02040c4:	f4a6                	sd	s1,104(sp)
ffffffffc02040c6:	f0ca                	sd	s2,96(sp)
ffffffffc02040c8:	ecce                	sd	s3,88(sp)
ffffffffc02040ca:	e8d2                	sd	s4,80(sp)
ffffffffc02040cc:	e4d6                	sd	s5,72(sp)
ffffffffc02040ce:	e0da                	sd	s6,64(sp)
ffffffffc02040d0:	fc5e                	sd	s7,56(sp)
ffffffffc02040d2:	f06a                	sd	s10,32(sp)
ffffffffc02040d4:	fc86                	sd	ra,120(sp)
ffffffffc02040d6:	f8a2                	sd	s0,112(sp)
ffffffffc02040d8:	f862                	sd	s8,48(sp)
ffffffffc02040da:	f466                	sd	s9,40(sp)
ffffffffc02040dc:	ec6e                	sd	s11,24(sp)
ffffffffc02040de:	892a                	mv	s2,a0
ffffffffc02040e0:	84ae                	mv	s1,a1
ffffffffc02040e2:	8d32                	mv	s10,a2
ffffffffc02040e4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040e6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02040ea:	5b7d                	li	s6,-1
ffffffffc02040ec:	00002a97          	auipc	s5,0x2
ffffffffc02040f0:	1d8a8a93          	addi	s5,s5,472 # ffffffffc02062c4 <default_pmm_manager+0xfe4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02040f4:	00002b97          	auipc	s7,0x2
ffffffffc02040f8:	3acb8b93          	addi	s7,s7,940 # ffffffffc02064a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040fc:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204100:	001d0413          	addi	s0,s10,1
ffffffffc0204104:	01350a63          	beq	a0,s3,ffffffffc0204118 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204108:	c121                	beqz	a0,ffffffffc0204148 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020410a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020410c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020410e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204110:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204114:	ff351ae3          	bne	a0,s3,ffffffffc0204108 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204118:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020411c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204120:	4c81                	li	s9,0
ffffffffc0204122:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204124:	5c7d                	li	s8,-1
ffffffffc0204126:	5dfd                	li	s11,-1
ffffffffc0204128:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020412c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204132:	0ff5f593          	zext.b	a1,a1
ffffffffc0204136:	00140d13          	addi	s10,s0,1
ffffffffc020413a:	04b56263          	bltu	a0,a1,ffffffffc020417e <vprintfmt+0xbc>
ffffffffc020413e:	058a                	slli	a1,a1,0x2
ffffffffc0204140:	95d6                	add	a1,a1,s5
ffffffffc0204142:	4194                	lw	a3,0(a1)
ffffffffc0204144:	96d6                	add	a3,a3,s5
ffffffffc0204146:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204148:	70e6                	ld	ra,120(sp)
ffffffffc020414a:	7446                	ld	s0,112(sp)
ffffffffc020414c:	74a6                	ld	s1,104(sp)
ffffffffc020414e:	7906                	ld	s2,96(sp)
ffffffffc0204150:	69e6                	ld	s3,88(sp)
ffffffffc0204152:	6a46                	ld	s4,80(sp)
ffffffffc0204154:	6aa6                	ld	s5,72(sp)
ffffffffc0204156:	6b06                	ld	s6,64(sp)
ffffffffc0204158:	7be2                	ld	s7,56(sp)
ffffffffc020415a:	7c42                	ld	s8,48(sp)
ffffffffc020415c:	7ca2                	ld	s9,40(sp)
ffffffffc020415e:	7d02                	ld	s10,32(sp)
ffffffffc0204160:	6de2                	ld	s11,24(sp)
ffffffffc0204162:	6109                	addi	sp,sp,128
ffffffffc0204164:	8082                	ret
            padc = '0';
ffffffffc0204166:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204168:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020416c:	846a                	mv	s0,s10
ffffffffc020416e:	00140d13          	addi	s10,s0,1
ffffffffc0204172:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204176:	0ff5f593          	zext.b	a1,a1
ffffffffc020417a:	fcb572e3          	bgeu	a0,a1,ffffffffc020413e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020417e:	85a6                	mv	a1,s1
ffffffffc0204180:	02500513          	li	a0,37
ffffffffc0204184:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204186:	fff44783          	lbu	a5,-1(s0)
ffffffffc020418a:	8d22                	mv	s10,s0
ffffffffc020418c:	f73788e3          	beq	a5,s3,ffffffffc02040fc <vprintfmt+0x3a>
ffffffffc0204190:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204194:	1d7d                	addi	s10,s10,-1
ffffffffc0204196:	ff379de3          	bne	a5,s3,ffffffffc0204190 <vprintfmt+0xce>
ffffffffc020419a:	b78d                	j	ffffffffc02040fc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020419c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02041a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041a4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02041a6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02041aa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02041ae:	02d86463          	bltu	a6,a3,ffffffffc02041d6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02041b2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02041b6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02041ba:	0186873b          	addw	a4,a3,s8
ffffffffc02041be:	0017171b          	slliw	a4,a4,0x1
ffffffffc02041c2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02041c4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02041c8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02041ca:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02041ce:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02041d2:	fed870e3          	bgeu	a6,a3,ffffffffc02041b2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02041d6:	f40ddce3          	bgez	s11,ffffffffc020412e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02041da:	8de2                	mv	s11,s8
ffffffffc02041dc:	5c7d                	li	s8,-1
ffffffffc02041de:	bf81                	j	ffffffffc020412e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02041e0:	fffdc693          	not	a3,s11
ffffffffc02041e4:	96fd                	srai	a3,a3,0x3f
ffffffffc02041e6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ea:	00144603          	lbu	a2,1(s0)
ffffffffc02041ee:	2d81                	sext.w	s11,s11
ffffffffc02041f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041f2:	bf35                	j	ffffffffc020412e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02041f4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041f8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02041fc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041fe:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204200:	bfd9                	j	ffffffffc02041d6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204202:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204204:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204208:	01174463          	blt	a4,a7,ffffffffc0204210 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020420c:	1a088e63          	beqz	a7,ffffffffc02043c8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204210:	000a3603          	ld	a2,0(s4)
ffffffffc0204214:	46c1                	li	a3,16
ffffffffc0204216:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204218:	2781                	sext.w	a5,a5
ffffffffc020421a:	876e                	mv	a4,s11
ffffffffc020421c:	85a6                	mv	a1,s1
ffffffffc020421e:	854a                	mv	a0,s2
ffffffffc0204220:	e37ff0ef          	jal	ra,ffffffffc0204056 <printnum>
            break;
ffffffffc0204224:	bde1                	j	ffffffffc02040fc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204226:	000a2503          	lw	a0,0(s4)
ffffffffc020422a:	85a6                	mv	a1,s1
ffffffffc020422c:	0a21                	addi	s4,s4,8
ffffffffc020422e:	9902                	jalr	s2
            break;
ffffffffc0204230:	b5f1                	j	ffffffffc02040fc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204232:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204234:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204238:	01174463          	blt	a4,a7,ffffffffc0204240 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020423c:	18088163          	beqz	a7,ffffffffc02043be <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204240:	000a3603          	ld	a2,0(s4)
ffffffffc0204244:	46a9                	li	a3,10
ffffffffc0204246:	8a2e                	mv	s4,a1
ffffffffc0204248:	bfc1                	j	ffffffffc0204218 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020424a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020424e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204250:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204252:	bdf1                	j	ffffffffc020412e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204254:	85a6                	mv	a1,s1
ffffffffc0204256:	02500513          	li	a0,37
ffffffffc020425a:	9902                	jalr	s2
            break;
ffffffffc020425c:	b545                	j	ffffffffc02040fc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020425e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204262:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204264:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204266:	b5e1                	j	ffffffffc020412e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204268:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020426a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020426e:	01174463          	blt	a4,a7,ffffffffc0204276 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204272:	14088163          	beqz	a7,ffffffffc02043b4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204276:	000a3603          	ld	a2,0(s4)
ffffffffc020427a:	46a1                	li	a3,8
ffffffffc020427c:	8a2e                	mv	s4,a1
ffffffffc020427e:	bf69                	j	ffffffffc0204218 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204280:	03000513          	li	a0,48
ffffffffc0204284:	85a6                	mv	a1,s1
ffffffffc0204286:	e03e                	sd	a5,0(sp)
ffffffffc0204288:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020428a:	85a6                	mv	a1,s1
ffffffffc020428c:	07800513          	li	a0,120
ffffffffc0204290:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204292:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204294:	6782                	ld	a5,0(sp)
ffffffffc0204296:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204298:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020429c:	bfb5                	j	ffffffffc0204218 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020429e:	000a3403          	ld	s0,0(s4)
ffffffffc02042a2:	008a0713          	addi	a4,s4,8
ffffffffc02042a6:	e03a                	sd	a4,0(sp)
ffffffffc02042a8:	14040263          	beqz	s0,ffffffffc02043ec <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02042ac:	0fb05763          	blez	s11,ffffffffc020439a <vprintfmt+0x2d8>
ffffffffc02042b0:	02d00693          	li	a3,45
ffffffffc02042b4:	0cd79163          	bne	a5,a3,ffffffffc0204376 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042b8:	00044783          	lbu	a5,0(s0)
ffffffffc02042bc:	0007851b          	sext.w	a0,a5
ffffffffc02042c0:	cf85                	beqz	a5,ffffffffc02042f8 <vprintfmt+0x236>
ffffffffc02042c2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042c6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042ca:	000c4563          	bltz	s8,ffffffffc02042d4 <vprintfmt+0x212>
ffffffffc02042ce:	3c7d                	addiw	s8,s8,-1
ffffffffc02042d0:	036c0263          	beq	s8,s6,ffffffffc02042f4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02042d4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042d6:	0e0c8e63          	beqz	s9,ffffffffc02043d2 <vprintfmt+0x310>
ffffffffc02042da:	3781                	addiw	a5,a5,-32
ffffffffc02042dc:	0ef47b63          	bgeu	s0,a5,ffffffffc02043d2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02042e0:	03f00513          	li	a0,63
ffffffffc02042e4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042e6:	000a4783          	lbu	a5,0(s4)
ffffffffc02042ea:	3dfd                	addiw	s11,s11,-1
ffffffffc02042ec:	0a05                	addi	s4,s4,1
ffffffffc02042ee:	0007851b          	sext.w	a0,a5
ffffffffc02042f2:	ffe1                	bnez	a5,ffffffffc02042ca <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02042f4:	01b05963          	blez	s11,ffffffffc0204306 <vprintfmt+0x244>
ffffffffc02042f8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02042fa:	85a6                	mv	a1,s1
ffffffffc02042fc:	02000513          	li	a0,32
ffffffffc0204300:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204302:	fe0d9be3          	bnez	s11,ffffffffc02042f8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204306:	6a02                	ld	s4,0(sp)
ffffffffc0204308:	bbd5                	j	ffffffffc02040fc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020430a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020430c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204310:	01174463          	blt	a4,a7,ffffffffc0204318 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204314:	08088d63          	beqz	a7,ffffffffc02043ae <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204318:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020431c:	0a044d63          	bltz	s0,ffffffffc02043d6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204320:	8622                	mv	a2,s0
ffffffffc0204322:	8a66                	mv	s4,s9
ffffffffc0204324:	46a9                	li	a3,10
ffffffffc0204326:	bdcd                	j	ffffffffc0204218 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204328:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020432c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020432e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204330:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204334:	8fb5                	xor	a5,a5,a3
ffffffffc0204336:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020433a:	02d74163          	blt	a4,a3,ffffffffc020435c <vprintfmt+0x29a>
ffffffffc020433e:	00369793          	slli	a5,a3,0x3
ffffffffc0204342:	97de                	add	a5,a5,s7
ffffffffc0204344:	639c                	ld	a5,0(a5)
ffffffffc0204346:	cb99                	beqz	a5,ffffffffc020435c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204348:	86be                	mv	a3,a5
ffffffffc020434a:	00002617          	auipc	a2,0x2
ffffffffc020434e:	f7660613          	addi	a2,a2,-138 # ffffffffc02062c0 <default_pmm_manager+0xfe0>
ffffffffc0204352:	85a6                	mv	a1,s1
ffffffffc0204354:	854a                	mv	a0,s2
ffffffffc0204356:	0ce000ef          	jal	ra,ffffffffc0204424 <printfmt>
ffffffffc020435a:	b34d                	j	ffffffffc02040fc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020435c:	00002617          	auipc	a2,0x2
ffffffffc0204360:	f5460613          	addi	a2,a2,-172 # ffffffffc02062b0 <default_pmm_manager+0xfd0>
ffffffffc0204364:	85a6                	mv	a1,s1
ffffffffc0204366:	854a                	mv	a0,s2
ffffffffc0204368:	0bc000ef          	jal	ra,ffffffffc0204424 <printfmt>
ffffffffc020436c:	bb41                	j	ffffffffc02040fc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020436e:	00002417          	auipc	s0,0x2
ffffffffc0204372:	f3a40413          	addi	s0,s0,-198 # ffffffffc02062a8 <default_pmm_manager+0xfc8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204376:	85e2                	mv	a1,s8
ffffffffc0204378:	8522                	mv	a0,s0
ffffffffc020437a:	e43e                	sd	a5,8(sp)
ffffffffc020437c:	196000ef          	jal	ra,ffffffffc0204512 <strnlen>
ffffffffc0204380:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204384:	01b05b63          	blez	s11,ffffffffc020439a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204388:	67a2                	ld	a5,8(sp)
ffffffffc020438a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020438e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204390:	85a6                	mv	a1,s1
ffffffffc0204392:	8552                	mv	a0,s4
ffffffffc0204394:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204396:	fe0d9ce3          	bnez	s11,ffffffffc020438e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020439a:	00044783          	lbu	a5,0(s0)
ffffffffc020439e:	00140a13          	addi	s4,s0,1
ffffffffc02043a2:	0007851b          	sext.w	a0,a5
ffffffffc02043a6:	d3a5                	beqz	a5,ffffffffc0204306 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043a8:	05e00413          	li	s0,94
ffffffffc02043ac:	bf39                	j	ffffffffc02042ca <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02043ae:	000a2403          	lw	s0,0(s4)
ffffffffc02043b2:	b7ad                	j	ffffffffc020431c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02043b4:	000a6603          	lwu	a2,0(s4)
ffffffffc02043b8:	46a1                	li	a3,8
ffffffffc02043ba:	8a2e                	mv	s4,a1
ffffffffc02043bc:	bdb1                	j	ffffffffc0204218 <vprintfmt+0x156>
ffffffffc02043be:	000a6603          	lwu	a2,0(s4)
ffffffffc02043c2:	46a9                	li	a3,10
ffffffffc02043c4:	8a2e                	mv	s4,a1
ffffffffc02043c6:	bd89                	j	ffffffffc0204218 <vprintfmt+0x156>
ffffffffc02043c8:	000a6603          	lwu	a2,0(s4)
ffffffffc02043cc:	46c1                	li	a3,16
ffffffffc02043ce:	8a2e                	mv	s4,a1
ffffffffc02043d0:	b5a1                	j	ffffffffc0204218 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02043d2:	9902                	jalr	s2
ffffffffc02043d4:	bf09                	j	ffffffffc02042e6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02043d6:	85a6                	mv	a1,s1
ffffffffc02043d8:	02d00513          	li	a0,45
ffffffffc02043dc:	e03e                	sd	a5,0(sp)
ffffffffc02043de:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02043e0:	6782                	ld	a5,0(sp)
ffffffffc02043e2:	8a66                	mv	s4,s9
ffffffffc02043e4:	40800633          	neg	a2,s0
ffffffffc02043e8:	46a9                	li	a3,10
ffffffffc02043ea:	b53d                	j	ffffffffc0204218 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02043ec:	03b05163          	blez	s11,ffffffffc020440e <vprintfmt+0x34c>
ffffffffc02043f0:	02d00693          	li	a3,45
ffffffffc02043f4:	f6d79de3          	bne	a5,a3,ffffffffc020436e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02043f8:	00002417          	auipc	s0,0x2
ffffffffc02043fc:	eb040413          	addi	s0,s0,-336 # ffffffffc02062a8 <default_pmm_manager+0xfc8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204400:	02800793          	li	a5,40
ffffffffc0204404:	02800513          	li	a0,40
ffffffffc0204408:	00140a13          	addi	s4,s0,1
ffffffffc020440c:	bd6d                	j	ffffffffc02042c6 <vprintfmt+0x204>
ffffffffc020440e:	00002a17          	auipc	s4,0x2
ffffffffc0204412:	e9ba0a13          	addi	s4,s4,-357 # ffffffffc02062a9 <default_pmm_manager+0xfc9>
ffffffffc0204416:	02800513          	li	a0,40
ffffffffc020441a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020441e:	05e00413          	li	s0,94
ffffffffc0204422:	b565                	j	ffffffffc02042ca <vprintfmt+0x208>

ffffffffc0204424 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204424:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204426:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020442a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020442c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020442e:	ec06                	sd	ra,24(sp)
ffffffffc0204430:	f83a                	sd	a4,48(sp)
ffffffffc0204432:	fc3e                	sd	a5,56(sp)
ffffffffc0204434:	e0c2                	sd	a6,64(sp)
ffffffffc0204436:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204438:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020443a:	c89ff0ef          	jal	ra,ffffffffc02040c2 <vprintfmt>
}
ffffffffc020443e:	60e2                	ld	ra,24(sp)
ffffffffc0204440:	6161                	addi	sp,sp,80
ffffffffc0204442:	8082                	ret

ffffffffc0204444 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204444:	715d                	addi	sp,sp,-80
ffffffffc0204446:	e486                	sd	ra,72(sp)
ffffffffc0204448:	e0a6                	sd	s1,64(sp)
ffffffffc020444a:	fc4a                	sd	s2,56(sp)
ffffffffc020444c:	f84e                	sd	s3,48(sp)
ffffffffc020444e:	f452                	sd	s4,40(sp)
ffffffffc0204450:	f056                	sd	s5,32(sp)
ffffffffc0204452:	ec5a                	sd	s6,24(sp)
ffffffffc0204454:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204456:	c901                	beqz	a0,ffffffffc0204466 <readline+0x22>
ffffffffc0204458:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020445a:	00002517          	auipc	a0,0x2
ffffffffc020445e:	e6650513          	addi	a0,a0,-410 # ffffffffc02062c0 <default_pmm_manager+0xfe0>
ffffffffc0204462:	c59fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204466:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204468:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020446a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020446c:	4aa9                	li	s5,10
ffffffffc020446e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204470:	0000db97          	auipc	s7,0xd
ffffffffc0204474:	c88b8b93          	addi	s7,s7,-888 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204478:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020447c:	c77fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204480:	00054a63          	bltz	a0,ffffffffc0204494 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204484:	00a95a63          	bge	s2,a0,ffffffffc0204498 <readline+0x54>
ffffffffc0204488:	029a5263          	bge	s4,s1,ffffffffc02044ac <readline+0x68>
        c = getchar();
ffffffffc020448c:	c67fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204490:	fe055ae3          	bgez	a0,ffffffffc0204484 <readline+0x40>
            return NULL;
ffffffffc0204494:	4501                	li	a0,0
ffffffffc0204496:	a091                	j	ffffffffc02044da <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204498:	03351463          	bne	a0,s3,ffffffffc02044c0 <readline+0x7c>
ffffffffc020449c:	e8a9                	bnez	s1,ffffffffc02044ee <readline+0xaa>
        c = getchar();
ffffffffc020449e:	c55fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044a2:	fe0549e3          	bltz	a0,ffffffffc0204494 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044a6:	fea959e3          	bge	s2,a0,ffffffffc0204498 <readline+0x54>
ffffffffc02044aa:	4481                	li	s1,0
            cputchar(c);
ffffffffc02044ac:	e42a                	sd	a0,8(sp)
ffffffffc02044ae:	c43fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02044b2:	6522                	ld	a0,8(sp)
ffffffffc02044b4:	009b87b3          	add	a5,s7,s1
ffffffffc02044b8:	2485                	addiw	s1,s1,1
ffffffffc02044ba:	00a78023          	sb	a0,0(a5)
ffffffffc02044be:	bf7d                	j	ffffffffc020447c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02044c0:	01550463          	beq	a0,s5,ffffffffc02044c8 <readline+0x84>
ffffffffc02044c4:	fb651ce3          	bne	a0,s6,ffffffffc020447c <readline+0x38>
            cputchar(c);
ffffffffc02044c8:	c29fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02044cc:	0000d517          	auipc	a0,0xd
ffffffffc02044d0:	c2c50513          	addi	a0,a0,-980 # ffffffffc02110f8 <buf>
ffffffffc02044d4:	94aa                	add	s1,s1,a0
ffffffffc02044d6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02044da:	60a6                	ld	ra,72(sp)
ffffffffc02044dc:	6486                	ld	s1,64(sp)
ffffffffc02044de:	7962                	ld	s2,56(sp)
ffffffffc02044e0:	79c2                	ld	s3,48(sp)
ffffffffc02044e2:	7a22                	ld	s4,40(sp)
ffffffffc02044e4:	7a82                	ld	s5,32(sp)
ffffffffc02044e6:	6b62                	ld	s6,24(sp)
ffffffffc02044e8:	6bc2                	ld	s7,16(sp)
ffffffffc02044ea:	6161                	addi	sp,sp,80
ffffffffc02044ec:	8082                	ret
            cputchar(c);
ffffffffc02044ee:	4521                	li	a0,8
ffffffffc02044f0:	c01fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02044f4:	34fd                	addiw	s1,s1,-1
ffffffffc02044f6:	b759                	j	ffffffffc020447c <readline+0x38>

ffffffffc02044f8 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02044f8:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02044fc:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02044fe:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204500:	cb81                	beqz	a5,ffffffffc0204510 <strlen+0x18>
        cnt ++;
ffffffffc0204502:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204504:	00a707b3          	add	a5,a4,a0
ffffffffc0204508:	0007c783          	lbu	a5,0(a5)
ffffffffc020450c:	fbfd                	bnez	a5,ffffffffc0204502 <strlen+0xa>
ffffffffc020450e:	8082                	ret
    }
    return cnt;
}
ffffffffc0204510:	8082                	ret

ffffffffc0204512 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204512:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204514:	e589                	bnez	a1,ffffffffc020451e <strnlen+0xc>
ffffffffc0204516:	a811                	j	ffffffffc020452a <strnlen+0x18>
        cnt ++;
ffffffffc0204518:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020451a:	00f58863          	beq	a1,a5,ffffffffc020452a <strnlen+0x18>
ffffffffc020451e:	00f50733          	add	a4,a0,a5
ffffffffc0204522:	00074703          	lbu	a4,0(a4)
ffffffffc0204526:	fb6d                	bnez	a4,ffffffffc0204518 <strnlen+0x6>
ffffffffc0204528:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020452a:	852e                	mv	a0,a1
ffffffffc020452c:	8082                	ret

ffffffffc020452e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020452e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204530:	0005c703          	lbu	a4,0(a1)
ffffffffc0204534:	0785                	addi	a5,a5,1
ffffffffc0204536:	0585                	addi	a1,a1,1
ffffffffc0204538:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020453c:	fb75                	bnez	a4,ffffffffc0204530 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020453e:	8082                	ret

ffffffffc0204540 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204540:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204544:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204548:	cb89                	beqz	a5,ffffffffc020455a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020454a:	0505                	addi	a0,a0,1
ffffffffc020454c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020454e:	fee789e3          	beq	a5,a4,ffffffffc0204540 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204552:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204556:	9d19                	subw	a0,a0,a4
ffffffffc0204558:	8082                	ret
ffffffffc020455a:	4501                	li	a0,0
ffffffffc020455c:	bfed                	j	ffffffffc0204556 <strcmp+0x16>

ffffffffc020455e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020455e:	00054783          	lbu	a5,0(a0)
ffffffffc0204562:	c799                	beqz	a5,ffffffffc0204570 <strchr+0x12>
        if (*s == c) {
ffffffffc0204564:	00f58763          	beq	a1,a5,ffffffffc0204572 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204568:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020456c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020456e:	fbfd                	bnez	a5,ffffffffc0204564 <strchr+0x6>
    }
    return NULL;
ffffffffc0204570:	4501                	li	a0,0
}
ffffffffc0204572:	8082                	ret

ffffffffc0204574 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204574:	ca01                	beqz	a2,ffffffffc0204584 <memset+0x10>
ffffffffc0204576:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204578:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020457a:	0785                	addi	a5,a5,1
ffffffffc020457c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204580:	fec79de3          	bne	a5,a2,ffffffffc020457a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204584:	8082                	ret

ffffffffc0204586 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204586:	ca19                	beqz	a2,ffffffffc020459c <memcpy+0x16>
ffffffffc0204588:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020458a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020458c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204590:	0585                	addi	a1,a1,1
ffffffffc0204592:	0785                	addi	a5,a5,1
ffffffffc0204594:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204598:	fec59ae3          	bne	a1,a2,ffffffffc020458c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020459c:	8082                	ret
