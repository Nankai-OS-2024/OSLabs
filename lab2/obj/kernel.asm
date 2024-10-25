
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02062b7          	lui	t0,0xc0206
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
ffffffffc020001c:	18029073          	csrw	satp,t0
ffffffffc0200020:	12000073          	sfence.vma
ffffffffc0200024:	c0206137          	lui	sp,0xc0206
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00007517          	auipc	a0,0x7
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0207010 <free_area>
ffffffffc020003a:	00007617          	auipc	a2,0x7
ffffffffc020003e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0207528 <end>
{
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
{
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	452020ef          	jal	ra,ffffffffc020249c <memset>
    cons_init(); // init the console
ffffffffc020004e:	400000ef          	jal	ra,ffffffffc020044e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    // cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	47650513          	addi	a0,a0,1142 # ffffffffc02024c8 <etext+0x2>
ffffffffc020005a:	094000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc020005e:	0e0000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init(); // init interrupt descriptor table
ffffffffc0200062:	406000ef          	jal	ra,ffffffffc0200468 <idt_init>

    pmm_init(); // init physical memory management
ffffffffc0200066:	264010ef          	jal	ra,ffffffffc02012ca <pmm_init>

    kmem_init(); // init kmem_cache which contains slabs
ffffffffc020006a:	0df010ef          	jal	ra,ffffffffc0201948 <kmem_init>

    idt_init(); // init interrupt descriptor table
ffffffffc020006e:	3fa000ef          	jal	ra,ffffffffc0200468 <idt_init>

    clock_init();  // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc0200076:	3e6000ef          	jal	ra,ffffffffc020045c <intr_enable>

    /* do nothing */
    while (1)
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x48>

ffffffffc020007c <cputch>:
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
ffffffffc0200084:	3cc000ef          	jal	ra,ffffffffc0200450 <cons_putc>
ffffffffc0200088:	401c                	lw	a5,0(s0)
ffffffffc020008a:	60a2                	ld	ra,8(sp)
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
ffffffffc0200096:	1101                	addi	sp,sp,-32
ffffffffc0200098:	862a                	mv	a2,a0
ffffffffc020009a:	86ae                	mv	a3,a1
ffffffffc020009c:	00000517          	auipc	a0,0x0
ffffffffc02000a0:	fe050513          	addi	a0,a0,-32 # ffffffffc020007c <cputch>
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
ffffffffc02000a8:	c602                	sw	zero,12(sp)
ffffffffc02000aa:	71d010ef          	jal	ra,ffffffffc0201fc6 <vprintfmt>
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
ffffffffc02000b6:	711d                	addi	sp,sp,-96
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
ffffffffc02000bc:	8e2a                	mv	t3,a0
ffffffffc02000be:	f42e                	sd	a1,40(sp)
ffffffffc02000c0:	f832                	sd	a2,48(sp)
ffffffffc02000c2:	fc36                	sd	a3,56(sp)
ffffffffc02000c4:	00000517          	auipc	a0,0x0
ffffffffc02000c8:	fb850513          	addi	a0,a0,-72 # ffffffffc020007c <cputch>
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	869a                	mv	a3,t1
ffffffffc02000d0:	8672                	mv	a2,t3
ffffffffc02000d2:	ec06                	sd	ra,24(sp)
ffffffffc02000d4:	e0ba                	sd	a4,64(sp)
ffffffffc02000d6:	e4be                	sd	a5,72(sp)
ffffffffc02000d8:	e8c2                	sd	a6,80(sp)
ffffffffc02000da:	ecc6                	sd	a7,88(sp)
ffffffffc02000dc:	e41a                	sd	t1,8(sp)
ffffffffc02000de:	c202                	sw	zero,4(sp)
ffffffffc02000e0:	6e7010ef          	jal	ra,ffffffffc0201fc6 <vprintfmt>
ffffffffc02000e4:	60e2                	ld	ra,24(sp)
ffffffffc02000e6:	4512                	lw	a0,4(sp)
ffffffffc02000e8:	6125                	addi	sp,sp,96
ffffffffc02000ea:	8082                	ret

ffffffffc02000ec <cputchar>:
ffffffffc02000ec:	a695                	j	ffffffffc0200450 <cons_putc>

ffffffffc02000ee <cputs>:
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
ffffffffc0200104:	34c000ef          	jal	ra,ffffffffc0200450 <cons_putc>
ffffffffc0200108:	00044503          	lbu	a0,0(s0)
ffffffffc020010c:	008487bb          	addw	a5,s1,s0
ffffffffc0200110:	0405                	addi	s0,s0,1
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	336000ef          	jal	ra,ffffffffc0200450 <cons_putc>
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
ffffffffc0200132:	326000ef          	jal	ra,ffffffffc0200458 <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
ffffffffc020013e:	1141                	addi	sp,sp,-16
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	3a850513          	addi	a0,a0,936 # ffffffffc02024e8 <etext+0x22>
ffffffffc0200148:	e406                	sd	ra,8(sp)
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee458593          	addi	a1,a1,-284 # ffffffffc0200032 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	3b250513          	addi	a0,a0,946 # ffffffffc0202508 <etext+0x42>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	36458593          	addi	a1,a1,868 # ffffffffc02024c6 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	3be50513          	addi	a0,a0,958 # ffffffffc0202528 <etext+0x62>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200176:	00007597          	auipc	a1,0x7
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0207010 <free_area>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	3ca50513          	addi	a0,a0,970 # ffffffffc0202548 <etext+0x82>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020018a:	00007597          	auipc	a1,0x7
ffffffffc020018e:	39e58593          	addi	a1,a1,926 # ffffffffc0207528 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	3d650513          	addi	a0,a0,982 # ffffffffc0202568 <etext+0xa2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020019e:	00007597          	auipc	a1,0x7
ffffffffc02001a2:	78958593          	addi	a1,a1,1929 # ffffffffc0207927 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e8c78793          	addi	a5,a5,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	3c850513          	addi	a0,a0,968 # ffffffffc0202588 <etext+0xc2>
ffffffffc02001c8:	0141                	addi	sp,sp,16
ffffffffc02001ca:	b5f5                	j	ffffffffc02000b6 <cprintf>

ffffffffc02001cc <print_stackframe>:
ffffffffc02001cc:	1141                	addi	sp,sp,-16
ffffffffc02001ce:	00002617          	auipc	a2,0x2
ffffffffc02001d2:	3ea60613          	addi	a2,a2,1002 # ffffffffc02025b8 <etext+0xf2>
ffffffffc02001d6:	04e00593          	li	a1,78
ffffffffc02001da:	00002517          	auipc	a0,0x2
ffffffffc02001de:	3f650513          	addi	a0,a0,1014 # ffffffffc02025d0 <etext+0x10a>
ffffffffc02001e2:	e406                	sd	ra,8(sp)
ffffffffc02001e4:	1cc000ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc02001e8 <mon_help>:
ffffffffc02001e8:	1141                	addi	sp,sp,-16
ffffffffc02001ea:	00002617          	auipc	a2,0x2
ffffffffc02001ee:	3fe60613          	addi	a2,a2,1022 # ffffffffc02025e8 <etext+0x122>
ffffffffc02001f2:	00002597          	auipc	a1,0x2
ffffffffc02001f6:	41658593          	addi	a1,a1,1046 # ffffffffc0202608 <etext+0x142>
ffffffffc02001fa:	00002517          	auipc	a0,0x2
ffffffffc02001fe:	41650513          	addi	a0,a0,1046 # ffffffffc0202610 <etext+0x14a>
ffffffffc0200202:	e406                	sd	ra,8(sp)
ffffffffc0200204:	eb3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200208:	00002617          	auipc	a2,0x2
ffffffffc020020c:	41860613          	addi	a2,a2,1048 # ffffffffc0202620 <etext+0x15a>
ffffffffc0200210:	00002597          	auipc	a1,0x2
ffffffffc0200214:	43858593          	addi	a1,a1,1080 # ffffffffc0202648 <etext+0x182>
ffffffffc0200218:	00002517          	auipc	a0,0x2
ffffffffc020021c:	3f850513          	addi	a0,a0,1016 # ffffffffc0202610 <etext+0x14a>
ffffffffc0200220:	e97ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200224:	00002617          	auipc	a2,0x2
ffffffffc0200228:	43460613          	addi	a2,a2,1076 # ffffffffc0202658 <etext+0x192>
ffffffffc020022c:	00002597          	auipc	a1,0x2
ffffffffc0200230:	44c58593          	addi	a1,a1,1100 # ffffffffc0202678 <etext+0x1b2>
ffffffffc0200234:	00002517          	auipc	a0,0x2
ffffffffc0200238:	3dc50513          	addi	a0,a0,988 # ffffffffc0202610 <etext+0x14a>
ffffffffc020023c:	e7bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200240:	60a2                	ld	ra,8(sp)
ffffffffc0200242:	4501                	li	a0,0
ffffffffc0200244:	0141                	addi	sp,sp,16
ffffffffc0200246:	8082                	ret

ffffffffc0200248 <mon_kerninfo>:
ffffffffc0200248:	1141                	addi	sp,sp,-16
ffffffffc020024a:	e406                	sd	ra,8(sp)
ffffffffc020024c:	ef3ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
ffffffffc0200250:	60a2                	ld	ra,8(sp)
ffffffffc0200252:	4501                	li	a0,0
ffffffffc0200254:	0141                	addi	sp,sp,16
ffffffffc0200256:	8082                	ret

ffffffffc0200258 <mon_backtrace>:
ffffffffc0200258:	1141                	addi	sp,sp,-16
ffffffffc020025a:	e406                	sd	ra,8(sp)
ffffffffc020025c:	f71ff0ef          	jal	ra,ffffffffc02001cc <print_stackframe>
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <kmonitor>:
ffffffffc0200268:	7115                	addi	sp,sp,-224
ffffffffc020026a:	ed5e                	sd	s7,152(sp)
ffffffffc020026c:	8baa                	mv	s7,a0
ffffffffc020026e:	00002517          	auipc	a0,0x2
ffffffffc0200272:	41a50513          	addi	a0,a0,1050 # ffffffffc0202688 <etext+0x1c2>
ffffffffc0200276:	ed86                	sd	ra,216(sp)
ffffffffc0200278:	e9a2                	sd	s0,208(sp)
ffffffffc020027a:	e5a6                	sd	s1,200(sp)
ffffffffc020027c:	e1ca                	sd	s2,192(sp)
ffffffffc020027e:	fd4e                	sd	s3,184(sp)
ffffffffc0200280:	f952                	sd	s4,176(sp)
ffffffffc0200282:	f556                	sd	s5,168(sp)
ffffffffc0200284:	f15a                	sd	s6,160(sp)
ffffffffc0200286:	e962                	sd	s8,144(sp)
ffffffffc0200288:	e566                	sd	s9,136(sp)
ffffffffc020028a:	e16a                	sd	s10,128(sp)
ffffffffc020028c:	e2bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200290:	00002517          	auipc	a0,0x2
ffffffffc0200294:	42050513          	addi	a0,a0,1056 # ffffffffc02026b0 <etext+0x1ea>
ffffffffc0200298:	e1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020029c:	000b8563          	beqz	s7,ffffffffc02002a6 <kmonitor+0x3e>
ffffffffc02002a0:	855e                	mv	a0,s7
ffffffffc02002a2:	3a4000ef          	jal	ra,ffffffffc0200646 <print_trapframe>
ffffffffc02002a6:	00002c17          	auipc	s8,0x2
ffffffffc02002aa:	47ac0c13          	addi	s8,s8,1146 # ffffffffc0202720 <commands>
ffffffffc02002ae:	00002917          	auipc	s2,0x2
ffffffffc02002b2:	42a90913          	addi	s2,s2,1066 # ffffffffc02026d8 <etext+0x212>
ffffffffc02002b6:	00002497          	auipc	s1,0x2
ffffffffc02002ba:	42a48493          	addi	s1,s1,1066 # ffffffffc02026e0 <etext+0x21a>
ffffffffc02002be:	49bd                	li	s3,15
ffffffffc02002c0:	00002b17          	auipc	s6,0x2
ffffffffc02002c4:	428b0b13          	addi	s6,s6,1064 # ffffffffc02026e8 <etext+0x222>
ffffffffc02002c8:	00002a17          	auipc	s4,0x2
ffffffffc02002cc:	340a0a13          	addi	s4,s4,832 # ffffffffc0202608 <etext+0x142>
ffffffffc02002d0:	4a8d                	li	s5,3
ffffffffc02002d2:	854a                	mv	a0,s2
ffffffffc02002d4:	074020ef          	jal	ra,ffffffffc0202348 <readline>
ffffffffc02002d8:	842a                	mv	s0,a0
ffffffffc02002da:	dd65                	beqz	a0,ffffffffc02002d2 <kmonitor+0x6a>
ffffffffc02002dc:	00054583          	lbu	a1,0(a0)
ffffffffc02002e0:	4c81                	li	s9,0
ffffffffc02002e2:	e1bd                	bnez	a1,ffffffffc0200348 <kmonitor+0xe0>
ffffffffc02002e4:	fe0c87e3          	beqz	s9,ffffffffc02002d2 <kmonitor+0x6a>
ffffffffc02002e8:	6582                	ld	a1,0(sp)
ffffffffc02002ea:	00002d17          	auipc	s10,0x2
ffffffffc02002ee:	436d0d13          	addi	s10,s10,1078 # ffffffffc0202720 <commands>
ffffffffc02002f2:	8552                	mv	a0,s4
ffffffffc02002f4:	4401                	li	s0,0
ffffffffc02002f6:	0d61                	addi	s10,s10,24
ffffffffc02002f8:	170020ef          	jal	ra,ffffffffc0202468 <strcmp>
ffffffffc02002fc:	c919                	beqz	a0,ffffffffc0200312 <kmonitor+0xaa>
ffffffffc02002fe:	2405                	addiw	s0,s0,1
ffffffffc0200300:	0b540063          	beq	s0,s5,ffffffffc02003a0 <kmonitor+0x138>
ffffffffc0200304:	000d3503          	ld	a0,0(s10)
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	15c020ef          	jal	ra,ffffffffc0202468 <strcmp>
ffffffffc0200310:	f57d                	bnez	a0,ffffffffc02002fe <kmonitor+0x96>
ffffffffc0200312:	00141793          	slli	a5,s0,0x1
ffffffffc0200316:	97a2                	add	a5,a5,s0
ffffffffc0200318:	078e                	slli	a5,a5,0x3
ffffffffc020031a:	97e2                	add	a5,a5,s8
ffffffffc020031c:	6b9c                	ld	a5,16(a5)
ffffffffc020031e:	865e                	mv	a2,s7
ffffffffc0200320:	002c                	addi	a1,sp,8
ffffffffc0200322:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200326:	9782                	jalr	a5
ffffffffc0200328:	fa0555e3          	bgez	a0,ffffffffc02002d2 <kmonitor+0x6a>
ffffffffc020032c:	60ee                	ld	ra,216(sp)
ffffffffc020032e:	644e                	ld	s0,208(sp)
ffffffffc0200330:	64ae                	ld	s1,200(sp)
ffffffffc0200332:	690e                	ld	s2,192(sp)
ffffffffc0200334:	79ea                	ld	s3,184(sp)
ffffffffc0200336:	7a4a                	ld	s4,176(sp)
ffffffffc0200338:	7aaa                	ld	s5,168(sp)
ffffffffc020033a:	7b0a                	ld	s6,160(sp)
ffffffffc020033c:	6bea                	ld	s7,152(sp)
ffffffffc020033e:	6c4a                	ld	s8,144(sp)
ffffffffc0200340:	6caa                	ld	s9,136(sp)
ffffffffc0200342:	6d0a                	ld	s10,128(sp)
ffffffffc0200344:	612d                	addi	sp,sp,224
ffffffffc0200346:	8082                	ret
ffffffffc0200348:	8526                	mv	a0,s1
ffffffffc020034a:	13c020ef          	jal	ra,ffffffffc0202486 <strchr>
ffffffffc020034e:	c901                	beqz	a0,ffffffffc020035e <kmonitor+0xf6>
ffffffffc0200350:	00144583          	lbu	a1,1(s0)
ffffffffc0200354:	00040023          	sb	zero,0(s0)
ffffffffc0200358:	0405                	addi	s0,s0,1
ffffffffc020035a:	d5c9                	beqz	a1,ffffffffc02002e4 <kmonitor+0x7c>
ffffffffc020035c:	b7f5                	j	ffffffffc0200348 <kmonitor+0xe0>
ffffffffc020035e:	00044783          	lbu	a5,0(s0)
ffffffffc0200362:	d3c9                	beqz	a5,ffffffffc02002e4 <kmonitor+0x7c>
ffffffffc0200364:	033c8963          	beq	s9,s3,ffffffffc0200396 <kmonitor+0x12e>
ffffffffc0200368:	003c9793          	slli	a5,s9,0x3
ffffffffc020036c:	0118                	addi	a4,sp,128
ffffffffc020036e:	97ba                	add	a5,a5,a4
ffffffffc0200370:	f887b023          	sd	s0,-128(a5)
ffffffffc0200374:	00044583          	lbu	a1,0(s0)
ffffffffc0200378:	2c85                	addiw	s9,s9,1
ffffffffc020037a:	e591                	bnez	a1,ffffffffc0200386 <kmonitor+0x11e>
ffffffffc020037c:	b7b5                	j	ffffffffc02002e8 <kmonitor+0x80>
ffffffffc020037e:	00144583          	lbu	a1,1(s0)
ffffffffc0200382:	0405                	addi	s0,s0,1
ffffffffc0200384:	d1a5                	beqz	a1,ffffffffc02002e4 <kmonitor+0x7c>
ffffffffc0200386:	8526                	mv	a0,s1
ffffffffc0200388:	0fe020ef          	jal	ra,ffffffffc0202486 <strchr>
ffffffffc020038c:	d96d                	beqz	a0,ffffffffc020037e <kmonitor+0x116>
ffffffffc020038e:	00044583          	lbu	a1,0(s0)
ffffffffc0200392:	d9a9                	beqz	a1,ffffffffc02002e4 <kmonitor+0x7c>
ffffffffc0200394:	bf55                	j	ffffffffc0200348 <kmonitor+0xe0>
ffffffffc0200396:	45c1                	li	a1,16
ffffffffc0200398:	855a                	mv	a0,s6
ffffffffc020039a:	d1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039e:	b7e9                	j	ffffffffc0200368 <kmonitor+0x100>
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00002517          	auipc	a0,0x2
ffffffffc02003a6:	36650513          	addi	a0,a0,870 # ffffffffc0202708 <etext+0x242>
ffffffffc02003aa:	d0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003ae:	b715                	j	ffffffffc02002d2 <kmonitor+0x6a>

ffffffffc02003b0 <__panic>:
ffffffffc02003b0:	00007317          	auipc	t1,0x7
ffffffffc02003b4:	13030313          	addi	t1,t1,304 # ffffffffc02074e0 <is_panic>
ffffffffc02003b8:	00032e03          	lw	t3,0(t1)
ffffffffc02003bc:	715d                	addi	sp,sp,-80
ffffffffc02003be:	ec06                	sd	ra,24(sp)
ffffffffc02003c0:	e822                	sd	s0,16(sp)
ffffffffc02003c2:	f436                	sd	a3,40(sp)
ffffffffc02003c4:	f83a                	sd	a4,48(sp)
ffffffffc02003c6:	fc3e                	sd	a5,56(sp)
ffffffffc02003c8:	e0c2                	sd	a6,64(sp)
ffffffffc02003ca:	e4c6                	sd	a7,72(sp)
ffffffffc02003cc:	020e1a63          	bnez	t3,ffffffffc0200400 <__panic+0x50>
ffffffffc02003d0:	4785                	li	a5,1
ffffffffc02003d2:	00f32023          	sw	a5,0(t1)
ffffffffc02003d6:	8432                	mv	s0,a2
ffffffffc02003d8:	103c                	addi	a5,sp,40
ffffffffc02003da:	862e                	mv	a2,a1
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	38a50513          	addi	a0,a0,906 # ffffffffc0202768 <commands+0x48>
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
ffffffffc02003f4:	00003517          	auipc	a0,0x3
ffffffffc02003f8:	08450513          	addi	a0,a0,132 # ffffffffc0203478 <best_fit_pmm_manager+0x518>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200400:	062000ef          	jal	ra,ffffffffc0200462 <intr_disable>
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e63ff0ef          	jal	ra,ffffffffc0200268 <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x54>

ffffffffc020040c <clock_init>:
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200418:	c0102573          	rdtime	a0
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	7f3010ef          	jal	ra,ffffffffc0202416 <sbi_set_timer>
ffffffffc0200428:	60a2                	ld	ra,8(sp)
ffffffffc020042a:	00007797          	auipc	a5,0x7
ffffffffc020042e:	0a07bf23          	sd	zero,190(a5) # ffffffffc02074e8 <ticks>
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	35650513          	addi	a0,a0,854 # ffffffffc0202788 <commands+0x68>
ffffffffc020043a:	0141                	addi	sp,sp,16
ffffffffc020043c:	b9ad                	j	ffffffffc02000b6 <cprintf>

ffffffffc020043e <clock_set_next_event>:
ffffffffc020043e:	c0102573          	rdtime	a0
ffffffffc0200442:	67e1                	lui	a5,0x18
ffffffffc0200444:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200448:	953e                	add	a0,a0,a5
ffffffffc020044a:	7cd0106f          	j	ffffffffc0202416 <sbi_set_timer>

ffffffffc020044e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044e:	8082                	ret

ffffffffc0200450 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200450:	0ff57513          	zext.b	a0,a0
ffffffffc0200454:	7a90106f          	j	ffffffffc02023fc <sbi_console_putchar>

ffffffffc0200458 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200458:	7d90106f          	j	ffffffffc0202430 <sbi_console_getchar>

ffffffffc020045c <intr_enable>:
ffffffffc020045c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200460:	8082                	ret

ffffffffc0200462 <intr_disable>:
ffffffffc0200462:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200466:	8082                	ret

ffffffffc0200468 <idt_init>:
ffffffffc0200468:	14005073          	csrwi	sscratch,0
ffffffffc020046c:	00000797          	auipc	a5,0x0
ffffffffc0200470:	2e478793          	addi	a5,a5,740 # ffffffffc0200750 <__alltraps>
ffffffffc0200474:	10579073          	csrw	stvec,a5
ffffffffc0200478:	8082                	ret

ffffffffc020047a <print_regs>:
ffffffffc020047a:	610c                	ld	a1,0(a0)
ffffffffc020047c:	1141                	addi	sp,sp,-16
ffffffffc020047e:	e022                	sd	s0,0(sp)
ffffffffc0200480:	842a                	mv	s0,a0
ffffffffc0200482:	00002517          	auipc	a0,0x2
ffffffffc0200486:	32650513          	addi	a0,a0,806 # ffffffffc02027a8 <commands+0x88>
ffffffffc020048a:	e406                	sd	ra,8(sp)
ffffffffc020048c:	c2bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200490:	640c                	ld	a1,8(s0)
ffffffffc0200492:	00002517          	auipc	a0,0x2
ffffffffc0200496:	32e50513          	addi	a0,a0,814 # ffffffffc02027c0 <commands+0xa0>
ffffffffc020049a:	c1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020049e:	680c                	ld	a1,16(s0)
ffffffffc02004a0:	00002517          	auipc	a0,0x2
ffffffffc02004a4:	33850513          	addi	a0,a0,824 # ffffffffc02027d8 <commands+0xb8>
ffffffffc02004a8:	c0fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004ac:	6c0c                	ld	a1,24(s0)
ffffffffc02004ae:	00002517          	auipc	a0,0x2
ffffffffc02004b2:	34250513          	addi	a0,a0,834 # ffffffffc02027f0 <commands+0xd0>
ffffffffc02004b6:	c01ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004ba:	700c                	ld	a1,32(s0)
ffffffffc02004bc:	00002517          	auipc	a0,0x2
ffffffffc02004c0:	34c50513          	addi	a0,a0,844 # ffffffffc0202808 <commands+0xe8>
ffffffffc02004c4:	bf3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004c8:	740c                	ld	a1,40(s0)
ffffffffc02004ca:	00002517          	auipc	a0,0x2
ffffffffc02004ce:	35650513          	addi	a0,a0,854 # ffffffffc0202820 <commands+0x100>
ffffffffc02004d2:	be5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004d6:	780c                	ld	a1,48(s0)
ffffffffc02004d8:	00002517          	auipc	a0,0x2
ffffffffc02004dc:	36050513          	addi	a0,a0,864 # ffffffffc0202838 <commands+0x118>
ffffffffc02004e0:	bd7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004e4:	7c0c                	ld	a1,56(s0)
ffffffffc02004e6:	00002517          	auipc	a0,0x2
ffffffffc02004ea:	36a50513          	addi	a0,a0,874 # ffffffffc0202850 <commands+0x130>
ffffffffc02004ee:	bc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004f2:	602c                	ld	a1,64(s0)
ffffffffc02004f4:	00002517          	auipc	a0,0x2
ffffffffc02004f8:	37450513          	addi	a0,a0,884 # ffffffffc0202868 <commands+0x148>
ffffffffc02004fc:	bbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200500:	642c                	ld	a1,72(s0)
ffffffffc0200502:	00002517          	auipc	a0,0x2
ffffffffc0200506:	37e50513          	addi	a0,a0,894 # ffffffffc0202880 <commands+0x160>
ffffffffc020050a:	badff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020050e:	682c                	ld	a1,80(s0)
ffffffffc0200510:	00002517          	auipc	a0,0x2
ffffffffc0200514:	38850513          	addi	a0,a0,904 # ffffffffc0202898 <commands+0x178>
ffffffffc0200518:	b9fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020051c:	6c2c                	ld	a1,88(s0)
ffffffffc020051e:	00002517          	auipc	a0,0x2
ffffffffc0200522:	39250513          	addi	a0,a0,914 # ffffffffc02028b0 <commands+0x190>
ffffffffc0200526:	b91ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020052a:	702c                	ld	a1,96(s0)
ffffffffc020052c:	00002517          	auipc	a0,0x2
ffffffffc0200530:	39c50513          	addi	a0,a0,924 # ffffffffc02028c8 <commands+0x1a8>
ffffffffc0200534:	b83ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200538:	742c                	ld	a1,104(s0)
ffffffffc020053a:	00002517          	auipc	a0,0x2
ffffffffc020053e:	3a650513          	addi	a0,a0,934 # ffffffffc02028e0 <commands+0x1c0>
ffffffffc0200542:	b75ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200546:	782c                	ld	a1,112(s0)
ffffffffc0200548:	00002517          	auipc	a0,0x2
ffffffffc020054c:	3b050513          	addi	a0,a0,944 # ffffffffc02028f8 <commands+0x1d8>
ffffffffc0200550:	b67ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200554:	7c2c                	ld	a1,120(s0)
ffffffffc0200556:	00002517          	auipc	a0,0x2
ffffffffc020055a:	3ba50513          	addi	a0,a0,954 # ffffffffc0202910 <commands+0x1f0>
ffffffffc020055e:	b59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200562:	604c                	ld	a1,128(s0)
ffffffffc0200564:	00002517          	auipc	a0,0x2
ffffffffc0200568:	3c450513          	addi	a0,a0,964 # ffffffffc0202928 <commands+0x208>
ffffffffc020056c:	b4bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200570:	644c                	ld	a1,136(s0)
ffffffffc0200572:	00002517          	auipc	a0,0x2
ffffffffc0200576:	3ce50513          	addi	a0,a0,974 # ffffffffc0202940 <commands+0x220>
ffffffffc020057a:	b3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020057e:	684c                	ld	a1,144(s0)
ffffffffc0200580:	00002517          	auipc	a0,0x2
ffffffffc0200584:	3d850513          	addi	a0,a0,984 # ffffffffc0202958 <commands+0x238>
ffffffffc0200588:	b2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020058c:	6c4c                	ld	a1,152(s0)
ffffffffc020058e:	00002517          	auipc	a0,0x2
ffffffffc0200592:	3e250513          	addi	a0,a0,994 # ffffffffc0202970 <commands+0x250>
ffffffffc0200596:	b21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020059a:	704c                	ld	a1,160(s0)
ffffffffc020059c:	00002517          	auipc	a0,0x2
ffffffffc02005a0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0202988 <commands+0x268>
ffffffffc02005a4:	b13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005a8:	744c                	ld	a1,168(s0)
ffffffffc02005aa:	00002517          	auipc	a0,0x2
ffffffffc02005ae:	3f650513          	addi	a0,a0,1014 # ffffffffc02029a0 <commands+0x280>
ffffffffc02005b2:	b05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005b6:	784c                	ld	a1,176(s0)
ffffffffc02005b8:	00002517          	auipc	a0,0x2
ffffffffc02005bc:	40050513          	addi	a0,a0,1024 # ffffffffc02029b8 <commands+0x298>
ffffffffc02005c0:	af7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005c4:	7c4c                	ld	a1,184(s0)
ffffffffc02005c6:	00002517          	auipc	a0,0x2
ffffffffc02005ca:	40a50513          	addi	a0,a0,1034 # ffffffffc02029d0 <commands+0x2b0>
ffffffffc02005ce:	ae9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005d2:	606c                	ld	a1,192(s0)
ffffffffc02005d4:	00002517          	auipc	a0,0x2
ffffffffc02005d8:	41450513          	addi	a0,a0,1044 # ffffffffc02029e8 <commands+0x2c8>
ffffffffc02005dc:	adbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005e0:	646c                	ld	a1,200(s0)
ffffffffc02005e2:	00002517          	auipc	a0,0x2
ffffffffc02005e6:	41e50513          	addi	a0,a0,1054 # ffffffffc0202a00 <commands+0x2e0>
ffffffffc02005ea:	acdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005ee:	686c                	ld	a1,208(s0)
ffffffffc02005f0:	00002517          	auipc	a0,0x2
ffffffffc02005f4:	42850513          	addi	a0,a0,1064 # ffffffffc0202a18 <commands+0x2f8>
ffffffffc02005f8:	abfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005fc:	6c6c                	ld	a1,216(s0)
ffffffffc02005fe:	00002517          	auipc	a0,0x2
ffffffffc0200602:	43250513          	addi	a0,a0,1074 # ffffffffc0202a30 <commands+0x310>
ffffffffc0200606:	ab1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020060a:	706c                	ld	a1,224(s0)
ffffffffc020060c:	00002517          	auipc	a0,0x2
ffffffffc0200610:	43c50513          	addi	a0,a0,1084 # ffffffffc0202a48 <commands+0x328>
ffffffffc0200614:	aa3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200618:	746c                	ld	a1,232(s0)
ffffffffc020061a:	00002517          	auipc	a0,0x2
ffffffffc020061e:	44650513          	addi	a0,a0,1094 # ffffffffc0202a60 <commands+0x340>
ffffffffc0200622:	a95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200626:	786c                	ld	a1,240(s0)
ffffffffc0200628:	00002517          	auipc	a0,0x2
ffffffffc020062c:	45050513          	addi	a0,a0,1104 # ffffffffc0202a78 <commands+0x358>
ffffffffc0200630:	a87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200634:	7c6c                	ld	a1,248(s0)
ffffffffc0200636:	6402                	ld	s0,0(sp)
ffffffffc0200638:	60a2                	ld	ra,8(sp)
ffffffffc020063a:	00002517          	auipc	a0,0x2
ffffffffc020063e:	45650513          	addi	a0,a0,1110 # ffffffffc0202a90 <commands+0x370>
ffffffffc0200642:	0141                	addi	sp,sp,16
ffffffffc0200644:	bc8d                	j	ffffffffc02000b6 <cprintf>

ffffffffc0200646 <print_trapframe>:
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
ffffffffc020064a:	85aa                	mv	a1,a0
ffffffffc020064c:	842a                	mv	s0,a0
ffffffffc020064e:	00002517          	auipc	a0,0x2
ffffffffc0200652:	45a50513          	addi	a0,a0,1114 # ffffffffc0202aa8 <commands+0x388>
ffffffffc0200656:	e406                	sd	ra,8(sp)
ffffffffc0200658:	a5fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020065c:	8522                	mv	a0,s0
ffffffffc020065e:	e1dff0ef          	jal	ra,ffffffffc020047a <print_regs>
ffffffffc0200662:	10043583          	ld	a1,256(s0)
ffffffffc0200666:	00002517          	auipc	a0,0x2
ffffffffc020066a:	45a50513          	addi	a0,a0,1114 # ffffffffc0202ac0 <commands+0x3a0>
ffffffffc020066e:	a49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200672:	10843583          	ld	a1,264(s0)
ffffffffc0200676:	00002517          	auipc	a0,0x2
ffffffffc020067a:	46250513          	addi	a0,a0,1122 # ffffffffc0202ad8 <commands+0x3b8>
ffffffffc020067e:	a39ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200682:	11043583          	ld	a1,272(s0)
ffffffffc0200686:	00002517          	auipc	a0,0x2
ffffffffc020068a:	46a50513          	addi	a0,a0,1130 # ffffffffc0202af0 <commands+0x3d0>
ffffffffc020068e:	a29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200692:	11843583          	ld	a1,280(s0)
ffffffffc0200696:	6402                	ld	s0,0(sp)
ffffffffc0200698:	60a2                	ld	ra,8(sp)
ffffffffc020069a:	00002517          	auipc	a0,0x2
ffffffffc020069e:	46e50513          	addi	a0,a0,1134 # ffffffffc0202b08 <commands+0x3e8>
ffffffffc02006a2:	0141                	addi	sp,sp,16
ffffffffc02006a4:	bc09                	j	ffffffffc02000b6 <cprintf>

ffffffffc02006a6 <interrupt_handler>:
ffffffffc02006a6:	11853783          	ld	a5,280(a0)
ffffffffc02006aa:	472d                	li	a4,11
ffffffffc02006ac:	0786                	slli	a5,a5,0x1
ffffffffc02006ae:	8385                	srli	a5,a5,0x1
ffffffffc02006b0:	06f76c63          	bltu	a4,a5,ffffffffc0200728 <interrupt_handler+0x82>
ffffffffc02006b4:	00002717          	auipc	a4,0x2
ffffffffc02006b8:	53470713          	addi	a4,a4,1332 # ffffffffc0202be8 <commands+0x4c8>
ffffffffc02006bc:	078a                	slli	a5,a5,0x2
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	439c                	lw	a5,0(a5)
ffffffffc02006c2:	97ba                	add	a5,a5,a4
ffffffffc02006c4:	8782                	jr	a5
ffffffffc02006c6:	00002517          	auipc	a0,0x2
ffffffffc02006ca:	4ba50513          	addi	a0,a0,1210 # ffffffffc0202b80 <commands+0x460>
ffffffffc02006ce:	b2e5                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006d0:	00002517          	auipc	a0,0x2
ffffffffc02006d4:	49050513          	addi	a0,a0,1168 # ffffffffc0202b60 <commands+0x440>
ffffffffc02006d8:	baf9                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	44650513          	addi	a0,a0,1094 # ffffffffc0202b20 <commands+0x400>
ffffffffc02006e2:	bad1                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006e4:	00002517          	auipc	a0,0x2
ffffffffc02006e8:	4bc50513          	addi	a0,a0,1212 # ffffffffc0202ba0 <commands+0x480>
ffffffffc02006ec:	b2e9                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006ee:	1141                	addi	sp,sp,-16
ffffffffc02006f0:	e406                	sd	ra,8(sp)
ffffffffc02006f2:	d4dff0ef          	jal	ra,ffffffffc020043e <clock_set_next_event>
ffffffffc02006f6:	00007697          	auipc	a3,0x7
ffffffffc02006fa:	df268693          	addi	a3,a3,-526 # ffffffffc02074e8 <ticks>
ffffffffc02006fe:	629c                	ld	a5,0(a3)
ffffffffc0200700:	06400713          	li	a4,100
ffffffffc0200704:	0785                	addi	a5,a5,1
ffffffffc0200706:	02e7f733          	remu	a4,a5,a4
ffffffffc020070a:	e29c                	sd	a5,0(a3)
ffffffffc020070c:	cf19                	beqz	a4,ffffffffc020072a <interrupt_handler+0x84>
ffffffffc020070e:	60a2                	ld	ra,8(sp)
ffffffffc0200710:	0141                	addi	sp,sp,16
ffffffffc0200712:	8082                	ret
ffffffffc0200714:	00002517          	auipc	a0,0x2
ffffffffc0200718:	4b450513          	addi	a0,a0,1204 # ffffffffc0202bc8 <commands+0x4a8>
ffffffffc020071c:	ba69                	j	ffffffffc02000b6 <cprintf>
ffffffffc020071e:	00002517          	auipc	a0,0x2
ffffffffc0200722:	42250513          	addi	a0,a0,1058 # ffffffffc0202b40 <commands+0x420>
ffffffffc0200726:	ba41                	j	ffffffffc02000b6 <cprintf>
ffffffffc0200728:	bf39                	j	ffffffffc0200646 <print_trapframe>
ffffffffc020072a:	60a2                	ld	ra,8(sp)
ffffffffc020072c:	06400593          	li	a1,100
ffffffffc0200730:	00002517          	auipc	a0,0x2
ffffffffc0200734:	48850513          	addi	a0,a0,1160 # ffffffffc0202bb8 <commands+0x498>
ffffffffc0200738:	0141                	addi	sp,sp,16
ffffffffc020073a:	bab5                	j	ffffffffc02000b6 <cprintf>

ffffffffc020073c <trap>:
ffffffffc020073c:	11853783          	ld	a5,280(a0)
ffffffffc0200740:	0007c763          	bltz	a5,ffffffffc020074e <trap+0x12>
ffffffffc0200744:	472d                	li	a4,11
ffffffffc0200746:	00f76363          	bltu	a4,a5,ffffffffc020074c <trap+0x10>
ffffffffc020074a:	8082                	ret
ffffffffc020074c:	bded                	j	ffffffffc0200646 <print_trapframe>
ffffffffc020074e:	bfa1                	j	ffffffffc02006a6 <interrupt_handler>

ffffffffc0200750 <__alltraps>:
ffffffffc0200750:	14011073          	csrw	sscratch,sp
ffffffffc0200754:	712d                	addi	sp,sp,-288
ffffffffc0200756:	e002                	sd	zero,0(sp)
ffffffffc0200758:	e406                	sd	ra,8(sp)
ffffffffc020075a:	ec0e                	sd	gp,24(sp)
ffffffffc020075c:	f012                	sd	tp,32(sp)
ffffffffc020075e:	f416                	sd	t0,40(sp)
ffffffffc0200760:	f81a                	sd	t1,48(sp)
ffffffffc0200762:	fc1e                	sd	t2,56(sp)
ffffffffc0200764:	e0a2                	sd	s0,64(sp)
ffffffffc0200766:	e4a6                	sd	s1,72(sp)
ffffffffc0200768:	e8aa                	sd	a0,80(sp)
ffffffffc020076a:	ecae                	sd	a1,88(sp)
ffffffffc020076c:	f0b2                	sd	a2,96(sp)
ffffffffc020076e:	f4b6                	sd	a3,104(sp)
ffffffffc0200770:	f8ba                	sd	a4,112(sp)
ffffffffc0200772:	fcbe                	sd	a5,120(sp)
ffffffffc0200774:	e142                	sd	a6,128(sp)
ffffffffc0200776:	e546                	sd	a7,136(sp)
ffffffffc0200778:	e94a                	sd	s2,144(sp)
ffffffffc020077a:	ed4e                	sd	s3,152(sp)
ffffffffc020077c:	f152                	sd	s4,160(sp)
ffffffffc020077e:	f556                	sd	s5,168(sp)
ffffffffc0200780:	f95a                	sd	s6,176(sp)
ffffffffc0200782:	fd5e                	sd	s7,184(sp)
ffffffffc0200784:	e1e2                	sd	s8,192(sp)
ffffffffc0200786:	e5e6                	sd	s9,200(sp)
ffffffffc0200788:	e9ea                	sd	s10,208(sp)
ffffffffc020078a:	edee                	sd	s11,216(sp)
ffffffffc020078c:	f1f2                	sd	t3,224(sp)
ffffffffc020078e:	f5f6                	sd	t4,232(sp)
ffffffffc0200790:	f9fa                	sd	t5,240(sp)
ffffffffc0200792:	fdfe                	sd	t6,248(sp)
ffffffffc0200794:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200798:	100024f3          	csrr	s1,sstatus
ffffffffc020079c:	14102973          	csrr	s2,sepc
ffffffffc02007a0:	143029f3          	csrr	s3,stval
ffffffffc02007a4:	14202a73          	csrr	s4,scause
ffffffffc02007a8:	e822                	sd	s0,16(sp)
ffffffffc02007aa:	e226                	sd	s1,256(sp)
ffffffffc02007ac:	e64a                	sd	s2,264(sp)
ffffffffc02007ae:	ea4e                	sd	s3,272(sp)
ffffffffc02007b0:	ee52                	sd	s4,280(sp)
ffffffffc02007b2:	850a                	mv	a0,sp
ffffffffc02007b4:	f89ff0ef          	jal	ra,ffffffffc020073c <trap>

ffffffffc02007b8 <__trapret>:
ffffffffc02007b8:	6492                	ld	s1,256(sp)
ffffffffc02007ba:	6932                	ld	s2,264(sp)
ffffffffc02007bc:	10049073          	csrw	sstatus,s1
ffffffffc02007c0:	14191073          	csrw	sepc,s2
ffffffffc02007c4:	60a2                	ld	ra,8(sp)
ffffffffc02007c6:	61e2                	ld	gp,24(sp)
ffffffffc02007c8:	7202                	ld	tp,32(sp)
ffffffffc02007ca:	72a2                	ld	t0,40(sp)
ffffffffc02007cc:	7342                	ld	t1,48(sp)
ffffffffc02007ce:	73e2                	ld	t2,56(sp)
ffffffffc02007d0:	6406                	ld	s0,64(sp)
ffffffffc02007d2:	64a6                	ld	s1,72(sp)
ffffffffc02007d4:	6546                	ld	a0,80(sp)
ffffffffc02007d6:	65e6                	ld	a1,88(sp)
ffffffffc02007d8:	7606                	ld	a2,96(sp)
ffffffffc02007da:	76a6                	ld	a3,104(sp)
ffffffffc02007dc:	7746                	ld	a4,112(sp)
ffffffffc02007de:	77e6                	ld	a5,120(sp)
ffffffffc02007e0:	680a                	ld	a6,128(sp)
ffffffffc02007e2:	68aa                	ld	a7,136(sp)
ffffffffc02007e4:	694a                	ld	s2,144(sp)
ffffffffc02007e6:	69ea                	ld	s3,152(sp)
ffffffffc02007e8:	7a0a                	ld	s4,160(sp)
ffffffffc02007ea:	7aaa                	ld	s5,168(sp)
ffffffffc02007ec:	7b4a                	ld	s6,176(sp)
ffffffffc02007ee:	7bea                	ld	s7,184(sp)
ffffffffc02007f0:	6c0e                	ld	s8,192(sp)
ffffffffc02007f2:	6cae                	ld	s9,200(sp)
ffffffffc02007f4:	6d4e                	ld	s10,208(sp)
ffffffffc02007f6:	6dee                	ld	s11,216(sp)
ffffffffc02007f8:	7e0e                	ld	t3,224(sp)
ffffffffc02007fa:	7eae                	ld	t4,232(sp)
ffffffffc02007fc:	7f4e                	ld	t5,240(sp)
ffffffffc02007fe:	7fee                	ld	t6,248(sp)
ffffffffc0200800:	6142                	ld	sp,16(sp)
ffffffffc0200802:	10200073          	sret

ffffffffc0200806 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200806:	00007797          	auipc	a5,0x7
ffffffffc020080a:	80a78793          	addi	a5,a5,-2038 # ffffffffc0207010 <free_area>
ffffffffc020080e:	e79c                	sd	a5,8(a5)
ffffffffc0200810:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200812:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200816:	8082                	ret

ffffffffc0200818 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200818:	00007517          	auipc	a0,0x7
ffffffffc020081c:	80856503          	lwu	a0,-2040(a0) # ffffffffc0207020 <free_area+0x10>
ffffffffc0200820:	8082                	ret

ffffffffc0200822 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200822:	c14d                	beqz	a0,ffffffffc02008c4 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200824:	00006617          	auipc	a2,0x6
ffffffffc0200828:	7ec60613          	addi	a2,a2,2028 # ffffffffc0207010 <free_area>
ffffffffc020082c:	01062803          	lw	a6,16(a2)
ffffffffc0200830:	86aa                	mv	a3,a0
ffffffffc0200832:	02081793          	slli	a5,a6,0x20
ffffffffc0200836:	9381                	srli	a5,a5,0x20
ffffffffc0200838:	08a7e463          	bltu	a5,a0,ffffffffc02008c0 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020083c:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc020083e:	0018059b          	addiw	a1,a6,1
ffffffffc0200842:	1582                	slli	a1,a1,0x20
ffffffffc0200844:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200846:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200848:	06c78b63          	beq	a5,a2,ffffffffc02008be <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) {
ffffffffc020084c:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200850:	00d76763          	bltu	a4,a3,ffffffffc020085e <best_fit_alloc_pages+0x3c>
ffffffffc0200854:	00b77563          	bgeu	a4,a1,ffffffffc020085e <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200858:	fe878513          	addi	a0,a5,-24
ffffffffc020085c:	85ba                	mv	a1,a4
ffffffffc020085e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200860:	fec796e3          	bne	a5,a2,ffffffffc020084c <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200864:	cd29                	beqz	a0,ffffffffc02008be <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200866:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200868:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc020086a:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc020086c:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200870:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200872:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200874:	02059793          	slli	a5,a1,0x20
ffffffffc0200878:	9381                	srli	a5,a5,0x20
ffffffffc020087a:	02f6f863          	bgeu	a3,a5,ffffffffc02008aa <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc020087e:	00269793          	slli	a5,a3,0x2
ffffffffc0200882:	97b6                	add	a5,a5,a3
ffffffffc0200884:	078e                	slli	a5,a5,0x3
ffffffffc0200886:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200888:	411585bb          	subw	a1,a1,a7
ffffffffc020088c:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088e:	4689                	li	a3,2
ffffffffc0200890:	00878593          	addi	a1,a5,8
ffffffffc0200894:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200898:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc020089a:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc020089e:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc02008a2:	e28c                	sd	a1,0(a3)
ffffffffc02008a4:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008a6:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008a8:	ef98                	sd	a4,24(a5)
ffffffffc02008aa:	4118083b          	subw	a6,a6,a7
ffffffffc02008ae:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008b2:	57f5                	li	a5,-3
ffffffffc02008b4:	00850713          	addi	a4,a0,8
ffffffffc02008b8:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008bc:	8082                	ret
}
ffffffffc02008be:	8082                	ret
        return NULL;
ffffffffc02008c0:	4501                	li	a0,0
ffffffffc02008c2:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008c4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008c6:	00002697          	auipc	a3,0x2
ffffffffc02008ca:	35268693          	addi	a3,a3,850 # ffffffffc0202c18 <commands+0x4f8>
ffffffffc02008ce:	00002617          	auipc	a2,0x2
ffffffffc02008d2:	35260613          	addi	a2,a2,850 # ffffffffc0202c20 <commands+0x500>
ffffffffc02008d6:	06e00593          	li	a1,110
ffffffffc02008da:	00002517          	auipc	a0,0x2
ffffffffc02008de:	35e50513          	addi	a0,a0,862 # ffffffffc0202c38 <commands+0x518>
best_fit_alloc_pages(size_t n) {
ffffffffc02008e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008e4:	acdff0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc02008e8 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02008e8:	715d                	addi	sp,sp,-80
ffffffffc02008ea:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02008ec:	00006417          	auipc	s0,0x6
ffffffffc02008f0:	72440413          	addi	s0,s0,1828 # ffffffffc0207010 <free_area>
ffffffffc02008f4:	641c                	ld	a5,8(s0)
ffffffffc02008f6:	e486                	sd	ra,72(sp)
ffffffffc02008f8:	fc26                	sd	s1,56(sp)
ffffffffc02008fa:	f84a                	sd	s2,48(sp)
ffffffffc02008fc:	f44e                	sd	s3,40(sp)
ffffffffc02008fe:	f052                	sd	s4,32(sp)
ffffffffc0200900:	ec56                	sd	s5,24(sp)
ffffffffc0200902:	e85a                	sd	s6,16(sp)
ffffffffc0200904:	e45e                	sd	s7,8(sp)
ffffffffc0200906:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200908:	26878b63          	beq	a5,s0,ffffffffc0200b7e <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc020090c:	4481                	li	s1,0
ffffffffc020090e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200910:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200914:	8b09                	andi	a4,a4,2
ffffffffc0200916:	26070863          	beqz	a4,ffffffffc0200b86 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc020091a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020091e:	679c                	ld	a5,8(a5)
ffffffffc0200920:	2905                	addiw	s2,s2,1
ffffffffc0200922:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200924:	fe8796e3          	bne	a5,s0,ffffffffc0200910 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200928:	89a6                	mv	s3,s1
ffffffffc020092a:	167000ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc020092e:	33351c63          	bne	a0,s3,ffffffffc0200c66 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200932:	4505                	li	a0,1
ffffffffc0200934:	0df000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200938:	8a2a                	mv	s4,a0
ffffffffc020093a:	36050663          	beqz	a0,ffffffffc0200ca6 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020093e:	4505                	li	a0,1
ffffffffc0200940:	0d3000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200944:	89aa                	mv	s3,a0
ffffffffc0200946:	34050063          	beqz	a0,ffffffffc0200c86 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020094a:	4505                	li	a0,1
ffffffffc020094c:	0c7000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200950:	8aaa                	mv	s5,a0
ffffffffc0200952:	2c050a63          	beqz	a0,ffffffffc0200c26 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200956:	253a0863          	beq	s4,s3,ffffffffc0200ba6 <best_fit_check+0x2be>
ffffffffc020095a:	24aa0663          	beq	s4,a0,ffffffffc0200ba6 <best_fit_check+0x2be>
ffffffffc020095e:	24a98463          	beq	s3,a0,ffffffffc0200ba6 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200962:	000a2783          	lw	a5,0(s4)
ffffffffc0200966:	26079063          	bnez	a5,ffffffffc0200bc6 <best_fit_check+0x2de>
ffffffffc020096a:	0009a783          	lw	a5,0(s3)
ffffffffc020096e:	24079c63          	bnez	a5,ffffffffc0200bc6 <best_fit_check+0x2de>
ffffffffc0200972:	411c                	lw	a5,0(a0)
ffffffffc0200974:	24079963          	bnez	a5,ffffffffc0200bc6 <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200978:	00007797          	auipc	a5,0x7
ffffffffc020097c:	b807b783          	ld	a5,-1152(a5) # ffffffffc02074f8 <pages>
ffffffffc0200980:	40fa0733          	sub	a4,s4,a5
ffffffffc0200984:	870d                	srai	a4,a4,0x3
ffffffffc0200986:	00003597          	auipc	a1,0x3
ffffffffc020098a:	d425b583          	ld	a1,-702(a1) # ffffffffc02036c8 <error_string+0x38>
ffffffffc020098e:	02b70733          	mul	a4,a4,a1
ffffffffc0200992:	00003617          	auipc	a2,0x3
ffffffffc0200996:	d3e63603          	ld	a2,-706(a2) # ffffffffc02036d0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020099a:	00007697          	auipc	a3,0x7
ffffffffc020099e:	b566b683          	ld	a3,-1194(a3) # ffffffffc02074f0 <npage>
ffffffffc02009a2:	06b2                	slli	a3,a3,0xc
ffffffffc02009a4:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009a6:	0732                	slli	a4,a4,0xc
ffffffffc02009a8:	22d77f63          	bgeu	a4,a3,ffffffffc0200be6 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ac:	40f98733          	sub	a4,s3,a5
ffffffffc02009b0:	870d                	srai	a4,a4,0x3
ffffffffc02009b2:	02b70733          	mul	a4,a4,a1
ffffffffc02009b6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009b8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009ba:	3ed77663          	bgeu	a4,a3,ffffffffc0200da6 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009be:	40f507b3          	sub	a5,a0,a5
ffffffffc02009c2:	878d                	srai	a5,a5,0x3
ffffffffc02009c4:	02b787b3          	mul	a5,a5,a1
ffffffffc02009c8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ca:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009cc:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200d86 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc02009d0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009d2:	00043c03          	ld	s8,0(s0)
ffffffffc02009d6:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02009da:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02009de:	e400                	sd	s0,8(s0)
ffffffffc02009e0:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02009e2:	00006797          	auipc	a5,0x6
ffffffffc02009e6:	6207af23          	sw	zero,1598(a5) # ffffffffc0207020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009ea:	029000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc02009ee:	36051c63          	bnez	a0,ffffffffc0200d66 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc02009f2:	4585                	li	a1,1
ffffffffc02009f4:	8552                	mv	a0,s4
ffffffffc02009f6:	05b000ef          	jal	ra,ffffffffc0201250 <free_pages>
    free_page(p1);
ffffffffc02009fa:	4585                	li	a1,1
ffffffffc02009fc:	854e                	mv	a0,s3
ffffffffc02009fe:	053000ef          	jal	ra,ffffffffc0201250 <free_pages>
    free_page(p2);
ffffffffc0200a02:	4585                	li	a1,1
ffffffffc0200a04:	8556                	mv	a0,s5
ffffffffc0200a06:	04b000ef          	jal	ra,ffffffffc0201250 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a0a:	4818                	lw	a4,16(s0)
ffffffffc0200a0c:	478d                	li	a5,3
ffffffffc0200a0e:	32f71c63          	bne	a4,a5,ffffffffc0200d46 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a12:	4505                	li	a0,1
ffffffffc0200a14:	7fe000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a18:	89aa                	mv	s3,a0
ffffffffc0200a1a:	30050663          	beqz	a0,ffffffffc0200d26 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a1e:	4505                	li	a0,1
ffffffffc0200a20:	7f2000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a24:	8aaa                	mv	s5,a0
ffffffffc0200a26:	2e050063          	beqz	a0,ffffffffc0200d06 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a2a:	4505                	li	a0,1
ffffffffc0200a2c:	7e6000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a30:	8a2a                	mv	s4,a0
ffffffffc0200a32:	2a050a63          	beqz	a0,ffffffffc0200ce6 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200a36:	4505                	li	a0,1
ffffffffc0200a38:	7da000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a3c:	28051563          	bnez	a0,ffffffffc0200cc6 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200a40:	4585                	li	a1,1
ffffffffc0200a42:	854e                	mv	a0,s3
ffffffffc0200a44:	00d000ef          	jal	ra,ffffffffc0201250 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a48:	641c                	ld	a5,8(s0)
ffffffffc0200a4a:	1a878e63          	beq	a5,s0,ffffffffc0200c06 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200a4e:	4505                	li	a0,1
ffffffffc0200a50:	7c2000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a54:	52a99963          	bne	s3,a0,ffffffffc0200f86 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200a58:	4505                	li	a0,1
ffffffffc0200a5a:	7b8000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a5e:	50051463          	bnez	a0,ffffffffc0200f66 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200a62:	481c                	lw	a5,16(s0)
ffffffffc0200a64:	4e079163          	bnez	a5,ffffffffc0200f46 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200a68:	854e                	mv	a0,s3
ffffffffc0200a6a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a6c:	01843023          	sd	s8,0(s0)
ffffffffc0200a70:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200a74:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200a78:	7d8000ef          	jal	ra,ffffffffc0201250 <free_pages>
    free_page(p1);
ffffffffc0200a7c:	4585                	li	a1,1
ffffffffc0200a7e:	8556                	mv	a0,s5
ffffffffc0200a80:	7d0000ef          	jal	ra,ffffffffc0201250 <free_pages>
    free_page(p2);
ffffffffc0200a84:	4585                	li	a1,1
ffffffffc0200a86:	8552                	mv	a0,s4
ffffffffc0200a88:	7c8000ef          	jal	ra,ffffffffc0201250 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a8c:	4515                	li	a0,5
ffffffffc0200a8e:	784000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200a92:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a94:	48050963          	beqz	a0,ffffffffc0200f26 <best_fit_check+0x63e>
ffffffffc0200a98:	651c                	ld	a5,8(a0)
ffffffffc0200a9a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a9c:	8b85                	andi	a5,a5,1
ffffffffc0200a9e:	46079463          	bnez	a5,ffffffffc0200f06 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200aa2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200aa4:	00043a83          	ld	s5,0(s0)
ffffffffc0200aa8:	00843a03          	ld	s4,8(s0)
ffffffffc0200aac:	e000                	sd	s0,0(s0)
ffffffffc0200aae:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200ab0:	762000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200ab4:	42051963          	bnez	a0,ffffffffc0200ee6 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200ab8:	4589                	li	a1,2
ffffffffc0200aba:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200abe:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200ac2:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200ac6:	00006797          	auipc	a5,0x6
ffffffffc0200aca:	5407ad23          	sw	zero,1370(a5) # ffffffffc0207020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200ace:	782000ef          	jal	ra,ffffffffc0201250 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200ad2:	8562                	mv	a0,s8
ffffffffc0200ad4:	4585                	li	a1,1
ffffffffc0200ad6:	77a000ef          	jal	ra,ffffffffc0201250 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ada:	4511                	li	a0,4
ffffffffc0200adc:	736000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200ae0:	3e051363          	bnez	a0,ffffffffc0200ec6 <best_fit_check+0x5de>
ffffffffc0200ae4:	0309b783          	ld	a5,48(s3)
ffffffffc0200ae8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200aea:	8b85                	andi	a5,a5,1
ffffffffc0200aec:	3a078d63          	beqz	a5,ffffffffc0200ea6 <best_fit_check+0x5be>
ffffffffc0200af0:	0389a703          	lw	a4,56(s3)
ffffffffc0200af4:	4789                	li	a5,2
ffffffffc0200af6:	3af71863          	bne	a4,a5,ffffffffc0200ea6 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200afa:	4505                	li	a0,1
ffffffffc0200afc:	716000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200b00:	8baa                	mv	s7,a0
ffffffffc0200b02:	38050263          	beqz	a0,ffffffffc0200e86 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b06:	4509                	li	a0,2
ffffffffc0200b08:	70a000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200b0c:	34050d63          	beqz	a0,ffffffffc0200e66 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200b10:	337c1b63          	bne	s8,s7,ffffffffc0200e46 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b14:	854e                	mv	a0,s3
ffffffffc0200b16:	4595                	li	a1,5
ffffffffc0200b18:	738000ef          	jal	ra,ffffffffc0201250 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b1c:	4515                	li	a0,5
ffffffffc0200b1e:	6f4000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200b22:	89aa                	mv	s3,a0
ffffffffc0200b24:	30050163          	beqz	a0,ffffffffc0200e26 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200b28:	4505                	li	a0,1
ffffffffc0200b2a:	6e8000ef          	jal	ra,ffffffffc0201212 <alloc_pages>
ffffffffc0200b2e:	2c051c63          	bnez	a0,ffffffffc0200e06 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b32:	481c                	lw	a5,16(s0)
ffffffffc0200b34:	2a079963          	bnez	a5,ffffffffc0200de6 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b38:	4595                	li	a1,5
ffffffffc0200b3a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b3c:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b40:	01543023          	sd	s5,0(s0)
ffffffffc0200b44:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b48:	708000ef          	jal	ra,ffffffffc0201250 <free_pages>
    return listelm->next;
ffffffffc0200b4c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4e:	00878963          	beq	a5,s0,ffffffffc0200b60 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b52:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b56:	679c                	ld	a5,8(a5)
ffffffffc0200b58:	397d                	addiw	s2,s2,-1
ffffffffc0200b5a:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b5c:	fe879be3          	bne	a5,s0,ffffffffc0200b52 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200b60:	26091363          	bnez	s2,ffffffffc0200dc6 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200b64:	e0ed                	bnez	s1,ffffffffc0200c46 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b66:	60a6                	ld	ra,72(sp)
ffffffffc0200b68:	6406                	ld	s0,64(sp)
ffffffffc0200b6a:	74e2                	ld	s1,56(sp)
ffffffffc0200b6c:	7942                	ld	s2,48(sp)
ffffffffc0200b6e:	79a2                	ld	s3,40(sp)
ffffffffc0200b70:	7a02                	ld	s4,32(sp)
ffffffffc0200b72:	6ae2                	ld	s5,24(sp)
ffffffffc0200b74:	6b42                	ld	s6,16(sp)
ffffffffc0200b76:	6ba2                	ld	s7,8(sp)
ffffffffc0200b78:	6c02                	ld	s8,0(sp)
ffffffffc0200b7a:	6161                	addi	sp,sp,80
ffffffffc0200b7c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b7e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b80:	4481                	li	s1,0
ffffffffc0200b82:	4901                	li	s2,0
ffffffffc0200b84:	b35d                	j	ffffffffc020092a <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b86:	00002697          	auipc	a3,0x2
ffffffffc0200b8a:	0ca68693          	addi	a3,a3,202 # ffffffffc0202c50 <commands+0x530>
ffffffffc0200b8e:	00002617          	auipc	a2,0x2
ffffffffc0200b92:	09260613          	addi	a2,a2,146 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200b96:	10d00593          	li	a1,269
ffffffffc0200b9a:	00002517          	auipc	a0,0x2
ffffffffc0200b9e:	09e50513          	addi	a0,a0,158 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200ba2:	80fff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ba6:	00002697          	auipc	a3,0x2
ffffffffc0200baa:	13a68693          	addi	a3,a3,314 # ffffffffc0202ce0 <commands+0x5c0>
ffffffffc0200bae:	00002617          	auipc	a2,0x2
ffffffffc0200bb2:	07260613          	addi	a2,a2,114 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200bb6:	0d900593          	li	a1,217
ffffffffc0200bba:	00002517          	auipc	a0,0x2
ffffffffc0200bbe:	07e50513          	addi	a0,a0,126 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200bc2:	feeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bc6:	00002697          	auipc	a3,0x2
ffffffffc0200bca:	14268693          	addi	a3,a3,322 # ffffffffc0202d08 <commands+0x5e8>
ffffffffc0200bce:	00002617          	auipc	a2,0x2
ffffffffc0200bd2:	05260613          	addi	a2,a2,82 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200bd6:	0da00593          	li	a1,218
ffffffffc0200bda:	00002517          	auipc	a0,0x2
ffffffffc0200bde:	05e50513          	addi	a0,a0,94 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200be2:	fceff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200be6:	00002697          	auipc	a3,0x2
ffffffffc0200bea:	16268693          	addi	a3,a3,354 # ffffffffc0202d48 <commands+0x628>
ffffffffc0200bee:	00002617          	auipc	a2,0x2
ffffffffc0200bf2:	03260613          	addi	a2,a2,50 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200bf6:	0dc00593          	li	a1,220
ffffffffc0200bfa:	00002517          	auipc	a0,0x2
ffffffffc0200bfe:	03e50513          	addi	a0,a0,62 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200c02:	faeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c06:	00002697          	auipc	a3,0x2
ffffffffc0200c0a:	1ca68693          	addi	a3,a3,458 # ffffffffc0202dd0 <commands+0x6b0>
ffffffffc0200c0e:	00002617          	auipc	a2,0x2
ffffffffc0200c12:	01260613          	addi	a2,a2,18 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200c16:	0f500593          	li	a1,245
ffffffffc0200c1a:	00002517          	auipc	a0,0x2
ffffffffc0200c1e:	01e50513          	addi	a0,a0,30 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200c22:	f8eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c26:	00002697          	auipc	a3,0x2
ffffffffc0200c2a:	09a68693          	addi	a3,a3,154 # ffffffffc0202cc0 <commands+0x5a0>
ffffffffc0200c2e:	00002617          	auipc	a2,0x2
ffffffffc0200c32:	ff260613          	addi	a2,a2,-14 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200c36:	0d700593          	li	a1,215
ffffffffc0200c3a:	00002517          	auipc	a0,0x2
ffffffffc0200c3e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200c42:	f6eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(total == 0);
ffffffffc0200c46:	00002697          	auipc	a3,0x2
ffffffffc0200c4a:	2ba68693          	addi	a3,a3,698 # ffffffffc0202f00 <commands+0x7e0>
ffffffffc0200c4e:	00002617          	auipc	a2,0x2
ffffffffc0200c52:	fd260613          	addi	a2,a2,-46 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200c56:	14f00593          	li	a1,335
ffffffffc0200c5a:	00002517          	auipc	a0,0x2
ffffffffc0200c5e:	fde50513          	addi	a0,a0,-34 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200c62:	f4eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c66:	00002697          	auipc	a3,0x2
ffffffffc0200c6a:	ffa68693          	addi	a3,a3,-6 # ffffffffc0202c60 <commands+0x540>
ffffffffc0200c6e:	00002617          	auipc	a2,0x2
ffffffffc0200c72:	fb260613          	addi	a2,a2,-78 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200c76:	11000593          	li	a1,272
ffffffffc0200c7a:	00002517          	auipc	a0,0x2
ffffffffc0200c7e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200c82:	f2eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c86:	00002697          	auipc	a3,0x2
ffffffffc0200c8a:	01a68693          	addi	a3,a3,26 # ffffffffc0202ca0 <commands+0x580>
ffffffffc0200c8e:	00002617          	auipc	a2,0x2
ffffffffc0200c92:	f9260613          	addi	a2,a2,-110 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200c96:	0d600593          	li	a1,214
ffffffffc0200c9a:	00002517          	auipc	a0,0x2
ffffffffc0200c9e:	f9e50513          	addi	a0,a0,-98 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200ca2:	f0eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ca6:	00002697          	auipc	a3,0x2
ffffffffc0200caa:	fda68693          	addi	a3,a3,-38 # ffffffffc0202c80 <commands+0x560>
ffffffffc0200cae:	00002617          	auipc	a2,0x2
ffffffffc0200cb2:	f7260613          	addi	a2,a2,-142 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200cb6:	0d500593          	li	a1,213
ffffffffc0200cba:	00002517          	auipc	a0,0x2
ffffffffc0200cbe:	f7e50513          	addi	a0,a0,-130 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200cc2:	eeeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cc6:	00002697          	auipc	a3,0x2
ffffffffc0200cca:	0e268693          	addi	a3,a3,226 # ffffffffc0202da8 <commands+0x688>
ffffffffc0200cce:	00002617          	auipc	a2,0x2
ffffffffc0200cd2:	f5260613          	addi	a2,a2,-174 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200cd6:	0f200593          	li	a1,242
ffffffffc0200cda:	00002517          	auipc	a0,0x2
ffffffffc0200cde:	f5e50513          	addi	a0,a0,-162 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200ce2:	eceff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ce6:	00002697          	auipc	a3,0x2
ffffffffc0200cea:	fda68693          	addi	a3,a3,-38 # ffffffffc0202cc0 <commands+0x5a0>
ffffffffc0200cee:	00002617          	auipc	a2,0x2
ffffffffc0200cf2:	f3260613          	addi	a2,a2,-206 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200cf6:	0f000593          	li	a1,240
ffffffffc0200cfa:	00002517          	auipc	a0,0x2
ffffffffc0200cfe:	f3e50513          	addi	a0,a0,-194 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200d02:	eaeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d06:	00002697          	auipc	a3,0x2
ffffffffc0200d0a:	f9a68693          	addi	a3,a3,-102 # ffffffffc0202ca0 <commands+0x580>
ffffffffc0200d0e:	00002617          	auipc	a2,0x2
ffffffffc0200d12:	f1260613          	addi	a2,a2,-238 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200d16:	0ef00593          	li	a1,239
ffffffffc0200d1a:	00002517          	auipc	a0,0x2
ffffffffc0200d1e:	f1e50513          	addi	a0,a0,-226 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200d22:	e8eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d26:	00002697          	auipc	a3,0x2
ffffffffc0200d2a:	f5a68693          	addi	a3,a3,-166 # ffffffffc0202c80 <commands+0x560>
ffffffffc0200d2e:	00002617          	auipc	a2,0x2
ffffffffc0200d32:	ef260613          	addi	a2,a2,-270 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200d36:	0ee00593          	li	a1,238
ffffffffc0200d3a:	00002517          	auipc	a0,0x2
ffffffffc0200d3e:	efe50513          	addi	a0,a0,-258 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200d42:	e6eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free == 3);
ffffffffc0200d46:	00002697          	auipc	a3,0x2
ffffffffc0200d4a:	07a68693          	addi	a3,a3,122 # ffffffffc0202dc0 <commands+0x6a0>
ffffffffc0200d4e:	00002617          	auipc	a2,0x2
ffffffffc0200d52:	ed260613          	addi	a2,a2,-302 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200d56:	0ec00593          	li	a1,236
ffffffffc0200d5a:	00002517          	auipc	a0,0x2
ffffffffc0200d5e:	ede50513          	addi	a0,a0,-290 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200d62:	e4eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d66:	00002697          	auipc	a3,0x2
ffffffffc0200d6a:	04268693          	addi	a3,a3,66 # ffffffffc0202da8 <commands+0x688>
ffffffffc0200d6e:	00002617          	auipc	a2,0x2
ffffffffc0200d72:	eb260613          	addi	a2,a2,-334 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200d76:	0e700593          	li	a1,231
ffffffffc0200d7a:	00002517          	auipc	a0,0x2
ffffffffc0200d7e:	ebe50513          	addi	a0,a0,-322 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200d82:	e2eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d86:	00002697          	auipc	a3,0x2
ffffffffc0200d8a:	00268693          	addi	a3,a3,2 # ffffffffc0202d88 <commands+0x668>
ffffffffc0200d8e:	00002617          	auipc	a2,0x2
ffffffffc0200d92:	e9260613          	addi	a2,a2,-366 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200d96:	0de00593          	li	a1,222
ffffffffc0200d9a:	00002517          	auipc	a0,0x2
ffffffffc0200d9e:	e9e50513          	addi	a0,a0,-354 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200da2:	e0eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200da6:	00002697          	auipc	a3,0x2
ffffffffc0200daa:	fc268693          	addi	a3,a3,-62 # ffffffffc0202d68 <commands+0x648>
ffffffffc0200dae:	00002617          	auipc	a2,0x2
ffffffffc0200db2:	e7260613          	addi	a2,a2,-398 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200db6:	0dd00593          	li	a1,221
ffffffffc0200dba:	00002517          	auipc	a0,0x2
ffffffffc0200dbe:	e7e50513          	addi	a0,a0,-386 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200dc2:	deeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(count == 0);
ffffffffc0200dc6:	00002697          	auipc	a3,0x2
ffffffffc0200dca:	12a68693          	addi	a3,a3,298 # ffffffffc0202ef0 <commands+0x7d0>
ffffffffc0200dce:	00002617          	auipc	a2,0x2
ffffffffc0200dd2:	e5260613          	addi	a2,a2,-430 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200dd6:	14e00593          	li	a1,334
ffffffffc0200dda:	00002517          	auipc	a0,0x2
ffffffffc0200dde:	e5e50513          	addi	a0,a0,-418 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200de2:	dceff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free == 0);
ffffffffc0200de6:	00002697          	auipc	a3,0x2
ffffffffc0200dea:	02268693          	addi	a3,a3,34 # ffffffffc0202e08 <commands+0x6e8>
ffffffffc0200dee:	00002617          	auipc	a2,0x2
ffffffffc0200df2:	e3260613          	addi	a2,a2,-462 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200df6:	14300593          	li	a1,323
ffffffffc0200dfa:	00002517          	auipc	a0,0x2
ffffffffc0200dfe:	e3e50513          	addi	a0,a0,-450 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200e02:	daeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e06:	00002697          	auipc	a3,0x2
ffffffffc0200e0a:	fa268693          	addi	a3,a3,-94 # ffffffffc0202da8 <commands+0x688>
ffffffffc0200e0e:	00002617          	auipc	a2,0x2
ffffffffc0200e12:	e1260613          	addi	a2,a2,-494 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200e16:	13d00593          	li	a1,317
ffffffffc0200e1a:	00002517          	auipc	a0,0x2
ffffffffc0200e1e:	e1e50513          	addi	a0,a0,-482 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200e22:	d8eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e26:	00002697          	auipc	a3,0x2
ffffffffc0200e2a:	0aa68693          	addi	a3,a3,170 # ffffffffc0202ed0 <commands+0x7b0>
ffffffffc0200e2e:	00002617          	auipc	a2,0x2
ffffffffc0200e32:	df260613          	addi	a2,a2,-526 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200e36:	13c00593          	li	a1,316
ffffffffc0200e3a:	00002517          	auipc	a0,0x2
ffffffffc0200e3e:	dfe50513          	addi	a0,a0,-514 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200e42:	d6eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e46:	00002697          	auipc	a3,0x2
ffffffffc0200e4a:	07a68693          	addi	a3,a3,122 # ffffffffc0202ec0 <commands+0x7a0>
ffffffffc0200e4e:	00002617          	auipc	a2,0x2
ffffffffc0200e52:	dd260613          	addi	a2,a2,-558 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200e56:	13400593          	li	a1,308
ffffffffc0200e5a:	00002517          	auipc	a0,0x2
ffffffffc0200e5e:	dde50513          	addi	a0,a0,-546 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200e62:	d4eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e66:	00002697          	auipc	a3,0x2
ffffffffc0200e6a:	04268693          	addi	a3,a3,66 # ffffffffc0202ea8 <commands+0x788>
ffffffffc0200e6e:	00002617          	auipc	a2,0x2
ffffffffc0200e72:	db260613          	addi	a2,a2,-590 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200e76:	13300593          	li	a1,307
ffffffffc0200e7a:	00002517          	auipc	a0,0x2
ffffffffc0200e7e:	dbe50513          	addi	a0,a0,-578 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200e82:	d2eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e86:	00002697          	auipc	a3,0x2
ffffffffc0200e8a:	00268693          	addi	a3,a3,2 # ffffffffc0202e88 <commands+0x768>
ffffffffc0200e8e:	00002617          	auipc	a2,0x2
ffffffffc0200e92:	d9260613          	addi	a2,a2,-622 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200e96:	13200593          	li	a1,306
ffffffffc0200e9a:	00002517          	auipc	a0,0x2
ffffffffc0200e9e:	d9e50513          	addi	a0,a0,-610 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200ea2:	d0eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ea6:	00002697          	auipc	a3,0x2
ffffffffc0200eaa:	fb268693          	addi	a3,a3,-78 # ffffffffc0202e58 <commands+0x738>
ffffffffc0200eae:	00002617          	auipc	a2,0x2
ffffffffc0200eb2:	d7260613          	addi	a2,a2,-654 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200eb6:	13000593          	li	a1,304
ffffffffc0200eba:	00002517          	auipc	a0,0x2
ffffffffc0200ebe:	d7e50513          	addi	a0,a0,-642 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200ec2:	ceeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ec6:	00002697          	auipc	a3,0x2
ffffffffc0200eca:	f7a68693          	addi	a3,a3,-134 # ffffffffc0202e40 <commands+0x720>
ffffffffc0200ece:	00002617          	auipc	a2,0x2
ffffffffc0200ed2:	d5260613          	addi	a2,a2,-686 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200ed6:	12f00593          	li	a1,303
ffffffffc0200eda:	00002517          	auipc	a0,0x2
ffffffffc0200ede:	d5e50513          	addi	a0,a0,-674 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200ee2:	cceff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ee6:	00002697          	auipc	a3,0x2
ffffffffc0200eea:	ec268693          	addi	a3,a3,-318 # ffffffffc0202da8 <commands+0x688>
ffffffffc0200eee:	00002617          	auipc	a2,0x2
ffffffffc0200ef2:	d3260613          	addi	a2,a2,-718 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200ef6:	12300593          	li	a1,291
ffffffffc0200efa:	00002517          	auipc	a0,0x2
ffffffffc0200efe:	d3e50513          	addi	a0,a0,-706 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200f02:	caeff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f06:	00002697          	auipc	a3,0x2
ffffffffc0200f0a:	f2268693          	addi	a3,a3,-222 # ffffffffc0202e28 <commands+0x708>
ffffffffc0200f0e:	00002617          	auipc	a2,0x2
ffffffffc0200f12:	d1260613          	addi	a2,a2,-750 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200f16:	11a00593          	li	a1,282
ffffffffc0200f1a:	00002517          	auipc	a0,0x2
ffffffffc0200f1e:	d1e50513          	addi	a0,a0,-738 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200f22:	c8eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(p0 != NULL);
ffffffffc0200f26:	00002697          	auipc	a3,0x2
ffffffffc0200f2a:	ef268693          	addi	a3,a3,-270 # ffffffffc0202e18 <commands+0x6f8>
ffffffffc0200f2e:	00002617          	auipc	a2,0x2
ffffffffc0200f32:	cf260613          	addi	a2,a2,-782 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200f36:	11900593          	li	a1,281
ffffffffc0200f3a:	00002517          	auipc	a0,0x2
ffffffffc0200f3e:	cfe50513          	addi	a0,a0,-770 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200f42:	c6eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free == 0);
ffffffffc0200f46:	00002697          	auipc	a3,0x2
ffffffffc0200f4a:	ec268693          	addi	a3,a3,-318 # ffffffffc0202e08 <commands+0x6e8>
ffffffffc0200f4e:	00002617          	auipc	a2,0x2
ffffffffc0200f52:	cd260613          	addi	a2,a2,-814 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200f56:	0fb00593          	li	a1,251
ffffffffc0200f5a:	00002517          	auipc	a0,0x2
ffffffffc0200f5e:	cde50513          	addi	a0,a0,-802 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200f62:	c4eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f66:	00002697          	auipc	a3,0x2
ffffffffc0200f6a:	e4268693          	addi	a3,a3,-446 # ffffffffc0202da8 <commands+0x688>
ffffffffc0200f6e:	00002617          	auipc	a2,0x2
ffffffffc0200f72:	cb260613          	addi	a2,a2,-846 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200f76:	0f900593          	li	a1,249
ffffffffc0200f7a:	00002517          	auipc	a0,0x2
ffffffffc0200f7e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200f82:	c2eff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f86:	00002697          	auipc	a3,0x2
ffffffffc0200f8a:	e6268693          	addi	a3,a3,-414 # ffffffffc0202de8 <commands+0x6c8>
ffffffffc0200f8e:	00002617          	auipc	a2,0x2
ffffffffc0200f92:	c9260613          	addi	a2,a2,-878 # ffffffffc0202c20 <commands+0x500>
ffffffffc0200f96:	0f800593          	li	a1,248
ffffffffc0200f9a:	00002517          	auipc	a0,0x2
ffffffffc0200f9e:	c9e50513          	addi	a0,a0,-866 # ffffffffc0202c38 <commands+0x518>
ffffffffc0200fa2:	c0eff0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0200fa6 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200fa6:	1141                	addi	sp,sp,-16
ffffffffc0200fa8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200faa:	14058a63          	beqz	a1,ffffffffc02010fe <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200fae:	00259693          	slli	a3,a1,0x2
ffffffffc0200fb2:	96ae                	add	a3,a3,a1
ffffffffc0200fb4:	068e                	slli	a3,a3,0x3
ffffffffc0200fb6:	96aa                	add	a3,a3,a0
ffffffffc0200fb8:	87aa                	mv	a5,a0
ffffffffc0200fba:	02d50263          	beq	a0,a3,ffffffffc0200fde <best_fit_free_pages+0x38>
ffffffffc0200fbe:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fc0:	8b05                	andi	a4,a4,1
ffffffffc0200fc2:	10071e63          	bnez	a4,ffffffffc02010de <best_fit_free_pages+0x138>
ffffffffc0200fc6:	6798                	ld	a4,8(a5)
ffffffffc0200fc8:	8b09                	andi	a4,a4,2
ffffffffc0200fca:	10071a63          	bnez	a4,ffffffffc02010de <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200fce:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fd2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fd6:	02878793          	addi	a5,a5,40
ffffffffc0200fda:	fed792e3          	bne	a5,a3,ffffffffc0200fbe <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200fde:	2581                	sext.w	a1,a1
ffffffffc0200fe0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200fe2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fe6:	4789                	li	a5,2
ffffffffc0200fe8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200fec:	00006697          	auipc	a3,0x6
ffffffffc0200ff0:	02468693          	addi	a3,a3,36 # ffffffffc0207010 <free_area>
ffffffffc0200ff4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200ff6:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200ff8:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200ffc:	9db9                	addw	a1,a1,a4
ffffffffc0200ffe:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201000:	0ad78863          	beq	a5,a3,ffffffffc02010b0 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201004:	fe878713          	addi	a4,a5,-24
ffffffffc0201008:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020100c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020100e:	00e56a63          	bltu	a0,a4,ffffffffc0201022 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0201012:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201014:	06d70263          	beq	a4,a3,ffffffffc0201078 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201018:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020101a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020101e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201012 <best_fit_free_pages+0x6c>
ffffffffc0201022:	c199                	beqz	a1,ffffffffc0201028 <best_fit_free_pages+0x82>
ffffffffc0201024:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201028:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020102a:	e390                	sd	a2,0(a5)
ffffffffc020102c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020102e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201030:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201032:	02d70063          	beq	a4,a3,ffffffffc0201052 <best_fit_free_pages+0xac>
        if (p + p->property == base){
ffffffffc0201036:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020103a:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base){
ffffffffc020103e:	02081613          	slli	a2,a6,0x20
ffffffffc0201042:	9201                	srli	a2,a2,0x20
ffffffffc0201044:	00261793          	slli	a5,a2,0x2
ffffffffc0201048:	97b2                	add	a5,a5,a2
ffffffffc020104a:	078e                	slli	a5,a5,0x3
ffffffffc020104c:	97ae                	add	a5,a5,a1
ffffffffc020104e:	02f50f63          	beq	a0,a5,ffffffffc020108c <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0201052:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201054:	00d70f63          	beq	a4,a3,ffffffffc0201072 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201058:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc020105a:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020105e:	02059613          	slli	a2,a1,0x20
ffffffffc0201062:	9201                	srli	a2,a2,0x20
ffffffffc0201064:	00261793          	slli	a5,a2,0x2
ffffffffc0201068:	97b2                	add	a5,a5,a2
ffffffffc020106a:	078e                	slli	a5,a5,0x3
ffffffffc020106c:	97aa                	add	a5,a5,a0
ffffffffc020106e:	04f68863          	beq	a3,a5,ffffffffc02010be <best_fit_free_pages+0x118>
}
ffffffffc0201072:	60a2                	ld	ra,8(sp)
ffffffffc0201074:	0141                	addi	sp,sp,16
ffffffffc0201076:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201078:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020107a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020107c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020107e:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201080:	02d70563          	beq	a4,a3,ffffffffc02010aa <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201084:	8832                	mv	a6,a2
ffffffffc0201086:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201088:	87ba                	mv	a5,a4
ffffffffc020108a:	bf41                	j	ffffffffc020101a <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc020108c:	491c                	lw	a5,16(a0)
ffffffffc020108e:	0107883b          	addw	a6,a5,a6
ffffffffc0201092:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201096:	57f5                	li	a5,-3
ffffffffc0201098:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020109c:	6d10                	ld	a2,24(a0)
ffffffffc020109e:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02010a0:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02010a2:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010a4:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010a6:	e390                	sd	a2,0(a5)
ffffffffc02010a8:	b775                	j	ffffffffc0201054 <best_fit_free_pages+0xae>
ffffffffc02010aa:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010ac:	873e                	mv	a4,a5
ffffffffc02010ae:	b761                	j	ffffffffc0201036 <best_fit_free_pages+0x90>
}
ffffffffc02010b0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02010b2:	e390                	sd	a2,0(a5)
ffffffffc02010b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010b6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010b8:	ed1c                	sd	a5,24(a0)
ffffffffc02010ba:	0141                	addi	sp,sp,16
ffffffffc02010bc:	8082                	ret
            base->property += p->property;
ffffffffc02010be:	ff872783          	lw	a5,-8(a4)
ffffffffc02010c2:	ff070693          	addi	a3,a4,-16
ffffffffc02010c6:	9dbd                	addw	a1,a1,a5
ffffffffc02010c8:	c90c                	sw	a1,16(a0)
ffffffffc02010ca:	57f5                	li	a5,-3
ffffffffc02010cc:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010d0:	6314                	ld	a3,0(a4)
ffffffffc02010d2:	671c                	ld	a5,8(a4)
}
ffffffffc02010d4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010d6:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02010d8:	e394                	sd	a3,0(a5)
ffffffffc02010da:	0141                	addi	sp,sp,16
ffffffffc02010dc:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010de:	00002697          	auipc	a3,0x2
ffffffffc02010e2:	e3268693          	addi	a3,a3,-462 # ffffffffc0202f10 <commands+0x7f0>
ffffffffc02010e6:	00002617          	auipc	a2,0x2
ffffffffc02010ea:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0202c20 <commands+0x500>
ffffffffc02010ee:	09500593          	li	a1,149
ffffffffc02010f2:	00002517          	auipc	a0,0x2
ffffffffc02010f6:	b4650513          	addi	a0,a0,-1210 # ffffffffc0202c38 <commands+0x518>
ffffffffc02010fa:	ab6ff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(n > 0);
ffffffffc02010fe:	00002697          	auipc	a3,0x2
ffffffffc0201102:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0202c18 <commands+0x4f8>
ffffffffc0201106:	00002617          	auipc	a2,0x2
ffffffffc020110a:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0202c20 <commands+0x500>
ffffffffc020110e:	09200593          	li	a1,146
ffffffffc0201112:	00002517          	auipc	a0,0x2
ffffffffc0201116:	b2650513          	addi	a0,a0,-1242 # ffffffffc0202c38 <commands+0x518>
ffffffffc020111a:	a96ff0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc020111e <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020111e:	1141                	addi	sp,sp,-16
ffffffffc0201120:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201122:	c9e1                	beqz	a1,ffffffffc02011f2 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201124:	00259693          	slli	a3,a1,0x2
ffffffffc0201128:	96ae                	add	a3,a3,a1
ffffffffc020112a:	068e                	slli	a3,a3,0x3
ffffffffc020112c:	96aa                	add	a3,a3,a0
ffffffffc020112e:	87aa                	mv	a5,a0
ffffffffc0201130:	00d50f63          	beq	a0,a3,ffffffffc020114e <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201134:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201136:	8b05                	andi	a4,a4,1
ffffffffc0201138:	cf49                	beqz	a4,ffffffffc02011d2 <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc020113a:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc020113e:	0007a823          	sw	zero,16(a5)
ffffffffc0201142:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201146:	02878793          	addi	a5,a5,40
ffffffffc020114a:	fed795e3          	bne	a5,a3,ffffffffc0201134 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020114e:	2581                	sext.w	a1,a1
ffffffffc0201150:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201152:	4789                	li	a5,2
ffffffffc0201154:	00850713          	addi	a4,a0,8
ffffffffc0201158:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020115c:	00006697          	auipc	a3,0x6
ffffffffc0201160:	eb468693          	addi	a3,a3,-332 # ffffffffc0207010 <free_area>
ffffffffc0201164:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201166:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201168:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020116c:	9db9                	addw	a1,a1,a4
ffffffffc020116e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201170:	04d78a63          	beq	a5,a3,ffffffffc02011c4 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201174:	fe878713          	addi	a4,a5,-24
ffffffffc0201178:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020117c:	4581                	li	a1,0
            if (base < page)
ffffffffc020117e:	00e56a63          	bltu	a0,a4,ffffffffc0201192 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201182:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201184:	02d70263          	beq	a4,a3,ffffffffc02011a8 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201188:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020118a:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc020118e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201182 <best_fit_init_memmap+0x64>
ffffffffc0201192:	c199                	beqz	a1,ffffffffc0201198 <best_fit_init_memmap+0x7a>
ffffffffc0201194:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201198:	6398                	ld	a4,0(a5)
}
ffffffffc020119a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020119c:	e390                	sd	a2,0(a5)
ffffffffc020119e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011a2:	ed18                	sd	a4,24(a0)
ffffffffc02011a4:	0141                	addi	sp,sp,16
ffffffffc02011a6:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011a8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011aa:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011ac:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011ae:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011b0:	00d70663          	beq	a4,a3,ffffffffc02011bc <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011b4:	8832                	mv	a6,a2
ffffffffc02011b6:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011b8:	87ba                	mv	a5,a4
ffffffffc02011ba:	bfc1                	j	ffffffffc020118a <best_fit_init_memmap+0x6c>
}
ffffffffc02011bc:	60a2                	ld	ra,8(sp)
ffffffffc02011be:	e290                	sd	a2,0(a3)
ffffffffc02011c0:	0141                	addi	sp,sp,16
ffffffffc02011c2:	8082                	ret
ffffffffc02011c4:	60a2                	ld	ra,8(sp)
ffffffffc02011c6:	e390                	sd	a2,0(a5)
ffffffffc02011c8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011ca:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011cc:	ed1c                	sd	a5,24(a0)
ffffffffc02011ce:	0141                	addi	sp,sp,16
ffffffffc02011d0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011d2:	00002697          	auipc	a3,0x2
ffffffffc02011d6:	d6668693          	addi	a3,a3,-666 # ffffffffc0202f38 <commands+0x818>
ffffffffc02011da:	00002617          	auipc	a2,0x2
ffffffffc02011de:	a4660613          	addi	a2,a2,-1466 # ffffffffc0202c20 <commands+0x500>
ffffffffc02011e2:	04a00593          	li	a1,74
ffffffffc02011e6:	00002517          	auipc	a0,0x2
ffffffffc02011ea:	a5250513          	addi	a0,a0,-1454 # ffffffffc0202c38 <commands+0x518>
ffffffffc02011ee:	9c2ff0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(n > 0);
ffffffffc02011f2:	00002697          	auipc	a3,0x2
ffffffffc02011f6:	a2668693          	addi	a3,a3,-1498 # ffffffffc0202c18 <commands+0x4f8>
ffffffffc02011fa:	00002617          	auipc	a2,0x2
ffffffffc02011fe:	a2660613          	addi	a2,a2,-1498 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201202:	04700593          	li	a1,71
ffffffffc0201206:	00002517          	auipc	a0,0x2
ffffffffc020120a:	a3250513          	addi	a0,a0,-1486 # ffffffffc0202c38 <commands+0x518>
ffffffffc020120e:	9a2ff0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0201212 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201212:	100027f3          	csrr	a5,sstatus
ffffffffc0201216:	8b89                	andi	a5,a5,2
ffffffffc0201218:	e799                	bnez	a5,ffffffffc0201226 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020121a:	00006797          	auipc	a5,0x6
ffffffffc020121e:	2e67b783          	ld	a5,742(a5) # ffffffffc0207500 <pmm_manager>
ffffffffc0201222:	6f9c                	ld	a5,24(a5)
ffffffffc0201224:	8782                	jr	a5
{
ffffffffc0201226:	1141                	addi	sp,sp,-16
ffffffffc0201228:	e406                	sd	ra,8(sp)
ffffffffc020122a:	e022                	sd	s0,0(sp)
ffffffffc020122c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020122e:	a34ff0ef          	jal	ra,ffffffffc0200462 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201232:	00006797          	auipc	a5,0x6
ffffffffc0201236:	2ce7b783          	ld	a5,718(a5) # ffffffffc0207500 <pmm_manager>
ffffffffc020123a:	6f9c                	ld	a5,24(a5)
ffffffffc020123c:	8522                	mv	a0,s0
ffffffffc020123e:	9782                	jalr	a5
ffffffffc0201240:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201242:	a1aff0ef          	jal	ra,ffffffffc020045c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201246:	60a2                	ld	ra,8(sp)
ffffffffc0201248:	8522                	mv	a0,s0
ffffffffc020124a:	6402                	ld	s0,0(sp)
ffffffffc020124c:	0141                	addi	sp,sp,16
ffffffffc020124e:	8082                	ret

ffffffffc0201250 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201250:	100027f3          	csrr	a5,sstatus
ffffffffc0201254:	8b89                	andi	a5,a5,2
ffffffffc0201256:	e799                	bnez	a5,ffffffffc0201264 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201258:	00006797          	auipc	a5,0x6
ffffffffc020125c:	2a87b783          	ld	a5,680(a5) # ffffffffc0207500 <pmm_manager>
ffffffffc0201260:	739c                	ld	a5,32(a5)
ffffffffc0201262:	8782                	jr	a5
{
ffffffffc0201264:	1101                	addi	sp,sp,-32
ffffffffc0201266:	ec06                	sd	ra,24(sp)
ffffffffc0201268:	e822                	sd	s0,16(sp)
ffffffffc020126a:	e426                	sd	s1,8(sp)
ffffffffc020126c:	842a                	mv	s0,a0
ffffffffc020126e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201270:	9f2ff0ef          	jal	ra,ffffffffc0200462 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201274:	00006797          	auipc	a5,0x6
ffffffffc0201278:	28c7b783          	ld	a5,652(a5) # ffffffffc0207500 <pmm_manager>
ffffffffc020127c:	739c                	ld	a5,32(a5)
ffffffffc020127e:	85a6                	mv	a1,s1
ffffffffc0201280:	8522                	mv	a0,s0
ffffffffc0201282:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201284:	6442                	ld	s0,16(sp)
ffffffffc0201286:	60e2                	ld	ra,24(sp)
ffffffffc0201288:	64a2                	ld	s1,8(sp)
ffffffffc020128a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020128c:	9d0ff06f          	j	ffffffffc020045c <intr_enable>

ffffffffc0201290 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201290:	100027f3          	csrr	a5,sstatus
ffffffffc0201294:	8b89                	andi	a5,a5,2
ffffffffc0201296:	e799                	bnez	a5,ffffffffc02012a4 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201298:	00006797          	auipc	a5,0x6
ffffffffc020129c:	2687b783          	ld	a5,616(a5) # ffffffffc0207500 <pmm_manager>
ffffffffc02012a0:	779c                	ld	a5,40(a5)
ffffffffc02012a2:	8782                	jr	a5
{
ffffffffc02012a4:	1141                	addi	sp,sp,-16
ffffffffc02012a6:	e406                	sd	ra,8(sp)
ffffffffc02012a8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012aa:	9b8ff0ef          	jal	ra,ffffffffc0200462 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012ae:	00006797          	auipc	a5,0x6
ffffffffc02012b2:	2527b783          	ld	a5,594(a5) # ffffffffc0207500 <pmm_manager>
ffffffffc02012b6:	779c                	ld	a5,40(a5)
ffffffffc02012b8:	9782                	jalr	a5
ffffffffc02012ba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012bc:	9a0ff0ef          	jal	ra,ffffffffc020045c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012c0:	60a2                	ld	ra,8(sp)
ffffffffc02012c2:	8522                	mv	a0,s0
ffffffffc02012c4:	6402                	ld	s0,0(sp)
ffffffffc02012c6:	0141                	addi	sp,sp,16
ffffffffc02012c8:	8082                	ret

ffffffffc02012ca <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012ca:	00002797          	auipc	a5,0x2
ffffffffc02012ce:	c9678793          	addi	a5,a5,-874 # ffffffffc0202f60 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d2:	638c                	ld	a1,0(a5)
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void)
{
ffffffffc02012d4:	1101                	addi	sp,sp,-32
ffffffffc02012d6:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d8:	00002517          	auipc	a0,0x2
ffffffffc02012dc:	cc050513          	addi	a0,a0,-832 # ffffffffc0202f98 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012e0:	00006497          	auipc	s1,0x6
ffffffffc02012e4:	22048493          	addi	s1,s1,544 # ffffffffc0207500 <pmm_manager>
{
ffffffffc02012e8:	ec06                	sd	ra,24(sp)
ffffffffc02012ea:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012ec:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012ee:	dc9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02012f2:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012f4:	00006417          	auipc	s0,0x6
ffffffffc02012f8:	22440413          	addi	s0,s0,548 # ffffffffc0207518 <va_pa_offset>
    pmm_manager->init();
ffffffffc02012fc:	679c                	ld	a5,8(a5)
ffffffffc02012fe:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201300:	57f5                	li	a5,-3
ffffffffc0201302:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201304:	00002517          	auipc	a0,0x2
ffffffffc0201308:	cac50513          	addi	a0,a0,-852 # ffffffffc0202fb0 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020130c:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020130e:	da9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201312:	46c5                	li	a3,17
ffffffffc0201314:	06ee                	slli	a3,a3,0x1b
ffffffffc0201316:	40100613          	li	a2,1025
ffffffffc020131a:	16fd                	addi	a3,a3,-1
ffffffffc020131c:	07e005b7          	lui	a1,0x7e00
ffffffffc0201320:	0656                	slli	a2,a2,0x15
ffffffffc0201322:	00002517          	auipc	a0,0x2
ffffffffc0201326:	ca650513          	addi	a0,a0,-858 # ffffffffc0202fc8 <best_fit_pmm_manager+0x68>
ffffffffc020132a:	d8dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020132e:	777d                	lui	a4,0xfffff
ffffffffc0201330:	00007797          	auipc	a5,0x7
ffffffffc0201334:	1f778793          	addi	a5,a5,503 # ffffffffc0208527 <end+0xfff>
ffffffffc0201338:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020133a:	00006517          	auipc	a0,0x6
ffffffffc020133e:	1b650513          	addi	a0,a0,438 # ffffffffc02074f0 <npage>
ffffffffc0201342:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201346:	00006597          	auipc	a1,0x6
ffffffffc020134a:	1b258593          	addi	a1,a1,434 # ffffffffc02074f8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020134e:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201350:	e19c                	sd	a5,0(a1)
ffffffffc0201352:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0201354:	4701                	li	a4,0
ffffffffc0201356:	4885                	li	a7,1
ffffffffc0201358:	fff80837          	lui	a6,0xfff80
ffffffffc020135c:	a011                	j	ffffffffc0201360 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020135e:	619c                	ld	a5,0(a1)
ffffffffc0201360:	97b6                	add	a5,a5,a3
ffffffffc0201362:	07a1                	addi	a5,a5,8
ffffffffc0201364:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0201368:	611c                	ld	a5,0(a0)
ffffffffc020136a:	0705                	addi	a4,a4,1
ffffffffc020136c:	02868693          	addi	a3,a3,40
ffffffffc0201370:	01078633          	add	a2,a5,a6
ffffffffc0201374:	fec765e3          	bltu	a4,a2,ffffffffc020135e <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201378:	6190                	ld	a2,0(a1)
ffffffffc020137a:	00279713          	slli	a4,a5,0x2
ffffffffc020137e:	973e                	add	a4,a4,a5
ffffffffc0201380:	fec006b7          	lui	a3,0xfec00
ffffffffc0201384:	070e                	slli	a4,a4,0x3
ffffffffc0201386:	96b2                	add	a3,a3,a2
ffffffffc0201388:	96ba                	add	a3,a3,a4
ffffffffc020138a:	c0200737          	lui	a4,0xc0200
ffffffffc020138e:	08e6ef63          	bltu	a3,a4,ffffffffc020142c <pmm_init+0x162>
ffffffffc0201392:	6018                	ld	a4,0(s0)
    if (freemem < mem_end)
ffffffffc0201394:	45c5                	li	a1,17
ffffffffc0201396:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201398:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end)
ffffffffc020139a:	04b6e863          	bltu	a3,a1,ffffffffc02013ea <pmm_init+0x120>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc020139e:	609c                	ld	a5,0(s1)
ffffffffc02013a0:	7b9c                	ld	a5,48(a5)
ffffffffc02013a2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013a4:	00002517          	auipc	a0,0x2
ffffffffc02013a8:	cbc50513          	addi	a0,a0,-836 # ffffffffc0203060 <best_fit_pmm_manager+0x100>
ffffffffc02013ac:	d0bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t *)boot_page_table_sv39;
ffffffffc02013b0:	00005597          	auipc	a1,0x5
ffffffffc02013b4:	c5058593          	addi	a1,a1,-944 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc02013b8:	00006797          	auipc	a5,0x6
ffffffffc02013bc:	14b7bc23          	sd	a1,344(a5) # ffffffffc0207510 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013c0:	c02007b7          	lui	a5,0xc0200
ffffffffc02013c4:	08f5e063          	bltu	a1,a5,ffffffffc0201444 <pmm_init+0x17a>
ffffffffc02013c8:	6010                	ld	a2,0(s0)
}
ffffffffc02013ca:	6442                	ld	s0,16(sp)
ffffffffc02013cc:	60e2                	ld	ra,24(sp)
ffffffffc02013ce:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013d0:	40c58633          	sub	a2,a1,a2
ffffffffc02013d4:	00006797          	auipc	a5,0x6
ffffffffc02013d8:	12c7ba23          	sd	a2,308(a5) # ffffffffc0207508 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013dc:	00002517          	auipc	a0,0x2
ffffffffc02013e0:	ca450513          	addi	a0,a0,-860 # ffffffffc0203080 <best_fit_pmm_manager+0x120>
}
ffffffffc02013e4:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013e6:	cd1fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013ea:	6705                	lui	a4,0x1
ffffffffc02013ec:	177d                	addi	a4,a4,-1
ffffffffc02013ee:	96ba                	add	a3,a3,a4
ffffffffc02013f0:	777d                	lui	a4,0xfffff
ffffffffc02013f2:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013f4:	00c6d513          	srli	a0,a3,0xc
ffffffffc02013f8:	00f57e63          	bgeu	a0,a5,ffffffffc0201414 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02013fc:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02013fe:	982a                	add	a6,a6,a0
ffffffffc0201400:	00281513          	slli	a0,a6,0x2
ffffffffc0201404:	9542                	add	a0,a0,a6
ffffffffc0201406:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201408:	8d95                	sub	a1,a1,a3
ffffffffc020140a:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020140c:	81b1                	srli	a1,a1,0xc
ffffffffc020140e:	9532                	add	a0,a0,a2
ffffffffc0201410:	9782                	jalr	a5
}
ffffffffc0201412:	b771                	j	ffffffffc020139e <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201414:	00002617          	auipc	a2,0x2
ffffffffc0201418:	c1c60613          	addi	a2,a2,-996 # ffffffffc0203030 <best_fit_pmm_manager+0xd0>
ffffffffc020141c:	06b00593          	li	a1,107
ffffffffc0201420:	00002517          	auipc	a0,0x2
ffffffffc0201424:	c3050513          	addi	a0,a0,-976 # ffffffffc0203050 <best_fit_pmm_manager+0xf0>
ffffffffc0201428:	f89fe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020142c:	00002617          	auipc	a2,0x2
ffffffffc0201430:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0202ff8 <best_fit_pmm_manager+0x98>
ffffffffc0201434:	07500593          	li	a1,117
ffffffffc0201438:	00002517          	auipc	a0,0x2
ffffffffc020143c:	be850513          	addi	a0,a0,-1048 # ffffffffc0203020 <best_fit_pmm_manager+0xc0>
ffffffffc0201440:	f71fe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201444:	86ae                	mv	a3,a1
ffffffffc0201446:	00002617          	auipc	a2,0x2
ffffffffc020144a:	bb260613          	addi	a2,a2,-1102 # ffffffffc0202ff8 <best_fit_pmm_manager+0x98>
ffffffffc020144e:	09200593          	li	a1,146
ffffffffc0201452:	00002517          	auipc	a0,0x2
ffffffffc0201456:	bce50513          	addi	a0,a0,-1074 # ffffffffc0203020 <best_fit_pmm_manager+0xc0>
ffffffffc020145a:	f57fe0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc020145e <kmem_slab_destroy>:
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020145e:	00006797          	auipc	a5,0x6
ffffffffc0201462:	09a7b783          	ld	a5,154(a5) # ffffffffc02074f8 <pages>
ffffffffc0201466:	40f587b3          	sub	a5,a1,a5
ffffffffc020146a:	00002717          	auipc	a4,0x2
ffffffffc020146e:	25e73703          	ld	a4,606(a4) # ffffffffc02036c8 <error_string+0x38>
ffffffffc0201472:	878d                	srai	a5,a5,0x3
ffffffffc0201474:	02e787b3          	mul	a5,a5,a4
ffffffffc0201478:	00002717          	auipc	a4,0x2
ffffffffc020147c:	25873703          	ld	a4,600(a4) # ffffffffc02036d0 <nbase>
#define le2slab(le, link) ((struct slab_t *)le2page((struct Page *)le, link))
#define slab2kva(slab) (page2kva((struct Page *)slab))

static inline void *page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
ffffffffc0201480:	00006617          	auipc	a2,0x6
ffffffffc0201484:	07063603          	ld	a2,112(a2) # ffffffffc02074f0 <npage>
ffffffffc0201488:	97ba                	add	a5,a5,a4
ffffffffc020148a:	00c79713          	slli	a4,a5,0xc
ffffffffc020148e:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201490:	00c79693          	slli	a3,a5,0xc
ffffffffc0201494:	06c77c63          	bgeu	a4,a2,ffffffffc020150c <kmem_slab_destroy+0xae>
/* 释放cachep中的一个slab块对应的页，析构buf中的对象后将page归还 */
static void kmem_slab_destroy(struct kmem_cache_t *cachep, struct slab_t *slab)
{
    struct Page *page = (struct Page *)slab;
    int16_t *bufctl = page2kva(page);
    void *buf = bufctl + cachep->num;
ffffffffc0201498:	03255603          	lhu	a2,50(a0)
    // slab下所有的obj全部析构为DEFAULT_DTVAL
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc020149c:	03055703          	lhu	a4,48(a0)
    return KADDR(page2pa(page));
ffffffffc02014a0:	00006797          	auipc	a5,0x6
ffffffffc02014a4:	0787b783          	ld	a5,120(a5) # ffffffffc0207518 <va_pa_offset>
ffffffffc02014a8:	97b6                	add	a5,a5,a3
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc02014aa:	02c706bb          	mulw	a3,a4,a2
    void *buf = bufctl + cachep->num;
ffffffffc02014ae:	0606                	slli	a2,a2,0x1
ffffffffc02014b0:	00c78333          	add	t1,a5,a2
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc02014b4:	8e2e                	mv	t3,a1
ffffffffc02014b6:	861a                	mv	a2,t1
    {
        char *objp = (char *)p;
        for (int i = 0; i < cachep->objsize; i++)
        {

            objp[i] = DEFAULT_DTVAL;
ffffffffc02014b8:	4885                	li	a7,1
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc02014ba:	00d307b3          	add	a5,t1,a3
ffffffffc02014be:	02f37a63          	bgeu	t1,a5,ffffffffc02014f2 <kmem_slab_destroy+0x94>
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc02014c2:	4781                	li	a5,0
ffffffffc02014c4:	4801                	li	a6,0
ffffffffc02014c6:	cf11                	beqz	a4,ffffffffc02014e2 <kmem_slab_destroy+0x84>
            objp[i] = DEFAULT_DTVAL;
ffffffffc02014c8:	00f60733          	add	a4,a2,a5
ffffffffc02014cc:	01170023          	sb	a7,0(a4)
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc02014d0:	03055703          	lhu	a4,48(a0)
ffffffffc02014d4:	0785                	addi	a5,a5,1
ffffffffc02014d6:	0007869b          	sext.w	a3,a5
ffffffffc02014da:	0007081b          	sext.w	a6,a4
ffffffffc02014de:	fee6c5e3          	blt	a3,a4,ffffffffc02014c8 <kmem_slab_destroy+0x6a>
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc02014e2:	03255783          	lhu	a5,50(a0)
ffffffffc02014e6:	963a                	add	a2,a2,a4
ffffffffc02014e8:	0307883b          	mulw	a6,a5,a6
ffffffffc02014ec:	981a                	add	a6,a6,t1
ffffffffc02014ee:	fd066ae3          	bltu	a2,a6,ffffffffc02014c2 <kmem_slab_destroy+0x64>
    __list_del(listelm->prev, listelm->next);
ffffffffc02014f2:	018e3703          	ld	a4,24(t3)
ffffffffc02014f6:	020e3783          	ld	a5,32(t3)
        }
    }
    page->property = page->flags = 0;
ffffffffc02014fa:	000e3423          	sd	zero,8(t3)
ffffffffc02014fe:	000e2823          	sw	zero,16(t3)
    prev->next = next;
ffffffffc0201502:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201504:	e398                	sd	a4,0(a5)
    list_del(&(page->page_link));
    free_page(page);
ffffffffc0201506:	4585                	li	a1,1
ffffffffc0201508:	8572                	mv	a0,t3
ffffffffc020150a:	b399                	j	ffffffffc0201250 <free_pages>
{
ffffffffc020150c:	1141                	addi	sp,sp,-16
    return KADDR(page2pa(page));
ffffffffc020150e:	00002617          	auipc	a2,0x2
ffffffffc0201512:	bb260613          	addi	a2,a2,-1102 # ffffffffc02030c0 <best_fit_pmm_manager+0x160>
ffffffffc0201516:	45d1                	li	a1,20
ffffffffc0201518:	00002517          	auipc	a0,0x2
ffffffffc020151c:	bd050513          	addi	a0,a0,-1072 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
{
ffffffffc0201520:	e406                	sd	ra,8(sp)
    return KADDR(page2pa(page));
ffffffffc0201522:	e8ffe0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0201526 <kmem_cache_alloc>:
// ! 第二层结构结束

// ! 第三层结构
/* 从cachep指向的仓库中分配一个对象，返回指向对象的指针objp */
void *kmem_cache_alloc(struct kmem_cache_t *cachep)
{
ffffffffc0201526:	7139                	addi	sp,sp,-64
ffffffffc0201528:	f426                	sd	s1,40(sp)
    return list->next == list;
ffffffffc020152a:	6d04                	ld	s1,24(a0)
ffffffffc020152c:	f822                	sd	s0,48(sp)
ffffffffc020152e:	f04a                	sd	s2,32(sp)
ffffffffc0201530:	ec4e                	sd	s3,24(sp)
ffffffffc0201532:	fc06                	sd	ra,56(sp)
ffffffffc0201534:	e852                	sd	s4,16(sp)
ffffffffc0201536:	e456                	sd	s5,8(sp)
ffffffffc0201538:	e05a                	sd	s6,0(sp)
    list_entry_t *le = NULL;
    if (!list_empty(&(cachep->slabs_partial)))
ffffffffc020153a:	01050913          	addi	s2,a0,16
{
ffffffffc020153e:	842a                	mv	s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201540:	00002997          	auipc	s3,0x2
ffffffffc0201544:	1909b983          	ld	s3,400(s3) # ffffffffc02036d0 <nbase>
    if (!list_empty(&(cachep->slabs_partial)))
ffffffffc0201548:	0a990063          	beq	s2,s1,ffffffffc02015e8 <kmem_cache_alloc+0xc2>
ffffffffc020154c:	00006817          	auipc	a6,0x6
ffffffffc0201550:	fac83803          	ld	a6,-84(a6) # ffffffffc02074f8 <pages>
    return KADDR(page2pa(page));
ffffffffc0201554:	00006617          	auipc	a2,0x6
ffffffffc0201558:	f9c63603          	ld	a2,-100(a2) # ffffffffc02074f0 <npage>
ffffffffc020155c:	00002a17          	auipc	s4,0x2
ffffffffc0201560:	16ca3a03          	ld	s4,364(s4) # ffffffffc02036c8 <error_string+0x38>
            return NULL;
        }
        le = list_next(&(cachep->slabs_free));
    }
    list_del(le);
    struct slab_t *slab = le2slab(le, page_link);
ffffffffc0201564:	fe848693          	addi	a3,s1,-24
ffffffffc0201568:	410686b3          	sub	a3,a3,a6
ffffffffc020156c:	868d                	srai	a3,a3,0x3
ffffffffc020156e:	034686b3          	mul	a3,a3,s4
    __list_del(listelm->prev, listelm->next);
ffffffffc0201572:	649c                	ld	a5,8(s1)
ffffffffc0201574:	6098                	ld	a4,0(s1)
    prev->next = next;
ffffffffc0201576:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201578:	e398                	sd	a4,0(a5)
ffffffffc020157a:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc020157c:	00c69793          	slli	a5,a3,0xc
ffffffffc0201580:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201582:	06b2                	slli	a3,a3,0xc
ffffffffc0201584:	16c7fb63          	bgeu	a5,a2,ffffffffc02016fa <kmem_cache_alloc+0x1d4>
    void *kva = slab2kva(slab);
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc0201588:	ffa49703          	lh	a4,-6(s1)
ffffffffc020158c:	03045503          	lhu	a0,48(s0)
    slab->inuse++;
ffffffffc0201590:	ff84d783          	lhu	a5,-8(s1)
    return KADDR(page2pa(page));
ffffffffc0201594:	00006617          	auipc	a2,0x6
ffffffffc0201598:	f8463603          	ld	a2,-124(a2) # ffffffffc0207518 <va_pa_offset>
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc020159c:	02e5053b          	mulw	a0,a0,a4
    slab->inuse++;
ffffffffc02015a0:	2785                	addiw	a5,a5,1
ffffffffc02015a2:	17c2                	slli	a5,a5,0x30
    return KADDR(page2pa(page));
ffffffffc02015a4:	96b2                	add	a3,a3,a2
    slab->inuse++;
ffffffffc02015a6:	93c1                	srli	a5,a5,0x30
    slab->free = bufctl[slab->free];
ffffffffc02015a8:	0706                	slli	a4,a4,0x1
    void *buf = bufctl + cachep->num;
ffffffffc02015aa:	03245603          	lhu	a2,50(s0)
    slab->free = bufctl[slab->free];
ffffffffc02015ae:	9736                	add	a4,a4,a3
    slab->inuse++;
ffffffffc02015b0:	fef49c23          	sh	a5,-8(s1)
    slab->free = bufctl[slab->free];
ffffffffc02015b4:	00071703          	lh	a4,0(a4)
    void *buf = bufctl + cachep->num;
ffffffffc02015b8:	00161593          	slli	a1,a2,0x1
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc02015bc:	952e                	add	a0,a0,a1
    slab->free = bufctl[slab->free];
ffffffffc02015be:	fee49d23          	sh	a4,-6(s1)
    void *objp = buf + slab->free * cachep->objsize;
ffffffffc02015c2:	9536                	add	a0,a0,a3
    if (slab->inuse == cachep->num)
ffffffffc02015c4:	12f60563          	beq	a2,a5,ffffffffc02016ee <kmem_cache_alloc+0x1c8>
    __list_add(elm, listelm, listelm->next);
ffffffffc02015c8:	6c1c                	ld	a5,24(s0)
    prev->next = next->prev = elm;
ffffffffc02015ca:	e384                	sd	s1,0(a5)
ffffffffc02015cc:	ec04                	sd	s1,24(s0)
    elm->next = next;
ffffffffc02015ce:	e49c                	sd	a5,8(s1)
    elm->prev = prev;
ffffffffc02015d0:	0124b023          	sd	s2,0(s1)
        list_add(&(cachep->slabs_full), le);
    else
        list_add(&(cachep->slabs_partial), le);
    return objp;
}
ffffffffc02015d4:	70e2                	ld	ra,56(sp)
ffffffffc02015d6:	7442                	ld	s0,48(sp)
ffffffffc02015d8:	74a2                	ld	s1,40(sp)
ffffffffc02015da:	7902                	ld	s2,32(sp)
ffffffffc02015dc:	69e2                	ld	s3,24(sp)
ffffffffc02015de:	6a42                	ld	s4,16(sp)
ffffffffc02015e0:	6aa2                	ld	s5,8(sp)
ffffffffc02015e2:	6b02                	ld	s6,0(sp)
ffffffffc02015e4:	6121                	addi	sp,sp,64
ffffffffc02015e6:	8082                	ret
    return list->next == list;
ffffffffc02015e8:	7504                	ld	s1,40(a0)
        if (list_empty(&(cachep->slabs_free)) && kmem_cache_grow(cachep) == NULL)
ffffffffc02015ea:	02050793          	addi	a5,a0,32
ffffffffc02015ee:	f4f49fe3          	bne	s1,a5,ffffffffc020154c <kmem_cache_alloc+0x26>
    struct Page *page = alloc_pages(1);
ffffffffc02015f2:	4505                	li	a0,1
ffffffffc02015f4:	c1fff0ef          	jal	ra,ffffffffc0201212 <alloc_pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02015f8:	00006b17          	auipc	s6,0x6
ffffffffc02015fc:	f00b0b13          	addi	s6,s6,-256 # ffffffffc02074f8 <pages>
ffffffffc0201600:	000b3783          	ld	a5,0(s6)
ffffffffc0201604:	00002a17          	auipc	s4,0x2
ffffffffc0201608:	0c4a3a03          	ld	s4,196(s4) # ffffffffc02036c8 <error_string+0x38>
ffffffffc020160c:	8aaa                	mv	s5,a0
ffffffffc020160e:	40f505b3          	sub	a1,a0,a5
ffffffffc0201612:	858d                	srai	a1,a1,0x3
ffffffffc0201614:	034585b3          	mul	a1,a1,s4
    cprintf("allocate page for kmem_cache, address: %p\n", page2pa(page));
ffffffffc0201618:	00002517          	auipc	a0,0x2
ffffffffc020161c:	ae050513          	addi	a0,a0,-1312 # ffffffffc02030f8 <best_fit_pmm_manager+0x198>
ffffffffc0201620:	95ce                	add	a1,a1,s3
ffffffffc0201622:	05b2                	slli	a1,a1,0xc
ffffffffc0201624:	a93fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0201628:	000b3803          	ld	a6,0(s6)
    return KADDR(page2pa(page));
ffffffffc020162c:	00006517          	auipc	a0,0x6
ffffffffc0201630:	ec450513          	addi	a0,a0,-316 # ffffffffc02074f0 <npage>
ffffffffc0201634:	6110                	ld	a2,0(a0)
ffffffffc0201636:	410a87b3          	sub	a5,s5,a6
ffffffffc020163a:	878d                	srai	a5,a5,0x3
ffffffffc020163c:	034787b3          	mul	a5,a5,s4
ffffffffc0201640:	97ce                	add	a5,a5,s3
ffffffffc0201642:	00c79713          	slli	a4,a5,0xc
ffffffffc0201646:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201648:	07b2                	slli	a5,a5,0xc
ffffffffc020164a:	0cc77363          	bgeu	a4,a2,ffffffffc0201710 <kmem_cache_alloc+0x1ea>
    slab->inuse = slab->free = 0;
ffffffffc020164e:	000aa823          	sw	zero,16(s5)
    for (int i = 1; i < cachep->num; i++)
ffffffffc0201652:	03245683          	lhu	a3,50(s0)
    return KADDR(page2pa(page));
ffffffffc0201656:	00006717          	auipc	a4,0x6
ffffffffc020165a:	ec273703          	ld	a4,-318(a4) # ffffffffc0207518 <va_pa_offset>
ffffffffc020165e:	97ba                	add	a5,a5,a4
    slab->cachep = cachep;
ffffffffc0201660:	008ab423          	sd	s0,8(s5)
    for (int i = 1; i < cachep->num; i++)
ffffffffc0201664:	4705                	li	a4,1
    return KADDR(page2pa(page));
ffffffffc0201666:	85be                	mv	a1,a5
    for (int i = 1; i < cachep->num; i++)
ffffffffc0201668:	00d77a63          	bgeu	a4,a3,ffffffffc020167c <kmem_cache_alloc+0x156>
        bufctl[i - 1] = i; // 链表结构，初始化时都是空闲，因此都指向自己的下一个元素
ffffffffc020166c:	00e79023          	sh	a4,0(a5)
    for (int i = 1; i < cachep->num; i++)
ffffffffc0201670:	03245683          	lhu	a3,50(s0)
ffffffffc0201674:	2705                	addiw	a4,a4,1
ffffffffc0201676:	0789                	addi	a5,a5,2
ffffffffc0201678:	fed74ae3          	blt	a4,a3,ffffffffc020166c <kmem_cache_alloc+0x146>
    bufctl[cachep->num - 1] = -1;
ffffffffc020167c:	00169793          	slli	a5,a3,0x1
ffffffffc0201680:	97ae                	add	a5,a5,a1
ffffffffc0201682:	577d                	li	a4,-1
ffffffffc0201684:	fee79f23          	sh	a4,-2(a5)
    void *buf = bufctl + cachep->num;
ffffffffc0201688:	03245783          	lhu	a5,50(s0)
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc020168c:	03045703          	lhu	a4,48(s0)
    void *buf = bufctl + cachep->num;
ffffffffc0201690:	00179693          	slli	a3,a5,0x1
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc0201694:	02f707bb          	mulw	a5,a4,a5
    void *buf = bufctl + cachep->num;
ffffffffc0201698:	96ae                	add	a3,a3,a1
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc020169a:	85b6                	mv	a1,a3
ffffffffc020169c:	97b6                	add	a5,a5,a3
ffffffffc020169e:	02f6fd63          	bgeu	a3,a5,ffffffffc02016d8 <kmem_cache_alloc+0x1b2>
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc02016a2:	4781                	li	a5,0
ffffffffc02016a4:	4801                	li	a6,0
ffffffffc02016a6:	cf11                	beqz	a4,ffffffffc02016c2 <kmem_cache_alloc+0x19c>
            objp[i] = DEFAULT_CTVAL;
ffffffffc02016a8:	00f58733          	add	a4,a1,a5
ffffffffc02016ac:	00070023          	sb	zero,0(a4)
        for (int i = 0; i < cachep->objsize; i++)
ffffffffc02016b0:	03045703          	lhu	a4,48(s0)
ffffffffc02016b4:	0785                	addi	a5,a5,1
ffffffffc02016b6:	0007861b          	sext.w	a2,a5
ffffffffc02016ba:	0007081b          	sext.w	a6,a4
ffffffffc02016be:	fee645e3          	blt	a2,a4,ffffffffc02016a8 <kmem_cache_alloc+0x182>
    for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
ffffffffc02016c2:	03245783          	lhu	a5,50(s0)
ffffffffc02016c6:	95ba                	add	a1,a1,a4
ffffffffc02016c8:	0307883b          	mulw	a6,a5,a6
ffffffffc02016cc:	9836                	add	a6,a6,a3
ffffffffc02016ce:	fd05eae3          	bltu	a1,a6,ffffffffc02016a2 <kmem_cache_alloc+0x17c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02016d2:	000b3803          	ld	a6,0(s6)
    return KADDR(page2pa(page));
ffffffffc02016d6:	6110                	ld	a2,0(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc02016d8:	741c                	ld	a5,40(s0)
    list_add(&(cachep->slabs_free), &(slab->slab_link));
ffffffffc02016da:	018a8713          	addi	a4,s5,24
    prev->next = next->prev = elm;
ffffffffc02016de:	e398                	sd	a4,0(a5)
ffffffffc02016e0:	f418                	sd	a4,40(s0)
    elm->next = next;
ffffffffc02016e2:	02fab023          	sd	a5,32(s5)
    elm->prev = prev;
ffffffffc02016e6:	009abc23          	sd	s1,24(s5)
    return listelm->next;
ffffffffc02016ea:	7404                	ld	s1,40(s0)
ffffffffc02016ec:	bda5                	j	ffffffffc0201564 <kmem_cache_alloc+0x3e>
    __list_add(elm, listelm, listelm->next);
ffffffffc02016ee:	641c                	ld	a5,8(s0)
    prev->next = next->prev = elm;
ffffffffc02016f0:	e384                	sd	s1,0(a5)
ffffffffc02016f2:	e404                	sd	s1,8(s0)
    elm->next = next;
ffffffffc02016f4:	e49c                	sd	a5,8(s1)
    elm->prev = prev;
ffffffffc02016f6:	e080                	sd	s0,0(s1)
}
ffffffffc02016f8:	bdf1                	j	ffffffffc02015d4 <kmem_cache_alloc+0xae>
    return KADDR(page2pa(page));
ffffffffc02016fa:	00002617          	auipc	a2,0x2
ffffffffc02016fe:	9c660613          	addi	a2,a2,-1594 # ffffffffc02030c0 <best_fit_pmm_manager+0x160>
ffffffffc0201702:	45d1                	li	a1,20
ffffffffc0201704:	00002517          	auipc	a0,0x2
ffffffffc0201708:	9e450513          	addi	a0,a0,-1564 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc020170c:	ca5fe0ef          	jal	ra,ffffffffc02003b0 <__panic>
ffffffffc0201710:	86be                	mv	a3,a5
ffffffffc0201712:	00002617          	auipc	a2,0x2
ffffffffc0201716:	9ae60613          	addi	a2,a2,-1618 # ffffffffc02030c0 <best_fit_pmm_manager+0x160>
ffffffffc020171a:	45d1                	li	a1,20
ffffffffc020171c:	00002517          	auipc	a0,0x2
ffffffffc0201720:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201724:	c8dfe0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0201728 <kmem_cache_create>:
{
ffffffffc0201728:	1101                	addi	sp,sp,-32
ffffffffc020172a:	e04a                	sd	s2,0(sp)
ffffffffc020172c:	892a                	mv	s2,a0
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
ffffffffc020172e:	00006517          	auipc	a0,0x6
ffffffffc0201732:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0207028 <cache_cache>
{
ffffffffc0201736:	e822                	sd	s0,16(sp)
ffffffffc0201738:	e426                	sd	s1,8(sp)
ffffffffc020173a:	ec06                	sd	ra,24(sp)
ffffffffc020173c:	84ae                	mv	s1,a1
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
ffffffffc020173e:	de9ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201742:	842a                	mv	s0,a0
    if (cachep != NULL)
ffffffffc0201744:	c531                	beqz	a0,ffffffffc0201790 <kmem_cache_create+0x68>
        cachep->num = PGSIZE / (sizeof(int16_t) + size); // int16_t是空闲链表指针的大小，size是obj的大小
ffffffffc0201746:	00248713          	addi	a4,s1,2
ffffffffc020174a:	6785                	lui	a5,0x1
ffffffffc020174c:	02e7d7b3          	divu	a5,a5,a4
        cachep->objsize = size;                          // 指定这个slab里面存的obj的大小
ffffffffc0201750:	02951823          	sh	s1,48(a0)
        memcpy(cachep->name, name, CACHE_NAMELEN);
ffffffffc0201754:	02000613          	li	a2,32
ffffffffc0201758:	85ca                	mv	a1,s2
ffffffffc020175a:	03450513          	addi	a0,a0,52
        cachep->num = PGSIZE / (sizeof(int16_t) + size); // int16_t是空闲链表指针的大小，size是obj的大小
ffffffffc020175e:	02f41923          	sh	a5,50(s0)
        memcpy(cachep->name, name, CACHE_NAMELEN);
ffffffffc0201762:	54d000ef          	jal	ra,ffffffffc02024ae <memcpy>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201766:	00006717          	auipc	a4,0x6
ffffffffc020176a:	92a70713          	addi	a4,a4,-1750 # ffffffffc0207090 <cache_chain>
    elm->prev = elm->next = elm;
ffffffffc020176e:	e400                	sd	s0,8(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201770:	6714                	ld	a3,8(a4)
        list_init(&(cachep->slabs_partial));
ffffffffc0201772:	01040593          	addi	a1,s0,16
        list_init(&(cachep->slabs_free));
ffffffffc0201776:	02040613          	addi	a2,s0,32
    elm->prev = elm->next = elm;
ffffffffc020177a:	e000                	sd	s0,0(s0)
        list_add(&(cache_chain), &(cachep->cache_link));
ffffffffc020177c:	05840793          	addi	a5,s0,88
ffffffffc0201780:	ec0c                	sd	a1,24(s0)
ffffffffc0201782:	e80c                	sd	a1,16(s0)
ffffffffc0201784:	f410                	sd	a2,40(s0)
ffffffffc0201786:	f010                	sd	a2,32(s0)
    prev->next = next->prev = elm;
ffffffffc0201788:	e29c                	sd	a5,0(a3)
ffffffffc020178a:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc020178c:	f034                	sd	a3,96(s0)
    elm->prev = prev;
ffffffffc020178e:	ec38                	sd	a4,88(s0)
}
ffffffffc0201790:	60e2                	ld	ra,24(sp)
ffffffffc0201792:	8522                	mv	a0,s0
ffffffffc0201794:	6442                	ld	s0,16(sp)
ffffffffc0201796:	64a2                	ld	s1,8(sp)
ffffffffc0201798:	6902                	ld	s2,0(sp)
ffffffffc020179a:	6105                	addi	sp,sp,32
ffffffffc020179c:	8082                	ret

ffffffffc020179e <kmem_cache_free>:
ffffffffc020179e:	00002697          	auipc	a3,0x2
ffffffffc02017a2:	f326b683          	ld	a3,-206(a3) # ffffffffc02036d0 <nbase>
    return KADDR(page2pa(page));
ffffffffc02017a6:	00c69793          	slli	a5,a3,0xc
ffffffffc02017aa:	00c7d713          	srli	a4,a5,0xc
ffffffffc02017ae:	00006617          	auipc	a2,0x6
ffffffffc02017b2:	d4263603          	ld	a2,-702(a2) # ffffffffc02074f0 <npage>

/* 将对象objp从cachep中的Slab中释放 */
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp)
{
    void *base = page2kva(pages);
ffffffffc02017b6:	00006797          	auipc	a5,0x6
ffffffffc02017ba:	d427b783          	ld	a5,-702(a5) # ffffffffc02074f8 <pages>
    return page2ppn(page) << PGSHIFT;
ffffffffc02017be:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02017c0:	08c77b63          	bgeu	a4,a2,ffffffffc0201856 <kmem_cache_free+0xb8>
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
ffffffffc02017c4:	03255703          	lhu	a4,50(a0)
    void *kva = ROUNDDOWN(objp, PGSIZE);
ffffffffc02017c8:	767d                	lui	a2,0xfffff
    int offset = (objp - buf) / cachep->objsize;
ffffffffc02017ca:	03055803          	lhu	a6,48(a0)
    void *kva = ROUNDDOWN(objp, PGSIZE);
ffffffffc02017ce:	8e6d                	and	a2,a2,a1
    void *buf = bufctl + cachep->num;
ffffffffc02017d0:	0706                	slli	a4,a4,0x1
ffffffffc02017d2:	9732                	add	a4,a4,a2
    int offset = (objp - buf) / cachep->objsize;
ffffffffc02017d4:	8d99                	sub	a1,a1,a4
ffffffffc02017d6:	0305c5b3          	div	a1,a1,a6
    return KADDR(page2pa(page));
ffffffffc02017da:	00006717          	auipc	a4,0x6
ffffffffc02017de:	d3e73703          	ld	a4,-706(a4) # ffffffffc0207518 <va_pa_offset>
ffffffffc02017e2:	96ba                	add	a3,a3,a4
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
ffffffffc02017e4:	40d606b3          	sub	a3,a2,a3
ffffffffc02017e8:	43f6d713          	srai	a4,a3,0x3f
ffffffffc02017ec:	1752                	slli	a4,a4,0x34
ffffffffc02017ee:	9351                	srli	a4,a4,0x34
ffffffffc02017f0:	9736                	add	a4,a4,a3
ffffffffc02017f2:	8731                	srai	a4,a4,0xc
ffffffffc02017f4:	00271693          	slli	a3,a4,0x2
ffffffffc02017f8:	9736                	add	a4,a4,a3
ffffffffc02017fa:	070e                	slli	a4,a4,0x3
ffffffffc02017fc:	97ba                	add	a5,a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc02017fe:	7398                	ld	a4,32(a5)
ffffffffc0201800:	6f94                	ld	a3,24(a5)
    list_del(&(slab->slab_link));
    bufctl[offset] = slab->free;
ffffffffc0201802:	01279883          	lh	a7,18(a5)
    slab->inuse--;
    slab->free = offset;
    if (slab->inuse == 0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
ffffffffc0201806:	01878813          	addi	a6,a5,24
    prev->next = next;
ffffffffc020180a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020180c:	e314                	sd	a3,0(a4)
    bufctl[offset] = slab->free;
ffffffffc020180e:	0005871b          	sext.w	a4,a1
ffffffffc0201812:	0706                	slli	a4,a4,0x1
ffffffffc0201814:	963a                	add	a2,a2,a4
ffffffffc0201816:	01161023          	sh	a7,0(a2) # fffffffffffff000 <end+0x3fdf7ad8>
    slab->inuse--;
ffffffffc020181a:	0107d703          	lhu	a4,16(a5)
    slab->free = offset;
ffffffffc020181e:	00b79923          	sh	a1,18(a5)
    slab->inuse--;
ffffffffc0201822:	377d                	addiw	a4,a4,-1
ffffffffc0201824:	1742                	slli	a4,a4,0x30
ffffffffc0201826:	9341                	srli	a4,a4,0x30
ffffffffc0201828:	00e79823          	sh	a4,16(a5)
    if (slab->inuse == 0)
ffffffffc020182c:	eb19                	bnez	a4,ffffffffc0201842 <kmem_cache_free+0xa4>
    __list_add(elm, listelm, listelm->next);
ffffffffc020182e:	7518                	ld	a4,40(a0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
ffffffffc0201830:	02050693          	addi	a3,a0,32
    prev->next = next->prev = elm;
ffffffffc0201834:	01073023          	sd	a6,0(a4)
ffffffffc0201838:	03053423          	sd	a6,40(a0)
    elm->next = next;
ffffffffc020183c:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc020183e:	ef94                	sd	a3,24(a5)
}
ffffffffc0201840:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0201842:	6d18                	ld	a4,24(a0)
    else
        list_add(&(cachep->slabs_partial), &(slab->slab_link));
ffffffffc0201844:	01050693          	addi	a3,a0,16
    prev->next = next->prev = elm;
ffffffffc0201848:	01073023          	sd	a6,0(a4)
ffffffffc020184c:	01053c23          	sd	a6,24(a0)
    elm->next = next;
ffffffffc0201850:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc0201852:	ef94                	sd	a3,24(a5)
ffffffffc0201854:	8082                	ret
{
ffffffffc0201856:	1141                	addi	sp,sp,-16
    return KADDR(page2pa(page));
ffffffffc0201858:	00002617          	auipc	a2,0x2
ffffffffc020185c:	86860613          	addi	a2,a2,-1944 # ffffffffc02030c0 <best_fit_pmm_manager+0x160>
ffffffffc0201860:	45d1                	li	a1,20
ffffffffc0201862:	00002517          	auipc	a0,0x2
ffffffffc0201866:	88650513          	addi	a0,a0,-1914 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
{
ffffffffc020186a:	e406                	sd	ra,8(sp)
    return KADDR(page2pa(page));
ffffffffc020186c:	b45fe0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0201870 <kmem_cache_destroy>:
{
ffffffffc0201870:	1101                	addi	sp,sp,-32
ffffffffc0201872:	e426                	sd	s1,8(sp)
    return listelm->next;
ffffffffc0201874:	6504                	ld	s1,8(a0)
ffffffffc0201876:	e822                	sd	s0,16(sp)
ffffffffc0201878:	ec06                	sd	ra,24(sp)
ffffffffc020187a:	e04a                	sd	s2,0(sp)
ffffffffc020187c:	842a                	mv	s0,a0
    while (le != head)
ffffffffc020187e:	00950a63          	beq	a0,s1,ffffffffc0201892 <kmem_cache_destroy+0x22>
ffffffffc0201882:	85a6                	mv	a1,s1
ffffffffc0201884:	6484                	ld	s1,8(s1)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc0201886:	15a1                	addi	a1,a1,-24
ffffffffc0201888:	8522                	mv	a0,s0
ffffffffc020188a:	bd5ff0ef          	jal	ra,ffffffffc020145e <kmem_slab_destroy>
    while (le != head)
ffffffffc020188e:	fe941ae3          	bne	s0,s1,ffffffffc0201882 <kmem_cache_destroy+0x12>
ffffffffc0201892:	6c04                	ld	s1,24(s0)
    head = &(cachep->slabs_partial);
ffffffffc0201894:	01040913          	addi	s2,s0,16
    while (le != head)
ffffffffc0201898:	00990a63          	beq	s2,s1,ffffffffc02018ac <kmem_cache_destroy+0x3c>
ffffffffc020189c:	85a6                	mv	a1,s1
ffffffffc020189e:	6484                	ld	s1,8(s1)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc02018a0:	15a1                	addi	a1,a1,-24
ffffffffc02018a2:	8522                	mv	a0,s0
ffffffffc02018a4:	bbbff0ef          	jal	ra,ffffffffc020145e <kmem_slab_destroy>
    while (le != head)
ffffffffc02018a8:	fe991ae3          	bne	s2,s1,ffffffffc020189c <kmem_cache_destroy+0x2c>
ffffffffc02018ac:	7404                	ld	s1,40(s0)
    head = &(cachep->slabs_free);
ffffffffc02018ae:	02040913          	addi	s2,s0,32
    while (le != head)
ffffffffc02018b2:	00990a63          	beq	s2,s1,ffffffffc02018c6 <kmem_cache_destroy+0x56>
ffffffffc02018b6:	85a6                	mv	a1,s1
ffffffffc02018b8:	6484                	ld	s1,8(s1)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc02018ba:	15a1                	addi	a1,a1,-24
ffffffffc02018bc:	8522                	mv	a0,s0
ffffffffc02018be:	ba1ff0ef          	jal	ra,ffffffffc020145e <kmem_slab_destroy>
    while (le != head)
ffffffffc02018c2:	ff249ae3          	bne	s1,s2,ffffffffc02018b6 <kmem_cache_destroy+0x46>
    kmem_cache_free(&(cache_cache), cachep);
ffffffffc02018c6:	85a2                	mv	a1,s0
}
ffffffffc02018c8:	6442                	ld	s0,16(sp)
ffffffffc02018ca:	60e2                	ld	ra,24(sp)
ffffffffc02018cc:	64a2                	ld	s1,8(sp)
ffffffffc02018ce:	6902                	ld	s2,0(sp)
    kmem_cache_free(&(cache_cache), cachep);
ffffffffc02018d0:	00005517          	auipc	a0,0x5
ffffffffc02018d4:	75850513          	addi	a0,a0,1880 # ffffffffc0207028 <cache_cache>
}
ffffffffc02018d8:	6105                	addi	sp,sp,32
    kmem_cache_free(&(cache_cache), cachep);
ffffffffc02018da:	b5d1                	j	ffffffffc020179e <kmem_cache_free>

ffffffffc02018dc <kfree>:
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018dc:	00002697          	auipc	a3,0x2
ffffffffc02018e0:	df46b683          	ld	a3,-524(a3) # ffffffffc02036d0 <nbase>
    return KADDR(page2pa(page));
ffffffffc02018e4:	00c69793          	slli	a5,a3,0xc
ffffffffc02018e8:	83b1                	srli	a5,a5,0xc
ffffffffc02018ea:	00006717          	auipc	a4,0x6
ffffffffc02018ee:	c0673703          	ld	a4,-1018(a4) # ffffffffc02074f0 <npage>
    void *base = slab2kva(pages);
ffffffffc02018f2:	00006617          	auipc	a2,0x6
ffffffffc02018f6:	c0663603          	ld	a2,-1018(a2) # ffffffffc02074f8 <pages>
    return page2ppn(page) << PGSHIFT;
ffffffffc02018fa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02018fc:	02e7f963          	bgeu	a5,a4,ffffffffc020192e <kfree+0x52>
ffffffffc0201900:	00006717          	auipc	a4,0x6
ffffffffc0201904:	c1873703          	ld	a4,-1000(a4) # ffffffffc0207518 <va_pa_offset>
    void *kva = ROUNDDOWN(objp, PGSIZE);
ffffffffc0201908:	77fd                	lui	a5,0xfffff
ffffffffc020190a:	8fe9                	and	a5,a5,a0
    return KADDR(page2pa(page));
ffffffffc020190c:	96ba                	add	a3,a3,a4
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
ffffffffc020190e:	40d786b3          	sub	a3,a5,a3
ffffffffc0201912:	43f6d793          	srai	a5,a3,0x3f
ffffffffc0201916:	17d2                	slli	a5,a5,0x34
ffffffffc0201918:	93d1                	srli	a5,a5,0x34
ffffffffc020191a:	97b6                	add	a5,a5,a3
ffffffffc020191c:	87b1                	srai	a5,a5,0xc
    kmem_cache_free(slab->cachep, objp);
ffffffffc020191e:	00279713          	slli	a4,a5,0x2
ffffffffc0201922:	97ba                	add	a5,a5,a4
ffffffffc0201924:	078e                	slli	a5,a5,0x3
ffffffffc0201926:	97b2                	add	a5,a5,a2
ffffffffc0201928:	85aa                	mv	a1,a0
ffffffffc020192a:	6788                	ld	a0,8(a5)
ffffffffc020192c:	bd8d                	j	ffffffffc020179e <kmem_cache_free>
{
ffffffffc020192e:	1141                	addi	sp,sp,-16
    return KADDR(page2pa(page));
ffffffffc0201930:	00001617          	auipc	a2,0x1
ffffffffc0201934:	79060613          	addi	a2,a2,1936 # ffffffffc02030c0 <best_fit_pmm_manager+0x160>
ffffffffc0201938:	45d1                	li	a1,20
ffffffffc020193a:	00001517          	auipc	a0,0x1
ffffffffc020193e:	7ae50513          	addi	a0,a0,1966 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
{
ffffffffc0201942:	e406                	sd	ra,8(sp)
    return KADDR(page2pa(page));
ffffffffc0201944:	a6dfe0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0201948 <kmem_init>:
    cputs("check_kmem() succeeded, all test passed!\n");
}
// ! 测试部分代码结束

void kmem_init()
{
ffffffffc0201948:	711d                	addi	sp,sp,-96
    // 1. 初始化kmem_cache的cache仓库，简称为cache_cache
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc020194a:	002607b7          	lui	a5,0x260
{
ffffffffc020194e:	e8a2                	sd	s0,80(sp)
ffffffffc0201950:	e4a6                	sd	s1,72(sp)
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc0201952:	00005417          	auipc	s0,0x5
ffffffffc0201956:	6d640413          	addi	s0,s0,1750 # ffffffffc0207028 <cache_cache>
{
ffffffffc020195a:	e0ca                	sd	s2,64(sp)
ffffffffc020195c:	fc4e                	sd	s3,56(sp)
ffffffffc020195e:	f852                	sd	s4,48(sp)
ffffffffc0201960:	f456                	sd	s5,40(sp)
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc0201962:	06878793          	addi	a5,a5,104 # 260068 <kern_entry-0xffffffffbff9ff98>
{
ffffffffc0201966:	ec86                	sd	ra,88(sp)
ffffffffc0201968:	f05a                	sd	s6,32(sp)
ffffffffc020196a:	ec5e                	sd	s7,24(sp)
ffffffffc020196c:	e862                	sd	s8,16(sp)
ffffffffc020196e:	e466                	sd	s9,8(sp)
ffffffffc0201970:	e06a                	sd	s10,0(sp)
    cache_cache.objsize = sizeof(struct kmem_cache_t);
ffffffffc0201972:	d81c                	sw	a5,48(s0)
    cache_cache.num = PGSIZE / (sizeof(int16_t) + sizeof(struct kmem_cache_t)); // 算num的时候还要考虑前面int16_t的信息
    memcpy(cache_cache.name, cache_cache_name, CACHE_NAMELEN);
ffffffffc0201974:	02000613          	li	a2,32
ffffffffc0201978:	00001597          	auipc	a1,0x1
ffffffffc020197c:	7b058593          	addi	a1,a1,1968 # ffffffffc0203128 <best_fit_pmm_manager+0x1c8>
ffffffffc0201980:	00005517          	auipc	a0,0x5
ffffffffc0201984:	6dc50513          	addi	a0,a0,1756 # ffffffffc020705c <cache_cache+0x34>
ffffffffc0201988:	327000ef          	jal	ra,ffffffffc02024ae <memcpy>
    prev->next = next->prev = elm;
ffffffffc020198c:	00005917          	auipc	s2,0x5
ffffffffc0201990:	70490913          	addi	s2,s2,1796 # ffffffffc0207090 <cache_chain>
    elm->prev = elm->next = elm;
ffffffffc0201994:	00005697          	auipc	a3,0x5
ffffffffc0201998:	6a468693          	addi	a3,a3,1700 # ffffffffc0207038 <cache_cache+0x10>
ffffffffc020199c:	00005717          	auipc	a4,0x5
ffffffffc02019a0:	6ac70713          	addi	a4,a4,1708 # ffffffffc0207048 <cache_cache+0x20>
    prev->next = next->prev = elm;
ffffffffc02019a4:	00005797          	auipc	a5,0x5
ffffffffc02019a8:	6dc78793          	addi	a5,a5,1756 # ffffffffc0207080 <cache_cache+0x58>
ffffffffc02019ac:	00005a97          	auipc	s5,0x5
ffffffffc02019b0:	6f4a8a93          	addi	s5,s5,1780 # ffffffffc02070a0 <sized_caches>
    elm->prev = elm->next = elm;
ffffffffc02019b4:	e400                	sd	s0,8(s0)
ffffffffc02019b6:	e000                	sd	s0,0(s0)
ffffffffc02019b8:	ec14                	sd	a3,24(s0)
ffffffffc02019ba:	e814                	sd	a3,16(s0)
ffffffffc02019bc:	f418                	sd	a4,40(s0)
ffffffffc02019be:	f018                	sd	a4,32(s0)
    elm->next = next;
ffffffffc02019c0:	07243023          	sd	s2,96(s0)
    elm->prev = prev;
ffffffffc02019c4:	05243c23          	sd	s2,88(s0)
    prev->next = next->prev = elm;
ffffffffc02019c8:	00f93023          	sd	a5,0(s2)
ffffffffc02019cc:	00f93423          	sd	a5,8(s2)
    list_init(&(cache_chain));
    // 将第一个kmem_cache_t也就是cache_cache加入到cache_chain对应的链表中
    list_add(&(cache_chain), &(cache_cache.cache_link));

    // 2. 初始化8个固定大小的内置仓库
    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2){
ffffffffc02019d0:	84d6                	mv	s1,s5
ffffffffc02019d2:	00005a17          	auipc	s4,0x5
ffffffffc02019d6:	70ea0a13          	addi	s4,s4,1806 # ffffffffc02070e0 <buf>
ffffffffc02019da:	4441                	li	s0,16
        sized_caches[i] = kmem_cache_create(sized_cache_name, size);
ffffffffc02019dc:	00001997          	auipc	s3,0x1
ffffffffc02019e0:	75498993          	addi	s3,s3,1876 # ffffffffc0203130 <best_fit_pmm_manager+0x1d0>
ffffffffc02019e4:	85a2                	mv	a1,s0
ffffffffc02019e6:	854e                	mv	a0,s3
ffffffffc02019e8:	d41ff0ef          	jal	ra,ffffffffc0201728 <kmem_cache_create>
ffffffffc02019ec:	e088                	sd	a0,0(s1)
    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2){
ffffffffc02019ee:	04a1                	addi	s1,s1,8
ffffffffc02019f0:	0014141b          	slliw	s0,s0,0x1
ffffffffc02019f4:	ff4498e3          	bne	s1,s4,ffffffffc02019e4 <kmem_init+0x9c>
    size_t fp = nr_free_pages();
ffffffffc02019f8:	899ff0ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc02019fc:	89aa                	mv	s3,a0
    struct kmem_cache_t *cp0 = kmem_cache_create(test_object_name, sizeof(struct test_object));
ffffffffc02019fe:	40000593          	li	a1,1024
ffffffffc0201a02:	00001517          	auipc	a0,0x1
ffffffffc0201a06:	73650513          	addi	a0,a0,1846 # ffffffffc0203138 <best_fit_pmm_manager+0x1d8>
ffffffffc0201a0a:	d1fff0ef          	jal	ra,ffffffffc0201728 <kmem_cache_create>
ffffffffc0201a0e:	8a2a                	mv	s4,a0
    assert(cp0 != NULL);                                         // 创建成功
ffffffffc0201a10:	3e050563          	beqz	a0,ffffffffc0201dfa <kmem_init+0x4b2>
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));  // 对象大小一致
ffffffffc0201a14:	03055703          	lhu	a4,48(a0)
ffffffffc0201a18:	40000793          	li	a5,1024
ffffffffc0201a1c:	3af71f63          	bne	a4,a5,ffffffffc0201dda <kmem_init+0x492>
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0); // 名字一样
ffffffffc0201a20:	00001597          	auipc	a1,0x1
ffffffffc0201a24:	71858593          	addi	a1,a1,1816 # ffffffffc0203138 <best_fit_pmm_manager+0x1d8>
ffffffffc0201a28:	03450513          	addi	a0,a0,52
ffffffffc0201a2c:	23d000ef          	jal	ra,ffffffffc0202468 <strcmp>
ffffffffc0201a30:	50051563          	bnez	a0,ffffffffc0201f3a <kmem_init+0x5f2>
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201a34:	8552                	mv	a0,s4
ffffffffc0201a36:	af1ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201a3a:	8baa                	mv	s7,a0
ffffffffc0201a3c:	4c050f63          	beqz	a0,ffffffffc0201f1a <kmem_init+0x5d2>
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201a40:	8552                	mv	a0,s4
ffffffffc0201a42:	ae5ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201a46:	8b2a                	mv	s6,a0
ffffffffc0201a48:	4a050963          	beqz	a0,ffffffffc0201efa <kmem_init+0x5b2>
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201a4c:	8552                	mv	a0,s4
ffffffffc0201a4e:	ad9ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201a52:	84aa                	mv	s1,a0
ffffffffc0201a54:	48050363          	beqz	a0,ffffffffc0201eda <kmem_init+0x592>
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201a58:	8552                	mv	a0,s4
ffffffffc0201a5a:	acdff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201a5e:	8c2a                	mv	s8,a0
ffffffffc0201a60:	44050d63          	beqz	a0,ffffffffc0201eba <kmem_init+0x572>
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201a64:	8552                	mv	a0,s4
ffffffffc0201a66:	ac1ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201a6a:	842a                	mv	s0,a0
ffffffffc0201a6c:	2a050763          	beqz	a0,ffffffffc0201d1a <kmem_init+0x3d2>
    assert((p5 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201a70:	8552                	mv	a0,s4
ffffffffc0201a72:	ab5ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201a76:	8caa                	mv	s9,a0
ffffffffc0201a78:	87aa                	mv	a5,a0
ffffffffc0201a7a:	40050693          	addi	a3,a0,1024
ffffffffc0201a7e:	26050e63          	beqz	a0,ffffffffc0201cfa <kmem_init+0x3b2>
        assert(p[i] == DEFAULT_CTVAL);
ffffffffc0201a82:	0007c703          	lbu	a4,0(a5)
ffffffffc0201a86:	20071a63          	bnez	a4,ffffffffc0201c9a <kmem_init+0x352>
    for (int i = 0; i < sizeof(struct test_object); i++)
ffffffffc0201a8a:	0785                	addi	a5,a5,1
ffffffffc0201a8c:	fed79be3          	bne	a5,a3,ffffffffc0201a82 <kmem_init+0x13a>
    assert(nr_free_pages() + 2 == fp);
ffffffffc0201a90:	801ff0ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc0201a94:	00250793          	addi	a5,a0,2
ffffffffc0201a98:	24f99163          	bne	s3,a5,ffffffffc0201cda <kmem_init+0x392>
    return listelm->next;
ffffffffc0201a9c:	008a3783          	ld	a5,8(s4)
    while ((le = list_next(le)) != listelm){
ffffffffc0201aa0:	3efa0d63          	beq	s4,a5,ffffffffc0201e9a <kmem_init+0x552>
    size_t len = 0;
ffffffffc0201aa4:	4701                	li	a4,0
ffffffffc0201aa6:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201aa8:	0705                	addi	a4,a4,1
    while ((le = list_next(le)) != listelm){
ffffffffc0201aaa:	fefa1ee3          	bne	s4,a5,ffffffffc0201aa6 <kmem_init+0x15e>
    assert(list_length(&(cp0->slabs_full)) == 2);
ffffffffc0201aae:	4789                	li	a5,2
ffffffffc0201ab0:	3ef71563          	bne	a4,a5,ffffffffc0201e9a <kmem_init+0x552>
    assert(list_empty(&(cp0->slabs_partial)) == 1);
ffffffffc0201ab4:	018a3703          	ld	a4,24(s4)
ffffffffc0201ab8:	010a0793          	addi	a5,s4,16
ffffffffc0201abc:	3af71f63          	bne	a4,a5,ffffffffc0201e7a <kmem_init+0x532>
    assert(list_empty(&(cp0->slabs_free)) == 1);
ffffffffc0201ac0:	028a3783          	ld	a5,40(s4)
ffffffffc0201ac4:	020a0d13          	addi	s10,s4,32
ffffffffc0201ac8:	38fd1963          	bne	s10,a5,ffffffffc0201e5a <kmem_init+0x512>
    kmem_cache_free(cp0, p3);
ffffffffc0201acc:	85e2                	mv	a1,s8
ffffffffc0201ace:	8552                	mv	a0,s4
ffffffffc0201ad0:	ccfff0ef          	jal	ra,ffffffffc020179e <kmem_cache_free>
    kmem_cache_free(cp0, p4);
ffffffffc0201ad4:	85a2                	mv	a1,s0
ffffffffc0201ad6:	8552                	mv	a0,s4
ffffffffc0201ad8:	cc7ff0ef          	jal	ra,ffffffffc020179e <kmem_cache_free>
    kmem_cache_free(cp0, p5);
ffffffffc0201adc:	85e6                	mv	a1,s9
ffffffffc0201ade:	8552                	mv	a0,s4
ffffffffc0201ae0:	cbfff0ef          	jal	ra,ffffffffc020179e <kmem_cache_free>
ffffffffc0201ae4:	028a3c03          	ld	s8,40(s4)
    while ((le = list_next(le)) != listelm){
ffffffffc0201ae8:	258d0963          	beq	s10,s8,ffffffffc0201d3a <kmem_init+0x3f2>
ffffffffc0201aec:	8ce2                	mv	s9,s8
    size_t len = 0;
ffffffffc0201aee:	4781                	li	a5,0
ffffffffc0201af0:	008cbc83          	ld	s9,8(s9)
        len++;
ffffffffc0201af4:	0785                	addi	a5,a5,1
    while ((le = list_next(le)) != listelm){
ffffffffc0201af6:	ff9d1de3          	bne	s10,s9,ffffffffc0201af0 <kmem_init+0x1a8>
    assert(list_length(&(cp0->slabs_free)) == 1);
ffffffffc0201afa:	4705                	li	a4,1
    int count = 0;
ffffffffc0201afc:	4d01                	li	s10,0
    assert(list_length(&(cp0->slabs_free)) == 1);
ffffffffc0201afe:	22e79e63          	bne	a5,a4,ffffffffc0201d3a <kmem_init+0x3f2>
ffffffffc0201b02:	85e2                	mv	a1,s8
ffffffffc0201b04:	008c3c03          	ld	s8,8(s8)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc0201b08:	15a1                	addi	a1,a1,-24
ffffffffc0201b0a:	8552                	mv	a0,s4
ffffffffc0201b0c:	953ff0ef          	jal	ra,ffffffffc020145e <kmem_slab_destroy>
        count++;
ffffffffc0201b10:	2d05                	addiw	s10,s10,1
    while (le != &(cachep->slabs_free))
ffffffffc0201b12:	ff8c98e3          	bne	s9,s8,ffffffffc0201b02 <kmem_init+0x1ba>
    assert(kmem_cache_shrink(cp0) == 1);    // 一共释放了1个slab
ffffffffc0201b16:	4785                	li	a5,1
ffffffffc0201b18:	12fd1163          	bne	s10,a5,ffffffffc0201c3a <kmem_init+0x2f2>
    assert(nr_free_pages() + 1 == fp);      // 现在多了一个空闲页
ffffffffc0201b1c:	f74ff0ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc0201b20:	00150793          	addi	a5,a0,1
ffffffffc0201b24:	24f99b63          	bne	s3,a5,ffffffffc0201d7a <kmem_init+0x432>
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
ffffffffc0201b28:	028a3783          	ld	a5,40(s4)
ffffffffc0201b2c:	85a2                	mv	a1,s0
ffffffffc0201b2e:	40040693          	addi	a3,s0,1024
        assert(p[i] == DEFAULT_DTVAL);
ffffffffc0201b32:	4705                	li	a4,1
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
ffffffffc0201b34:	28fc9363          	bne	s9,a5,ffffffffc0201dba <kmem_init+0x472>
        assert(p[i] == DEFAULT_DTVAL);
ffffffffc0201b38:	0005c783          	lbu	a5,0(a1)
ffffffffc0201b3c:	16e79f63          	bne	a5,a4,ffffffffc0201cba <kmem_init+0x372>
    for (int i = 0; i < sizeof(struct test_object); i++){
ffffffffc0201b40:	0585                	addi	a1,a1,1
ffffffffc0201b42:	fed59be3          	bne	a1,a3,ffffffffc0201b38 <kmem_init+0x1f0>
    kmem_cache_free(cp0, p0);
ffffffffc0201b46:	85de                	mv	a1,s7
ffffffffc0201b48:	8552                	mv	a0,s4
ffffffffc0201b4a:	c55ff0ef          	jal	ra,ffffffffc020179e <kmem_cache_free>
    kmem_cache_free(cp0, p1);
ffffffffc0201b4e:	85da                	mv	a1,s6
ffffffffc0201b50:	8552                	mv	a0,s4
ffffffffc0201b52:	c4dff0ef          	jal	ra,ffffffffc020179e <kmem_cache_free>
    kmem_cache_free(cp0, p2);
ffffffffc0201b56:	85a6                	mv	a1,s1
ffffffffc0201b58:	8552                	mv	a0,s4
ffffffffc0201b5a:	c45ff0ef          	jal	ra,ffffffffc020179e <kmem_cache_free>
ffffffffc0201b5e:	00893c03          	ld	s8,8(s2)
    int count = 0;
ffffffffc0201b62:	4c81                	li	s9,0
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0201b64:	0f2c0b63          	beq	s8,s2,ffffffffc0201c5a <kmem_init+0x312>
ffffffffc0201b68:	fd0c3403          	ld	s0,-48(s8)
    while (le != &(cachep->slabs_free))
ffffffffc0201b6c:	fc8c0b13          	addi	s6,s8,-56
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc0201b70:	fa8c0b93          	addi	s7,s8,-88
    while (le != &(cachep->slabs_free))
ffffffffc0201b74:	01640e63          	beq	s0,s6,ffffffffc0201b90 <kmem_init+0x248>
    int count = 0;
ffffffffc0201b78:	4481                	li	s1,0
ffffffffc0201b7a:	85a2                	mv	a1,s0
ffffffffc0201b7c:	6400                	ld	s0,8(s0)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc0201b7e:	15a1                	addi	a1,a1,-24
ffffffffc0201b80:	855e                	mv	a0,s7
ffffffffc0201b82:	8ddff0ef          	jal	ra,ffffffffc020145e <kmem_slab_destroy>
        count++;
ffffffffc0201b86:	2485                	addiw	s1,s1,1
    while (le != &(cachep->slabs_free))
ffffffffc0201b88:	ff6419e3          	bne	s0,s6,ffffffffc0201b7a <kmem_init+0x232>
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc0201b8c:	01948cbb          	addw	s9,s1,s9
ffffffffc0201b90:	008c3c03          	ld	s8,8(s8)
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0201b94:	fd2c1ae3          	bne	s8,s2,ffffffffc0201b68 <kmem_init+0x220>
    assert(kmem_cache_reap() == 1);
ffffffffc0201b98:	4785                	li	a5,1
ffffffffc0201b9a:	0cfc9063          	bne	s9,a5,ffffffffc0201c5a <kmem_init+0x312>
    assert(nr_free_pages() == fp);
ffffffffc0201b9e:	ef2ff0ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc0201ba2:	1ea99c63          	bne	s3,a0,ffffffffc0201d9a <kmem_init+0x452>
    kmem_cache_destroy(cp0);
ffffffffc0201ba6:	8552                	mv	a0,s4
ffffffffc0201ba8:	cc9ff0ef          	jal	ra,ffffffffc0201870 <kmem_cache_destroy>
    return kmem_cache_alloc(sized_caches[kmem_sized_index(size)]);
ffffffffc0201bac:	030ab503          	ld	a0,48(s5)
ffffffffc0201bb0:	977ff0ef          	jal	ra,ffffffffc0201526 <kmem_cache_alloc>
ffffffffc0201bb4:	842a                	mv	s0,a0
    assert((p0 = kmalloc(1024)) != NULL);
ffffffffc0201bb6:	28050263          	beqz	a0,ffffffffc0201e3a <kmem_init+0x4f2>
    assert(nr_free_pages() + 1 == fp);
ffffffffc0201bba:	ed6ff0ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc0201bbe:	00150793          	addi	a5,a0,1
ffffffffc0201bc2:	18f99c63          	bne	s3,a5,ffffffffc0201d5a <kmem_init+0x412>
    kfree(p0);
ffffffffc0201bc6:	8522                	mv	a0,s0
ffffffffc0201bc8:	d15ff0ef          	jal	ra,ffffffffc02018dc <kfree>
ffffffffc0201bcc:	00893b03          	ld	s6,8(s2)
    int count = 0;
ffffffffc0201bd0:	4b81                	li	s7,0
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0201bd2:	0b2b0463          	beq	s6,s2,ffffffffc0201c7a <kmem_init+0x332>
ffffffffc0201bd6:	fd0b3403          	ld	s0,-48(s6)
    while (le != &(cachep->slabs_free))
ffffffffc0201bda:	fc8b0a13          	addi	s4,s6,-56
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc0201bde:	fa8b0a93          	addi	s5,s6,-88
    while (le != &(cachep->slabs_free))
ffffffffc0201be2:	01440e63          	beq	s0,s4,ffffffffc0201bfe <kmem_init+0x2b6>
    int count = 0;
ffffffffc0201be6:	4481                	li	s1,0
ffffffffc0201be8:	85a2                	mv	a1,s0
ffffffffc0201bea:	6400                	ld	s0,8(s0)
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
ffffffffc0201bec:	15a1                	addi	a1,a1,-24
ffffffffc0201bee:	8556                	mv	a0,s5
ffffffffc0201bf0:	86fff0ef          	jal	ra,ffffffffc020145e <kmem_slab_destroy>
        count++;
ffffffffc0201bf4:	2485                	addiw	s1,s1,1
    while (le != &(cachep->slabs_free))
ffffffffc0201bf6:	ff4419e3          	bne	s0,s4,ffffffffc0201be8 <kmem_init+0x2a0>
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
ffffffffc0201bfa:	01748bbb          	addw	s7,s1,s7
ffffffffc0201bfe:	008b3b03          	ld	s6,8(s6)
    while ((le = list_next(le)) != &(cache_chain))
ffffffffc0201c02:	fd2b1ae3          	bne	s6,s2,ffffffffc0201bd6 <kmem_init+0x28e>
    assert(kmem_cache_reap() == 1);
ffffffffc0201c06:	4785                	li	a5,1
ffffffffc0201c08:	06fb9963          	bne	s7,a5,ffffffffc0201c7a <kmem_init+0x332>
    assert(nr_free_pages() == fp);
ffffffffc0201c0c:	e84ff0ef          	jal	ra,ffffffffc0201290 <nr_free_pages>
ffffffffc0201c10:	20a99563          	bne	s3,a0,ffffffffc0201e1a <kmem_init+0x4d2>
    }

    // 3. 进行测试
    check_kmem();
ffffffffc0201c14:	6446                	ld	s0,80(sp)
ffffffffc0201c16:	60e6                	ld	ra,88(sp)
ffffffffc0201c18:	64a6                	ld	s1,72(sp)
ffffffffc0201c1a:	6906                	ld	s2,64(sp)
ffffffffc0201c1c:	79e2                	ld	s3,56(sp)
ffffffffc0201c1e:	7a42                	ld	s4,48(sp)
ffffffffc0201c20:	7aa2                	ld	s5,40(sp)
ffffffffc0201c22:	7b02                	ld	s6,32(sp)
ffffffffc0201c24:	6be2                	ld	s7,24(sp)
ffffffffc0201c26:	6c42                	ld	s8,16(sp)
ffffffffc0201c28:	6ca2                	ld	s9,8(sp)
ffffffffc0201c2a:	6d02                	ld	s10,0(sp)
    cputs("check_kmem() succeeded, all test passed!\n");
ffffffffc0201c2c:	00002517          	auipc	a0,0x2
ffffffffc0201c30:	82450513          	addi	a0,a0,-2012 # ffffffffc0203450 <best_fit_pmm_manager+0x4f0>
ffffffffc0201c34:	6125                	addi	sp,sp,96
    cputs("check_kmem() succeeded, all test passed!\n");
ffffffffc0201c36:	cb8fe06f          	j	ffffffffc02000ee <cputs>
    assert(kmem_cache_shrink(cp0) == 1);    // 一共释放了1个slab
ffffffffc0201c3a:	00001697          	auipc	a3,0x1
ffffffffc0201c3e:	74e68693          	addi	a3,a3,1870 # ffffffffc0203388 <best_fit_pmm_manager+0x428>
ffffffffc0201c42:	00001617          	auipc	a2,0x1
ffffffffc0201c46:	fde60613          	addi	a2,a2,-34 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201c4a:	13a00593          	li	a1,314
ffffffffc0201c4e:	00001517          	auipc	a0,0x1
ffffffffc0201c52:	49a50513          	addi	a0,a0,1178 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201c56:	f5afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(kmem_cache_reap() == 1);
ffffffffc0201c5a:	00001697          	auipc	a3,0x1
ffffffffc0201c5e:	7a668693          	addi	a3,a3,1958 # ffffffffc0203400 <best_fit_pmm_manager+0x4a0>
ffffffffc0201c62:	00001617          	auipc	a2,0x1
ffffffffc0201c66:	fbe60613          	addi	a2,a2,-66 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201c6a:	14700593          	li	a1,327
ffffffffc0201c6e:	00001517          	auipc	a0,0x1
ffffffffc0201c72:	47a50513          	addi	a0,a0,1146 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201c76:	f3afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(kmem_cache_reap() == 1);
ffffffffc0201c7a:	00001697          	auipc	a3,0x1
ffffffffc0201c7e:	78668693          	addi	a3,a3,1926 # ffffffffc0203400 <best_fit_pmm_manager+0x4a0>
ffffffffc0201c82:	00001617          	auipc	a2,0x1
ffffffffc0201c86:	f9e60613          	addi	a2,a2,-98 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201c8a:	15400593          	li	a1,340
ffffffffc0201c8e:	00001517          	auipc	a0,0x1
ffffffffc0201c92:	45a50513          	addi	a0,a0,1114 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201c96:	f1afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
        assert(p[i] == DEFAULT_CTVAL);
ffffffffc0201c9a:	00001697          	auipc	a3,0x1
ffffffffc0201c9e:	61668693          	addi	a3,a3,1558 # ffffffffc02032b0 <best_fit_pmm_manager+0x350>
ffffffffc0201ca2:	00001617          	auipc	a2,0x1
ffffffffc0201ca6:	f7e60613          	addi	a2,a2,-130 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201caa:	12b00593          	li	a1,299
ffffffffc0201cae:	00001517          	auipc	a0,0x1
ffffffffc0201cb2:	43a50513          	addi	a0,a0,1082 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201cb6:	efafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
        assert(p[i] == DEFAULT_DTVAL);
ffffffffc0201cba:	00001697          	auipc	a3,0x1
ffffffffc0201cbe:	72e68693          	addi	a3,a3,1838 # ffffffffc02033e8 <best_fit_pmm_manager+0x488>
ffffffffc0201cc2:	00001617          	auipc	a2,0x1
ffffffffc0201cc6:	f5e60613          	addi	a2,a2,-162 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201cca:	14000593          	li	a1,320
ffffffffc0201cce:	00001517          	auipc	a0,0x1
ffffffffc0201cd2:	41a50513          	addi	a0,a0,1050 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201cd6:	edafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free_pages() + 2 == fp);
ffffffffc0201cda:	00001697          	auipc	a3,0x1
ffffffffc0201cde:	5ee68693          	addi	a3,a3,1518 # ffffffffc02032c8 <best_fit_pmm_manager+0x368>
ffffffffc0201ce2:	00001617          	auipc	a2,0x1
ffffffffc0201ce6:	f3e60613          	addi	a2,a2,-194 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201cea:	12e00593          	li	a1,302
ffffffffc0201cee:	00001517          	auipc	a0,0x1
ffffffffc0201cf2:	3fa50513          	addi	a0,a0,1018 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201cf6:	ebafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p5 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201cfa:	00001697          	auipc	a3,0x1
ffffffffc0201cfe:	58e68693          	addi	a3,a3,1422 # ffffffffc0203288 <best_fit_pmm_manager+0x328>
ffffffffc0201d02:	00001617          	auipc	a2,0x1
ffffffffc0201d06:	f1e60613          	addi	a2,a2,-226 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201d0a:	12600593          	li	a1,294
ffffffffc0201d0e:	00001517          	auipc	a0,0x1
ffffffffc0201d12:	3da50513          	addi	a0,a0,986 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201d16:	e9afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201d1a:	00001697          	auipc	a3,0x1
ffffffffc0201d1e:	54668693          	addi	a3,a3,1350 # ffffffffc0203260 <best_fit_pmm_manager+0x300>
ffffffffc0201d22:	00001617          	auipc	a2,0x1
ffffffffc0201d26:	efe60613          	addi	a2,a2,-258 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201d2a:	12500593          	li	a1,293
ffffffffc0201d2e:	00001517          	auipc	a0,0x1
ffffffffc0201d32:	3ba50513          	addi	a0,a0,954 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201d36:	e7afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(list_length(&(cp0->slabs_free)) == 1);
ffffffffc0201d3a:	00001697          	auipc	a3,0x1
ffffffffc0201d3e:	62668693          	addi	a3,a3,1574 # ffffffffc0203360 <best_fit_pmm_manager+0x400>
ffffffffc0201d42:	00001617          	auipc	a2,0x1
ffffffffc0201d46:	ede60613          	addi	a2,a2,-290 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201d4a:	13800593          	li	a1,312
ffffffffc0201d4e:	00001517          	auipc	a0,0x1
ffffffffc0201d52:	39a50513          	addi	a0,a0,922 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201d56:	e5afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free_pages() + 1 == fp);
ffffffffc0201d5a:	00001697          	auipc	a3,0x1
ffffffffc0201d5e:	64e68693          	addi	a3,a3,1614 # ffffffffc02033a8 <best_fit_pmm_manager+0x448>
ffffffffc0201d62:	00001617          	auipc	a2,0x1
ffffffffc0201d66:	ebe60613          	addi	a2,a2,-322 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201d6a:	15000593          	li	a1,336
ffffffffc0201d6e:	00001517          	auipc	a0,0x1
ffffffffc0201d72:	37a50513          	addi	a0,a0,890 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201d76:	e3afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free_pages() + 1 == fp);      // 现在多了一个空闲页
ffffffffc0201d7a:	00001697          	auipc	a3,0x1
ffffffffc0201d7e:	62e68693          	addi	a3,a3,1582 # ffffffffc02033a8 <best_fit_pmm_manager+0x448>
ffffffffc0201d82:	00001617          	auipc	a2,0x1
ffffffffc0201d86:	e9e60613          	addi	a2,a2,-354 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201d8a:	13b00593          	li	a1,315
ffffffffc0201d8e:	00001517          	auipc	a0,0x1
ffffffffc0201d92:	35a50513          	addi	a0,a0,858 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201d96:	e1afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free_pages() == fp);
ffffffffc0201d9a:	00001697          	auipc	a3,0x1
ffffffffc0201d9e:	67e68693          	addi	a3,a3,1662 # ffffffffc0203418 <best_fit_pmm_manager+0x4b8>
ffffffffc0201da2:	00001617          	auipc	a2,0x1
ffffffffc0201da6:	e7e60613          	addi	a2,a2,-386 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201daa:	14900593          	li	a1,329
ffffffffc0201dae:	00001517          	auipc	a0,0x1
ffffffffc0201db2:	33a50513          	addi	a0,a0,826 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201db6:	dfafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
ffffffffc0201dba:	00001697          	auipc	a3,0x1
ffffffffc0201dbe:	60e68693          	addi	a3,a3,1550 # ffffffffc02033c8 <best_fit_pmm_manager+0x468>
ffffffffc0201dc2:	00001617          	auipc	a2,0x1
ffffffffc0201dc6:	e5e60613          	addi	a2,a2,-418 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201dca:	13c00593          	li	a1,316
ffffffffc0201dce:	00001517          	auipc	a0,0x1
ffffffffc0201dd2:	31a50513          	addi	a0,a0,794 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201dd6:	ddafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));  // 对象大小一致
ffffffffc0201dda:	00001697          	auipc	a3,0x1
ffffffffc0201dde:	37668693          	addi	a3,a3,886 # ffffffffc0203150 <best_fit_pmm_manager+0x1f0>
ffffffffc0201de2:	00001617          	auipc	a2,0x1
ffffffffc0201de6:	e3e60613          	addi	a2,a2,-450 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201dea:	11c00593          	li	a1,284
ffffffffc0201dee:	00001517          	auipc	a0,0x1
ffffffffc0201df2:	2fa50513          	addi	a0,a0,762 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201df6:	dbafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(cp0 != NULL);                                         // 创建成功
ffffffffc0201dfa:	00001697          	auipc	a3,0x1
ffffffffc0201dfe:	34668693          	addi	a3,a3,838 # ffffffffc0203140 <best_fit_pmm_manager+0x1e0>
ffffffffc0201e02:	00001617          	auipc	a2,0x1
ffffffffc0201e06:	e1e60613          	addi	a2,a2,-482 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201e0a:	11b00593          	li	a1,283
ffffffffc0201e0e:	00001517          	auipc	a0,0x1
ffffffffc0201e12:	2da50513          	addi	a0,a0,730 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201e16:	d9afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(nr_free_pages() == fp);
ffffffffc0201e1a:	00001697          	auipc	a3,0x1
ffffffffc0201e1e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0203418 <best_fit_pmm_manager+0x4b8>
ffffffffc0201e22:	00001617          	auipc	a2,0x1
ffffffffc0201e26:	dfe60613          	addi	a2,a2,-514 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201e2a:	15600593          	li	a1,342
ffffffffc0201e2e:	00001517          	auipc	a0,0x1
ffffffffc0201e32:	2ba50513          	addi	a0,a0,698 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201e36:	d7afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p0 = kmalloc(1024)) != NULL);
ffffffffc0201e3a:	00001697          	auipc	a3,0x1
ffffffffc0201e3e:	5f668693          	addi	a3,a3,1526 # ffffffffc0203430 <best_fit_pmm_manager+0x4d0>
ffffffffc0201e42:	00001617          	auipc	a2,0x1
ffffffffc0201e46:	dde60613          	addi	a2,a2,-546 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201e4a:	14e00593          	li	a1,334
ffffffffc0201e4e:	00001517          	auipc	a0,0x1
ffffffffc0201e52:	29a50513          	addi	a0,a0,666 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201e56:	d5afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(list_empty(&(cp0->slabs_free)) == 1);
ffffffffc0201e5a:	00001697          	auipc	a3,0x1
ffffffffc0201e5e:	4de68693          	addi	a3,a3,1246 # ffffffffc0203338 <best_fit_pmm_manager+0x3d8>
ffffffffc0201e62:	00001617          	auipc	a2,0x1
ffffffffc0201e66:	dbe60613          	addi	a2,a2,-578 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201e6a:	13300593          	li	a1,307
ffffffffc0201e6e:	00001517          	auipc	a0,0x1
ffffffffc0201e72:	27a50513          	addi	a0,a0,634 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201e76:	d3afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(list_empty(&(cp0->slabs_partial)) == 1);
ffffffffc0201e7a:	00001697          	auipc	a3,0x1
ffffffffc0201e7e:	49668693          	addi	a3,a3,1174 # ffffffffc0203310 <best_fit_pmm_manager+0x3b0>
ffffffffc0201e82:	00001617          	auipc	a2,0x1
ffffffffc0201e86:	d9e60613          	addi	a2,a2,-610 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201e8a:	13200593          	li	a1,306
ffffffffc0201e8e:	00001517          	auipc	a0,0x1
ffffffffc0201e92:	25a50513          	addi	a0,a0,602 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201e96:	d1afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(list_length(&(cp0->slabs_full)) == 2);
ffffffffc0201e9a:	00001697          	auipc	a3,0x1
ffffffffc0201e9e:	44e68693          	addi	a3,a3,1102 # ffffffffc02032e8 <best_fit_pmm_manager+0x388>
ffffffffc0201ea2:	00001617          	auipc	a2,0x1
ffffffffc0201ea6:	d7e60613          	addi	a2,a2,-642 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201eaa:	13000593          	li	a1,304
ffffffffc0201eae:	00001517          	auipc	a0,0x1
ffffffffc0201eb2:	23a50513          	addi	a0,a0,570 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201eb6:	cfafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201eba:	00001697          	auipc	a3,0x1
ffffffffc0201ebe:	37e68693          	addi	a3,a3,894 # ffffffffc0203238 <best_fit_pmm_manager+0x2d8>
ffffffffc0201ec2:	00001617          	auipc	a2,0x1
ffffffffc0201ec6:	d5e60613          	addi	a2,a2,-674 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201eca:	12400593          	li	a1,292
ffffffffc0201ece:	00001517          	auipc	a0,0x1
ffffffffc0201ed2:	21a50513          	addi	a0,a0,538 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201ed6:	cdafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201eda:	00001697          	auipc	a3,0x1
ffffffffc0201ede:	33668693          	addi	a3,a3,822 # ffffffffc0203210 <best_fit_pmm_manager+0x2b0>
ffffffffc0201ee2:	00001617          	auipc	a2,0x1
ffffffffc0201ee6:	d3e60613          	addi	a2,a2,-706 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201eea:	12300593          	li	a1,291
ffffffffc0201eee:	00001517          	auipc	a0,0x1
ffffffffc0201ef2:	1fa50513          	addi	a0,a0,506 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201ef6:	cbafe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201efa:	00001697          	auipc	a3,0x1
ffffffffc0201efe:	2ee68693          	addi	a3,a3,750 # ffffffffc02031e8 <best_fit_pmm_manager+0x288>
ffffffffc0201f02:	00001617          	auipc	a2,0x1
ffffffffc0201f06:	d1e60613          	addi	a2,a2,-738 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201f0a:	12200593          	li	a1,290
ffffffffc0201f0e:	00001517          	auipc	a0,0x1
ffffffffc0201f12:	1da50513          	addi	a0,a0,474 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201f16:	c9afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
ffffffffc0201f1a:	00001697          	auipc	a3,0x1
ffffffffc0201f1e:	2a668693          	addi	a3,a3,678 # ffffffffc02031c0 <best_fit_pmm_manager+0x260>
ffffffffc0201f22:	00001617          	auipc	a2,0x1
ffffffffc0201f26:	cfe60613          	addi	a2,a2,-770 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201f2a:	12100593          	li	a1,289
ffffffffc0201f2e:	00001517          	auipc	a0,0x1
ffffffffc0201f32:	1ba50513          	addi	a0,a0,442 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201f36:	c7afe0ef          	jal	ra,ffffffffc02003b0 <__panic>
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0); // 名字一样
ffffffffc0201f3a:	00001697          	auipc	a3,0x1
ffffffffc0201f3e:	24e68693          	addi	a3,a3,590 # ffffffffc0203188 <best_fit_pmm_manager+0x228>
ffffffffc0201f42:	00001617          	auipc	a2,0x1
ffffffffc0201f46:	cde60613          	addi	a2,a2,-802 # ffffffffc0202c20 <commands+0x500>
ffffffffc0201f4a:	11d00593          	li	a1,285
ffffffffc0201f4e:	00001517          	auipc	a0,0x1
ffffffffc0201f52:	19a50513          	addi	a0,a0,410 # ffffffffc02030e8 <best_fit_pmm_manager+0x188>
ffffffffc0201f56:	c5afe0ef          	jal	ra,ffffffffc02003b0 <__panic>

ffffffffc0201f5a <printnum>:
ffffffffc0201f5a:	02069813          	slli	a6,a3,0x20
ffffffffc0201f5e:	7179                	addi	sp,sp,-48
ffffffffc0201f60:	02085813          	srli	a6,a6,0x20
ffffffffc0201f64:	e052                	sd	s4,0(sp)
ffffffffc0201f66:	03067a33          	remu	s4,a2,a6
ffffffffc0201f6a:	f022                	sd	s0,32(sp)
ffffffffc0201f6c:	ec26                	sd	s1,24(sp)
ffffffffc0201f6e:	e84a                	sd	s2,16(sp)
ffffffffc0201f70:	f406                	sd	ra,40(sp)
ffffffffc0201f72:	e44e                	sd	s3,8(sp)
ffffffffc0201f74:	84aa                	mv	s1,a0
ffffffffc0201f76:	892e                	mv	s2,a1
ffffffffc0201f78:	fff7041b          	addiw	s0,a4,-1
ffffffffc0201f7c:	2a01                	sext.w	s4,s4
ffffffffc0201f7e:	03067e63          	bgeu	a2,a6,ffffffffc0201fba <printnum+0x60>
ffffffffc0201f82:	89be                	mv	s3,a5
ffffffffc0201f84:	00805763          	blez	s0,ffffffffc0201f92 <printnum+0x38>
ffffffffc0201f88:	347d                	addiw	s0,s0,-1
ffffffffc0201f8a:	85ca                	mv	a1,s2
ffffffffc0201f8c:	854e                	mv	a0,s3
ffffffffc0201f8e:	9482                	jalr	s1
ffffffffc0201f90:	fc65                	bnez	s0,ffffffffc0201f88 <printnum+0x2e>
ffffffffc0201f92:	1a02                	slli	s4,s4,0x20
ffffffffc0201f94:	00001797          	auipc	a5,0x1
ffffffffc0201f98:	4ec78793          	addi	a5,a5,1260 # ffffffffc0203480 <best_fit_pmm_manager+0x520>
ffffffffc0201f9c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201fa0:	9a3e                	add	s4,s4,a5
ffffffffc0201fa2:	7402                	ld	s0,32(sp)
ffffffffc0201fa4:	000a4503          	lbu	a0,0(s4)
ffffffffc0201fa8:	70a2                	ld	ra,40(sp)
ffffffffc0201faa:	69a2                	ld	s3,8(sp)
ffffffffc0201fac:	6a02                	ld	s4,0(sp)
ffffffffc0201fae:	85ca                	mv	a1,s2
ffffffffc0201fb0:	87a6                	mv	a5,s1
ffffffffc0201fb2:	6942                	ld	s2,16(sp)
ffffffffc0201fb4:	64e2                	ld	s1,24(sp)
ffffffffc0201fb6:	6145                	addi	sp,sp,48
ffffffffc0201fb8:	8782                	jr	a5
ffffffffc0201fba:	03065633          	divu	a2,a2,a6
ffffffffc0201fbe:	8722                	mv	a4,s0
ffffffffc0201fc0:	f9bff0ef          	jal	ra,ffffffffc0201f5a <printnum>
ffffffffc0201fc4:	b7f9                	j	ffffffffc0201f92 <printnum+0x38>

ffffffffc0201fc6 <vprintfmt>:
ffffffffc0201fc6:	7119                	addi	sp,sp,-128
ffffffffc0201fc8:	f4a6                	sd	s1,104(sp)
ffffffffc0201fca:	f0ca                	sd	s2,96(sp)
ffffffffc0201fcc:	ecce                	sd	s3,88(sp)
ffffffffc0201fce:	e8d2                	sd	s4,80(sp)
ffffffffc0201fd0:	e4d6                	sd	s5,72(sp)
ffffffffc0201fd2:	e0da                	sd	s6,64(sp)
ffffffffc0201fd4:	fc5e                	sd	s7,56(sp)
ffffffffc0201fd6:	f06a                	sd	s10,32(sp)
ffffffffc0201fd8:	fc86                	sd	ra,120(sp)
ffffffffc0201fda:	f8a2                	sd	s0,112(sp)
ffffffffc0201fdc:	f862                	sd	s8,48(sp)
ffffffffc0201fde:	f466                	sd	s9,40(sp)
ffffffffc0201fe0:	ec6e                	sd	s11,24(sp)
ffffffffc0201fe2:	892a                	mv	s2,a0
ffffffffc0201fe4:	84ae                	mv	s1,a1
ffffffffc0201fe6:	8d32                	mv	s10,a2
ffffffffc0201fe8:	8a36                	mv	s4,a3
ffffffffc0201fea:	02500993          	li	s3,37
ffffffffc0201fee:	5b7d                	li	s6,-1
ffffffffc0201ff0:	00001a97          	auipc	s5,0x1
ffffffffc0201ff4:	4c4a8a93          	addi	s5,s5,1220 # ffffffffc02034b4 <best_fit_pmm_manager+0x554>
ffffffffc0201ff8:	00001b97          	auipc	s7,0x1
ffffffffc0201ffc:	698b8b93          	addi	s7,s7,1688 # ffffffffc0203690 <error_string>
ffffffffc0202000:	000d4503          	lbu	a0,0(s10)
ffffffffc0202004:	001d0413          	addi	s0,s10,1
ffffffffc0202008:	01350a63          	beq	a0,s3,ffffffffc020201c <vprintfmt+0x56>
ffffffffc020200c:	c121                	beqz	a0,ffffffffc020204c <vprintfmt+0x86>
ffffffffc020200e:	85a6                	mv	a1,s1
ffffffffc0202010:	0405                	addi	s0,s0,1
ffffffffc0202012:	9902                	jalr	s2
ffffffffc0202014:	fff44503          	lbu	a0,-1(s0)
ffffffffc0202018:	ff351ae3          	bne	a0,s3,ffffffffc020200c <vprintfmt+0x46>
ffffffffc020201c:	00044603          	lbu	a2,0(s0)
ffffffffc0202020:	02000793          	li	a5,32
ffffffffc0202024:	4c81                	li	s9,0
ffffffffc0202026:	4881                	li	a7,0
ffffffffc0202028:	5c7d                	li	s8,-1
ffffffffc020202a:	5dfd                	li	s11,-1
ffffffffc020202c:	05500513          	li	a0,85
ffffffffc0202030:	4825                	li	a6,9
ffffffffc0202032:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0202036:	0ff5f593          	zext.b	a1,a1
ffffffffc020203a:	00140d13          	addi	s10,s0,1
ffffffffc020203e:	04b56263          	bltu	a0,a1,ffffffffc0202082 <vprintfmt+0xbc>
ffffffffc0202042:	058a                	slli	a1,a1,0x2
ffffffffc0202044:	95d6                	add	a1,a1,s5
ffffffffc0202046:	4194                	lw	a3,0(a1)
ffffffffc0202048:	96d6                	add	a3,a3,s5
ffffffffc020204a:	8682                	jr	a3
ffffffffc020204c:	70e6                	ld	ra,120(sp)
ffffffffc020204e:	7446                	ld	s0,112(sp)
ffffffffc0202050:	74a6                	ld	s1,104(sp)
ffffffffc0202052:	7906                	ld	s2,96(sp)
ffffffffc0202054:	69e6                	ld	s3,88(sp)
ffffffffc0202056:	6a46                	ld	s4,80(sp)
ffffffffc0202058:	6aa6                	ld	s5,72(sp)
ffffffffc020205a:	6b06                	ld	s6,64(sp)
ffffffffc020205c:	7be2                	ld	s7,56(sp)
ffffffffc020205e:	7c42                	ld	s8,48(sp)
ffffffffc0202060:	7ca2                	ld	s9,40(sp)
ffffffffc0202062:	7d02                	ld	s10,32(sp)
ffffffffc0202064:	6de2                	ld	s11,24(sp)
ffffffffc0202066:	6109                	addi	sp,sp,128
ffffffffc0202068:	8082                	ret
ffffffffc020206a:	87b2                	mv	a5,a2
ffffffffc020206c:	00144603          	lbu	a2,1(s0)
ffffffffc0202070:	846a                	mv	s0,s10
ffffffffc0202072:	00140d13          	addi	s10,s0,1
ffffffffc0202076:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020207a:	0ff5f593          	zext.b	a1,a1
ffffffffc020207e:	fcb572e3          	bgeu	a0,a1,ffffffffc0202042 <vprintfmt+0x7c>
ffffffffc0202082:	85a6                	mv	a1,s1
ffffffffc0202084:	02500513          	li	a0,37
ffffffffc0202088:	9902                	jalr	s2
ffffffffc020208a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020208e:	8d22                	mv	s10,s0
ffffffffc0202090:	f73788e3          	beq	a5,s3,ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc0202094:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0202098:	1d7d                	addi	s10,s10,-1
ffffffffc020209a:	ff379de3          	bne	a5,s3,ffffffffc0202094 <vprintfmt+0xce>
ffffffffc020209e:	b78d                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc02020a0:	fd060c1b          	addiw	s8,a2,-48
ffffffffc02020a4:	00144603          	lbu	a2,1(s0)
ffffffffc02020a8:	846a                	mv	s0,s10
ffffffffc02020aa:	fd06069b          	addiw	a3,a2,-48
ffffffffc02020ae:	0006059b          	sext.w	a1,a2
ffffffffc02020b2:	02d86463          	bltu	a6,a3,ffffffffc02020da <vprintfmt+0x114>
ffffffffc02020b6:	00144603          	lbu	a2,1(s0)
ffffffffc02020ba:	002c169b          	slliw	a3,s8,0x2
ffffffffc02020be:	0186873b          	addw	a4,a3,s8
ffffffffc02020c2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02020c6:	9f2d                	addw	a4,a4,a1
ffffffffc02020c8:	fd06069b          	addiw	a3,a2,-48
ffffffffc02020cc:	0405                	addi	s0,s0,1
ffffffffc02020ce:	fd070c1b          	addiw	s8,a4,-48
ffffffffc02020d2:	0006059b          	sext.w	a1,a2
ffffffffc02020d6:	fed870e3          	bgeu	a6,a3,ffffffffc02020b6 <vprintfmt+0xf0>
ffffffffc02020da:	f40ddce3          	bgez	s11,ffffffffc0202032 <vprintfmt+0x6c>
ffffffffc02020de:	8de2                	mv	s11,s8
ffffffffc02020e0:	5c7d                	li	s8,-1
ffffffffc02020e2:	bf81                	j	ffffffffc0202032 <vprintfmt+0x6c>
ffffffffc02020e4:	fffdc693          	not	a3,s11
ffffffffc02020e8:	96fd                	srai	a3,a3,0x3f
ffffffffc02020ea:	00ddfdb3          	and	s11,s11,a3
ffffffffc02020ee:	00144603          	lbu	a2,1(s0)
ffffffffc02020f2:	2d81                	sext.w	s11,s11
ffffffffc02020f4:	846a                	mv	s0,s10
ffffffffc02020f6:	bf35                	j	ffffffffc0202032 <vprintfmt+0x6c>
ffffffffc02020f8:	000a2c03          	lw	s8,0(s4)
ffffffffc02020fc:	00144603          	lbu	a2,1(s0)
ffffffffc0202100:	0a21                	addi	s4,s4,8
ffffffffc0202102:	846a                	mv	s0,s10
ffffffffc0202104:	bfd9                	j	ffffffffc02020da <vprintfmt+0x114>
ffffffffc0202106:	4705                	li	a4,1
ffffffffc0202108:	008a0593          	addi	a1,s4,8
ffffffffc020210c:	01174463          	blt	a4,a7,ffffffffc0202114 <vprintfmt+0x14e>
ffffffffc0202110:	1a088e63          	beqz	a7,ffffffffc02022cc <vprintfmt+0x306>
ffffffffc0202114:	000a3603          	ld	a2,0(s4)
ffffffffc0202118:	46c1                	li	a3,16
ffffffffc020211a:	8a2e                	mv	s4,a1
ffffffffc020211c:	2781                	sext.w	a5,a5
ffffffffc020211e:	876e                	mv	a4,s11
ffffffffc0202120:	85a6                	mv	a1,s1
ffffffffc0202122:	854a                	mv	a0,s2
ffffffffc0202124:	e37ff0ef          	jal	ra,ffffffffc0201f5a <printnum>
ffffffffc0202128:	bde1                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc020212a:	000a2503          	lw	a0,0(s4)
ffffffffc020212e:	85a6                	mv	a1,s1
ffffffffc0202130:	0a21                	addi	s4,s4,8
ffffffffc0202132:	9902                	jalr	s2
ffffffffc0202134:	b5f1                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc0202136:	4705                	li	a4,1
ffffffffc0202138:	008a0593          	addi	a1,s4,8
ffffffffc020213c:	01174463          	blt	a4,a7,ffffffffc0202144 <vprintfmt+0x17e>
ffffffffc0202140:	18088163          	beqz	a7,ffffffffc02022c2 <vprintfmt+0x2fc>
ffffffffc0202144:	000a3603          	ld	a2,0(s4)
ffffffffc0202148:	46a9                	li	a3,10
ffffffffc020214a:	8a2e                	mv	s4,a1
ffffffffc020214c:	bfc1                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc020214e:	00144603          	lbu	a2,1(s0)
ffffffffc0202152:	4c85                	li	s9,1
ffffffffc0202154:	846a                	mv	s0,s10
ffffffffc0202156:	bdf1                	j	ffffffffc0202032 <vprintfmt+0x6c>
ffffffffc0202158:	85a6                	mv	a1,s1
ffffffffc020215a:	02500513          	li	a0,37
ffffffffc020215e:	9902                	jalr	s2
ffffffffc0202160:	b545                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc0202162:	00144603          	lbu	a2,1(s0)
ffffffffc0202166:	2885                	addiw	a7,a7,1
ffffffffc0202168:	846a                	mv	s0,s10
ffffffffc020216a:	b5e1                	j	ffffffffc0202032 <vprintfmt+0x6c>
ffffffffc020216c:	4705                	li	a4,1
ffffffffc020216e:	008a0593          	addi	a1,s4,8
ffffffffc0202172:	01174463          	blt	a4,a7,ffffffffc020217a <vprintfmt+0x1b4>
ffffffffc0202176:	14088163          	beqz	a7,ffffffffc02022b8 <vprintfmt+0x2f2>
ffffffffc020217a:	000a3603          	ld	a2,0(s4)
ffffffffc020217e:	46a1                	li	a3,8
ffffffffc0202180:	8a2e                	mv	s4,a1
ffffffffc0202182:	bf69                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc0202184:	03000513          	li	a0,48
ffffffffc0202188:	85a6                	mv	a1,s1
ffffffffc020218a:	e03e                	sd	a5,0(sp)
ffffffffc020218c:	9902                	jalr	s2
ffffffffc020218e:	85a6                	mv	a1,s1
ffffffffc0202190:	07800513          	li	a0,120
ffffffffc0202194:	9902                	jalr	s2
ffffffffc0202196:	0a21                	addi	s4,s4,8
ffffffffc0202198:	6782                	ld	a5,0(sp)
ffffffffc020219a:	46c1                	li	a3,16
ffffffffc020219c:	ff8a3603          	ld	a2,-8(s4)
ffffffffc02021a0:	bfb5                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc02021a2:	000a3403          	ld	s0,0(s4)
ffffffffc02021a6:	008a0713          	addi	a4,s4,8
ffffffffc02021aa:	e03a                	sd	a4,0(sp)
ffffffffc02021ac:	14040263          	beqz	s0,ffffffffc02022f0 <vprintfmt+0x32a>
ffffffffc02021b0:	0fb05763          	blez	s11,ffffffffc020229e <vprintfmt+0x2d8>
ffffffffc02021b4:	02d00693          	li	a3,45
ffffffffc02021b8:	0cd79163          	bne	a5,a3,ffffffffc020227a <vprintfmt+0x2b4>
ffffffffc02021bc:	00044783          	lbu	a5,0(s0)
ffffffffc02021c0:	0007851b          	sext.w	a0,a5
ffffffffc02021c4:	cf85                	beqz	a5,ffffffffc02021fc <vprintfmt+0x236>
ffffffffc02021c6:	00140a13          	addi	s4,s0,1
ffffffffc02021ca:	05e00413          	li	s0,94
ffffffffc02021ce:	000c4563          	bltz	s8,ffffffffc02021d8 <vprintfmt+0x212>
ffffffffc02021d2:	3c7d                	addiw	s8,s8,-1
ffffffffc02021d4:	036c0263          	beq	s8,s6,ffffffffc02021f8 <vprintfmt+0x232>
ffffffffc02021d8:	85a6                	mv	a1,s1
ffffffffc02021da:	0e0c8e63          	beqz	s9,ffffffffc02022d6 <vprintfmt+0x310>
ffffffffc02021de:	3781                	addiw	a5,a5,-32
ffffffffc02021e0:	0ef47b63          	bgeu	s0,a5,ffffffffc02022d6 <vprintfmt+0x310>
ffffffffc02021e4:	03f00513          	li	a0,63
ffffffffc02021e8:	9902                	jalr	s2
ffffffffc02021ea:	000a4783          	lbu	a5,0(s4)
ffffffffc02021ee:	3dfd                	addiw	s11,s11,-1
ffffffffc02021f0:	0a05                	addi	s4,s4,1
ffffffffc02021f2:	0007851b          	sext.w	a0,a5
ffffffffc02021f6:	ffe1                	bnez	a5,ffffffffc02021ce <vprintfmt+0x208>
ffffffffc02021f8:	01b05963          	blez	s11,ffffffffc020220a <vprintfmt+0x244>
ffffffffc02021fc:	3dfd                	addiw	s11,s11,-1
ffffffffc02021fe:	85a6                	mv	a1,s1
ffffffffc0202200:	02000513          	li	a0,32
ffffffffc0202204:	9902                	jalr	s2
ffffffffc0202206:	fe0d9be3          	bnez	s11,ffffffffc02021fc <vprintfmt+0x236>
ffffffffc020220a:	6a02                	ld	s4,0(sp)
ffffffffc020220c:	bbd5                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc020220e:	4705                	li	a4,1
ffffffffc0202210:	008a0c93          	addi	s9,s4,8
ffffffffc0202214:	01174463          	blt	a4,a7,ffffffffc020221c <vprintfmt+0x256>
ffffffffc0202218:	08088d63          	beqz	a7,ffffffffc02022b2 <vprintfmt+0x2ec>
ffffffffc020221c:	000a3403          	ld	s0,0(s4)
ffffffffc0202220:	0a044d63          	bltz	s0,ffffffffc02022da <vprintfmt+0x314>
ffffffffc0202224:	8622                	mv	a2,s0
ffffffffc0202226:	8a66                	mv	s4,s9
ffffffffc0202228:	46a9                	li	a3,10
ffffffffc020222a:	bdcd                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc020222c:	000a2783          	lw	a5,0(s4)
ffffffffc0202230:	4719                	li	a4,6
ffffffffc0202232:	0a21                	addi	s4,s4,8
ffffffffc0202234:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0202238:	8fb5                	xor	a5,a5,a3
ffffffffc020223a:	40d786bb          	subw	a3,a5,a3
ffffffffc020223e:	02d74163          	blt	a4,a3,ffffffffc0202260 <vprintfmt+0x29a>
ffffffffc0202242:	00369793          	slli	a5,a3,0x3
ffffffffc0202246:	97de                	add	a5,a5,s7
ffffffffc0202248:	639c                	ld	a5,0(a5)
ffffffffc020224a:	cb99                	beqz	a5,ffffffffc0202260 <vprintfmt+0x29a>
ffffffffc020224c:	86be                	mv	a3,a5
ffffffffc020224e:	00001617          	auipc	a2,0x1
ffffffffc0202252:	26260613          	addi	a2,a2,610 # ffffffffc02034b0 <best_fit_pmm_manager+0x550>
ffffffffc0202256:	85a6                	mv	a1,s1
ffffffffc0202258:	854a                	mv	a0,s2
ffffffffc020225a:	0ce000ef          	jal	ra,ffffffffc0202328 <printfmt>
ffffffffc020225e:	b34d                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc0202260:	00001617          	auipc	a2,0x1
ffffffffc0202264:	24060613          	addi	a2,a2,576 # ffffffffc02034a0 <best_fit_pmm_manager+0x540>
ffffffffc0202268:	85a6                	mv	a1,s1
ffffffffc020226a:	854a                	mv	a0,s2
ffffffffc020226c:	0bc000ef          	jal	ra,ffffffffc0202328 <printfmt>
ffffffffc0202270:	bb41                	j	ffffffffc0202000 <vprintfmt+0x3a>
ffffffffc0202272:	00001417          	auipc	s0,0x1
ffffffffc0202276:	22640413          	addi	s0,s0,550 # ffffffffc0203498 <best_fit_pmm_manager+0x538>
ffffffffc020227a:	85e2                	mv	a1,s8
ffffffffc020227c:	8522                	mv	a0,s0
ffffffffc020227e:	e43e                	sd	a5,8(sp)
ffffffffc0202280:	1cc000ef          	jal	ra,ffffffffc020244c <strnlen>
ffffffffc0202284:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0202288:	01b05b63          	blez	s11,ffffffffc020229e <vprintfmt+0x2d8>
ffffffffc020228c:	67a2                	ld	a5,8(sp)
ffffffffc020228e:	00078a1b          	sext.w	s4,a5
ffffffffc0202292:	3dfd                	addiw	s11,s11,-1
ffffffffc0202294:	85a6                	mv	a1,s1
ffffffffc0202296:	8552                	mv	a0,s4
ffffffffc0202298:	9902                	jalr	s2
ffffffffc020229a:	fe0d9ce3          	bnez	s11,ffffffffc0202292 <vprintfmt+0x2cc>
ffffffffc020229e:	00044783          	lbu	a5,0(s0)
ffffffffc02022a2:	00140a13          	addi	s4,s0,1
ffffffffc02022a6:	0007851b          	sext.w	a0,a5
ffffffffc02022aa:	d3a5                	beqz	a5,ffffffffc020220a <vprintfmt+0x244>
ffffffffc02022ac:	05e00413          	li	s0,94
ffffffffc02022b0:	bf39                	j	ffffffffc02021ce <vprintfmt+0x208>
ffffffffc02022b2:	000a2403          	lw	s0,0(s4)
ffffffffc02022b6:	b7ad                	j	ffffffffc0202220 <vprintfmt+0x25a>
ffffffffc02022b8:	000a6603          	lwu	a2,0(s4)
ffffffffc02022bc:	46a1                	li	a3,8
ffffffffc02022be:	8a2e                	mv	s4,a1
ffffffffc02022c0:	bdb1                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc02022c2:	000a6603          	lwu	a2,0(s4)
ffffffffc02022c6:	46a9                	li	a3,10
ffffffffc02022c8:	8a2e                	mv	s4,a1
ffffffffc02022ca:	bd89                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc02022cc:	000a6603          	lwu	a2,0(s4)
ffffffffc02022d0:	46c1                	li	a3,16
ffffffffc02022d2:	8a2e                	mv	s4,a1
ffffffffc02022d4:	b5a1                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc02022d6:	9902                	jalr	s2
ffffffffc02022d8:	bf09                	j	ffffffffc02021ea <vprintfmt+0x224>
ffffffffc02022da:	85a6                	mv	a1,s1
ffffffffc02022dc:	02d00513          	li	a0,45
ffffffffc02022e0:	e03e                	sd	a5,0(sp)
ffffffffc02022e2:	9902                	jalr	s2
ffffffffc02022e4:	6782                	ld	a5,0(sp)
ffffffffc02022e6:	8a66                	mv	s4,s9
ffffffffc02022e8:	40800633          	neg	a2,s0
ffffffffc02022ec:	46a9                	li	a3,10
ffffffffc02022ee:	b53d                	j	ffffffffc020211c <vprintfmt+0x156>
ffffffffc02022f0:	03b05163          	blez	s11,ffffffffc0202312 <vprintfmt+0x34c>
ffffffffc02022f4:	02d00693          	li	a3,45
ffffffffc02022f8:	f6d79de3          	bne	a5,a3,ffffffffc0202272 <vprintfmt+0x2ac>
ffffffffc02022fc:	00001417          	auipc	s0,0x1
ffffffffc0202300:	19c40413          	addi	s0,s0,412 # ffffffffc0203498 <best_fit_pmm_manager+0x538>
ffffffffc0202304:	02800793          	li	a5,40
ffffffffc0202308:	02800513          	li	a0,40
ffffffffc020230c:	00140a13          	addi	s4,s0,1
ffffffffc0202310:	bd6d                	j	ffffffffc02021ca <vprintfmt+0x204>
ffffffffc0202312:	00001a17          	auipc	s4,0x1
ffffffffc0202316:	187a0a13          	addi	s4,s4,391 # ffffffffc0203499 <best_fit_pmm_manager+0x539>
ffffffffc020231a:	02800513          	li	a0,40
ffffffffc020231e:	02800793          	li	a5,40
ffffffffc0202322:	05e00413          	li	s0,94
ffffffffc0202326:	b565                	j	ffffffffc02021ce <vprintfmt+0x208>

ffffffffc0202328 <printfmt>:
ffffffffc0202328:	715d                	addi	sp,sp,-80
ffffffffc020232a:	02810313          	addi	t1,sp,40
ffffffffc020232e:	f436                	sd	a3,40(sp)
ffffffffc0202330:	869a                	mv	a3,t1
ffffffffc0202332:	ec06                	sd	ra,24(sp)
ffffffffc0202334:	f83a                	sd	a4,48(sp)
ffffffffc0202336:	fc3e                	sd	a5,56(sp)
ffffffffc0202338:	e0c2                	sd	a6,64(sp)
ffffffffc020233a:	e4c6                	sd	a7,72(sp)
ffffffffc020233c:	e41a                	sd	t1,8(sp)
ffffffffc020233e:	c89ff0ef          	jal	ra,ffffffffc0201fc6 <vprintfmt>
ffffffffc0202342:	60e2                	ld	ra,24(sp)
ffffffffc0202344:	6161                	addi	sp,sp,80
ffffffffc0202346:	8082                	ret

ffffffffc0202348 <readline>:
ffffffffc0202348:	715d                	addi	sp,sp,-80
ffffffffc020234a:	e486                	sd	ra,72(sp)
ffffffffc020234c:	e0a6                	sd	s1,64(sp)
ffffffffc020234e:	fc4a                	sd	s2,56(sp)
ffffffffc0202350:	f84e                	sd	s3,48(sp)
ffffffffc0202352:	f452                	sd	s4,40(sp)
ffffffffc0202354:	f056                	sd	s5,32(sp)
ffffffffc0202356:	ec5a                	sd	s6,24(sp)
ffffffffc0202358:	e85e                	sd	s7,16(sp)
ffffffffc020235a:	c901                	beqz	a0,ffffffffc020236a <readline+0x22>
ffffffffc020235c:	85aa                	mv	a1,a0
ffffffffc020235e:	00001517          	auipc	a0,0x1
ffffffffc0202362:	15250513          	addi	a0,a0,338 # ffffffffc02034b0 <best_fit_pmm_manager+0x550>
ffffffffc0202366:	d51fd0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020236a:	4481                	li	s1,0
ffffffffc020236c:	497d                	li	s2,31
ffffffffc020236e:	49a1                	li	s3,8
ffffffffc0202370:	4aa9                	li	s5,10
ffffffffc0202372:	4b35                	li	s6,13
ffffffffc0202374:	00005b97          	auipc	s7,0x5
ffffffffc0202378:	d6cb8b93          	addi	s7,s7,-660 # ffffffffc02070e0 <buf>
ffffffffc020237c:	3fe00a13          	li	s4,1022
ffffffffc0202380:	daffd0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0202384:	00054a63          	bltz	a0,ffffffffc0202398 <readline+0x50>
ffffffffc0202388:	00a95a63          	bge	s2,a0,ffffffffc020239c <readline+0x54>
ffffffffc020238c:	029a5263          	bge	s4,s1,ffffffffc02023b0 <readline+0x68>
ffffffffc0202390:	d9ffd0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0202394:	fe055ae3          	bgez	a0,ffffffffc0202388 <readline+0x40>
ffffffffc0202398:	4501                	li	a0,0
ffffffffc020239a:	a091                	j	ffffffffc02023de <readline+0x96>
ffffffffc020239c:	03351463          	bne	a0,s3,ffffffffc02023c4 <readline+0x7c>
ffffffffc02023a0:	e8a9                	bnez	s1,ffffffffc02023f2 <readline+0xaa>
ffffffffc02023a2:	d8dfd0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02023a6:	fe0549e3          	bltz	a0,ffffffffc0202398 <readline+0x50>
ffffffffc02023aa:	fea959e3          	bge	s2,a0,ffffffffc020239c <readline+0x54>
ffffffffc02023ae:	4481                	li	s1,0
ffffffffc02023b0:	e42a                	sd	a0,8(sp)
ffffffffc02023b2:	d3bfd0ef          	jal	ra,ffffffffc02000ec <cputchar>
ffffffffc02023b6:	6522                	ld	a0,8(sp)
ffffffffc02023b8:	009b87b3          	add	a5,s7,s1
ffffffffc02023bc:	2485                	addiw	s1,s1,1
ffffffffc02023be:	00a78023          	sb	a0,0(a5)
ffffffffc02023c2:	bf7d                	j	ffffffffc0202380 <readline+0x38>
ffffffffc02023c4:	01550463          	beq	a0,s5,ffffffffc02023cc <readline+0x84>
ffffffffc02023c8:	fb651ce3          	bne	a0,s6,ffffffffc0202380 <readline+0x38>
ffffffffc02023cc:	d21fd0ef          	jal	ra,ffffffffc02000ec <cputchar>
ffffffffc02023d0:	00005517          	auipc	a0,0x5
ffffffffc02023d4:	d1050513          	addi	a0,a0,-752 # ffffffffc02070e0 <buf>
ffffffffc02023d8:	94aa                	add	s1,s1,a0
ffffffffc02023da:	00048023          	sb	zero,0(s1)
ffffffffc02023de:	60a6                	ld	ra,72(sp)
ffffffffc02023e0:	6486                	ld	s1,64(sp)
ffffffffc02023e2:	7962                	ld	s2,56(sp)
ffffffffc02023e4:	79c2                	ld	s3,48(sp)
ffffffffc02023e6:	7a22                	ld	s4,40(sp)
ffffffffc02023e8:	7a82                	ld	s5,32(sp)
ffffffffc02023ea:	6b62                	ld	s6,24(sp)
ffffffffc02023ec:	6bc2                	ld	s7,16(sp)
ffffffffc02023ee:	6161                	addi	sp,sp,80
ffffffffc02023f0:	8082                	ret
ffffffffc02023f2:	4521                	li	a0,8
ffffffffc02023f4:	cf9fd0ef          	jal	ra,ffffffffc02000ec <cputchar>
ffffffffc02023f8:	34fd                	addiw	s1,s1,-1
ffffffffc02023fa:	b759                	j	ffffffffc0202380 <readline+0x38>

ffffffffc02023fc <sbi_console_putchar>:
ffffffffc02023fc:	4781                	li	a5,0
ffffffffc02023fe:	00005717          	auipc	a4,0x5
ffffffffc0202402:	c0a73703          	ld	a4,-1014(a4) # ffffffffc0207008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0202406:	88ba                	mv	a7,a4
ffffffffc0202408:	852a                	mv	a0,a0
ffffffffc020240a:	85be                	mv	a1,a5
ffffffffc020240c:	863e                	mv	a2,a5
ffffffffc020240e:	00000073          	ecall
ffffffffc0202412:	87aa                	mv	a5,a0
ffffffffc0202414:	8082                	ret

ffffffffc0202416 <sbi_set_timer>:
ffffffffc0202416:	4781                	li	a5,0
ffffffffc0202418:	00005717          	auipc	a4,0x5
ffffffffc020241c:	10873703          	ld	a4,264(a4) # ffffffffc0207520 <SBI_SET_TIMER>
ffffffffc0202420:	88ba                	mv	a7,a4
ffffffffc0202422:	852a                	mv	a0,a0
ffffffffc0202424:	85be                	mv	a1,a5
ffffffffc0202426:	863e                	mv	a2,a5
ffffffffc0202428:	00000073          	ecall
ffffffffc020242c:	87aa                	mv	a5,a0
ffffffffc020242e:	8082                	ret

ffffffffc0202430 <sbi_console_getchar>:
ffffffffc0202430:	4501                	li	a0,0
ffffffffc0202432:	00005797          	auipc	a5,0x5
ffffffffc0202436:	bce7b783          	ld	a5,-1074(a5) # ffffffffc0207000 <SBI_CONSOLE_GETCHAR>
ffffffffc020243a:	88be                	mv	a7,a5
ffffffffc020243c:	852a                	mv	a0,a0
ffffffffc020243e:	85aa                	mv	a1,a0
ffffffffc0202440:	862a                	mv	a2,a0
ffffffffc0202442:	00000073          	ecall
ffffffffc0202446:	852a                	mv	a0,a0
ffffffffc0202448:	2501                	sext.w	a0,a0
ffffffffc020244a:	8082                	ret

ffffffffc020244c <strnlen>:
ffffffffc020244c:	4781                	li	a5,0
ffffffffc020244e:	e589                	bnez	a1,ffffffffc0202458 <strnlen+0xc>
ffffffffc0202450:	a811                	j	ffffffffc0202464 <strnlen+0x18>
ffffffffc0202452:	0785                	addi	a5,a5,1
ffffffffc0202454:	00f58863          	beq	a1,a5,ffffffffc0202464 <strnlen+0x18>
ffffffffc0202458:	00f50733          	add	a4,a0,a5
ffffffffc020245c:	00074703          	lbu	a4,0(a4)
ffffffffc0202460:	fb6d                	bnez	a4,ffffffffc0202452 <strnlen+0x6>
ffffffffc0202462:	85be                	mv	a1,a5
ffffffffc0202464:	852e                	mv	a0,a1
ffffffffc0202466:	8082                	ret

ffffffffc0202468 <strcmp>:
ffffffffc0202468:	00054783          	lbu	a5,0(a0)
ffffffffc020246c:	0005c703          	lbu	a4,0(a1)
ffffffffc0202470:	cb89                	beqz	a5,ffffffffc0202482 <strcmp+0x1a>
ffffffffc0202472:	0505                	addi	a0,a0,1
ffffffffc0202474:	0585                	addi	a1,a1,1
ffffffffc0202476:	fee789e3          	beq	a5,a4,ffffffffc0202468 <strcmp>
ffffffffc020247a:	0007851b          	sext.w	a0,a5
ffffffffc020247e:	9d19                	subw	a0,a0,a4
ffffffffc0202480:	8082                	ret
ffffffffc0202482:	4501                	li	a0,0
ffffffffc0202484:	bfed                	j	ffffffffc020247e <strcmp+0x16>

ffffffffc0202486 <strchr>:
ffffffffc0202486:	00054783          	lbu	a5,0(a0)
ffffffffc020248a:	c799                	beqz	a5,ffffffffc0202498 <strchr+0x12>
ffffffffc020248c:	00f58763          	beq	a1,a5,ffffffffc020249a <strchr+0x14>
ffffffffc0202490:	00154783          	lbu	a5,1(a0)
ffffffffc0202494:	0505                	addi	a0,a0,1
ffffffffc0202496:	fbfd                	bnez	a5,ffffffffc020248c <strchr+0x6>
ffffffffc0202498:	4501                	li	a0,0
ffffffffc020249a:	8082                	ret

ffffffffc020249c <memset>:
ffffffffc020249c:	ca01                	beqz	a2,ffffffffc02024ac <memset+0x10>
ffffffffc020249e:	962a                	add	a2,a2,a0
ffffffffc02024a0:	87aa                	mv	a5,a0
ffffffffc02024a2:	0785                	addi	a5,a5,1
ffffffffc02024a4:	feb78fa3          	sb	a1,-1(a5)
ffffffffc02024a8:	fec79de3          	bne	a5,a2,ffffffffc02024a2 <memset+0x6>
ffffffffc02024ac:	8082                	ret

ffffffffc02024ae <memcpy>:
ffffffffc02024ae:	ca19                	beqz	a2,ffffffffc02024c4 <memcpy+0x16>
ffffffffc02024b0:	962e                	add	a2,a2,a1
ffffffffc02024b2:	87aa                	mv	a5,a0
ffffffffc02024b4:	0005c703          	lbu	a4,0(a1)
ffffffffc02024b8:	0585                	addi	a1,a1,1
ffffffffc02024ba:	0785                	addi	a5,a5,1
ffffffffc02024bc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02024c0:	fec59ae3          	bne	a1,a2,ffffffffc02024b4 <memcpy+0x6>
ffffffffc02024c4:	8082                	ret
