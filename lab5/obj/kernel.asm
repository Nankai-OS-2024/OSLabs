
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020c2b7          	lui	t0,0xc020c
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
ffffffffc0200024:	c020c137          	lui	sp,0xc020c

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a8517          	auipc	a0,0xa8
ffffffffc0200036:	2c650513          	addi	a0,a0,710 # ffffffffc02a82f8 <buf>
ffffffffc020003a:	000b4617          	auipc	a2,0xb4
ffffffffc020003e:	82260613          	addi	a2,a2,-2014 # ffffffffc02b385c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	7ae060ef          	jal	ra,ffffffffc02067f8 <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	7d658593          	addi	a1,a1,2006 # ffffffffc0206828 <etext+0x6>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0206848 <etext+0x26>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	512020ef          	jal	ra,ffffffffc020257c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5de000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	528040ef          	jal	ra,ffffffffc020459e <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	6f7050ef          	jal	ra,ffffffffc0205f70 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	42a030ef          	jal	ra,ffffffffc02034ac <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b6000ef          	jal	ra,ffffffffc0200640 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	07a060ef          	jal	ra,ffffffffc0206108 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	7a850513          	addi	a0,a0,1960 # ffffffffc0206850 <etext+0x2e>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	000a8b97          	auipc	s7,0xa8
ffffffffc02000c2:	23ab8b93          	addi	s7,s7,570 # ffffffffc02a82f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	000a8517          	auipc	a0,0xa8
ffffffffc020011e:	1de50513          	addi	a0,a0,478 # ffffffffc02a82f8 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	286060ef          	jal	ra,ffffffffc02063fa <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020c028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	250060ef          	jal	ra,ffffffffc02063fa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	64e50513          	addi	a0,a0,1614 # ffffffffc0206858 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	65850513          	addi	a0,a0,1624 # ffffffffc0206878 <etext+0x56>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	5f658593          	addi	a1,a1,1526 # ffffffffc0206822 <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	66450513          	addi	a0,a0,1636 # ffffffffc0206898 <etext+0x76>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a8597          	auipc	a1,0xa8
ffffffffc0200244:	0b858593          	addi	a1,a1,184 # ffffffffc02a82f8 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	67050513          	addi	a0,a0,1648 # ffffffffc02068b8 <etext+0x96>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b3597          	auipc	a1,0xb3
ffffffffc0200258:	60858593          	addi	a1,a1,1544 # ffffffffc02b385c <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	67c50513          	addi	a0,a0,1660 # ffffffffc02068d8 <etext+0xb6>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b4597          	auipc	a1,0xb4
ffffffffc020026c:	9f358593          	addi	a1,a1,-1549 # ffffffffc02b3c5b <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	66e50513          	addi	a0,a0,1646 # ffffffffc02068f8 <etext+0xd6>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	69060613          	addi	a2,a2,1680 # ffffffffc0206928 <etext+0x106>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	69c50513          	addi	a0,a0,1692 # ffffffffc0206940 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	6a460613          	addi	a2,a2,1700 # ffffffffc0206958 <etext+0x136>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	6bc58593          	addi	a1,a1,1724 # ffffffffc0206978 <etext+0x156>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206980 <etext+0x15e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	6be60613          	addi	a2,a2,1726 # ffffffffc0206990 <etext+0x16e>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	6de58593          	addi	a1,a1,1758 # ffffffffc02069b8 <etext+0x196>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	69e50513          	addi	a0,a0,1694 # ffffffffc0206980 <etext+0x15e>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	6da60613          	addi	a2,a2,1754 # ffffffffc02069c8 <etext+0x1a6>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	6f258593          	addi	a1,a1,1778 # ffffffffc02069e8 <etext+0x1c6>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	68250513          	addi	a0,a0,1666 # ffffffffc0206980 <etext+0x15e>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	6c050513          	addi	a0,a0,1728 # ffffffffc02069f8 <etext+0x1d6>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	6c650513          	addi	a0,a0,1734 # ffffffffc0206a20 <etext+0x1fe>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4c8000ef          	jal	ra,ffffffffc0200834 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	720c0c13          	addi	s8,s8,1824 # ffffffffc0206a90 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	6d090913          	addi	s2,s2,1744 # ffffffffc0206a48 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	6d048493          	addi	s1,s1,1744 # ffffffffc0206a50 <etext+0x22e>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	6ceb0b13          	addi	s6,s6,1742 # ffffffffc0206a58 <etext+0x236>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	5e6a0a13          	addi	s4,s4,1510 # ffffffffc0206978 <etext+0x156>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	6dcd0d13          	addi	s10,s10,1756 # ffffffffc0206a90 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	402060ef          	jal	ra,ffffffffc02067c4 <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	3ee060ef          	jal	ra,ffffffffc02067c4 <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	3ce060ef          	jal	ra,ffffffffc02067e2 <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	390060ef          	jal	ra,ffffffffc02067e2 <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	60c50513          	addi	a0,a0,1548 # ffffffffc0206a78 <etext+0x256>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b3317          	auipc	t1,0xb3
ffffffffc020047e:	34630313          	addi	t1,t1,838 # ffffffffc02b37c0 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	63050513          	addi	a0,a0,1584 # ffffffffc0206ad8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	5d250513          	addi	a0,a0,1490 # ffffffffc0207a90 <default_pmm_manager+0x518>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	170000ef          	jal	ra,ffffffffc0200646 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	60650513          	addi	a0,a0,1542 # ffffffffc0206af8 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	57e50513          	addi	a0,a0,1406 # ffffffffc0207a90 <default_pmm_manager+0x518>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd580>
ffffffffc020052c:	000b3717          	auipc	a4,0xb3
ffffffffc0200530:	2af73223          	sd	a5,676(a4) # ffffffffc02b37d0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206b18 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b3797          	auipc	a5,0xb3
ffffffffc0200558:	2607ba23          	sd	zero,628(a5) # ffffffffc02b37c8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b3797          	auipc	a5,0xb3
ffffffffc0200566:	26e7b783          	ld	a5,622(a5) # ffffffffc02b37d0 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	zext.b	a0,a0
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	0ae000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a851                	j	ffffffffc0200640 <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	07c000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	062000ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f8:	000a8797          	auipc	a5,0xa8
ffffffffc02005fc:	10078793          	addi	a5,a5,256 # ffffffffc02a86f8 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200600:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200608:	95be                	add	a1,a1,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200610:	1fa060ef          	jal	ra,ffffffffc020680a <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc020061c:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200620:	000a8517          	auipc	a0,0xa8
ffffffffc0200624:	0d850513          	addi	a0,a0,216 # ffffffffc02a86f8 <ide>
                   size_t nsecs) {
ffffffffc0200628:	1141                	addi	sp,sp,-16
ffffffffc020062a:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062c:	953e                	add	a0,a0,a5
ffffffffc020062e:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200632:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200634:	1d6060ef          	jal	ra,ffffffffc020680a <memcpy>
    return 0;
}
ffffffffc0200638:	60a2                	ld	ra,8(sp)
ffffffffc020063a:	4501                	li	a0,0
ffffffffc020063c:	0141                	addi	sp,sp,16
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200646:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	4c850513          	addi	a0,a0,1224 # ffffffffc0206b38 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	4d050513          	addi	a0,a0,1232 # ffffffffc0206b50 <commands+0xc0>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	4da50513          	addi	a0,a0,1242 # ffffffffc0206b68 <commands+0xd8>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	4e450513          	addi	a0,a0,1252 # ffffffffc0206b80 <commands+0xf0>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206b98 <commands+0x108>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	4f850513          	addi	a0,a0,1272 # ffffffffc0206bb0 <commands+0x120>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	50250513          	addi	a0,a0,1282 # ffffffffc0206bc8 <commands+0x138>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	50c50513          	addi	a0,a0,1292 # ffffffffc0206be0 <commands+0x150>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	51650513          	addi	a0,a0,1302 # ffffffffc0206bf8 <commands+0x168>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	52050513          	addi	a0,a0,1312 # ffffffffc0206c10 <commands+0x180>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	52a50513          	addi	a0,a0,1322 # ffffffffc0206c28 <commands+0x198>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	53450513          	addi	a0,a0,1332 # ffffffffc0206c40 <commands+0x1b0>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	53e50513          	addi	a0,a0,1342 # ffffffffc0206c58 <commands+0x1c8>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	54850513          	addi	a0,a0,1352 # ffffffffc0206c70 <commands+0x1e0>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	55250513          	addi	a0,a0,1362 # ffffffffc0206c88 <commands+0x1f8>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	55c50513          	addi	a0,a0,1372 # ffffffffc0206ca0 <commands+0x210>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	56650513          	addi	a0,a0,1382 # ffffffffc0206cb8 <commands+0x228>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	57050513          	addi	a0,a0,1392 # ffffffffc0206cd0 <commands+0x240>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	57a50513          	addi	a0,a0,1402 # ffffffffc0206ce8 <commands+0x258>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	58450513          	addi	a0,a0,1412 # ffffffffc0206d00 <commands+0x270>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	58e50513          	addi	a0,a0,1422 # ffffffffc0206d18 <commands+0x288>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	59850513          	addi	a0,a0,1432 # ffffffffc0206d30 <commands+0x2a0>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	5a250513          	addi	a0,a0,1442 # ffffffffc0206d48 <commands+0x2b8>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206d60 <commands+0x2d0>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	5b650513          	addi	a0,a0,1462 # ffffffffc0206d78 <commands+0x2e8>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	5c050513          	addi	a0,a0,1472 # ffffffffc0206d90 <commands+0x300>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206da8 <commands+0x318>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	5d450513          	addi	a0,a0,1492 # ffffffffc0206dc0 <commands+0x330>
ffffffffc02007f4:	98dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	5de50513          	addi	a0,a0,1502 # ffffffffc0206dd8 <commands+0x348>
ffffffffc0200802:	97fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	5e850513          	addi	a0,a0,1512 # ffffffffc0206df0 <commands+0x360>
ffffffffc0200810:	971ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	5f250513          	addi	a0,a0,1522 # ffffffffc0206e08 <commands+0x378>
ffffffffc020081e:	963ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	5f850513          	addi	a0,a0,1528 # ffffffffc0206e20 <commands+0x390>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	b2b9                	j	ffffffffc0200180 <cprintf>

ffffffffc0200834 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	1141                	addi	sp,sp,-16
ffffffffc0200836:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206e38 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200844:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	93bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084a:	8522                	mv	a0,s0
ffffffffc020084c:	e1dff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200850:	10043583          	ld	a1,256(s0)
ffffffffc0200854:	00006517          	auipc	a0,0x6
ffffffffc0200858:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206e50 <commands+0x3c0>
ffffffffc020085c:	925ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200860:	10843583          	ld	a1,264(s0)
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	60450513          	addi	a0,a0,1540 # ffffffffc0206e68 <commands+0x3d8>
ffffffffc020086c:	915ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200870:	11043583          	ld	a1,272(s0)
ffffffffc0200874:	00006517          	auipc	a0,0x6
ffffffffc0200878:	60c50513          	addi	a0,a0,1548 # ffffffffc0206e80 <commands+0x3f0>
ffffffffc020087c:	905ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	11843583          	ld	a1,280(s0)
}
ffffffffc0200884:	6402                	ld	s0,0(sp)
ffffffffc0200886:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200888:	00006517          	auipc	a0,0x6
ffffffffc020088c:	60850513          	addi	a0,a0,1544 # ffffffffc0206e90 <commands+0x400>
}
ffffffffc0200890:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200896 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200896:	1101                	addi	sp,sp,-32
ffffffffc0200898:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089a:	000b3497          	auipc	s1,0xb3
ffffffffc020089e:	f9648493          	addi	s1,s1,-106 # ffffffffc02b3830 <check_mm_struct>
ffffffffc02008a2:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	e822                	sd	s0,16(sp)
ffffffffc02008a6:	ec06                	sd	ra,24(sp)
ffffffffc02008a8:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008aa:	cbad                	beqz	a5,ffffffffc020091c <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ac:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b0:	11053583          	ld	a1,272(a0)
ffffffffc02008b4:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	c7b1                	beqz	a5,ffffffffc0200908 <pgfault_handler+0x72>
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05700693          	li	a3,87
ffffffffc02008c8:	00f70463          	beq	a4,a5,ffffffffc02008d0 <pgfault_handler+0x3a>
ffffffffc02008cc:	05200693          	li	a3,82
ffffffffc02008d0:	00006517          	auipc	a0,0x6
ffffffffc02008d4:	5d850513          	addi	a0,a0,1496 # ffffffffc0206ea8 <commands+0x418>
ffffffffc02008d8:	8a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008dc:	6088                	ld	a0,0(s1)
ffffffffc02008de:	cd1d                	beqz	a0,ffffffffc020091c <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e0:	000b3717          	auipc	a4,0xb3
ffffffffc02008e4:	f6073703          	ld	a4,-160(a4) # ffffffffc02b3840 <current>
ffffffffc02008e8:	000b3797          	auipc	a5,0xb3
ffffffffc02008ec:	f607b783          	ld	a5,-160(a5) # ffffffffc02b3848 <idleproc>
ffffffffc02008f0:	04f71663          	bne	a4,a5,ffffffffc020093c <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f4:	11043603          	ld	a2,272(s0)
ffffffffc02008f8:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fc:	6442                	ld	s0,16(sp)
ffffffffc02008fe:	60e2                	ld	ra,24(sp)
ffffffffc0200900:	64a2                	ld	s1,8(sp)
ffffffffc0200902:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	1c60406f          	j	ffffffffc0204aca <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200908:	11843703          	ld	a4,280(s0)
ffffffffc020090c:	47bd                	li	a5,15
ffffffffc020090e:	05500613          	li	a2,85
ffffffffc0200912:	05700693          	li	a3,87
ffffffffc0200916:	faf71be3          	bne	a4,a5,ffffffffc02008cc <pgfault_handler+0x36>
ffffffffc020091a:	bf5d                	j	ffffffffc02008d0 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091c:	000b3797          	auipc	a5,0xb3
ffffffffc0200920:	f247b783          	ld	a5,-220(a5) # ffffffffc02b3840 <current>
ffffffffc0200924:	cf85                	beqz	a5,ffffffffc020095c <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200926:	11043603          	ld	a2,272(s0)
ffffffffc020092a:	11843583          	ld	a1,280(s0)
}
ffffffffc020092e:	6442                	ld	s0,16(sp)
ffffffffc0200930:	60e2                	ld	ra,24(sp)
ffffffffc0200932:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200934:	7788                	ld	a0,40(a5)
}
ffffffffc0200936:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	1920406f          	j	ffffffffc0204aca <do_pgfault>
        assert(current == idleproc);
ffffffffc020093c:	00006697          	auipc	a3,0x6
ffffffffc0200940:	58c68693          	addi	a3,a3,1420 # ffffffffc0206ec8 <commands+0x438>
ffffffffc0200944:	00006617          	auipc	a2,0x6
ffffffffc0200948:	59c60613          	addi	a2,a2,1436 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020094c:	06b00593          	li	a1,107
ffffffffc0200950:	00006517          	auipc	a0,0x6
ffffffffc0200954:	5a850513          	addi	a0,a0,1448 # ffffffffc0206ef8 <commands+0x468>
ffffffffc0200958:	b23ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	ed7ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200962:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200966:	11043583          	ld	a1,272(s0)
ffffffffc020096a:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020096e:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200972:	e399                	bnez	a5,ffffffffc0200978 <pgfault_handler+0xe2>
ffffffffc0200974:	05500613          	li	a2,85
ffffffffc0200978:	11843703          	ld	a4,280(s0)
ffffffffc020097c:	47bd                	li	a5,15
ffffffffc020097e:	02f70663          	beq	a4,a5,ffffffffc02009aa <pgfault_handler+0x114>
ffffffffc0200982:	05200693          	li	a3,82
ffffffffc0200986:	00006517          	auipc	a0,0x6
ffffffffc020098a:	52250513          	addi	a0,a0,1314 # ffffffffc0206ea8 <commands+0x418>
ffffffffc020098e:	ff2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200992:	00006617          	auipc	a2,0x6
ffffffffc0200996:	57e60613          	addi	a2,a2,1406 # ffffffffc0206f10 <commands+0x480>
ffffffffc020099a:	07200593          	li	a1,114
ffffffffc020099e:	00006517          	auipc	a0,0x6
ffffffffc02009a2:	55a50513          	addi	a0,a0,1370 # ffffffffc0206ef8 <commands+0x468>
ffffffffc02009a6:	ad5ff0ef          	jal	ra,ffffffffc020047a <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009aa:	05700693          	li	a3,87
ffffffffc02009ae:	bfe1                	j	ffffffffc0200986 <pgfault_handler+0xf0>

ffffffffc02009b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b0:	11853783          	ld	a5,280(a0)
ffffffffc02009b4:	472d                	li	a4,11
ffffffffc02009b6:	0786                	slli	a5,a5,0x1
ffffffffc02009b8:	8385                	srli	a5,a5,0x1
ffffffffc02009ba:	08f76363          	bltu	a4,a5,ffffffffc0200a40 <interrupt_handler+0x90>
ffffffffc02009be:	00006717          	auipc	a4,0x6
ffffffffc02009c2:	60a70713          	addi	a4,a4,1546 # ffffffffc0206fc8 <commands+0x538>
ffffffffc02009c6:	078a                	slli	a5,a5,0x2
ffffffffc02009c8:	97ba                	add	a5,a5,a4
ffffffffc02009ca:	439c                	lw	a5,0(a5)
ffffffffc02009cc:	97ba                	add	a5,a5,a4
ffffffffc02009ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	5b850513          	addi	a0,a0,1464 # ffffffffc0206f88 <commands+0x4f8>
ffffffffc02009d8:	fa8ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009dc:	00006517          	auipc	a0,0x6
ffffffffc02009e0:	58c50513          	addi	a0,a0,1420 # ffffffffc0206f68 <commands+0x4d8>
ffffffffc02009e4:	f9cff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e8:	00006517          	auipc	a0,0x6
ffffffffc02009ec:	54050513          	addi	a0,a0,1344 # ffffffffc0206f28 <commands+0x498>
ffffffffc02009f0:	f90ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f4:	00006517          	auipc	a0,0x6
ffffffffc02009f8:	55450513          	addi	a0,a0,1364 # ffffffffc0206f48 <commands+0x4b8>
ffffffffc02009fc:	f84ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a00:	1141                	addi	sp,sp,-16
ffffffffc0200a02:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a04:	b5bff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a08:	000b3697          	auipc	a3,0xb3
ffffffffc0200a0c:	dc068693          	addi	a3,a3,-576 # ffffffffc02b37c8 <ticks>
ffffffffc0200a10:	629c                	ld	a5,0(a3)
ffffffffc0200a12:	06400713          	li	a4,100
ffffffffc0200a16:	0785                	addi	a5,a5,1
ffffffffc0200a18:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1c:	e29c                	sd	a5,0(a3)
ffffffffc0200a1e:	eb01                	bnez	a4,ffffffffc0200a2e <interrupt_handler+0x7e>
ffffffffc0200a20:	000b3797          	auipc	a5,0xb3
ffffffffc0200a24:	e207b783          	ld	a5,-480(a5) # ffffffffc02b3840 <current>
ffffffffc0200a28:	c399                	beqz	a5,ffffffffc0200a2e <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2a:	4705                	li	a4,1
ffffffffc0200a2c:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a2e:	60a2                	ld	ra,8(sp)
ffffffffc0200a30:	0141                	addi	sp,sp,16
ffffffffc0200a32:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a34:	00006517          	auipc	a0,0x6
ffffffffc0200a38:	57450513          	addi	a0,a0,1396 # ffffffffc0206fa8 <commands+0x518>
ffffffffc0200a3c:	f44ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a40:	bbd5                	j	ffffffffc0200834 <print_trapframe>

ffffffffc0200a42 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a42:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a46:	1101                	addi	sp,sp,-32
ffffffffc0200a48:	e822                	sd	s0,16(sp)
ffffffffc0200a4a:	ec06                	sd	ra,24(sp)
ffffffffc0200a4c:	e426                	sd	s1,8(sp)
ffffffffc0200a4e:	473d                	li	a4,15
ffffffffc0200a50:	842a                	mv	s0,a0
ffffffffc0200a52:	18f76563          	bltu	a4,a5,ffffffffc0200bdc <exception_handler+0x19a>
ffffffffc0200a56:	00006717          	auipc	a4,0x6
ffffffffc0200a5a:	73a70713          	addi	a4,a4,1850 # ffffffffc0207190 <commands+0x700>
ffffffffc0200a5e:	078a                	slli	a5,a5,0x2
ffffffffc0200a60:	97ba                	add	a5,a5,a4
ffffffffc0200a62:	439c                	lw	a5,0(a5)
ffffffffc0200a64:	97ba                	add	a5,a5,a4
ffffffffc0200a66:	8782                	jr	a5
            //avoid repetitive execution
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a68:	00006517          	auipc	a0,0x6
ffffffffc0200a6c:	68050513          	addi	a0,a0,1664 # ffffffffc02070e8 <commands+0x658>
ffffffffc0200a70:	f10ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a74:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a78:	60e2                	ld	ra,24(sp)
ffffffffc0200a7a:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7c:	0791                	addi	a5,a5,4
ffffffffc0200a7e:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a86:	0730506f          	j	ffffffffc02062f8 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8a:	00006517          	auipc	a0,0x6
ffffffffc0200a8e:	67e50513          	addi	a0,a0,1662 # ffffffffc0207108 <commands+0x678>
}
ffffffffc0200a92:	6442                	ld	s0,16(sp)
ffffffffc0200a94:	60e2                	ld	ra,24(sp)
ffffffffc0200a96:	64a2                	ld	s1,8(sp)
ffffffffc0200a98:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9a:	ee6ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a9e:	00006517          	auipc	a0,0x6
ffffffffc0200aa2:	68a50513          	addi	a0,a0,1674 # ffffffffc0207128 <commands+0x698>
ffffffffc0200aa6:	b7f5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aa8:	00006517          	auipc	a0,0x6
ffffffffc0200aac:	6a050513          	addi	a0,a0,1696 # ffffffffc0207148 <commands+0x6b8>
ffffffffc0200ab0:	b7cd                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0207160 <commands+0x6d0>
ffffffffc0200aba:	ec6ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	dd7ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ac4:	84aa                	mv	s1,a0
ffffffffc0200ac6:	12051d63          	bnez	a0,ffffffffc0200c00 <exception_handler+0x1be>
}
ffffffffc0200aca:	60e2                	ld	ra,24(sp)
ffffffffc0200acc:	6442                	ld	s0,16(sp)
ffffffffc0200ace:	64a2                	ld	s1,8(sp)
ffffffffc0200ad0:	6105                	addi	sp,sp,32
ffffffffc0200ad2:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad4:	00006517          	auipc	a0,0x6
ffffffffc0200ad8:	6a450513          	addi	a0,a0,1700 # ffffffffc0207178 <commands+0x6e8>
ffffffffc0200adc:	ea4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae0:	8522                	mv	a0,s0
ffffffffc0200ae2:	db5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ae6:	84aa                	mv	s1,a0
ffffffffc0200ae8:	d16d                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aea:	8522                	mv	a0,s0
ffffffffc0200aec:	d49ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af0:	86a6                	mv	a3,s1
ffffffffc0200af2:	00006617          	auipc	a2,0x6
ffffffffc0200af6:	5a660613          	addi	a2,a2,1446 # ffffffffc0207098 <commands+0x608>
ffffffffc0200afa:	0f900593          	li	a1,249
ffffffffc0200afe:	00006517          	auipc	a0,0x6
ffffffffc0200b02:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206ef8 <commands+0x468>
ffffffffc0200b06:	975ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0a:	00006517          	auipc	a0,0x6
ffffffffc0200b0e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206ff8 <commands+0x568>
ffffffffc0200b12:	b741                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b14:	00006517          	auipc	a0,0x6
ffffffffc0200b18:	50450513          	addi	a0,a0,1284 # ffffffffc0207018 <commands+0x588>
ffffffffc0200b1c:	bf9d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	51a50513          	addi	a0,a0,1306 # ffffffffc0207038 <commands+0x5a8>
ffffffffc0200b26:	b7b5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b28:	00006517          	auipc	a0,0x6
ffffffffc0200b2c:	52850513          	addi	a0,a0,1320 # ffffffffc0207050 <commands+0x5c0>
ffffffffc0200b30:	e50ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b34:	6458                	ld	a4,136(s0)
ffffffffc0200b36:	47a9                	li	a5,10
ffffffffc0200b38:	f8f719e3          	bne	a4,a5,ffffffffc0200aca <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3c:	10843783          	ld	a5,264(s0)
ffffffffc0200b40:	0791                	addi	a5,a5,4
ffffffffc0200b42:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b46:	7b2050ef          	jal	ra,ffffffffc02062f8 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4a:	000b3797          	auipc	a5,0xb3
ffffffffc0200b4e:	cf67b783          	ld	a5,-778(a5) # ffffffffc02b3840 <current>
ffffffffc0200b52:	6b9c                	ld	a5,16(a5)
ffffffffc0200b54:	8522                	mv	a0,s0
}
ffffffffc0200b56:	6442                	ld	s0,16(sp)
ffffffffc0200b58:	60e2                	ld	ra,24(sp)
ffffffffc0200b5a:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6589                	lui	a1,0x2
ffffffffc0200b5e:	95be                	add	a1,a1,a5
}
ffffffffc0200b60:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b62:	ac21                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b64:	00006517          	auipc	a0,0x6
ffffffffc0200b68:	4fc50513          	addi	a0,a0,1276 # ffffffffc0207060 <commands+0x5d0>
ffffffffc0200b6c:	b71d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b6e:	00006517          	auipc	a0,0x6
ffffffffc0200b72:	51250513          	addi	a0,a0,1298 # ffffffffc0207080 <commands+0x5f0>
ffffffffc0200b76:	e0aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	d1bff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200b80:	84aa                	mv	s1,a0
ffffffffc0200b82:	d521                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b84:	8522                	mv	a0,s0
ffffffffc0200b86:	cafff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8a:	86a6                	mv	a3,s1
ffffffffc0200b8c:	00006617          	auipc	a2,0x6
ffffffffc0200b90:	50c60613          	addi	a2,a2,1292 # ffffffffc0207098 <commands+0x608>
ffffffffc0200b94:	0cd00593          	li	a1,205
ffffffffc0200b98:	00006517          	auipc	a0,0x6
ffffffffc0200b9c:	36050513          	addi	a0,a0,864 # ffffffffc0206ef8 <commands+0x468>
ffffffffc0200ba0:	8dbff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba4:	00006517          	auipc	a0,0x6
ffffffffc0200ba8:	52c50513          	addi	a0,a0,1324 # ffffffffc02070d0 <commands+0x640>
ffffffffc0200bac:	dd4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	ce5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200bb6:	84aa                	mv	s1,a0
ffffffffc0200bb8:	f00509e3          	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	c77ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc2:	86a6                	mv	a3,s1
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	4d460613          	addi	a2,a2,1236 # ffffffffc0207098 <commands+0x608>
ffffffffc0200bcc:	0d700593          	li	a1,215
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	32850513          	addi	a0,a0,808 # ffffffffc0206ef8 <commands+0x468>
ffffffffc0200bd8:	8a3ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200bdc:	8522                	mv	a0,s0
}
ffffffffc0200bde:	6442                	ld	s0,16(sp)
ffffffffc0200be0:	60e2                	ld	ra,24(sp)
ffffffffc0200be2:	64a2                	ld	s1,8(sp)
ffffffffc0200be4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be6:	b1b9                	j	ffffffffc0200834 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200be8:	00006617          	auipc	a2,0x6
ffffffffc0200bec:	4d060613          	addi	a2,a2,1232 # ffffffffc02070b8 <commands+0x628>
ffffffffc0200bf0:	0d100593          	li	a1,209
ffffffffc0200bf4:	00006517          	auipc	a0,0x6
ffffffffc0200bf8:	30450513          	addi	a0,a0,772 # ffffffffc0206ef8 <commands+0x468>
ffffffffc0200bfc:	87fff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200c00:	8522                	mv	a0,s0
ffffffffc0200c02:	c33ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c06:	86a6                	mv	a3,s1
ffffffffc0200c08:	00006617          	auipc	a2,0x6
ffffffffc0200c0c:	49060613          	addi	a2,a2,1168 # ffffffffc0207098 <commands+0x608>
ffffffffc0200c10:	0f200593          	li	a1,242
ffffffffc0200c14:	00006517          	auipc	a0,0x6
ffffffffc0200c18:	2e450513          	addi	a0,a0,740 # ffffffffc0206ef8 <commands+0x468>
ffffffffc0200c1c:	85fff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200c20 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c20:	1101                	addi	sp,sp,-32
ffffffffc0200c22:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c24:	000b3417          	auipc	s0,0xb3
ffffffffc0200c28:	c1c40413          	addi	s0,s0,-996 # ffffffffc02b3840 <current>
ffffffffc0200c2c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c2e:	ec06                	sd	ra,24(sp)
ffffffffc0200c30:	e426                	sd	s1,8(sp)
ffffffffc0200c32:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c38:	cf1d                	beqz	a4,ffffffffc0200c76 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c3e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c42:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c44:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c48:	0206c463          	bltz	a3,ffffffffc0200c70 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4c:	df7ff0ef          	jal	ra,ffffffffc0200a42 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c50:	601c                	ld	a5,0(s0)
ffffffffc0200c52:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c56:	e499                	bnez	s1,ffffffffc0200c64 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c58:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5c:	8b05                	andi	a4,a4,1
ffffffffc0200c5e:	e329                	bnez	a4,ffffffffc0200ca0 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c60:	6f9c                	ld	a5,24(a5)
ffffffffc0200c62:	eb85                	bnez	a5,ffffffffc0200c92 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
ffffffffc0200c66:	6442                	ld	s0,16(sp)
ffffffffc0200c68:	64a2                	ld	s1,8(sp)
ffffffffc0200c6a:	6902                	ld	s2,0(sp)
ffffffffc0200c6c:	6105                	addi	sp,sp,32
ffffffffc0200c6e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c70:	d41ff0ef          	jal	ra,ffffffffc02009b0 <interrupt_handler>
ffffffffc0200c74:	bff1                	j	ffffffffc0200c50 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c76:	0006c863          	bltz	a3,ffffffffc0200c86 <trap+0x66>
}
ffffffffc0200c7a:	6442                	ld	s0,16(sp)
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	64a2                	ld	s1,8(sp)
ffffffffc0200c80:	6902                	ld	s2,0(sp)
ffffffffc0200c82:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c84:	bb7d                	j	ffffffffc0200a42 <exception_handler>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c90:	b305                	j	ffffffffc02009b0 <interrupt_handler>
}
ffffffffc0200c92:	6442                	ld	s0,16(sp)
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	64a2                	ld	s1,8(sp)
ffffffffc0200c98:	6902                	ld	s2,0(sp)
ffffffffc0200c9a:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9c:	5700506f          	j	ffffffffc020620c <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca0:	555d                	li	a0,-9
ffffffffc0200ca2:	0b1040ef          	jal	ra,ffffffffc0205552 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca6:	601c                	ld	a5,0(s0)
ffffffffc0200ca8:	bf65                	j	ffffffffc0200c60 <trap+0x40>
	...

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f09ff0ef          	jal	ra,ffffffffc0200c20 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e22:	000af797          	auipc	a5,0xaf
ffffffffc0200e26:	8d678793          	addi	a5,a5,-1834 # ffffffffc02af6f8 <free_area>
ffffffffc0200e2a:	e79c                	sd	a5,8(a5)
ffffffffc0200e2c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e2e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e32:	8082                	ret

ffffffffc0200e34 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e34:	000af517          	auipc	a0,0xaf
ffffffffc0200e38:	8d456503          	lwu	a0,-1836(a0) # ffffffffc02af708 <free_area+0x10>
ffffffffc0200e3c:	8082                	ret

ffffffffc0200e3e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e3e:	715d                	addi	sp,sp,-80
ffffffffc0200e40:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e42:	000af417          	auipc	s0,0xaf
ffffffffc0200e46:	8b640413          	addi	s0,s0,-1866 # ffffffffc02af6f8 <free_area>
ffffffffc0200e4a:	641c                	ld	a5,8(s0)
ffffffffc0200e4c:	e486                	sd	ra,72(sp)
ffffffffc0200e4e:	fc26                	sd	s1,56(sp)
ffffffffc0200e50:	f84a                	sd	s2,48(sp)
ffffffffc0200e52:	f44e                	sd	s3,40(sp)
ffffffffc0200e54:	f052                	sd	s4,32(sp)
ffffffffc0200e56:	ec56                	sd	s5,24(sp)
ffffffffc0200e58:	e85a                	sd	s6,16(sp)
ffffffffc0200e5a:	e45e                	sd	s7,8(sp)
ffffffffc0200e5c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5e:	2a878d63          	beq	a5,s0,ffffffffc0201118 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e62:	4481                	li	s1,0
ffffffffc0200e64:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e66:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e6a:	8b09                	andi	a4,a4,2
ffffffffc0200e6c:	2a070a63          	beqz	a4,ffffffffc0201120 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e70:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e74:	679c                	ld	a5,8(a5)
ffffffffc0200e76:	2905                	addiw	s2,s2,1
ffffffffc0200e78:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7a:	fe8796e3          	bne	a5,s0,ffffffffc0200e66 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e7e:	89a6                	mv	s3,s1
ffffffffc0200e80:	733000ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0200e84:	6f351e63          	bne	a0,s3,ffffffffc0201580 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e88:	4505                	li	a0,1
ffffffffc0200e8a:	657000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200e8e:	8aaa                	mv	s5,a0
ffffffffc0200e90:	42050863          	beqz	a0,ffffffffc02012c0 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e94:	4505                	li	a0,1
ffffffffc0200e96:	64b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200e9a:	89aa                	mv	s3,a0
ffffffffc0200e9c:	70050263          	beqz	a0,ffffffffc02015a0 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ea0:	4505                	li	a0,1
ffffffffc0200ea2:	63f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200ea6:	8a2a                	mv	s4,a0
ffffffffc0200ea8:	48050c63          	beqz	a0,ffffffffc0201340 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200eac:	293a8a63          	beq	s5,s3,ffffffffc0201140 <default_check+0x302>
ffffffffc0200eb0:	28aa8863          	beq	s5,a0,ffffffffc0201140 <default_check+0x302>
ffffffffc0200eb4:	28a98663          	beq	s3,a0,ffffffffc0201140 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb8:	000aa783          	lw	a5,0(s5)
ffffffffc0200ebc:	2a079263          	bnez	a5,ffffffffc0201160 <default_check+0x322>
ffffffffc0200ec0:	0009a783          	lw	a5,0(s3)
ffffffffc0200ec4:	28079e63          	bnez	a5,ffffffffc0201160 <default_check+0x322>
ffffffffc0200ec8:	411c                	lw	a5,0(a0)
ffffffffc0200eca:	28079b63          	bnez	a5,ffffffffc0201160 <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ece:	000b3797          	auipc	a5,0xb3
ffffffffc0200ed2:	92a7b783          	ld	a5,-1750(a5) # ffffffffc02b37f8 <pages>
ffffffffc0200ed6:	40fa8733          	sub	a4,s5,a5
ffffffffc0200eda:	00008617          	auipc	a2,0x8
ffffffffc0200ede:	1be63603          	ld	a2,446(a2) # ffffffffc0209098 <nbase>
ffffffffc0200ee2:	8719                	srai	a4,a4,0x6
ffffffffc0200ee4:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ee6:	000b3697          	auipc	a3,0xb3
ffffffffc0200eea:	90a6b683          	ld	a3,-1782(a3) # ffffffffc02b37f0 <npage>
ffffffffc0200eee:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ef0:	0732                	slli	a4,a4,0xc
ffffffffc0200ef2:	28d77763          	bgeu	a4,a3,ffffffffc0201180 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ef6:	40f98733          	sub	a4,s3,a5
ffffffffc0200efa:	8719                	srai	a4,a4,0x6
ffffffffc0200efc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200efe:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f00:	4cd77063          	bgeu	a4,a3,ffffffffc02013c0 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200f04:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f08:	8799                	srai	a5,a5,0x6
ffffffffc0200f0a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f0c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f0e:	30d7f963          	bgeu	a5,a3,ffffffffc0201220 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200f12:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f14:	00043c03          	ld	s8,0(s0)
ffffffffc0200f18:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f1c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200f20:	e400                	sd	s0,8(s0)
ffffffffc0200f22:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f24:	000ae797          	auipc	a5,0xae
ffffffffc0200f28:	7e07a223          	sw	zero,2020(a5) # ffffffffc02af708 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f2c:	5b5000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f30:	2c051863          	bnez	a0,ffffffffc0201200 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200f34:	4585                	li	a1,1
ffffffffc0200f36:	8556                	mv	a0,s5
ffffffffc0200f38:	63b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p1);
ffffffffc0200f3c:	4585                	li	a1,1
ffffffffc0200f3e:	854e                	mv	a0,s3
ffffffffc0200f40:	633000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc0200f44:	4585                	li	a1,1
ffffffffc0200f46:	8552                	mv	a0,s4
ffffffffc0200f48:	62b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f4c:	4818                	lw	a4,16(s0)
ffffffffc0200f4e:	478d                	li	a5,3
ffffffffc0200f50:	28f71863          	bne	a4,a5,ffffffffc02011e0 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f54:	4505                	li	a0,1
ffffffffc0200f56:	58b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f5a:	89aa                	mv	s3,a0
ffffffffc0200f5c:	26050263          	beqz	a0,ffffffffc02011c0 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f60:	4505                	li	a0,1
ffffffffc0200f62:	57f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f66:	8aaa                	mv	s5,a0
ffffffffc0200f68:	3a050c63          	beqz	a0,ffffffffc0201320 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	573000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f72:	8a2a                	mv	s4,a0
ffffffffc0200f74:	38050663          	beqz	a0,ffffffffc0201300 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f78:	4505                	li	a0,1
ffffffffc0200f7a:	567000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f7e:	36051163          	bnez	a0,ffffffffc02012e0 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	854e                	mv	a0,s3
ffffffffc0200f86:	5ed000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f8a:	641c                	ld	a5,8(s0)
ffffffffc0200f8c:	20878a63          	beq	a5,s0,ffffffffc02011a0 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f90:	4505                	li	a0,1
ffffffffc0200f92:	54f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f96:	30a99563          	bne	s3,a0,ffffffffc02012a0 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f9a:	4505                	li	a0,1
ffffffffc0200f9c:	545000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200fa0:	2e051063          	bnez	a0,ffffffffc0201280 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200fa4:	481c                	lw	a5,16(s0)
ffffffffc0200fa6:	2a079d63          	bnez	a5,ffffffffc0201260 <default_check+0x422>
    free_page(p);
ffffffffc0200faa:	854e                	mv	a0,s3
ffffffffc0200fac:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fae:	01843023          	sd	s8,0(s0)
ffffffffc0200fb2:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200fb6:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200fba:	5b9000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p1);
ffffffffc0200fbe:	4585                	li	a1,1
ffffffffc0200fc0:	8556                	mv	a0,s5
ffffffffc0200fc2:	5b1000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc0200fc6:	4585                	li	a1,1
ffffffffc0200fc8:	8552                	mv	a0,s4
ffffffffc0200fca:	5a9000ef          	jal	ra,ffffffffc0201d72 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fce:	4515                	li	a0,5
ffffffffc0200fd0:	511000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200fd4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fd6:	26050563          	beqz	a0,ffffffffc0201240 <default_check+0x402>
ffffffffc0200fda:	651c                	ld	a5,8(a0)
ffffffffc0200fdc:	8385                	srli	a5,a5,0x1
ffffffffc0200fde:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200fe0:	54079063          	bnez	a5,ffffffffc0201520 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fe6:	00043b03          	ld	s6,0(s0)
ffffffffc0200fea:	00843a83          	ld	s5,8(s0)
ffffffffc0200fee:	e000                	sd	s0,0(s0)
ffffffffc0200ff0:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200ff2:	4ef000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200ff6:	50051563          	bnez	a0,ffffffffc0201500 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ffa:	08098a13          	addi	s4,s3,128
ffffffffc0200ffe:	8552                	mv	a0,s4
ffffffffc0201000:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201002:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201006:	000ae797          	auipc	a5,0xae
ffffffffc020100a:	7007a123          	sw	zero,1794(a5) # ffffffffc02af708 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020100e:	565000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201012:	4511                	li	a0,4
ffffffffc0201014:	4cd000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201018:	4c051463          	bnez	a0,ffffffffc02014e0 <default_check+0x6a2>
ffffffffc020101c:	0889b783          	ld	a5,136(s3)
ffffffffc0201020:	8385                	srli	a5,a5,0x1
ffffffffc0201022:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201024:	48078e63          	beqz	a5,ffffffffc02014c0 <default_check+0x682>
ffffffffc0201028:	0909a703          	lw	a4,144(s3)
ffffffffc020102c:	478d                	li	a5,3
ffffffffc020102e:	48f71963          	bne	a4,a5,ffffffffc02014c0 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201032:	450d                	li	a0,3
ffffffffc0201034:	4ad000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201038:	8c2a                	mv	s8,a0
ffffffffc020103a:	46050363          	beqz	a0,ffffffffc02014a0 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020103e:	4505                	li	a0,1
ffffffffc0201040:	4a1000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201044:	42051e63          	bnez	a0,ffffffffc0201480 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201048:	418a1c63          	bne	s4,s8,ffffffffc0201460 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020104c:	4585                	li	a1,1
ffffffffc020104e:	854e                	mv	a0,s3
ffffffffc0201050:	523000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_pages(p1, 3);
ffffffffc0201054:	458d                	li	a1,3
ffffffffc0201056:	8552                	mv	a0,s4
ffffffffc0201058:	51b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
ffffffffc020105c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201060:	04098c13          	addi	s8,s3,64
ffffffffc0201064:	8385                	srli	a5,a5,0x1
ffffffffc0201066:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201068:	3c078c63          	beqz	a5,ffffffffc0201440 <default_check+0x602>
ffffffffc020106c:	0109a703          	lw	a4,16(s3)
ffffffffc0201070:	4785                	li	a5,1
ffffffffc0201072:	3cf71763          	bne	a4,a5,ffffffffc0201440 <default_check+0x602>
ffffffffc0201076:	008a3783          	ld	a5,8(s4)
ffffffffc020107a:	8385                	srli	a5,a5,0x1
ffffffffc020107c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020107e:	3a078163          	beqz	a5,ffffffffc0201420 <default_check+0x5e2>
ffffffffc0201082:	010a2703          	lw	a4,16(s4)
ffffffffc0201086:	478d                	li	a5,3
ffffffffc0201088:	38f71c63          	bne	a4,a5,ffffffffc0201420 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020108c:	4505                	li	a0,1
ffffffffc020108e:	453000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201092:	36a99763          	bne	s3,a0,ffffffffc0201400 <default_check+0x5c2>
    free_page(p0);
ffffffffc0201096:	4585                	li	a1,1
ffffffffc0201098:	4db000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020109c:	4509                	li	a0,2
ffffffffc020109e:	443000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010a2:	32aa1f63          	bne	s4,a0,ffffffffc02013e0 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02010a6:	4589                	li	a1,2
ffffffffc02010a8:	4cb000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc02010ac:	4585                	li	a1,1
ffffffffc02010ae:	8562                	mv	a0,s8
ffffffffc02010b0:	4c3000ef          	jal	ra,ffffffffc0201d72 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010b4:	4515                	li	a0,5
ffffffffc02010b6:	42b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010ba:	89aa                	mv	s3,a0
ffffffffc02010bc:	48050263          	beqz	a0,ffffffffc0201540 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02010c0:	4505                	li	a0,1
ffffffffc02010c2:	41f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010c6:	2c051d63          	bnez	a0,ffffffffc02013a0 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02010ca:	481c                	lw	a5,16(s0)
ffffffffc02010cc:	2a079a63          	bnez	a5,ffffffffc0201380 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010d0:	4595                	li	a1,5
ffffffffc02010d2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010d4:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010d8:	01643023          	sd	s6,0(s0)
ffffffffc02010dc:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010e0:	493000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return listelm->next;
ffffffffc02010e4:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010e6:	00878963          	beq	a5,s0,ffffffffc02010f8 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010ea:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ee:	679c                	ld	a5,8(a5)
ffffffffc02010f0:	397d                	addiw	s2,s2,-1
ffffffffc02010f2:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010f4:	fe879be3          	bne	a5,s0,ffffffffc02010ea <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010f8:	26091463          	bnez	s2,ffffffffc0201360 <default_check+0x522>
    assert(total == 0);
ffffffffc02010fc:	46049263          	bnez	s1,ffffffffc0201560 <default_check+0x722>
}
ffffffffc0201100:	60a6                	ld	ra,72(sp)
ffffffffc0201102:	6406                	ld	s0,64(sp)
ffffffffc0201104:	74e2                	ld	s1,56(sp)
ffffffffc0201106:	7942                	ld	s2,48(sp)
ffffffffc0201108:	79a2                	ld	s3,40(sp)
ffffffffc020110a:	7a02                	ld	s4,32(sp)
ffffffffc020110c:	6ae2                	ld	s5,24(sp)
ffffffffc020110e:	6b42                	ld	s6,16(sp)
ffffffffc0201110:	6ba2                	ld	s7,8(sp)
ffffffffc0201112:	6c02                	ld	s8,0(sp)
ffffffffc0201114:	6161                	addi	sp,sp,80
ffffffffc0201116:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201118:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020111a:	4481                	li	s1,0
ffffffffc020111c:	4901                	li	s2,0
ffffffffc020111e:	b38d                	j	ffffffffc0200e80 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201120:	00006697          	auipc	a3,0x6
ffffffffc0201124:	0b068693          	addi	a3,a3,176 # ffffffffc02071d0 <commands+0x740>
ffffffffc0201128:	00006617          	auipc	a2,0x6
ffffffffc020112c:	db860613          	addi	a2,a2,-584 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201130:	0f000593          	li	a1,240
ffffffffc0201134:	00006517          	auipc	a0,0x6
ffffffffc0201138:	0ac50513          	addi	a0,a0,172 # ffffffffc02071e0 <commands+0x750>
ffffffffc020113c:	b3eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201140:	00006697          	auipc	a3,0x6
ffffffffc0201144:	13868693          	addi	a3,a3,312 # ffffffffc0207278 <commands+0x7e8>
ffffffffc0201148:	00006617          	auipc	a2,0x6
ffffffffc020114c:	d9860613          	addi	a2,a2,-616 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201150:	0bd00593          	li	a1,189
ffffffffc0201154:	00006517          	auipc	a0,0x6
ffffffffc0201158:	08c50513          	addi	a0,a0,140 # ffffffffc02071e0 <commands+0x750>
ffffffffc020115c:	b1eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201160:	00006697          	auipc	a3,0x6
ffffffffc0201164:	14068693          	addi	a3,a3,320 # ffffffffc02072a0 <commands+0x810>
ffffffffc0201168:	00006617          	auipc	a2,0x6
ffffffffc020116c:	d7860613          	addi	a2,a2,-648 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201170:	0be00593          	li	a1,190
ffffffffc0201174:	00006517          	auipc	a0,0x6
ffffffffc0201178:	06c50513          	addi	a0,a0,108 # ffffffffc02071e0 <commands+0x750>
ffffffffc020117c:	afeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	16068693          	addi	a3,a3,352 # ffffffffc02072e0 <commands+0x850>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	d5860613          	addi	a2,a2,-680 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201190:	0c000593          	li	a1,192
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	04c50513          	addi	a0,a0,76 # ffffffffc02071e0 <commands+0x750>
ffffffffc020119c:	adeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc02011a0:	00006697          	auipc	a3,0x6
ffffffffc02011a4:	1c868693          	addi	a3,a3,456 # ffffffffc0207368 <commands+0x8d8>
ffffffffc02011a8:	00006617          	auipc	a2,0x6
ffffffffc02011ac:	d3860613          	addi	a2,a2,-712 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02011b0:	0d900593          	li	a1,217
ffffffffc02011b4:	00006517          	auipc	a0,0x6
ffffffffc02011b8:	02c50513          	addi	a0,a0,44 # ffffffffc02071e0 <commands+0x750>
ffffffffc02011bc:	abeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011c0:	00006697          	auipc	a3,0x6
ffffffffc02011c4:	05868693          	addi	a3,a3,88 # ffffffffc0207218 <commands+0x788>
ffffffffc02011c8:	00006617          	auipc	a2,0x6
ffffffffc02011cc:	d1860613          	addi	a2,a2,-744 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02011d0:	0d200593          	li	a1,210
ffffffffc02011d4:	00006517          	auipc	a0,0x6
ffffffffc02011d8:	00c50513          	addi	a0,a0,12 # ffffffffc02071e0 <commands+0x750>
ffffffffc02011dc:	a9eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc02011e0:	00006697          	auipc	a3,0x6
ffffffffc02011e4:	17868693          	addi	a3,a3,376 # ffffffffc0207358 <commands+0x8c8>
ffffffffc02011e8:	00006617          	auipc	a2,0x6
ffffffffc02011ec:	cf860613          	addi	a2,a2,-776 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02011f0:	0d000593          	li	a1,208
ffffffffc02011f4:	00006517          	auipc	a0,0x6
ffffffffc02011f8:	fec50513          	addi	a0,a0,-20 # ffffffffc02071e0 <commands+0x750>
ffffffffc02011fc:	a7eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201200:	00006697          	auipc	a3,0x6
ffffffffc0201204:	14068693          	addi	a3,a3,320 # ffffffffc0207340 <commands+0x8b0>
ffffffffc0201208:	00006617          	auipc	a2,0x6
ffffffffc020120c:	cd860613          	addi	a2,a2,-808 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201210:	0cb00593          	li	a1,203
ffffffffc0201214:	00006517          	auipc	a0,0x6
ffffffffc0201218:	fcc50513          	addi	a0,a0,-52 # ffffffffc02071e0 <commands+0x750>
ffffffffc020121c:	a5eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201220:	00006697          	auipc	a3,0x6
ffffffffc0201224:	10068693          	addi	a3,a3,256 # ffffffffc0207320 <commands+0x890>
ffffffffc0201228:	00006617          	auipc	a2,0x6
ffffffffc020122c:	cb860613          	addi	a2,a2,-840 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201230:	0c200593          	li	a1,194
ffffffffc0201234:	00006517          	auipc	a0,0x6
ffffffffc0201238:	fac50513          	addi	a0,a0,-84 # ffffffffc02071e0 <commands+0x750>
ffffffffc020123c:	a3eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc0201240:	00006697          	auipc	a3,0x6
ffffffffc0201244:	17068693          	addi	a3,a3,368 # ffffffffc02073b0 <commands+0x920>
ffffffffc0201248:	00006617          	auipc	a2,0x6
ffffffffc020124c:	c9860613          	addi	a2,a2,-872 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201250:	0f800593          	li	a1,248
ffffffffc0201254:	00006517          	auipc	a0,0x6
ffffffffc0201258:	f8c50513          	addi	a0,a0,-116 # ffffffffc02071e0 <commands+0x750>
ffffffffc020125c:	a1eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc0201260:	00006697          	auipc	a3,0x6
ffffffffc0201264:	14068693          	addi	a3,a3,320 # ffffffffc02073a0 <commands+0x910>
ffffffffc0201268:	00006617          	auipc	a2,0x6
ffffffffc020126c:	c7860613          	addi	a2,a2,-904 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201270:	0df00593          	li	a1,223
ffffffffc0201274:	00006517          	auipc	a0,0x6
ffffffffc0201278:	f6c50513          	addi	a0,a0,-148 # ffffffffc02071e0 <commands+0x750>
ffffffffc020127c:	9feff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201280:	00006697          	auipc	a3,0x6
ffffffffc0201284:	0c068693          	addi	a3,a3,192 # ffffffffc0207340 <commands+0x8b0>
ffffffffc0201288:	00006617          	auipc	a2,0x6
ffffffffc020128c:	c5860613          	addi	a2,a2,-936 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201290:	0dd00593          	li	a1,221
ffffffffc0201294:	00006517          	auipc	a0,0x6
ffffffffc0201298:	f4c50513          	addi	a0,a0,-180 # ffffffffc02071e0 <commands+0x750>
ffffffffc020129c:	9deff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02012a0:	00006697          	auipc	a3,0x6
ffffffffc02012a4:	0e068693          	addi	a3,a3,224 # ffffffffc0207380 <commands+0x8f0>
ffffffffc02012a8:	00006617          	auipc	a2,0x6
ffffffffc02012ac:	c3860613          	addi	a2,a2,-968 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02012b0:	0dc00593          	li	a1,220
ffffffffc02012b4:	00006517          	auipc	a0,0x6
ffffffffc02012b8:	f2c50513          	addi	a0,a0,-212 # ffffffffc02071e0 <commands+0x750>
ffffffffc02012bc:	9beff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012c0:	00006697          	auipc	a3,0x6
ffffffffc02012c4:	f5868693          	addi	a3,a3,-168 # ffffffffc0207218 <commands+0x788>
ffffffffc02012c8:	00006617          	auipc	a2,0x6
ffffffffc02012cc:	c1860613          	addi	a2,a2,-1000 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02012d0:	0b900593          	li	a1,185
ffffffffc02012d4:	00006517          	auipc	a0,0x6
ffffffffc02012d8:	f0c50513          	addi	a0,a0,-244 # ffffffffc02071e0 <commands+0x750>
ffffffffc02012dc:	99eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e0:	00006697          	auipc	a3,0x6
ffffffffc02012e4:	06068693          	addi	a3,a3,96 # ffffffffc0207340 <commands+0x8b0>
ffffffffc02012e8:	00006617          	auipc	a2,0x6
ffffffffc02012ec:	bf860613          	addi	a2,a2,-1032 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02012f0:	0d600593          	li	a1,214
ffffffffc02012f4:	00006517          	auipc	a0,0x6
ffffffffc02012f8:	eec50513          	addi	a0,a0,-276 # ffffffffc02071e0 <commands+0x750>
ffffffffc02012fc:	97eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201300:	00006697          	auipc	a3,0x6
ffffffffc0201304:	f5868693          	addi	a3,a3,-168 # ffffffffc0207258 <commands+0x7c8>
ffffffffc0201308:	00006617          	auipc	a2,0x6
ffffffffc020130c:	bd860613          	addi	a2,a2,-1064 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201310:	0d400593          	li	a1,212
ffffffffc0201314:	00006517          	auipc	a0,0x6
ffffffffc0201318:	ecc50513          	addi	a0,a0,-308 # ffffffffc02071e0 <commands+0x750>
ffffffffc020131c:	95eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201320:	00006697          	auipc	a3,0x6
ffffffffc0201324:	f1868693          	addi	a3,a3,-232 # ffffffffc0207238 <commands+0x7a8>
ffffffffc0201328:	00006617          	auipc	a2,0x6
ffffffffc020132c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201330:	0d300593          	li	a1,211
ffffffffc0201334:	00006517          	auipc	a0,0x6
ffffffffc0201338:	eac50513          	addi	a0,a0,-340 # ffffffffc02071e0 <commands+0x750>
ffffffffc020133c:	93eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201340:	00006697          	auipc	a3,0x6
ffffffffc0201344:	f1868693          	addi	a3,a3,-232 # ffffffffc0207258 <commands+0x7c8>
ffffffffc0201348:	00006617          	auipc	a2,0x6
ffffffffc020134c:	b9860613          	addi	a2,a2,-1128 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201350:	0bb00593          	li	a1,187
ffffffffc0201354:	00006517          	auipc	a0,0x6
ffffffffc0201358:	e8c50513          	addi	a0,a0,-372 # ffffffffc02071e0 <commands+0x750>
ffffffffc020135c:	91eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc0201360:	00006697          	auipc	a3,0x6
ffffffffc0201364:	1a068693          	addi	a3,a3,416 # ffffffffc0207500 <commands+0xa70>
ffffffffc0201368:	00006617          	auipc	a2,0x6
ffffffffc020136c:	b7860613          	addi	a2,a2,-1160 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201370:	12500593          	li	a1,293
ffffffffc0201374:	00006517          	auipc	a0,0x6
ffffffffc0201378:	e6c50513          	addi	a0,a0,-404 # ffffffffc02071e0 <commands+0x750>
ffffffffc020137c:	8feff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc0201380:	00006697          	auipc	a3,0x6
ffffffffc0201384:	02068693          	addi	a3,a3,32 # ffffffffc02073a0 <commands+0x910>
ffffffffc0201388:	00006617          	auipc	a2,0x6
ffffffffc020138c:	b5860613          	addi	a2,a2,-1192 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201390:	11a00593          	li	a1,282
ffffffffc0201394:	00006517          	auipc	a0,0x6
ffffffffc0201398:	e4c50513          	addi	a0,a0,-436 # ffffffffc02071e0 <commands+0x750>
ffffffffc020139c:	8deff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013a0:	00006697          	auipc	a3,0x6
ffffffffc02013a4:	fa068693          	addi	a3,a3,-96 # ffffffffc0207340 <commands+0x8b0>
ffffffffc02013a8:	00006617          	auipc	a2,0x6
ffffffffc02013ac:	b3860613          	addi	a2,a2,-1224 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02013b0:	11800593          	li	a1,280
ffffffffc02013b4:	00006517          	auipc	a0,0x6
ffffffffc02013b8:	e2c50513          	addi	a0,a0,-468 # ffffffffc02071e0 <commands+0x750>
ffffffffc02013bc:	8beff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02013c0:	00006697          	auipc	a3,0x6
ffffffffc02013c4:	f4068693          	addi	a3,a3,-192 # ffffffffc0207300 <commands+0x870>
ffffffffc02013c8:	00006617          	auipc	a2,0x6
ffffffffc02013cc:	b1860613          	addi	a2,a2,-1256 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02013d0:	0c100593          	li	a1,193
ffffffffc02013d4:	00006517          	auipc	a0,0x6
ffffffffc02013d8:	e0c50513          	addi	a0,a0,-500 # ffffffffc02071e0 <commands+0x750>
ffffffffc02013dc:	89eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013e0:	00006697          	auipc	a3,0x6
ffffffffc02013e4:	0e068693          	addi	a3,a3,224 # ffffffffc02074c0 <commands+0xa30>
ffffffffc02013e8:	00006617          	auipc	a2,0x6
ffffffffc02013ec:	af860613          	addi	a2,a2,-1288 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02013f0:	11200593          	li	a1,274
ffffffffc02013f4:	00006517          	auipc	a0,0x6
ffffffffc02013f8:	dec50513          	addi	a0,a0,-532 # ffffffffc02071e0 <commands+0x750>
ffffffffc02013fc:	87eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201400:	00006697          	auipc	a3,0x6
ffffffffc0201404:	0a068693          	addi	a3,a3,160 # ffffffffc02074a0 <commands+0xa10>
ffffffffc0201408:	00006617          	auipc	a2,0x6
ffffffffc020140c:	ad860613          	addi	a2,a2,-1320 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201410:	11000593          	li	a1,272
ffffffffc0201414:	00006517          	auipc	a0,0x6
ffffffffc0201418:	dcc50513          	addi	a0,a0,-564 # ffffffffc02071e0 <commands+0x750>
ffffffffc020141c:	85eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201420:	00006697          	auipc	a3,0x6
ffffffffc0201424:	05868693          	addi	a3,a3,88 # ffffffffc0207478 <commands+0x9e8>
ffffffffc0201428:	00006617          	auipc	a2,0x6
ffffffffc020142c:	ab860613          	addi	a2,a2,-1352 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201430:	10e00593          	li	a1,270
ffffffffc0201434:	00006517          	auipc	a0,0x6
ffffffffc0201438:	dac50513          	addi	a0,a0,-596 # ffffffffc02071e0 <commands+0x750>
ffffffffc020143c:	83eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201440:	00006697          	auipc	a3,0x6
ffffffffc0201444:	01068693          	addi	a3,a3,16 # ffffffffc0207450 <commands+0x9c0>
ffffffffc0201448:	00006617          	auipc	a2,0x6
ffffffffc020144c:	a9860613          	addi	a2,a2,-1384 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201450:	10d00593          	li	a1,269
ffffffffc0201454:	00006517          	auipc	a0,0x6
ffffffffc0201458:	d8c50513          	addi	a0,a0,-628 # ffffffffc02071e0 <commands+0x750>
ffffffffc020145c:	81eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201460:	00006697          	auipc	a3,0x6
ffffffffc0201464:	fe068693          	addi	a3,a3,-32 # ffffffffc0207440 <commands+0x9b0>
ffffffffc0201468:	00006617          	auipc	a2,0x6
ffffffffc020146c:	a7860613          	addi	a2,a2,-1416 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201470:	10800593          	li	a1,264
ffffffffc0201474:	00006517          	auipc	a0,0x6
ffffffffc0201478:	d6c50513          	addi	a0,a0,-660 # ffffffffc02071e0 <commands+0x750>
ffffffffc020147c:	ffffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201480:	00006697          	auipc	a3,0x6
ffffffffc0201484:	ec068693          	addi	a3,a3,-320 # ffffffffc0207340 <commands+0x8b0>
ffffffffc0201488:	00006617          	auipc	a2,0x6
ffffffffc020148c:	a5860613          	addi	a2,a2,-1448 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201490:	10700593          	li	a1,263
ffffffffc0201494:	00006517          	auipc	a0,0x6
ffffffffc0201498:	d4c50513          	addi	a0,a0,-692 # ffffffffc02071e0 <commands+0x750>
ffffffffc020149c:	fdffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02014a0:	00006697          	auipc	a3,0x6
ffffffffc02014a4:	f8068693          	addi	a3,a3,-128 # ffffffffc0207420 <commands+0x990>
ffffffffc02014a8:	00006617          	auipc	a2,0x6
ffffffffc02014ac:	a3860613          	addi	a2,a2,-1480 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02014b0:	10600593          	li	a1,262
ffffffffc02014b4:	00006517          	auipc	a0,0x6
ffffffffc02014b8:	d2c50513          	addi	a0,a0,-724 # ffffffffc02071e0 <commands+0x750>
ffffffffc02014bc:	fbffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02014c0:	00006697          	auipc	a3,0x6
ffffffffc02014c4:	f3068693          	addi	a3,a3,-208 # ffffffffc02073f0 <commands+0x960>
ffffffffc02014c8:	00006617          	auipc	a2,0x6
ffffffffc02014cc:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02014d0:	10500593          	li	a1,261
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	d0c50513          	addi	a0,a0,-756 # ffffffffc02071e0 <commands+0x750>
ffffffffc02014dc:	f9ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	ef868693          	addi	a3,a3,-264 # ffffffffc02073d8 <commands+0x948>
ffffffffc02014e8:	00006617          	auipc	a2,0x6
ffffffffc02014ec:	9f860613          	addi	a2,a2,-1544 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02014f0:	10400593          	li	a1,260
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	cec50513          	addi	a0,a0,-788 # ffffffffc02071e0 <commands+0x750>
ffffffffc02014fc:	f7ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201500:	00006697          	auipc	a3,0x6
ffffffffc0201504:	e4068693          	addi	a3,a3,-448 # ffffffffc0207340 <commands+0x8b0>
ffffffffc0201508:	00006617          	auipc	a2,0x6
ffffffffc020150c:	9d860613          	addi	a2,a2,-1576 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201510:	0fe00593          	li	a1,254
ffffffffc0201514:	00006517          	auipc	a0,0x6
ffffffffc0201518:	ccc50513          	addi	a0,a0,-820 # ffffffffc02071e0 <commands+0x750>
ffffffffc020151c:	f5ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc0201520:	00006697          	auipc	a3,0x6
ffffffffc0201524:	ea068693          	addi	a3,a3,-352 # ffffffffc02073c0 <commands+0x930>
ffffffffc0201528:	00006617          	auipc	a2,0x6
ffffffffc020152c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201530:	0f900593          	li	a1,249
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	cac50513          	addi	a0,a0,-852 # ffffffffc02071e0 <commands+0x750>
ffffffffc020153c:	f3ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201540:	00006697          	auipc	a3,0x6
ffffffffc0201544:	fa068693          	addi	a3,a3,-96 # ffffffffc02074e0 <commands+0xa50>
ffffffffc0201548:	00006617          	auipc	a2,0x6
ffffffffc020154c:	99860613          	addi	a2,a2,-1640 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201550:	11700593          	li	a1,279
ffffffffc0201554:	00006517          	auipc	a0,0x6
ffffffffc0201558:	c8c50513          	addi	a0,a0,-884 # ffffffffc02071e0 <commands+0x750>
ffffffffc020155c:	f1ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc0201560:	00006697          	auipc	a3,0x6
ffffffffc0201564:	fb068693          	addi	a3,a3,-80 # ffffffffc0207510 <commands+0xa80>
ffffffffc0201568:	00006617          	auipc	a2,0x6
ffffffffc020156c:	97860613          	addi	a2,a2,-1672 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201570:	12600593          	li	a1,294
ffffffffc0201574:	00006517          	auipc	a0,0x6
ffffffffc0201578:	c6c50513          	addi	a0,a0,-916 # ffffffffc02071e0 <commands+0x750>
ffffffffc020157c:	efffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc0201580:	00006697          	auipc	a3,0x6
ffffffffc0201584:	c7868693          	addi	a3,a3,-904 # ffffffffc02071f8 <commands+0x768>
ffffffffc0201588:	00006617          	auipc	a2,0x6
ffffffffc020158c:	95860613          	addi	a2,a2,-1704 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201590:	0f300593          	li	a1,243
ffffffffc0201594:	00006517          	auipc	a0,0x6
ffffffffc0201598:	c4c50513          	addi	a0,a0,-948 # ffffffffc02071e0 <commands+0x750>
ffffffffc020159c:	edffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015a0:	00006697          	auipc	a3,0x6
ffffffffc02015a4:	c9868693          	addi	a3,a3,-872 # ffffffffc0207238 <commands+0x7a8>
ffffffffc02015a8:	00006617          	auipc	a2,0x6
ffffffffc02015ac:	93860613          	addi	a2,a2,-1736 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02015b0:	0ba00593          	li	a1,186
ffffffffc02015b4:	00006517          	auipc	a0,0x6
ffffffffc02015b8:	c2c50513          	addi	a0,a0,-980 # ffffffffc02071e0 <commands+0x750>
ffffffffc02015bc:	ebffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02015c0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02015c0:	1141                	addi	sp,sp,-16
ffffffffc02015c2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015c4:	14058463          	beqz	a1,ffffffffc020170c <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015c8:	00659693          	slli	a3,a1,0x6
ffffffffc02015cc:	96aa                	add	a3,a3,a0
ffffffffc02015ce:	87aa                	mv	a5,a0
ffffffffc02015d0:	02d50263          	beq	a0,a3,ffffffffc02015f4 <default_free_pages+0x34>
ffffffffc02015d4:	6798                	ld	a4,8(a5)
ffffffffc02015d6:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015d8:	10071a63          	bnez	a4,ffffffffc02016ec <default_free_pages+0x12c>
ffffffffc02015dc:	6798                	ld	a4,8(a5)
ffffffffc02015de:	8b09                	andi	a4,a4,2
ffffffffc02015e0:	10071663          	bnez	a4,ffffffffc02016ec <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015e4:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ec:	04078793          	addi	a5,a5,64
ffffffffc02015f0:	fed792e3          	bne	a5,a3,ffffffffc02015d4 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015f4:	2581                	sext.w	a1,a1
ffffffffc02015f6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015f8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fc:	4789                	li	a5,2
ffffffffc02015fe:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201602:	000ae697          	auipc	a3,0xae
ffffffffc0201606:	0f668693          	addi	a3,a3,246 # ffffffffc02af6f8 <free_area>
ffffffffc020160a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020160c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020160e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201612:	9db9                	addw	a1,a1,a4
ffffffffc0201614:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201616:	0ad78463          	beq	a5,a3,ffffffffc02016be <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020161a:	fe878713          	addi	a4,a5,-24
ffffffffc020161e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201622:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201624:	00e56a63          	bltu	a0,a4,ffffffffc0201638 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201628:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020162a:	04d70c63          	beq	a4,a3,ffffffffc0201682 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020162e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201630:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201634:	fee57ae3          	bgeu	a0,a4,ffffffffc0201628 <default_free_pages+0x68>
ffffffffc0201638:	c199                	beqz	a1,ffffffffc020163e <default_free_pages+0x7e>
ffffffffc020163a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020163e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201640:	e390                	sd	a2,0(a5)
ffffffffc0201642:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201644:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201646:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201648:	00d70d63          	beq	a4,a3,ffffffffc0201662 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020164c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201650:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201654:	02059813          	slli	a6,a1,0x20
ffffffffc0201658:	01a85793          	srli	a5,a6,0x1a
ffffffffc020165c:	97b2                	add	a5,a5,a2
ffffffffc020165e:	02f50c63          	beq	a0,a5,ffffffffc0201696 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201662:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201664:	00d78c63          	beq	a5,a3,ffffffffc020167c <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201668:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020166a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020166e:	02061593          	slli	a1,a2,0x20
ffffffffc0201672:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201676:	972a                	add	a4,a4,a0
ffffffffc0201678:	04e68a63          	beq	a3,a4,ffffffffc02016cc <default_free_pages+0x10c>
}
ffffffffc020167c:	60a2                	ld	ra,8(sp)
ffffffffc020167e:	0141                	addi	sp,sp,16
ffffffffc0201680:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201682:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201684:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201686:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201688:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020168a:	02d70763          	beq	a4,a3,ffffffffc02016b8 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020168e:	8832                	mv	a6,a2
ffffffffc0201690:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201692:	87ba                	mv	a5,a4
ffffffffc0201694:	bf71                	j	ffffffffc0201630 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201696:	491c                	lw	a5,16(a0)
ffffffffc0201698:	9dbd                	addw	a1,a1,a5
ffffffffc020169a:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020169e:	57f5                	li	a5,-3
ffffffffc02016a0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016a4:	01853803          	ld	a6,24(a0)
ffffffffc02016a8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02016aa:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016ac:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02016b0:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02016b2:	0105b023          	sd	a6,0(a1)
ffffffffc02016b6:	b77d                	j	ffffffffc0201664 <default_free_pages+0xa4>
ffffffffc02016b8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ba:	873e                	mv	a4,a5
ffffffffc02016bc:	bf41                	j	ffffffffc020164c <default_free_pages+0x8c>
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016c0:	e390                	sd	a2,0(a5)
ffffffffc02016c2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016c4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016c6:	ed1c                	sd	a5,24(a0)
ffffffffc02016c8:	0141                	addi	sp,sp,16
ffffffffc02016ca:	8082                	ret
            base->property += p->property;
ffffffffc02016cc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016d0:	ff078693          	addi	a3,a5,-16
ffffffffc02016d4:	9e39                	addw	a2,a2,a4
ffffffffc02016d6:	c910                	sw	a2,16(a0)
ffffffffc02016d8:	5775                	li	a4,-3
ffffffffc02016da:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016de:	6398                	ld	a4,0(a5)
ffffffffc02016e0:	679c                	ld	a5,8(a5)
}
ffffffffc02016e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016e4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016e6:	e398                	sd	a4,0(a5)
ffffffffc02016e8:	0141                	addi	sp,sp,16
ffffffffc02016ea:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016ec:	00006697          	auipc	a3,0x6
ffffffffc02016f0:	e3c68693          	addi	a3,a3,-452 # ffffffffc0207528 <commands+0xa98>
ffffffffc02016f4:	00005617          	auipc	a2,0x5
ffffffffc02016f8:	7ec60613          	addi	a2,a2,2028 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02016fc:	08300593          	li	a1,131
ffffffffc0201700:	00006517          	auipc	a0,0x6
ffffffffc0201704:	ae050513          	addi	a0,a0,-1312 # ffffffffc02071e0 <commands+0x750>
ffffffffc0201708:	d73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc020170c:	00006697          	auipc	a3,0x6
ffffffffc0201710:	e1468693          	addi	a3,a3,-492 # ffffffffc0207520 <commands+0xa90>
ffffffffc0201714:	00005617          	auipc	a2,0x5
ffffffffc0201718:	7cc60613          	addi	a2,a2,1996 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020171c:	08000593          	li	a1,128
ffffffffc0201720:	00006517          	auipc	a0,0x6
ffffffffc0201724:	ac050513          	addi	a0,a0,-1344 # ffffffffc02071e0 <commands+0x750>
ffffffffc0201728:	d53fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020172c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020172c:	c941                	beqz	a0,ffffffffc02017bc <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020172e:	000ae597          	auipc	a1,0xae
ffffffffc0201732:	fca58593          	addi	a1,a1,-54 # ffffffffc02af6f8 <free_area>
ffffffffc0201736:	0105a803          	lw	a6,16(a1)
ffffffffc020173a:	872a                	mv	a4,a0
ffffffffc020173c:	02081793          	slli	a5,a6,0x20
ffffffffc0201740:	9381                	srli	a5,a5,0x20
ffffffffc0201742:	00a7ee63          	bltu	a5,a0,ffffffffc020175e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201746:	87ae                	mv	a5,a1
ffffffffc0201748:	a801                	j	ffffffffc0201758 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020174a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020174e:	02069613          	slli	a2,a3,0x20
ffffffffc0201752:	9201                	srli	a2,a2,0x20
ffffffffc0201754:	00e67763          	bgeu	a2,a4,ffffffffc0201762 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201758:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020175a:	feb798e3          	bne	a5,a1,ffffffffc020174a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020175e:	4501                	li	a0,0
}
ffffffffc0201760:	8082                	ret
    return listelm->prev;
ffffffffc0201762:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201766:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020176a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020176e:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201772:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201776:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020177a:	02c77863          	bgeu	a4,a2,ffffffffc02017aa <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020177e:	071a                	slli	a4,a4,0x6
ffffffffc0201780:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201782:	41c686bb          	subw	a3,a3,t3
ffffffffc0201786:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201788:	00870613          	addi	a2,a4,8
ffffffffc020178c:	4689                	li	a3,2
ffffffffc020178e:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201792:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201796:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020179a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020179e:	e290                	sd	a2,0(a3)
ffffffffc02017a0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02017a4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02017a6:	01173c23          	sd	a7,24(a4)
ffffffffc02017aa:	41c8083b          	subw	a6,a6,t3
ffffffffc02017ae:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017b2:	5775                	li	a4,-3
ffffffffc02017b4:	17c1                	addi	a5,a5,-16
ffffffffc02017b6:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02017ba:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02017bc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02017be:	00006697          	auipc	a3,0x6
ffffffffc02017c2:	d6268693          	addi	a3,a3,-670 # ffffffffc0207520 <commands+0xa90>
ffffffffc02017c6:	00005617          	auipc	a2,0x5
ffffffffc02017ca:	71a60613          	addi	a2,a2,1818 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02017ce:	06200593          	li	a1,98
ffffffffc02017d2:	00006517          	auipc	a0,0x6
ffffffffc02017d6:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02071e0 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02017da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017dc:	c9ffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02017e0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017e0:	1141                	addi	sp,sp,-16
ffffffffc02017e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017e4:	c5f1                	beqz	a1,ffffffffc02018b0 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017e6:	00659693          	slli	a3,a1,0x6
ffffffffc02017ea:	96aa                	add	a3,a3,a0
ffffffffc02017ec:	87aa                	mv	a5,a0
ffffffffc02017ee:	00d50f63          	beq	a0,a3,ffffffffc020180c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017f2:	6798                	ld	a4,8(a5)
ffffffffc02017f4:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017f6:	cf49                	beqz	a4,ffffffffc0201890 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017f8:	0007a823          	sw	zero,16(a5)
ffffffffc02017fc:	0007b423          	sd	zero,8(a5)
ffffffffc0201800:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201804:	04078793          	addi	a5,a5,64
ffffffffc0201808:	fed795e3          	bne	a5,a3,ffffffffc02017f2 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020180c:	2581                	sext.w	a1,a1
ffffffffc020180e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201810:	4789                	li	a5,2
ffffffffc0201812:	00850713          	addi	a4,a0,8
ffffffffc0201816:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020181a:	000ae697          	auipc	a3,0xae
ffffffffc020181e:	ede68693          	addi	a3,a3,-290 # ffffffffc02af6f8 <free_area>
ffffffffc0201822:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201824:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201826:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020182a:	9db9                	addw	a1,a1,a4
ffffffffc020182c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020182e:	04d78a63          	beq	a5,a3,ffffffffc0201882 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201832:	fe878713          	addi	a4,a5,-24
ffffffffc0201836:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020183a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020183c:	00e56a63          	bltu	a0,a4,ffffffffc0201850 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201840:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201842:	02d70263          	beq	a4,a3,ffffffffc0201866 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201846:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201848:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020184c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201840 <default_init_memmap+0x60>
ffffffffc0201850:	c199                	beqz	a1,ffffffffc0201856 <default_init_memmap+0x76>
ffffffffc0201852:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201856:	6398                	ld	a4,0(a5)
}
ffffffffc0201858:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020185a:	e390                	sd	a2,0(a5)
ffffffffc020185c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020185e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201860:	ed18                	sd	a4,24(a0)
ffffffffc0201862:	0141                	addi	sp,sp,16
ffffffffc0201864:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201866:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201868:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020186a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020186c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020186e:	00d70663          	beq	a4,a3,ffffffffc020187a <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201872:	8832                	mv	a6,a2
ffffffffc0201874:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201876:	87ba                	mv	a5,a4
ffffffffc0201878:	bfc1                	j	ffffffffc0201848 <default_init_memmap+0x68>
}
ffffffffc020187a:	60a2                	ld	ra,8(sp)
ffffffffc020187c:	e290                	sd	a2,0(a3)
ffffffffc020187e:	0141                	addi	sp,sp,16
ffffffffc0201880:	8082                	ret
ffffffffc0201882:	60a2                	ld	ra,8(sp)
ffffffffc0201884:	e390                	sd	a2,0(a5)
ffffffffc0201886:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201888:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020188a:	ed1c                	sd	a5,24(a0)
ffffffffc020188c:	0141                	addi	sp,sp,16
ffffffffc020188e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201890:	00006697          	auipc	a3,0x6
ffffffffc0201894:	cc068693          	addi	a3,a3,-832 # ffffffffc0207550 <commands+0xac0>
ffffffffc0201898:	00005617          	auipc	a2,0x5
ffffffffc020189c:	64860613          	addi	a2,a2,1608 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02018a0:	04900593          	li	a1,73
ffffffffc02018a4:	00006517          	auipc	a0,0x6
ffffffffc02018a8:	93c50513          	addi	a0,a0,-1732 # ffffffffc02071e0 <commands+0x750>
ffffffffc02018ac:	bcffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc02018b0:	00006697          	auipc	a3,0x6
ffffffffc02018b4:	c7068693          	addi	a3,a3,-912 # ffffffffc0207520 <commands+0xa90>
ffffffffc02018b8:	00005617          	auipc	a2,0x5
ffffffffc02018bc:	62860613          	addi	a2,a2,1576 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02018c0:	04600593          	li	a1,70
ffffffffc02018c4:	00006517          	auipc	a0,0x6
ffffffffc02018c8:	91c50513          	addi	a0,a0,-1764 # ffffffffc02071e0 <commands+0x750>
ffffffffc02018cc:	baffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02018d0 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018d0:	c94d                	beqz	a0,ffffffffc0201982 <slob_free+0xb2>
{
ffffffffc02018d2:	1141                	addi	sp,sp,-16
ffffffffc02018d4:	e022                	sd	s0,0(sp)
ffffffffc02018d6:	e406                	sd	ra,8(sp)
ffffffffc02018d8:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018da:	e9c1                	bnez	a1,ffffffffc020196a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018dc:	100027f3          	csrr	a5,sstatus
ffffffffc02018e0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018e2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018e4:	ebd9                	bnez	a5,ffffffffc020197a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018e6:	000a7617          	auipc	a2,0xa7
ffffffffc02018ea:	a0260613          	addi	a2,a2,-1534 # ffffffffc02a82e8 <slobfree>
ffffffffc02018ee:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018f0:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018f2:	679c                	ld	a5,8(a5)
ffffffffc02018f4:	02877a63          	bgeu	a4,s0,ffffffffc0201928 <slob_free+0x58>
ffffffffc02018f8:	00f46463          	bltu	s0,a5,ffffffffc0201900 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018fc:	fef76ae3          	bltu	a4,a5,ffffffffc02018f0 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201900:	400c                	lw	a1,0(s0)
ffffffffc0201902:	00459693          	slli	a3,a1,0x4
ffffffffc0201906:	96a2                	add	a3,a3,s0
ffffffffc0201908:	02d78a63          	beq	a5,a3,ffffffffc020193c <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020190c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020190e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201910:	00469793          	slli	a5,a3,0x4
ffffffffc0201914:	97ba                	add	a5,a5,a4
ffffffffc0201916:	02f40e63          	beq	s0,a5,ffffffffc0201952 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020191a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020191c:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020191e:	e129                	bnez	a0,ffffffffc0201960 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201920:	60a2                	ld	ra,8(sp)
ffffffffc0201922:	6402                	ld	s0,0(sp)
ffffffffc0201924:	0141                	addi	sp,sp,16
ffffffffc0201926:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201928:	fcf764e3          	bltu	a4,a5,ffffffffc02018f0 <slob_free+0x20>
ffffffffc020192c:	fcf472e3          	bgeu	s0,a5,ffffffffc02018f0 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201930:	400c                	lw	a1,0(s0)
ffffffffc0201932:	00459693          	slli	a3,a1,0x4
ffffffffc0201936:	96a2                	add	a3,a3,s0
ffffffffc0201938:	fcd79ae3          	bne	a5,a3,ffffffffc020190c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020193c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020193e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201940:	9db5                	addw	a1,a1,a3
ffffffffc0201942:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201944:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201946:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201948:	00469793          	slli	a5,a3,0x4
ffffffffc020194c:	97ba                	add	a5,a5,a4
ffffffffc020194e:	fcf416e3          	bne	s0,a5,ffffffffc020191a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201952:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201954:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201956:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201958:	9ebd                	addw	a3,a3,a5
ffffffffc020195a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc020195c:	e70c                	sd	a1,8(a4)
ffffffffc020195e:	d169                	beqz	a0,ffffffffc0201920 <slob_free+0x50>
}
ffffffffc0201960:	6402                	ld	s0,0(sp)
ffffffffc0201962:	60a2                	ld	ra,8(sp)
ffffffffc0201964:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201966:	cdbfe06f          	j	ffffffffc0200640 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020196a:	25bd                	addiw	a1,a1,15
ffffffffc020196c:	8191                	srli	a1,a1,0x4
ffffffffc020196e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201970:	100027f3          	csrr	a5,sstatus
ffffffffc0201974:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201976:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201978:	d7bd                	beqz	a5,ffffffffc02018e6 <slob_free+0x16>
        intr_disable();
ffffffffc020197a:	ccdfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020197e:	4505                	li	a0,1
ffffffffc0201980:	b79d                	j	ffffffffc02018e6 <slob_free+0x16>
ffffffffc0201982:	8082                	ret

ffffffffc0201984 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201984:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201986:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201988:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020198c:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020198e:	352000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
  if(!page)
ffffffffc0201992:	c91d                	beqz	a0,ffffffffc02019c8 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201994:	000b2697          	auipc	a3,0xb2
ffffffffc0201998:	e646b683          	ld	a3,-412(a3) # ffffffffc02b37f8 <pages>
ffffffffc020199c:	8d15                	sub	a0,a0,a3
ffffffffc020199e:	8519                	srai	a0,a0,0x6
ffffffffc02019a0:	00007697          	auipc	a3,0x7
ffffffffc02019a4:	6f86b683          	ld	a3,1784(a3) # ffffffffc0209098 <nbase>
ffffffffc02019a8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02019aa:	00c51793          	slli	a5,a0,0xc
ffffffffc02019ae:	83b1                	srli	a5,a5,0xc
ffffffffc02019b0:	000b2717          	auipc	a4,0xb2
ffffffffc02019b4:	e4073703          	ld	a4,-448(a4) # ffffffffc02b37f0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02019b8:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ba:	00e7fa63          	bgeu	a5,a4,ffffffffc02019ce <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019be:	000b2697          	auipc	a3,0xb2
ffffffffc02019c2:	e4a6b683          	ld	a3,-438(a3) # ffffffffc02b3808 <va_pa_offset>
ffffffffc02019c6:	9536                	add	a0,a0,a3
}
ffffffffc02019c8:	60a2                	ld	ra,8(sp)
ffffffffc02019ca:	0141                	addi	sp,sp,16
ffffffffc02019cc:	8082                	ret
ffffffffc02019ce:	86aa                	mv	a3,a0
ffffffffc02019d0:	00006617          	auipc	a2,0x6
ffffffffc02019d4:	be060613          	addi	a2,a2,-1056 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc02019d8:	06900593          	li	a1,105
ffffffffc02019dc:	00006517          	auipc	a0,0x6
ffffffffc02019e0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc02019e4:	a97fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02019e8 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019e8:	1101                	addi	sp,sp,-32
ffffffffc02019ea:	ec06                	sd	ra,24(sp)
ffffffffc02019ec:	e822                	sd	s0,16(sp)
ffffffffc02019ee:	e426                	sd	s1,8(sp)
ffffffffc02019f0:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019f2:	01050713          	addi	a4,a0,16
ffffffffc02019f6:	6785                	lui	a5,0x1
ffffffffc02019f8:	0cf77363          	bgeu	a4,a5,ffffffffc0201abe <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019fc:	00f50493          	addi	s1,a0,15
ffffffffc0201a00:	8091                	srli	s1,s1,0x4
ffffffffc0201a02:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a04:	10002673          	csrr	a2,sstatus
ffffffffc0201a08:	8a09                	andi	a2,a2,2
ffffffffc0201a0a:	e25d                	bnez	a2,ffffffffc0201ab0 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a0c:	000a7917          	auipc	s2,0xa7
ffffffffc0201a10:	8dc90913          	addi	s2,s2,-1828 # ffffffffc02a82e8 <slobfree>
ffffffffc0201a14:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a18:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a1a:	4398                	lw	a4,0(a5)
ffffffffc0201a1c:	08975e63          	bge	a4,s1,ffffffffc0201ab8 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201a20:	00f68b63          	beq	a3,a5,ffffffffc0201a36 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a24:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a26:	4018                	lw	a4,0(s0)
ffffffffc0201a28:	02975a63          	bge	a4,s1,ffffffffc0201a5c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a2c:	00093683          	ld	a3,0(s2)
ffffffffc0201a30:	87a2                	mv	a5,s0
ffffffffc0201a32:	fef699e3          	bne	a3,a5,ffffffffc0201a24 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a36:	ee31                	bnez	a2,ffffffffc0201a92 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a38:	4501                	li	a0,0
ffffffffc0201a3a:	f4bff0ef          	jal	ra,ffffffffc0201984 <__slob_get_free_pages.constprop.0>
ffffffffc0201a3e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a40:	cd05                	beqz	a0,ffffffffc0201a78 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a42:	6585                	lui	a1,0x1
ffffffffc0201a44:	e8dff0ef          	jal	ra,ffffffffc02018d0 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a48:	10002673          	csrr	a2,sstatus
ffffffffc0201a4c:	8a09                	andi	a2,a2,2
ffffffffc0201a4e:	ee05                	bnez	a2,ffffffffc0201a86 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a50:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a54:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a56:	4018                	lw	a4,0(s0)
ffffffffc0201a58:	fc974ae3          	blt	a4,s1,ffffffffc0201a2c <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a5c:	04e48763          	beq	s1,a4,ffffffffc0201aaa <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a60:	00449693          	slli	a3,s1,0x4
ffffffffc0201a64:	96a2                	add	a3,a3,s0
ffffffffc0201a66:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a68:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a6a:	9f05                	subw	a4,a4,s1
ffffffffc0201a6c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a6e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a70:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a72:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a76:	e20d                	bnez	a2,ffffffffc0201a98 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a78:	60e2                	ld	ra,24(sp)
ffffffffc0201a7a:	8522                	mv	a0,s0
ffffffffc0201a7c:	6442                	ld	s0,16(sp)
ffffffffc0201a7e:	64a2                	ld	s1,8(sp)
ffffffffc0201a80:	6902                	ld	s2,0(sp)
ffffffffc0201a82:	6105                	addi	sp,sp,32
ffffffffc0201a84:	8082                	ret
        intr_disable();
ffffffffc0201a86:	bc1fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
			cur = slobfree;
ffffffffc0201a8a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a8e:	4605                	li	a2,1
ffffffffc0201a90:	b7d1                	j	ffffffffc0201a54 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a92:	baffe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201a96:	b74d                	j	ffffffffc0201a38 <slob_alloc.constprop.0+0x50>
ffffffffc0201a98:	ba9fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc0201a9c:	60e2                	ld	ra,24(sp)
ffffffffc0201a9e:	8522                	mv	a0,s0
ffffffffc0201aa0:	6442                	ld	s0,16(sp)
ffffffffc0201aa2:	64a2                	ld	s1,8(sp)
ffffffffc0201aa4:	6902                	ld	s2,0(sp)
ffffffffc0201aa6:	6105                	addi	sp,sp,32
ffffffffc0201aa8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201aaa:	6418                	ld	a4,8(s0)
ffffffffc0201aac:	e798                	sd	a4,8(a5)
ffffffffc0201aae:	b7d1                	j	ffffffffc0201a72 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201ab0:	b97fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0201ab4:	4605                	li	a2,1
ffffffffc0201ab6:	bf99                	j	ffffffffc0201a0c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201ab8:	843e                	mv	s0,a5
ffffffffc0201aba:	87b6                	mv	a5,a3
ffffffffc0201abc:	b745                	j	ffffffffc0201a5c <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201abe:	00006697          	auipc	a3,0x6
ffffffffc0201ac2:	b2a68693          	addi	a3,a3,-1238 # ffffffffc02075e8 <default_pmm_manager+0x70>
ffffffffc0201ac6:	00005617          	auipc	a2,0x5
ffffffffc0201aca:	41a60613          	addi	a2,a2,1050 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0201ace:	06400593          	li	a1,100
ffffffffc0201ad2:	00006517          	auipc	a0,0x6
ffffffffc0201ad6:	b3650513          	addi	a0,a0,-1226 # ffffffffc0207608 <default_pmm_manager+0x90>
ffffffffc0201ada:	9a1fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ade <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201ade:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201ae0:	00006517          	auipc	a0,0x6
ffffffffc0201ae4:	b4050513          	addi	a0,a0,-1216 # ffffffffc0207620 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201ae8:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201aea:	e96fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201af0:	00006517          	auipc	a0,0x6
ffffffffc0201af4:	b4850513          	addi	a0,a0,-1208 # ffffffffc0207638 <default_pmm_manager+0xc0>
}
ffffffffc0201af8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201afa:	e86fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201afe <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201afe:	4501                	li	a0,0
ffffffffc0201b00:	8082                	ret

ffffffffc0201b02 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b02:	1101                	addi	sp,sp,-32
ffffffffc0201b04:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b06:	6905                	lui	s2,0x1
{
ffffffffc0201b08:	e822                	sd	s0,16(sp)
ffffffffc0201b0a:	ec06                	sd	ra,24(sp)
ffffffffc0201b0c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b0e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc0201b12:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b14:	04a7f963          	bgeu	a5,a0,ffffffffc0201b66 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b18:	4561                	li	a0,24
ffffffffc0201b1a:	ecfff0ef          	jal	ra,ffffffffc02019e8 <slob_alloc.constprop.0>
ffffffffc0201b1e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b20:	c929                	beqz	a0,ffffffffc0201b72 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b22:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b26:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b28:	00f95763          	bge	s2,a5,ffffffffc0201b36 <kmalloc+0x34>
ffffffffc0201b2c:	6705                	lui	a4,0x1
ffffffffc0201b2e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b30:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b32:	fef74ee3          	blt	a4,a5,ffffffffc0201b2e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b36:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b38:	e4dff0ef          	jal	ra,ffffffffc0201984 <__slob_get_free_pages.constprop.0>
ffffffffc0201b3c:	e488                	sd	a0,8(s1)
ffffffffc0201b3e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201b40:	c525                	beqz	a0,ffffffffc0201ba8 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b42:	100027f3          	csrr	a5,sstatus
ffffffffc0201b46:	8b89                	andi	a5,a5,2
ffffffffc0201b48:	ef8d                	bnez	a5,ffffffffc0201b82 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b4a:	000b2797          	auipc	a5,0xb2
ffffffffc0201b4e:	c8e78793          	addi	a5,a5,-882 # ffffffffc02b37d8 <bigblocks>
ffffffffc0201b52:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b54:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b56:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b58:	60e2                	ld	ra,24(sp)
ffffffffc0201b5a:	8522                	mv	a0,s0
ffffffffc0201b5c:	6442                	ld	s0,16(sp)
ffffffffc0201b5e:	64a2                	ld	s1,8(sp)
ffffffffc0201b60:	6902                	ld	s2,0(sp)
ffffffffc0201b62:	6105                	addi	sp,sp,32
ffffffffc0201b64:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b66:	0541                	addi	a0,a0,16
ffffffffc0201b68:	e81ff0ef          	jal	ra,ffffffffc02019e8 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b6c:	01050413          	addi	s0,a0,16
ffffffffc0201b70:	f565                	bnez	a0,ffffffffc0201b58 <kmalloc+0x56>
ffffffffc0201b72:	4401                	li	s0,0
}
ffffffffc0201b74:	60e2                	ld	ra,24(sp)
ffffffffc0201b76:	8522                	mv	a0,s0
ffffffffc0201b78:	6442                	ld	s0,16(sp)
ffffffffc0201b7a:	64a2                	ld	s1,8(sp)
ffffffffc0201b7c:	6902                	ld	s2,0(sp)
ffffffffc0201b7e:	6105                	addi	sp,sp,32
ffffffffc0201b80:	8082                	ret
        intr_disable();
ffffffffc0201b82:	ac5fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b86:	000b2797          	auipc	a5,0xb2
ffffffffc0201b8a:	c5278793          	addi	a5,a5,-942 # ffffffffc02b37d8 <bigblocks>
ffffffffc0201b8e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b90:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b92:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b94:	aadfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
		return bb->pages;
ffffffffc0201b98:	6480                	ld	s0,8(s1)
}
ffffffffc0201b9a:	60e2                	ld	ra,24(sp)
ffffffffc0201b9c:	64a2                	ld	s1,8(sp)
ffffffffc0201b9e:	8522                	mv	a0,s0
ffffffffc0201ba0:	6442                	ld	s0,16(sp)
ffffffffc0201ba2:	6902                	ld	s2,0(sp)
ffffffffc0201ba4:	6105                	addi	sp,sp,32
ffffffffc0201ba6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ba8:	45e1                	li	a1,24
ffffffffc0201baa:	8526                	mv	a0,s1
ffffffffc0201bac:	d25ff0ef          	jal	ra,ffffffffc02018d0 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201bb0:	b765                	j	ffffffffc0201b58 <kmalloc+0x56>

ffffffffc0201bb2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bb2:	c169                	beqz	a0,ffffffffc0201c74 <kfree+0xc2>
{
ffffffffc0201bb4:	1101                	addi	sp,sp,-32
ffffffffc0201bb6:	e822                	sd	s0,16(sp)
ffffffffc0201bb8:	ec06                	sd	ra,24(sp)
ffffffffc0201bba:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201bbc:	03451793          	slli	a5,a0,0x34
ffffffffc0201bc0:	842a                	mv	s0,a0
ffffffffc0201bc2:	e3d9                	bnez	a5,ffffffffc0201c48 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc8:	8b89                	andi	a5,a5,2
ffffffffc0201bca:	e7d9                	bnez	a5,ffffffffc0201c58 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bcc:	000b2797          	auipc	a5,0xb2
ffffffffc0201bd0:	c0c7b783          	ld	a5,-1012(a5) # ffffffffc02b37d8 <bigblocks>
    return 0;
ffffffffc0201bd4:	4601                	li	a2,0
ffffffffc0201bd6:	cbad                	beqz	a5,ffffffffc0201c48 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bd8:	000b2697          	auipc	a3,0xb2
ffffffffc0201bdc:	c0068693          	addi	a3,a3,-1024 # ffffffffc02b37d8 <bigblocks>
ffffffffc0201be0:	a021                	j	ffffffffc0201be8 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201be2:	01048693          	addi	a3,s1,16
ffffffffc0201be6:	c3a5                	beqz	a5,ffffffffc0201c46 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201be8:	6798                	ld	a4,8(a5)
ffffffffc0201bea:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201bec:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201bee:	fe871ae3          	bne	a4,s0,ffffffffc0201be2 <kfree+0x30>
				*last = bb->next;
ffffffffc0201bf2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bf4:	ee2d                	bnez	a2,ffffffffc0201c6e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bf6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bfa:	4098                	lw	a4,0(s1)
ffffffffc0201bfc:	08f46963          	bltu	s0,a5,ffffffffc0201c8e <kfree+0xdc>
ffffffffc0201c00:	000b2697          	auipc	a3,0xb2
ffffffffc0201c04:	c086b683          	ld	a3,-1016(a3) # ffffffffc02b3808 <va_pa_offset>
ffffffffc0201c08:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c0a:	8031                	srli	s0,s0,0xc
ffffffffc0201c0c:	000b2797          	auipc	a5,0xb2
ffffffffc0201c10:	be47b783          	ld	a5,-1052(a5) # ffffffffc02b37f0 <npage>
ffffffffc0201c14:	06f47163          	bgeu	s0,a5,ffffffffc0201c76 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c18:	00007517          	auipc	a0,0x7
ffffffffc0201c1c:	48053503          	ld	a0,1152(a0) # ffffffffc0209098 <nbase>
ffffffffc0201c20:	8c09                	sub	s0,s0,a0
ffffffffc0201c22:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201c24:	000b2517          	auipc	a0,0xb2
ffffffffc0201c28:	bd453503          	ld	a0,-1068(a0) # ffffffffc02b37f8 <pages>
ffffffffc0201c2c:	4585                	li	a1,1
ffffffffc0201c2e:	9522                	add	a0,a0,s0
ffffffffc0201c30:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c34:	13e000ef          	jal	ra,ffffffffc0201d72 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c38:	6442                	ld	s0,16(sp)
ffffffffc0201c3a:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c3c:	8526                	mv	a0,s1
}
ffffffffc0201c3e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c40:	45e1                	li	a1,24
}
ffffffffc0201c42:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c44:	b171                	j	ffffffffc02018d0 <slob_free>
ffffffffc0201c46:	e20d                	bnez	a2,ffffffffc0201c68 <kfree+0xb6>
ffffffffc0201c48:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c4c:	6442                	ld	s0,16(sp)
ffffffffc0201c4e:	60e2                	ld	ra,24(sp)
ffffffffc0201c50:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c52:	4581                	li	a1,0
}
ffffffffc0201c54:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c56:	b9ad                	j	ffffffffc02018d0 <slob_free>
        intr_disable();
ffffffffc0201c58:	9effe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c5c:	000b2797          	auipc	a5,0xb2
ffffffffc0201c60:	b7c7b783          	ld	a5,-1156(a5) # ffffffffc02b37d8 <bigblocks>
        return 1;
ffffffffc0201c64:	4605                	li	a2,1
ffffffffc0201c66:	fbad                	bnez	a5,ffffffffc0201bd8 <kfree+0x26>
        intr_enable();
ffffffffc0201c68:	9d9fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c6c:	bff1                	j	ffffffffc0201c48 <kfree+0x96>
ffffffffc0201c6e:	9d3fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c72:	b751                	j	ffffffffc0201bf6 <kfree+0x44>
ffffffffc0201c74:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c76:	00006617          	auipc	a2,0x6
ffffffffc0201c7a:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc0201c7e:	06200593          	li	a1,98
ffffffffc0201c82:	00006517          	auipc	a0,0x6
ffffffffc0201c86:	95650513          	addi	a0,a0,-1706 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0201c8a:	ff0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c8e:	86a2                	mv	a3,s0
ffffffffc0201c90:	00006617          	auipc	a2,0x6
ffffffffc0201c94:	9c860613          	addi	a2,a2,-1592 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc0201c98:	06e00593          	li	a1,110
ffffffffc0201c9c:	00006517          	auipc	a0,0x6
ffffffffc0201ca0:	93c50513          	addi	a0,a0,-1732 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0201ca4:	fd6fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ca8 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201ca8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201caa:	00006617          	auipc	a2,0x6
ffffffffc0201cae:	9d660613          	addi	a2,a2,-1578 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc0201cb2:	06200593          	li	a1,98
ffffffffc0201cb6:	00006517          	auipc	a0,0x6
ffffffffc0201cba:	92250513          	addi	a0,a0,-1758 # ffffffffc02075d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201cbe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201cc0:	fbafe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201cc4 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201cc4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201cc6:	00006617          	auipc	a2,0x6
ffffffffc0201cca:	9da60613          	addi	a2,a2,-1574 # ffffffffc02076a0 <default_pmm_manager+0x128>
ffffffffc0201cce:	07400593          	li	a1,116
ffffffffc0201cd2:	00006517          	auipc	a0,0x6
ffffffffc0201cd6:	90650513          	addi	a0,a0,-1786 # ffffffffc02075d8 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201cda:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201cdc:	f9efe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ce0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201ce0:	7139                	addi	sp,sp,-64
ffffffffc0201ce2:	f426                	sd	s1,40(sp)
ffffffffc0201ce4:	f04a                	sd	s2,32(sp)
ffffffffc0201ce6:	ec4e                	sd	s3,24(sp)
ffffffffc0201ce8:	e852                	sd	s4,16(sp)
ffffffffc0201cea:	e456                	sd	s5,8(sp)
ffffffffc0201cec:	e05a                	sd	s6,0(sp)
ffffffffc0201cee:	fc06                	sd	ra,56(sp)
ffffffffc0201cf0:	f822                	sd	s0,48(sp)
ffffffffc0201cf2:	84aa                	mv	s1,a0
ffffffffc0201cf4:	000b2917          	auipc	s2,0xb2
ffffffffc0201cf8:	b0c90913          	addi	s2,s2,-1268 # ffffffffc02b3800 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cfc:	4a05                	li	s4,1
ffffffffc0201cfe:	000b2a97          	auipc	s5,0xb2
ffffffffc0201d02:	b22a8a93          	addi	s5,s5,-1246 # ffffffffc02b3820 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d06:	0005099b          	sext.w	s3,a0
ffffffffc0201d0a:	000b2b17          	auipc	s6,0xb2
ffffffffc0201d0e:	b26b0b13          	addi	s6,s6,-1242 # ffffffffc02b3830 <check_mm_struct>
ffffffffc0201d12:	a01d                	j	ffffffffc0201d38 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d14:	00093783          	ld	a5,0(s2)
ffffffffc0201d18:	6f9c                	ld	a5,24(a5)
ffffffffc0201d1a:	9782                	jalr	a5
ffffffffc0201d1c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d1e:	4601                	li	a2,0
ffffffffc0201d20:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d22:	ec0d                	bnez	s0,ffffffffc0201d5c <alloc_pages+0x7c>
ffffffffc0201d24:	029a6c63          	bltu	s4,s1,ffffffffc0201d5c <alloc_pages+0x7c>
ffffffffc0201d28:	000aa783          	lw	a5,0(s5)
ffffffffc0201d2c:	2781                	sext.w	a5,a5
ffffffffc0201d2e:	c79d                	beqz	a5,ffffffffc0201d5c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d30:	000b3503          	ld	a0,0(s6)
ffffffffc0201d34:	6d7010ef          	jal	ra,ffffffffc0203c0a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d38:	100027f3          	csrr	a5,sstatus
ffffffffc0201d3c:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d3e:	8526                	mv	a0,s1
ffffffffc0201d40:	dbf1                	beqz	a5,ffffffffc0201d14 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d42:	905fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0201d46:	00093783          	ld	a5,0(s2)
ffffffffc0201d4a:	8526                	mv	a0,s1
ffffffffc0201d4c:	6f9c                	ld	a5,24(a5)
ffffffffc0201d4e:	9782                	jalr	a5
ffffffffc0201d50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d52:	8effe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d56:	4601                	li	a2,0
ffffffffc0201d58:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d5a:	d469                	beqz	s0,ffffffffc0201d24 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d5c:	70e2                	ld	ra,56(sp)
ffffffffc0201d5e:	8522                	mv	a0,s0
ffffffffc0201d60:	7442                	ld	s0,48(sp)
ffffffffc0201d62:	74a2                	ld	s1,40(sp)
ffffffffc0201d64:	7902                	ld	s2,32(sp)
ffffffffc0201d66:	69e2                	ld	s3,24(sp)
ffffffffc0201d68:	6a42                	ld	s4,16(sp)
ffffffffc0201d6a:	6aa2                	ld	s5,8(sp)
ffffffffc0201d6c:	6b02                	ld	s6,0(sp)
ffffffffc0201d6e:	6121                	addi	sp,sp,64
ffffffffc0201d70:	8082                	ret

ffffffffc0201d72 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d72:	100027f3          	csrr	a5,sstatus
ffffffffc0201d76:	8b89                	andi	a5,a5,2
ffffffffc0201d78:	e799                	bnez	a5,ffffffffc0201d86 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d7a:	000b2797          	auipc	a5,0xb2
ffffffffc0201d7e:	a867b783          	ld	a5,-1402(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0201d82:	739c                	ld	a5,32(a5)
ffffffffc0201d84:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d86:	1101                	addi	sp,sp,-32
ffffffffc0201d88:	ec06                	sd	ra,24(sp)
ffffffffc0201d8a:	e822                	sd	s0,16(sp)
ffffffffc0201d8c:	e426                	sd	s1,8(sp)
ffffffffc0201d8e:	842a                	mv	s0,a0
ffffffffc0201d90:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d92:	8b5fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d96:	000b2797          	auipc	a5,0xb2
ffffffffc0201d9a:	a6a7b783          	ld	a5,-1430(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0201d9e:	739c                	ld	a5,32(a5)
ffffffffc0201da0:	85a6                	mv	a1,s1
ffffffffc0201da2:	8522                	mv	a0,s0
ffffffffc0201da4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201da6:	6442                	ld	s0,16(sp)
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
ffffffffc0201dac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201dae:	893fe06f          	j	ffffffffc0200640 <intr_enable>

ffffffffc0201db2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db2:	100027f3          	csrr	a5,sstatus
ffffffffc0201db6:	8b89                	andi	a5,a5,2
ffffffffc0201db8:	e799                	bnez	a5,ffffffffc0201dc6 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dba:	000b2797          	auipc	a5,0xb2
ffffffffc0201dbe:	a467b783          	ld	a5,-1466(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0201dc2:	779c                	ld	a5,40(a5)
ffffffffc0201dc4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201dc6:	1141                	addi	sp,sp,-16
ffffffffc0201dc8:	e406                	sd	ra,8(sp)
ffffffffc0201dca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201dcc:	87bfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dd0:	000b2797          	auipc	a5,0xb2
ffffffffc0201dd4:	a307b783          	ld	a5,-1488(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0201dd8:	779c                	ld	a5,40(a5)
ffffffffc0201dda:	9782                	jalr	a5
ffffffffc0201ddc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dde:	863fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201de2:	60a2                	ld	ra,8(sp)
ffffffffc0201de4:	8522                	mv	a0,s0
ffffffffc0201de6:	6402                	ld	s0,0(sp)
ffffffffc0201de8:	0141                	addi	sp,sp,16
ffffffffc0201dea:	8082                	ret

ffffffffc0201dec <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dec:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201df0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201df6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dfa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dfe:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e00:	f04a                	sd	s2,32(sp)
ffffffffc0201e02:	ec4e                	sd	s3,24(sp)
ffffffffc0201e04:	e852                	sd	s4,16(sp)
ffffffffc0201e06:	fc06                	sd	ra,56(sp)
ffffffffc0201e08:	f822                	sd	s0,48(sp)
ffffffffc0201e0a:	e456                	sd	s5,8(sp)
ffffffffc0201e0c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e0e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e12:	892e                	mv	s2,a1
ffffffffc0201e14:	89b2                	mv	s3,a2
ffffffffc0201e16:	000b2a17          	auipc	s4,0xb2
ffffffffc0201e1a:	9daa0a13          	addi	s4,s4,-1574 # ffffffffc02b37f0 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e1e:	e7b5                	bnez	a5,ffffffffc0201e8a <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e20:	12060b63          	beqz	a2,ffffffffc0201f56 <get_pte+0x16a>
ffffffffc0201e24:	4505                	li	a0,1
ffffffffc0201e26:	ebbff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201e2a:	842a                	mv	s0,a0
ffffffffc0201e2c:	12050563          	beqz	a0,ffffffffc0201f56 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e30:	000b2b17          	auipc	s6,0xb2
ffffffffc0201e34:	9c8b0b13          	addi	s6,s6,-1592 # ffffffffc02b37f8 <pages>
ffffffffc0201e38:	000b3503          	ld	a0,0(s6)
ffffffffc0201e3c:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e40:	000b2a17          	auipc	s4,0xb2
ffffffffc0201e44:	9b0a0a13          	addi	s4,s4,-1616 # ffffffffc02b37f0 <npage>
ffffffffc0201e48:	40a40533          	sub	a0,s0,a0
ffffffffc0201e4c:	8519                	srai	a0,a0,0x6
ffffffffc0201e4e:	9556                	add	a0,a0,s5
ffffffffc0201e50:	000a3703          	ld	a4,0(s4)
ffffffffc0201e54:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e58:	4685                	li	a3,1
ffffffffc0201e5a:	c014                	sw	a3,0(s0)
ffffffffc0201e5c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e5e:	0532                	slli	a0,a0,0xc
ffffffffc0201e60:	14e7f263          	bgeu	a5,a4,ffffffffc0201fa4 <get_pte+0x1b8>
ffffffffc0201e64:	000b2797          	auipc	a5,0xb2
ffffffffc0201e68:	9a47b783          	ld	a5,-1628(a5) # ffffffffc02b3808 <va_pa_offset>
ffffffffc0201e6c:	6605                	lui	a2,0x1
ffffffffc0201e6e:	4581                	li	a1,0
ffffffffc0201e70:	953e                	add	a0,a0,a5
ffffffffc0201e72:	187040ef          	jal	ra,ffffffffc02067f8 <memset>
    return page - pages + nbase;
ffffffffc0201e76:	000b3683          	ld	a3,0(s6)
ffffffffc0201e7a:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e7e:	8699                	srai	a3,a3,0x6
ffffffffc0201e80:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e82:	06aa                	slli	a3,a3,0xa
ffffffffc0201e84:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e88:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e8a:	77fd                	lui	a5,0xfffff
ffffffffc0201e8c:	068a                	slli	a3,a3,0x2
ffffffffc0201e8e:	000a3703          	ld	a4,0(s4)
ffffffffc0201e92:	8efd                	and	a3,a3,a5
ffffffffc0201e94:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e98:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f5a <get_pte+0x16e>
ffffffffc0201e9c:	000b2a97          	auipc	s5,0xb2
ffffffffc0201ea0:	96ca8a93          	addi	s5,s5,-1684 # ffffffffc02b3808 <va_pa_offset>
ffffffffc0201ea4:	000ab403          	ld	s0,0(s5)
ffffffffc0201ea8:	01595793          	srli	a5,s2,0x15
ffffffffc0201eac:	1ff7f793          	andi	a5,a5,511
ffffffffc0201eb0:	96a2                	add	a3,a3,s0
ffffffffc0201eb2:	00379413          	slli	s0,a5,0x3
ffffffffc0201eb6:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201eb8:	6014                	ld	a3,0(s0)
ffffffffc0201eba:	0016f793          	andi	a5,a3,1
ffffffffc0201ebe:	e3ad                	bnez	a5,ffffffffc0201f20 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201ec0:	08098b63          	beqz	s3,ffffffffc0201f56 <get_pte+0x16a>
ffffffffc0201ec4:	4505                	li	a0,1
ffffffffc0201ec6:	e1bff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201eca:	84aa                	mv	s1,a0
ffffffffc0201ecc:	c549                	beqz	a0,ffffffffc0201f56 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ece:	000b2b17          	auipc	s6,0xb2
ffffffffc0201ed2:	92ab0b13          	addi	s6,s6,-1750 # ffffffffc02b37f8 <pages>
ffffffffc0201ed6:	000b3503          	ld	a0,0(s6)
ffffffffc0201eda:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ede:	000a3703          	ld	a4,0(s4)
ffffffffc0201ee2:	40a48533          	sub	a0,s1,a0
ffffffffc0201ee6:	8519                	srai	a0,a0,0x6
ffffffffc0201ee8:	954e                	add	a0,a0,s3
ffffffffc0201eea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201eee:	4685                	li	a3,1
ffffffffc0201ef0:	c094                	sw	a3,0(s1)
ffffffffc0201ef2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ef4:	0532                	slli	a0,a0,0xc
ffffffffc0201ef6:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f8a <get_pte+0x19e>
ffffffffc0201efa:	000ab783          	ld	a5,0(s5)
ffffffffc0201efe:	6605                	lui	a2,0x1
ffffffffc0201f00:	4581                	li	a1,0
ffffffffc0201f02:	953e                	add	a0,a0,a5
ffffffffc0201f04:	0f5040ef          	jal	ra,ffffffffc02067f8 <memset>
    return page - pages + nbase;
ffffffffc0201f08:	000b3683          	ld	a3,0(s6)
ffffffffc0201f0c:	40d486b3          	sub	a3,s1,a3
ffffffffc0201f10:	8699                	srai	a3,a3,0x6
ffffffffc0201f12:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f14:	06aa                	slli	a3,a3,0xa
ffffffffc0201f16:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f1a:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f1c:	000a3703          	ld	a4,0(s4)
ffffffffc0201f20:	068a                	slli	a3,a3,0x2
ffffffffc0201f22:	757d                	lui	a0,0xfffff
ffffffffc0201f24:	8ee9                	and	a3,a3,a0
ffffffffc0201f26:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f2a:	04e7f463          	bgeu	a5,a4,ffffffffc0201f72 <get_pte+0x186>
ffffffffc0201f2e:	000ab503          	ld	a0,0(s5)
ffffffffc0201f32:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f36:	1ff97913          	andi	s2,s2,511
ffffffffc0201f3a:	96aa                	add	a3,a3,a0
ffffffffc0201f3c:	00391513          	slli	a0,s2,0x3
ffffffffc0201f40:	9536                	add	a0,a0,a3
}
ffffffffc0201f42:	70e2                	ld	ra,56(sp)
ffffffffc0201f44:	7442                	ld	s0,48(sp)
ffffffffc0201f46:	74a2                	ld	s1,40(sp)
ffffffffc0201f48:	7902                	ld	s2,32(sp)
ffffffffc0201f4a:	69e2                	ld	s3,24(sp)
ffffffffc0201f4c:	6a42                	ld	s4,16(sp)
ffffffffc0201f4e:	6aa2                	ld	s5,8(sp)
ffffffffc0201f50:	6b02                	ld	s6,0(sp)
ffffffffc0201f52:	6121                	addi	sp,sp,64
ffffffffc0201f54:	8082                	ret
            return NULL;
ffffffffc0201f56:	4501                	li	a0,0
ffffffffc0201f58:	b7ed                	j	ffffffffc0201f42 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f5a:	00005617          	auipc	a2,0x5
ffffffffc0201f5e:	65660613          	addi	a2,a2,1622 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0201f62:	0e300593          	li	a1,227
ffffffffc0201f66:	00005517          	auipc	a0,0x5
ffffffffc0201f6a:	76250513          	addi	a0,a0,1890 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0201f6e:	d0cfe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f72:	00005617          	auipc	a2,0x5
ffffffffc0201f76:	63e60613          	addi	a2,a2,1598 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0201f7a:	0ee00593          	li	a1,238
ffffffffc0201f7e:	00005517          	auipc	a0,0x5
ffffffffc0201f82:	74a50513          	addi	a0,a0,1866 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0201f86:	cf4fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f8a:	86aa                	mv	a3,a0
ffffffffc0201f8c:	00005617          	auipc	a2,0x5
ffffffffc0201f90:	62460613          	addi	a2,a2,1572 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0201f94:	0eb00593          	li	a1,235
ffffffffc0201f98:	00005517          	auipc	a0,0x5
ffffffffc0201f9c:	73050513          	addi	a0,a0,1840 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0201fa0:	cdafe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fa4:	86aa                	mv	a3,a0
ffffffffc0201fa6:	00005617          	auipc	a2,0x5
ffffffffc0201faa:	60a60613          	addi	a2,a2,1546 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0201fae:	0df00593          	li	a1,223
ffffffffc0201fb2:	00005517          	auipc	a0,0x5
ffffffffc0201fb6:	71650513          	addi	a0,a0,1814 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0201fba:	cc0fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201fbe <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fbe:	1141                	addi	sp,sp,-16
ffffffffc0201fc0:	e022                	sd	s0,0(sp)
ffffffffc0201fc2:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fc4:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fc6:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fc8:	e25ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201fcc:	c011                	beqz	s0,ffffffffc0201fd0 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201fce:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fd0:	c511                	beqz	a0,ffffffffc0201fdc <get_page+0x1e>
ffffffffc0201fd2:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201fd4:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fd6:	0017f713          	andi	a4,a5,1
ffffffffc0201fda:	e709                	bnez	a4,ffffffffc0201fe4 <get_page+0x26>
}
ffffffffc0201fdc:	60a2                	ld	ra,8(sp)
ffffffffc0201fde:	6402                	ld	s0,0(sp)
ffffffffc0201fe0:	0141                	addi	sp,sp,16
ffffffffc0201fe2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fe4:	078a                	slli	a5,a5,0x2
ffffffffc0201fe6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fe8:	000b2717          	auipc	a4,0xb2
ffffffffc0201fec:	80873703          	ld	a4,-2040(a4) # ffffffffc02b37f0 <npage>
ffffffffc0201ff0:	00e7ff63          	bgeu	a5,a4,ffffffffc020200e <get_page+0x50>
ffffffffc0201ff4:	60a2                	ld	ra,8(sp)
ffffffffc0201ff6:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff8:	fff80537          	lui	a0,0xfff80
ffffffffc0201ffc:	97aa                	add	a5,a5,a0
ffffffffc0201ffe:	079a                	slli	a5,a5,0x6
ffffffffc0202000:	000b1517          	auipc	a0,0xb1
ffffffffc0202004:	7f853503          	ld	a0,2040(a0) # ffffffffc02b37f8 <pages>
ffffffffc0202008:	953e                	add	a0,a0,a5
ffffffffc020200a:	0141                	addi	sp,sp,16
ffffffffc020200c:	8082                	ret
ffffffffc020200e:	c9bff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202012 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202012:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202014:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202018:	f486                	sd	ra,104(sp)
ffffffffc020201a:	f0a2                	sd	s0,96(sp)
ffffffffc020201c:	eca6                	sd	s1,88(sp)
ffffffffc020201e:	e8ca                	sd	s2,80(sp)
ffffffffc0202020:	e4ce                	sd	s3,72(sp)
ffffffffc0202022:	e0d2                	sd	s4,64(sp)
ffffffffc0202024:	fc56                	sd	s5,56(sp)
ffffffffc0202026:	f85a                	sd	s6,48(sp)
ffffffffc0202028:	f45e                	sd	s7,40(sp)
ffffffffc020202a:	f062                	sd	s8,32(sp)
ffffffffc020202c:	ec66                	sd	s9,24(sp)
ffffffffc020202e:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202030:	17d2                	slli	a5,a5,0x34
ffffffffc0202032:	e3ed                	bnez	a5,ffffffffc0202114 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202034:	002007b7          	lui	a5,0x200
ffffffffc0202038:	842e                	mv	s0,a1
ffffffffc020203a:	0ef5ed63          	bltu	a1,a5,ffffffffc0202134 <unmap_range+0x122>
ffffffffc020203e:	8932                	mv	s2,a2
ffffffffc0202040:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202134 <unmap_range+0x122>
ffffffffc0202044:	4785                	li	a5,1
ffffffffc0202046:	07fe                	slli	a5,a5,0x1f
ffffffffc0202048:	0ec7e663          	bltu	a5,a2,ffffffffc0202134 <unmap_range+0x122>
ffffffffc020204c:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020204e:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202050:	000b1c97          	auipc	s9,0xb1
ffffffffc0202054:	7a0c8c93          	addi	s9,s9,1952 # ffffffffc02b37f0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202058:	000b1c17          	auipc	s8,0xb1
ffffffffc020205c:	7a0c0c13          	addi	s8,s8,1952 # ffffffffc02b37f8 <pages>
ffffffffc0202060:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202064:	000b1d17          	auipc	s10,0xb1
ffffffffc0202068:	79cd0d13          	addi	s10,s10,1948 # ffffffffc02b3800 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020206c:	00200b37          	lui	s6,0x200
ffffffffc0202070:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202074:	4601                	li	a2,0
ffffffffc0202076:	85a2                	mv	a1,s0
ffffffffc0202078:	854e                	mv	a0,s3
ffffffffc020207a:	d73ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020207e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202080:	cd29                	beqz	a0,ffffffffc02020da <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc0202082:	611c                	ld	a5,0(a0)
ffffffffc0202084:	e395                	bnez	a5,ffffffffc02020a8 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202086:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202088:	ff2466e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x62>
}
ffffffffc020208c:	70a6                	ld	ra,104(sp)
ffffffffc020208e:	7406                	ld	s0,96(sp)
ffffffffc0202090:	64e6                	ld	s1,88(sp)
ffffffffc0202092:	6946                	ld	s2,80(sp)
ffffffffc0202094:	69a6                	ld	s3,72(sp)
ffffffffc0202096:	6a06                	ld	s4,64(sp)
ffffffffc0202098:	7ae2                	ld	s5,56(sp)
ffffffffc020209a:	7b42                	ld	s6,48(sp)
ffffffffc020209c:	7ba2                	ld	s7,40(sp)
ffffffffc020209e:	7c02                	ld	s8,32(sp)
ffffffffc02020a0:	6ce2                	ld	s9,24(sp)
ffffffffc02020a2:	6d42                	ld	s10,16(sp)
ffffffffc02020a4:	6165                	addi	sp,sp,112
ffffffffc02020a6:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02020a8:	0017f713          	andi	a4,a5,1
ffffffffc02020ac:	df69                	beqz	a4,ffffffffc0202086 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc02020ae:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02020b2:	078a                	slli	a5,a5,0x2
ffffffffc02020b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b6:	08e7ff63          	bgeu	a5,a4,ffffffffc0202154 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02020ba:	000c3503          	ld	a0,0(s8)
ffffffffc02020be:	97de                	add	a5,a5,s7
ffffffffc02020c0:	079a                	slli	a5,a5,0x6
ffffffffc02020c2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020c4:	411c                	lw	a5,0(a0)
ffffffffc02020c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02020ca:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02020cc:	cf11                	beqz	a4,ffffffffc02020e8 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020ce:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020d2:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020d6:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020d8:	bf45                	j	ffffffffc0202088 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020da:	945a                	add	s0,s0,s6
ffffffffc02020dc:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02020e0:	d455                	beqz	s0,ffffffffc020208c <unmap_range+0x7a>
ffffffffc02020e2:	f92469e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x62>
ffffffffc02020e6:	b75d                	j	ffffffffc020208c <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020e8:	100027f3          	csrr	a5,sstatus
ffffffffc02020ec:	8b89                	andi	a5,a5,2
ffffffffc02020ee:	e799                	bnez	a5,ffffffffc02020fc <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02020f0:	000d3783          	ld	a5,0(s10)
ffffffffc02020f4:	4585                	li	a1,1
ffffffffc02020f6:	739c                	ld	a5,32(a5)
ffffffffc02020f8:	9782                	jalr	a5
    if (flag) {
ffffffffc02020fa:	bfd1                	j	ffffffffc02020ce <unmap_range+0xbc>
ffffffffc02020fc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020fe:	d48fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202102:	000d3783          	ld	a5,0(s10)
ffffffffc0202106:	6522                	ld	a0,8(sp)
ffffffffc0202108:	4585                	li	a1,1
ffffffffc020210a:	739c                	ld	a5,32(a5)
ffffffffc020210c:	9782                	jalr	a5
        intr_enable();
ffffffffc020210e:	d32fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202112:	bf75                	j	ffffffffc02020ce <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202114:	00005697          	auipc	a3,0x5
ffffffffc0202118:	5c468693          	addi	a3,a3,1476 # ffffffffc02076d8 <default_pmm_manager+0x160>
ffffffffc020211c:	00005617          	auipc	a2,0x5
ffffffffc0202120:	dc460613          	addi	a2,a2,-572 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202124:	10f00593          	li	a1,271
ffffffffc0202128:	00005517          	auipc	a0,0x5
ffffffffc020212c:	5a050513          	addi	a0,a0,1440 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202130:	b4afe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202134:	00005697          	auipc	a3,0x5
ffffffffc0202138:	5d468693          	addi	a3,a3,1492 # ffffffffc0207708 <default_pmm_manager+0x190>
ffffffffc020213c:	00005617          	auipc	a2,0x5
ffffffffc0202140:	da460613          	addi	a2,a2,-604 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202144:	11000593          	li	a1,272
ffffffffc0202148:	00005517          	auipc	a0,0x5
ffffffffc020214c:	58050513          	addi	a0,a0,1408 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202150:	b2afe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202154:	b55ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202158 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202158:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020215a:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020215e:	fc86                	sd	ra,120(sp)
ffffffffc0202160:	f8a2                	sd	s0,112(sp)
ffffffffc0202162:	f4a6                	sd	s1,104(sp)
ffffffffc0202164:	f0ca                	sd	s2,96(sp)
ffffffffc0202166:	ecce                	sd	s3,88(sp)
ffffffffc0202168:	e8d2                	sd	s4,80(sp)
ffffffffc020216a:	e4d6                	sd	s5,72(sp)
ffffffffc020216c:	e0da                	sd	s6,64(sp)
ffffffffc020216e:	fc5e                	sd	s7,56(sp)
ffffffffc0202170:	f862                	sd	s8,48(sp)
ffffffffc0202172:	f466                	sd	s9,40(sp)
ffffffffc0202174:	f06a                	sd	s10,32(sp)
ffffffffc0202176:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202178:	17d2                	slli	a5,a5,0x34
ffffffffc020217a:	20079a63          	bnez	a5,ffffffffc020238e <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020217e:	002007b7          	lui	a5,0x200
ffffffffc0202182:	24f5e463          	bltu	a1,a5,ffffffffc02023ca <exit_range+0x272>
ffffffffc0202186:	8ab2                	mv	s5,a2
ffffffffc0202188:	24c5f163          	bgeu	a1,a2,ffffffffc02023ca <exit_range+0x272>
ffffffffc020218c:	4785                	li	a5,1
ffffffffc020218e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202190:	22c7ed63          	bltu	a5,a2,ffffffffc02023ca <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202194:	c00009b7          	lui	s3,0xc0000
ffffffffc0202198:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020219c:	ffe00937          	lui	s2,0xffe00
ffffffffc02021a0:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02021a4:	5cfd                	li	s9,-1
ffffffffc02021a6:	8c2a                	mv	s8,a0
ffffffffc02021a8:	0125f933          	and	s2,a1,s2
ffffffffc02021ac:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc02021ae:	000b1d17          	auipc	s10,0xb1
ffffffffc02021b2:	642d0d13          	addi	s10,s10,1602 # ffffffffc02b37f0 <npage>
    return KADDR(page2pa(page));
ffffffffc02021b6:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02021ba:	000b1717          	auipc	a4,0xb1
ffffffffc02021be:	63e70713          	addi	a4,a4,1598 # ffffffffc02b37f8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02021c2:	000b1d97          	auipc	s11,0xb1
ffffffffc02021c6:	63ed8d93          	addi	s11,s11,1598 # ffffffffc02b3800 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021ca:	c0000437          	lui	s0,0xc0000
ffffffffc02021ce:	944e                	add	s0,s0,s3
ffffffffc02021d0:	8079                	srli	s0,s0,0x1e
ffffffffc02021d2:	1ff47413          	andi	s0,s0,511
ffffffffc02021d6:	040e                	slli	s0,s0,0x3
ffffffffc02021d8:	9462                	add	s0,s0,s8
ffffffffc02021da:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
        if (pde1&PTE_V){
ffffffffc02021de:	001a7793          	andi	a5,s4,1
ffffffffc02021e2:	eb99                	bnez	a5,ffffffffc02021f8 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02021e4:	12098463          	beqz	s3,ffffffffc020230c <exit_range+0x1b4>
ffffffffc02021e8:	400007b7          	lui	a5,0x40000
ffffffffc02021ec:	97ce                	add	a5,a5,s3
ffffffffc02021ee:	894e                	mv	s2,s3
ffffffffc02021f0:	1159fe63          	bgeu	s3,s5,ffffffffc020230c <exit_range+0x1b4>
ffffffffc02021f4:	89be                	mv	s3,a5
ffffffffc02021f6:	bfd1                	j	ffffffffc02021ca <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021f8:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021fc:	0a0a                	slli	s4,s4,0x2
ffffffffc02021fe:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202202:	1cfa7263          	bgeu	s4,a5,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202206:	fff80637          	lui	a2,0xfff80
ffffffffc020220a:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc020220c:	000806b7          	lui	a3,0x80
ffffffffc0202210:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202212:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202216:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202218:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020221a:	18f5fa63          	bgeu	a1,a5,ffffffffc02023ae <exit_range+0x256>
ffffffffc020221e:	000b1817          	auipc	a6,0xb1
ffffffffc0202222:	5ea80813          	addi	a6,a6,1514 # ffffffffc02b3808 <va_pa_offset>
ffffffffc0202226:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc020222a:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc020222c:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202230:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202232:	00080337          	lui	t1,0x80
ffffffffc0202236:	6885                	lui	a7,0x1
ffffffffc0202238:	a819                	j	ffffffffc020224e <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc020223a:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc020223c:	002007b7          	lui	a5,0x200
ffffffffc0202240:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202242:	08090c63          	beqz	s2,ffffffffc02022da <exit_range+0x182>
ffffffffc0202246:	09397a63          	bgeu	s2,s3,ffffffffc02022da <exit_range+0x182>
ffffffffc020224a:	0f597063          	bgeu	s2,s5,ffffffffc020232a <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020224e:	01595493          	srli	s1,s2,0x15
ffffffffc0202252:	1ff4f493          	andi	s1,s1,511
ffffffffc0202256:	048e                	slli	s1,s1,0x3
ffffffffc0202258:	94da                	add	s1,s1,s6
ffffffffc020225a:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc020225c:	0017f693          	andi	a3,a5,1
ffffffffc0202260:	dee9                	beqz	a3,ffffffffc020223a <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0202262:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202266:	078a                	slli	a5,a5,0x2
ffffffffc0202268:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020226a:	14b7fe63          	bgeu	a5,a1,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020226e:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202270:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202274:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202278:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020227c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020227e:	12bef863          	bgeu	t4,a1,ffffffffc02023ae <exit_range+0x256>
ffffffffc0202282:	00083783          	ld	a5,0(a6)
ffffffffc0202286:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202288:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc020228c:	629c                	ld	a5,0(a3)
ffffffffc020228e:	8b85                	andi	a5,a5,1
ffffffffc0202290:	f7d5                	bnez	a5,ffffffffc020223c <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202292:	06a1                	addi	a3,a3,8
ffffffffc0202294:	fed59ce3          	bne	a1,a3,ffffffffc020228c <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202298:	631c                	ld	a5,0(a4)
ffffffffc020229a:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020229c:	100027f3          	csrr	a5,sstatus
ffffffffc02022a0:	8b89                	andi	a5,a5,2
ffffffffc02022a2:	e7d9                	bnez	a5,ffffffffc0202330 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02022a4:	000db783          	ld	a5,0(s11)
ffffffffc02022a8:	4585                	li	a1,1
ffffffffc02022aa:	e032                	sd	a2,0(sp)
ffffffffc02022ac:	739c                	ld	a5,32(a5)
ffffffffc02022ae:	9782                	jalr	a5
    if (flag) {
ffffffffc02022b0:	6602                	ld	a2,0(sp)
ffffffffc02022b2:	000b1817          	auipc	a6,0xb1
ffffffffc02022b6:	55680813          	addi	a6,a6,1366 # ffffffffc02b3808 <va_pa_offset>
ffffffffc02022ba:	fff80e37          	lui	t3,0xfff80
ffffffffc02022be:	00080337          	lui	t1,0x80
ffffffffc02022c2:	6885                	lui	a7,0x1
ffffffffc02022c4:	000b1717          	auipc	a4,0xb1
ffffffffc02022c8:	53470713          	addi	a4,a4,1332 # ffffffffc02b37f8 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022cc:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02022d0:	002007b7          	lui	a5,0x200
ffffffffc02022d4:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022d6:	f60918e3          	bnez	s2,ffffffffc0202246 <exit_range+0xee>
            if (free_pd0) {
ffffffffc02022da:	f00b85e3          	beqz	s7,ffffffffc02021e4 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02022de:	000d3783          	ld	a5,0(s10)
ffffffffc02022e2:	0efa7263          	bgeu	s4,a5,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022e6:	6308                	ld	a0,0(a4)
ffffffffc02022e8:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022ea:	100027f3          	csrr	a5,sstatus
ffffffffc02022ee:	8b89                	andi	a5,a5,2
ffffffffc02022f0:	efad                	bnez	a5,ffffffffc020236a <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02022f2:	000db783          	ld	a5,0(s11)
ffffffffc02022f6:	4585                	li	a1,1
ffffffffc02022f8:	739c                	ld	a5,32(a5)
ffffffffc02022fa:	9782                	jalr	a5
ffffffffc02022fc:	000b1717          	auipc	a4,0xb1
ffffffffc0202300:	4fc70713          	addi	a4,a4,1276 # ffffffffc02b37f8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202304:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202308:	ee0990e3          	bnez	s3,ffffffffc02021e8 <exit_range+0x90>
}
ffffffffc020230c:	70e6                	ld	ra,120(sp)
ffffffffc020230e:	7446                	ld	s0,112(sp)
ffffffffc0202310:	74a6                	ld	s1,104(sp)
ffffffffc0202312:	7906                	ld	s2,96(sp)
ffffffffc0202314:	69e6                	ld	s3,88(sp)
ffffffffc0202316:	6a46                	ld	s4,80(sp)
ffffffffc0202318:	6aa6                	ld	s5,72(sp)
ffffffffc020231a:	6b06                	ld	s6,64(sp)
ffffffffc020231c:	7be2                	ld	s7,56(sp)
ffffffffc020231e:	7c42                	ld	s8,48(sp)
ffffffffc0202320:	7ca2                	ld	s9,40(sp)
ffffffffc0202322:	7d02                	ld	s10,32(sp)
ffffffffc0202324:	6de2                	ld	s11,24(sp)
ffffffffc0202326:	6109                	addi	sp,sp,128
ffffffffc0202328:	8082                	ret
            if (free_pd0) {
ffffffffc020232a:	ea0b8fe3          	beqz	s7,ffffffffc02021e8 <exit_range+0x90>
ffffffffc020232e:	bf45                	j	ffffffffc02022de <exit_range+0x186>
ffffffffc0202330:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202332:	e42a                	sd	a0,8(sp)
ffffffffc0202334:	b12fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202338:	000db783          	ld	a5,0(s11)
ffffffffc020233c:	6522                	ld	a0,8(sp)
ffffffffc020233e:	4585                	li	a1,1
ffffffffc0202340:	739c                	ld	a5,32(a5)
ffffffffc0202342:	9782                	jalr	a5
        intr_enable();
ffffffffc0202344:	afcfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202348:	6602                	ld	a2,0(sp)
ffffffffc020234a:	000b1717          	auipc	a4,0xb1
ffffffffc020234e:	4ae70713          	addi	a4,a4,1198 # ffffffffc02b37f8 <pages>
ffffffffc0202352:	6885                	lui	a7,0x1
ffffffffc0202354:	00080337          	lui	t1,0x80
ffffffffc0202358:	fff80e37          	lui	t3,0xfff80
ffffffffc020235c:	000b1817          	auipc	a6,0xb1
ffffffffc0202360:	4ac80813          	addi	a6,a6,1196 # ffffffffc02b3808 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202364:	0004b023          	sd	zero,0(s1)
ffffffffc0202368:	b7a5                	j	ffffffffc02022d0 <exit_range+0x178>
ffffffffc020236a:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020236c:	adafe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202370:	000db783          	ld	a5,0(s11)
ffffffffc0202374:	6502                	ld	a0,0(sp)
ffffffffc0202376:	4585                	li	a1,1
ffffffffc0202378:	739c                	ld	a5,32(a5)
ffffffffc020237a:	9782                	jalr	a5
        intr_enable();
ffffffffc020237c:	ac4fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202380:	000b1717          	auipc	a4,0xb1
ffffffffc0202384:	47870713          	addi	a4,a4,1144 # ffffffffc02b37f8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202388:	00043023          	sd	zero,0(s0)
ffffffffc020238c:	bfb5                	j	ffffffffc0202308 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020238e:	00005697          	auipc	a3,0x5
ffffffffc0202392:	34a68693          	addi	a3,a3,842 # ffffffffc02076d8 <default_pmm_manager+0x160>
ffffffffc0202396:	00005617          	auipc	a2,0x5
ffffffffc020239a:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020239e:	12000593          	li	a1,288
ffffffffc02023a2:	00005517          	auipc	a0,0x5
ffffffffc02023a6:	32650513          	addi	a0,a0,806 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02023aa:	8d0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02023ae:	00005617          	auipc	a2,0x5
ffffffffc02023b2:	20260613          	addi	a2,a2,514 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc02023b6:	06900593          	li	a1,105
ffffffffc02023ba:	00005517          	auipc	a0,0x5
ffffffffc02023be:	21e50513          	addi	a0,a0,542 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc02023c2:	8b8fe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02023c6:	8e3ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023ca:	00005697          	auipc	a3,0x5
ffffffffc02023ce:	33e68693          	addi	a3,a3,830 # ffffffffc0207708 <default_pmm_manager+0x190>
ffffffffc02023d2:	00005617          	auipc	a2,0x5
ffffffffc02023d6:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02023da:	12100593          	li	a1,289
ffffffffc02023de:	00005517          	auipc	a0,0x5
ffffffffc02023e2:	2ea50513          	addi	a0,a0,746 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02023e6:	894fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02023ea <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ea:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023ec:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ee:	ec26                	sd	s1,24(sp)
ffffffffc02023f0:	f406                	sd	ra,40(sp)
ffffffffc02023f2:	f022                	sd	s0,32(sp)
ffffffffc02023f4:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023f6:	9f7ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep != NULL) {
ffffffffc02023fa:	c511                	beqz	a0,ffffffffc0202406 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023fc:	611c                	ld	a5,0(a0)
ffffffffc02023fe:	842a                	mv	s0,a0
ffffffffc0202400:	0017f713          	andi	a4,a5,1
ffffffffc0202404:	e711                	bnez	a4,ffffffffc0202410 <page_remove+0x26>
}
ffffffffc0202406:	70a2                	ld	ra,40(sp)
ffffffffc0202408:	7402                	ld	s0,32(sp)
ffffffffc020240a:	64e2                	ld	s1,24(sp)
ffffffffc020240c:	6145                	addi	sp,sp,48
ffffffffc020240e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202410:	078a                	slli	a5,a5,0x2
ffffffffc0202412:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202414:	000b1717          	auipc	a4,0xb1
ffffffffc0202418:	3dc73703          	ld	a4,988(a4) # ffffffffc02b37f0 <npage>
ffffffffc020241c:	06e7f363          	bgeu	a5,a4,ffffffffc0202482 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202420:	fff80537          	lui	a0,0xfff80
ffffffffc0202424:	97aa                	add	a5,a5,a0
ffffffffc0202426:	079a                	slli	a5,a5,0x6
ffffffffc0202428:	000b1517          	auipc	a0,0xb1
ffffffffc020242c:	3d053503          	ld	a0,976(a0) # ffffffffc02b37f8 <pages>
ffffffffc0202430:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202432:	411c                	lw	a5,0(a0)
ffffffffc0202434:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202438:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020243a:	cb11                	beqz	a4,ffffffffc020244e <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020243c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202440:	12048073          	sfence.vma	s1
}
ffffffffc0202444:	70a2                	ld	ra,40(sp)
ffffffffc0202446:	7402                	ld	s0,32(sp)
ffffffffc0202448:	64e2                	ld	s1,24(sp)
ffffffffc020244a:	6145                	addi	sp,sp,48
ffffffffc020244c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020244e:	100027f3          	csrr	a5,sstatus
ffffffffc0202452:	8b89                	andi	a5,a5,2
ffffffffc0202454:	eb89                	bnez	a5,ffffffffc0202466 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202456:	000b1797          	auipc	a5,0xb1
ffffffffc020245a:	3aa7b783          	ld	a5,938(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc020245e:	739c                	ld	a5,32(a5)
ffffffffc0202460:	4585                	li	a1,1
ffffffffc0202462:	9782                	jalr	a5
    if (flag) {
ffffffffc0202464:	bfe1                	j	ffffffffc020243c <page_remove+0x52>
        intr_disable();
ffffffffc0202466:	e42a                	sd	a0,8(sp)
ffffffffc0202468:	9defe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020246c:	000b1797          	auipc	a5,0xb1
ffffffffc0202470:	3947b783          	ld	a5,916(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0202474:	739c                	ld	a5,32(a5)
ffffffffc0202476:	6522                	ld	a0,8(sp)
ffffffffc0202478:	4585                	li	a1,1
ffffffffc020247a:	9782                	jalr	a5
        intr_enable();
ffffffffc020247c:	9c4fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202480:	bf75                	j	ffffffffc020243c <page_remove+0x52>
ffffffffc0202482:	827ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202486 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202486:	7139                	addi	sp,sp,-64
ffffffffc0202488:	e852                	sd	s4,16(sp)
ffffffffc020248a:	8a32                	mv	s4,a2
ffffffffc020248c:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020248e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202490:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202492:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202494:	f426                	sd	s1,40(sp)
ffffffffc0202496:	fc06                	sd	ra,56(sp)
ffffffffc0202498:	f04a                	sd	s2,32(sp)
ffffffffc020249a:	ec4e                	sd	s3,24(sp)
ffffffffc020249c:	e456                	sd	s5,8(sp)
ffffffffc020249e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024a0:	94dff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep == NULL) {
ffffffffc02024a4:	c961                	beqz	a0,ffffffffc0202574 <page_insert+0xee>
    page->ref += 1;
ffffffffc02024a6:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02024a8:	611c                	ld	a5,0(a0)
ffffffffc02024aa:	89aa                	mv	s3,a0
ffffffffc02024ac:	0016871b          	addiw	a4,a3,1
ffffffffc02024b0:	c018                	sw	a4,0(s0)
ffffffffc02024b2:	0017f713          	andi	a4,a5,1
ffffffffc02024b6:	ef05                	bnez	a4,ffffffffc02024ee <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02024b8:	000b1717          	auipc	a4,0xb1
ffffffffc02024bc:	34073703          	ld	a4,832(a4) # ffffffffc02b37f8 <pages>
ffffffffc02024c0:	8c19                	sub	s0,s0,a4
ffffffffc02024c2:	000807b7          	lui	a5,0x80
ffffffffc02024c6:	8419                	srai	s0,s0,0x6
ffffffffc02024c8:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024ca:	042a                	slli	s0,s0,0xa
ffffffffc02024cc:	8cc1                	or	s1,s1,s0
ffffffffc02024ce:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024d2:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024d6:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024da:	4501                	li	a0,0
}
ffffffffc02024dc:	70e2                	ld	ra,56(sp)
ffffffffc02024de:	7442                	ld	s0,48(sp)
ffffffffc02024e0:	74a2                	ld	s1,40(sp)
ffffffffc02024e2:	7902                	ld	s2,32(sp)
ffffffffc02024e4:	69e2                	ld	s3,24(sp)
ffffffffc02024e6:	6a42                	ld	s4,16(sp)
ffffffffc02024e8:	6aa2                	ld	s5,8(sp)
ffffffffc02024ea:	6121                	addi	sp,sp,64
ffffffffc02024ec:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024ee:	078a                	slli	a5,a5,0x2
ffffffffc02024f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024f2:	000b1717          	auipc	a4,0xb1
ffffffffc02024f6:	2fe73703          	ld	a4,766(a4) # ffffffffc02b37f0 <npage>
ffffffffc02024fa:	06e7ff63          	bgeu	a5,a4,ffffffffc0202578 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02024fe:	000b1a97          	auipc	s5,0xb1
ffffffffc0202502:	2faa8a93          	addi	s5,s5,762 # ffffffffc02b37f8 <pages>
ffffffffc0202506:	000ab703          	ld	a4,0(s5)
ffffffffc020250a:	fff80937          	lui	s2,0xfff80
ffffffffc020250e:	993e                	add	s2,s2,a5
ffffffffc0202510:	091a                	slli	s2,s2,0x6
ffffffffc0202512:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202514:	01240c63          	beq	s0,s2,ffffffffc020252c <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202518:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccc7a4>
ffffffffc020251c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202520:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202524:	c691                	beqz	a3,ffffffffc0202530 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202526:	120a0073          	sfence.vma	s4
}
ffffffffc020252a:	bf59                	j	ffffffffc02024c0 <page_insert+0x3a>
ffffffffc020252c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020252e:	bf49                	j	ffffffffc02024c0 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202530:	100027f3          	csrr	a5,sstatus
ffffffffc0202534:	8b89                	andi	a5,a5,2
ffffffffc0202536:	ef91                	bnez	a5,ffffffffc0202552 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202538:	000b1797          	auipc	a5,0xb1
ffffffffc020253c:	2c87b783          	ld	a5,712(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0202540:	739c                	ld	a5,32(a5)
ffffffffc0202542:	4585                	li	a1,1
ffffffffc0202544:	854a                	mv	a0,s2
ffffffffc0202546:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202548:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254c:	120a0073          	sfence.vma	s4
ffffffffc0202550:	bf85                	j	ffffffffc02024c0 <page_insert+0x3a>
        intr_disable();
ffffffffc0202552:	8f4fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202556:	000b1797          	auipc	a5,0xb1
ffffffffc020255a:	2aa7b783          	ld	a5,682(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc020255e:	739c                	ld	a5,32(a5)
ffffffffc0202560:	4585                	li	a1,1
ffffffffc0202562:	854a                	mv	a0,s2
ffffffffc0202564:	9782                	jalr	a5
        intr_enable();
ffffffffc0202566:	8dafe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020256a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020256e:	120a0073          	sfence.vma	s4
ffffffffc0202572:	b7b9                	j	ffffffffc02024c0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202574:	5571                	li	a0,-4
ffffffffc0202576:	b79d                	j	ffffffffc02024dc <page_insert+0x56>
ffffffffc0202578:	f30ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc020257c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020257c:	00005797          	auipc	a5,0x5
ffffffffc0202580:	ffc78793          	addi	a5,a5,-4 # ffffffffc0207578 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202584:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202586:	711d                	addi	sp,sp,-96
ffffffffc0202588:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020258a:	00005517          	auipc	a0,0x5
ffffffffc020258e:	19650513          	addi	a0,a0,406 # ffffffffc0207720 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202592:	000b1b97          	auipc	s7,0xb1
ffffffffc0202596:	26eb8b93          	addi	s7,s7,622 # ffffffffc02b3800 <pmm_manager>
void pmm_init(void) {
ffffffffc020259a:	ec86                	sd	ra,88(sp)
ffffffffc020259c:	e4a6                	sd	s1,72(sp)
ffffffffc020259e:	fc4e                	sd	s3,56(sp)
ffffffffc02025a0:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02025a2:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02025a6:	e8a2                	sd	s0,80(sp)
ffffffffc02025a8:	e0ca                	sd	s2,64(sp)
ffffffffc02025aa:	f852                	sd	s4,48(sp)
ffffffffc02025ac:	f456                	sd	s5,40(sp)
ffffffffc02025ae:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025b0:	bd1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc02025b4:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025b8:	000b1997          	auipc	s3,0xb1
ffffffffc02025bc:	25098993          	addi	s3,s3,592 # ffffffffc02b3808 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02025c0:	000b1497          	auipc	s1,0xb1
ffffffffc02025c4:	23048493          	addi	s1,s1,560 # ffffffffc02b37f0 <npage>
    pmm_manager->init();
ffffffffc02025c8:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025ca:	000b1b17          	auipc	s6,0xb1
ffffffffc02025ce:	22eb0b13          	addi	s6,s6,558 # ffffffffc02b37f8 <pages>
    pmm_manager->init();
ffffffffc02025d2:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025d4:	57f5                	li	a5,-3
ffffffffc02025d6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025d8:	00005517          	auipc	a0,0x5
ffffffffc02025dc:	16050513          	addi	a0,a0,352 # ffffffffc0207738 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025e0:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025e4:	b9dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025e8:	46c5                	li	a3,17
ffffffffc02025ea:	06ee                	slli	a3,a3,0x1b
ffffffffc02025ec:	40100613          	li	a2,1025
ffffffffc02025f0:	07e005b7          	lui	a1,0x7e00
ffffffffc02025f4:	16fd                	addi	a3,a3,-1
ffffffffc02025f6:	0656                	slli	a2,a2,0x15
ffffffffc02025f8:	00005517          	auipc	a0,0x5
ffffffffc02025fc:	15850513          	addi	a0,a0,344 # ffffffffc0207750 <default_pmm_manager+0x1d8>
ffffffffc0202600:	b81fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202604:	777d                	lui	a4,0xfffff
ffffffffc0202606:	000b2797          	auipc	a5,0xb2
ffffffffc020260a:	25578793          	addi	a5,a5,597 # ffffffffc02b485b <end+0xfff>
ffffffffc020260e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202610:	00088737          	lui	a4,0x88
ffffffffc0202614:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202616:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020261a:	4701                	li	a4,0
ffffffffc020261c:	4585                	li	a1,1
ffffffffc020261e:	fff80837          	lui	a6,0xfff80
ffffffffc0202622:	a019                	j	ffffffffc0202628 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0202624:	000b3783          	ld	a5,0(s6)
ffffffffc0202628:	00671693          	slli	a3,a4,0x6
ffffffffc020262c:	97b6                	add	a5,a5,a3
ffffffffc020262e:	07a1                	addi	a5,a5,8
ffffffffc0202630:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202634:	6090                	ld	a2,0(s1)
ffffffffc0202636:	0705                	addi	a4,a4,1
ffffffffc0202638:	010607b3          	add	a5,a2,a6
ffffffffc020263c:	fef764e3          	bltu	a4,a5,ffffffffc0202624 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202640:	000b3503          	ld	a0,0(s6)
ffffffffc0202644:	079a                	slli	a5,a5,0x6
ffffffffc0202646:	c0200737          	lui	a4,0xc0200
ffffffffc020264a:	00f506b3          	add	a3,a0,a5
ffffffffc020264e:	60e6e563          	bltu	a3,a4,ffffffffc0202c58 <pmm_init+0x6dc>
ffffffffc0202652:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202656:	4745                	li	a4,17
ffffffffc0202658:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020265a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020265c:	4ae6e563          	bltu	a3,a4,ffffffffc0202b06 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202660:	00005517          	auipc	a0,0x5
ffffffffc0202664:	11850513          	addi	a0,a0,280 # ffffffffc0207778 <default_pmm_manager+0x200>
ffffffffc0202668:	b19fd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020266c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202670:	000b1917          	auipc	s2,0xb1
ffffffffc0202674:	17890913          	addi	s2,s2,376 # ffffffffc02b37e8 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202678:	7b9c                	ld	a5,48(a5)
ffffffffc020267a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020267c:	00005517          	auipc	a0,0x5
ffffffffc0202680:	11450513          	addi	a0,a0,276 # ffffffffc0207790 <default_pmm_manager+0x218>
ffffffffc0202684:	afdfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202688:	0000a697          	auipc	a3,0xa
ffffffffc020268c:	97868693          	addi	a3,a3,-1672 # ffffffffc020c000 <boot_page_table_sv39>
ffffffffc0202690:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202694:	c02007b7          	lui	a5,0xc0200
ffffffffc0202698:	5cf6ec63          	bltu	a3,a5,ffffffffc0202c70 <pmm_init+0x6f4>
ffffffffc020269c:	0009b783          	ld	a5,0(s3)
ffffffffc02026a0:	8e9d                	sub	a3,a3,a5
ffffffffc02026a2:	000b1797          	auipc	a5,0xb1
ffffffffc02026a6:	12d7bf23          	sd	a3,318(a5) # ffffffffc02b37e0 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026aa:	100027f3          	csrr	a5,sstatus
ffffffffc02026ae:	8b89                	andi	a5,a5,2
ffffffffc02026b0:	48079263          	bnez	a5,ffffffffc0202b34 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026b4:	000bb783          	ld	a5,0(s7)
ffffffffc02026b8:	779c                	ld	a5,40(a5)
ffffffffc02026ba:	9782                	jalr	a5
ffffffffc02026bc:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02026be:	6098                	ld	a4,0(s1)
ffffffffc02026c0:	c80007b7          	lui	a5,0xc8000
ffffffffc02026c4:	83b1                	srli	a5,a5,0xc
ffffffffc02026c6:	5ee7e163          	bltu	a5,a4,ffffffffc0202ca8 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026ca:	00093503          	ld	a0,0(s2)
ffffffffc02026ce:	5a050d63          	beqz	a0,ffffffffc0202c88 <pmm_init+0x70c>
ffffffffc02026d2:	03451793          	slli	a5,a0,0x34
ffffffffc02026d6:	5a079963          	bnez	a5,ffffffffc0202c88 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026da:	4601                	li	a2,0
ffffffffc02026dc:	4581                	li	a1,0
ffffffffc02026de:	8e1ff0ef          	jal	ra,ffffffffc0201fbe <get_page>
ffffffffc02026e2:	62051563          	bnez	a0,ffffffffc0202d0c <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026e6:	4505                	li	a0,1
ffffffffc02026e8:	df8ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02026ec:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026ee:	00093503          	ld	a0,0(s2)
ffffffffc02026f2:	4681                	li	a3,0
ffffffffc02026f4:	4601                	li	a2,0
ffffffffc02026f6:	85d2                	mv	a1,s4
ffffffffc02026f8:	d8fff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02026fc:	5e051863          	bnez	a0,ffffffffc0202cec <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202700:	00093503          	ld	a0,0(s2)
ffffffffc0202704:	4601                	li	a2,0
ffffffffc0202706:	4581                	li	a1,0
ffffffffc0202708:	ee4ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020270c:	5c050063          	beqz	a0,ffffffffc0202ccc <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202710:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202712:	0017f713          	andi	a4,a5,1
ffffffffc0202716:	5a070963          	beqz	a4,ffffffffc0202cc8 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020271a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020271c:	078a                	slli	a5,a5,0x2
ffffffffc020271e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202720:	52e7fa63          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202724:	000b3683          	ld	a3,0(s6)
ffffffffc0202728:	fff80637          	lui	a2,0xfff80
ffffffffc020272c:	97b2                	add	a5,a5,a2
ffffffffc020272e:	079a                	slli	a5,a5,0x6
ffffffffc0202730:	97b6                	add	a5,a5,a3
ffffffffc0202732:	10fa16e3          	bne	s4,a5,ffffffffc020303e <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0202736:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc020273a:	4785                	li	a5,1
ffffffffc020273c:	12f69de3          	bne	a3,a5,ffffffffc0203076 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202740:	00093503          	ld	a0,0(s2)
ffffffffc0202744:	77fd                	lui	a5,0xfffff
ffffffffc0202746:	6114                	ld	a3,0(a0)
ffffffffc0202748:	068a                	slli	a3,a3,0x2
ffffffffc020274a:	8efd                	and	a3,a3,a5
ffffffffc020274c:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202750:	10e677e3          	bgeu	a2,a4,ffffffffc020305e <pmm_init+0xae2>
ffffffffc0202754:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202758:	96e2                	add	a3,a3,s8
ffffffffc020275a:	0006ba83          	ld	s5,0(a3)
ffffffffc020275e:	0a8a                	slli	s5,s5,0x2
ffffffffc0202760:	00fafab3          	and	s5,s5,a5
ffffffffc0202764:	00cad793          	srli	a5,s5,0xc
ffffffffc0202768:	62e7f263          	bgeu	a5,a4,ffffffffc0202d8c <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020276c:	4601                	li	a2,0
ffffffffc020276e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202770:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202772:	e7aff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202776:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202778:	5f551a63          	bne	a0,s5,ffffffffc0202d6c <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc020277c:	4505                	li	a0,1
ffffffffc020277e:	d62ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0202782:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202784:	00093503          	ld	a0,0(s2)
ffffffffc0202788:	46d1                	li	a3,20
ffffffffc020278a:	6605                	lui	a2,0x1
ffffffffc020278c:	85d6                	mv	a1,s5
ffffffffc020278e:	cf9ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc0202792:	58051d63          	bnez	a0,ffffffffc0202d2c <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202796:	00093503          	ld	a0,0(s2)
ffffffffc020279a:	4601                	li	a2,0
ffffffffc020279c:	6585                	lui	a1,0x1
ffffffffc020279e:	e4eff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02027a2:	0e050ae3          	beqz	a0,ffffffffc0203096 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc02027a6:	611c                	ld	a5,0(a0)
ffffffffc02027a8:	0107f713          	andi	a4,a5,16
ffffffffc02027ac:	6e070d63          	beqz	a4,ffffffffc0202ea6 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02027b0:	8b91                	andi	a5,a5,4
ffffffffc02027b2:	6a078a63          	beqz	a5,ffffffffc0202e66 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027b6:	00093503          	ld	a0,0(s2)
ffffffffc02027ba:	611c                	ld	a5,0(a0)
ffffffffc02027bc:	8bc1                	andi	a5,a5,16
ffffffffc02027be:	68078463          	beqz	a5,ffffffffc0202e46 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02027c2:	000aa703          	lw	a4,0(s5)
ffffffffc02027c6:	4785                	li	a5,1
ffffffffc02027c8:	58f71263          	bne	a4,a5,ffffffffc0202d4c <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027cc:	4681                	li	a3,0
ffffffffc02027ce:	6605                	lui	a2,0x1
ffffffffc02027d0:	85d2                	mv	a1,s4
ffffffffc02027d2:	cb5ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02027d6:	62051863          	bnez	a0,ffffffffc0202e06 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02027da:	000a2703          	lw	a4,0(s4)
ffffffffc02027de:	4789                	li	a5,2
ffffffffc02027e0:	60f71363          	bne	a4,a5,ffffffffc0202de6 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02027e4:	000aa783          	lw	a5,0(s5)
ffffffffc02027e8:	5c079f63          	bnez	a5,ffffffffc0202dc6 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027ec:	00093503          	ld	a0,0(s2)
ffffffffc02027f0:	4601                	li	a2,0
ffffffffc02027f2:	6585                	lui	a1,0x1
ffffffffc02027f4:	df8ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02027f8:	5a050763          	beqz	a0,ffffffffc0202da6 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027fc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027fe:	00177793          	andi	a5,a4,1
ffffffffc0202802:	4c078363          	beqz	a5,ffffffffc0202cc8 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202806:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202808:	00271793          	slli	a5,a4,0x2
ffffffffc020280c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020280e:	44d7f363          	bgeu	a5,a3,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202812:	000b3683          	ld	a3,0(s6)
ffffffffc0202816:	fff80637          	lui	a2,0xfff80
ffffffffc020281a:	97b2                	add	a5,a5,a2
ffffffffc020281c:	079a                	slli	a5,a5,0x6
ffffffffc020281e:	97b6                	add	a5,a5,a3
ffffffffc0202820:	6efa1363          	bne	s4,a5,ffffffffc0202f06 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202824:	8b41                	andi	a4,a4,16
ffffffffc0202826:	6c071063          	bnez	a4,ffffffffc0202ee6 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020282a:	00093503          	ld	a0,0(s2)
ffffffffc020282e:	4581                	li	a1,0
ffffffffc0202830:	bbbff0ef          	jal	ra,ffffffffc02023ea <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202834:	000a2703          	lw	a4,0(s4)
ffffffffc0202838:	4785                	li	a5,1
ffffffffc020283a:	68f71663          	bne	a4,a5,ffffffffc0202ec6 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc020283e:	000aa783          	lw	a5,0(s5)
ffffffffc0202842:	74079e63          	bnez	a5,ffffffffc0202f9e <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202846:	00093503          	ld	a0,0(s2)
ffffffffc020284a:	6585                	lui	a1,0x1
ffffffffc020284c:	b9fff0ef          	jal	ra,ffffffffc02023ea <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202850:	000a2783          	lw	a5,0(s4)
ffffffffc0202854:	72079563          	bnez	a5,ffffffffc0202f7e <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202858:	000aa783          	lw	a5,0(s5)
ffffffffc020285c:	70079163          	bnez	a5,ffffffffc0202f5e <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202860:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202864:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202866:	000a3683          	ld	a3,0(s4)
ffffffffc020286a:	068a                	slli	a3,a3,0x2
ffffffffc020286c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020286e:	3ee6f363          	bgeu	a3,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202872:	fff807b7          	lui	a5,0xfff80
ffffffffc0202876:	000b3503          	ld	a0,0(s6)
ffffffffc020287a:	96be                	add	a3,a3,a5
ffffffffc020287c:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020287e:	00d507b3          	add	a5,a0,a3
ffffffffc0202882:	4390                	lw	a2,0(a5)
ffffffffc0202884:	4785                	li	a5,1
ffffffffc0202886:	6af61c63          	bne	a2,a5,ffffffffc0202f3e <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020288a:	8699                	srai	a3,a3,0x6
ffffffffc020288c:	000805b7          	lui	a1,0x80
ffffffffc0202890:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202892:	00c69613          	slli	a2,a3,0xc
ffffffffc0202896:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202898:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020289a:	68e67663          	bgeu	a2,a4,ffffffffc0202f26 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020289e:	0009b603          	ld	a2,0(s3)
ffffffffc02028a2:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02028a4:	629c                	ld	a5,0(a3)
ffffffffc02028a6:	078a                	slli	a5,a5,0x2
ffffffffc02028a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028aa:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ae:	8f8d                	sub	a5,a5,a1
ffffffffc02028b0:	079a                	slli	a5,a5,0x6
ffffffffc02028b2:	953e                	add	a0,a0,a5
ffffffffc02028b4:	100027f3          	csrr	a5,sstatus
ffffffffc02028b8:	8b89                	andi	a5,a5,2
ffffffffc02028ba:	2c079763          	bnez	a5,ffffffffc0202b88 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02028be:	000bb783          	ld	a5,0(s7)
ffffffffc02028c2:	4585                	li	a1,1
ffffffffc02028c4:	739c                	ld	a5,32(a5)
ffffffffc02028c6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028c8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028cc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028ce:	078a                	slli	a5,a5,0x2
ffffffffc02028d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028d2:	38e7f163          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028d6:	000b3503          	ld	a0,0(s6)
ffffffffc02028da:	fff80737          	lui	a4,0xfff80
ffffffffc02028de:	97ba                	add	a5,a5,a4
ffffffffc02028e0:	079a                	slli	a5,a5,0x6
ffffffffc02028e2:	953e                	add	a0,a0,a5
ffffffffc02028e4:	100027f3          	csrr	a5,sstatus
ffffffffc02028e8:	8b89                	andi	a5,a5,2
ffffffffc02028ea:	28079363          	bnez	a5,ffffffffc0202b70 <pmm_init+0x5f4>
ffffffffc02028ee:	000bb783          	ld	a5,0(s7)
ffffffffc02028f2:	4585                	li	a1,1
ffffffffc02028f4:	739c                	ld	a5,32(a5)
ffffffffc02028f6:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028f8:	00093783          	ld	a5,0(s2)
ffffffffc02028fc:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccc7a4>
  asm volatile("sfence.vma");
ffffffffc0202900:	12000073          	sfence.vma
ffffffffc0202904:	100027f3          	csrr	a5,sstatus
ffffffffc0202908:	8b89                	andi	a5,a5,2
ffffffffc020290a:	24079963          	bnez	a5,ffffffffc0202b5c <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc020290e:	000bb783          	ld	a5,0(s7)
ffffffffc0202912:	779c                	ld	a5,40(a5)
ffffffffc0202914:	9782                	jalr	a5
ffffffffc0202916:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202918:	71441363          	bne	s0,s4,ffffffffc020301e <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020291c:	00005517          	auipc	a0,0x5
ffffffffc0202920:	15c50513          	addi	a0,a0,348 # ffffffffc0207a78 <default_pmm_manager+0x500>
ffffffffc0202924:	85dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202928:	100027f3          	csrr	a5,sstatus
ffffffffc020292c:	8b89                	andi	a5,a5,2
ffffffffc020292e:	20079d63          	bnez	a5,ffffffffc0202b48 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202932:	000bb783          	ld	a5,0(s7)
ffffffffc0202936:	779c                	ld	a5,40(a5)
ffffffffc0202938:	9782                	jalr	a5
ffffffffc020293a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020293c:	6098                	ld	a4,0(s1)
ffffffffc020293e:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202942:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202944:	00c71793          	slli	a5,a4,0xc
ffffffffc0202948:	6a05                	lui	s4,0x1
ffffffffc020294a:	02f47c63          	bgeu	s0,a5,ffffffffc0202982 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020294e:	00c45793          	srli	a5,s0,0xc
ffffffffc0202952:	00093503          	ld	a0,0(s2)
ffffffffc0202956:	2ee7f263          	bgeu	a5,a4,ffffffffc0202c3a <pmm_init+0x6be>
ffffffffc020295a:	0009b583          	ld	a1,0(s3)
ffffffffc020295e:	4601                	li	a2,0
ffffffffc0202960:	95a2                	add	a1,a1,s0
ffffffffc0202962:	c8aff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0202966:	2a050a63          	beqz	a0,ffffffffc0202c1a <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020296a:	611c                	ld	a5,0(a0)
ffffffffc020296c:	078a                	slli	a5,a5,0x2
ffffffffc020296e:	0157f7b3          	and	a5,a5,s5
ffffffffc0202972:	28879463          	bne	a5,s0,ffffffffc0202bfa <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202976:	6098                	ld	a4,0(s1)
ffffffffc0202978:	9452                	add	s0,s0,s4
ffffffffc020297a:	00c71793          	slli	a5,a4,0xc
ffffffffc020297e:	fcf468e3          	bltu	s0,a5,ffffffffc020294e <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202982:	00093783          	ld	a5,0(s2)
ffffffffc0202986:	639c                	ld	a5,0(a5)
ffffffffc0202988:	66079b63          	bnez	a5,ffffffffc0202ffe <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc020298c:	4505                	li	a0,1
ffffffffc020298e:	b52ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0202992:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	4699                	li	a3,6
ffffffffc020299a:	10000613          	li	a2,256
ffffffffc020299e:	85d6                	mv	a1,s5
ffffffffc02029a0:	ae7ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02029a4:	62051d63          	bnez	a0,ffffffffc0202fde <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc02029a8:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4b7a4>
ffffffffc02029ac:	4785                	li	a5,1
ffffffffc02029ae:	60f71863          	bne	a4,a5,ffffffffc0202fbe <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02029b2:	00093503          	ld	a0,0(s2)
ffffffffc02029b6:	6405                	lui	s0,0x1
ffffffffc02029b8:	4699                	li	a3,6
ffffffffc02029ba:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc02029be:	85d6                	mv	a1,s5
ffffffffc02029c0:	ac7ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02029c4:	46051163          	bnez	a0,ffffffffc0202e26 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02029c8:	000aa703          	lw	a4,0(s5)
ffffffffc02029cc:	4789                	li	a5,2
ffffffffc02029ce:	72f71463          	bne	a4,a5,ffffffffc02030f6 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029d2:	00005597          	auipc	a1,0x5
ffffffffc02029d6:	1de58593          	addi	a1,a1,478 # ffffffffc0207bb0 <default_pmm_manager+0x638>
ffffffffc02029da:	10000513          	li	a0,256
ffffffffc02029de:	5d5030ef          	jal	ra,ffffffffc02067b2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029e2:	10040593          	addi	a1,s0,256
ffffffffc02029e6:	10000513          	li	a0,256
ffffffffc02029ea:	5db030ef          	jal	ra,ffffffffc02067c4 <strcmp>
ffffffffc02029ee:	6e051463          	bnez	a0,ffffffffc02030d6 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02029f2:	000b3683          	ld	a3,0(s6)
ffffffffc02029f6:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02029fa:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02029fc:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a00:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a02:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a04:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a06:	8031                	srli	s0,s0,0xc
ffffffffc0202a08:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a0c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a0e:	50f77c63          	bgeu	a4,a5,ffffffffc0202f26 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a12:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a16:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a1a:	96be                	add	a3,a3,a5
ffffffffc0202a1c:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a20:	55d030ef          	jal	ra,ffffffffc020677c <strlen>
ffffffffc0202a24:	68051963          	bnez	a0,ffffffffc02030b6 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a28:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a2c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a2e:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0202a32:	068a                	slli	a3,a3,0x2
ffffffffc0202a34:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a36:	20f6ff63          	bgeu	a3,a5,ffffffffc0202c54 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202a3a:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a3c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a3e:	4ef47463          	bgeu	s0,a5,ffffffffc0202f26 <pmm_init+0x9aa>
ffffffffc0202a42:	0009b403          	ld	s0,0(s3)
ffffffffc0202a46:	9436                	add	s0,s0,a3
ffffffffc0202a48:	100027f3          	csrr	a5,sstatus
ffffffffc0202a4c:	8b89                	andi	a5,a5,2
ffffffffc0202a4e:	18079b63          	bnez	a5,ffffffffc0202be4 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202a52:	000bb783          	ld	a5,0(s7)
ffffffffc0202a56:	4585                	li	a1,1
ffffffffc0202a58:	8556                	mv	a0,s5
ffffffffc0202a5a:	739c                	ld	a5,32(a5)
ffffffffc0202a5c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a5e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a60:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a62:	078a                	slli	a5,a5,0x2
ffffffffc0202a64:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a66:	1ee7f763          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a6a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a6e:	fff80737          	lui	a4,0xfff80
ffffffffc0202a72:	97ba                	add	a5,a5,a4
ffffffffc0202a74:	079a                	slli	a5,a5,0x6
ffffffffc0202a76:	953e                	add	a0,a0,a5
ffffffffc0202a78:	100027f3          	csrr	a5,sstatus
ffffffffc0202a7c:	8b89                	andi	a5,a5,2
ffffffffc0202a7e:	14079763          	bnez	a5,ffffffffc0202bcc <pmm_init+0x650>
ffffffffc0202a82:	000bb783          	ld	a5,0(s7)
ffffffffc0202a86:	4585                	li	a1,1
ffffffffc0202a88:	739c                	ld	a5,32(a5)
ffffffffc0202a8a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a8c:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a90:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a92:	078a                	slli	a5,a5,0x2
ffffffffc0202a94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a96:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a9a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a9e:	fff80737          	lui	a4,0xfff80
ffffffffc0202aa2:	97ba                	add	a5,a5,a4
ffffffffc0202aa4:	079a                	slli	a5,a5,0x6
ffffffffc0202aa6:	953e                	add	a0,a0,a5
ffffffffc0202aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aac:	8b89                	andi	a5,a5,2
ffffffffc0202aae:	10079363          	bnez	a5,ffffffffc0202bb4 <pmm_init+0x638>
ffffffffc0202ab2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ab6:	4585                	li	a1,1
ffffffffc0202ab8:	739c                	ld	a5,32(a5)
ffffffffc0202aba:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202abc:	00093783          	ld	a5,0(s2)
ffffffffc0202ac0:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202ac4:	12000073          	sfence.vma
ffffffffc0202ac8:	100027f3          	csrr	a5,sstatus
ffffffffc0202acc:	8b89                	andi	a5,a5,2
ffffffffc0202ace:	0c079963          	bnez	a5,ffffffffc0202ba0 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ad2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ad6:	779c                	ld	a5,40(a5)
ffffffffc0202ad8:	9782                	jalr	a5
ffffffffc0202ada:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202adc:	3a8c1563          	bne	s8,s0,ffffffffc0202e86 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ae0:	00005517          	auipc	a0,0x5
ffffffffc0202ae4:	14850513          	addi	a0,a0,328 # ffffffffc0207c28 <default_pmm_manager+0x6b0>
ffffffffc0202ae8:	e98fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202aec:	6446                	ld	s0,80(sp)
ffffffffc0202aee:	60e6                	ld	ra,88(sp)
ffffffffc0202af0:	64a6                	ld	s1,72(sp)
ffffffffc0202af2:	6906                	ld	s2,64(sp)
ffffffffc0202af4:	79e2                	ld	s3,56(sp)
ffffffffc0202af6:	7a42                	ld	s4,48(sp)
ffffffffc0202af8:	7aa2                	ld	s5,40(sp)
ffffffffc0202afa:	7b02                	ld	s6,32(sp)
ffffffffc0202afc:	6be2                	ld	s7,24(sp)
ffffffffc0202afe:	6c42                	ld	s8,16(sp)
ffffffffc0202b00:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202b02:	fddfe06f          	j	ffffffffc0201ade <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202b06:	6785                	lui	a5,0x1
ffffffffc0202b08:	17fd                	addi	a5,a5,-1
ffffffffc0202b0a:	96be                	add	a3,a3,a5
ffffffffc0202b0c:	77fd                	lui	a5,0xfffff
ffffffffc0202b0e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202b10:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202b14:	14c6f063          	bgeu	a3,a2,ffffffffc0202c54 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202b18:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202b1c:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202b1e:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202b22:	6a10                	ld	a2,16(a2)
ffffffffc0202b24:	069a                	slli	a3,a3,0x6
ffffffffc0202b26:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202b2a:	9536                	add	a0,a0,a3
ffffffffc0202b2c:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b2e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b32:	b63d                	j	ffffffffc0202660 <pmm_init+0xe4>
        intr_disable();
ffffffffc0202b34:	b13fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b38:	000bb783          	ld	a5,0(s7)
ffffffffc0202b3c:	779c                	ld	a5,40(a5)
ffffffffc0202b3e:	9782                	jalr	a5
ffffffffc0202b40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b42:	afffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b46:	bea5                	j	ffffffffc02026be <pmm_init+0x142>
        intr_disable();
ffffffffc0202b48:	afffd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b4c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b50:	779c                	ld	a5,40(a5)
ffffffffc0202b52:	9782                	jalr	a5
ffffffffc0202b54:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b56:	aebfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b5a:	b3cd                	j	ffffffffc020293c <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b5c:	aebfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b60:	000bb783          	ld	a5,0(s7)
ffffffffc0202b64:	779c                	ld	a5,40(a5)
ffffffffc0202b66:	9782                	jalr	a5
ffffffffc0202b68:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b6a:	ad7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b6e:	b36d                	j	ffffffffc0202918 <pmm_init+0x39c>
ffffffffc0202b70:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b72:	ad5fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b76:	000bb783          	ld	a5,0(s7)
ffffffffc0202b7a:	6522                	ld	a0,8(sp)
ffffffffc0202b7c:	4585                	li	a1,1
ffffffffc0202b7e:	739c                	ld	a5,32(a5)
ffffffffc0202b80:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b82:	abffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b86:	bb8d                	j	ffffffffc02028f8 <pmm_init+0x37c>
ffffffffc0202b88:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b8a:	abdfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b8e:	000bb783          	ld	a5,0(s7)
ffffffffc0202b92:	6522                	ld	a0,8(sp)
ffffffffc0202b94:	4585                	li	a1,1
ffffffffc0202b96:	739c                	ld	a5,32(a5)
ffffffffc0202b98:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b9a:	aa7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b9e:	b32d                	j	ffffffffc02028c8 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202ba0:	aa7fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ba4:	000bb783          	ld	a5,0(s7)
ffffffffc0202ba8:	779c                	ld	a5,40(a5)
ffffffffc0202baa:	9782                	jalr	a5
ffffffffc0202bac:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bae:	a93fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bb2:	b72d                	j	ffffffffc0202adc <pmm_init+0x560>
ffffffffc0202bb4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bb6:	a91fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202bba:	000bb783          	ld	a5,0(s7)
ffffffffc0202bbe:	6522                	ld	a0,8(sp)
ffffffffc0202bc0:	4585                	li	a1,1
ffffffffc0202bc2:	739c                	ld	a5,32(a5)
ffffffffc0202bc4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bc6:	a7bfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bca:	bdcd                	j	ffffffffc0202abc <pmm_init+0x540>
ffffffffc0202bcc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bce:	a79fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202bd2:	000bb783          	ld	a5,0(s7)
ffffffffc0202bd6:	6522                	ld	a0,8(sp)
ffffffffc0202bd8:	4585                	li	a1,1
ffffffffc0202bda:	739c                	ld	a5,32(a5)
ffffffffc0202bdc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bde:	a63fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202be2:	b56d                	j	ffffffffc0202a8c <pmm_init+0x510>
        intr_disable();
ffffffffc0202be4:	a63fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202be8:	000bb783          	ld	a5,0(s7)
ffffffffc0202bec:	4585                	li	a1,1
ffffffffc0202bee:	8556                	mv	a0,s5
ffffffffc0202bf0:	739c                	ld	a5,32(a5)
ffffffffc0202bf2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bf4:	a4dfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bf8:	b59d                	j	ffffffffc0202a5e <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bfa:	00005697          	auipc	a3,0x5
ffffffffc0202bfe:	ede68693          	addi	a3,a3,-290 # ffffffffc0207ad8 <default_pmm_manager+0x560>
ffffffffc0202c02:	00004617          	auipc	a2,0x4
ffffffffc0202c06:	2de60613          	addi	a2,a2,734 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202c0a:	23c00593          	li	a1,572
ffffffffc0202c0e:	00005517          	auipc	a0,0x5
ffffffffc0202c12:	aba50513          	addi	a0,a0,-1350 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202c16:	865fd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c1a:	00005697          	auipc	a3,0x5
ffffffffc0202c1e:	e7e68693          	addi	a3,a3,-386 # ffffffffc0207a98 <default_pmm_manager+0x520>
ffffffffc0202c22:	00004617          	auipc	a2,0x4
ffffffffc0202c26:	2be60613          	addi	a2,a2,702 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202c2a:	23b00593          	li	a1,571
ffffffffc0202c2e:	00005517          	auipc	a0,0x5
ffffffffc0202c32:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202c36:	845fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c3a:	86a2                	mv	a3,s0
ffffffffc0202c3c:	00005617          	auipc	a2,0x5
ffffffffc0202c40:	97460613          	addi	a2,a2,-1676 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0202c44:	23b00593          	li	a1,571
ffffffffc0202c48:	00005517          	auipc	a0,0x5
ffffffffc0202c4c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202c50:	82bfd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c54:	854ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c58:	00005617          	auipc	a2,0x5
ffffffffc0202c5c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc0202c60:	07f00593          	li	a1,127
ffffffffc0202c64:	00005517          	auipc	a0,0x5
ffffffffc0202c68:	a6450513          	addi	a0,a0,-1436 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202c6c:	80ffd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c70:	00005617          	auipc	a2,0x5
ffffffffc0202c74:	9e860613          	addi	a2,a2,-1560 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc0202c78:	0c100593          	li	a1,193
ffffffffc0202c7c:	00005517          	auipc	a0,0x5
ffffffffc0202c80:	a4c50513          	addi	a0,a0,-1460 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202c84:	ff6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c88:	00005697          	auipc	a3,0x5
ffffffffc0202c8c:	b4868693          	addi	a3,a3,-1208 # ffffffffc02077d0 <default_pmm_manager+0x258>
ffffffffc0202c90:	00004617          	auipc	a2,0x4
ffffffffc0202c94:	25060613          	addi	a2,a2,592 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202c98:	1ff00593          	li	a1,511
ffffffffc0202c9c:	00005517          	auipc	a0,0x5
ffffffffc0202ca0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202ca4:	fd6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202ca8:	00005697          	auipc	a3,0x5
ffffffffc0202cac:	b0868693          	addi	a3,a3,-1272 # ffffffffc02077b0 <default_pmm_manager+0x238>
ffffffffc0202cb0:	00004617          	auipc	a2,0x4
ffffffffc0202cb4:	23060613          	addi	a2,a2,560 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202cb8:	1fe00593          	li	a1,510
ffffffffc0202cbc:	00005517          	auipc	a0,0x5
ffffffffc0202cc0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202cc4:	fb6fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202cc8:	ffdfe0ef          	jal	ra,ffffffffc0201cc4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ccc:	00005697          	auipc	a3,0x5
ffffffffc0202cd0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0207860 <default_pmm_manager+0x2e8>
ffffffffc0202cd4:	00004617          	auipc	a2,0x4
ffffffffc0202cd8:	20c60613          	addi	a2,a2,524 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202cdc:	20700593          	li	a1,519
ffffffffc0202ce0:	00005517          	auipc	a0,0x5
ffffffffc0202ce4:	9e850513          	addi	a0,a0,-1560 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202ce8:	f92fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202cec:	00005697          	auipc	a3,0x5
ffffffffc0202cf0:	b4468693          	addi	a3,a3,-1212 # ffffffffc0207830 <default_pmm_manager+0x2b8>
ffffffffc0202cf4:	00004617          	auipc	a2,0x4
ffffffffc0202cf8:	1ec60613          	addi	a2,a2,492 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202cfc:	20400593          	li	a1,516
ffffffffc0202d00:	00005517          	auipc	a0,0x5
ffffffffc0202d04:	9c850513          	addi	a0,a0,-1592 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202d08:	f72fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202d0c:	00005697          	auipc	a3,0x5
ffffffffc0202d10:	afc68693          	addi	a3,a3,-1284 # ffffffffc0207808 <default_pmm_manager+0x290>
ffffffffc0202d14:	00004617          	auipc	a2,0x4
ffffffffc0202d18:	1cc60613          	addi	a2,a2,460 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202d1c:	20000593          	li	a1,512
ffffffffc0202d20:	00005517          	auipc	a0,0x5
ffffffffc0202d24:	9a850513          	addi	a0,a0,-1624 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202d28:	f52fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d2c:	00005697          	auipc	a3,0x5
ffffffffc0202d30:	bbc68693          	addi	a3,a3,-1092 # ffffffffc02078e8 <default_pmm_manager+0x370>
ffffffffc0202d34:	00004617          	auipc	a2,0x4
ffffffffc0202d38:	1ac60613          	addi	a2,a2,428 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202d3c:	21000593          	li	a1,528
ffffffffc0202d40:	00005517          	auipc	a0,0x5
ffffffffc0202d44:	98850513          	addi	a0,a0,-1656 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202d48:	f32fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d4c:	00005697          	auipc	a3,0x5
ffffffffc0202d50:	c3c68693          	addi	a3,a3,-964 # ffffffffc0207988 <default_pmm_manager+0x410>
ffffffffc0202d54:	00004617          	auipc	a2,0x4
ffffffffc0202d58:	18c60613          	addi	a2,a2,396 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202d5c:	21500593          	li	a1,533
ffffffffc0202d60:	00005517          	auipc	a0,0x5
ffffffffc0202d64:	96850513          	addi	a0,a0,-1688 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202d68:	f12fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d6c:	00005697          	auipc	a3,0x5
ffffffffc0202d70:	b5468693          	addi	a3,a3,-1196 # ffffffffc02078c0 <default_pmm_manager+0x348>
ffffffffc0202d74:	00004617          	auipc	a2,0x4
ffffffffc0202d78:	16c60613          	addi	a2,a2,364 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202d7c:	20d00593          	li	a1,525
ffffffffc0202d80:	00005517          	auipc	a0,0x5
ffffffffc0202d84:	94850513          	addi	a0,a0,-1720 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202d88:	ef2fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d8c:	86d6                	mv	a3,s5
ffffffffc0202d8e:	00005617          	auipc	a2,0x5
ffffffffc0202d92:	82260613          	addi	a2,a2,-2014 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0202d96:	20c00593          	li	a1,524
ffffffffc0202d9a:	00005517          	auipc	a0,0x5
ffffffffc0202d9e:	92e50513          	addi	a0,a0,-1746 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202da2:	ed8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202da6:	00005697          	auipc	a3,0x5
ffffffffc0202daa:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0207920 <default_pmm_manager+0x3a8>
ffffffffc0202dae:	00004617          	auipc	a2,0x4
ffffffffc0202db2:	13260613          	addi	a2,a2,306 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202db6:	21a00593          	li	a1,538
ffffffffc0202dba:	00005517          	auipc	a0,0x5
ffffffffc0202dbe:	90e50513          	addi	a0,a0,-1778 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202dc2:	eb8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dc6:	00005697          	auipc	a3,0x5
ffffffffc0202dca:	c2268693          	addi	a3,a3,-990 # ffffffffc02079e8 <default_pmm_manager+0x470>
ffffffffc0202dce:	00004617          	auipc	a2,0x4
ffffffffc0202dd2:	11260613          	addi	a2,a2,274 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202dd6:	21900593          	li	a1,537
ffffffffc0202dda:	00005517          	auipc	a0,0x5
ffffffffc0202dde:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202de2:	e98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202de6:	00005697          	auipc	a3,0x5
ffffffffc0202dea:	bea68693          	addi	a3,a3,-1046 # ffffffffc02079d0 <default_pmm_manager+0x458>
ffffffffc0202dee:	00004617          	auipc	a2,0x4
ffffffffc0202df2:	0f260613          	addi	a2,a2,242 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202df6:	21800593          	li	a1,536
ffffffffc0202dfa:	00005517          	auipc	a0,0x5
ffffffffc0202dfe:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202e02:	e78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202e06:	00005697          	auipc	a3,0x5
ffffffffc0202e0a:	b9a68693          	addi	a3,a3,-1126 # ffffffffc02079a0 <default_pmm_manager+0x428>
ffffffffc0202e0e:	00004617          	auipc	a2,0x4
ffffffffc0202e12:	0d260613          	addi	a2,a2,210 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202e16:	21700593          	li	a1,535
ffffffffc0202e1a:	00005517          	auipc	a0,0x5
ffffffffc0202e1e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202e22:	e58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e26:	00005697          	auipc	a3,0x5
ffffffffc0202e2a:	d3268693          	addi	a3,a3,-718 # ffffffffc0207b58 <default_pmm_manager+0x5e0>
ffffffffc0202e2e:	00004617          	auipc	a2,0x4
ffffffffc0202e32:	0b260613          	addi	a2,a2,178 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202e36:	24600593          	li	a1,582
ffffffffc0202e3a:	00005517          	auipc	a0,0x5
ffffffffc0202e3e:	88e50513          	addi	a0,a0,-1906 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202e42:	e38fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e46:	00005697          	auipc	a3,0x5
ffffffffc0202e4a:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0207970 <default_pmm_manager+0x3f8>
ffffffffc0202e4e:	00004617          	auipc	a2,0x4
ffffffffc0202e52:	09260613          	addi	a2,a2,146 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202e56:	21400593          	li	a1,532
ffffffffc0202e5a:	00005517          	auipc	a0,0x5
ffffffffc0202e5e:	86e50513          	addi	a0,a0,-1938 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202e62:	e18fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e66:	00005697          	auipc	a3,0x5
ffffffffc0202e6a:	afa68693          	addi	a3,a3,-1286 # ffffffffc0207960 <default_pmm_manager+0x3e8>
ffffffffc0202e6e:	00004617          	auipc	a2,0x4
ffffffffc0202e72:	07260613          	addi	a2,a2,114 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202e76:	21300593          	li	a1,531
ffffffffc0202e7a:	00005517          	auipc	a0,0x5
ffffffffc0202e7e:	84e50513          	addi	a0,a0,-1970 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202e82:	df8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e86:	00005697          	auipc	a3,0x5
ffffffffc0202e8a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0207a58 <default_pmm_manager+0x4e0>
ffffffffc0202e8e:	00004617          	auipc	a2,0x4
ffffffffc0202e92:	05260613          	addi	a2,a2,82 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202e96:	25700593          	li	a1,599
ffffffffc0202e9a:	00005517          	auipc	a0,0x5
ffffffffc0202e9e:	82e50513          	addi	a0,a0,-2002 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202ea2:	dd8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ea6:	00005697          	auipc	a3,0x5
ffffffffc0202eaa:	aaa68693          	addi	a3,a3,-1366 # ffffffffc0207950 <default_pmm_manager+0x3d8>
ffffffffc0202eae:	00004617          	auipc	a2,0x4
ffffffffc0202eb2:	03260613          	addi	a2,a2,50 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202eb6:	21200593          	li	a1,530
ffffffffc0202eba:	00005517          	auipc	a0,0x5
ffffffffc0202ebe:	80e50513          	addi	a0,a0,-2034 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202ec2:	db8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ec6:	00005697          	auipc	a3,0x5
ffffffffc0202eca:	9e268693          	addi	a3,a3,-1566 # ffffffffc02078a8 <default_pmm_manager+0x330>
ffffffffc0202ece:	00004617          	auipc	a2,0x4
ffffffffc0202ed2:	01260613          	addi	a2,a2,18 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202ed6:	21f00593          	li	a1,543
ffffffffc0202eda:	00004517          	auipc	a0,0x4
ffffffffc0202ede:	7ee50513          	addi	a0,a0,2030 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202ee2:	d98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ee6:	00005697          	auipc	a3,0x5
ffffffffc0202eea:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207a00 <default_pmm_manager+0x488>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	ff260613          	addi	a2,a2,-14 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202ef6:	21c00593          	li	a1,540
ffffffffc0202efa:	00004517          	auipc	a0,0x4
ffffffffc0202efe:	7ce50513          	addi	a0,a0,1998 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202f02:	d78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	98a68693          	addi	a3,a3,-1654 # ffffffffc0207890 <default_pmm_manager+0x318>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	fd260613          	addi	a2,a2,-46 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202f16:	21b00593          	li	a1,539
ffffffffc0202f1a:	00004517          	auipc	a0,0x4
ffffffffc0202f1e:	7ae50513          	addi	a0,a0,1966 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202f22:	d58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	68a60613          	addi	a2,a2,1674 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0202f2e:	06900593          	li	a1,105
ffffffffc0202f32:	00004517          	auipc	a0,0x4
ffffffffc0202f36:	6a650513          	addi	a0,a0,1702 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0202f3a:	d40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f3e:	00005697          	auipc	a3,0x5
ffffffffc0202f42:	af268693          	addi	a3,a3,-1294 # ffffffffc0207a30 <default_pmm_manager+0x4b8>
ffffffffc0202f46:	00004617          	auipc	a2,0x4
ffffffffc0202f4a:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202f4e:	22600593          	li	a1,550
ffffffffc0202f52:	00004517          	auipc	a0,0x4
ffffffffc0202f56:	77650513          	addi	a0,a0,1910 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202f5a:	d20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f5e:	00005697          	auipc	a3,0x5
ffffffffc0202f62:	a8a68693          	addi	a3,a3,-1398 # ffffffffc02079e8 <default_pmm_manager+0x470>
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	f7a60613          	addi	a2,a2,-134 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202f6e:	22400593          	li	a1,548
ffffffffc0202f72:	00004517          	auipc	a0,0x4
ffffffffc0202f76:	75650513          	addi	a0,a0,1878 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202f7a:	d00fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f7e:	00005697          	auipc	a3,0x5
ffffffffc0202f82:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0207a18 <default_pmm_manager+0x4a0>
ffffffffc0202f86:	00004617          	auipc	a2,0x4
ffffffffc0202f8a:	f5a60613          	addi	a2,a2,-166 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202f8e:	22300593          	li	a1,547
ffffffffc0202f92:	00004517          	auipc	a0,0x4
ffffffffc0202f96:	73650513          	addi	a0,a0,1846 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202f9a:	ce0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f9e:	00005697          	auipc	a3,0x5
ffffffffc0202fa2:	a4a68693          	addi	a3,a3,-1462 # ffffffffc02079e8 <default_pmm_manager+0x470>
ffffffffc0202fa6:	00004617          	auipc	a2,0x4
ffffffffc0202faa:	f3a60613          	addi	a2,a2,-198 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202fae:	22000593          	li	a1,544
ffffffffc0202fb2:	00004517          	auipc	a0,0x4
ffffffffc0202fb6:	71650513          	addi	a0,a0,1814 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202fba:	cc0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202fbe:	00005697          	auipc	a3,0x5
ffffffffc0202fc2:	b8268693          	addi	a3,a3,-1150 # ffffffffc0207b40 <default_pmm_manager+0x5c8>
ffffffffc0202fc6:	00004617          	auipc	a2,0x4
ffffffffc0202fca:	f1a60613          	addi	a2,a2,-230 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202fce:	24500593          	li	a1,581
ffffffffc0202fd2:	00004517          	auipc	a0,0x4
ffffffffc0202fd6:	6f650513          	addi	a0,a0,1782 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202fda:	ca0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202fde:	00005697          	auipc	a3,0x5
ffffffffc0202fe2:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0207b08 <default_pmm_manager+0x590>
ffffffffc0202fe6:	00004617          	auipc	a2,0x4
ffffffffc0202fea:	efa60613          	addi	a2,a2,-262 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0202fee:	24400593          	li	a1,580
ffffffffc0202ff2:	00004517          	auipc	a0,0x4
ffffffffc0202ff6:	6d650513          	addi	a0,a0,1750 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0202ffa:	c80fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202ffe:	00005697          	auipc	a3,0x5
ffffffffc0203002:	af268693          	addi	a3,a3,-1294 # ffffffffc0207af0 <default_pmm_manager+0x578>
ffffffffc0203006:	00004617          	auipc	a2,0x4
ffffffffc020300a:	eda60613          	addi	a2,a2,-294 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020300e:	24000593          	li	a1,576
ffffffffc0203012:	00004517          	auipc	a0,0x4
ffffffffc0203016:	6b650513          	addi	a0,a0,1718 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc020301a:	c60fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020301e:	00005697          	auipc	a3,0x5
ffffffffc0203022:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207a58 <default_pmm_manager+0x4e0>
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	eba60613          	addi	a2,a2,-326 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020302e:	22e00593          	li	a1,558
ffffffffc0203032:	00004517          	auipc	a0,0x4
ffffffffc0203036:	69650513          	addi	a0,a0,1686 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc020303a:	c40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020303e:	00005697          	auipc	a3,0x5
ffffffffc0203042:	85268693          	addi	a3,a3,-1966 # ffffffffc0207890 <default_pmm_manager+0x318>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	e9a60613          	addi	a2,a2,-358 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020304e:	20800593          	li	a1,520
ffffffffc0203052:	00004517          	auipc	a0,0x4
ffffffffc0203056:	67650513          	addi	a0,a0,1654 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc020305a:	c20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020305e:	00004617          	auipc	a2,0x4
ffffffffc0203062:	55260613          	addi	a2,a2,1362 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0203066:	20b00593          	li	a1,523
ffffffffc020306a:	00004517          	auipc	a0,0x4
ffffffffc020306e:	65e50513          	addi	a0,a0,1630 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0203072:	c08fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203076:	00005697          	auipc	a3,0x5
ffffffffc020307a:	83268693          	addi	a3,a3,-1998 # ffffffffc02078a8 <default_pmm_manager+0x330>
ffffffffc020307e:	00004617          	auipc	a2,0x4
ffffffffc0203082:	e6260613          	addi	a2,a2,-414 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203086:	20900593          	li	a1,521
ffffffffc020308a:	00004517          	auipc	a0,0x4
ffffffffc020308e:	63e50513          	addi	a0,a0,1598 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0203092:	be8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203096:	00005697          	auipc	a3,0x5
ffffffffc020309a:	88a68693          	addi	a3,a3,-1910 # ffffffffc0207920 <default_pmm_manager+0x3a8>
ffffffffc020309e:	00004617          	auipc	a2,0x4
ffffffffc02030a2:	e4260613          	addi	a2,a2,-446 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02030a6:	21100593          	li	a1,529
ffffffffc02030aa:	00004517          	auipc	a0,0x4
ffffffffc02030ae:	61e50513          	addi	a0,a0,1566 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02030b2:	bc8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02030b6:	00005697          	auipc	a3,0x5
ffffffffc02030ba:	b4a68693          	addi	a3,a3,-1206 # ffffffffc0207c00 <default_pmm_manager+0x688>
ffffffffc02030be:	00004617          	auipc	a2,0x4
ffffffffc02030c2:	e2260613          	addi	a2,a2,-478 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02030c6:	24e00593          	li	a1,590
ffffffffc02030ca:	00004517          	auipc	a0,0x4
ffffffffc02030ce:	5fe50513          	addi	a0,a0,1534 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02030d2:	ba8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030d6:	00005697          	auipc	a3,0x5
ffffffffc02030da:	af268693          	addi	a3,a3,-1294 # ffffffffc0207bc8 <default_pmm_manager+0x650>
ffffffffc02030de:	00004617          	auipc	a2,0x4
ffffffffc02030e2:	e0260613          	addi	a2,a2,-510 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02030e6:	24b00593          	li	a1,587
ffffffffc02030ea:	00004517          	auipc	a0,0x4
ffffffffc02030ee:	5de50513          	addi	a0,a0,1502 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02030f2:	b88fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030f6:	00005697          	auipc	a3,0x5
ffffffffc02030fa:	aa268693          	addi	a3,a3,-1374 # ffffffffc0207b98 <default_pmm_manager+0x620>
ffffffffc02030fe:	00004617          	auipc	a2,0x4
ffffffffc0203102:	de260613          	addi	a2,a2,-542 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203106:	24700593          	li	a1,583
ffffffffc020310a:	00004517          	auipc	a0,0x4
ffffffffc020310e:	5be50513          	addi	a0,a0,1470 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0203112:	b68fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203116 <copy_range>:
               bool share) {
ffffffffc0203116:	7119                	addi	sp,sp,-128
ffffffffc0203118:	f4a6                	sd	s1,104(sp)
ffffffffc020311a:	84b6                	mv	s1,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020311c:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc020311e:	fc86                	sd	ra,120(sp)
ffffffffc0203120:	f8a2                	sd	s0,112(sp)
ffffffffc0203122:	f0ca                	sd	s2,96(sp)
ffffffffc0203124:	ecce                	sd	s3,88(sp)
ffffffffc0203126:	e8d2                	sd	s4,80(sp)
ffffffffc0203128:	e4d6                	sd	s5,72(sp)
ffffffffc020312a:	e0da                	sd	s6,64(sp)
ffffffffc020312c:	fc5e                	sd	s7,56(sp)
ffffffffc020312e:	f862                	sd	s8,48(sp)
ffffffffc0203130:	f466                	sd	s9,40(sp)
ffffffffc0203132:	f06a                	sd	s10,32(sp)
ffffffffc0203134:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203136:	16d2                	slli	a3,a3,0x34
               bool share) {
ffffffffc0203138:	e43a                	sd	a4,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020313a:	26069b63          	bnez	a3,ffffffffc02033b0 <copy_range+0x29a>
    assert(USER_ACCESS(start, end));
ffffffffc020313e:	00200737          	lui	a4,0x200
ffffffffc0203142:	8d32                	mv	s10,a2
ffffffffc0203144:	1ce66e63          	bltu	a2,a4,ffffffffc0203320 <copy_range+0x20a>
ffffffffc0203148:	1c967c63          	bgeu	a2,s1,ffffffffc0203320 <copy_range+0x20a>
ffffffffc020314c:	4705                	li	a4,1
ffffffffc020314e:	077e                	slli	a4,a4,0x1f
ffffffffc0203150:	1c976863          	bltu	a4,s1,ffffffffc0203320 <copy_range+0x20a>
ffffffffc0203154:	5afd                	li	s5,-1
ffffffffc0203156:	8a2a                	mv	s4,a0
ffffffffc0203158:	842e                	mv	s0,a1
        start += PGSIZE;
ffffffffc020315a:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc020315c:	000b0c17          	auipc	s8,0xb0
ffffffffc0203160:	694c0c13          	addi	s8,s8,1684 # ffffffffc02b37f0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203164:	000b0b97          	auipc	s7,0xb0
ffffffffc0203168:	694b8b93          	addi	s7,s7,1684 # ffffffffc02b37f8 <pages>
    return KADDR(page2pa(page));
ffffffffc020316c:	00cada93          	srli	s5,s5,0xc
ffffffffc0203170:	000b0c97          	auipc	s9,0xb0
ffffffffc0203174:	698c8c93          	addi	s9,s9,1688 # ffffffffc02b3808 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203178:	4601                	li	a2,0
ffffffffc020317a:	85ea                	mv	a1,s10
ffffffffc020317c:	8522                	mv	a0,s0
ffffffffc020317e:	c6ffe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203182:	892a                	mv	s2,a0
        if (ptep == NULL) {
ffffffffc0203184:	c969                	beqz	a0,ffffffffc0203256 <copy_range+0x140>
        if (*ptep & PTE_V) {
ffffffffc0203186:	6118                	ld	a4,0(a0)
ffffffffc0203188:	8b05                	andi	a4,a4,1
ffffffffc020318a:	e705                	bnez	a4,ffffffffc02031b2 <copy_range+0x9c>
        start += PGSIZE;
ffffffffc020318c:	9d4e                	add	s10,s10,s3
    } while (start != 0 && start < end);
ffffffffc020318e:	fe9d65e3          	bltu	s10,s1,ffffffffc0203178 <copy_range+0x62>
    return 0;
ffffffffc0203192:	4501                	li	a0,0
}
ffffffffc0203194:	70e6                	ld	ra,120(sp)
ffffffffc0203196:	7446                	ld	s0,112(sp)
ffffffffc0203198:	74a6                	ld	s1,104(sp)
ffffffffc020319a:	7906                	ld	s2,96(sp)
ffffffffc020319c:	69e6                	ld	s3,88(sp)
ffffffffc020319e:	6a46                	ld	s4,80(sp)
ffffffffc02031a0:	6aa6                	ld	s5,72(sp)
ffffffffc02031a2:	6b06                	ld	s6,64(sp)
ffffffffc02031a4:	7be2                	ld	s7,56(sp)
ffffffffc02031a6:	7c42                	ld	s8,48(sp)
ffffffffc02031a8:	7ca2                	ld	s9,40(sp)
ffffffffc02031aa:	7d02                	ld	s10,32(sp)
ffffffffc02031ac:	6de2                	ld	s11,24(sp)
ffffffffc02031ae:	6109                	addi	sp,sp,128
ffffffffc02031b0:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02031b2:	4605                	li	a2,1
ffffffffc02031b4:	85ea                	mv	a1,s10
ffffffffc02031b6:	8552                	mv	a0,s4
ffffffffc02031b8:	c35fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02031bc:	14050363          	beqz	a0,ffffffffc0203302 <copy_range+0x1ec>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031c0:	00093703          	ld	a4,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc02031c4:	00177693          	andi	a3,a4,1
ffffffffc02031c8:	0007091b          	sext.w	s2,a4
ffffffffc02031cc:	1a068663          	beqz	a3,ffffffffc0203378 <copy_range+0x262>
    if (PPN(pa) >= npage) {
ffffffffc02031d0:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031d4:	070a                	slli	a4,a4,0x2
ffffffffc02031d6:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031d8:	16d77463          	bgeu	a4,a3,ffffffffc0203340 <copy_range+0x22a>
    return &pages[PPN(pa) - nbase];
ffffffffc02031dc:	000bb803          	ld	a6,0(s7)
ffffffffc02031e0:	fff807b7          	lui	a5,0xfff80
ffffffffc02031e4:	973e                	add	a4,a4,a5
ffffffffc02031e6:	071a                	slli	a4,a4,0x6
ffffffffc02031e8:	00e80b33          	add	s6,a6,a4
            assert(page != NULL);
ffffffffc02031ec:	1a0b0263          	beqz	s6,ffffffffc0203390 <copy_range+0x27a>
            if(share){
ffffffffc02031f0:	67a2                	ld	a5,8(sp)
ffffffffc02031f2:	cfbd                	beqz	a5,ffffffffc0203270 <copy_range+0x15a>
    return page - pages + nbase;
ffffffffc02031f4:	8719                	srai	a4,a4,0x6
ffffffffc02031f6:	000807b7          	lui	a5,0x80
ffffffffc02031fa:	973e                	add	a4,a4,a5
    return KADDR(page2pa(page));
ffffffffc02031fc:	01577633          	and	a2,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203200:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0203202:	10d67263          	bgeu	a2,a3,ffffffffc0203306 <copy_range+0x1f0>
ffffffffc0203206:	000cb583          	ld	a1,0(s9)
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc020320a:	00005517          	auipc	a0,0x5
ffffffffc020320e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0207c58 <default_pmm_manager+0x6e0>
                page_insert(from, page, start, perm & (~PTE_W));
ffffffffc0203212:	01b97913          	andi	s2,s2,27
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0203216:	95ba                	add	a1,a1,a4
ffffffffc0203218:	f69fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                page_insert(from, page, start, perm & (~PTE_W));
ffffffffc020321c:	86ca                	mv	a3,s2
ffffffffc020321e:	866a                	mv	a2,s10
ffffffffc0203220:	85da                	mv	a1,s6
ffffffffc0203222:	8522                	mv	a0,s0
ffffffffc0203224:	a62ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
                ret = page_insert(to, page, start, perm & (~PTE_W));
ffffffffc0203228:	86ca                	mv	a3,s2
ffffffffc020322a:	866a                	mv	a2,s10
ffffffffc020322c:	85da                	mv	a1,s6
ffffffffc020322e:	8552                	mv	a0,s4
ffffffffc0203230:	a56ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
            assert(ret == 0);
ffffffffc0203234:	dd21                	beqz	a0,ffffffffc020318c <copy_range+0x76>
ffffffffc0203236:	00005697          	auipc	a3,0x5
ffffffffc020323a:	a6268693          	addi	a3,a3,-1438 # ffffffffc0207c98 <default_pmm_manager+0x720>
ffffffffc020323e:	00004617          	auipc	a2,0x4
ffffffffc0203242:	ca260613          	addi	a2,a2,-862 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203246:	1a000593          	li	a1,416
ffffffffc020324a:	00004517          	auipc	a0,0x4
ffffffffc020324e:	47e50513          	addi	a0,a0,1150 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0203252:	a28fd0ef          	jal	ra,ffffffffc020047a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203256:	00200637          	lui	a2,0x200
ffffffffc020325a:	00cd07b3          	add	a5,s10,a2
ffffffffc020325e:	ffe00637          	lui	a2,0xffe00
ffffffffc0203262:	00c7fd33          	and	s10,a5,a2
    } while (start != 0 && start < end);
ffffffffc0203266:	f20d06e3          	beqz	s10,ffffffffc0203192 <copy_range+0x7c>
ffffffffc020326a:	f09d67e3          	bltu	s10,s1,ffffffffc0203178 <copy_range+0x62>
ffffffffc020326e:	b715                	j	ffffffffc0203192 <copy_range+0x7c>
                struct Page *npage = alloc_page();
ffffffffc0203270:	4505                	li	a0,1
ffffffffc0203272:	a6ffe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0203276:	8daa                	mv	s11,a0
                assert(npage != NULL);
ffffffffc0203278:	c165                	beqz	a0,ffffffffc0203358 <copy_range+0x242>
    return page - pages + nbase;
ffffffffc020327a:	000bb683          	ld	a3,0(s7)
ffffffffc020327e:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0203282:	000c3703          	ld	a4,0(s8)
    return page - pages + nbase;
ffffffffc0203286:	40d506b3          	sub	a3,a0,a3
ffffffffc020328a:	8699                	srai	a3,a3,0x6
ffffffffc020328c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020328e:	0156f633          	and	a2,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203292:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203294:	06e67a63          	bgeu	a2,a4,ffffffffc0203308 <copy_range+0x1f2>
ffffffffc0203298:	000cb583          	ld	a1,0(s9)
                cprintf("alloc a new page 0x%x\n", page2kva(npage));
ffffffffc020329c:	00005517          	auipc	a0,0x5
ffffffffc02032a0:	9e450513          	addi	a0,a0,-1564 # ffffffffc0207c80 <default_pmm_manager+0x708>
ffffffffc02032a4:	95b6                	add	a1,a1,a3
ffffffffc02032a6:	edbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return page - pages + nbase;
ffffffffc02032aa:	000bb703          	ld	a4,0(s7)
ffffffffc02032ae:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc02032b2:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02032b6:	40eb06b3          	sub	a3,s6,a4
ffffffffc02032ba:	8699                	srai	a3,a3,0x6
ffffffffc02032bc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02032be:	0156f5b3          	and	a1,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02032c2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02032c4:	04c5f263          	bgeu	a1,a2,ffffffffc0203308 <copy_range+0x1f2>
    return page - pages + nbase;
ffffffffc02032c8:	40ed8733          	sub	a4,s11,a4
    return KADDR(page2pa(page));
ffffffffc02032cc:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc02032d0:	8719                	srai	a4,a4,0x6
ffffffffc02032d2:	000807b7          	lui	a5,0x80
ffffffffc02032d6:	973e                	add	a4,a4,a5
    return KADDR(page2pa(page));
ffffffffc02032d8:	01577833          	and	a6,a4,s5
ffffffffc02032dc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02032e0:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02032e2:	02c87263          	bgeu	a6,a2,ffffffffc0203306 <copy_range+0x1f0>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02032e6:	6605                	lui	a2,0x1
ffffffffc02032e8:	953a                	add	a0,a0,a4
ffffffffc02032ea:	520030ef          	jal	ra,ffffffffc020680a <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02032ee:	01f97693          	andi	a3,s2,31
ffffffffc02032f2:	866a                	mv	a2,s10
ffffffffc02032f4:	85ee                	mv	a1,s11
ffffffffc02032f6:	8552                	mv	a0,s4
ffffffffc02032f8:	98eff0ef          	jal	ra,ffffffffc0202486 <page_insert>
            assert(ret == 0);
ffffffffc02032fc:	e80508e3          	beqz	a0,ffffffffc020318c <copy_range+0x76>
ffffffffc0203300:	bf1d                	j	ffffffffc0203236 <copy_range+0x120>
                return -E_NO_MEM;
ffffffffc0203302:	5571                	li	a0,-4
ffffffffc0203304:	bd41                	j	ffffffffc0203194 <copy_range+0x7e>
ffffffffc0203306:	86ba                	mv	a3,a4
ffffffffc0203308:	00004617          	auipc	a2,0x4
ffffffffc020330c:	2a860613          	addi	a2,a2,680 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0203310:	06900593          	li	a1,105
ffffffffc0203314:	00004517          	auipc	a0,0x4
ffffffffc0203318:	2c450513          	addi	a0,a0,708 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc020331c:	95efd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203320:	00004697          	auipc	a3,0x4
ffffffffc0203324:	3e868693          	addi	a3,a3,1000 # ffffffffc0207708 <default_pmm_manager+0x190>
ffffffffc0203328:	00004617          	auipc	a2,0x4
ffffffffc020332c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203330:	15e00593          	li	a1,350
ffffffffc0203334:	00004517          	auipc	a0,0x4
ffffffffc0203338:	39450513          	addi	a0,a0,916 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc020333c:	93efd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203340:	00004617          	auipc	a2,0x4
ffffffffc0203344:	34060613          	addi	a2,a2,832 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc0203348:	06200593          	li	a1,98
ffffffffc020334c:	00004517          	auipc	a0,0x4
ffffffffc0203350:	28c50513          	addi	a0,a0,652 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0203354:	926fd0ef          	jal	ra,ffffffffc020047a <__panic>
                assert(npage != NULL);
ffffffffc0203358:	00005697          	auipc	a3,0x5
ffffffffc020335c:	91868693          	addi	a3,a3,-1768 # ffffffffc0207c70 <default_pmm_manager+0x6f8>
ffffffffc0203360:	00004617          	auipc	a2,0x4
ffffffffc0203364:	b8060613          	addi	a2,a2,-1152 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203368:	17b00593          	li	a1,379
ffffffffc020336c:	00004517          	auipc	a0,0x4
ffffffffc0203370:	35c50513          	addi	a0,a0,860 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc0203374:	906fd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203378:	00004617          	auipc	a2,0x4
ffffffffc020337c:	32860613          	addi	a2,a2,808 # ffffffffc02076a0 <default_pmm_manager+0x128>
ffffffffc0203380:	07400593          	li	a1,116
ffffffffc0203384:	00004517          	auipc	a0,0x4
ffffffffc0203388:	25450513          	addi	a0,a0,596 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc020338c:	8eefd0ef          	jal	ra,ffffffffc020047a <__panic>
            assert(page != NULL);
ffffffffc0203390:	00005697          	auipc	a3,0x5
ffffffffc0203394:	8b868693          	addi	a3,a3,-1864 # ffffffffc0207c48 <default_pmm_manager+0x6d0>
ffffffffc0203398:	00004617          	auipc	a2,0x4
ffffffffc020339c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02033a0:	17300593          	li	a1,371
ffffffffc02033a4:	00004517          	auipc	a0,0x4
ffffffffc02033a8:	32450513          	addi	a0,a0,804 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02033ac:	8cefd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02033b0:	00004697          	auipc	a3,0x4
ffffffffc02033b4:	32868693          	addi	a3,a3,808 # ffffffffc02076d8 <default_pmm_manager+0x160>
ffffffffc02033b8:	00004617          	auipc	a2,0x4
ffffffffc02033bc:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02033c0:	15d00593          	li	a1,349
ffffffffc02033c4:	00004517          	auipc	a0,0x4
ffffffffc02033c8:	30450513          	addi	a0,a0,772 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc02033cc:	8aefd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02033d0 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033d0:	12058073          	sfence.vma	a1
}
ffffffffc02033d4:	8082                	ret

ffffffffc02033d6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02033d6:	7179                	addi	sp,sp,-48
ffffffffc02033d8:	e84a                	sd	s2,16(sp)
ffffffffc02033da:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02033dc:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02033de:	f022                	sd	s0,32(sp)
ffffffffc02033e0:	ec26                	sd	s1,24(sp)
ffffffffc02033e2:	e44e                	sd	s3,8(sp)
ffffffffc02033e4:	f406                	sd	ra,40(sp)
ffffffffc02033e6:	84ae                	mv	s1,a1
ffffffffc02033e8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02033ea:	8f7fe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02033ee:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02033f0:	cd05                	beqz	a0,ffffffffc0203428 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02033f2:	85aa                	mv	a1,a0
ffffffffc02033f4:	86ce                	mv	a3,s3
ffffffffc02033f6:	8626                	mv	a2,s1
ffffffffc02033f8:	854a                	mv	a0,s2
ffffffffc02033fa:	88cff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02033fe:	ed0d                	bnez	a0,ffffffffc0203438 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0203400:	000b0797          	auipc	a5,0xb0
ffffffffc0203404:	4207a783          	lw	a5,1056(a5) # ffffffffc02b3820 <swap_init_ok>
ffffffffc0203408:	c385                	beqz	a5,ffffffffc0203428 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc020340a:	000b0517          	auipc	a0,0xb0
ffffffffc020340e:	42653503          	ld	a0,1062(a0) # ffffffffc02b3830 <check_mm_struct>
ffffffffc0203412:	c919                	beqz	a0,ffffffffc0203428 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203414:	4681                	li	a3,0
ffffffffc0203416:	8622                	mv	a2,s0
ffffffffc0203418:	85a6                	mv	a1,s1
ffffffffc020341a:	7e4000ef          	jal	ra,ffffffffc0203bfe <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc020341e:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203420:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203422:	4785                	li	a5,1
ffffffffc0203424:	04f71663          	bne	a4,a5,ffffffffc0203470 <pgdir_alloc_page+0x9a>
}
ffffffffc0203428:	70a2                	ld	ra,40(sp)
ffffffffc020342a:	8522                	mv	a0,s0
ffffffffc020342c:	7402                	ld	s0,32(sp)
ffffffffc020342e:	64e2                	ld	s1,24(sp)
ffffffffc0203430:	6942                	ld	s2,16(sp)
ffffffffc0203432:	69a2                	ld	s3,8(sp)
ffffffffc0203434:	6145                	addi	sp,sp,48
ffffffffc0203436:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203438:	100027f3          	csrr	a5,sstatus
ffffffffc020343c:	8b89                	andi	a5,a5,2
ffffffffc020343e:	eb99                	bnez	a5,ffffffffc0203454 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0203440:	000b0797          	auipc	a5,0xb0
ffffffffc0203444:	3c07b783          	ld	a5,960(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0203448:	739c                	ld	a5,32(a5)
ffffffffc020344a:	8522                	mv	a0,s0
ffffffffc020344c:	4585                	li	a1,1
ffffffffc020344e:	9782                	jalr	a5
            return NULL;
ffffffffc0203450:	4401                	li	s0,0
ffffffffc0203452:	bfd9                	j	ffffffffc0203428 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0203454:	9f2fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203458:	000b0797          	auipc	a5,0xb0
ffffffffc020345c:	3a87b783          	ld	a5,936(a5) # ffffffffc02b3800 <pmm_manager>
ffffffffc0203460:	739c                	ld	a5,32(a5)
ffffffffc0203462:	8522                	mv	a0,s0
ffffffffc0203464:	4585                	li	a1,1
ffffffffc0203466:	9782                	jalr	a5
            return NULL;
ffffffffc0203468:	4401                	li	s0,0
        intr_enable();
ffffffffc020346a:	9d6fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020346e:	bf6d                	j	ffffffffc0203428 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0203470:	00005697          	auipc	a3,0x5
ffffffffc0203474:	83868693          	addi	a3,a3,-1992 # ffffffffc0207ca8 <default_pmm_manager+0x730>
ffffffffc0203478:	00004617          	auipc	a2,0x4
ffffffffc020347c:	a6860613          	addi	a2,a2,-1432 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203480:	1df00593          	li	a1,479
ffffffffc0203484:	00004517          	auipc	a0,0x4
ffffffffc0203488:	24450513          	addi	a0,a0,580 # ffffffffc02076c8 <default_pmm_manager+0x150>
ffffffffc020348c:	feffc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203490 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203490:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203492:	00004617          	auipc	a2,0x4
ffffffffc0203496:	1ee60613          	addi	a2,a2,494 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc020349a:	06200593          	li	a1,98
ffffffffc020349e:	00004517          	auipc	a0,0x4
ffffffffc02034a2:	13a50513          	addi	a0,a0,314 # ffffffffc02075d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc02034a6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02034a8:	fd3fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02034ac <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02034ac:	7135                	addi	sp,sp,-160
ffffffffc02034ae:	ed06                	sd	ra,152(sp)
ffffffffc02034b0:	e922                	sd	s0,144(sp)
ffffffffc02034b2:	e526                	sd	s1,136(sp)
ffffffffc02034b4:	e14a                	sd	s2,128(sp)
ffffffffc02034b6:	fcce                	sd	s3,120(sp)
ffffffffc02034b8:	f8d2                	sd	s4,112(sp)
ffffffffc02034ba:	f4d6                	sd	s5,104(sp)
ffffffffc02034bc:	f0da                	sd	s6,96(sp)
ffffffffc02034be:	ecde                	sd	s7,88(sp)
ffffffffc02034c0:	e8e2                	sd	s8,80(sp)
ffffffffc02034c2:	e4e6                	sd	s9,72(sp)
ffffffffc02034c4:	e0ea                	sd	s10,64(sp)
ffffffffc02034c6:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02034c8:	0f1010ef          	jal	ra,ffffffffc0204db8 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02034cc:	000b0697          	auipc	a3,0xb0
ffffffffc02034d0:	3446b683          	ld	a3,836(a3) # ffffffffc02b3810 <max_swap_offset>
ffffffffc02034d4:	010007b7          	lui	a5,0x1000
ffffffffc02034d8:	ff968713          	addi	a4,a3,-7
ffffffffc02034dc:	17e1                	addi	a5,a5,-8
ffffffffc02034de:	42e7e663          	bltu	a5,a4,ffffffffc020390a <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02034e2:	000a5797          	auipc	a5,0xa5
ffffffffc02034e6:	dc678793          	addi	a5,a5,-570 # ffffffffc02a82a8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02034ea:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02034ec:	000b0b97          	auipc	s7,0xb0
ffffffffc02034f0:	32cb8b93          	addi	s7,s7,812 # ffffffffc02b3818 <sm>
ffffffffc02034f4:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02034f8:	9702                	jalr	a4
ffffffffc02034fa:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02034fc:	c10d                	beqz	a0,ffffffffc020351e <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02034fe:	60ea                	ld	ra,152(sp)
ffffffffc0203500:	644a                	ld	s0,144(sp)
ffffffffc0203502:	64aa                	ld	s1,136(sp)
ffffffffc0203504:	79e6                	ld	s3,120(sp)
ffffffffc0203506:	7a46                	ld	s4,112(sp)
ffffffffc0203508:	7aa6                	ld	s5,104(sp)
ffffffffc020350a:	7b06                	ld	s6,96(sp)
ffffffffc020350c:	6be6                	ld	s7,88(sp)
ffffffffc020350e:	6c46                	ld	s8,80(sp)
ffffffffc0203510:	6ca6                	ld	s9,72(sp)
ffffffffc0203512:	6d06                	ld	s10,64(sp)
ffffffffc0203514:	7de2                	ld	s11,56(sp)
ffffffffc0203516:	854a                	mv	a0,s2
ffffffffc0203518:	690a                	ld	s2,128(sp)
ffffffffc020351a:	610d                	addi	sp,sp,160
ffffffffc020351c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020351e:	000bb783          	ld	a5,0(s7)
ffffffffc0203522:	00004517          	auipc	a0,0x4
ffffffffc0203526:	7ce50513          	addi	a0,a0,1998 # ffffffffc0207cf0 <default_pmm_manager+0x778>
    return listelm->next;
ffffffffc020352a:	000ac417          	auipc	s0,0xac
ffffffffc020352e:	1ce40413          	addi	s0,s0,462 # ffffffffc02af6f8 <free_area>
ffffffffc0203532:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203534:	4785                	li	a5,1
ffffffffc0203536:	000b0717          	auipc	a4,0xb0
ffffffffc020353a:	2ef72523          	sw	a5,746(a4) # ffffffffc02b3820 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020353e:	c43fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203542:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203544:	4d01                	li	s10,0
ffffffffc0203546:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203548:	34878163          	beq	a5,s0,ffffffffc020388a <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020354c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203550:	8b09                	andi	a4,a4,2
ffffffffc0203552:	32070e63          	beqz	a4,ffffffffc020388e <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203556:	ff87a703          	lw	a4,-8(a5)
ffffffffc020355a:	679c                	ld	a5,8(a5)
ffffffffc020355c:	2d85                	addiw	s11,s11,1
ffffffffc020355e:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203562:	fe8795e3          	bne	a5,s0,ffffffffc020354c <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203566:	84ea                	mv	s1,s10
ffffffffc0203568:	84bfe0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc020356c:	42951763          	bne	a0,s1,ffffffffc020399a <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203570:	866a                	mv	a2,s10
ffffffffc0203572:	85ee                	mv	a1,s11
ffffffffc0203574:	00004517          	auipc	a0,0x4
ffffffffc0203578:	79450513          	addi	a0,a0,1940 # ffffffffc0207d08 <default_pmm_manager+0x790>
ffffffffc020357c:	c05fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203580:	487000ef          	jal	ra,ffffffffc0204206 <mm_create>
ffffffffc0203584:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0203586:	46050a63          	beqz	a0,ffffffffc02039fa <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020358a:	000b0797          	auipc	a5,0xb0
ffffffffc020358e:	2a678793          	addi	a5,a5,678 # ffffffffc02b3830 <check_mm_struct>
ffffffffc0203592:	6398                	ld	a4,0(a5)
ffffffffc0203594:	3e071363          	bnez	a4,ffffffffc020397a <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203598:	000b0717          	auipc	a4,0xb0
ffffffffc020359c:	25070713          	addi	a4,a4,592 # ffffffffc02b37e8 <boot_pgdir>
ffffffffc02035a0:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02035a4:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02035a6:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02035aa:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02035ae:	42079663          	bnez	a5,ffffffffc02039da <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02035b2:	6599                	lui	a1,0x6
ffffffffc02035b4:	460d                	li	a2,3
ffffffffc02035b6:	6505                	lui	a0,0x1
ffffffffc02035b8:	497000ef          	jal	ra,ffffffffc020424e <vma_create>
ffffffffc02035bc:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02035be:	52050a63          	beqz	a0,ffffffffc0203af2 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02035c2:	8556                	mv	a0,s5
ffffffffc02035c4:	4f9000ef          	jal	ra,ffffffffc02042bc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02035c8:	00004517          	auipc	a0,0x4
ffffffffc02035cc:	7b050513          	addi	a0,a0,1968 # ffffffffc0207d78 <default_pmm_manager+0x800>
ffffffffc02035d0:	bb1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02035d4:	018ab503          	ld	a0,24(s5)
ffffffffc02035d8:	4605                	li	a2,1
ffffffffc02035da:	6585                	lui	a1,0x1
ffffffffc02035dc:	811fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02035e0:	4c050963          	beqz	a0,ffffffffc0203ab2 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02035e4:	00004517          	auipc	a0,0x4
ffffffffc02035e8:	7e450513          	addi	a0,a0,2020 # ffffffffc0207dc8 <default_pmm_manager+0x850>
ffffffffc02035ec:	000ac497          	auipc	s1,0xac
ffffffffc02035f0:	14448493          	addi	s1,s1,324 # ffffffffc02af730 <check_rp>
ffffffffc02035f4:	b8dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035f8:	000ac997          	auipc	s3,0xac
ffffffffc02035fc:	15898993          	addi	s3,s3,344 # ffffffffc02af750 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203600:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203602:	4505                	li	a0,1
ffffffffc0203604:	edcfe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0203608:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc020360c:	2c050f63          	beqz	a0,ffffffffc02038ea <swap_init+0x43e>
ffffffffc0203610:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203612:	8b89                	andi	a5,a5,2
ffffffffc0203614:	34079363          	bnez	a5,ffffffffc020395a <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203618:	0a21                	addi	s4,s4,8
ffffffffc020361a:	ff3a14e3          	bne	s4,s3,ffffffffc0203602 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc020361e:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203620:	000aca17          	auipc	s4,0xac
ffffffffc0203624:	110a0a13          	addi	s4,s4,272 # ffffffffc02af730 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0203628:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020362a:	ec3e                	sd	a5,24(sp)
ffffffffc020362c:	641c                	ld	a5,8(s0)
ffffffffc020362e:	e400                	sd	s0,8(s0)
ffffffffc0203630:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203632:	481c                	lw	a5,16(s0)
ffffffffc0203634:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203636:	000ac797          	auipc	a5,0xac
ffffffffc020363a:	0c07a923          	sw	zero,210(a5) # ffffffffc02af708 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020363e:	000a3503          	ld	a0,0(s4)
ffffffffc0203642:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203644:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203646:	f2cfe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020364a:	ff3a1ae3          	bne	s4,s3,ffffffffc020363e <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020364e:	01042a03          	lw	s4,16(s0)
ffffffffc0203652:	4791                	li	a5,4
ffffffffc0203654:	42fa1f63          	bne	s4,a5,ffffffffc0203a92 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203658:	00004517          	auipc	a0,0x4
ffffffffc020365c:	7f850513          	addi	a0,a0,2040 # ffffffffc0207e50 <default_pmm_manager+0x8d8>
ffffffffc0203660:	b21fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203664:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203666:	000b0797          	auipc	a5,0xb0
ffffffffc020366a:	1c07a923          	sw	zero,466(a5) # ffffffffc02b3838 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020366e:	4629                	li	a2,10
ffffffffc0203670:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc0203674:	000b0697          	auipc	a3,0xb0
ffffffffc0203678:	1c46a683          	lw	a3,452(a3) # ffffffffc02b3838 <pgfault_num>
ffffffffc020367c:	4585                	li	a1,1
ffffffffc020367e:	000b0797          	auipc	a5,0xb0
ffffffffc0203682:	1ba78793          	addi	a5,a5,442 # ffffffffc02b3838 <pgfault_num>
ffffffffc0203686:	54b69663          	bne	a3,a1,ffffffffc0203bd2 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020368a:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc020368e:	4398                	lw	a4,0(a5)
ffffffffc0203690:	2701                	sext.w	a4,a4
ffffffffc0203692:	3ed71063          	bne	a4,a3,ffffffffc0203a72 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203696:	6689                	lui	a3,0x2
ffffffffc0203698:	462d                	li	a2,11
ffffffffc020369a:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc020369e:	4398                	lw	a4,0(a5)
ffffffffc02036a0:	4589                	li	a1,2
ffffffffc02036a2:	2701                	sext.w	a4,a4
ffffffffc02036a4:	4ab71763          	bne	a4,a1,ffffffffc0203b52 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02036a8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02036ac:	4394                	lw	a3,0(a5)
ffffffffc02036ae:	2681                	sext.w	a3,a3
ffffffffc02036b0:	4ce69163          	bne	a3,a4,ffffffffc0203b72 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02036b4:	668d                	lui	a3,0x3
ffffffffc02036b6:	4631                	li	a2,12
ffffffffc02036b8:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc02036bc:	4398                	lw	a4,0(a5)
ffffffffc02036be:	458d                	li	a1,3
ffffffffc02036c0:	2701                	sext.w	a4,a4
ffffffffc02036c2:	4cb71863          	bne	a4,a1,ffffffffc0203b92 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02036c6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02036ca:	4394                	lw	a3,0(a5)
ffffffffc02036cc:	2681                	sext.w	a3,a3
ffffffffc02036ce:	4ee69263          	bne	a3,a4,ffffffffc0203bb2 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02036d2:	6691                	lui	a3,0x4
ffffffffc02036d4:	4635                	li	a2,13
ffffffffc02036d6:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc02036da:	4398                	lw	a4,0(a5)
ffffffffc02036dc:	2701                	sext.w	a4,a4
ffffffffc02036de:	43471a63          	bne	a4,s4,ffffffffc0203b12 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02036e2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02036e6:	439c                	lw	a5,0(a5)
ffffffffc02036e8:	2781                	sext.w	a5,a5
ffffffffc02036ea:	44e79463          	bne	a5,a4,ffffffffc0203b32 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02036ee:	481c                	lw	a5,16(s0)
ffffffffc02036f0:	2c079563          	bnez	a5,ffffffffc02039ba <swap_init+0x50e>
ffffffffc02036f4:	000ac797          	auipc	a5,0xac
ffffffffc02036f8:	05c78793          	addi	a5,a5,92 # ffffffffc02af750 <swap_in_seq_no>
ffffffffc02036fc:	000ac717          	auipc	a4,0xac
ffffffffc0203700:	07c70713          	addi	a4,a4,124 # ffffffffc02af778 <swap_out_seq_no>
ffffffffc0203704:	000ac617          	auipc	a2,0xac
ffffffffc0203708:	07460613          	addi	a2,a2,116 # ffffffffc02af778 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020370c:	56fd                	li	a3,-1
ffffffffc020370e:	c394                	sw	a3,0(a5)
ffffffffc0203710:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203712:	0791                	addi	a5,a5,4
ffffffffc0203714:	0711                	addi	a4,a4,4
ffffffffc0203716:	fec79ce3          	bne	a5,a2,ffffffffc020370e <swap_init+0x262>
ffffffffc020371a:	000ac717          	auipc	a4,0xac
ffffffffc020371e:	ff670713          	addi	a4,a4,-10 # ffffffffc02af710 <check_ptep>
ffffffffc0203722:	000ac697          	auipc	a3,0xac
ffffffffc0203726:	00e68693          	addi	a3,a3,14 # ffffffffc02af730 <check_rp>
ffffffffc020372a:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc020372c:	000b0c17          	auipc	s8,0xb0
ffffffffc0203730:	0c4c0c13          	addi	s8,s8,196 # ffffffffc02b37f0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203734:	000b0c97          	auipc	s9,0xb0
ffffffffc0203738:	0c4c8c93          	addi	s9,s9,196 # ffffffffc02b37f8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020373c:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203740:	4601                	li	a2,0
ffffffffc0203742:	855a                	mv	a0,s6
ffffffffc0203744:	e836                	sd	a3,16(sp)
ffffffffc0203746:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203748:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020374a:	ea2fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020374e:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203750:	65a2                	ld	a1,8(sp)
ffffffffc0203752:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203754:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203756:	1c050663          	beqz	a0,ffffffffc0203922 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020375a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020375c:	0017f613          	andi	a2,a5,1
ffffffffc0203760:	1e060163          	beqz	a2,ffffffffc0203942 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203764:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203768:	078a                	slli	a5,a5,0x2
ffffffffc020376a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020376c:	14c7f363          	bgeu	a5,a2,ffffffffc02038b2 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203770:	00006617          	auipc	a2,0x6
ffffffffc0203774:	92860613          	addi	a2,a2,-1752 # ffffffffc0209098 <nbase>
ffffffffc0203778:	00063a03          	ld	s4,0(a2)
ffffffffc020377c:	000cb603          	ld	a2,0(s9)
ffffffffc0203780:	6288                	ld	a0,0(a3)
ffffffffc0203782:	414787b3          	sub	a5,a5,s4
ffffffffc0203786:	079a                	slli	a5,a5,0x6
ffffffffc0203788:	97b2                	add	a5,a5,a2
ffffffffc020378a:	14f51063          	bne	a0,a5,ffffffffc02038ca <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020378e:	6785                	lui	a5,0x1
ffffffffc0203790:	95be                	add	a1,a1,a5
ffffffffc0203792:	6795                	lui	a5,0x5
ffffffffc0203794:	0721                	addi	a4,a4,8
ffffffffc0203796:	06a1                	addi	a3,a3,8
ffffffffc0203798:	faf592e3          	bne	a1,a5,ffffffffc020373c <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020379c:	00004517          	auipc	a0,0x4
ffffffffc02037a0:	75c50513          	addi	a0,a0,1884 # ffffffffc0207ef8 <default_pmm_manager+0x980>
ffffffffc02037a4:	9ddfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc02037a8:	000bb783          	ld	a5,0(s7)
ffffffffc02037ac:	7f9c                	ld	a5,56(a5)
ffffffffc02037ae:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02037b0:	32051163          	bnez	a0,ffffffffc0203ad2 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc02037b4:	77a2                	ld	a5,40(sp)
ffffffffc02037b6:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc02037b8:	67e2                	ld	a5,24(sp)
ffffffffc02037ba:	e01c                	sd	a5,0(s0)
ffffffffc02037bc:	7782                	ld	a5,32(sp)
ffffffffc02037be:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02037c0:	6088                	ld	a0,0(s1)
ffffffffc02037c2:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037c4:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc02037c6:	dacfe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037ca:	ff349be3          	bne	s1,s3,ffffffffc02037c0 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02037ce:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc02037d2:	8556                	mv	a0,s5
ffffffffc02037d4:	3b9000ef          	jal	ra,ffffffffc020438c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02037d8:	000b0797          	auipc	a5,0xb0
ffffffffc02037dc:	01078793          	addi	a5,a5,16 # ffffffffc02b37e8 <boot_pgdir>
ffffffffc02037e0:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02037e2:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc02037e6:	000b0697          	auipc	a3,0xb0
ffffffffc02037ea:	0406b523          	sd	zero,74(a3) # ffffffffc02b3830 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037ee:	639c                	ld	a5,0(a5)
ffffffffc02037f0:	078a                	slli	a5,a5,0x2
ffffffffc02037f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037f4:	0ae7fd63          	bgeu	a5,a4,ffffffffc02038ae <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02037f8:	414786b3          	sub	a3,a5,s4
ffffffffc02037fc:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02037fe:	8699                	srai	a3,a3,0x6
ffffffffc0203800:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203802:	00c69793          	slli	a5,a3,0xc
ffffffffc0203806:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203808:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc020380c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020380e:	22e7f663          	bgeu	a5,a4,ffffffffc0203a3a <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203812:	000b0797          	auipc	a5,0xb0
ffffffffc0203816:	ff67b783          	ld	a5,-10(a5) # ffffffffc02b3808 <va_pa_offset>
ffffffffc020381a:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020381c:	629c                	ld	a5,0(a3)
ffffffffc020381e:	078a                	slli	a5,a5,0x2
ffffffffc0203820:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203822:	08e7f663          	bgeu	a5,a4,ffffffffc02038ae <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203826:	414787b3          	sub	a5,a5,s4
ffffffffc020382a:	079a                	slli	a5,a5,0x6
ffffffffc020382c:	953e                	add	a0,a0,a5
ffffffffc020382e:	4585                	li	a1,1
ffffffffc0203830:	d42fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203834:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203838:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc020383c:	078a                	slli	a5,a5,0x2
ffffffffc020383e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203840:	06e7f763          	bgeu	a5,a4,ffffffffc02038ae <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203844:	000cb503          	ld	a0,0(s9)
ffffffffc0203848:	414787b3          	sub	a5,a5,s4
ffffffffc020384c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020384e:	4585                	li	a1,1
ffffffffc0203850:	953e                	add	a0,a0,a5
ffffffffc0203852:	d20fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     pgdir[0] = 0;
ffffffffc0203856:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020385a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020385e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203860:	00878a63          	beq	a5,s0,ffffffffc0203874 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203864:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203868:	679c                	ld	a5,8(a5)
ffffffffc020386a:	3dfd                	addiw	s11,s11,-1
ffffffffc020386c:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203870:	fe879ae3          	bne	a5,s0,ffffffffc0203864 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203874:	1c0d9f63          	bnez	s11,ffffffffc0203a52 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203878:	1a0d1163          	bnez	s10,ffffffffc0203a1a <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc020387c:	00004517          	auipc	a0,0x4
ffffffffc0203880:	6cc50513          	addi	a0,a0,1740 # ffffffffc0207f48 <default_pmm_manager+0x9d0>
ffffffffc0203884:	8fdfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203888:	b99d                	j	ffffffffc02034fe <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc020388a:	4481                	li	s1,0
ffffffffc020388c:	b9f1                	j	ffffffffc0203568 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc020388e:	00004697          	auipc	a3,0x4
ffffffffc0203892:	94268693          	addi	a3,a3,-1726 # ffffffffc02071d0 <commands+0x740>
ffffffffc0203896:	00003617          	auipc	a2,0x3
ffffffffc020389a:	64a60613          	addi	a2,a2,1610 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020389e:	0bc00593          	li	a1,188
ffffffffc02038a2:	00004517          	auipc	a0,0x4
ffffffffc02038a6:	43e50513          	addi	a0,a0,1086 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc02038aa:	bd1fc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02038ae:	be3ff0ef          	jal	ra,ffffffffc0203490 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc02038b2:	00004617          	auipc	a2,0x4
ffffffffc02038b6:	dce60613          	addi	a2,a2,-562 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc02038ba:	06200593          	li	a1,98
ffffffffc02038be:	00004517          	auipc	a0,0x4
ffffffffc02038c2:	d1a50513          	addi	a0,a0,-742 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc02038c6:	bb5fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02038ca:	00004697          	auipc	a3,0x4
ffffffffc02038ce:	60668693          	addi	a3,a3,1542 # ffffffffc0207ed0 <default_pmm_manager+0x958>
ffffffffc02038d2:	00003617          	auipc	a2,0x3
ffffffffc02038d6:	60e60613          	addi	a2,a2,1550 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02038da:	0fc00593          	li	a1,252
ffffffffc02038de:	00004517          	auipc	a0,0x4
ffffffffc02038e2:	40250513          	addi	a0,a0,1026 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc02038e6:	b95fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02038ea:	00004697          	auipc	a3,0x4
ffffffffc02038ee:	50668693          	addi	a3,a3,1286 # ffffffffc0207df0 <default_pmm_manager+0x878>
ffffffffc02038f2:	00003617          	auipc	a2,0x3
ffffffffc02038f6:	5ee60613          	addi	a2,a2,1518 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02038fa:	0dc00593          	li	a1,220
ffffffffc02038fe:	00004517          	auipc	a0,0x4
ffffffffc0203902:	3e250513          	addi	a0,a0,994 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203906:	b75fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020390a:	00004617          	auipc	a2,0x4
ffffffffc020390e:	3b660613          	addi	a2,a2,950 # ffffffffc0207cc0 <default_pmm_manager+0x748>
ffffffffc0203912:	02800593          	li	a1,40
ffffffffc0203916:	00004517          	auipc	a0,0x4
ffffffffc020391a:	3ca50513          	addi	a0,a0,970 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc020391e:	b5dfc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203922:	00004697          	auipc	a3,0x4
ffffffffc0203926:	59668693          	addi	a3,a3,1430 # ffffffffc0207eb8 <default_pmm_manager+0x940>
ffffffffc020392a:	00003617          	auipc	a2,0x3
ffffffffc020392e:	5b660613          	addi	a2,a2,1462 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203932:	0fb00593          	li	a1,251
ffffffffc0203936:	00004517          	auipc	a0,0x4
ffffffffc020393a:	3aa50513          	addi	a0,a0,938 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc020393e:	b3dfc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203942:	00004617          	auipc	a2,0x4
ffffffffc0203946:	d5e60613          	addi	a2,a2,-674 # ffffffffc02076a0 <default_pmm_manager+0x128>
ffffffffc020394a:	07400593          	li	a1,116
ffffffffc020394e:	00004517          	auipc	a0,0x4
ffffffffc0203952:	c8a50513          	addi	a0,a0,-886 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0203956:	b25fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020395a:	00004697          	auipc	a3,0x4
ffffffffc020395e:	4ae68693          	addi	a3,a3,1198 # ffffffffc0207e08 <default_pmm_manager+0x890>
ffffffffc0203962:	00003617          	auipc	a2,0x3
ffffffffc0203966:	57e60613          	addi	a2,a2,1406 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020396a:	0dd00593          	li	a1,221
ffffffffc020396e:	00004517          	auipc	a0,0x4
ffffffffc0203972:	37250513          	addi	a0,a0,882 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203976:	b05fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020397a:	00004697          	auipc	a3,0x4
ffffffffc020397e:	3c668693          	addi	a3,a3,966 # ffffffffc0207d40 <default_pmm_manager+0x7c8>
ffffffffc0203982:	00003617          	auipc	a2,0x3
ffffffffc0203986:	55e60613          	addi	a2,a2,1374 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020398a:	0c700593          	li	a1,199
ffffffffc020398e:	00004517          	auipc	a0,0x4
ffffffffc0203992:	35250513          	addi	a0,a0,850 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203996:	ae5fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc020399a:	00004697          	auipc	a3,0x4
ffffffffc020399e:	85e68693          	addi	a3,a3,-1954 # ffffffffc02071f8 <commands+0x768>
ffffffffc02039a2:	00003617          	auipc	a2,0x3
ffffffffc02039a6:	53e60613          	addi	a2,a2,1342 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02039aa:	0bf00593          	li	a1,191
ffffffffc02039ae:	00004517          	auipc	a0,0x4
ffffffffc02039b2:	33250513          	addi	a0,a0,818 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc02039b6:	ac5fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc02039ba:	00004697          	auipc	a3,0x4
ffffffffc02039be:	9e668693          	addi	a3,a3,-1562 # ffffffffc02073a0 <commands+0x910>
ffffffffc02039c2:	00003617          	auipc	a2,0x3
ffffffffc02039c6:	51e60613          	addi	a2,a2,1310 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02039ca:	0f300593          	li	a1,243
ffffffffc02039ce:	00004517          	auipc	a0,0x4
ffffffffc02039d2:	31250513          	addi	a0,a0,786 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc02039d6:	aa5fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc02039da:	00004697          	auipc	a3,0x4
ffffffffc02039de:	37e68693          	addi	a3,a3,894 # ffffffffc0207d58 <default_pmm_manager+0x7e0>
ffffffffc02039e2:	00003617          	auipc	a2,0x3
ffffffffc02039e6:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02039ea:	0cc00593          	li	a1,204
ffffffffc02039ee:	00004517          	auipc	a0,0x4
ffffffffc02039f2:	2f250513          	addi	a0,a0,754 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc02039f6:	a85fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc02039fa:	00004697          	auipc	a3,0x4
ffffffffc02039fe:	33668693          	addi	a3,a3,822 # ffffffffc0207d30 <default_pmm_manager+0x7b8>
ffffffffc0203a02:	00003617          	auipc	a2,0x3
ffffffffc0203a06:	4de60613          	addi	a2,a2,1246 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203a0a:	0c400593          	li	a1,196
ffffffffc0203a0e:	00004517          	auipc	a0,0x4
ffffffffc0203a12:	2d250513          	addi	a0,a0,722 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203a16:	a65fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc0203a1a:	00004697          	auipc	a3,0x4
ffffffffc0203a1e:	51e68693          	addi	a3,a3,1310 # ffffffffc0207f38 <default_pmm_manager+0x9c0>
ffffffffc0203a22:	00003617          	auipc	a2,0x3
ffffffffc0203a26:	4be60613          	addi	a2,a2,1214 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203a2a:	11e00593          	li	a1,286
ffffffffc0203a2e:	00004517          	auipc	a0,0x4
ffffffffc0203a32:	2b250513          	addi	a0,a0,690 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203a36:	a45fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a3a:	00004617          	auipc	a2,0x4
ffffffffc0203a3e:	b7660613          	addi	a2,a2,-1162 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0203a42:	06900593          	li	a1,105
ffffffffc0203a46:	00004517          	auipc	a0,0x4
ffffffffc0203a4a:	b9250513          	addi	a0,a0,-1134 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0203a4e:	a2dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc0203a52:	00004697          	auipc	a3,0x4
ffffffffc0203a56:	4d668693          	addi	a3,a3,1238 # ffffffffc0207f28 <default_pmm_manager+0x9b0>
ffffffffc0203a5a:	00003617          	auipc	a2,0x3
ffffffffc0203a5e:	48660613          	addi	a2,a2,1158 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203a62:	11d00593          	li	a1,285
ffffffffc0203a66:	00004517          	auipc	a0,0x4
ffffffffc0203a6a:	27a50513          	addi	a0,a0,634 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203a6e:	a0dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203a72:	00004697          	auipc	a3,0x4
ffffffffc0203a76:	40668693          	addi	a3,a3,1030 # ffffffffc0207e78 <default_pmm_manager+0x900>
ffffffffc0203a7a:	00003617          	auipc	a2,0x3
ffffffffc0203a7e:	46660613          	addi	a2,a2,1126 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203a82:	09500593          	li	a1,149
ffffffffc0203a86:	00004517          	auipc	a0,0x4
ffffffffc0203a8a:	25a50513          	addi	a0,a0,602 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203a8e:	9edfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a92:	00004697          	auipc	a3,0x4
ffffffffc0203a96:	39668693          	addi	a3,a3,918 # ffffffffc0207e28 <default_pmm_manager+0x8b0>
ffffffffc0203a9a:	00003617          	auipc	a2,0x3
ffffffffc0203a9e:	44660613          	addi	a2,a2,1094 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203aa2:	0ea00593          	li	a1,234
ffffffffc0203aa6:	00004517          	auipc	a0,0x4
ffffffffc0203aaa:	23a50513          	addi	a0,a0,570 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203aae:	9cdfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203ab2:	00004697          	auipc	a3,0x4
ffffffffc0203ab6:	2fe68693          	addi	a3,a3,766 # ffffffffc0207db0 <default_pmm_manager+0x838>
ffffffffc0203aba:	00003617          	auipc	a2,0x3
ffffffffc0203abe:	42660613          	addi	a2,a2,1062 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203ac2:	0d700593          	li	a1,215
ffffffffc0203ac6:	00004517          	auipc	a0,0x4
ffffffffc0203aca:	21a50513          	addi	a0,a0,538 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203ace:	9adfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc0203ad2:	00004697          	auipc	a3,0x4
ffffffffc0203ad6:	44e68693          	addi	a3,a3,1102 # ffffffffc0207f20 <default_pmm_manager+0x9a8>
ffffffffc0203ada:	00003617          	auipc	a2,0x3
ffffffffc0203ade:	40660613          	addi	a2,a2,1030 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203ae2:	10200593          	li	a1,258
ffffffffc0203ae6:	00004517          	auipc	a0,0x4
ffffffffc0203aea:	1fa50513          	addi	a0,a0,506 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203aee:	98dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc0203af2:	00004697          	auipc	a3,0x4
ffffffffc0203af6:	27668693          	addi	a3,a3,630 # ffffffffc0207d68 <default_pmm_manager+0x7f0>
ffffffffc0203afa:	00003617          	auipc	a2,0x3
ffffffffc0203afe:	3e660613          	addi	a2,a2,998 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203b02:	0cf00593          	li	a1,207
ffffffffc0203b06:	00004517          	auipc	a0,0x4
ffffffffc0203b0a:	1da50513          	addi	a0,a0,474 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203b0e:	96dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203b12:	00004697          	auipc	a3,0x4
ffffffffc0203b16:	39668693          	addi	a3,a3,918 # ffffffffc0207ea8 <default_pmm_manager+0x930>
ffffffffc0203b1a:	00003617          	auipc	a2,0x3
ffffffffc0203b1e:	3c660613          	addi	a2,a2,966 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203b22:	09f00593          	li	a1,159
ffffffffc0203b26:	00004517          	auipc	a0,0x4
ffffffffc0203b2a:	1ba50513          	addi	a0,a0,442 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203b2e:	94dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203b32:	00004697          	auipc	a3,0x4
ffffffffc0203b36:	37668693          	addi	a3,a3,886 # ffffffffc0207ea8 <default_pmm_manager+0x930>
ffffffffc0203b3a:	00003617          	auipc	a2,0x3
ffffffffc0203b3e:	3a660613          	addi	a2,a2,934 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203b42:	0a100593          	li	a1,161
ffffffffc0203b46:	00004517          	auipc	a0,0x4
ffffffffc0203b4a:	19a50513          	addi	a0,a0,410 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203b4e:	92dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203b52:	00004697          	auipc	a3,0x4
ffffffffc0203b56:	33668693          	addi	a3,a3,822 # ffffffffc0207e88 <default_pmm_manager+0x910>
ffffffffc0203b5a:	00003617          	auipc	a2,0x3
ffffffffc0203b5e:	38660613          	addi	a2,a2,902 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203b62:	09700593          	li	a1,151
ffffffffc0203b66:	00004517          	auipc	a0,0x4
ffffffffc0203b6a:	17a50513          	addi	a0,a0,378 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203b6e:	90dfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203b72:	00004697          	auipc	a3,0x4
ffffffffc0203b76:	31668693          	addi	a3,a3,790 # ffffffffc0207e88 <default_pmm_manager+0x910>
ffffffffc0203b7a:	00003617          	auipc	a2,0x3
ffffffffc0203b7e:	36660613          	addi	a2,a2,870 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203b82:	09900593          	li	a1,153
ffffffffc0203b86:	00004517          	auipc	a0,0x4
ffffffffc0203b8a:	15a50513          	addi	a0,a0,346 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203b8e:	8edfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203b92:	00004697          	auipc	a3,0x4
ffffffffc0203b96:	30668693          	addi	a3,a3,774 # ffffffffc0207e98 <default_pmm_manager+0x920>
ffffffffc0203b9a:	00003617          	auipc	a2,0x3
ffffffffc0203b9e:	34660613          	addi	a2,a2,838 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203ba2:	09b00593          	li	a1,155
ffffffffc0203ba6:	00004517          	auipc	a0,0x4
ffffffffc0203baa:	13a50513          	addi	a0,a0,314 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203bae:	8cdfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203bb2:	00004697          	auipc	a3,0x4
ffffffffc0203bb6:	2e668693          	addi	a3,a3,742 # ffffffffc0207e98 <default_pmm_manager+0x920>
ffffffffc0203bba:	00003617          	auipc	a2,0x3
ffffffffc0203bbe:	32660613          	addi	a2,a2,806 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203bc2:	09d00593          	li	a1,157
ffffffffc0203bc6:	00004517          	auipc	a0,0x4
ffffffffc0203bca:	11a50513          	addi	a0,a0,282 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203bce:	8adfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203bd2:	00004697          	auipc	a3,0x4
ffffffffc0203bd6:	2a668693          	addi	a3,a3,678 # ffffffffc0207e78 <default_pmm_manager+0x900>
ffffffffc0203bda:	00003617          	auipc	a2,0x3
ffffffffc0203bde:	30660613          	addi	a2,a2,774 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203be2:	09300593          	li	a1,147
ffffffffc0203be6:	00004517          	auipc	a0,0x4
ffffffffc0203bea:	0fa50513          	addi	a0,a0,250 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203bee:	88dfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203bf2 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203bf2:	000b0797          	auipc	a5,0xb0
ffffffffc0203bf6:	c267b783          	ld	a5,-986(a5) # ffffffffc02b3818 <sm>
ffffffffc0203bfa:	6b9c                	ld	a5,16(a5)
ffffffffc0203bfc:	8782                	jr	a5

ffffffffc0203bfe <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203bfe:	000b0797          	auipc	a5,0xb0
ffffffffc0203c02:	c1a7b783          	ld	a5,-998(a5) # ffffffffc02b3818 <sm>
ffffffffc0203c06:	739c                	ld	a5,32(a5)
ffffffffc0203c08:	8782                	jr	a5

ffffffffc0203c0a <swap_out>:
{
ffffffffc0203c0a:	711d                	addi	sp,sp,-96
ffffffffc0203c0c:	ec86                	sd	ra,88(sp)
ffffffffc0203c0e:	e8a2                	sd	s0,80(sp)
ffffffffc0203c10:	e4a6                	sd	s1,72(sp)
ffffffffc0203c12:	e0ca                	sd	s2,64(sp)
ffffffffc0203c14:	fc4e                	sd	s3,56(sp)
ffffffffc0203c16:	f852                	sd	s4,48(sp)
ffffffffc0203c18:	f456                	sd	s5,40(sp)
ffffffffc0203c1a:	f05a                	sd	s6,32(sp)
ffffffffc0203c1c:	ec5e                	sd	s7,24(sp)
ffffffffc0203c1e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203c20:	cde9                	beqz	a1,ffffffffc0203cfa <swap_out+0xf0>
ffffffffc0203c22:	8a2e                	mv	s4,a1
ffffffffc0203c24:	892a                	mv	s2,a0
ffffffffc0203c26:	8ab2                	mv	s5,a2
ffffffffc0203c28:	4401                	li	s0,0
ffffffffc0203c2a:	000b0997          	auipc	s3,0xb0
ffffffffc0203c2e:	bee98993          	addi	s3,s3,-1042 # ffffffffc02b3818 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c32:	00004b17          	auipc	s6,0x4
ffffffffc0203c36:	396b0b13          	addi	s6,s6,918 # ffffffffc0207fc8 <default_pmm_manager+0xa50>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c3a:	00004b97          	auipc	s7,0x4
ffffffffc0203c3e:	376b8b93          	addi	s7,s7,886 # ffffffffc0207fb0 <default_pmm_manager+0xa38>
ffffffffc0203c42:	a825                	j	ffffffffc0203c7a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c44:	67a2                	ld	a5,8(sp)
ffffffffc0203c46:	8626                	mv	a2,s1
ffffffffc0203c48:	85a2                	mv	a1,s0
ffffffffc0203c4a:	7f94                	ld	a3,56(a5)
ffffffffc0203c4c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203c4e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c50:	82b1                	srli	a3,a3,0xc
ffffffffc0203c52:	0685                	addi	a3,a3,1
ffffffffc0203c54:	d2cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c58:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203c5a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c5c:	7d1c                	ld	a5,56(a0)
ffffffffc0203c5e:	83b1                	srli	a5,a5,0xc
ffffffffc0203c60:	0785                	addi	a5,a5,1
ffffffffc0203c62:	07a2                	slli	a5,a5,0x8
ffffffffc0203c64:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203c68:	90afe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203c6c:	01893503          	ld	a0,24(s2)
ffffffffc0203c70:	85a6                	mv	a1,s1
ffffffffc0203c72:	f5eff0ef          	jal	ra,ffffffffc02033d0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c76:	048a0d63          	beq	s4,s0,ffffffffc0203cd0 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c7a:	0009b783          	ld	a5,0(s3)
ffffffffc0203c7e:	8656                	mv	a2,s5
ffffffffc0203c80:	002c                	addi	a1,sp,8
ffffffffc0203c82:	7b9c                	ld	a5,48(a5)
ffffffffc0203c84:	854a                	mv	a0,s2
ffffffffc0203c86:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c88:	e12d                	bnez	a0,ffffffffc0203cea <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203c8a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c8c:	01893503          	ld	a0,24(s2)
ffffffffc0203c90:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c92:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c94:	85a6                	mv	a1,s1
ffffffffc0203c96:	956fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c9a:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c9c:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c9e:	8b85                	andi	a5,a5,1
ffffffffc0203ca0:	cfb9                	beqz	a5,ffffffffc0203cfe <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203ca2:	65a2                	ld	a1,8(sp)
ffffffffc0203ca4:	7d9c                	ld	a5,56(a1)
ffffffffc0203ca6:	83b1                	srli	a5,a5,0xc
ffffffffc0203ca8:	0785                	addi	a5,a5,1
ffffffffc0203caa:	00879513          	slli	a0,a5,0x8
ffffffffc0203cae:	1d0010ef          	jal	ra,ffffffffc0204e7e <swapfs_write>
ffffffffc0203cb2:	d949                	beqz	a0,ffffffffc0203c44 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203cb4:	855e                	mv	a0,s7
ffffffffc0203cb6:	ccafc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203cba:	0009b783          	ld	a5,0(s3)
ffffffffc0203cbe:	6622                	ld	a2,8(sp)
ffffffffc0203cc0:	4681                	li	a3,0
ffffffffc0203cc2:	739c                	ld	a5,32(a5)
ffffffffc0203cc4:	85a6                	mv	a1,s1
ffffffffc0203cc6:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203cc8:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203cca:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203ccc:	fa8a17e3          	bne	s4,s0,ffffffffc0203c7a <swap_out+0x70>
}
ffffffffc0203cd0:	60e6                	ld	ra,88(sp)
ffffffffc0203cd2:	8522                	mv	a0,s0
ffffffffc0203cd4:	6446                	ld	s0,80(sp)
ffffffffc0203cd6:	64a6                	ld	s1,72(sp)
ffffffffc0203cd8:	6906                	ld	s2,64(sp)
ffffffffc0203cda:	79e2                	ld	s3,56(sp)
ffffffffc0203cdc:	7a42                	ld	s4,48(sp)
ffffffffc0203cde:	7aa2                	ld	s5,40(sp)
ffffffffc0203ce0:	7b02                	ld	s6,32(sp)
ffffffffc0203ce2:	6be2                	ld	s7,24(sp)
ffffffffc0203ce4:	6c42                	ld	s8,16(sp)
ffffffffc0203ce6:	6125                	addi	sp,sp,96
ffffffffc0203ce8:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203cea:	85a2                	mv	a1,s0
ffffffffc0203cec:	00004517          	auipc	a0,0x4
ffffffffc0203cf0:	27c50513          	addi	a0,a0,636 # ffffffffc0207f68 <default_pmm_manager+0x9f0>
ffffffffc0203cf4:	c8cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203cf8:	bfe1                	j	ffffffffc0203cd0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203cfa:	4401                	li	s0,0
ffffffffc0203cfc:	bfd1                	j	ffffffffc0203cd0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203cfe:	00004697          	auipc	a3,0x4
ffffffffc0203d02:	29a68693          	addi	a3,a3,666 # ffffffffc0207f98 <default_pmm_manager+0xa20>
ffffffffc0203d06:	00003617          	auipc	a2,0x3
ffffffffc0203d0a:	1da60613          	addi	a2,a2,474 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203d0e:	06800593          	li	a1,104
ffffffffc0203d12:	00004517          	auipc	a0,0x4
ffffffffc0203d16:	fce50513          	addi	a0,a0,-50 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203d1a:	f60fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d1e <swap_in>:
{
ffffffffc0203d1e:	7179                	addi	sp,sp,-48
ffffffffc0203d20:	e84a                	sd	s2,16(sp)
ffffffffc0203d22:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203d24:	4505                	li	a0,1
{
ffffffffc0203d26:	ec26                	sd	s1,24(sp)
ffffffffc0203d28:	e44e                	sd	s3,8(sp)
ffffffffc0203d2a:	f406                	sd	ra,40(sp)
ffffffffc0203d2c:	f022                	sd	s0,32(sp)
ffffffffc0203d2e:	84ae                	mv	s1,a1
ffffffffc0203d30:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203d32:	faffd0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203d36:	c129                	beqz	a0,ffffffffc0203d78 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d38:	842a                	mv	s0,a0
ffffffffc0203d3a:	01893503          	ld	a0,24(s2)
ffffffffc0203d3e:	4601                	li	a2,0
ffffffffc0203d40:	85a6                	mv	a1,s1
ffffffffc0203d42:	8aafe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203d46:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203d48:	6108                	ld	a0,0(a0)
ffffffffc0203d4a:	85a2                	mv	a1,s0
ffffffffc0203d4c:	0a4010ef          	jal	ra,ffffffffc0204df0 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203d50:	00093583          	ld	a1,0(s2)
ffffffffc0203d54:	8626                	mv	a2,s1
ffffffffc0203d56:	00004517          	auipc	a0,0x4
ffffffffc0203d5a:	2c250513          	addi	a0,a0,706 # ffffffffc0208018 <default_pmm_manager+0xaa0>
ffffffffc0203d5e:	81a1                	srli	a1,a1,0x8
ffffffffc0203d60:	c20fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203d64:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203d66:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203d6a:	7402                	ld	s0,32(sp)
ffffffffc0203d6c:	64e2                	ld	s1,24(sp)
ffffffffc0203d6e:	6942                	ld	s2,16(sp)
ffffffffc0203d70:	69a2                	ld	s3,8(sp)
ffffffffc0203d72:	4501                	li	a0,0
ffffffffc0203d74:	6145                	addi	sp,sp,48
ffffffffc0203d76:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d78:	00004697          	auipc	a3,0x4
ffffffffc0203d7c:	29068693          	addi	a3,a3,656 # ffffffffc0208008 <default_pmm_manager+0xa90>
ffffffffc0203d80:	00003617          	auipc	a2,0x3
ffffffffc0203d84:	16060613          	addi	a2,a2,352 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203d88:	07e00593          	li	a1,126
ffffffffc0203d8c:	00004517          	auipc	a0,0x4
ffffffffc0203d90:	f5450513          	addi	a0,a0,-172 # ffffffffc0207ce0 <default_pmm_manager+0x768>
ffffffffc0203d94:	ee6fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d98 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d98:	000ac797          	auipc	a5,0xac
ffffffffc0203d9c:	a0878793          	addi	a5,a5,-1528 # ffffffffc02af7a0 <pra_list_head>
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc0203da0:	f51c                	sd	a5,40(a0)
ffffffffc0203da2:	e79c                	sd	a5,8(a5)
ffffffffc0203da4:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc0203da6:	000b0717          	auipc	a4,0xb0
ffffffffc0203daa:	a8f73123          	sd	a5,-1406(a4) # ffffffffc02b3828 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203dae:	4501                	li	a0,0
ffffffffc0203db0:	8082                	ret

ffffffffc0203db2 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203db2:	4501                	li	a0,0
ffffffffc0203db4:	8082                	ret

ffffffffc0203db6 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203db6:	4501                	li	a0,0
ffffffffc0203db8:	8082                	ret

ffffffffc0203dba <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203dba:	4501                	li	a0,0
ffffffffc0203dbc:	8082                	ret

ffffffffc0203dbe <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203dbe:	711d                	addi	sp,sp,-96
ffffffffc0203dc0:	fc4e                	sd	s3,56(sp)
ffffffffc0203dc2:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dc4:	00004517          	auipc	a0,0x4
ffffffffc0203dc8:	29450513          	addi	a0,a0,660 # ffffffffc0208058 <default_pmm_manager+0xae0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dcc:	698d                	lui	s3,0x3
ffffffffc0203dce:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203dd0:	e0ca                	sd	s2,64(sp)
ffffffffc0203dd2:	ec86                	sd	ra,88(sp)
ffffffffc0203dd4:	e8a2                	sd	s0,80(sp)
ffffffffc0203dd6:	e4a6                	sd	s1,72(sp)
ffffffffc0203dd8:	f456                	sd	s5,40(sp)
ffffffffc0203dda:	f05a                	sd	s6,32(sp)
ffffffffc0203ddc:	ec5e                	sd	s7,24(sp)
ffffffffc0203dde:	e862                	sd	s8,16(sp)
ffffffffc0203de0:	e466                	sd	s9,8(sp)
ffffffffc0203de2:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203de4:	b9cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203de8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc0203dec:	000b0917          	auipc	s2,0xb0
ffffffffc0203df0:	a4c92903          	lw	s2,-1460(s2) # ffffffffc02b3838 <pgfault_num>
ffffffffc0203df4:	4791                	li	a5,4
ffffffffc0203df6:	14f91e63          	bne	s2,a5,ffffffffc0203f52 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dfa:	00004517          	auipc	a0,0x4
ffffffffc0203dfe:	29e50513          	addi	a0,a0,670 # ffffffffc0208098 <default_pmm_manager+0xb20>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e02:	6a85                	lui	s5,0x1
ffffffffc0203e04:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e06:	b7afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203e0a:	000b0417          	auipc	s0,0xb0
ffffffffc0203e0e:	a2e40413          	addi	s0,s0,-1490 # ffffffffc02b3838 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e12:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc0203e16:	4004                	lw	s1,0(s0)
ffffffffc0203e18:	2481                	sext.w	s1,s1
ffffffffc0203e1a:	2b249c63          	bne	s1,s2,ffffffffc02040d2 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e1e:	00004517          	auipc	a0,0x4
ffffffffc0203e22:	2a250513          	addi	a0,a0,674 # ffffffffc02080c0 <default_pmm_manager+0xb48>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e26:	6b91                	lui	s7,0x4
ffffffffc0203e28:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e2a:	b56fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e2e:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc0203e32:	00042903          	lw	s2,0(s0)
ffffffffc0203e36:	2901                	sext.w	s2,s2
ffffffffc0203e38:	26991d63          	bne	s2,s1,ffffffffc02040b2 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e3c:	00004517          	auipc	a0,0x4
ffffffffc0203e40:	2ac50513          	addi	a0,a0,684 # ffffffffc02080e8 <default_pmm_manager+0xb70>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e44:	6c89                	lui	s9,0x2
ffffffffc0203e46:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e48:	b38fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e4c:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0203e50:	401c                	lw	a5,0(s0)
ffffffffc0203e52:	2781                	sext.w	a5,a5
ffffffffc0203e54:	23279f63          	bne	a5,s2,ffffffffc0204092 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e58:	00004517          	auipc	a0,0x4
ffffffffc0203e5c:	2b850513          	addi	a0,a0,696 # ffffffffc0208110 <default_pmm_manager+0xb98>
ffffffffc0203e60:	b20fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e64:	6795                	lui	a5,0x5
ffffffffc0203e66:	4739                	li	a4,14
ffffffffc0203e68:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc0203e6c:	4004                	lw	s1,0(s0)
ffffffffc0203e6e:	4795                	li	a5,5
ffffffffc0203e70:	2481                	sext.w	s1,s1
ffffffffc0203e72:	20f49063          	bne	s1,a5,ffffffffc0204072 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e76:	00004517          	auipc	a0,0x4
ffffffffc0203e7a:	27250513          	addi	a0,a0,626 # ffffffffc02080e8 <default_pmm_manager+0xb70>
ffffffffc0203e7e:	b02fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e82:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203e86:	401c                	lw	a5,0(s0)
ffffffffc0203e88:	2781                	sext.w	a5,a5
ffffffffc0203e8a:	1c979463          	bne	a5,s1,ffffffffc0204052 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e8e:	00004517          	auipc	a0,0x4
ffffffffc0203e92:	20a50513          	addi	a0,a0,522 # ffffffffc0208098 <default_pmm_manager+0xb20>
ffffffffc0203e96:	aeafc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e9a:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e9e:	401c                	lw	a5,0(s0)
ffffffffc0203ea0:	4719                	li	a4,6
ffffffffc0203ea2:	2781                	sext.w	a5,a5
ffffffffc0203ea4:	18e79763          	bne	a5,a4,ffffffffc0204032 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ea8:	00004517          	auipc	a0,0x4
ffffffffc0203eac:	24050513          	addi	a0,a0,576 # ffffffffc02080e8 <default_pmm_manager+0xb70>
ffffffffc0203eb0:	ad0fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203eb4:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203eb8:	401c                	lw	a5,0(s0)
ffffffffc0203eba:	471d                	li	a4,7
ffffffffc0203ebc:	2781                	sext.w	a5,a5
ffffffffc0203ebe:	14e79a63          	bne	a5,a4,ffffffffc0204012 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203ec2:	00004517          	auipc	a0,0x4
ffffffffc0203ec6:	19650513          	addi	a0,a0,406 # ffffffffc0208058 <default_pmm_manager+0xae0>
ffffffffc0203eca:	ab6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ece:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203ed2:	401c                	lw	a5,0(s0)
ffffffffc0203ed4:	4721                	li	a4,8
ffffffffc0203ed6:	2781                	sext.w	a5,a5
ffffffffc0203ed8:	10e79d63          	bne	a5,a4,ffffffffc0203ff2 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203edc:	00004517          	auipc	a0,0x4
ffffffffc0203ee0:	1e450513          	addi	a0,a0,484 # ffffffffc02080c0 <default_pmm_manager+0xb48>
ffffffffc0203ee4:	a9cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ee8:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203eec:	401c                	lw	a5,0(s0)
ffffffffc0203eee:	4725                	li	a4,9
ffffffffc0203ef0:	2781                	sext.w	a5,a5
ffffffffc0203ef2:	0ee79063          	bne	a5,a4,ffffffffc0203fd2 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203ef6:	00004517          	auipc	a0,0x4
ffffffffc0203efa:	21a50513          	addi	a0,a0,538 # ffffffffc0208110 <default_pmm_manager+0xb98>
ffffffffc0203efe:	a82fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203f02:	6795                	lui	a5,0x5
ffffffffc0203f04:	4739                	li	a4,14
ffffffffc0203f06:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc0203f0a:	4004                	lw	s1,0(s0)
ffffffffc0203f0c:	47a9                	li	a5,10
ffffffffc0203f0e:	2481                	sext.w	s1,s1
ffffffffc0203f10:	0af49163          	bne	s1,a5,ffffffffc0203fb2 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203f14:	00004517          	auipc	a0,0x4
ffffffffc0203f18:	18450513          	addi	a0,a0,388 # ffffffffc0208098 <default_pmm_manager+0xb20>
ffffffffc0203f1c:	a64fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f20:	6785                	lui	a5,0x1
ffffffffc0203f22:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203f26:	06979663          	bne	a5,s1,ffffffffc0203f92 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203f2a:	401c                	lw	a5,0(s0)
ffffffffc0203f2c:	472d                	li	a4,11
ffffffffc0203f2e:	2781                	sext.w	a5,a5
ffffffffc0203f30:	04e79163          	bne	a5,a4,ffffffffc0203f72 <_fifo_check_swap+0x1b4>
}
ffffffffc0203f34:	60e6                	ld	ra,88(sp)
ffffffffc0203f36:	6446                	ld	s0,80(sp)
ffffffffc0203f38:	64a6                	ld	s1,72(sp)
ffffffffc0203f3a:	6906                	ld	s2,64(sp)
ffffffffc0203f3c:	79e2                	ld	s3,56(sp)
ffffffffc0203f3e:	7a42                	ld	s4,48(sp)
ffffffffc0203f40:	7aa2                	ld	s5,40(sp)
ffffffffc0203f42:	7b02                	ld	s6,32(sp)
ffffffffc0203f44:	6be2                	ld	s7,24(sp)
ffffffffc0203f46:	6c42                	ld	s8,16(sp)
ffffffffc0203f48:	6ca2                	ld	s9,8(sp)
ffffffffc0203f4a:	6d02                	ld	s10,0(sp)
ffffffffc0203f4c:	4501                	li	a0,0
ffffffffc0203f4e:	6125                	addi	sp,sp,96
ffffffffc0203f50:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203f52:	00004697          	auipc	a3,0x4
ffffffffc0203f56:	f5668693          	addi	a3,a3,-170 # ffffffffc0207ea8 <default_pmm_manager+0x930>
ffffffffc0203f5a:	00003617          	auipc	a2,0x3
ffffffffc0203f5e:	f8660613          	addi	a2,a2,-122 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203f62:	05b00593          	li	a1,91
ffffffffc0203f66:	00004517          	auipc	a0,0x4
ffffffffc0203f6a:	11a50513          	addi	a0,a0,282 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0203f6e:	d0cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203f72:	00004697          	auipc	a3,0x4
ffffffffc0203f76:	24e68693          	addi	a3,a3,590 # ffffffffc02081c0 <default_pmm_manager+0xc48>
ffffffffc0203f7a:	00003617          	auipc	a2,0x3
ffffffffc0203f7e:	f6660613          	addi	a2,a2,-154 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203f82:	07d00593          	li	a1,125
ffffffffc0203f86:	00004517          	auipc	a0,0x4
ffffffffc0203f8a:	0fa50513          	addi	a0,a0,250 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0203f8e:	cecfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f92:	00004697          	auipc	a3,0x4
ffffffffc0203f96:	20668693          	addi	a3,a3,518 # ffffffffc0208198 <default_pmm_manager+0xc20>
ffffffffc0203f9a:	00003617          	auipc	a2,0x3
ffffffffc0203f9e:	f4660613          	addi	a2,a2,-186 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203fa2:	07b00593          	li	a1,123
ffffffffc0203fa6:	00004517          	auipc	a0,0x4
ffffffffc0203faa:	0da50513          	addi	a0,a0,218 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0203fae:	cccfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc0203fb2:	00004697          	auipc	a3,0x4
ffffffffc0203fb6:	1d668693          	addi	a3,a3,470 # ffffffffc0208188 <default_pmm_manager+0xc10>
ffffffffc0203fba:	00003617          	auipc	a2,0x3
ffffffffc0203fbe:	f2660613          	addi	a2,a2,-218 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203fc2:	07900593          	li	a1,121
ffffffffc0203fc6:	00004517          	auipc	a0,0x4
ffffffffc0203fca:	0ba50513          	addi	a0,a0,186 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0203fce:	cacfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc0203fd2:	00004697          	auipc	a3,0x4
ffffffffc0203fd6:	1a668693          	addi	a3,a3,422 # ffffffffc0208178 <default_pmm_manager+0xc00>
ffffffffc0203fda:	00003617          	auipc	a2,0x3
ffffffffc0203fde:	f0660613          	addi	a2,a2,-250 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0203fe2:	07600593          	li	a1,118
ffffffffc0203fe6:	00004517          	auipc	a0,0x4
ffffffffc0203fea:	09a50513          	addi	a0,a0,154 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0203fee:	c8cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc0203ff2:	00004697          	auipc	a3,0x4
ffffffffc0203ff6:	17668693          	addi	a3,a3,374 # ffffffffc0208168 <default_pmm_manager+0xbf0>
ffffffffc0203ffa:	00003617          	auipc	a2,0x3
ffffffffc0203ffe:	ee660613          	addi	a2,a2,-282 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204002:	07300593          	li	a1,115
ffffffffc0204006:	00004517          	auipc	a0,0x4
ffffffffc020400a:	07a50513          	addi	a0,a0,122 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc020400e:	c6cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc0204012:	00004697          	auipc	a3,0x4
ffffffffc0204016:	14668693          	addi	a3,a3,326 # ffffffffc0208158 <default_pmm_manager+0xbe0>
ffffffffc020401a:	00003617          	auipc	a2,0x3
ffffffffc020401e:	ec660613          	addi	a2,a2,-314 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204022:	07000593          	li	a1,112
ffffffffc0204026:	00004517          	auipc	a0,0x4
ffffffffc020402a:	05a50513          	addi	a0,a0,90 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc020402e:	c4cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc0204032:	00004697          	auipc	a3,0x4
ffffffffc0204036:	11668693          	addi	a3,a3,278 # ffffffffc0208148 <default_pmm_manager+0xbd0>
ffffffffc020403a:	00003617          	auipc	a2,0x3
ffffffffc020403e:	ea660613          	addi	a2,a2,-346 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204042:	06d00593          	li	a1,109
ffffffffc0204046:	00004517          	auipc	a0,0x4
ffffffffc020404a:	03a50513          	addi	a0,a0,58 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc020404e:	c2cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0204052:	00004697          	auipc	a3,0x4
ffffffffc0204056:	0e668693          	addi	a3,a3,230 # ffffffffc0208138 <default_pmm_manager+0xbc0>
ffffffffc020405a:	00003617          	auipc	a2,0x3
ffffffffc020405e:	e8660613          	addi	a2,a2,-378 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204062:	06a00593          	li	a1,106
ffffffffc0204066:	00004517          	auipc	a0,0x4
ffffffffc020406a:	01a50513          	addi	a0,a0,26 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc020406e:	c0cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0204072:	00004697          	auipc	a3,0x4
ffffffffc0204076:	0c668693          	addi	a3,a3,198 # ffffffffc0208138 <default_pmm_manager+0xbc0>
ffffffffc020407a:	00003617          	auipc	a2,0x3
ffffffffc020407e:	e6660613          	addi	a2,a2,-410 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204082:	06700593          	li	a1,103
ffffffffc0204086:	00004517          	auipc	a0,0x4
ffffffffc020408a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc020408e:	becfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0204092:	00004697          	auipc	a3,0x4
ffffffffc0204096:	e1668693          	addi	a3,a3,-490 # ffffffffc0207ea8 <default_pmm_manager+0x930>
ffffffffc020409a:	00003617          	auipc	a2,0x3
ffffffffc020409e:	e4660613          	addi	a2,a2,-442 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02040a2:	06400593          	li	a1,100
ffffffffc02040a6:	00004517          	auipc	a0,0x4
ffffffffc02040aa:	fda50513          	addi	a0,a0,-38 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc02040ae:	bccfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc02040b2:	00004697          	auipc	a3,0x4
ffffffffc02040b6:	df668693          	addi	a3,a3,-522 # ffffffffc0207ea8 <default_pmm_manager+0x930>
ffffffffc02040ba:	00003617          	auipc	a2,0x3
ffffffffc02040be:	e2660613          	addi	a2,a2,-474 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02040c2:	06100593          	li	a1,97
ffffffffc02040c6:	00004517          	auipc	a0,0x4
ffffffffc02040ca:	fba50513          	addi	a0,a0,-70 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc02040ce:	bacfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc02040d2:	00004697          	auipc	a3,0x4
ffffffffc02040d6:	dd668693          	addi	a3,a3,-554 # ffffffffc0207ea8 <default_pmm_manager+0x930>
ffffffffc02040da:	00003617          	auipc	a2,0x3
ffffffffc02040de:	e0660613          	addi	a2,a2,-506 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02040e2:	05e00593          	li	a1,94
ffffffffc02040e6:	00004517          	auipc	a0,0x4
ffffffffc02040ea:	f9a50513          	addi	a0,a0,-102 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc02040ee:	b8cfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02040f2 <_fifo_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040f2:	751c                	ld	a5,40(a0)
{
ffffffffc02040f4:	1101                	addi	sp,sp,-32
ffffffffc02040f6:	ec06                	sd	ra,24(sp)
ffffffffc02040f8:	e822                	sd	s0,16(sp)
ffffffffc02040fa:	e426                	sd	s1,8(sp)
    assert(head != NULL);
ffffffffc02040fc:	cba5                	beqz	a5,ffffffffc020416c <_fifo_swap_out_victim+0x7a>
    assert(in_tick==0);
ffffffffc02040fe:	e639                	bnez	a2,ffffffffc020414c <_fifo_swap_out_victim+0x5a>
ffffffffc0204100:	842e                	mv	s0,a1
    return listelm->prev;
ffffffffc0204102:	638c                	ld	a1,0(a5)
    curr_ptr = list_prev(head);
ffffffffc0204104:	000af497          	auipc	s1,0xaf
ffffffffc0204108:	72448493          	addi	s1,s1,1828 # ffffffffc02b3828 <curr_ptr>
ffffffffc020410c:	e08c                	sd	a1,0(s1)
    if (curr_ptr != head)
ffffffffc020410e:	02b78763          	beq	a5,a1,ffffffffc020413c <_fifo_swap_out_victim+0x4a>
        cprintf("curr_ptr 0xffffffff%08x\n", curr_ptr);
ffffffffc0204112:	00004517          	auipc	a0,0x4
ffffffffc0204116:	0de50513          	addi	a0,a0,222 # ffffffffc02081f0 <default_pmm_manager+0xc78>
ffffffffc020411a:	866fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
        list_del(curr_ptr);
ffffffffc020411e:	609c                	ld	a5,0(s1)
}
ffffffffc0204120:	60e2                	ld	ra,24(sp)
ffffffffc0204122:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204124:	6394                	ld	a3,0(a5)
ffffffffc0204126:	6798                	ld	a4,8(a5)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc0204128:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020412c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020412e:	e314                	sd	a3,0(a4)
ffffffffc0204130:	e01c                	sd	a5,0(s0)
}
ffffffffc0204132:	6442                	ld	s0,16(sp)
        curr_ptr = list_next(curr_ptr);
ffffffffc0204134:	e098                	sd	a4,0(s1)
}
ffffffffc0204136:	64a2                	ld	s1,8(sp)
ffffffffc0204138:	6105                	addi	sp,sp,32
ffffffffc020413a:	8082                	ret
ffffffffc020413c:	60e2                	ld	ra,24(sp)
        *ptr_page = NULL;
ffffffffc020413e:	00043023          	sd	zero,0(s0)
}
ffffffffc0204142:	6442                	ld	s0,16(sp)
ffffffffc0204144:	64a2                	ld	s1,8(sp)
ffffffffc0204146:	4501                	li	a0,0
ffffffffc0204148:	6105                	addi	sp,sp,32
ffffffffc020414a:	8082                	ret
    assert(in_tick==0);
ffffffffc020414c:	00004697          	auipc	a3,0x4
ffffffffc0204150:	09468693          	addi	a3,a3,148 # ffffffffc02081e0 <default_pmm_manager+0xc68>
ffffffffc0204154:	00003617          	auipc	a2,0x3
ffffffffc0204158:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020415c:	04300593          	li	a1,67
ffffffffc0204160:	00004517          	auipc	a0,0x4
ffffffffc0204164:	f2050513          	addi	a0,a0,-224 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0204168:	b12fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(head != NULL);
ffffffffc020416c:	00004697          	auipc	a3,0x4
ffffffffc0204170:	06468693          	addi	a3,a3,100 # ffffffffc02081d0 <default_pmm_manager+0xc58>
ffffffffc0204174:	00003617          	auipc	a2,0x3
ffffffffc0204178:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020417c:	04200593          	li	a1,66
ffffffffc0204180:	00004517          	auipc	a0,0x4
ffffffffc0204184:	f0050513          	addi	a0,a0,-256 # ffffffffc0208080 <default_pmm_manager+0xb08>
ffffffffc0204188:	af2fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020418c <_fifo_map_swappable>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc020418c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020418e:	cb91                	beqz	a5,ffffffffc02041a2 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0204190:	6794                	ld	a3,8(a5)
ffffffffc0204192:	02860713          	addi	a4,a2,40
}
ffffffffc0204196:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0204198:	e298                	sd	a4,0(a3)
ffffffffc020419a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020419c:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc020419e:	f61c                	sd	a5,40(a2)
ffffffffc02041a0:	8082                	ret
{
ffffffffc02041a2:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02041a4:	00004697          	auipc	a3,0x4
ffffffffc02041a8:	06c68693          	addi	a3,a3,108 # ffffffffc0208210 <default_pmm_manager+0xc98>
ffffffffc02041ac:	00003617          	auipc	a2,0x3
ffffffffc02041b0:	d3460613          	addi	a2,a2,-716 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02041b4:	03300593          	li	a1,51
ffffffffc02041b8:	00004517          	auipc	a0,0x4
ffffffffc02041bc:	ec850513          	addi	a0,a0,-312 # ffffffffc0208080 <default_pmm_manager+0xb08>
{
ffffffffc02041c0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02041c2:	ab8fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02041c6 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02041c6:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02041c8:	00004697          	auipc	a3,0x4
ffffffffc02041cc:	08068693          	addi	a3,a3,128 # ffffffffc0208248 <default_pmm_manager+0xcd0>
ffffffffc02041d0:	00003617          	auipc	a2,0x3
ffffffffc02041d4:	d1060613          	addi	a2,a2,-752 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02041d8:	06d00593          	li	a1,109
ffffffffc02041dc:	00004517          	auipc	a0,0x4
ffffffffc02041e0:	08c50513          	addi	a0,a0,140 # ffffffffc0208268 <default_pmm_manager+0xcf0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02041e4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02041e6:	a94fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02041ea <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02041ea:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02041ec:	00003617          	auipc	a2,0x3
ffffffffc02041f0:	49460613          	addi	a2,a2,1172 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc02041f4:	06200593          	li	a1,98
ffffffffc02041f8:	00003517          	auipc	a0,0x3
ffffffffc02041fc:	3e050513          	addi	a0,a0,992 # ffffffffc02075d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0204200:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0204202:	a78fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204206 <mm_create>:
mm_create(void) {
ffffffffc0204206:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204208:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020420c:	e022                	sd	s0,0(sp)
ffffffffc020420e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204210:	8f3fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204214:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204216:	c505                	beqz	a0,ffffffffc020423e <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0204218:	e408                	sd	a0,8(s0)
ffffffffc020421a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020421c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204220:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204224:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204228:	000af797          	auipc	a5,0xaf
ffffffffc020422c:	5f87a783          	lw	a5,1528(a5) # ffffffffc02b3820 <swap_init_ok>
ffffffffc0204230:	ef81                	bnez	a5,ffffffffc0204248 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204232:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204236:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020423a:	02043c23          	sd	zero,56(s0)
}
ffffffffc020423e:	60a2                	ld	ra,8(sp)
ffffffffc0204240:	8522                	mv	a0,s0
ffffffffc0204242:	6402                	ld	s0,0(sp)
ffffffffc0204244:	0141                	addi	sp,sp,16
ffffffffc0204246:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204248:	9abff0ef          	jal	ra,ffffffffc0203bf2 <swap_init_mm>
ffffffffc020424c:	b7ed                	j	ffffffffc0204236 <mm_create+0x30>

ffffffffc020424e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020424e:	1101                	addi	sp,sp,-32
ffffffffc0204250:	e04a                	sd	s2,0(sp)
ffffffffc0204252:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204254:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204258:	e822                	sd	s0,16(sp)
ffffffffc020425a:	e426                	sd	s1,8(sp)
ffffffffc020425c:	ec06                	sd	ra,24(sp)
ffffffffc020425e:	84ae                	mv	s1,a1
ffffffffc0204260:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204262:	8a1fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
    if (vma != NULL) {
ffffffffc0204266:	c509                	beqz	a0,ffffffffc0204270 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0204268:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020426c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020426e:	cd00                	sw	s0,24(a0)
}
ffffffffc0204270:	60e2                	ld	ra,24(sp)
ffffffffc0204272:	6442                	ld	s0,16(sp)
ffffffffc0204274:	64a2                	ld	s1,8(sp)
ffffffffc0204276:	6902                	ld	s2,0(sp)
ffffffffc0204278:	6105                	addi	sp,sp,32
ffffffffc020427a:	8082                	ret

ffffffffc020427c <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020427c:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc020427e:	c505                	beqz	a0,ffffffffc02042a6 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0204280:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204282:	c501                	beqz	a0,ffffffffc020428a <find_vma+0xe>
ffffffffc0204284:	651c                	ld	a5,8(a0)
ffffffffc0204286:	02f5f263          	bgeu	a1,a5,ffffffffc02042aa <find_vma+0x2e>
    return listelm->next;
ffffffffc020428a:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020428c:	00f68d63          	beq	a3,a5,ffffffffc02042a6 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204290:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204294:	00e5e663          	bltu	a1,a4,ffffffffc02042a0 <find_vma+0x24>
ffffffffc0204298:	ff07b703          	ld	a4,-16(a5)
ffffffffc020429c:	00e5ec63          	bltu	a1,a4,ffffffffc02042b4 <find_vma+0x38>
ffffffffc02042a0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02042a2:	fef697e3          	bne	a3,a5,ffffffffc0204290 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02042a6:	4501                	li	a0,0
}
ffffffffc02042a8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02042aa:	691c                	ld	a5,16(a0)
ffffffffc02042ac:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020428a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02042b0:	ea88                	sd	a0,16(a3)
ffffffffc02042b2:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc02042b4:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02042b8:	ea88                	sd	a0,16(a3)
ffffffffc02042ba:	8082                	ret

ffffffffc02042bc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02042bc:	6590                	ld	a2,8(a1)
ffffffffc02042be:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8ba0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02042c2:	1141                	addi	sp,sp,-16
ffffffffc02042c4:	e406                	sd	ra,8(sp)
ffffffffc02042c6:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02042c8:	01066763          	bltu	a2,a6,ffffffffc02042d6 <insert_vma_struct+0x1a>
ffffffffc02042cc:	a085                	j	ffffffffc020432c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02042ce:	fe87b703          	ld	a4,-24(a5)
ffffffffc02042d2:	04e66863          	bltu	a2,a4,ffffffffc0204322 <insert_vma_struct+0x66>
ffffffffc02042d6:	86be                	mv	a3,a5
ffffffffc02042d8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02042da:	fef51ae3          	bne	a0,a5,ffffffffc02042ce <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02042de:	02a68463          	beq	a3,a0,ffffffffc0204306 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02042e2:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02042e6:	fe86b883          	ld	a7,-24(a3)
ffffffffc02042ea:	08e8f163          	bgeu	a7,a4,ffffffffc020436c <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042ee:	04e66f63          	bltu	a2,a4,ffffffffc020434c <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02042f2:	00f50a63          	beq	a0,a5,ffffffffc0204306 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02042f6:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042fa:	05076963          	bltu	a4,a6,ffffffffc020434c <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02042fe:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204302:	02c77363          	bgeu	a4,a2,ffffffffc0204328 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204306:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0204308:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020430a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020430e:	e390                	sd	a2,0(a5)
ffffffffc0204310:	e690                	sd	a2,8(a3)
}
ffffffffc0204312:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204314:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204316:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0204318:	0017079b          	addiw	a5,a4,1
ffffffffc020431c:	d11c                	sw	a5,32(a0)
}
ffffffffc020431e:	0141                	addi	sp,sp,16
ffffffffc0204320:	8082                	ret
    if (le_prev != list) {
ffffffffc0204322:	fca690e3          	bne	a3,a0,ffffffffc02042e2 <insert_vma_struct+0x26>
ffffffffc0204326:	bfd1                	j	ffffffffc02042fa <insert_vma_struct+0x3e>
ffffffffc0204328:	e9fff0ef          	jal	ra,ffffffffc02041c6 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020432c:	00004697          	auipc	a3,0x4
ffffffffc0204330:	f4c68693          	addi	a3,a3,-180 # ffffffffc0208278 <default_pmm_manager+0xd00>
ffffffffc0204334:	00003617          	auipc	a2,0x3
ffffffffc0204338:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020433c:	07400593          	li	a1,116
ffffffffc0204340:	00004517          	auipc	a0,0x4
ffffffffc0204344:	f2850513          	addi	a0,a0,-216 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204348:	932fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020434c:	00004697          	auipc	a3,0x4
ffffffffc0204350:	f6c68693          	addi	a3,a3,-148 # ffffffffc02082b8 <default_pmm_manager+0xd40>
ffffffffc0204354:	00003617          	auipc	a2,0x3
ffffffffc0204358:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020435c:	06c00593          	li	a1,108
ffffffffc0204360:	00004517          	auipc	a0,0x4
ffffffffc0204364:	f0850513          	addi	a0,a0,-248 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204368:	912fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020436c:	00004697          	auipc	a3,0x4
ffffffffc0204370:	f2c68693          	addi	a3,a3,-212 # ffffffffc0208298 <default_pmm_manager+0xd20>
ffffffffc0204374:	00003617          	auipc	a2,0x3
ffffffffc0204378:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020437c:	06b00593          	li	a1,107
ffffffffc0204380:	00004517          	auipc	a0,0x4
ffffffffc0204384:	ee850513          	addi	a0,a0,-280 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204388:	8f2fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020438c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020438c:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020438e:	1141                	addi	sp,sp,-16
ffffffffc0204390:	e406                	sd	ra,8(sp)
ffffffffc0204392:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204394:	e78d                	bnez	a5,ffffffffc02043be <mm_destroy+0x32>
ffffffffc0204396:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204398:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020439a:	00a40c63          	beq	s0,a0,ffffffffc02043b2 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020439e:	6118                	ld	a4,0(a0)
ffffffffc02043a0:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02043a2:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02043a4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02043a6:	e398                	sd	a4,0(a5)
ffffffffc02043a8:	80bfd0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    return listelm->next;
ffffffffc02043ac:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02043ae:	fea418e3          	bne	s0,a0,ffffffffc020439e <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02043b2:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02043b4:	6402                	ld	s0,0(sp)
ffffffffc02043b6:	60a2                	ld	ra,8(sp)
ffffffffc02043b8:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02043ba:	ff8fd06f          	j	ffffffffc0201bb2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02043be:	00004697          	auipc	a3,0x4
ffffffffc02043c2:	f1a68693          	addi	a3,a3,-230 # ffffffffc02082d8 <default_pmm_manager+0xd60>
ffffffffc02043c6:	00003617          	auipc	a2,0x3
ffffffffc02043ca:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02043ce:	09400593          	li	a1,148
ffffffffc02043d2:	00004517          	auipc	a0,0x4
ffffffffc02043d6:	e9650513          	addi	a0,a0,-362 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02043da:	8a0fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02043de <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc02043de:	7139                	addi	sp,sp,-64
ffffffffc02043e0:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043e2:	6405                	lui	s0,0x1
ffffffffc02043e4:	147d                	addi	s0,s0,-1
ffffffffc02043e6:	77fd                	lui	a5,0xfffff
ffffffffc02043e8:	9622                	add	a2,a2,s0
ffffffffc02043ea:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc02043ec:	f426                	sd	s1,40(sp)
ffffffffc02043ee:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043f0:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc02043f4:	f04a                	sd	s2,32(sp)
ffffffffc02043f6:	ec4e                	sd	s3,24(sp)
ffffffffc02043f8:	e852                	sd	s4,16(sp)
ffffffffc02043fa:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc02043fc:	002005b7          	lui	a1,0x200
ffffffffc0204400:	00f67433          	and	s0,a2,a5
ffffffffc0204404:	06b4e363          	bltu	s1,a1,ffffffffc020446a <mm_map+0x8c>
ffffffffc0204408:	0684f163          	bgeu	s1,s0,ffffffffc020446a <mm_map+0x8c>
ffffffffc020440c:	4785                	li	a5,1
ffffffffc020440e:	07fe                	slli	a5,a5,0x1f
ffffffffc0204410:	0487ed63          	bltu	a5,s0,ffffffffc020446a <mm_map+0x8c>
ffffffffc0204414:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204416:	cd21                	beqz	a0,ffffffffc020446e <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204418:	85a6                	mv	a1,s1
ffffffffc020441a:	8ab6                	mv	s5,a3
ffffffffc020441c:	8a3a                	mv	s4,a4
ffffffffc020441e:	e5fff0ef          	jal	ra,ffffffffc020427c <find_vma>
ffffffffc0204422:	c501                	beqz	a0,ffffffffc020442a <mm_map+0x4c>
ffffffffc0204424:	651c                	ld	a5,8(a0)
ffffffffc0204426:	0487e263          	bltu	a5,s0,ffffffffc020446a <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020442a:	03000513          	li	a0,48
ffffffffc020442e:	ed4fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204432:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204434:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204436:	02090163          	beqz	s2,ffffffffc0204458 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020443a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020443c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204440:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204444:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204448:	85ca                	mv	a1,s2
ffffffffc020444a:	e73ff0ef          	jal	ra,ffffffffc02042bc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020444e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204450:	000a0463          	beqz	s4,ffffffffc0204458 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0204454:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204458:	70e2                	ld	ra,56(sp)
ffffffffc020445a:	7442                	ld	s0,48(sp)
ffffffffc020445c:	74a2                	ld	s1,40(sp)
ffffffffc020445e:	7902                	ld	s2,32(sp)
ffffffffc0204460:	69e2                	ld	s3,24(sp)
ffffffffc0204462:	6a42                	ld	s4,16(sp)
ffffffffc0204464:	6aa2                	ld	s5,8(sp)
ffffffffc0204466:	6121                	addi	sp,sp,64
ffffffffc0204468:	8082                	ret
        return -E_INVAL;
ffffffffc020446a:	5575                	li	a0,-3
ffffffffc020446c:	b7f5                	j	ffffffffc0204458 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020446e:	00004697          	auipc	a3,0x4
ffffffffc0204472:	8c268693          	addi	a3,a3,-1854 # ffffffffc0207d30 <default_pmm_manager+0x7b8>
ffffffffc0204476:	00003617          	auipc	a2,0x3
ffffffffc020447a:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020447e:	0a700593          	li	a1,167
ffffffffc0204482:	00004517          	auipc	a0,0x4
ffffffffc0204486:	de650513          	addi	a0,a0,-538 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020448a:	ff1fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020448e <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc020448e:	7139                	addi	sp,sp,-64
ffffffffc0204490:	fc06                	sd	ra,56(sp)
ffffffffc0204492:	f822                	sd	s0,48(sp)
ffffffffc0204494:	f426                	sd	s1,40(sp)
ffffffffc0204496:	f04a                	sd	s2,32(sp)
ffffffffc0204498:	ec4e                	sd	s3,24(sp)
ffffffffc020449a:	e852                	sd	s4,16(sp)
ffffffffc020449c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020449e:	c52d                	beqz	a0,ffffffffc0204508 <dup_mmap+0x7a>
ffffffffc02044a0:	892a                	mv	s2,a0
ffffffffc02044a2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02044a4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02044a6:	e595                	bnez	a1,ffffffffc02044d2 <dup_mmap+0x44>
ffffffffc02044a8:	a085                	j	ffffffffc0204508 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02044aa:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02044ac:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee8>
        vma->vm_end = vm_end;
ffffffffc02044b0:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02044b4:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02044b8:	e05ff0ef          	jal	ra,ffffffffc02042bc <insert_vma_struct>
        //enable sharing mechanism --set share from 0 to 1
        //bool share = 0;
        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02044bc:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02044c0:	fe843603          	ld	a2,-24(s0)
ffffffffc02044c4:	6c8c                	ld	a1,24(s1)
ffffffffc02044c6:	01893503          	ld	a0,24(s2)
ffffffffc02044ca:	4705                	li	a4,1
ffffffffc02044cc:	c4bfe0ef          	jal	ra,ffffffffc0203116 <copy_range>
ffffffffc02044d0:	e105                	bnez	a0,ffffffffc02044f0 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02044d2:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02044d4:	02848863          	beq	s1,s0,ffffffffc0204504 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044d8:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02044dc:	fe843a83          	ld	s5,-24(s0)
ffffffffc02044e0:	ff043a03          	ld	s4,-16(s0)
ffffffffc02044e4:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044e8:	e1afd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc02044ec:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02044ee:	fd55                	bnez	a0,ffffffffc02044aa <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02044f0:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02044f2:	70e2                	ld	ra,56(sp)
ffffffffc02044f4:	7442                	ld	s0,48(sp)
ffffffffc02044f6:	74a2                	ld	s1,40(sp)
ffffffffc02044f8:	7902                	ld	s2,32(sp)
ffffffffc02044fa:	69e2                	ld	s3,24(sp)
ffffffffc02044fc:	6a42                	ld	s4,16(sp)
ffffffffc02044fe:	6aa2                	ld	s5,8(sp)
ffffffffc0204500:	6121                	addi	sp,sp,64
ffffffffc0204502:	8082                	ret
    return 0;
ffffffffc0204504:	4501                	li	a0,0
ffffffffc0204506:	b7f5                	j	ffffffffc02044f2 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0204508:	00004697          	auipc	a3,0x4
ffffffffc020450c:	de868693          	addi	a3,a3,-536 # ffffffffc02082f0 <default_pmm_manager+0xd78>
ffffffffc0204510:	00003617          	auipc	a2,0x3
ffffffffc0204514:	9d060613          	addi	a2,a2,-1584 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204518:	0c000593          	li	a1,192
ffffffffc020451c:	00004517          	auipc	a0,0x4
ffffffffc0204520:	d4c50513          	addi	a0,a0,-692 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204524:	f57fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204528 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0204528:	1101                	addi	sp,sp,-32
ffffffffc020452a:	ec06                	sd	ra,24(sp)
ffffffffc020452c:	e822                	sd	s0,16(sp)
ffffffffc020452e:	e426                	sd	s1,8(sp)
ffffffffc0204530:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204532:	c531                	beqz	a0,ffffffffc020457e <exit_mmap+0x56>
ffffffffc0204534:	591c                	lw	a5,48(a0)
ffffffffc0204536:	84aa                	mv	s1,a0
ffffffffc0204538:	e3b9                	bnez	a5,ffffffffc020457e <exit_mmap+0x56>
    return listelm->next;
ffffffffc020453a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020453c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204540:	02850663          	beq	a0,s0,ffffffffc020456c <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204544:	ff043603          	ld	a2,-16(s0)
ffffffffc0204548:	fe843583          	ld	a1,-24(s0)
ffffffffc020454c:	854a                	mv	a0,s2
ffffffffc020454e:	ac5fd0ef          	jal	ra,ffffffffc0202012 <unmap_range>
ffffffffc0204552:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204554:	fe8498e3          	bne	s1,s0,ffffffffc0204544 <exit_mmap+0x1c>
ffffffffc0204558:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020455a:	00848c63          	beq	s1,s0,ffffffffc0204572 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020455e:	ff043603          	ld	a2,-16(s0)
ffffffffc0204562:	fe843583          	ld	a1,-24(s0)
ffffffffc0204566:	854a                	mv	a0,s2
ffffffffc0204568:	bf1fd0ef          	jal	ra,ffffffffc0202158 <exit_range>
ffffffffc020456c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020456e:	fe8498e3          	bne	s1,s0,ffffffffc020455e <exit_mmap+0x36>
    }
}
ffffffffc0204572:	60e2                	ld	ra,24(sp)
ffffffffc0204574:	6442                	ld	s0,16(sp)
ffffffffc0204576:	64a2                	ld	s1,8(sp)
ffffffffc0204578:	6902                	ld	s2,0(sp)
ffffffffc020457a:	6105                	addi	sp,sp,32
ffffffffc020457c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020457e:	00004697          	auipc	a3,0x4
ffffffffc0204582:	d9268693          	addi	a3,a3,-622 # ffffffffc0208310 <default_pmm_manager+0xd98>
ffffffffc0204586:	00003617          	auipc	a2,0x3
ffffffffc020458a:	95a60613          	addi	a2,a2,-1702 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020458e:	0d700593          	li	a1,215
ffffffffc0204592:	00004517          	auipc	a0,0x4
ffffffffc0204596:	cd650513          	addi	a0,a0,-810 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020459a:	ee1fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020459e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020459e:	7139                	addi	sp,sp,-64
ffffffffc02045a0:	f822                	sd	s0,48(sp)
ffffffffc02045a2:	f426                	sd	s1,40(sp)
ffffffffc02045a4:	fc06                	sd	ra,56(sp)
ffffffffc02045a6:	f04a                	sd	s2,32(sp)
ffffffffc02045a8:	ec4e                	sd	s3,24(sp)
ffffffffc02045aa:	e852                	sd	s4,16(sp)
ffffffffc02045ac:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02045ae:	c59ff0ef          	jal	ra,ffffffffc0204206 <mm_create>
    assert(mm != NULL);
ffffffffc02045b2:	84aa                	mv	s1,a0
ffffffffc02045b4:	03200413          	li	s0,50
ffffffffc02045b8:	e919                	bnez	a0,ffffffffc02045ce <vmm_init+0x30>
ffffffffc02045ba:	a991                	j	ffffffffc0204a0e <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02045bc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02045be:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02045c0:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02045c4:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02045c6:	8526                	mv	a0,s1
ffffffffc02045c8:	cf5ff0ef          	jal	ra,ffffffffc02042bc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02045cc:	c80d                	beqz	s0,ffffffffc02045fe <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045ce:	03000513          	li	a0,48
ffffffffc02045d2:	d30fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc02045d6:	85aa                	mv	a1,a0
ffffffffc02045d8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02045dc:	f165                	bnez	a0,ffffffffc02045bc <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02045de:	00003697          	auipc	a3,0x3
ffffffffc02045e2:	78a68693          	addi	a3,a3,1930 # ffffffffc0207d68 <default_pmm_manager+0x7f0>
ffffffffc02045e6:	00003617          	auipc	a2,0x3
ffffffffc02045ea:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02045ee:	11400593          	li	a1,276
ffffffffc02045f2:	00004517          	auipc	a0,0x4
ffffffffc02045f6:	c7650513          	addi	a0,a0,-906 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02045fa:	e81fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02045fe:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204602:	1f900913          	li	s2,505
ffffffffc0204606:	a819                	j	ffffffffc020461c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0204608:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020460a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020460c:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204610:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204612:	8526                	mv	a0,s1
ffffffffc0204614:	ca9ff0ef          	jal	ra,ffffffffc02042bc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204618:	03240a63          	beq	s0,s2,ffffffffc020464c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020461c:	03000513          	li	a0,48
ffffffffc0204620:	ce2fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204624:	85aa                	mv	a1,a0
ffffffffc0204626:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020462a:	fd79                	bnez	a0,ffffffffc0204608 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020462c:	00003697          	auipc	a3,0x3
ffffffffc0204630:	73c68693          	addi	a3,a3,1852 # ffffffffc0207d68 <default_pmm_manager+0x7f0>
ffffffffc0204634:	00003617          	auipc	a2,0x3
ffffffffc0204638:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020463c:	11a00593          	li	a1,282
ffffffffc0204640:	00004517          	auipc	a0,0x4
ffffffffc0204644:	c2850513          	addi	a0,a0,-984 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204648:	e33fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc020464c:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020464e:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0204650:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204654:	2cf48d63          	beq	s1,a5,ffffffffc020492e <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204658:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4b78c>
ffffffffc020465c:	ffe70613          	addi	a2,a4,-2
ffffffffc0204660:	24d61763          	bne	a2,a3,ffffffffc02048ae <vmm_init+0x310>
ffffffffc0204664:	ff07b683          	ld	a3,-16(a5)
ffffffffc0204668:	24d71363          	bne	a4,a3,ffffffffc02048ae <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc020466c:	0715                	addi	a4,a4,5
ffffffffc020466e:	679c                	ld	a5,8(a5)
ffffffffc0204670:	feb712e3          	bne	a4,a1,ffffffffc0204654 <vmm_init+0xb6>
ffffffffc0204674:	4a1d                	li	s4,7
ffffffffc0204676:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204678:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020467c:	85a2                	mv	a1,s0
ffffffffc020467e:	8526                	mv	a0,s1
ffffffffc0204680:	bfdff0ef          	jal	ra,ffffffffc020427c <find_vma>
ffffffffc0204684:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0204686:	30050463          	beqz	a0,ffffffffc020498e <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020468a:	00140593          	addi	a1,s0,1
ffffffffc020468e:	8526                	mv	a0,s1
ffffffffc0204690:	bedff0ef          	jal	ra,ffffffffc020427c <find_vma>
ffffffffc0204694:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204696:	2c050c63          	beqz	a0,ffffffffc020496e <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020469a:	85d2                	mv	a1,s4
ffffffffc020469c:	8526                	mv	a0,s1
ffffffffc020469e:	bdfff0ef          	jal	ra,ffffffffc020427c <find_vma>
        assert(vma3 == NULL);
ffffffffc02046a2:	2a051663          	bnez	a0,ffffffffc020494e <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02046a6:	00340593          	addi	a1,s0,3
ffffffffc02046aa:	8526                	mv	a0,s1
ffffffffc02046ac:	bd1ff0ef          	jal	ra,ffffffffc020427c <find_vma>
        assert(vma4 == NULL);
ffffffffc02046b0:	30051f63          	bnez	a0,ffffffffc02049ce <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02046b4:	00440593          	addi	a1,s0,4
ffffffffc02046b8:	8526                	mv	a0,s1
ffffffffc02046ba:	bc3ff0ef          	jal	ra,ffffffffc020427c <find_vma>
        assert(vma5 == NULL);
ffffffffc02046be:	2e051863          	bnez	a0,ffffffffc02049ae <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02046c2:	00893783          	ld	a5,8(s2)
ffffffffc02046c6:	20f41463          	bne	s0,a5,ffffffffc02048ce <vmm_init+0x330>
ffffffffc02046ca:	01093783          	ld	a5,16(s2)
ffffffffc02046ce:	21479063          	bne	a5,s4,ffffffffc02048ce <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02046d2:	0089b783          	ld	a5,8(s3)
ffffffffc02046d6:	20f41c63          	bne	s0,a5,ffffffffc02048ee <vmm_init+0x350>
ffffffffc02046da:	0109b783          	ld	a5,16(s3)
ffffffffc02046de:	21479863          	bne	a5,s4,ffffffffc02048ee <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02046e2:	0415                	addi	s0,s0,5
ffffffffc02046e4:	0a15                	addi	s4,s4,5
ffffffffc02046e6:	f9541be3          	bne	s0,s5,ffffffffc020467c <vmm_init+0xde>
ffffffffc02046ea:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02046ec:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02046ee:	85a2                	mv	a1,s0
ffffffffc02046f0:	8526                	mv	a0,s1
ffffffffc02046f2:	b8bff0ef          	jal	ra,ffffffffc020427c <find_vma>
ffffffffc02046f6:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02046fa:	c90d                	beqz	a0,ffffffffc020472c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02046fc:	6914                	ld	a3,16(a0)
ffffffffc02046fe:	6510                	ld	a2,8(a0)
ffffffffc0204700:	00004517          	auipc	a0,0x4
ffffffffc0204704:	d3050513          	addi	a0,a0,-720 # ffffffffc0208430 <default_pmm_manager+0xeb8>
ffffffffc0204708:	a79fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020470c:	00004697          	auipc	a3,0x4
ffffffffc0204710:	d4c68693          	addi	a3,a3,-692 # ffffffffc0208458 <default_pmm_manager+0xee0>
ffffffffc0204714:	00002617          	auipc	a2,0x2
ffffffffc0204718:	7cc60613          	addi	a2,a2,1996 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020471c:	13c00593          	li	a1,316
ffffffffc0204720:	00004517          	auipc	a0,0x4
ffffffffc0204724:	b4850513          	addi	a0,a0,-1208 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204728:	d53fb0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020472c:	147d                	addi	s0,s0,-1
ffffffffc020472e:	fd2410e3          	bne	s0,s2,ffffffffc02046ee <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204732:	8526                	mv	a0,s1
ffffffffc0204734:	c59ff0ef          	jal	ra,ffffffffc020438c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0204738:	00004517          	auipc	a0,0x4
ffffffffc020473c:	d3850513          	addi	a0,a0,-712 # ffffffffc0208470 <default_pmm_manager+0xef8>
ffffffffc0204740:	a41fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204744:	e6efd0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0204748:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc020474a:	abdff0ef          	jal	ra,ffffffffc0204206 <mm_create>
ffffffffc020474e:	000af797          	auipc	a5,0xaf
ffffffffc0204752:	0ea7b123          	sd	a0,226(a5) # ffffffffc02b3830 <check_mm_struct>
ffffffffc0204756:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0204758:	28050b63          	beqz	a0,ffffffffc02049ee <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020475c:	000af497          	auipc	s1,0xaf
ffffffffc0204760:	08c4b483          	ld	s1,140(s1) # ffffffffc02b37e8 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0204764:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204766:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204768:	2e079f63          	bnez	a5,ffffffffc0204a66 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020476c:	03000513          	li	a0,48
ffffffffc0204770:	b92fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204774:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0204776:	18050c63          	beqz	a0,ffffffffc020490e <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc020477a:	002007b7          	lui	a5,0x200
ffffffffc020477e:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0204782:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204784:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204786:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc020478a:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020478c:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204790:	b2dff0ef          	jal	ra,ffffffffc02042bc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204794:	10000593          	li	a1,256
ffffffffc0204798:	8522                	mv	a0,s0
ffffffffc020479a:	ae3ff0ef          	jal	ra,ffffffffc020427c <find_vma>
ffffffffc020479e:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02047a2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02047a6:	2ea99063          	bne	s3,a0,ffffffffc0204a86 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02047aa:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ee0>
    for (i = 0; i < 100; i ++) {
ffffffffc02047ae:	0785                	addi	a5,a5,1
ffffffffc02047b0:	fee79de3          	bne	a5,a4,ffffffffc02047aa <vmm_init+0x20c>
        sum += i;
ffffffffc02047b4:	6705                	lui	a4,0x1
ffffffffc02047b6:	10000793          	li	a5,256
ffffffffc02047ba:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02047be:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02047c2:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02047c6:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02047c8:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02047ca:	fec79ce3          	bne	a5,a2,ffffffffc02047c2 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02047ce:	2c071e63          	bnez	a4,ffffffffc0204aaa <vmm_init+0x50c>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047d2:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02047d4:	000afa97          	auipc	s5,0xaf
ffffffffc02047d8:	01ca8a93          	addi	s5,s5,28 # ffffffffc02b37f0 <npage>
ffffffffc02047dc:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047e0:	078a                	slli	a5,a5,0x2
ffffffffc02047e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047e4:	2cc7f163          	bgeu	a5,a2,ffffffffc0204aa6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02047e8:	00005a17          	auipc	s4,0x5
ffffffffc02047ec:	8b0a3a03          	ld	s4,-1872(s4) # ffffffffc0209098 <nbase>
ffffffffc02047f0:	414787b3          	sub	a5,a5,s4
ffffffffc02047f4:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02047f6:	8799                	srai	a5,a5,0x6
ffffffffc02047f8:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02047fa:	00c79713          	slli	a4,a5,0xc
ffffffffc02047fe:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204800:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204804:	24c77563          	bgeu	a4,a2,ffffffffc0204a4e <vmm_init+0x4b0>
ffffffffc0204808:	000af997          	auipc	s3,0xaf
ffffffffc020480c:	0009b983          	ld	s3,0(s3) # ffffffffc02b3808 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0204810:	4581                	li	a1,0
ffffffffc0204812:	8526                	mv	a0,s1
ffffffffc0204814:	99b6                	add	s3,s3,a3
ffffffffc0204816:	bd5fd0ef          	jal	ra,ffffffffc02023ea <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020481a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020481e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204822:	078a                	slli	a5,a5,0x2
ffffffffc0204824:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204826:	28e7f063          	bgeu	a5,a4,ffffffffc0204aa6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020482a:	000af997          	auipc	s3,0xaf
ffffffffc020482e:	fce98993          	addi	s3,s3,-50 # ffffffffc02b37f8 <pages>
ffffffffc0204832:	0009b503          	ld	a0,0(s3)
ffffffffc0204836:	414787b3          	sub	a5,a5,s4
ffffffffc020483a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020483c:	953e                	add	a0,a0,a5
ffffffffc020483e:	4585                	li	a1,1
ffffffffc0204840:	d32fd0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204844:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0204846:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020484a:	078a                	slli	a5,a5,0x2
ffffffffc020484c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020484e:	24e7fc63          	bgeu	a5,a4,ffffffffc0204aa6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204852:	0009b503          	ld	a0,0(s3)
ffffffffc0204856:	414787b3          	sub	a5,a5,s4
ffffffffc020485a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020485c:	4585                	li	a1,1
ffffffffc020485e:	953e                	add	a0,a0,a5
ffffffffc0204860:	d12fd0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    pgdir[0] = 0;
ffffffffc0204864:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc0204868:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020486c:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020486e:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204872:	b1bff0ef          	jal	ra,ffffffffc020438c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204876:	000af797          	auipc	a5,0xaf
ffffffffc020487a:	fa07bd23          	sd	zero,-70(a5) # ffffffffc02b3830 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020487e:	d34fd0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0204882:	1aa91663          	bne	s2,a0,ffffffffc0204a2e <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204886:	00004517          	auipc	a0,0x4
ffffffffc020488a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0208500 <default_pmm_manager+0xf88>
ffffffffc020488e:	8f3fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0204892:	7442                	ld	s0,48(sp)
ffffffffc0204894:	70e2                	ld	ra,56(sp)
ffffffffc0204896:	74a2                	ld	s1,40(sp)
ffffffffc0204898:	7902                	ld	s2,32(sp)
ffffffffc020489a:	69e2                	ld	s3,24(sp)
ffffffffc020489c:	6a42                	ld	s4,16(sp)
ffffffffc020489e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02048a0:	00004517          	auipc	a0,0x4
ffffffffc02048a4:	c8050513          	addi	a0,a0,-896 # ffffffffc0208520 <default_pmm_manager+0xfa8>
}
ffffffffc02048a8:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02048aa:	8d7fb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02048ae:	00004697          	auipc	a3,0x4
ffffffffc02048b2:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0208348 <default_pmm_manager+0xdd0>
ffffffffc02048b6:	00002617          	auipc	a2,0x2
ffffffffc02048ba:	62a60613          	addi	a2,a2,1578 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02048be:	12300593          	li	a1,291
ffffffffc02048c2:	00004517          	auipc	a0,0x4
ffffffffc02048c6:	9a650513          	addi	a0,a0,-1626 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02048ca:	bb1fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02048ce:	00004697          	auipc	a3,0x4
ffffffffc02048d2:	b0268693          	addi	a3,a3,-1278 # ffffffffc02083d0 <default_pmm_manager+0xe58>
ffffffffc02048d6:	00002617          	auipc	a2,0x2
ffffffffc02048da:	60a60613          	addi	a2,a2,1546 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02048de:	13300593          	li	a1,307
ffffffffc02048e2:	00004517          	auipc	a0,0x4
ffffffffc02048e6:	98650513          	addi	a0,a0,-1658 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02048ea:	b91fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02048ee:	00004697          	auipc	a3,0x4
ffffffffc02048f2:	b1268693          	addi	a3,a3,-1262 # ffffffffc0208400 <default_pmm_manager+0xe88>
ffffffffc02048f6:	00002617          	auipc	a2,0x2
ffffffffc02048fa:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02048fe:	13400593          	li	a1,308
ffffffffc0204902:	00004517          	auipc	a0,0x4
ffffffffc0204906:	96650513          	addi	a0,a0,-1690 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020490a:	b71fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc020490e:	00003697          	auipc	a3,0x3
ffffffffc0204912:	45a68693          	addi	a3,a3,1114 # ffffffffc0207d68 <default_pmm_manager+0x7f0>
ffffffffc0204916:	00002617          	auipc	a2,0x2
ffffffffc020491a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020491e:	15300593          	li	a1,339
ffffffffc0204922:	00004517          	auipc	a0,0x4
ffffffffc0204926:	94650513          	addi	a0,a0,-1722 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020492a:	b51fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020492e:	00004697          	auipc	a3,0x4
ffffffffc0204932:	a0268693          	addi	a3,a3,-1534 # ffffffffc0208330 <default_pmm_manager+0xdb8>
ffffffffc0204936:	00002617          	auipc	a2,0x2
ffffffffc020493a:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020493e:	12100593          	li	a1,289
ffffffffc0204942:	00004517          	auipc	a0,0x4
ffffffffc0204946:	92650513          	addi	a0,a0,-1754 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020494a:	b31fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc020494e:	00004697          	auipc	a3,0x4
ffffffffc0204952:	a5268693          	addi	a3,a3,-1454 # ffffffffc02083a0 <default_pmm_manager+0xe28>
ffffffffc0204956:	00002617          	auipc	a2,0x2
ffffffffc020495a:	58a60613          	addi	a2,a2,1418 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020495e:	12d00593          	li	a1,301
ffffffffc0204962:	00004517          	auipc	a0,0x4
ffffffffc0204966:	90650513          	addi	a0,a0,-1786 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020496a:	b11fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc020496e:	00004697          	auipc	a3,0x4
ffffffffc0204972:	a2268693          	addi	a3,a3,-1502 # ffffffffc0208390 <default_pmm_manager+0xe18>
ffffffffc0204976:	00002617          	auipc	a2,0x2
ffffffffc020497a:	56a60613          	addi	a2,a2,1386 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020497e:	12b00593          	li	a1,299
ffffffffc0204982:	00004517          	auipc	a0,0x4
ffffffffc0204986:	8e650513          	addi	a0,a0,-1818 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc020498a:	af1fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc020498e:	00004697          	auipc	a3,0x4
ffffffffc0204992:	9f268693          	addi	a3,a3,-1550 # ffffffffc0208380 <default_pmm_manager+0xe08>
ffffffffc0204996:	00002617          	auipc	a2,0x2
ffffffffc020499a:	54a60613          	addi	a2,a2,1354 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020499e:	12900593          	li	a1,297
ffffffffc02049a2:	00004517          	auipc	a0,0x4
ffffffffc02049a6:	8c650513          	addi	a0,a0,-1850 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02049aa:	ad1fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc02049ae:	00004697          	auipc	a3,0x4
ffffffffc02049b2:	a1268693          	addi	a3,a3,-1518 # ffffffffc02083c0 <default_pmm_manager+0xe48>
ffffffffc02049b6:	00002617          	auipc	a2,0x2
ffffffffc02049ba:	52a60613          	addi	a2,a2,1322 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02049be:	13100593          	li	a1,305
ffffffffc02049c2:	00004517          	auipc	a0,0x4
ffffffffc02049c6:	8a650513          	addi	a0,a0,-1882 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02049ca:	ab1fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc02049ce:	00004697          	auipc	a3,0x4
ffffffffc02049d2:	9e268693          	addi	a3,a3,-1566 # ffffffffc02083b0 <default_pmm_manager+0xe38>
ffffffffc02049d6:	00002617          	auipc	a2,0x2
ffffffffc02049da:	50a60613          	addi	a2,a2,1290 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02049de:	12f00593          	li	a1,303
ffffffffc02049e2:	00004517          	auipc	a0,0x4
ffffffffc02049e6:	88650513          	addi	a0,a0,-1914 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc02049ea:	a91fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02049ee:	00004697          	auipc	a3,0x4
ffffffffc02049f2:	aa268693          	addi	a3,a3,-1374 # ffffffffc0208490 <default_pmm_manager+0xf18>
ffffffffc02049f6:	00002617          	auipc	a2,0x2
ffffffffc02049fa:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02049fe:	14c00593          	li	a1,332
ffffffffc0204a02:	00004517          	auipc	a0,0x4
ffffffffc0204a06:	86650513          	addi	a0,a0,-1946 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204a0a:	a71fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc0204a0e:	00003697          	auipc	a3,0x3
ffffffffc0204a12:	32268693          	addi	a3,a3,802 # ffffffffc0207d30 <default_pmm_manager+0x7b8>
ffffffffc0204a16:	00002617          	auipc	a2,0x2
ffffffffc0204a1a:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204a1e:	10d00593          	li	a1,269
ffffffffc0204a22:	00004517          	auipc	a0,0x4
ffffffffc0204a26:	84650513          	addi	a0,a0,-1978 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204a2a:	a51fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204a2e:	00004697          	auipc	a3,0x4
ffffffffc0204a32:	aaa68693          	addi	a3,a3,-1366 # ffffffffc02084d8 <default_pmm_manager+0xf60>
ffffffffc0204a36:	00002617          	auipc	a2,0x2
ffffffffc0204a3a:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204a3e:	17100593          	li	a1,369
ffffffffc0204a42:	00004517          	auipc	a0,0x4
ffffffffc0204a46:	82650513          	addi	a0,a0,-2010 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204a4a:	a31fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204a4e:	00003617          	auipc	a2,0x3
ffffffffc0204a52:	b6260613          	addi	a2,a2,-1182 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0204a56:	06900593          	li	a1,105
ffffffffc0204a5a:	00003517          	auipc	a0,0x3
ffffffffc0204a5e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0204a62:	a19fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204a66:	00003697          	auipc	a3,0x3
ffffffffc0204a6a:	2f268693          	addi	a3,a3,754 # ffffffffc0207d58 <default_pmm_manager+0x7e0>
ffffffffc0204a6e:	00002617          	auipc	a2,0x2
ffffffffc0204a72:	47260613          	addi	a2,a2,1138 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204a76:	15000593          	li	a1,336
ffffffffc0204a7a:	00003517          	auipc	a0,0x3
ffffffffc0204a7e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204a82:	9f9fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204a86:	00004697          	auipc	a3,0x4
ffffffffc0204a8a:	a2268693          	addi	a3,a3,-1502 # ffffffffc02084a8 <default_pmm_manager+0xf30>
ffffffffc0204a8e:	00002617          	auipc	a2,0x2
ffffffffc0204a92:	45260613          	addi	a2,a2,1106 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204a96:	15800593          	li	a1,344
ffffffffc0204a9a:	00003517          	auipc	a0,0x3
ffffffffc0204a9e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204aa2:	9d9fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204aa6:	f44ff0ef          	jal	ra,ffffffffc02041ea <pa2page.part.0>
    assert(sum == 0);
ffffffffc0204aaa:	00004697          	auipc	a3,0x4
ffffffffc0204aae:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02084c8 <default_pmm_manager+0xf50>
ffffffffc0204ab2:	00002617          	auipc	a2,0x2
ffffffffc0204ab6:	42e60613          	addi	a2,a2,1070 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204aba:	16400593          	li	a1,356
ffffffffc0204abe:	00003517          	auipc	a0,0x3
ffffffffc0204ac2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204ac6:	9b5fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204aca <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204aca:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204acc:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204ace:	e0a2                	sd	s0,64(sp)
ffffffffc0204ad0:	fc26                	sd	s1,56(sp)
ffffffffc0204ad2:	e486                	sd	ra,72(sp)
ffffffffc0204ad4:	f84a                	sd	s2,48(sp)
ffffffffc0204ad6:	f44e                	sd	s3,40(sp)
ffffffffc0204ad8:	f052                	sd	s4,32(sp)
ffffffffc0204ada:	ec56                	sd	s5,24(sp)
ffffffffc0204adc:	e85a                	sd	s6,16(sp)
ffffffffc0204ade:	8432                	mv	s0,a2
ffffffffc0204ae0:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204ae2:	f9aff0ef          	jal	ra,ffffffffc020427c <find_vma>

    pgfault_num++;
ffffffffc0204ae6:	000af797          	auipc	a5,0xaf
ffffffffc0204aea:	d527a783          	lw	a5,-686(a5) # ffffffffc02b3838 <pgfault_num>
ffffffffc0204aee:	2785                	addiw	a5,a5,1
ffffffffc0204af0:	000af717          	auipc	a4,0xaf
ffffffffc0204af4:	d4f72423          	sw	a5,-696(a4) # ffffffffc02b3838 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204af8:	1a050263          	beqz	a0,ffffffffc0204c9c <do_pgfault+0x1d2>
ffffffffc0204afc:	651c                	ld	a5,8(a0)
ffffffffc0204afe:	18f46f63          	bltu	s0,a5,ffffffffc0204c9c <do_pgfault+0x1d2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204b02:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204b04:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204b06:	8b89                	andi	a5,a5,2
ffffffffc0204b08:	e7b5                	bnez	a5,ffffffffc0204b74 <do_pgfault+0xaa>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204b0a:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204b0c:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204b0e:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204b10:	4605                	li	a2,1
ffffffffc0204b12:	85a2                	mv	a1,s0
ffffffffc0204b14:	ad8fd0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0204b18:	892a                	mv	s2,a0
ffffffffc0204b1a:	1a050263          	beqz	a0,ffffffffc0204cbe <do_pgfault+0x1f4>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204b1e:	610c                	ld	a1,0(a0)
ffffffffc0204b20:	12058863          	beqz	a1,ffffffffc0204c50 <do_pgfault+0x186>
    //     uintptr_t *dst_kvaddr = page2kva(npage);
    //     memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
    // 
    }else {
        struct Page *page = NULL;
        if(*ptep & PTE_V){
ffffffffc0204b24:	0015f793          	andi	a5,a1,1
ffffffffc0204b28:	eba1                	bnez	a5,ffffffffc0204b78 <do_pgfault+0xae>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
            if (swap_init_ok) {
ffffffffc0204b2a:	000af797          	auipc	a5,0xaf
ffffffffc0204b2e:	cf67a783          	lw	a5,-778(a5) # ffffffffc02b3820 <swap_init_ok>
ffffffffc0204b32:	16078e63          	beqz	a5,ffffffffc0204cae <do_pgfault+0x1e4>
                struct Page *page = NULL;
                // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
                //(1）According to the mm AND addr, try
                //to load the content of right disk page
                //into the memory which page managed.
                swap_in(mm, addr, &page);
ffffffffc0204b36:	85a2                	mv	a1,s0
ffffffffc0204b38:	0030                	addi	a2,sp,8
ffffffffc0204b3a:	8526                	mv	a0,s1
                struct Page *page = NULL;
ffffffffc0204b3c:	e402                	sd	zero,8(sp)
                swap_in(mm, addr, &page);
ffffffffc0204b3e:	9e0ff0ef          	jal	ra,ffffffffc0203d1e <swap_in>
                //(2) According to the mm,
                //addr AND page, setup the
                //map of phy addr <--->
                //logical addr
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204b42:	65a2                	ld	a1,8(sp)
ffffffffc0204b44:	6c88                	ld	a0,24(s1)
ffffffffc0204b46:	86ce                	mv	a3,s3
ffffffffc0204b48:	8622                	mv	a2,s0
ffffffffc0204b4a:	93dfd0ef          	jal	ra,ffffffffc0202486 <page_insert>
                //(3) make the page swappable.
                swap_map_swappable(mm, addr, page, 1);
ffffffffc0204b4e:	6622                	ld	a2,8(sp)
ffffffffc0204b50:	4685                	li	a3,1
ffffffffc0204b52:	85a2                	mv	a1,s0
ffffffffc0204b54:	8526                	mv	a0,s1
ffffffffc0204b56:	8a8ff0ef          	jal	ra,ffffffffc0203bfe <swap_map_swappable>
                page->pra_vaddr = addr;
ffffffffc0204b5a:	67a2                	ld	a5,8(sp)
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
                goto failed;
            }
    }
}
   ret = 0;
ffffffffc0204b5c:	4501                	li	a0,0
                page->pra_vaddr = addr;
ffffffffc0204b5e:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0204b60:	60a6                	ld	ra,72(sp)
ffffffffc0204b62:	6406                	ld	s0,64(sp)
ffffffffc0204b64:	74e2                	ld	s1,56(sp)
ffffffffc0204b66:	7942                	ld	s2,48(sp)
ffffffffc0204b68:	79a2                	ld	s3,40(sp)
ffffffffc0204b6a:	7a02                	ld	s4,32(sp)
ffffffffc0204b6c:	6ae2                	ld	s5,24(sp)
ffffffffc0204b6e:	6b42                	ld	s6,16(sp)
ffffffffc0204b70:	6161                	addi	sp,sp,80
ffffffffc0204b72:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204b74:	49dd                	li	s3,23
ffffffffc0204b76:	bf51                	j	ffffffffc0204b0a <do_pgfault+0x40>
            cprintf("\n\nCOW：ptep 0x%x, pte 0x%x\n, ptep, *ptep");
ffffffffc0204b78:	00004517          	auipc	a0,0x4
ffffffffc0204b7c:	a3850513          	addi	a0,a0,-1480 # ffffffffc02085b0 <default_pmm_manager+0x1038>
ffffffffc0204b80:	e00fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
            page = pte2page(*ptep);
ffffffffc0204b84:	00093783          	ld	a5,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0204b88:	0017f713          	andi	a4,a5,1
ffffffffc0204b8c:	14070163          	beqz	a4,ffffffffc0204cce <do_pgfault+0x204>
    if (PPN(pa) >= npage) {
ffffffffc0204b90:	000afa97          	auipc	s5,0xaf
ffffffffc0204b94:	c60a8a93          	addi	s5,s5,-928 # ffffffffc02b37f0 <npage>
ffffffffc0204b98:	000ab703          	ld	a4,0(s5)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204b9c:	078a                	slli	a5,a5,0x2
ffffffffc0204b9e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204ba0:	18e7f063          	bgeu	a5,a4,ffffffffc0204d20 <do_pgfault+0x256>
    return &pages[PPN(pa) - nbase];
ffffffffc0204ba4:	000afb17          	auipc	s6,0xaf
ffffffffc0204ba8:	c54b0b13          	addi	s6,s6,-940 # ffffffffc02b37f8 <pages>
ffffffffc0204bac:	000b3903          	ld	s2,0(s6)
ffffffffc0204bb0:	00004a17          	auipc	s4,0x4
ffffffffc0204bb4:	4e8a3a03          	ld	s4,1256(s4) # ffffffffc0209098 <nbase>
ffffffffc0204bb8:	414787b3          	sub	a5,a5,s4
ffffffffc0204bbc:	079a                	slli	a5,a5,0x6
ffffffffc0204bbe:	993e                	add	s2,s2,a5
            cprintf("Original page: 0x%x, reference count: %d\n", page, page_ref(page));
ffffffffc0204bc0:	00092603          	lw	a2,0(s2)
ffffffffc0204bc4:	85ca                	mv	a1,s2
ffffffffc0204bc6:	00004517          	auipc	a0,0x4
ffffffffc0204bca:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02085e0 <default_pmm_manager+0x1068>
ffffffffc0204bce:	db2fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(page_ref(page) > 1)
ffffffffc0204bd2:	00092703          	lw	a4,0(s2)
ffffffffc0204bd6:	4785                	li	a5,1
ffffffffc0204bd8:	08e7dd63          	bge	a5,a4,ffffffffc0204c72 <do_pgfault+0x1a8>
                cprintf("Page reference count > 1, need to create a new page.\n");
ffffffffc0204bdc:	00004517          	auipc	a0,0x4
ffffffffc0204be0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0208610 <default_pmm_manager+0x1098>
ffffffffc0204be4:	d9cfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
                struct Page* newPage = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0204be8:	6c88                	ld	a0,24(s1)
ffffffffc0204bea:	864e                	mv	a2,s3
ffffffffc0204bec:	85a2                	mv	a1,s0
ffffffffc0204bee:	fe8fe0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
                assert(newPage != NULL);
ffffffffc0204bf2:	10050763          	beqz	a0,ffffffffc0204d00 <do_pgfault+0x236>
    return page - pages + nbase;
ffffffffc0204bf6:	000b3783          	ld	a5,0(s6)
    return KADDR(page2pa(page));
ffffffffc0204bfa:	577d                	li	a4,-1
ffffffffc0204bfc:	000ab603          	ld	a2,0(s5)
    return page - pages + nbase;
ffffffffc0204c00:	40f906b3          	sub	a3,s2,a5
ffffffffc0204c04:	8699                	srai	a3,a3,0x6
ffffffffc0204c06:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204c08:	8331                	srli	a4,a4,0xc
ffffffffc0204c0a:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c0e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c10:	0cc5fc63          	bgeu	a1,a2,ffffffffc0204ce8 <do_pgfault+0x21e>
    return page - pages + nbase;
ffffffffc0204c14:	40f507b3          	sub	a5,a0,a5
ffffffffc0204c18:	8799                	srai	a5,a5,0x6
ffffffffc0204c1a:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0204c1c:	000af497          	auipc	s1,0xaf
ffffffffc0204c20:	bec4b483          	ld	s1,-1044(s1) # ffffffffc02b3808 <va_pa_offset>
ffffffffc0204c24:	8f7d                	and	a4,a4,a5
ffffffffc0204c26:	00968433          	add	s0,a3,s1
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c2a:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204c2c:	0ac77d63          	bgeu	a4,a2,ffffffffc0204ce6 <do_pgfault+0x21c>
ffffffffc0204c30:	94be                	add	s1,s1,a5
                cprintf("Copying from src_kvaddr: 0x%p to dst_kvaddr: 0x%p\n", src_kvaddr, dst_kvaddr);
ffffffffc0204c32:	8626                	mv	a2,s1
ffffffffc0204c34:	85a2                	mv	a1,s0
ffffffffc0204c36:	00004517          	auipc	a0,0x4
ffffffffc0204c3a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0208658 <default_pmm_manager+0x10e0>
ffffffffc0204c3e:	d42fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0204c42:	6605                	lui	a2,0x1
ffffffffc0204c44:	85a2                	mv	a1,s0
ffffffffc0204c46:	8526                	mv	a0,s1
ffffffffc0204c48:	3c3010ef          	jal	ra,ffffffffc020680a <memcpy>
   ret = 0;
ffffffffc0204c4c:	4501                	li	a0,0
ffffffffc0204c4e:	bf09                	j	ffffffffc0204b60 <do_pgfault+0x96>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204c50:	6c88                	ld	a0,24(s1)
ffffffffc0204c52:	864e                	mv	a2,s3
ffffffffc0204c54:	85a2                	mv	a1,s0
ffffffffc0204c56:	f80fe0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0204c5a:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0204c5c:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204c5e:	f00791e3          	bnez	a5,ffffffffc0204b60 <do_pgfault+0x96>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204c62:	00004517          	auipc	a0,0x4
ffffffffc0204c66:	92650513          	addi	a0,a0,-1754 # ffffffffc0208588 <default_pmm_manager+0x1010>
ffffffffc0204c6a:	d16fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204c6e:	5571                	li	a0,-4
            goto failed;
ffffffffc0204c70:	bdc5                	j	ffffffffc0204b60 <do_pgfault+0x96>
                cprintf("Page reference count is 1, directly inserting page into page table.\n");
ffffffffc0204c72:	00004517          	auipc	a0,0x4
ffffffffc0204c76:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0208690 <default_pmm_manager+0x1118>
ffffffffc0204c7a:	d06fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204c7e:	6c88                	ld	a0,24(s1)
ffffffffc0204c80:	86ce                	mv	a3,s3
ffffffffc0204c82:	8622                	mv	a2,s0
ffffffffc0204c84:	85ca                	mv	a1,s2
ffffffffc0204c86:	801fd0ef          	jal	ra,ffffffffc0202486 <page_insert>
                cprintf("Page inserted at address: 0x%p\n", addr);
ffffffffc0204c8a:	85a2                	mv	a1,s0
ffffffffc0204c8c:	00004517          	auipc	a0,0x4
ffffffffc0204c90:	a4c50513          	addi	a0,a0,-1460 # ffffffffc02086d8 <default_pmm_manager+0x1160>
ffffffffc0204c94:	cecfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
   ret = 0;
ffffffffc0204c98:	4501                	li	a0,0
ffffffffc0204c9a:	b5d9                	j	ffffffffc0204b60 <do_pgfault+0x96>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204c9c:	85a2                	mv	a1,s0
ffffffffc0204c9e:	00004517          	auipc	a0,0x4
ffffffffc0204ca2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0208538 <default_pmm_manager+0xfc0>
ffffffffc0204ca6:	cdafb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204caa:	5575                	li	a0,-3
        goto failed;
ffffffffc0204cac:	bd55                	j	ffffffffc0204b60 <do_pgfault+0x96>
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204cae:	00004517          	auipc	a0,0x4
ffffffffc0204cb2:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02086f8 <default_pmm_manager+0x1180>
ffffffffc0204cb6:	ccafb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204cba:	5571                	li	a0,-4
                goto failed;
ffffffffc0204cbc:	b555                	j	ffffffffc0204b60 <do_pgfault+0x96>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204cbe:	00004517          	auipc	a0,0x4
ffffffffc0204cc2:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0208568 <default_pmm_manager+0xff0>
ffffffffc0204cc6:	cbafb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204cca:	5571                	li	a0,-4
        goto failed;
ffffffffc0204ccc:	bd51                	j	ffffffffc0204b60 <do_pgfault+0x96>
        panic("pte2page called with invalid pte");
ffffffffc0204cce:	00003617          	auipc	a2,0x3
ffffffffc0204cd2:	9d260613          	addi	a2,a2,-1582 # ffffffffc02076a0 <default_pmm_manager+0x128>
ffffffffc0204cd6:	07400593          	li	a1,116
ffffffffc0204cda:	00003517          	auipc	a0,0x3
ffffffffc0204cde:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0204ce2:	f98fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204ce6:	86be                	mv	a3,a5
ffffffffc0204ce8:	00003617          	auipc	a2,0x3
ffffffffc0204cec:	8c860613          	addi	a2,a2,-1848 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0204cf0:	06900593          	li	a1,105
ffffffffc0204cf4:	00003517          	auipc	a0,0x3
ffffffffc0204cf8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0204cfc:	f7efb0ef          	jal	ra,ffffffffc020047a <__panic>
                assert(newPage != NULL);
ffffffffc0204d00:	00004697          	auipc	a3,0x4
ffffffffc0204d04:	94868693          	addi	a3,a3,-1720 # ffffffffc0208648 <default_pmm_manager+0x10d0>
ffffffffc0204d08:	00002617          	auipc	a2,0x2
ffffffffc0204d0c:	1d860613          	addi	a2,a2,472 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0204d10:	1cb00593          	li	a1,459
ffffffffc0204d14:	00003517          	auipc	a0,0x3
ffffffffc0204d18:	55450513          	addi	a0,a0,1364 # ffffffffc0208268 <default_pmm_manager+0xcf0>
ffffffffc0204d1c:	f5efb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204d20:	ccaff0ef          	jal	ra,ffffffffc02041ea <pa2page.part.0>

ffffffffc0204d24 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204d24:	7179                	addi	sp,sp,-48
ffffffffc0204d26:	f022                	sd	s0,32(sp)
ffffffffc0204d28:	f406                	sd	ra,40(sp)
ffffffffc0204d2a:	ec26                	sd	s1,24(sp)
ffffffffc0204d2c:	e84a                	sd	s2,16(sp)
ffffffffc0204d2e:	e44e                	sd	s3,8(sp)
ffffffffc0204d30:	e052                	sd	s4,0(sp)
ffffffffc0204d32:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204d34:	c135                	beqz	a0,ffffffffc0204d98 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204d36:	002007b7          	lui	a5,0x200
ffffffffc0204d3a:	04f5e663          	bltu	a1,a5,ffffffffc0204d86 <user_mem_check+0x62>
ffffffffc0204d3e:	00c584b3          	add	s1,a1,a2
ffffffffc0204d42:	0495f263          	bgeu	a1,s1,ffffffffc0204d86 <user_mem_check+0x62>
ffffffffc0204d46:	4785                	li	a5,1
ffffffffc0204d48:	07fe                	slli	a5,a5,0x1f
ffffffffc0204d4a:	0297ee63          	bltu	a5,s1,ffffffffc0204d86 <user_mem_check+0x62>
ffffffffc0204d4e:	892a                	mv	s2,a0
ffffffffc0204d50:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d52:	6a05                	lui	s4,0x1
ffffffffc0204d54:	a821                	j	ffffffffc0204d6c <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d56:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d5a:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204d5c:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d5e:	c685                	beqz	a3,ffffffffc0204d86 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204d60:	c399                	beqz	a5,ffffffffc0204d66 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d62:	02e46263          	bltu	s0,a4,ffffffffc0204d86 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204d66:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204d68:	04947663          	bgeu	s0,s1,ffffffffc0204db4 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204d6c:	85a2                	mv	a1,s0
ffffffffc0204d6e:	854a                	mv	a0,s2
ffffffffc0204d70:	d0cff0ef          	jal	ra,ffffffffc020427c <find_vma>
ffffffffc0204d74:	c909                	beqz	a0,ffffffffc0204d86 <user_mem_check+0x62>
ffffffffc0204d76:	6518                	ld	a4,8(a0)
ffffffffc0204d78:	00e46763          	bltu	s0,a4,ffffffffc0204d86 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d7c:	4d1c                	lw	a5,24(a0)
ffffffffc0204d7e:	fc099ce3          	bnez	s3,ffffffffc0204d56 <user_mem_check+0x32>
ffffffffc0204d82:	8b85                	andi	a5,a5,1
ffffffffc0204d84:	f3ed                	bnez	a5,ffffffffc0204d66 <user_mem_check+0x42>
            return 0;
ffffffffc0204d86:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204d88:	70a2                	ld	ra,40(sp)
ffffffffc0204d8a:	7402                	ld	s0,32(sp)
ffffffffc0204d8c:	64e2                	ld	s1,24(sp)
ffffffffc0204d8e:	6942                	ld	s2,16(sp)
ffffffffc0204d90:	69a2                	ld	s3,8(sp)
ffffffffc0204d92:	6a02                	ld	s4,0(sp)
ffffffffc0204d94:	6145                	addi	sp,sp,48
ffffffffc0204d96:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204d98:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d9c:	4501                	li	a0,0
ffffffffc0204d9e:	fef5e5e3          	bltu	a1,a5,ffffffffc0204d88 <user_mem_check+0x64>
ffffffffc0204da2:	962e                	add	a2,a2,a1
ffffffffc0204da4:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204d88 <user_mem_check+0x64>
ffffffffc0204da8:	c8000537          	lui	a0,0xc8000
ffffffffc0204dac:	0505                	addi	a0,a0,1
ffffffffc0204dae:	00a63533          	sltu	a0,a2,a0
ffffffffc0204db2:	bfd9                	j	ffffffffc0204d88 <user_mem_check+0x64>
        return 1;
ffffffffc0204db4:	4505                	li	a0,1
ffffffffc0204db6:	bfc9                	j	ffffffffc0204d88 <user_mem_check+0x64>

ffffffffc0204db8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204db8:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204dba:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204dbc:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204dbe:	82ffb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc0204dc2:	cd01                	beqz	a0,ffffffffc0204dda <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204dc4:	4505                	li	a0,1
ffffffffc0204dc6:	82dfb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc0204dca:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204dcc:	810d                	srli	a0,a0,0x3
ffffffffc0204dce:	000af797          	auipc	a5,0xaf
ffffffffc0204dd2:	a4a7b123          	sd	a0,-1470(a5) # ffffffffc02b3810 <max_swap_offset>
}
ffffffffc0204dd6:	0141                	addi	sp,sp,16
ffffffffc0204dd8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204dda:	00004617          	auipc	a2,0x4
ffffffffc0204dde:	94660613          	addi	a2,a2,-1722 # ffffffffc0208720 <default_pmm_manager+0x11a8>
ffffffffc0204de2:	45b5                	li	a1,13
ffffffffc0204de4:	00004517          	auipc	a0,0x4
ffffffffc0204de8:	95c50513          	addi	a0,a0,-1700 # ffffffffc0208740 <default_pmm_manager+0x11c8>
ffffffffc0204dec:	e8efb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204df0 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204df0:	1141                	addi	sp,sp,-16
ffffffffc0204df2:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204df4:	00855793          	srli	a5,a0,0x8
ffffffffc0204df8:	cbb1                	beqz	a5,ffffffffc0204e4c <swapfs_read+0x5c>
ffffffffc0204dfa:	000af717          	auipc	a4,0xaf
ffffffffc0204dfe:	a1673703          	ld	a4,-1514(a4) # ffffffffc02b3810 <max_swap_offset>
ffffffffc0204e02:	04e7f563          	bgeu	a5,a4,ffffffffc0204e4c <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204e06:	000af617          	auipc	a2,0xaf
ffffffffc0204e0a:	9f263603          	ld	a2,-1550(a2) # ffffffffc02b37f8 <pages>
ffffffffc0204e0e:	8d91                	sub	a1,a1,a2
ffffffffc0204e10:	4065d613          	srai	a2,a1,0x6
ffffffffc0204e14:	00004717          	auipc	a4,0x4
ffffffffc0204e18:	28473703          	ld	a4,644(a4) # ffffffffc0209098 <nbase>
ffffffffc0204e1c:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204e1e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204e22:	8331                	srli	a4,a4,0xc
ffffffffc0204e24:	000af697          	auipc	a3,0xaf
ffffffffc0204e28:	9cc6b683          	ld	a3,-1588(a3) # ffffffffc02b37f0 <npage>
ffffffffc0204e2c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e30:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e32:	02d77963          	bgeu	a4,a3,ffffffffc0204e64 <swapfs_read+0x74>
}
ffffffffc0204e36:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e38:	000af797          	auipc	a5,0xaf
ffffffffc0204e3c:	9d07b783          	ld	a5,-1584(a5) # ffffffffc02b3808 <va_pa_offset>
ffffffffc0204e40:	46a1                	li	a3,8
ffffffffc0204e42:	963e                	add	a2,a2,a5
ffffffffc0204e44:	4505                	li	a0,1
}
ffffffffc0204e46:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e48:	fb0fb06f          	j	ffffffffc02005f8 <ide_read_secs>
ffffffffc0204e4c:	86aa                	mv	a3,a0
ffffffffc0204e4e:	00004617          	auipc	a2,0x4
ffffffffc0204e52:	90a60613          	addi	a2,a2,-1782 # ffffffffc0208758 <default_pmm_manager+0x11e0>
ffffffffc0204e56:	45d1                	li	a1,20
ffffffffc0204e58:	00004517          	auipc	a0,0x4
ffffffffc0204e5c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0208740 <default_pmm_manager+0x11c8>
ffffffffc0204e60:	e1afb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204e64:	86b2                	mv	a3,a2
ffffffffc0204e66:	06900593          	li	a1,105
ffffffffc0204e6a:	00002617          	auipc	a2,0x2
ffffffffc0204e6e:	74660613          	addi	a2,a2,1862 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0204e72:	00002517          	auipc	a0,0x2
ffffffffc0204e76:	76650513          	addi	a0,a0,1894 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0204e7a:	e00fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204e7e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204e7e:	1141                	addi	sp,sp,-16
ffffffffc0204e80:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e82:	00855793          	srli	a5,a0,0x8
ffffffffc0204e86:	cbb1                	beqz	a5,ffffffffc0204eda <swapfs_write+0x5c>
ffffffffc0204e88:	000af717          	auipc	a4,0xaf
ffffffffc0204e8c:	98873703          	ld	a4,-1656(a4) # ffffffffc02b3810 <max_swap_offset>
ffffffffc0204e90:	04e7f563          	bgeu	a5,a4,ffffffffc0204eda <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204e94:	000af617          	auipc	a2,0xaf
ffffffffc0204e98:	96463603          	ld	a2,-1692(a2) # ffffffffc02b37f8 <pages>
ffffffffc0204e9c:	8d91                	sub	a1,a1,a2
ffffffffc0204e9e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204ea2:	00004717          	auipc	a4,0x4
ffffffffc0204ea6:	1f673703          	ld	a4,502(a4) # ffffffffc0209098 <nbase>
ffffffffc0204eaa:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204eac:	00c61713          	slli	a4,a2,0xc
ffffffffc0204eb0:	8331                	srli	a4,a4,0xc
ffffffffc0204eb2:	000af697          	auipc	a3,0xaf
ffffffffc0204eb6:	93e6b683          	ld	a3,-1730(a3) # ffffffffc02b37f0 <npage>
ffffffffc0204eba:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ebe:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204ec0:	02d77963          	bgeu	a4,a3,ffffffffc0204ef2 <swapfs_write+0x74>
}
ffffffffc0204ec4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ec6:	000af797          	auipc	a5,0xaf
ffffffffc0204eca:	9427b783          	ld	a5,-1726(a5) # ffffffffc02b3808 <va_pa_offset>
ffffffffc0204ece:	46a1                	li	a3,8
ffffffffc0204ed0:	963e                	add	a2,a2,a5
ffffffffc0204ed2:	4505                	li	a0,1
}
ffffffffc0204ed4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ed6:	f46fb06f          	j	ffffffffc020061c <ide_write_secs>
ffffffffc0204eda:	86aa                	mv	a3,a0
ffffffffc0204edc:	00004617          	auipc	a2,0x4
ffffffffc0204ee0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0208758 <default_pmm_manager+0x11e0>
ffffffffc0204ee4:	45e5                	li	a1,25
ffffffffc0204ee6:	00004517          	auipc	a0,0x4
ffffffffc0204eea:	85a50513          	addi	a0,a0,-1958 # ffffffffc0208740 <default_pmm_manager+0x11c8>
ffffffffc0204eee:	d8cfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204ef2:	86b2                	mv	a3,a2
ffffffffc0204ef4:	06900593          	li	a1,105
ffffffffc0204ef8:	00002617          	auipc	a2,0x2
ffffffffc0204efc:	6b860613          	addi	a2,a2,1720 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0204f00:	00002517          	auipc	a0,0x2
ffffffffc0204f04:	6d850513          	addi	a0,a0,1752 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0204f08:	d72fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204f0c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204f0c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204f0e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204f10:	642000ef          	jal	ra,ffffffffc0205552 <do_exit>

ffffffffc0204f14 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204f14:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204f16:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204f1a:	e022                	sd	s0,0(sp)
ffffffffc0204f1c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204f1e:	be5fc0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204f22:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204f24:	cd21                	beqz	a0,ffffffffc0204f7c <alloc_proc+0x68>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;
ffffffffc0204f26:	57fd                	li	a5,-1
ffffffffc0204f28:	1782                	slli	a5,a5,0x20
ffffffffc0204f2a:	e11c                	sd	a5,0(a0)
    proc->cptr = NULL;
    proc->yptr = NULL;
    proc->optr = NULL;
   
    //初始化上下文
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204f2c:	07000613          	li	a2,112
ffffffffc0204f30:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204f32:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204f36:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204f3a:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204f3e:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204f42:	02053423          	sd	zero,40(a0)
    proc->exit_code = 0;
ffffffffc0204f46:	0e053423          	sd	zero,232(a0)
    proc->cptr = NULL;
ffffffffc0204f4a:	0e053823          	sd	zero,240(a0)
    proc->yptr = NULL;
ffffffffc0204f4e:	0e053c23          	sd	zero,248(a0)
    proc->optr = NULL;
ffffffffc0204f52:	10053023          	sd	zero,256(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204f56:	03050513          	addi	a0,a0,48
ffffffffc0204f5a:	09f010ef          	jal	ra,ffffffffc02067f8 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204f5e:	000af797          	auipc	a5,0xaf
ffffffffc0204f62:	8827b783          	ld	a5,-1918(a5) # ffffffffc02b37e0 <boot_cr3>
    proc->tf = NULL;
ffffffffc0204f66:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204f6a:	f45c                	sd	a5,168(s0)
    proc->flags = 0;
ffffffffc0204f6c:	0a042823          	sw	zero,176(s0)
    //初始化上下文
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204f70:	463d                	li	a2,15
ffffffffc0204f72:	4581                	li	a1,0
ffffffffc0204f74:	0b440513          	addi	a0,s0,180
ffffffffc0204f78:	081010ef          	jal	ra,ffffffffc02067f8 <memset>
    }
    return proc;
}
ffffffffc0204f7c:	60a2                	ld	ra,8(sp)
ffffffffc0204f7e:	8522                	mv	a0,s0
ffffffffc0204f80:	6402                	ld	s0,0(sp)
ffffffffc0204f82:	0141                	addi	sp,sp,16
ffffffffc0204f84:	8082                	ret

ffffffffc0204f86 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204f86:	000af797          	auipc	a5,0xaf
ffffffffc0204f8a:	8ba7b783          	ld	a5,-1862(a5) # ffffffffc02b3840 <current>
ffffffffc0204f8e:	73c8                	ld	a0,160(a5)
ffffffffc0204f90:	de7fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204f94 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f94:	000af797          	auipc	a5,0xaf
ffffffffc0204f98:	8ac7b783          	ld	a5,-1876(a5) # ffffffffc02b3840 <current>
ffffffffc0204f9c:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204f9e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204fa0:	00003617          	auipc	a2,0x3
ffffffffc0204fa4:	7d860613          	addi	a2,a2,2008 # ffffffffc0208778 <default_pmm_manager+0x1200>
ffffffffc0204fa8:	00003517          	auipc	a0,0x3
ffffffffc0204fac:	7e050513          	addi	a0,a0,2016 # ffffffffc0208788 <default_pmm_manager+0x1210>
user_main(void *arg) {
ffffffffc0204fb0:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204fb2:	9cefb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0204fb6:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204fba:	9b278793          	addi	a5,a5,-1614 # a968 <_binary_obj___user_forktest_out_size>
ffffffffc0204fbe:	e43e                	sd	a5,8(sp)
ffffffffc0204fc0:	00003517          	auipc	a0,0x3
ffffffffc0204fc4:	7b850513          	addi	a0,a0,1976 # ffffffffc0208778 <default_pmm_manager+0x1200>
ffffffffc0204fc8:	00046797          	auipc	a5,0x46
ffffffffc0204fcc:	73878793          	addi	a5,a5,1848 # ffffffffc024b700 <_binary_obj___user_forktest_out_start>
ffffffffc0204fd0:	f03e                	sd	a5,32(sp)
ffffffffc0204fd2:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204fd4:	e802                	sd	zero,16(sp)
ffffffffc0204fd6:	7a6010ef          	jal	ra,ffffffffc020677c <strlen>
ffffffffc0204fda:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204fdc:	4511                	li	a0,4
ffffffffc0204fde:	55a2                	lw	a1,40(sp)
ffffffffc0204fe0:	4662                	lw	a2,24(sp)
ffffffffc0204fe2:	5682                	lw	a3,32(sp)
ffffffffc0204fe4:	4722                	lw	a4,8(sp)
ffffffffc0204fe6:	48a9                	li	a7,10
ffffffffc0204fe8:	9002                	ebreak
ffffffffc0204fea:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204fec:	65c2                	ld	a1,16(sp)
ffffffffc0204fee:	00003517          	auipc	a0,0x3
ffffffffc0204ff2:	7c250513          	addi	a0,a0,1986 # ffffffffc02087b0 <default_pmm_manager+0x1238>
ffffffffc0204ff6:	98afb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204ffa:	00003617          	auipc	a2,0x3
ffffffffc0204ffe:	7c660613          	addi	a2,a2,1990 # ffffffffc02087c0 <default_pmm_manager+0x1248>
ffffffffc0205002:	35600593          	li	a1,854
ffffffffc0205006:	00003517          	auipc	a0,0x3
ffffffffc020500a:	7da50513          	addi	a0,a0,2010 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020500e:	c6cfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205012 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0205012:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0205014:	1141                	addi	sp,sp,-16
ffffffffc0205016:	e406                	sd	ra,8(sp)
ffffffffc0205018:	c02007b7          	lui	a5,0xc0200
ffffffffc020501c:	02f6ee63          	bltu	a3,a5,ffffffffc0205058 <put_pgdir+0x46>
ffffffffc0205020:	000ae517          	auipc	a0,0xae
ffffffffc0205024:	7e853503          	ld	a0,2024(a0) # ffffffffc02b3808 <va_pa_offset>
ffffffffc0205028:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc020502a:	82b1                	srli	a3,a3,0xc
ffffffffc020502c:	000ae797          	auipc	a5,0xae
ffffffffc0205030:	7c47b783          	ld	a5,1988(a5) # ffffffffc02b37f0 <npage>
ffffffffc0205034:	02f6fe63          	bgeu	a3,a5,ffffffffc0205070 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0205038:	00004517          	auipc	a0,0x4
ffffffffc020503c:	06053503          	ld	a0,96(a0) # ffffffffc0209098 <nbase>
}
ffffffffc0205040:	60a2                	ld	ra,8(sp)
ffffffffc0205042:	8e89                	sub	a3,a3,a0
ffffffffc0205044:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0205046:	000ae517          	auipc	a0,0xae
ffffffffc020504a:	7b253503          	ld	a0,1970(a0) # ffffffffc02b37f8 <pages>
ffffffffc020504e:	4585                	li	a1,1
ffffffffc0205050:	9536                	add	a0,a0,a3
}
ffffffffc0205052:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0205054:	d1ffc06f          	j	ffffffffc0201d72 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0205058:	00002617          	auipc	a2,0x2
ffffffffc020505c:	60060613          	addi	a2,a2,1536 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc0205060:	06e00593          	li	a1,110
ffffffffc0205064:	00002517          	auipc	a0,0x2
ffffffffc0205068:	57450513          	addi	a0,a0,1396 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc020506c:	c0efb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205070:	00002617          	auipc	a2,0x2
ffffffffc0205074:	61060613          	addi	a2,a2,1552 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc0205078:	06200593          	li	a1,98
ffffffffc020507c:	00002517          	auipc	a0,0x2
ffffffffc0205080:	55c50513          	addi	a0,a0,1372 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0205084:	bf6fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205088 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0205088:	7179                	addi	sp,sp,-48
ffffffffc020508a:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc020508c:	000ae917          	auipc	s2,0xae
ffffffffc0205090:	7b490913          	addi	s2,s2,1972 # ffffffffc02b3840 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0205094:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0205096:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc020509a:	f406                	sd	ra,40(sp)
ffffffffc020509c:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc020509e:	02a48863          	beq	s1,a0,ffffffffc02050ce <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050a2:	100027f3          	csrr	a5,sstatus
ffffffffc02050a6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050a8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050aa:	ef9d                	bnez	a5,ffffffffc02050e8 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc02050ac:	755c                	ld	a5,168(a0)
ffffffffc02050ae:	577d                	li	a4,-1
ffffffffc02050b0:	177e                	slli	a4,a4,0x3f
ffffffffc02050b2:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc02050b4:	00a93023          	sd	a0,0(s2)
ffffffffc02050b8:	8fd9                	or	a5,a5,a4
ffffffffc02050ba:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc02050be:	03050593          	addi	a1,a0,48
ffffffffc02050c2:	03048513          	addi	a0,s1,48
ffffffffc02050c6:	05c010ef          	jal	ra,ffffffffc0206122 <switch_to>
    if (flag) {
ffffffffc02050ca:	00099863          	bnez	s3,ffffffffc02050da <proc_run+0x52>
}
ffffffffc02050ce:	70a2                	ld	ra,40(sp)
ffffffffc02050d0:	7482                	ld	s1,32(sp)
ffffffffc02050d2:	6962                	ld	s2,24(sp)
ffffffffc02050d4:	69c2                	ld	s3,16(sp)
ffffffffc02050d6:	6145                	addi	sp,sp,48
ffffffffc02050d8:	8082                	ret
ffffffffc02050da:	70a2                	ld	ra,40(sp)
ffffffffc02050dc:	7482                	ld	s1,32(sp)
ffffffffc02050de:	6962                	ld	s2,24(sp)
ffffffffc02050e0:	69c2                	ld	s3,16(sp)
ffffffffc02050e2:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02050e4:	d5cfb06f          	j	ffffffffc0200640 <intr_enable>
ffffffffc02050e8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02050ea:	d5cfb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc02050ee:	6522                	ld	a0,8(sp)
ffffffffc02050f0:	4985                	li	s3,1
ffffffffc02050f2:	bf6d                	j	ffffffffc02050ac <proc_run+0x24>

ffffffffc02050f4 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02050f4:	7159                	addi	sp,sp,-112
ffffffffc02050f6:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02050f8:	000ae917          	auipc	s2,0xae
ffffffffc02050fc:	76090913          	addi	s2,s2,1888 # ffffffffc02b3858 <nr_process>
ffffffffc0205100:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205104:	f486                	sd	ra,104(sp)
ffffffffc0205106:	f0a2                	sd	s0,96(sp)
ffffffffc0205108:	eca6                	sd	s1,88(sp)
ffffffffc020510a:	e4ce                	sd	s3,72(sp)
ffffffffc020510c:	e0d2                	sd	s4,64(sp)
ffffffffc020510e:	fc56                	sd	s5,56(sp)
ffffffffc0205110:	f85a                	sd	s6,48(sp)
ffffffffc0205112:	f45e                	sd	s7,40(sp)
ffffffffc0205114:	f062                	sd	s8,32(sp)
ffffffffc0205116:	ec66                	sd	s9,24(sp)
ffffffffc0205118:	e86a                	sd	s10,16(sp)
ffffffffc020511a:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020511c:	6785                	lui	a5,0x1
ffffffffc020511e:	34f75063          	bge	a4,a5,ffffffffc020545e <do_fork+0x36a>
ffffffffc0205122:	8a2a                	mv	s4,a0
ffffffffc0205124:	89ae                	mv	s3,a1
ffffffffc0205126:	8432                	mv	s0,a2
    if((proc =  alloc_proc()) == NULL){
ffffffffc0205128:	dedff0ef          	jal	ra,ffffffffc0204f14 <alloc_proc>
ffffffffc020512c:	84aa                	mv	s1,a0
ffffffffc020512e:	2c050863          	beqz	a0,ffffffffc02053fe <do_fork+0x30a>
    proc->parent = current; //
ffffffffc0205132:	000aea97          	auipc	s5,0xae
ffffffffc0205136:	70ea8a93          	addi	s5,s5,1806 # ffffffffc02b3840 <current>
ffffffffc020513a:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc020513e:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current; //
ffffffffc0205142:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205144:	38071363          	bnez	a4,ffffffffc02054ca <do_fork+0x3d6>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205148:	4509                	li	a0,2
ffffffffc020514a:	b97fc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
    if (page != NULL) {
ffffffffc020514e:	2c050763          	beqz	a0,ffffffffc020541c <do_fork+0x328>
    return page - pages + nbase;
ffffffffc0205152:	000aed97          	auipc	s11,0xae
ffffffffc0205156:	6a6d8d93          	addi	s11,s11,1702 # ffffffffc02b37f8 <pages>
ffffffffc020515a:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc020515e:	000aed17          	auipc	s10,0xae
ffffffffc0205162:	692d0d13          	addi	s10,s10,1682 # ffffffffc02b37f0 <npage>
    return page - pages + nbase;
ffffffffc0205166:	00004c97          	auipc	s9,0x4
ffffffffc020516a:	f32cbc83          	ld	s9,-206(s9) # ffffffffc0209098 <nbase>
ffffffffc020516e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205172:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205174:	5c7d                	li	s8,-1
ffffffffc0205176:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc020517a:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc020517c:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0205180:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0205184:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205186:	30f77963          	bgeu	a4,a5,ffffffffc0205498 <do_fork+0x3a4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020518a:	000ab703          	ld	a4,0(s5)
ffffffffc020518e:	000aea97          	auipc	s5,0xae
ffffffffc0205192:	67aa8a93          	addi	s5,s5,1658 # ffffffffc02b3808 <va_pa_offset>
ffffffffc0205196:	000ab783          	ld	a5,0(s5)
ffffffffc020519a:	02873b83          	ld	s7,40(a4)
ffffffffc020519e:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02051a0:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc02051a2:	020b8863          	beqz	s7,ffffffffc02051d2 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc02051a6:	100a7a13          	andi	s4,s4,256
ffffffffc02051aa:	1c0a0163          	beqz	s4,ffffffffc020536c <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02051ae:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02051b2:	018bb783          	ld	a5,24(s7)
ffffffffc02051b6:	c02006b7          	lui	a3,0xc0200
ffffffffc02051ba:	2705                	addiw	a4,a4,1
ffffffffc02051bc:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc02051c0:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02051c4:	2ed7e663          	bltu	a5,a3,ffffffffc02054b0 <do_fork+0x3bc>
ffffffffc02051c8:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02051cc:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02051ce:	8f99                	sub	a5,a5,a4
ffffffffc02051d0:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02051d2:	6789                	lui	a5,0x2
ffffffffc02051d4:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc02051d8:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02051da:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02051dc:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc02051de:	87b6                	mv	a5,a3
ffffffffc02051e0:	12040893          	addi	a7,s0,288
ffffffffc02051e4:	00063803          	ld	a6,0(a2)
ffffffffc02051e8:	6608                	ld	a0,8(a2)
ffffffffc02051ea:	6a0c                	ld	a1,16(a2)
ffffffffc02051ec:	6e18                	ld	a4,24(a2)
ffffffffc02051ee:	0107b023          	sd	a6,0(a5)
ffffffffc02051f2:	e788                	sd	a0,8(a5)
ffffffffc02051f4:	eb8c                	sd	a1,16(a5)
ffffffffc02051f6:	ef98                	sd	a4,24(a5)
ffffffffc02051f8:	02060613          	addi	a2,a2,32
ffffffffc02051fc:	02078793          	addi	a5,a5,32
ffffffffc0205200:	ff1612e3          	bne	a2,a7,ffffffffc02051e4 <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc0205204:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205208:	12098f63          	beqz	s3,ffffffffc0205346 <do_fork+0x252>
ffffffffc020520c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205210:	00000797          	auipc	a5,0x0
ffffffffc0205214:	d7678793          	addi	a5,a5,-650 # ffffffffc0204f86 <forkret>
ffffffffc0205218:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020521a:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020521c:	100027f3          	csrr	a5,sstatus
ffffffffc0205220:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205222:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205224:	14079063          	bnez	a5,ffffffffc0205364 <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205228:	000a3817          	auipc	a6,0xa3
ffffffffc020522c:	0c880813          	addi	a6,a6,200 # ffffffffc02a82f0 <last_pid.1>
ffffffffc0205230:	00082783          	lw	a5,0(a6)
ffffffffc0205234:	6709                	lui	a4,0x2
ffffffffc0205236:	0017851b          	addiw	a0,a5,1
ffffffffc020523a:	00a82023          	sw	a0,0(a6)
ffffffffc020523e:	08e55d63          	bge	a0,a4,ffffffffc02052d8 <do_fork+0x1e4>
    if (last_pid >= next_safe) {
ffffffffc0205242:	000a3317          	auipc	t1,0xa3
ffffffffc0205246:	0b230313          	addi	t1,t1,178 # ffffffffc02a82f4 <next_safe.0>
ffffffffc020524a:	00032783          	lw	a5,0(t1)
ffffffffc020524e:	000ae417          	auipc	s0,0xae
ffffffffc0205252:	56240413          	addi	s0,s0,1378 # ffffffffc02b37b0 <proc_list>
ffffffffc0205256:	08f55963          	bge	a0,a5,ffffffffc02052e8 <do_fork+0x1f4>
        proc->pid = get_pid();
ffffffffc020525a:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020525c:	45a9                	li	a1,10
ffffffffc020525e:	2501                	sext.w	a0,a0
ffffffffc0205260:	118010ef          	jal	ra,ffffffffc0206378 <hash32>
ffffffffc0205264:	02051793          	slli	a5,a0,0x20
ffffffffc0205268:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020526c:	000aa797          	auipc	a5,0xaa
ffffffffc0205270:	54478793          	addi	a5,a5,1348 # ffffffffc02af7b0 <hash_list>
ffffffffc0205274:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205276:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205278:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020527a:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc020527e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205280:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0205282:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205284:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205286:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc020528a:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc020528c:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc020528e:	e21c                	sd	a5,0(a2)
ffffffffc0205290:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0205292:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0205294:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0205296:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020529a:	10e4b023          	sd	a4,256(s1)
ffffffffc020529e:	c311                	beqz	a4,ffffffffc02052a2 <do_fork+0x1ae>
        proc->optr->yptr = proc;
ffffffffc02052a0:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc02052a2:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02052a6:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc02052a8:	2785                	addiw	a5,a5,1
ffffffffc02052aa:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc02052ae:	14099a63          	bnez	s3,ffffffffc0205402 <do_fork+0x30e>
    wakeup_proc(proc);
ffffffffc02052b2:	8526                	mv	a0,s1
ffffffffc02052b4:	6d9000ef          	jal	ra,ffffffffc020618c <wakeup_proc>
    ret = proc->pid;
ffffffffc02052b8:	40c8                	lw	a0,4(s1)
}
ffffffffc02052ba:	70a6                	ld	ra,104(sp)
ffffffffc02052bc:	7406                	ld	s0,96(sp)
ffffffffc02052be:	64e6                	ld	s1,88(sp)
ffffffffc02052c0:	6946                	ld	s2,80(sp)
ffffffffc02052c2:	69a6                	ld	s3,72(sp)
ffffffffc02052c4:	6a06                	ld	s4,64(sp)
ffffffffc02052c6:	7ae2                	ld	s5,56(sp)
ffffffffc02052c8:	7b42                	ld	s6,48(sp)
ffffffffc02052ca:	7ba2                	ld	s7,40(sp)
ffffffffc02052cc:	7c02                	ld	s8,32(sp)
ffffffffc02052ce:	6ce2                	ld	s9,24(sp)
ffffffffc02052d0:	6d42                	ld	s10,16(sp)
ffffffffc02052d2:	6da2                	ld	s11,8(sp)
ffffffffc02052d4:	6165                	addi	sp,sp,112
ffffffffc02052d6:	8082                	ret
        last_pid = 1;
ffffffffc02052d8:	4785                	li	a5,1
ffffffffc02052da:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02052de:	4505                	li	a0,1
ffffffffc02052e0:	000a3317          	auipc	t1,0xa3
ffffffffc02052e4:	01430313          	addi	t1,t1,20 # ffffffffc02a82f4 <next_safe.0>
    return listelm->next;
ffffffffc02052e8:	000ae417          	auipc	s0,0xae
ffffffffc02052ec:	4c840413          	addi	s0,s0,1224 # ffffffffc02b37b0 <proc_list>
ffffffffc02052f0:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02052f4:	6789                	lui	a5,0x2
ffffffffc02052f6:	00f32023          	sw	a5,0(t1)
ffffffffc02052fa:	86aa                	mv	a3,a0
ffffffffc02052fc:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc02052fe:	6e89                	lui	t4,0x2
ffffffffc0205300:	108e0963          	beq	t3,s0,ffffffffc0205412 <do_fork+0x31e>
ffffffffc0205304:	88ae                	mv	a7,a1
ffffffffc0205306:	87f2                	mv	a5,t3
ffffffffc0205308:	6609                	lui	a2,0x2
ffffffffc020530a:	a811                	j	ffffffffc020531e <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020530c:	00e6d663          	bge	a3,a4,ffffffffc0205318 <do_fork+0x224>
ffffffffc0205310:	00c75463          	bge	a4,a2,ffffffffc0205318 <do_fork+0x224>
ffffffffc0205314:	863a                	mv	a2,a4
ffffffffc0205316:	4885                	li	a7,1
ffffffffc0205318:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020531a:	00878d63          	beq	a5,s0,ffffffffc0205334 <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc020531e:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc0205322:	fed715e3          	bne	a4,a3,ffffffffc020530c <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc0205326:	2685                	addiw	a3,a3,1
ffffffffc0205328:	0ec6d063          	bge	a3,a2,ffffffffc0205408 <do_fork+0x314>
ffffffffc020532c:	679c                	ld	a5,8(a5)
ffffffffc020532e:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205330:	fe8797e3          	bne	a5,s0,ffffffffc020531e <do_fork+0x22a>
ffffffffc0205334:	c581                	beqz	a1,ffffffffc020533c <do_fork+0x248>
ffffffffc0205336:	00d82023          	sw	a3,0(a6)
ffffffffc020533a:	8536                	mv	a0,a3
ffffffffc020533c:	f0088fe3          	beqz	a7,ffffffffc020525a <do_fork+0x166>
ffffffffc0205340:	00c32023          	sw	a2,0(t1)
ffffffffc0205344:	bf19                	j	ffffffffc020525a <do_fork+0x166>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205346:	89b6                	mv	s3,a3
ffffffffc0205348:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020534c:	00000797          	auipc	a5,0x0
ffffffffc0205350:	c3a78793          	addi	a5,a5,-966 # ffffffffc0204f86 <forkret>
ffffffffc0205354:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205356:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205358:	100027f3          	csrr	a5,sstatus
ffffffffc020535c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020535e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205360:	ec0784e3          	beqz	a5,ffffffffc0205228 <do_fork+0x134>
        intr_disable();
ffffffffc0205364:	ae2fb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205368:	4985                	li	s3,1
ffffffffc020536a:	bd7d                	j	ffffffffc0205228 <do_fork+0x134>
    if ((mm = mm_create()) == NULL) {
ffffffffc020536c:	e9bfe0ef          	jal	ra,ffffffffc0204206 <mm_create>
ffffffffc0205370:	8b2a                	mv	s6,a0
ffffffffc0205372:	c159                	beqz	a0,ffffffffc02053f8 <do_fork+0x304>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205374:	4505                	li	a0,1
ffffffffc0205376:	96bfc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc020537a:	cd25                	beqz	a0,ffffffffc02053f2 <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc020537c:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0205380:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0205384:	40d506b3          	sub	a3,a0,a3
ffffffffc0205388:	8699                	srai	a3,a3,0x6
ffffffffc020538a:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc020538c:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0205390:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205392:	10fc7363          	bgeu	s8,a5,ffffffffc0205498 <do_fork+0x3a4>
ffffffffc0205396:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020539a:	6605                	lui	a2,0x1
ffffffffc020539c:	000ae597          	auipc	a1,0xae
ffffffffc02053a0:	44c5b583          	ld	a1,1100(a1) # ffffffffc02b37e8 <boot_pgdir>
ffffffffc02053a4:	9a36                	add	s4,s4,a3
ffffffffc02053a6:	8552                	mv	a0,s4
ffffffffc02053a8:	462010ef          	jal	ra,ffffffffc020680a <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02053ac:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc02053b0:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02053b4:	4785                	li	a5,1
ffffffffc02053b6:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02053ba:	8b85                	andi	a5,a5,1
ffffffffc02053bc:	4a05                	li	s4,1
ffffffffc02053be:	c799                	beqz	a5,ffffffffc02053cc <do_fork+0x2d8>
        schedule();
ffffffffc02053c0:	64d000ef          	jal	ra,ffffffffc020620c <schedule>
ffffffffc02053c4:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc02053c8:	8b85                	andi	a5,a5,1
ffffffffc02053ca:	fbfd                	bnez	a5,ffffffffc02053c0 <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc02053cc:	85de                	mv	a1,s7
ffffffffc02053ce:	855a                	mv	a0,s6
ffffffffc02053d0:	8beff0ef          	jal	ra,ffffffffc020448e <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02053d4:	57f9                	li	a5,-2
ffffffffc02053d6:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc02053da:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02053dc:	10078763          	beqz	a5,ffffffffc02054ea <do_fork+0x3f6>
good_mm:
ffffffffc02053e0:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc02053e2:	dc0506e3          	beqz	a0,ffffffffc02051ae <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02053e6:	855a                	mv	a0,s6
ffffffffc02053e8:	940ff0ef          	jal	ra,ffffffffc0204528 <exit_mmap>
    put_pgdir(mm);
ffffffffc02053ec:	855a                	mv	a0,s6
ffffffffc02053ee:	c25ff0ef          	jal	ra,ffffffffc0205012 <put_pgdir>
    mm_destroy(mm);
ffffffffc02053f2:	855a                	mv	a0,s6
ffffffffc02053f4:	f99fe0ef          	jal	ra,ffffffffc020438c <mm_destroy>
    kfree(proc);
ffffffffc02053f8:	8526                	mv	a0,s1
ffffffffc02053fa:	fb8fc0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    ret = -E_NO_MEM;
ffffffffc02053fe:	5571                	li	a0,-4
    return ret;
ffffffffc0205400:	bd6d                	j	ffffffffc02052ba <do_fork+0x1c6>
        intr_enable();
ffffffffc0205402:	a3efb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0205406:	b575                	j	ffffffffc02052b2 <do_fork+0x1be>
                    if (last_pid >= MAX_PID) {
ffffffffc0205408:	01d6c363          	blt	a3,t4,ffffffffc020540e <do_fork+0x31a>
                        last_pid = 1;
ffffffffc020540c:	4685                	li	a3,1
                    goto repeat;
ffffffffc020540e:	4585                	li	a1,1
ffffffffc0205410:	bdc5                	j	ffffffffc0205300 <do_fork+0x20c>
ffffffffc0205412:	c9a1                	beqz	a1,ffffffffc0205462 <do_fork+0x36e>
ffffffffc0205414:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0205418:	8536                	mv	a0,a3
ffffffffc020541a:	b581                	j	ffffffffc020525a <do_fork+0x166>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020541c:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc020541e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205422:	04f6ef63          	bltu	a3,a5,ffffffffc0205480 <do_fork+0x38c>
ffffffffc0205426:	000ae797          	auipc	a5,0xae
ffffffffc020542a:	3e27b783          	ld	a5,994(a5) # ffffffffc02b3808 <va_pa_offset>
ffffffffc020542e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205432:	83b1                	srli	a5,a5,0xc
ffffffffc0205434:	000ae717          	auipc	a4,0xae
ffffffffc0205438:	3bc73703          	ld	a4,956(a4) # ffffffffc02b37f0 <npage>
ffffffffc020543c:	02e7f663          	bgeu	a5,a4,ffffffffc0205468 <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc0205440:	00004717          	auipc	a4,0x4
ffffffffc0205444:	c5873703          	ld	a4,-936(a4) # ffffffffc0209098 <nbase>
ffffffffc0205448:	8f99                	sub	a5,a5,a4
ffffffffc020544a:	079a                	slli	a5,a5,0x6
ffffffffc020544c:	000ae517          	auipc	a0,0xae
ffffffffc0205450:	3ac53503          	ld	a0,940(a0) # ffffffffc02b37f8 <pages>
ffffffffc0205454:	4589                	li	a1,2
ffffffffc0205456:	953e                	add	a0,a0,a5
ffffffffc0205458:	91bfc0ef          	jal	ra,ffffffffc0201d72 <free_pages>
}
ffffffffc020545c:	bf71                	j	ffffffffc02053f8 <do_fork+0x304>
    int ret = -E_NO_FREE_PROC;
ffffffffc020545e:	556d                	li	a0,-5
ffffffffc0205460:	bda9                	j	ffffffffc02052ba <do_fork+0x1c6>
    return last_pid;
ffffffffc0205462:	00082503          	lw	a0,0(a6)
ffffffffc0205466:	bbd5                	j	ffffffffc020525a <do_fork+0x166>
        panic("pa2page called with invalid pa");
ffffffffc0205468:	00002617          	auipc	a2,0x2
ffffffffc020546c:	21860613          	addi	a2,a2,536 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc0205470:	06200593          	li	a1,98
ffffffffc0205474:	00002517          	auipc	a0,0x2
ffffffffc0205478:	16450513          	addi	a0,a0,356 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc020547c:	ffffa0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205480:	00002617          	auipc	a2,0x2
ffffffffc0205484:	1d860613          	addi	a2,a2,472 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc0205488:	06e00593          	li	a1,110
ffffffffc020548c:	00002517          	auipc	a0,0x2
ffffffffc0205490:	14c50513          	addi	a0,a0,332 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0205494:	fe7fa0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0205498:	00002617          	auipc	a2,0x2
ffffffffc020549c:	11860613          	addi	a2,a2,280 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc02054a0:	06900593          	li	a1,105
ffffffffc02054a4:	00002517          	auipc	a0,0x2
ffffffffc02054a8:	13450513          	addi	a0,a0,308 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc02054ac:	fcffa0ef          	jal	ra,ffffffffc020047a <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02054b0:	86be                	mv	a3,a5
ffffffffc02054b2:	00002617          	auipc	a2,0x2
ffffffffc02054b6:	1a660613          	addi	a2,a2,422 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc02054ba:	16c00593          	li	a1,364
ffffffffc02054be:	00003517          	auipc	a0,0x3
ffffffffc02054c2:	32250513          	addi	a0,a0,802 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc02054c6:	fb5fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(current->wait_state == 0);
ffffffffc02054ca:	00003697          	auipc	a3,0x3
ffffffffc02054ce:	32e68693          	addi	a3,a3,814 # ffffffffc02087f8 <default_pmm_manager+0x1280>
ffffffffc02054d2:	00002617          	auipc	a2,0x2
ffffffffc02054d6:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02054da:	1b900593          	li	a1,441
ffffffffc02054de:	00003517          	auipc	a0,0x3
ffffffffc02054e2:	30250513          	addi	a0,a0,770 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc02054e6:	f95fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("Unlock failed.\n");
ffffffffc02054ea:	00003617          	auipc	a2,0x3
ffffffffc02054ee:	32e60613          	addi	a2,a2,814 # ffffffffc0208818 <default_pmm_manager+0x12a0>
ffffffffc02054f2:	03100593          	li	a1,49
ffffffffc02054f6:	00003517          	auipc	a0,0x3
ffffffffc02054fa:	33250513          	addi	a0,a0,818 # ffffffffc0208828 <default_pmm_manager+0x12b0>
ffffffffc02054fe:	f7dfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205502 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205502:	7129                	addi	sp,sp,-320
ffffffffc0205504:	fa22                	sd	s0,304(sp)
ffffffffc0205506:	f626                	sd	s1,296(sp)
ffffffffc0205508:	f24a                	sd	s2,288(sp)
ffffffffc020550a:	84ae                	mv	s1,a1
ffffffffc020550c:	892a                	mv	s2,a0
ffffffffc020550e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205510:	4581                	li	a1,0
ffffffffc0205512:	12000613          	li	a2,288
ffffffffc0205516:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205518:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020551a:	2de010ef          	jal	ra,ffffffffc02067f8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020551e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205520:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205522:	100027f3          	csrr	a5,sstatus
ffffffffc0205526:	edd7f793          	andi	a5,a5,-291
ffffffffc020552a:	1207e793          	ori	a5,a5,288
ffffffffc020552e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205530:	860a                	mv	a2,sp
ffffffffc0205532:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205536:	00000797          	auipc	a5,0x0
ffffffffc020553a:	9d678793          	addi	a5,a5,-1578 # ffffffffc0204f0c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020553e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205540:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205542:	bb3ff0ef          	jal	ra,ffffffffc02050f4 <do_fork>
}
ffffffffc0205546:	70f2                	ld	ra,312(sp)
ffffffffc0205548:	7452                	ld	s0,304(sp)
ffffffffc020554a:	74b2                	ld	s1,296(sp)
ffffffffc020554c:	7912                	ld	s2,288(sp)
ffffffffc020554e:	6131                	addi	sp,sp,320
ffffffffc0205550:	8082                	ret

ffffffffc0205552 <do_exit>:
do_exit(int error_code) {
ffffffffc0205552:	7179                	addi	sp,sp,-48
ffffffffc0205554:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205556:	000ae417          	auipc	s0,0xae
ffffffffc020555a:	2ea40413          	addi	s0,s0,746 # ffffffffc02b3840 <current>
ffffffffc020555e:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205560:	f406                	sd	ra,40(sp)
ffffffffc0205562:	ec26                	sd	s1,24(sp)
ffffffffc0205564:	e84a                	sd	s2,16(sp)
ffffffffc0205566:	e44e                	sd	s3,8(sp)
ffffffffc0205568:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020556a:	000ae717          	auipc	a4,0xae
ffffffffc020556e:	2de73703          	ld	a4,734(a4) # ffffffffc02b3848 <idleproc>
ffffffffc0205572:	0ce78c63          	beq	a5,a4,ffffffffc020564a <do_exit+0xf8>
    if (current == initproc) {
ffffffffc0205576:	000ae497          	auipc	s1,0xae
ffffffffc020557a:	2da48493          	addi	s1,s1,730 # ffffffffc02b3850 <initproc>
ffffffffc020557e:	6098                	ld	a4,0(s1)
ffffffffc0205580:	0ee78b63          	beq	a5,a4,ffffffffc0205676 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205584:	0287b983          	ld	s3,40(a5)
ffffffffc0205588:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020558a:	02098663          	beqz	s3,ffffffffc02055b6 <do_exit+0x64>
ffffffffc020558e:	000ae797          	auipc	a5,0xae
ffffffffc0205592:	2527b783          	ld	a5,594(a5) # ffffffffc02b37e0 <boot_cr3>
ffffffffc0205596:	577d                	li	a4,-1
ffffffffc0205598:	177e                	slli	a4,a4,0x3f
ffffffffc020559a:	83b1                	srli	a5,a5,0xc
ffffffffc020559c:	8fd9                	or	a5,a5,a4
ffffffffc020559e:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02055a2:	0309a783          	lw	a5,48(s3)
ffffffffc02055a6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02055aa:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02055ae:	cb55                	beqz	a4,ffffffffc0205662 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02055b0:	601c                	ld	a5,0(s0)
ffffffffc02055b2:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02055b6:	601c                	ld	a5,0(s0)
ffffffffc02055b8:	470d                	li	a4,3
ffffffffc02055ba:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02055bc:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055c0:	100027f3          	csrr	a5,sstatus
ffffffffc02055c4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055c6:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055c8:	e3f9                	bnez	a5,ffffffffc020568e <do_exit+0x13c>
        proc = current->parent;
ffffffffc02055ca:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055cc:	800007b7          	lui	a5,0x80000
ffffffffc02055d0:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02055d2:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055d4:	0ec52703          	lw	a4,236(a0)
ffffffffc02055d8:	0af70f63          	beq	a4,a5,ffffffffc0205696 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02055dc:	6018                	ld	a4,0(s0)
ffffffffc02055de:	7b7c                	ld	a5,240(a4)
ffffffffc02055e0:	c3a1                	beqz	a5,ffffffffc0205620 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055e2:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055e6:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055e8:	0985                	addi	s3,s3,1
ffffffffc02055ea:	a021                	j	ffffffffc02055f2 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02055ec:	6018                	ld	a4,0(s0)
ffffffffc02055ee:	7b7c                	ld	a5,240(a4)
ffffffffc02055f0:	cb85                	beqz	a5,ffffffffc0205620 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02055f2:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055f6:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02055f8:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055fa:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02055fc:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205600:	10e7b023          	sd	a4,256(a5)
ffffffffc0205604:	c311                	beqz	a4,ffffffffc0205608 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205606:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205608:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020560a:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020560c:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020560e:	fd271fe3          	bne	a4,s2,ffffffffc02055ec <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205612:	0ec52783          	lw	a5,236(a0)
ffffffffc0205616:	fd379be3          	bne	a5,s3,ffffffffc02055ec <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020561a:	373000ef          	jal	ra,ffffffffc020618c <wakeup_proc>
ffffffffc020561e:	b7f9                	j	ffffffffc02055ec <do_exit+0x9a>
    if (flag) {
ffffffffc0205620:	020a1263          	bnez	s4,ffffffffc0205644 <do_exit+0xf2>
    schedule();
ffffffffc0205624:	3e9000ef          	jal	ra,ffffffffc020620c <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205628:	601c                	ld	a5,0(s0)
ffffffffc020562a:	00003617          	auipc	a2,0x3
ffffffffc020562e:	23660613          	addi	a2,a2,566 # ffffffffc0208860 <default_pmm_manager+0x12e8>
ffffffffc0205632:	20c00593          	li	a1,524
ffffffffc0205636:	43d4                	lw	a3,4(a5)
ffffffffc0205638:	00003517          	auipc	a0,0x3
ffffffffc020563c:	1a850513          	addi	a0,a0,424 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205640:	e3bfa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc0205644:	ffdfa0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0205648:	bff1                	j	ffffffffc0205624 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020564a:	00003617          	auipc	a2,0x3
ffffffffc020564e:	1f660613          	addi	a2,a2,502 # ffffffffc0208840 <default_pmm_manager+0x12c8>
ffffffffc0205652:	1e000593          	li	a1,480
ffffffffc0205656:	00003517          	auipc	a0,0x3
ffffffffc020565a:	18a50513          	addi	a0,a0,394 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020565e:	e1dfa0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc0205662:	854e                	mv	a0,s3
ffffffffc0205664:	ec5fe0ef          	jal	ra,ffffffffc0204528 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205668:	854e                	mv	a0,s3
ffffffffc020566a:	9a9ff0ef          	jal	ra,ffffffffc0205012 <put_pgdir>
            mm_destroy(mm);
ffffffffc020566e:	854e                	mv	a0,s3
ffffffffc0205670:	d1dfe0ef          	jal	ra,ffffffffc020438c <mm_destroy>
ffffffffc0205674:	bf35                	j	ffffffffc02055b0 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0205676:	00003617          	auipc	a2,0x3
ffffffffc020567a:	1da60613          	addi	a2,a2,474 # ffffffffc0208850 <default_pmm_manager+0x12d8>
ffffffffc020567e:	1e300593          	li	a1,483
ffffffffc0205682:	00003517          	auipc	a0,0x3
ffffffffc0205686:	15e50513          	addi	a0,a0,350 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020568a:	df1fa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc020568e:	fb9fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205692:	4a05                	li	s4,1
ffffffffc0205694:	bf1d                	j	ffffffffc02055ca <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0205696:	2f7000ef          	jal	ra,ffffffffc020618c <wakeup_proc>
ffffffffc020569a:	b789                	j	ffffffffc02055dc <do_exit+0x8a>

ffffffffc020569c <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc020569c:	715d                	addi	sp,sp,-80
ffffffffc020569e:	f84a                	sd	s2,48(sp)
ffffffffc02056a0:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02056a2:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02056a6:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc02056a8:	fc26                	sd	s1,56(sp)
ffffffffc02056aa:	f052                	sd	s4,32(sp)
ffffffffc02056ac:	ec56                	sd	s5,24(sp)
ffffffffc02056ae:	e85a                	sd	s6,16(sp)
ffffffffc02056b0:	e45e                	sd	s7,8(sp)
ffffffffc02056b2:	e486                	sd	ra,72(sp)
ffffffffc02056b4:	e0a2                	sd	s0,64(sp)
ffffffffc02056b6:	84aa                	mv	s1,a0
ffffffffc02056b8:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02056ba:	000aeb97          	auipc	s7,0xae
ffffffffc02056be:	186b8b93          	addi	s7,s7,390 # ffffffffc02b3840 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02056c2:	00050b1b          	sext.w	s6,a0
ffffffffc02056c6:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02056ca:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02056cc:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02056ce:	ccbd                	beqz	s1,ffffffffc020574c <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02056d0:	0359e863          	bltu	s3,s5,ffffffffc0205700 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02056d4:	45a9                	li	a1,10
ffffffffc02056d6:	855a                	mv	a0,s6
ffffffffc02056d8:	4a1000ef          	jal	ra,ffffffffc0206378 <hash32>
ffffffffc02056dc:	02051793          	slli	a5,a0,0x20
ffffffffc02056e0:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02056e4:	000aa797          	auipc	a5,0xaa
ffffffffc02056e8:	0cc78793          	addi	a5,a5,204 # ffffffffc02af7b0 <hash_list>
ffffffffc02056ec:	953e                	add	a0,a0,a5
ffffffffc02056ee:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02056f0:	a029                	j	ffffffffc02056fa <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02056f2:	f2c42783          	lw	a5,-212(s0)
ffffffffc02056f6:	02978163          	beq	a5,s1,ffffffffc0205718 <do_wait.part.0+0x7c>
ffffffffc02056fa:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02056fc:	fe851be3          	bne	a0,s0,ffffffffc02056f2 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205700:	5579                	li	a0,-2
}
ffffffffc0205702:	60a6                	ld	ra,72(sp)
ffffffffc0205704:	6406                	ld	s0,64(sp)
ffffffffc0205706:	74e2                	ld	s1,56(sp)
ffffffffc0205708:	7942                	ld	s2,48(sp)
ffffffffc020570a:	79a2                	ld	s3,40(sp)
ffffffffc020570c:	7a02                	ld	s4,32(sp)
ffffffffc020570e:	6ae2                	ld	s5,24(sp)
ffffffffc0205710:	6b42                	ld	s6,16(sp)
ffffffffc0205712:	6ba2                	ld	s7,8(sp)
ffffffffc0205714:	6161                	addi	sp,sp,80
ffffffffc0205716:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205718:	000bb683          	ld	a3,0(s7)
ffffffffc020571c:	f4843783          	ld	a5,-184(s0)
ffffffffc0205720:	fed790e3          	bne	a5,a3,ffffffffc0205700 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205724:	f2842703          	lw	a4,-216(s0)
ffffffffc0205728:	478d                	li	a5,3
ffffffffc020572a:	0ef70b63          	beq	a4,a5,ffffffffc0205820 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020572e:	4785                	li	a5,1
ffffffffc0205730:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205732:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205736:	2d7000ef          	jal	ra,ffffffffc020620c <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020573a:	000bb783          	ld	a5,0(s7)
ffffffffc020573e:	0b07a783          	lw	a5,176(a5)
ffffffffc0205742:	8b85                	andi	a5,a5,1
ffffffffc0205744:	d7c9                	beqz	a5,ffffffffc02056ce <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205746:	555d                	li	a0,-9
ffffffffc0205748:	e0bff0ef          	jal	ra,ffffffffc0205552 <do_exit>
        proc = current->cptr;
ffffffffc020574c:	000bb683          	ld	a3,0(s7)
ffffffffc0205750:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205752:	d45d                	beqz	s0,ffffffffc0205700 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205754:	470d                	li	a4,3
ffffffffc0205756:	a021                	j	ffffffffc020575e <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205758:	10043403          	ld	s0,256(s0)
ffffffffc020575c:	d869                	beqz	s0,ffffffffc020572e <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020575e:	401c                	lw	a5,0(s0)
ffffffffc0205760:	fee79ce3          	bne	a5,a4,ffffffffc0205758 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205764:	000ae797          	auipc	a5,0xae
ffffffffc0205768:	0e47b783          	ld	a5,228(a5) # ffffffffc02b3848 <idleproc>
ffffffffc020576c:	0c878963          	beq	a5,s0,ffffffffc020583e <do_wait.part.0+0x1a2>
ffffffffc0205770:	000ae797          	auipc	a5,0xae
ffffffffc0205774:	0e07b783          	ld	a5,224(a5) # ffffffffc02b3850 <initproc>
ffffffffc0205778:	0cf40363          	beq	s0,a5,ffffffffc020583e <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc020577c:	000a0663          	beqz	s4,ffffffffc0205788 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205780:	0e842783          	lw	a5,232(s0)
ffffffffc0205784:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205788:	100027f3          	csrr	a5,sstatus
ffffffffc020578c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020578e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205790:	e7c1                	bnez	a5,ffffffffc0205818 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205792:	6c70                	ld	a2,216(s0)
ffffffffc0205794:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205796:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020579a:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020579c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020579e:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02057a0:	6470                	ld	a2,200(s0)
ffffffffc02057a2:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02057a4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02057a6:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc02057a8:	c319                	beqz	a4,ffffffffc02057ae <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02057aa:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc02057ac:	7c7c                	ld	a5,248(s0)
ffffffffc02057ae:	c3b5                	beqz	a5,ffffffffc0205812 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02057b0:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02057b4:	000ae717          	auipc	a4,0xae
ffffffffc02057b8:	0a470713          	addi	a4,a4,164 # ffffffffc02b3858 <nr_process>
ffffffffc02057bc:	431c                	lw	a5,0(a4)
ffffffffc02057be:	37fd                	addiw	a5,a5,-1
ffffffffc02057c0:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02057c2:	e5a9                	bnez	a1,ffffffffc020580c <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02057c4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02057c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02057ca:	04f6ee63          	bltu	a3,a5,ffffffffc0205826 <do_wait.part.0+0x18a>
ffffffffc02057ce:	000ae797          	auipc	a5,0xae
ffffffffc02057d2:	03a7b783          	ld	a5,58(a5) # ffffffffc02b3808 <va_pa_offset>
ffffffffc02057d6:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02057d8:	82b1                	srli	a3,a3,0xc
ffffffffc02057da:	000ae797          	auipc	a5,0xae
ffffffffc02057de:	0167b783          	ld	a5,22(a5) # ffffffffc02b37f0 <npage>
ffffffffc02057e2:	06f6fa63          	bgeu	a3,a5,ffffffffc0205856 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02057e6:	00004517          	auipc	a0,0x4
ffffffffc02057ea:	8b253503          	ld	a0,-1870(a0) # ffffffffc0209098 <nbase>
ffffffffc02057ee:	8e89                	sub	a3,a3,a0
ffffffffc02057f0:	069a                	slli	a3,a3,0x6
ffffffffc02057f2:	000ae517          	auipc	a0,0xae
ffffffffc02057f6:	00653503          	ld	a0,6(a0) # ffffffffc02b37f8 <pages>
ffffffffc02057fa:	9536                	add	a0,a0,a3
ffffffffc02057fc:	4589                	li	a1,2
ffffffffc02057fe:	d74fc0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    kfree(proc);
ffffffffc0205802:	8522                	mv	a0,s0
ffffffffc0205804:	baefc0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    return 0;
ffffffffc0205808:	4501                	li	a0,0
ffffffffc020580a:	bde5                	j	ffffffffc0205702 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc020580c:	e35fa0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0205810:	bf55                	j	ffffffffc02057c4 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0205812:	701c                	ld	a5,32(s0)
ffffffffc0205814:	fbf8                	sd	a4,240(a5)
ffffffffc0205816:	bf79                	j	ffffffffc02057b4 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205818:	e2ffa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020581c:	4585                	li	a1,1
ffffffffc020581e:	bf95                	j	ffffffffc0205792 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205820:	f2840413          	addi	s0,s0,-216
ffffffffc0205824:	b781                	j	ffffffffc0205764 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205826:	00002617          	auipc	a2,0x2
ffffffffc020582a:	e3260613          	addi	a2,a2,-462 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc020582e:	06e00593          	li	a1,110
ffffffffc0205832:	00002517          	auipc	a0,0x2
ffffffffc0205836:	da650513          	addi	a0,a0,-602 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc020583a:	c41fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc020583e:	00003617          	auipc	a2,0x3
ffffffffc0205842:	04260613          	addi	a2,a2,66 # ffffffffc0208880 <default_pmm_manager+0x1308>
ffffffffc0205846:	30400593          	li	a1,772
ffffffffc020584a:	00003517          	auipc	a0,0x3
ffffffffc020584e:	f9650513          	addi	a0,a0,-106 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205852:	c29fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205856:	00002617          	auipc	a2,0x2
ffffffffc020585a:	e2a60613          	addi	a2,a2,-470 # ffffffffc0207680 <default_pmm_manager+0x108>
ffffffffc020585e:	06200593          	li	a1,98
ffffffffc0205862:	00002517          	auipc	a0,0x2
ffffffffc0205866:	d7650513          	addi	a0,a0,-650 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc020586a:	c11fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020586e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020586e:	1141                	addi	sp,sp,-16
ffffffffc0205870:	e406                	sd	ra,8(sp)
    //call pmm->nr_free_pages to get the size (nr*PAGESIZE) of current free memory
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205872:	d40fc0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>

    size_t kernel_allocated_store = kallocated();
ffffffffc0205876:	a88fc0ef          	jal	ra,ffffffffc0201afe <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020587a:	4601                	li	a2,0
ffffffffc020587c:	4581                	li	a1,0
ffffffffc020587e:	fffff517          	auipc	a0,0xfffff
ffffffffc0205882:	71650513          	addi	a0,a0,1814 # ffffffffc0204f94 <user_main>
ffffffffc0205886:	c7dff0ef          	jal	ra,ffffffffc0205502 <kernel_thread>
    if (pid <= 0) {
ffffffffc020588a:	00a04563          	bgtz	a0,ffffffffc0205894 <init_main+0x26>
ffffffffc020588e:	a071                	j	ffffffffc020591a <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205890:	17d000ef          	jal	ra,ffffffffc020620c <schedule>
    if (code_store != NULL) {
ffffffffc0205894:	4581                	li	a1,0
ffffffffc0205896:	4501                	li	a0,0
ffffffffc0205898:	e05ff0ef          	jal	ra,ffffffffc020569c <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc020589c:	d975                	beqz	a0,ffffffffc0205890 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020589e:	00003517          	auipc	a0,0x3
ffffffffc02058a2:	02250513          	addi	a0,a0,34 # ffffffffc02088c0 <default_pmm_manager+0x1348>
ffffffffc02058a6:	8dbfa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058aa:	000ae797          	auipc	a5,0xae
ffffffffc02058ae:	fa67b783          	ld	a5,-90(a5) # ffffffffc02b3850 <initproc>
ffffffffc02058b2:	7bf8                	ld	a4,240(a5)
ffffffffc02058b4:	e339                	bnez	a4,ffffffffc02058fa <init_main+0x8c>
ffffffffc02058b6:	7ff8                	ld	a4,248(a5)
ffffffffc02058b8:	e329                	bnez	a4,ffffffffc02058fa <init_main+0x8c>
ffffffffc02058ba:	1007b703          	ld	a4,256(a5)
ffffffffc02058be:	ef15                	bnez	a4,ffffffffc02058fa <init_main+0x8c>
    //only have idleproc and initproc
    assert(nr_process == 2);
ffffffffc02058c0:	000ae697          	auipc	a3,0xae
ffffffffc02058c4:	f986a683          	lw	a3,-104(a3) # ffffffffc02b3858 <nr_process>
ffffffffc02058c8:	4709                	li	a4,2
ffffffffc02058ca:	0ae69463          	bne	a3,a4,ffffffffc0205972 <init_main+0x104>
    return listelm->next;
ffffffffc02058ce:	000ae697          	auipc	a3,0xae
ffffffffc02058d2:	ee268693          	addi	a3,a3,-286 # ffffffffc02b37b0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02058d6:	6698                	ld	a4,8(a3)
ffffffffc02058d8:	0c878793          	addi	a5,a5,200
ffffffffc02058dc:	06f71b63          	bne	a4,a5,ffffffffc0205952 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02058e0:	629c                	ld	a5,0(a3)
ffffffffc02058e2:	04f71863          	bne	a4,a5,ffffffffc0205932 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02058e6:	00003517          	auipc	a0,0x3
ffffffffc02058ea:	0c250513          	addi	a0,a0,194 # ffffffffc02089a8 <default_pmm_manager+0x1430>
ffffffffc02058ee:	893fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc02058f2:	60a2                	ld	ra,8(sp)
ffffffffc02058f4:	4501                	li	a0,0
ffffffffc02058f6:	0141                	addi	sp,sp,16
ffffffffc02058f8:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058fa:	00003697          	auipc	a3,0x3
ffffffffc02058fe:	fee68693          	addi	a3,a3,-18 # ffffffffc02088e8 <default_pmm_manager+0x1370>
ffffffffc0205902:	00001617          	auipc	a2,0x1
ffffffffc0205906:	5de60613          	addi	a2,a2,1502 # ffffffffc0206ee0 <commands+0x450>
ffffffffc020590a:	36b00593          	li	a1,875
ffffffffc020590e:	00003517          	auipc	a0,0x3
ffffffffc0205912:	ed250513          	addi	a0,a0,-302 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205916:	b65fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc020591a:	00003617          	auipc	a2,0x3
ffffffffc020591e:	f8660613          	addi	a2,a2,-122 # ffffffffc02088a0 <default_pmm_manager+0x1328>
ffffffffc0205922:	36300593          	li	a1,867
ffffffffc0205926:	00003517          	auipc	a0,0x3
ffffffffc020592a:	eba50513          	addi	a0,a0,-326 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020592e:	b4dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205932:	00003697          	auipc	a3,0x3
ffffffffc0205936:	04668693          	addi	a3,a3,70 # ffffffffc0208978 <default_pmm_manager+0x1400>
ffffffffc020593a:	00001617          	auipc	a2,0x1
ffffffffc020593e:	5a660613          	addi	a2,a2,1446 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205942:	36f00593          	li	a1,879
ffffffffc0205946:	00003517          	auipc	a0,0x3
ffffffffc020594a:	e9a50513          	addi	a0,a0,-358 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020594e:	b2dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205952:	00003697          	auipc	a3,0x3
ffffffffc0205956:	ff668693          	addi	a3,a3,-10 # ffffffffc0208948 <default_pmm_manager+0x13d0>
ffffffffc020595a:	00001617          	auipc	a2,0x1
ffffffffc020595e:	58660613          	addi	a2,a2,1414 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205962:	36e00593          	li	a1,878
ffffffffc0205966:	00003517          	auipc	a0,0x3
ffffffffc020596a:	e7a50513          	addi	a0,a0,-390 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020596e:	b0dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc0205972:	00003697          	auipc	a3,0x3
ffffffffc0205976:	fc668693          	addi	a3,a3,-58 # ffffffffc0208938 <default_pmm_manager+0x13c0>
ffffffffc020597a:	00001617          	auipc	a2,0x1
ffffffffc020597e:	56660613          	addi	a2,a2,1382 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205982:	36d00593          	li	a1,877
ffffffffc0205986:	00003517          	auipc	a0,0x3
ffffffffc020598a:	e5a50513          	addi	a0,a0,-422 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc020598e:	aedfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205992 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205992:	7171                	addi	sp,sp,-176
ffffffffc0205994:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205996:	000aed97          	auipc	s11,0xae
ffffffffc020599a:	eaad8d93          	addi	s11,s11,-342 # ffffffffc02b3840 <current>
ffffffffc020599e:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059a2:	e54e                	sd	s3,136(sp)
ffffffffc02059a4:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059a6:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059aa:	e94a                	sd	s2,144(sp)
ffffffffc02059ac:	f4de                	sd	s7,104(sp)
ffffffffc02059ae:	892a                	mv	s2,a0
ffffffffc02059b0:	8bb2                	mv	s7,a2
ffffffffc02059b2:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059b4:	862e                	mv	a2,a1
ffffffffc02059b6:	4681                	li	a3,0
ffffffffc02059b8:	85aa                	mv	a1,a0
ffffffffc02059ba:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059bc:	f506                	sd	ra,168(sp)
ffffffffc02059be:	f122                	sd	s0,160(sp)
ffffffffc02059c0:	e152                	sd	s4,128(sp)
ffffffffc02059c2:	fcd6                	sd	s5,120(sp)
ffffffffc02059c4:	f8da                	sd	s6,112(sp)
ffffffffc02059c6:	f0e2                	sd	s8,96(sp)
ffffffffc02059c8:	ece6                	sd	s9,88(sp)
ffffffffc02059ca:	e8ea                	sd	s10,80(sp)
ffffffffc02059cc:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059ce:	b56ff0ef          	jal	ra,ffffffffc0204d24 <user_mem_check>
ffffffffc02059d2:	40050a63          	beqz	a0,ffffffffc0205de6 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02059d6:	4641                	li	a2,16
ffffffffc02059d8:	4581                	li	a1,0
ffffffffc02059da:	1808                	addi	a0,sp,48
ffffffffc02059dc:	61d000ef          	jal	ra,ffffffffc02067f8 <memset>
    memcpy(local_name, name, len);
ffffffffc02059e0:	47bd                	li	a5,15
ffffffffc02059e2:	8626                	mv	a2,s1
ffffffffc02059e4:	1e97e263          	bltu	a5,s1,ffffffffc0205bc8 <do_execve+0x236>
ffffffffc02059e8:	85ca                	mv	a1,s2
ffffffffc02059ea:	1808                	addi	a0,sp,48
ffffffffc02059ec:	61f000ef          	jal	ra,ffffffffc020680a <memcpy>
    if (mm != NULL) {
ffffffffc02059f0:	1e098363          	beqz	s3,ffffffffc0205bd6 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc02059f4:	00002517          	auipc	a0,0x2
ffffffffc02059f8:	33c50513          	addi	a0,a0,828 # ffffffffc0207d30 <default_pmm_manager+0x7b8>
ffffffffc02059fc:	fbcfa0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc0205a00:	000ae797          	auipc	a5,0xae
ffffffffc0205a04:	de07b783          	ld	a5,-544(a5) # ffffffffc02b37e0 <boot_cr3>
ffffffffc0205a08:	577d                	li	a4,-1
ffffffffc0205a0a:	177e                	slli	a4,a4,0x3f
ffffffffc0205a0c:	83b1                	srli	a5,a5,0xc
ffffffffc0205a0e:	8fd9                	or	a5,a5,a4
ffffffffc0205a10:	18079073          	csrw	satp,a5
ffffffffc0205a14:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc0205a18:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205a1c:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205a20:	2c070463          	beqz	a4,ffffffffc0205ce8 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0205a24:	000db783          	ld	a5,0(s11)
ffffffffc0205a28:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205a2c:	fdafe0ef          	jal	ra,ffffffffc0204206 <mm_create>
ffffffffc0205a30:	84aa                	mv	s1,a0
ffffffffc0205a32:	1c050d63          	beqz	a0,ffffffffc0205c0c <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205a36:	4505                	li	a0,1
ffffffffc0205a38:	aa8fc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0205a3c:	3a050963          	beqz	a0,ffffffffc0205dee <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0205a40:	000aec97          	auipc	s9,0xae
ffffffffc0205a44:	db8c8c93          	addi	s9,s9,-584 # ffffffffc02b37f8 <pages>
ffffffffc0205a48:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205a4c:	000aec17          	auipc	s8,0xae
ffffffffc0205a50:	da4c0c13          	addi	s8,s8,-604 # ffffffffc02b37f0 <npage>
    return page - pages + nbase;
ffffffffc0205a54:	00003717          	auipc	a4,0x3
ffffffffc0205a58:	64473703          	ld	a4,1604(a4) # ffffffffc0209098 <nbase>
ffffffffc0205a5c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205a60:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a62:	5afd                	li	s5,-1
ffffffffc0205a64:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205a68:	96ba                	add	a3,a3,a4
ffffffffc0205a6a:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a6c:	00cad713          	srli	a4,s5,0xc
ffffffffc0205a70:	ec3a                	sd	a4,24(sp)
ffffffffc0205a72:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a76:	38f77063          	bgeu	a4,a5,ffffffffc0205df6 <do_execve+0x464>
ffffffffc0205a7a:	000aeb17          	auipc	s6,0xae
ffffffffc0205a7e:	d8eb0b13          	addi	s6,s6,-626 # ffffffffc02b3808 <va_pa_offset>
ffffffffc0205a82:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205a86:	6605                	lui	a2,0x1
ffffffffc0205a88:	000ae597          	auipc	a1,0xae
ffffffffc0205a8c:	d605b583          	ld	a1,-672(a1) # ffffffffc02b37e8 <boot_pgdir>
ffffffffc0205a90:	9936                	add	s2,s2,a3
ffffffffc0205a92:	854a                	mv	a0,s2
ffffffffc0205a94:	577000ef          	jal	ra,ffffffffc020680a <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a98:	7782                	ld	a5,32(sp)
ffffffffc0205a9a:	4398                	lw	a4,0(a5)
ffffffffc0205a9c:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205aa0:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205aa4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b945f>
ffffffffc0205aa8:	14f71863          	bne	a4,a5,ffffffffc0205bf8 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205aac:	7682                	ld	a3,32(sp)
ffffffffc0205aae:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205ab2:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205ab6:	00371793          	slli	a5,a4,0x3
ffffffffc0205aba:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205abc:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205abe:	078e                	slli	a5,a5,0x3
ffffffffc0205ac0:	97ce                	add	a5,a5,s3
ffffffffc0205ac2:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205ac4:	00f9fc63          	bgeu	s3,a5,ffffffffc0205adc <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205ac8:	0009a783          	lw	a5,0(s3)
ffffffffc0205acc:	4705                	li	a4,1
ffffffffc0205ace:	14e78163          	beq	a5,a4,ffffffffc0205c10 <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc0205ad2:	77a2                	ld	a5,40(sp)
ffffffffc0205ad4:	03898993          	addi	s3,s3,56
ffffffffc0205ad8:	fef9e8e3          	bltu	s3,a5,ffffffffc0205ac8 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205adc:	4701                	li	a4,0
ffffffffc0205ade:	46ad                	li	a3,11
ffffffffc0205ae0:	00100637          	lui	a2,0x100
ffffffffc0205ae4:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205ae8:	8526                	mv	a0,s1
ffffffffc0205aea:	8f5fe0ef          	jal	ra,ffffffffc02043de <mm_map>
ffffffffc0205aee:	8a2a                	mv	s4,a0
ffffffffc0205af0:	1e051263          	bnez	a0,ffffffffc0205cd4 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205af4:	6c88                	ld	a0,24(s1)
ffffffffc0205af6:	467d                	li	a2,31
ffffffffc0205af8:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205afc:	8dbfd0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0205b00:	38050363          	beqz	a0,ffffffffc0205e86 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b04:	6c88                	ld	a0,24(s1)
ffffffffc0205b06:	467d                	li	a2,31
ffffffffc0205b08:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205b0c:	8cbfd0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0205b10:	34050b63          	beqz	a0,ffffffffc0205e66 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b14:	6c88                	ld	a0,24(s1)
ffffffffc0205b16:	467d                	li	a2,31
ffffffffc0205b18:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205b1c:	8bbfd0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0205b20:	32050363          	beqz	a0,ffffffffc0205e46 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b24:	6c88                	ld	a0,24(s1)
ffffffffc0205b26:	467d                	li	a2,31
ffffffffc0205b28:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205b2c:	8abfd0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0205b30:	2e050b63          	beqz	a0,ffffffffc0205e26 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0205b34:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205b36:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b3a:	6c94                	ld	a3,24(s1)
ffffffffc0205b3c:	2785                	addiw	a5,a5,1
ffffffffc0205b3e:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205b40:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b42:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b46:	2cf6e463          	bltu	a3,a5,ffffffffc0205e0e <do_execve+0x47c>
ffffffffc0205b4a:	000b3783          	ld	a5,0(s6)
ffffffffc0205b4e:	577d                	li	a4,-1
ffffffffc0205b50:	177e                	slli	a4,a4,0x3f
ffffffffc0205b52:	8e9d                	sub	a3,a3,a5
ffffffffc0205b54:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205b58:	f654                	sd	a3,168(a2)
ffffffffc0205b5a:	8fd9                	or	a5,a5,a4
ffffffffc0205b5c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205b60:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b62:	4581                	li	a1,0
ffffffffc0205b64:	12000613          	li	a2,288
ffffffffc0205b68:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205b6a:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b6e:	48b000ef          	jal	ra,ffffffffc02067f8 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205b72:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b74:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b78:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc0205b7c:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b7e:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b80:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f94>
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b84:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b86:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b8a:	4641                	li	a2,16
ffffffffc0205b8c:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b8e:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205b90:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b94:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b98:	854a                	mv	a0,s2
ffffffffc0205b9a:	45f000ef          	jal	ra,ffffffffc02067f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205b9e:	463d                	li	a2,15
ffffffffc0205ba0:	180c                	addi	a1,sp,48
ffffffffc0205ba2:	854a                	mv	a0,s2
ffffffffc0205ba4:	467000ef          	jal	ra,ffffffffc020680a <memcpy>
}
ffffffffc0205ba8:	70aa                	ld	ra,168(sp)
ffffffffc0205baa:	740a                	ld	s0,160(sp)
ffffffffc0205bac:	64ea                	ld	s1,152(sp)
ffffffffc0205bae:	694a                	ld	s2,144(sp)
ffffffffc0205bb0:	69aa                	ld	s3,136(sp)
ffffffffc0205bb2:	7ae6                	ld	s5,120(sp)
ffffffffc0205bb4:	7b46                	ld	s6,112(sp)
ffffffffc0205bb6:	7ba6                	ld	s7,104(sp)
ffffffffc0205bb8:	7c06                	ld	s8,96(sp)
ffffffffc0205bba:	6ce6                	ld	s9,88(sp)
ffffffffc0205bbc:	6d46                	ld	s10,80(sp)
ffffffffc0205bbe:	6da6                	ld	s11,72(sp)
ffffffffc0205bc0:	8552                	mv	a0,s4
ffffffffc0205bc2:	6a0a                	ld	s4,128(sp)
ffffffffc0205bc4:	614d                	addi	sp,sp,176
ffffffffc0205bc6:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205bc8:	463d                	li	a2,15
ffffffffc0205bca:	85ca                	mv	a1,s2
ffffffffc0205bcc:	1808                	addi	a0,sp,48
ffffffffc0205bce:	43d000ef          	jal	ra,ffffffffc020680a <memcpy>
    if (mm != NULL) {
ffffffffc0205bd2:	e20991e3          	bnez	s3,ffffffffc02059f4 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205bd6:	000db783          	ld	a5,0(s11)
ffffffffc0205bda:	779c                	ld	a5,40(a5)
ffffffffc0205bdc:	e40788e3          	beqz	a5,ffffffffc0205a2c <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205be0:	00003617          	auipc	a2,0x3
ffffffffc0205be4:	de860613          	addi	a2,a2,-536 # ffffffffc02089c8 <default_pmm_manager+0x1450>
ffffffffc0205be8:	21600593          	li	a1,534
ffffffffc0205bec:	00003517          	auipc	a0,0x3
ffffffffc0205bf0:	bf450513          	addi	a0,a0,-1036 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205bf4:	887fa0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc0205bf8:	8526                	mv	a0,s1
ffffffffc0205bfa:	c18ff0ef          	jal	ra,ffffffffc0205012 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205bfe:	8526                	mv	a0,s1
ffffffffc0205c00:	f8cfe0ef          	jal	ra,ffffffffc020438c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205c04:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205c06:	8552                	mv	a0,s4
ffffffffc0205c08:	94bff0ef          	jal	ra,ffffffffc0205552 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205c0c:	5a71                	li	s4,-4
ffffffffc0205c0e:	bfe5                	j	ffffffffc0205c06 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205c10:	0289b603          	ld	a2,40(s3)
ffffffffc0205c14:	0209b783          	ld	a5,32(s3)
ffffffffc0205c18:	1cf66d63          	bltu	a2,a5,ffffffffc0205df2 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c1c:	0049a783          	lw	a5,4(s3)
ffffffffc0205c20:	0017f693          	andi	a3,a5,1
ffffffffc0205c24:	c291                	beqz	a3,ffffffffc0205c28 <do_execve+0x296>
ffffffffc0205c26:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c28:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c2c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c2e:	e779                	bnez	a4,ffffffffc0205cfc <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205c30:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c32:	c781                	beqz	a5,ffffffffc0205c3a <do_execve+0x2a8>
ffffffffc0205c34:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205c38:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c3a:	0026f793          	andi	a5,a3,2
ffffffffc0205c3e:	e3f1                	bnez	a5,ffffffffc0205d02 <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205c40:	0046f793          	andi	a5,a3,4
ffffffffc0205c44:	c399                	beqz	a5,ffffffffc0205c4a <do_execve+0x2b8>
ffffffffc0205c46:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205c4a:	0109b583          	ld	a1,16(s3)
ffffffffc0205c4e:	4701                	li	a4,0
ffffffffc0205c50:	8526                	mv	a0,s1
ffffffffc0205c52:	f8cfe0ef          	jal	ra,ffffffffc02043de <mm_map>
ffffffffc0205c56:	8a2a                	mv	s4,a0
ffffffffc0205c58:	ed35                	bnez	a0,ffffffffc0205cd4 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c5a:	0109bb83          	ld	s7,16(s3)
ffffffffc0205c5e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c60:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c64:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c68:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c6c:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c6e:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c70:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205c72:	054be963          	bltu	s7,s4,ffffffffc0205cc4 <do_execve+0x332>
ffffffffc0205c76:	aa95                	j	ffffffffc0205dea <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c78:	6785                	lui	a5,0x1
ffffffffc0205c7a:	415b8533          	sub	a0,s7,s5
ffffffffc0205c7e:	9abe                	add	s5,s5,a5
ffffffffc0205c80:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205c84:	015a7463          	bgeu	s4,s5,ffffffffc0205c8c <do_execve+0x2fa>
                size -= la - end;
ffffffffc0205c88:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205c8c:	000cb683          	ld	a3,0(s9)
ffffffffc0205c90:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c92:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205c96:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c9a:	8699                	srai	a3,a3,0x6
ffffffffc0205c9c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c9e:	67e2                	ld	a5,24(sp)
ffffffffc0205ca0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ca4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ca6:	14b87863          	bgeu	a6,a1,ffffffffc0205df6 <do_execve+0x464>
ffffffffc0205caa:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205cae:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205cb0:	9bb2                	add	s7,s7,a2
ffffffffc0205cb2:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205cb4:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205cb6:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205cb8:	353000ef          	jal	ra,ffffffffc020680a <memcpy>
            start += size, from += size;
ffffffffc0205cbc:	6622                	ld	a2,8(sp)
ffffffffc0205cbe:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205cc0:	054bf363          	bgeu	s7,s4,ffffffffc0205d06 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205cc4:	6c88                	ld	a0,24(s1)
ffffffffc0205cc6:	866a                	mv	a2,s10
ffffffffc0205cc8:	85d6                	mv	a1,s5
ffffffffc0205cca:	f0cfd0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0205cce:	842a                	mv	s0,a0
ffffffffc0205cd0:	f545                	bnez	a0,ffffffffc0205c78 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205cd2:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205cd4:	8526                	mv	a0,s1
ffffffffc0205cd6:	853fe0ef          	jal	ra,ffffffffc0204528 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205cda:	8526                	mv	a0,s1
ffffffffc0205cdc:	b36ff0ef          	jal	ra,ffffffffc0205012 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ce0:	8526                	mv	a0,s1
ffffffffc0205ce2:	eaafe0ef          	jal	ra,ffffffffc020438c <mm_destroy>
    return ret;
ffffffffc0205ce6:	b705                	j	ffffffffc0205c06 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0205ce8:	854e                	mv	a0,s3
ffffffffc0205cea:	83ffe0ef          	jal	ra,ffffffffc0204528 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205cee:	854e                	mv	a0,s3
ffffffffc0205cf0:	b22ff0ef          	jal	ra,ffffffffc0205012 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205cf4:	854e                	mv	a0,s3
ffffffffc0205cf6:	e96fe0ef          	jal	ra,ffffffffc020438c <mm_destroy>
ffffffffc0205cfa:	b32d                	j	ffffffffc0205a24 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205cfc:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d00:	fb95                	bnez	a5,ffffffffc0205c34 <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205d02:	4d5d                	li	s10,23
ffffffffc0205d04:	bf35                	j	ffffffffc0205c40 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205d06:	0109b683          	ld	a3,16(s3)
ffffffffc0205d0a:	0289b903          	ld	s2,40(s3)
ffffffffc0205d0e:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205d10:	075bfd63          	bgeu	s7,s5,ffffffffc0205d8a <do_execve+0x3f8>
            if (start == end) {
ffffffffc0205d14:	db790fe3          	beq	s2,s7,ffffffffc0205ad2 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d18:	6785                	lui	a5,0x1
ffffffffc0205d1a:	00fb8533          	add	a0,s7,a5
ffffffffc0205d1e:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205d22:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205d26:	0b597d63          	bgeu	s2,s5,ffffffffc0205de0 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0205d2a:	000cb683          	ld	a3,0(s9)
ffffffffc0205d2e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205d30:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205d34:	40d406b3          	sub	a3,s0,a3
ffffffffc0205d38:	8699                	srai	a3,a3,0x6
ffffffffc0205d3a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205d3c:	67e2                	ld	a5,24(sp)
ffffffffc0205d3e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d42:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d44:	0ac5f963          	bgeu	a1,a2,ffffffffc0205df6 <do_execve+0x464>
ffffffffc0205d48:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d4c:	8652                	mv	a2,s4
ffffffffc0205d4e:	4581                	li	a1,0
ffffffffc0205d50:	96c2                	add	a3,a3,a6
ffffffffc0205d52:	9536                	add	a0,a0,a3
ffffffffc0205d54:	2a5000ef          	jal	ra,ffffffffc02067f8 <memset>
            start += size;
ffffffffc0205d58:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d5c:	03597463          	bgeu	s2,s5,ffffffffc0205d84 <do_execve+0x3f2>
ffffffffc0205d60:	d6e909e3          	beq	s2,a4,ffffffffc0205ad2 <do_execve+0x140>
ffffffffc0205d64:	00003697          	auipc	a3,0x3
ffffffffc0205d68:	c8c68693          	addi	a3,a3,-884 # ffffffffc02089f0 <default_pmm_manager+0x1478>
ffffffffc0205d6c:	00001617          	auipc	a2,0x1
ffffffffc0205d70:	17460613          	addi	a2,a2,372 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205d74:	26b00593          	li	a1,619
ffffffffc0205d78:	00003517          	auipc	a0,0x3
ffffffffc0205d7c:	a6850513          	addi	a0,a0,-1432 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205d80:	efafa0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0205d84:	ff5710e3          	bne	a4,s5,ffffffffc0205d64 <do_execve+0x3d2>
ffffffffc0205d88:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205d8a:	d52bf4e3          	bgeu	s7,s2,ffffffffc0205ad2 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205d8e:	6c88                	ld	a0,24(s1)
ffffffffc0205d90:	866a                	mv	a2,s10
ffffffffc0205d92:	85d6                	mv	a1,s5
ffffffffc0205d94:	e42fd0ef          	jal	ra,ffffffffc02033d6 <pgdir_alloc_page>
ffffffffc0205d98:	842a                	mv	s0,a0
ffffffffc0205d9a:	dd05                	beqz	a0,ffffffffc0205cd2 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205d9c:	6785                	lui	a5,0x1
ffffffffc0205d9e:	415b8533          	sub	a0,s7,s5
ffffffffc0205da2:	9abe                	add	s5,s5,a5
ffffffffc0205da4:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205da8:	01597463          	bgeu	s2,s5,ffffffffc0205db0 <do_execve+0x41e>
                size -= la - end;
ffffffffc0205dac:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205db0:	000cb683          	ld	a3,0(s9)
ffffffffc0205db4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205db6:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205dba:	40d406b3          	sub	a3,s0,a3
ffffffffc0205dbe:	8699                	srai	a3,a3,0x6
ffffffffc0205dc0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205dc2:	67e2                	ld	a5,24(sp)
ffffffffc0205dc4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205dc8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205dca:	02b87663          	bgeu	a6,a1,ffffffffc0205df6 <do_execve+0x464>
ffffffffc0205dce:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205dd2:	4581                	li	a1,0
            start += size;
ffffffffc0205dd4:	9bb2                	add	s7,s7,a2
ffffffffc0205dd6:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205dd8:	9536                	add	a0,a0,a3
ffffffffc0205dda:	21f000ef          	jal	ra,ffffffffc02067f8 <memset>
ffffffffc0205dde:	b775                	j	ffffffffc0205d8a <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205de0:	417a8a33          	sub	s4,s5,s7
ffffffffc0205de4:	b799                	j	ffffffffc0205d2a <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205de6:	5a75                	li	s4,-3
ffffffffc0205de8:	b3c1                	j	ffffffffc0205ba8 <do_execve+0x216>
        while (start < end) {
ffffffffc0205dea:	86de                	mv	a3,s7
ffffffffc0205dec:	bf39                	j	ffffffffc0205d0a <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205dee:	5a71                	li	s4,-4
ffffffffc0205df0:	bdc5                	j	ffffffffc0205ce0 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205df2:	5a61                	li	s4,-8
ffffffffc0205df4:	b5c5                	j	ffffffffc0205cd4 <do_execve+0x342>
ffffffffc0205df6:	00001617          	auipc	a2,0x1
ffffffffc0205dfa:	7ba60613          	addi	a2,a2,1978 # ffffffffc02075b0 <default_pmm_manager+0x38>
ffffffffc0205dfe:	06900593          	li	a1,105
ffffffffc0205e02:	00001517          	auipc	a0,0x1
ffffffffc0205e06:	7d650513          	addi	a0,a0,2006 # ffffffffc02075d8 <default_pmm_manager+0x60>
ffffffffc0205e0a:	e70fa0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205e0e:	00002617          	auipc	a2,0x2
ffffffffc0205e12:	84a60613          	addi	a2,a2,-1974 # ffffffffc0207658 <default_pmm_manager+0xe0>
ffffffffc0205e16:	28600593          	li	a1,646
ffffffffc0205e1a:	00003517          	auipc	a0,0x3
ffffffffc0205e1e:	9c650513          	addi	a0,a0,-1594 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205e22:	e58fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e26:	00003697          	auipc	a3,0x3
ffffffffc0205e2a:	ce268693          	addi	a3,a3,-798 # ffffffffc0208b08 <default_pmm_manager+0x1590>
ffffffffc0205e2e:	00001617          	auipc	a2,0x1
ffffffffc0205e32:	0b260613          	addi	a2,a2,178 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205e36:	28100593          	li	a1,641
ffffffffc0205e3a:	00003517          	auipc	a0,0x3
ffffffffc0205e3e:	9a650513          	addi	a0,a0,-1626 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205e42:	e38fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e46:	00003697          	auipc	a3,0x3
ffffffffc0205e4a:	c7a68693          	addi	a3,a3,-902 # ffffffffc0208ac0 <default_pmm_manager+0x1548>
ffffffffc0205e4e:	00001617          	auipc	a2,0x1
ffffffffc0205e52:	09260613          	addi	a2,a2,146 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205e56:	28000593          	li	a1,640
ffffffffc0205e5a:	00003517          	auipc	a0,0x3
ffffffffc0205e5e:	98650513          	addi	a0,a0,-1658 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205e62:	e18fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e66:	00003697          	auipc	a3,0x3
ffffffffc0205e6a:	c1268693          	addi	a3,a3,-1006 # ffffffffc0208a78 <default_pmm_manager+0x1500>
ffffffffc0205e6e:	00001617          	auipc	a2,0x1
ffffffffc0205e72:	07260613          	addi	a2,a2,114 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205e76:	27f00593          	li	a1,639
ffffffffc0205e7a:	00003517          	auipc	a0,0x3
ffffffffc0205e7e:	96650513          	addi	a0,a0,-1690 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205e82:	df8fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205e86:	00003697          	auipc	a3,0x3
ffffffffc0205e8a:	baa68693          	addi	a3,a3,-1110 # ffffffffc0208a30 <default_pmm_manager+0x14b8>
ffffffffc0205e8e:	00001617          	auipc	a2,0x1
ffffffffc0205e92:	05260613          	addi	a2,a2,82 # ffffffffc0206ee0 <commands+0x450>
ffffffffc0205e96:	27e00593          	li	a1,638
ffffffffc0205e9a:	00003517          	auipc	a0,0x3
ffffffffc0205e9e:	94650513          	addi	a0,a0,-1722 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0205ea2:	dd8fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205ea6 <do_yield>:
    current->need_resched = 1;
ffffffffc0205ea6:	000ae797          	auipc	a5,0xae
ffffffffc0205eaa:	99a7b783          	ld	a5,-1638(a5) # ffffffffc02b3840 <current>
ffffffffc0205eae:	4705                	li	a4,1
ffffffffc0205eb0:	ef98                	sd	a4,24(a5)
}
ffffffffc0205eb2:	4501                	li	a0,0
ffffffffc0205eb4:	8082                	ret

ffffffffc0205eb6 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205eb6:	1101                	addi	sp,sp,-32
ffffffffc0205eb8:	e822                	sd	s0,16(sp)
ffffffffc0205eba:	e426                	sd	s1,8(sp)
ffffffffc0205ebc:	ec06                	sd	ra,24(sp)
ffffffffc0205ebe:	842e                	mv	s0,a1
ffffffffc0205ec0:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ec2:	c999                	beqz	a1,ffffffffc0205ed8 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205ec4:	000ae797          	auipc	a5,0xae
ffffffffc0205ec8:	97c7b783          	ld	a5,-1668(a5) # ffffffffc02b3840 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205ecc:	7788                	ld	a0,40(a5)
ffffffffc0205ece:	4685                	li	a3,1
ffffffffc0205ed0:	4611                	li	a2,4
ffffffffc0205ed2:	e53fe0ef          	jal	ra,ffffffffc0204d24 <user_mem_check>
ffffffffc0205ed6:	c909                	beqz	a0,ffffffffc0205ee8 <do_wait+0x32>
ffffffffc0205ed8:	85a2                	mv	a1,s0
}
ffffffffc0205eda:	6442                	ld	s0,16(sp)
ffffffffc0205edc:	60e2                	ld	ra,24(sp)
ffffffffc0205ede:	8526                	mv	a0,s1
ffffffffc0205ee0:	64a2                	ld	s1,8(sp)
ffffffffc0205ee2:	6105                	addi	sp,sp,32
ffffffffc0205ee4:	fb8ff06f          	j	ffffffffc020569c <do_wait.part.0>
ffffffffc0205ee8:	60e2                	ld	ra,24(sp)
ffffffffc0205eea:	6442                	ld	s0,16(sp)
ffffffffc0205eec:	64a2                	ld	s1,8(sp)
ffffffffc0205eee:	5575                	li	a0,-3
ffffffffc0205ef0:	6105                	addi	sp,sp,32
ffffffffc0205ef2:	8082                	ret

ffffffffc0205ef4 <do_kill>:
do_kill(int pid) {
ffffffffc0205ef4:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205ef6:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205ef8:	e406                	sd	ra,8(sp)
ffffffffc0205efa:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205efc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205f00:	17f9                	addi	a5,a5,-2
ffffffffc0205f02:	02e7e963          	bltu	a5,a4,ffffffffc0205f34 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205f06:	842a                	mv	s0,a0
ffffffffc0205f08:	45a9                	li	a1,10
ffffffffc0205f0a:	2501                	sext.w	a0,a0
ffffffffc0205f0c:	46c000ef          	jal	ra,ffffffffc0206378 <hash32>
ffffffffc0205f10:	02051793          	slli	a5,a0,0x20
ffffffffc0205f14:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205f18:	000aa797          	auipc	a5,0xaa
ffffffffc0205f1c:	89878793          	addi	a5,a5,-1896 # ffffffffc02af7b0 <hash_list>
ffffffffc0205f20:	953e                	add	a0,a0,a5
ffffffffc0205f22:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205f24:	a029                	j	ffffffffc0205f2e <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205f26:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205f2a:	00870b63          	beq	a4,s0,ffffffffc0205f40 <do_kill+0x4c>
ffffffffc0205f2e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205f30:	fef51be3          	bne	a0,a5,ffffffffc0205f26 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205f34:	5475                	li	s0,-3
}
ffffffffc0205f36:	60a2                	ld	ra,8(sp)
ffffffffc0205f38:	8522                	mv	a0,s0
ffffffffc0205f3a:	6402                	ld	s0,0(sp)
ffffffffc0205f3c:	0141                	addi	sp,sp,16
ffffffffc0205f3e:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205f40:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205f44:	00177693          	andi	a3,a4,1
ffffffffc0205f48:	e295                	bnez	a3,ffffffffc0205f6c <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f4a:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205f4c:	00176713          	ori	a4,a4,1
ffffffffc0205f50:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205f54:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f56:	fe06d0e3          	bgez	a3,ffffffffc0205f36 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205f5a:	f2878513          	addi	a0,a5,-216
ffffffffc0205f5e:	22e000ef          	jal	ra,ffffffffc020618c <wakeup_proc>
}
ffffffffc0205f62:	60a2                	ld	ra,8(sp)
ffffffffc0205f64:	8522                	mv	a0,s0
ffffffffc0205f66:	6402                	ld	s0,0(sp)
ffffffffc0205f68:	0141                	addi	sp,sp,16
ffffffffc0205f6a:	8082                	ret
        return -E_KILLED;
ffffffffc0205f6c:	545d                	li	s0,-9
ffffffffc0205f6e:	b7e1                	j	ffffffffc0205f36 <do_kill+0x42>

ffffffffc0205f70 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205f70:	1101                	addi	sp,sp,-32
ffffffffc0205f72:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205f74:	000ae797          	auipc	a5,0xae
ffffffffc0205f78:	83c78793          	addi	a5,a5,-1988 # ffffffffc02b37b0 <proc_list>
ffffffffc0205f7c:	ec06                	sd	ra,24(sp)
ffffffffc0205f7e:	e822                	sd	s0,16(sp)
ffffffffc0205f80:	e04a                	sd	s2,0(sp)
ffffffffc0205f82:	000aa497          	auipc	s1,0xaa
ffffffffc0205f86:	82e48493          	addi	s1,s1,-2002 # ffffffffc02af7b0 <hash_list>
ffffffffc0205f8a:	e79c                	sd	a5,8(a5)
ffffffffc0205f8c:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205f8e:	000ae717          	auipc	a4,0xae
ffffffffc0205f92:	82270713          	addi	a4,a4,-2014 # ffffffffc02b37b0 <proc_list>
ffffffffc0205f96:	87a6                	mv	a5,s1
ffffffffc0205f98:	e79c                	sd	a5,8(a5)
ffffffffc0205f9a:	e39c                	sd	a5,0(a5)
ffffffffc0205f9c:	07c1                	addi	a5,a5,16
ffffffffc0205f9e:	fef71de3          	bne	a4,a5,ffffffffc0205f98 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205fa2:	f73fe0ef          	jal	ra,ffffffffc0204f14 <alloc_proc>
ffffffffc0205fa6:	000ae917          	auipc	s2,0xae
ffffffffc0205faa:	8a290913          	addi	s2,s2,-1886 # ffffffffc02b3848 <idleproc>
ffffffffc0205fae:	00a93023          	sd	a0,0(s2)
ffffffffc0205fb2:	0e050f63          	beqz	a0,ffffffffc02060b0 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205fb6:	4789                	li	a5,2
ffffffffc0205fb8:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fba:	00004797          	auipc	a5,0x4
ffffffffc0205fbe:	04678793          	addi	a5,a5,70 # ffffffffc020a000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205fc2:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fc6:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205fc8:	4785                	li	a5,1
ffffffffc0205fca:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205fcc:	4641                	li	a2,16
ffffffffc0205fce:	4581                	li	a1,0
ffffffffc0205fd0:	8522                	mv	a0,s0
ffffffffc0205fd2:	027000ef          	jal	ra,ffffffffc02067f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205fd6:	463d                	li	a2,15
ffffffffc0205fd8:	00003597          	auipc	a1,0x3
ffffffffc0205fdc:	b9058593          	addi	a1,a1,-1136 # ffffffffc0208b68 <default_pmm_manager+0x15f0>
ffffffffc0205fe0:	8522                	mv	a0,s0
ffffffffc0205fe2:	029000ef          	jal	ra,ffffffffc020680a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205fe6:	000ae717          	auipc	a4,0xae
ffffffffc0205fea:	87270713          	addi	a4,a4,-1934 # ffffffffc02b3858 <nr_process>
ffffffffc0205fee:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205ff0:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ff4:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205ff6:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ff8:	4581                	li	a1,0
ffffffffc0205ffa:	00000517          	auipc	a0,0x0
ffffffffc0205ffe:	87450513          	addi	a0,a0,-1932 # ffffffffc020586e <init_main>
    nr_process ++;
ffffffffc0206002:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0206004:	000ae797          	auipc	a5,0xae
ffffffffc0206008:	82d7be23          	sd	a3,-1988(a5) # ffffffffc02b3840 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020600c:	cf6ff0ef          	jal	ra,ffffffffc0205502 <kernel_thread>
ffffffffc0206010:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0206012:	08a05363          	blez	a0,ffffffffc0206098 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0206016:	6789                	lui	a5,0x2
ffffffffc0206018:	fff5071b          	addiw	a4,a0,-1
ffffffffc020601c:	17f9                	addi	a5,a5,-2
ffffffffc020601e:	2501                	sext.w	a0,a0
ffffffffc0206020:	02e7e363          	bltu	a5,a4,ffffffffc0206046 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0206024:	45a9                	li	a1,10
ffffffffc0206026:	352000ef          	jal	ra,ffffffffc0206378 <hash32>
ffffffffc020602a:	02051793          	slli	a5,a0,0x20
ffffffffc020602e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0206032:	96a6                	add	a3,a3,s1
ffffffffc0206034:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0206036:	a029                	j	ffffffffc0206040 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0206038:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc020603c:	04870b63          	beq	a4,s0,ffffffffc0206092 <proc_init+0x122>
    return listelm->next;
ffffffffc0206040:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0206042:	fef69be3          	bne	a3,a5,ffffffffc0206038 <proc_init+0xc8>
    return NULL;
ffffffffc0206046:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206048:	0b478493          	addi	s1,a5,180
ffffffffc020604c:	4641                	li	a2,16
ffffffffc020604e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0206050:	000ae417          	auipc	s0,0xae
ffffffffc0206054:	80040413          	addi	s0,s0,-2048 # ffffffffc02b3850 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206058:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020605a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020605c:	79c000ef          	jal	ra,ffffffffc02067f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0206060:	463d                	li	a2,15
ffffffffc0206062:	00003597          	auipc	a1,0x3
ffffffffc0206066:	b2e58593          	addi	a1,a1,-1234 # ffffffffc0208b90 <default_pmm_manager+0x1618>
ffffffffc020606a:	8526                	mv	a0,s1
ffffffffc020606c:	79e000ef          	jal	ra,ffffffffc020680a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206070:	00093783          	ld	a5,0(s2)
ffffffffc0206074:	cbb5                	beqz	a5,ffffffffc02060e8 <proc_init+0x178>
ffffffffc0206076:	43dc                	lw	a5,4(a5)
ffffffffc0206078:	eba5                	bnez	a5,ffffffffc02060e8 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020607a:	601c                	ld	a5,0(s0)
ffffffffc020607c:	c7b1                	beqz	a5,ffffffffc02060c8 <proc_init+0x158>
ffffffffc020607e:	43d8                	lw	a4,4(a5)
ffffffffc0206080:	4785                	li	a5,1
ffffffffc0206082:	04f71363          	bne	a4,a5,ffffffffc02060c8 <proc_init+0x158>
}
ffffffffc0206086:	60e2                	ld	ra,24(sp)
ffffffffc0206088:	6442                	ld	s0,16(sp)
ffffffffc020608a:	64a2                	ld	s1,8(sp)
ffffffffc020608c:	6902                	ld	s2,0(sp)
ffffffffc020608e:	6105                	addi	sp,sp,32
ffffffffc0206090:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0206092:	f2878793          	addi	a5,a5,-216
ffffffffc0206096:	bf4d                	j	ffffffffc0206048 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0206098:	00003617          	auipc	a2,0x3
ffffffffc020609c:	ad860613          	addi	a2,a2,-1320 # ffffffffc0208b70 <default_pmm_manager+0x15f8>
ffffffffc02060a0:	38f00593          	li	a1,911
ffffffffc02060a4:	00002517          	auipc	a0,0x2
ffffffffc02060a8:	73c50513          	addi	a0,a0,1852 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc02060ac:	bcefa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02060b0:	00003617          	auipc	a2,0x3
ffffffffc02060b4:	aa060613          	addi	a2,a2,-1376 # ffffffffc0208b50 <default_pmm_manager+0x15d8>
ffffffffc02060b8:	38100593          	li	a1,897
ffffffffc02060bc:	00002517          	auipc	a0,0x2
ffffffffc02060c0:	72450513          	addi	a0,a0,1828 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc02060c4:	bb6fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02060c8:	00003697          	auipc	a3,0x3
ffffffffc02060cc:	af868693          	addi	a3,a3,-1288 # ffffffffc0208bc0 <default_pmm_manager+0x1648>
ffffffffc02060d0:	00001617          	auipc	a2,0x1
ffffffffc02060d4:	e1060613          	addi	a2,a2,-496 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02060d8:	39600593          	li	a1,918
ffffffffc02060dc:	00002517          	auipc	a0,0x2
ffffffffc02060e0:	70450513          	addi	a0,a0,1796 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc02060e4:	b96fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02060e8:	00003697          	auipc	a3,0x3
ffffffffc02060ec:	ab068693          	addi	a3,a3,-1360 # ffffffffc0208b98 <default_pmm_manager+0x1620>
ffffffffc02060f0:	00001617          	auipc	a2,0x1
ffffffffc02060f4:	df060613          	addi	a2,a2,-528 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02060f8:	39500593          	li	a1,917
ffffffffc02060fc:	00002517          	auipc	a0,0x2
ffffffffc0206100:	6e450513          	addi	a0,a0,1764 # ffffffffc02087e0 <default_pmm_manager+0x1268>
ffffffffc0206104:	b76fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0206108 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0206108:	1141                	addi	sp,sp,-16
ffffffffc020610a:	e022                	sd	s0,0(sp)
ffffffffc020610c:	e406                	sd	ra,8(sp)
ffffffffc020610e:	000ad417          	auipc	s0,0xad
ffffffffc0206112:	73240413          	addi	s0,s0,1842 # ffffffffc02b3840 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0206116:	6018                	ld	a4,0(s0)
ffffffffc0206118:	6f1c                	ld	a5,24(a4)
ffffffffc020611a:	dffd                	beqz	a5,ffffffffc0206118 <cpu_idle+0x10>
            schedule();
ffffffffc020611c:	0f0000ef          	jal	ra,ffffffffc020620c <schedule>
ffffffffc0206120:	bfdd                	j	ffffffffc0206116 <cpu_idle+0xe>

ffffffffc0206122 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0206122:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0206126:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020612a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020612c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020612e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0206132:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0206136:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020613a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020613e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0206142:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0206146:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020614a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020614e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0206152:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0206156:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020615a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020615e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0206160:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0206162:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0206166:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020616a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020616e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0206172:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206176:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020617a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020617e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206182:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206186:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020618a:	8082                	ret

ffffffffc020618c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020618c:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020618e:	1101                	addi	sp,sp,-32
ffffffffc0206190:	ec06                	sd	ra,24(sp)
ffffffffc0206192:	e822                	sd	s0,16(sp)
ffffffffc0206194:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206196:	478d                	li	a5,3
ffffffffc0206198:	04f70b63          	beq	a4,a5,ffffffffc02061ee <wakeup_proc+0x62>
ffffffffc020619c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020619e:	100027f3          	csrr	a5,sstatus
ffffffffc02061a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02061a4:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02061a6:	ef9d                	bnez	a5,ffffffffc02061e4 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02061a8:	4789                	li	a5,2
ffffffffc02061aa:	02f70163          	beq	a4,a5,ffffffffc02061cc <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc02061ae:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc02061b0:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc02061b4:	e491                	bnez	s1,ffffffffc02061c0 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02061b6:	60e2                	ld	ra,24(sp)
ffffffffc02061b8:	6442                	ld	s0,16(sp)
ffffffffc02061ba:	64a2                	ld	s1,8(sp)
ffffffffc02061bc:	6105                	addi	sp,sp,32
ffffffffc02061be:	8082                	ret
ffffffffc02061c0:	6442                	ld	s0,16(sp)
ffffffffc02061c2:	60e2                	ld	ra,24(sp)
ffffffffc02061c4:	64a2                	ld	s1,8(sp)
ffffffffc02061c6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02061c8:	c78fa06f          	j	ffffffffc0200640 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02061cc:	00003617          	auipc	a2,0x3
ffffffffc02061d0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0208c20 <default_pmm_manager+0x16a8>
ffffffffc02061d4:	45c9                	li	a1,18
ffffffffc02061d6:	00003517          	auipc	a0,0x3
ffffffffc02061da:	a3250513          	addi	a0,a0,-1486 # ffffffffc0208c08 <default_pmm_manager+0x1690>
ffffffffc02061de:	b04fa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc02061e2:	bfc9                	j	ffffffffc02061b4 <wakeup_proc+0x28>
        intr_disable();
ffffffffc02061e4:	c62fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02061e8:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02061ea:	4485                	li	s1,1
ffffffffc02061ec:	bf75                	j	ffffffffc02061a8 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02061ee:	00003697          	auipc	a3,0x3
ffffffffc02061f2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0208be8 <default_pmm_manager+0x1670>
ffffffffc02061f6:	00001617          	auipc	a2,0x1
ffffffffc02061fa:	cea60613          	addi	a2,a2,-790 # ffffffffc0206ee0 <commands+0x450>
ffffffffc02061fe:	45a5                	li	a1,9
ffffffffc0206200:	00003517          	auipc	a0,0x3
ffffffffc0206204:	a0850513          	addi	a0,a0,-1528 # ffffffffc0208c08 <default_pmm_manager+0x1690>
ffffffffc0206208:	a72fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020620c <schedule>:

void
schedule(void) {
ffffffffc020620c:	1141                	addi	sp,sp,-16
ffffffffc020620e:	e406                	sd	ra,8(sp)
ffffffffc0206210:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206212:	100027f3          	csrr	a5,sstatus
ffffffffc0206216:	8b89                	andi	a5,a5,2
ffffffffc0206218:	4401                	li	s0,0
ffffffffc020621a:	efbd                	bnez	a5,ffffffffc0206298 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020621c:	000ad897          	auipc	a7,0xad
ffffffffc0206220:	6248b883          	ld	a7,1572(a7) # ffffffffc02b3840 <current>
ffffffffc0206224:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206228:	000ad517          	auipc	a0,0xad
ffffffffc020622c:	62053503          	ld	a0,1568(a0) # ffffffffc02b3848 <idleproc>
ffffffffc0206230:	04a88e63          	beq	a7,a0,ffffffffc020628c <schedule+0x80>
ffffffffc0206234:	0c888693          	addi	a3,a7,200
ffffffffc0206238:	000ad617          	auipc	a2,0xad
ffffffffc020623c:	57860613          	addi	a2,a2,1400 # ffffffffc02b37b0 <proc_list>
        le = last;
ffffffffc0206240:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206242:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206244:	4809                	li	a6,2
ffffffffc0206246:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206248:	00c78863          	beq	a5,a2,ffffffffc0206258 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020624c:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206250:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206254:	03070163          	beq	a4,a6,ffffffffc0206276 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206258:	fef697e3          	bne	a3,a5,ffffffffc0206246 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020625c:	ed89                	bnez	a1,ffffffffc0206276 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020625e:	451c                	lw	a5,8(a0)
ffffffffc0206260:	2785                	addiw	a5,a5,1
ffffffffc0206262:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206264:	00a88463          	beq	a7,a0,ffffffffc020626c <schedule+0x60>
            proc_run(next);
ffffffffc0206268:	e21fe0ef          	jal	ra,ffffffffc0205088 <proc_run>
    if (flag) {
ffffffffc020626c:	e819                	bnez	s0,ffffffffc0206282 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020626e:	60a2                	ld	ra,8(sp)
ffffffffc0206270:	6402                	ld	s0,0(sp)
ffffffffc0206272:	0141                	addi	sp,sp,16
ffffffffc0206274:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206276:	4198                	lw	a4,0(a1)
ffffffffc0206278:	4789                	li	a5,2
ffffffffc020627a:	fef712e3          	bne	a4,a5,ffffffffc020625e <schedule+0x52>
ffffffffc020627e:	852e                	mv	a0,a1
ffffffffc0206280:	bff9                	j	ffffffffc020625e <schedule+0x52>
}
ffffffffc0206282:	6402                	ld	s0,0(sp)
ffffffffc0206284:	60a2                	ld	ra,8(sp)
ffffffffc0206286:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206288:	bb8fa06f          	j	ffffffffc0200640 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020628c:	000ad617          	auipc	a2,0xad
ffffffffc0206290:	52460613          	addi	a2,a2,1316 # ffffffffc02b37b0 <proc_list>
ffffffffc0206294:	86b2                	mv	a3,a2
ffffffffc0206296:	b76d                	j	ffffffffc0206240 <schedule+0x34>
        intr_disable();
ffffffffc0206298:	baefa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020629c:	4405                	li	s0,1
ffffffffc020629e:	bfbd                	j	ffffffffc020621c <schedule+0x10>

ffffffffc02062a0 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02062a0:	000ad797          	auipc	a5,0xad
ffffffffc02062a4:	5a07b783          	ld	a5,1440(a5) # ffffffffc02b3840 <current>
}
ffffffffc02062a8:	43c8                	lw	a0,4(a5)
ffffffffc02062aa:	8082                	ret

ffffffffc02062ac <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02062ac:	4501                	li	a0,0
ffffffffc02062ae:	8082                	ret

ffffffffc02062b0 <sys_putc>:
    cputchar(c);
ffffffffc02062b0:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02062b2:	1141                	addi	sp,sp,-16
ffffffffc02062b4:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02062b6:	f01f90ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc02062ba:	60a2                	ld	ra,8(sp)
ffffffffc02062bc:	4501                	li	a0,0
ffffffffc02062be:	0141                	addi	sp,sp,16
ffffffffc02062c0:	8082                	ret

ffffffffc02062c2 <sys_kill>:
    return do_kill(pid);
ffffffffc02062c2:	4108                	lw	a0,0(a0)
ffffffffc02062c4:	c31ff06f          	j	ffffffffc0205ef4 <do_kill>

ffffffffc02062c8 <sys_yield>:
    return do_yield();
ffffffffc02062c8:	bdfff06f          	j	ffffffffc0205ea6 <do_yield>

ffffffffc02062cc <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02062cc:	6d14                	ld	a3,24(a0)
ffffffffc02062ce:	6910                	ld	a2,16(a0)
ffffffffc02062d0:	650c                	ld	a1,8(a0)
ffffffffc02062d2:	6108                	ld	a0,0(a0)
ffffffffc02062d4:	ebeff06f          	j	ffffffffc0205992 <do_execve>

ffffffffc02062d8 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02062d8:	650c                	ld	a1,8(a0)
ffffffffc02062da:	4108                	lw	a0,0(a0)
ffffffffc02062dc:	bdbff06f          	j	ffffffffc0205eb6 <do_wait>

ffffffffc02062e0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02062e0:	000ad797          	auipc	a5,0xad
ffffffffc02062e4:	5607b783          	ld	a5,1376(a5) # ffffffffc02b3840 <current>
ffffffffc02062e8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02062ea:	4501                	li	a0,0
ffffffffc02062ec:	6a0c                	ld	a1,16(a2)
ffffffffc02062ee:	e07fe06f          	j	ffffffffc02050f4 <do_fork>

ffffffffc02062f2 <sys_exit>:
    return do_exit(error_code);
ffffffffc02062f2:	4108                	lw	a0,0(a0)
ffffffffc02062f4:	a5eff06f          	j	ffffffffc0205552 <do_exit>

ffffffffc02062f8 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02062f8:	715d                	addi	sp,sp,-80
ffffffffc02062fa:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02062fc:	000ad497          	auipc	s1,0xad
ffffffffc0206300:	54448493          	addi	s1,s1,1348 # ffffffffc02b3840 <current>
ffffffffc0206304:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206306:	e0a2                	sd	s0,64(sp)
ffffffffc0206308:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020630a:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020630c:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020630e:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0206310:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206314:	0327ee63          	bltu	a5,s2,ffffffffc0206350 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206318:	00391713          	slli	a4,s2,0x3
ffffffffc020631c:	00003797          	auipc	a5,0x3
ffffffffc0206320:	96c78793          	addi	a5,a5,-1684 # ffffffffc0208c88 <syscalls>
ffffffffc0206324:	97ba                	add	a5,a5,a4
ffffffffc0206326:	639c                	ld	a5,0(a5)
ffffffffc0206328:	c785                	beqz	a5,ffffffffc0206350 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc020632a:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020632c:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020632e:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206330:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206332:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206334:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206336:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206338:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020633a:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020633c:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020633e:	0028                	addi	a0,sp,8
ffffffffc0206340:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206342:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206344:	e828                	sd	a0,80(s0)
}
ffffffffc0206346:	6406                	ld	s0,64(sp)
ffffffffc0206348:	74e2                	ld	s1,56(sp)
ffffffffc020634a:	7942                	ld	s2,48(sp)
ffffffffc020634c:	6161                	addi	sp,sp,80
ffffffffc020634e:	8082                	ret
    print_trapframe(tf);
ffffffffc0206350:	8522                	mv	a0,s0
ffffffffc0206352:	ce2fa0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206356:	609c                	ld	a5,0(s1)
ffffffffc0206358:	86ca                	mv	a3,s2
ffffffffc020635a:	00003617          	auipc	a2,0x3
ffffffffc020635e:	8e660613          	addi	a2,a2,-1818 # ffffffffc0208c40 <default_pmm_manager+0x16c8>
ffffffffc0206362:	43d8                	lw	a4,4(a5)
ffffffffc0206364:	06200593          	li	a1,98
ffffffffc0206368:	0b478793          	addi	a5,a5,180
ffffffffc020636c:	00003517          	auipc	a0,0x3
ffffffffc0206370:	90450513          	addi	a0,a0,-1788 # ffffffffc0208c70 <default_pmm_manager+0x16f8>
ffffffffc0206374:	906fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0206378 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206378:	9e3707b7          	lui	a5,0x9e370
ffffffffc020637c:	2785                	addiw	a5,a5,1
ffffffffc020637e:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206382:	02000793          	li	a5,32
ffffffffc0206386:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206388:	00f5553b          	srlw	a0,a0,a5
ffffffffc020638c:	8082                	ret

ffffffffc020638e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020638e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206392:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206394:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206398:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020639a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020639e:	f022                	sd	s0,32(sp)
ffffffffc02063a0:	ec26                	sd	s1,24(sp)
ffffffffc02063a2:	e84a                	sd	s2,16(sp)
ffffffffc02063a4:	f406                	sd	ra,40(sp)
ffffffffc02063a6:	e44e                	sd	s3,8(sp)
ffffffffc02063a8:	84aa                	mv	s1,a0
ffffffffc02063aa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02063ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02063b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02063b2:	03067e63          	bgeu	a2,a6,ffffffffc02063ee <printnum+0x60>
ffffffffc02063b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02063b8:	00805763          	blez	s0,ffffffffc02063c6 <printnum+0x38>
ffffffffc02063bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02063be:	85ca                	mv	a1,s2
ffffffffc02063c0:	854e                	mv	a0,s3
ffffffffc02063c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02063c4:	fc65                	bnez	s0,ffffffffc02063bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063c6:	1a02                	slli	s4,s4,0x20
ffffffffc02063c8:	00003797          	auipc	a5,0x3
ffffffffc02063cc:	9c078793          	addi	a5,a5,-1600 # ffffffffc0208d88 <syscalls+0x100>
ffffffffc02063d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02063d4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02063d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02063dc:	70a2                	ld	ra,40(sp)
ffffffffc02063de:	69a2                	ld	s3,8(sp)
ffffffffc02063e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063e2:	85ca                	mv	a1,s2
ffffffffc02063e4:	87a6                	mv	a5,s1
}
ffffffffc02063e6:	6942                	ld	s2,16(sp)
ffffffffc02063e8:	64e2                	ld	s1,24(sp)
ffffffffc02063ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063ec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02063ee:	03065633          	divu	a2,a2,a6
ffffffffc02063f2:	8722                	mv	a4,s0
ffffffffc02063f4:	f9bff0ef          	jal	ra,ffffffffc020638e <printnum>
ffffffffc02063f8:	b7f9                	j	ffffffffc02063c6 <printnum+0x38>

ffffffffc02063fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02063fa:	7119                	addi	sp,sp,-128
ffffffffc02063fc:	f4a6                	sd	s1,104(sp)
ffffffffc02063fe:	f0ca                	sd	s2,96(sp)
ffffffffc0206400:	ecce                	sd	s3,88(sp)
ffffffffc0206402:	e8d2                	sd	s4,80(sp)
ffffffffc0206404:	e4d6                	sd	s5,72(sp)
ffffffffc0206406:	e0da                	sd	s6,64(sp)
ffffffffc0206408:	fc5e                	sd	s7,56(sp)
ffffffffc020640a:	f06a                	sd	s10,32(sp)
ffffffffc020640c:	fc86                	sd	ra,120(sp)
ffffffffc020640e:	f8a2                	sd	s0,112(sp)
ffffffffc0206410:	f862                	sd	s8,48(sp)
ffffffffc0206412:	f466                	sd	s9,40(sp)
ffffffffc0206414:	ec6e                	sd	s11,24(sp)
ffffffffc0206416:	892a                	mv	s2,a0
ffffffffc0206418:	84ae                	mv	s1,a1
ffffffffc020641a:	8d32                	mv	s10,a2
ffffffffc020641c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020641e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206422:	5b7d                	li	s6,-1
ffffffffc0206424:	00003a97          	auipc	s5,0x3
ffffffffc0206428:	990a8a93          	addi	s5,s5,-1648 # ffffffffc0208db4 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020642c:	00003b97          	auipc	s7,0x3
ffffffffc0206430:	ba4b8b93          	addi	s7,s7,-1116 # ffffffffc0208fd0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206434:	000d4503          	lbu	a0,0(s10)
ffffffffc0206438:	001d0413          	addi	s0,s10,1
ffffffffc020643c:	01350a63          	beq	a0,s3,ffffffffc0206450 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206440:	c121                	beqz	a0,ffffffffc0206480 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206442:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206444:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206446:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206448:	fff44503          	lbu	a0,-1(s0)
ffffffffc020644c:	ff351ae3          	bne	a0,s3,ffffffffc0206440 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206450:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206454:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206458:	4c81                	li	s9,0
ffffffffc020645a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020645c:	5c7d                	li	s8,-1
ffffffffc020645e:	5dfd                	li	s11,-1
ffffffffc0206460:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206464:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206466:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020646a:	0ff5f593          	zext.b	a1,a1
ffffffffc020646e:	00140d13          	addi	s10,s0,1
ffffffffc0206472:	04b56263          	bltu	a0,a1,ffffffffc02064b6 <vprintfmt+0xbc>
ffffffffc0206476:	058a                	slli	a1,a1,0x2
ffffffffc0206478:	95d6                	add	a1,a1,s5
ffffffffc020647a:	4194                	lw	a3,0(a1)
ffffffffc020647c:	96d6                	add	a3,a3,s5
ffffffffc020647e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206480:	70e6                	ld	ra,120(sp)
ffffffffc0206482:	7446                	ld	s0,112(sp)
ffffffffc0206484:	74a6                	ld	s1,104(sp)
ffffffffc0206486:	7906                	ld	s2,96(sp)
ffffffffc0206488:	69e6                	ld	s3,88(sp)
ffffffffc020648a:	6a46                	ld	s4,80(sp)
ffffffffc020648c:	6aa6                	ld	s5,72(sp)
ffffffffc020648e:	6b06                	ld	s6,64(sp)
ffffffffc0206490:	7be2                	ld	s7,56(sp)
ffffffffc0206492:	7c42                	ld	s8,48(sp)
ffffffffc0206494:	7ca2                	ld	s9,40(sp)
ffffffffc0206496:	7d02                	ld	s10,32(sp)
ffffffffc0206498:	6de2                	ld	s11,24(sp)
ffffffffc020649a:	6109                	addi	sp,sp,128
ffffffffc020649c:	8082                	ret
            padc = '0';
ffffffffc020649e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02064a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064a4:	846a                	mv	s0,s10
ffffffffc02064a6:	00140d13          	addi	s10,s0,1
ffffffffc02064aa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02064ae:	0ff5f593          	zext.b	a1,a1
ffffffffc02064b2:	fcb572e3          	bgeu	a0,a1,ffffffffc0206476 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02064b6:	85a6                	mv	a1,s1
ffffffffc02064b8:	02500513          	li	a0,37
ffffffffc02064bc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02064be:	fff44783          	lbu	a5,-1(s0)
ffffffffc02064c2:	8d22                	mv	s10,s0
ffffffffc02064c4:	f73788e3          	beq	a5,s3,ffffffffc0206434 <vprintfmt+0x3a>
ffffffffc02064c8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02064cc:	1d7d                	addi	s10,s10,-1
ffffffffc02064ce:	ff379de3          	bne	a5,s3,ffffffffc02064c8 <vprintfmt+0xce>
ffffffffc02064d2:	b78d                	j	ffffffffc0206434 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02064d4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02064d8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064dc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02064de:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02064e2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064e6:	02d86463          	bltu	a6,a3,ffffffffc020650e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02064ea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02064ee:	002c169b          	slliw	a3,s8,0x2
ffffffffc02064f2:	0186873b          	addw	a4,a3,s8
ffffffffc02064f6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02064fa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02064fc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206500:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206502:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0206506:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020650a:	fed870e3          	bgeu	a6,a3,ffffffffc02064ea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020650e:	f40ddce3          	bgez	s11,ffffffffc0206466 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206512:	8de2                	mv	s11,s8
ffffffffc0206514:	5c7d                	li	s8,-1
ffffffffc0206516:	bf81                	j	ffffffffc0206466 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0206518:	fffdc693          	not	a3,s11
ffffffffc020651c:	96fd                	srai	a3,a3,0x3f
ffffffffc020651e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206522:	00144603          	lbu	a2,1(s0)
ffffffffc0206526:	2d81                	sext.w	s11,s11
ffffffffc0206528:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020652a:	bf35                	j	ffffffffc0206466 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020652c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206530:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206534:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206536:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206538:	bfd9                	j	ffffffffc020650e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020653a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020653c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206540:	01174463          	blt	a4,a7,ffffffffc0206548 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206544:	1a088e63          	beqz	a7,ffffffffc0206700 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206548:	000a3603          	ld	a2,0(s4)
ffffffffc020654c:	46c1                	li	a3,16
ffffffffc020654e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206550:	2781                	sext.w	a5,a5
ffffffffc0206552:	876e                	mv	a4,s11
ffffffffc0206554:	85a6                	mv	a1,s1
ffffffffc0206556:	854a                	mv	a0,s2
ffffffffc0206558:	e37ff0ef          	jal	ra,ffffffffc020638e <printnum>
            break;
ffffffffc020655c:	bde1                	j	ffffffffc0206434 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020655e:	000a2503          	lw	a0,0(s4)
ffffffffc0206562:	85a6                	mv	a1,s1
ffffffffc0206564:	0a21                	addi	s4,s4,8
ffffffffc0206566:	9902                	jalr	s2
            break;
ffffffffc0206568:	b5f1                	j	ffffffffc0206434 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020656a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020656c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206570:	01174463          	blt	a4,a7,ffffffffc0206578 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206574:	18088163          	beqz	a7,ffffffffc02066f6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206578:	000a3603          	ld	a2,0(s4)
ffffffffc020657c:	46a9                	li	a3,10
ffffffffc020657e:	8a2e                	mv	s4,a1
ffffffffc0206580:	bfc1                	j	ffffffffc0206550 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206582:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206586:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206588:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020658a:	bdf1                	j	ffffffffc0206466 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020658c:	85a6                	mv	a1,s1
ffffffffc020658e:	02500513          	li	a0,37
ffffffffc0206592:	9902                	jalr	s2
            break;
ffffffffc0206594:	b545                	j	ffffffffc0206434 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206596:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020659a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020659c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020659e:	b5e1                	j	ffffffffc0206466 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02065a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02065a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02065a6:	01174463          	blt	a4,a7,ffffffffc02065ae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02065aa:	14088163          	beqz	a7,ffffffffc02066ec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02065ae:	000a3603          	ld	a2,0(s4)
ffffffffc02065b2:	46a1                	li	a3,8
ffffffffc02065b4:	8a2e                	mv	s4,a1
ffffffffc02065b6:	bf69                	j	ffffffffc0206550 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02065b8:	03000513          	li	a0,48
ffffffffc02065bc:	85a6                	mv	a1,s1
ffffffffc02065be:	e03e                	sd	a5,0(sp)
ffffffffc02065c0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02065c2:	85a6                	mv	a1,s1
ffffffffc02065c4:	07800513          	li	a0,120
ffffffffc02065c8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02065ca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02065cc:	6782                	ld	a5,0(sp)
ffffffffc02065ce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02065d0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02065d4:	bfb5                	j	ffffffffc0206550 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02065d6:	000a3403          	ld	s0,0(s4)
ffffffffc02065da:	008a0713          	addi	a4,s4,8
ffffffffc02065de:	e03a                	sd	a4,0(sp)
ffffffffc02065e0:	14040263          	beqz	s0,ffffffffc0206724 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02065e4:	0fb05763          	blez	s11,ffffffffc02066d2 <vprintfmt+0x2d8>
ffffffffc02065e8:	02d00693          	li	a3,45
ffffffffc02065ec:	0cd79163          	bne	a5,a3,ffffffffc02066ae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065f0:	00044783          	lbu	a5,0(s0)
ffffffffc02065f4:	0007851b          	sext.w	a0,a5
ffffffffc02065f8:	cf85                	beqz	a5,ffffffffc0206630 <vprintfmt+0x236>
ffffffffc02065fa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065fe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206602:	000c4563          	bltz	s8,ffffffffc020660c <vprintfmt+0x212>
ffffffffc0206606:	3c7d                	addiw	s8,s8,-1
ffffffffc0206608:	036c0263          	beq	s8,s6,ffffffffc020662c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020660c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020660e:	0e0c8e63          	beqz	s9,ffffffffc020670a <vprintfmt+0x310>
ffffffffc0206612:	3781                	addiw	a5,a5,-32
ffffffffc0206614:	0ef47b63          	bgeu	s0,a5,ffffffffc020670a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206618:	03f00513          	li	a0,63
ffffffffc020661c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020661e:	000a4783          	lbu	a5,0(s4)
ffffffffc0206622:	3dfd                	addiw	s11,s11,-1
ffffffffc0206624:	0a05                	addi	s4,s4,1
ffffffffc0206626:	0007851b          	sext.w	a0,a5
ffffffffc020662a:	ffe1                	bnez	a5,ffffffffc0206602 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020662c:	01b05963          	blez	s11,ffffffffc020663e <vprintfmt+0x244>
ffffffffc0206630:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206632:	85a6                	mv	a1,s1
ffffffffc0206634:	02000513          	li	a0,32
ffffffffc0206638:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020663a:	fe0d9be3          	bnez	s11,ffffffffc0206630 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020663e:	6a02                	ld	s4,0(sp)
ffffffffc0206640:	bbd5                	j	ffffffffc0206434 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206642:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206644:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206648:	01174463          	blt	a4,a7,ffffffffc0206650 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020664c:	08088d63          	beqz	a7,ffffffffc02066e6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206650:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206654:	0a044d63          	bltz	s0,ffffffffc020670e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206658:	8622                	mv	a2,s0
ffffffffc020665a:	8a66                	mv	s4,s9
ffffffffc020665c:	46a9                	li	a3,10
ffffffffc020665e:	bdcd                	j	ffffffffc0206550 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206660:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206664:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206666:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206668:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020666c:	8fb5                	xor	a5,a5,a3
ffffffffc020666e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206672:	02d74163          	blt	a4,a3,ffffffffc0206694 <vprintfmt+0x29a>
ffffffffc0206676:	00369793          	slli	a5,a3,0x3
ffffffffc020667a:	97de                	add	a5,a5,s7
ffffffffc020667c:	639c                	ld	a5,0(a5)
ffffffffc020667e:	cb99                	beqz	a5,ffffffffc0206694 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206680:	86be                	mv	a3,a5
ffffffffc0206682:	00000617          	auipc	a2,0x0
ffffffffc0206686:	1ce60613          	addi	a2,a2,462 # ffffffffc0206850 <etext+0x2e>
ffffffffc020668a:	85a6                	mv	a1,s1
ffffffffc020668c:	854a                	mv	a0,s2
ffffffffc020668e:	0ce000ef          	jal	ra,ffffffffc020675c <printfmt>
ffffffffc0206692:	b34d                	j	ffffffffc0206434 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206694:	00002617          	auipc	a2,0x2
ffffffffc0206698:	71460613          	addi	a2,a2,1812 # ffffffffc0208da8 <syscalls+0x120>
ffffffffc020669c:	85a6                	mv	a1,s1
ffffffffc020669e:	854a                	mv	a0,s2
ffffffffc02066a0:	0bc000ef          	jal	ra,ffffffffc020675c <printfmt>
ffffffffc02066a4:	bb41                	j	ffffffffc0206434 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02066a6:	00002417          	auipc	s0,0x2
ffffffffc02066aa:	6fa40413          	addi	s0,s0,1786 # ffffffffc0208da0 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066ae:	85e2                	mv	a1,s8
ffffffffc02066b0:	8522                	mv	a0,s0
ffffffffc02066b2:	e43e                	sd	a5,8(sp)
ffffffffc02066b4:	0e2000ef          	jal	ra,ffffffffc0206796 <strnlen>
ffffffffc02066b8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02066bc:	01b05b63          	blez	s11,ffffffffc02066d2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02066c0:	67a2                	ld	a5,8(sp)
ffffffffc02066c2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066c6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02066c8:	85a6                	mv	a1,s1
ffffffffc02066ca:	8552                	mv	a0,s4
ffffffffc02066cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066ce:	fe0d9ce3          	bnez	s11,ffffffffc02066c6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02066d2:	00044783          	lbu	a5,0(s0)
ffffffffc02066d6:	00140a13          	addi	s4,s0,1
ffffffffc02066da:	0007851b          	sext.w	a0,a5
ffffffffc02066de:	d3a5                	beqz	a5,ffffffffc020663e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02066e0:	05e00413          	li	s0,94
ffffffffc02066e4:	bf39                	j	ffffffffc0206602 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02066e6:	000a2403          	lw	s0,0(s4)
ffffffffc02066ea:	b7ad                	j	ffffffffc0206654 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02066ec:	000a6603          	lwu	a2,0(s4)
ffffffffc02066f0:	46a1                	li	a3,8
ffffffffc02066f2:	8a2e                	mv	s4,a1
ffffffffc02066f4:	bdb1                	j	ffffffffc0206550 <vprintfmt+0x156>
ffffffffc02066f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02066fa:	46a9                	li	a3,10
ffffffffc02066fc:	8a2e                	mv	s4,a1
ffffffffc02066fe:	bd89                	j	ffffffffc0206550 <vprintfmt+0x156>
ffffffffc0206700:	000a6603          	lwu	a2,0(s4)
ffffffffc0206704:	46c1                	li	a3,16
ffffffffc0206706:	8a2e                	mv	s4,a1
ffffffffc0206708:	b5a1                	j	ffffffffc0206550 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020670a:	9902                	jalr	s2
ffffffffc020670c:	bf09                	j	ffffffffc020661e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020670e:	85a6                	mv	a1,s1
ffffffffc0206710:	02d00513          	li	a0,45
ffffffffc0206714:	e03e                	sd	a5,0(sp)
ffffffffc0206716:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206718:	6782                	ld	a5,0(sp)
ffffffffc020671a:	8a66                	mv	s4,s9
ffffffffc020671c:	40800633          	neg	a2,s0
ffffffffc0206720:	46a9                	li	a3,10
ffffffffc0206722:	b53d                	j	ffffffffc0206550 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206724:	03b05163          	blez	s11,ffffffffc0206746 <vprintfmt+0x34c>
ffffffffc0206728:	02d00693          	li	a3,45
ffffffffc020672c:	f6d79de3          	bne	a5,a3,ffffffffc02066a6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206730:	00002417          	auipc	s0,0x2
ffffffffc0206734:	67040413          	addi	s0,s0,1648 # ffffffffc0208da0 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206738:	02800793          	li	a5,40
ffffffffc020673c:	02800513          	li	a0,40
ffffffffc0206740:	00140a13          	addi	s4,s0,1
ffffffffc0206744:	bd6d                	j	ffffffffc02065fe <vprintfmt+0x204>
ffffffffc0206746:	00002a17          	auipc	s4,0x2
ffffffffc020674a:	65ba0a13          	addi	s4,s4,1627 # ffffffffc0208da1 <syscalls+0x119>
ffffffffc020674e:	02800513          	li	a0,40
ffffffffc0206752:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206756:	05e00413          	li	s0,94
ffffffffc020675a:	b565                	j	ffffffffc0206602 <vprintfmt+0x208>

ffffffffc020675c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020675c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020675e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206762:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206764:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206766:	ec06                	sd	ra,24(sp)
ffffffffc0206768:	f83a                	sd	a4,48(sp)
ffffffffc020676a:	fc3e                	sd	a5,56(sp)
ffffffffc020676c:	e0c2                	sd	a6,64(sp)
ffffffffc020676e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206770:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206772:	c89ff0ef          	jal	ra,ffffffffc02063fa <vprintfmt>
}
ffffffffc0206776:	60e2                	ld	ra,24(sp)
ffffffffc0206778:	6161                	addi	sp,sp,80
ffffffffc020677a:	8082                	ret

ffffffffc020677c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020677c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206780:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206782:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206784:	cb81                	beqz	a5,ffffffffc0206794 <strlen+0x18>
        cnt ++;
ffffffffc0206786:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206788:	00a707b3          	add	a5,a4,a0
ffffffffc020678c:	0007c783          	lbu	a5,0(a5)
ffffffffc0206790:	fbfd                	bnez	a5,ffffffffc0206786 <strlen+0xa>
ffffffffc0206792:	8082                	ret
    }
    return cnt;
}
ffffffffc0206794:	8082                	ret

ffffffffc0206796 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206796:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206798:	e589                	bnez	a1,ffffffffc02067a2 <strnlen+0xc>
ffffffffc020679a:	a811                	j	ffffffffc02067ae <strnlen+0x18>
        cnt ++;
ffffffffc020679c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020679e:	00f58863          	beq	a1,a5,ffffffffc02067ae <strnlen+0x18>
ffffffffc02067a2:	00f50733          	add	a4,a0,a5
ffffffffc02067a6:	00074703          	lbu	a4,0(a4)
ffffffffc02067aa:	fb6d                	bnez	a4,ffffffffc020679c <strnlen+0x6>
ffffffffc02067ac:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02067ae:	852e                	mv	a0,a1
ffffffffc02067b0:	8082                	ret

ffffffffc02067b2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02067b2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02067b4:	0005c703          	lbu	a4,0(a1)
ffffffffc02067b8:	0785                	addi	a5,a5,1
ffffffffc02067ba:	0585                	addi	a1,a1,1
ffffffffc02067bc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02067c0:	fb75                	bnez	a4,ffffffffc02067b4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02067c2:	8082                	ret

ffffffffc02067c4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02067c4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02067c8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02067cc:	cb89                	beqz	a5,ffffffffc02067de <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02067ce:	0505                	addi	a0,a0,1
ffffffffc02067d0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02067d2:	fee789e3          	beq	a5,a4,ffffffffc02067c4 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02067d6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02067da:	9d19                	subw	a0,a0,a4
ffffffffc02067dc:	8082                	ret
ffffffffc02067de:	4501                	li	a0,0
ffffffffc02067e0:	bfed                	j	ffffffffc02067da <strcmp+0x16>

ffffffffc02067e2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02067e2:	00054783          	lbu	a5,0(a0)
ffffffffc02067e6:	c799                	beqz	a5,ffffffffc02067f4 <strchr+0x12>
        if (*s == c) {
ffffffffc02067e8:	00f58763          	beq	a1,a5,ffffffffc02067f6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02067ec:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02067f0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02067f2:	fbfd                	bnez	a5,ffffffffc02067e8 <strchr+0x6>
    }
    return NULL;
ffffffffc02067f4:	4501                	li	a0,0
}
ffffffffc02067f6:	8082                	ret

ffffffffc02067f8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02067f8:	ca01                	beqz	a2,ffffffffc0206808 <memset+0x10>
ffffffffc02067fa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02067fc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02067fe:	0785                	addi	a5,a5,1
ffffffffc0206800:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206804:	fec79de3          	bne	a5,a2,ffffffffc02067fe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206808:	8082                	ret

ffffffffc020680a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020680a:	ca19                	beqz	a2,ffffffffc0206820 <memcpy+0x16>
ffffffffc020680c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020680e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206810:	0005c703          	lbu	a4,0(a1)
ffffffffc0206814:	0585                	addi	a1,a1,1
ffffffffc0206816:	0785                	addi	a5,a5,1
ffffffffc0206818:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020681c:	fec59ae3          	bne	a1,a2,ffffffffc0206810 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206820:	8082                	ret
