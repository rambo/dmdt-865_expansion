
/Users/rambo/Documents/ChatGPT/motorbikestuff/work/gpio-api-trace/libjni_freeme_expand-16.so:	file format elf64-littleaarch64

Disassembly of section .text:

0000000000004000 <.text>:
    4000: d503201f     	nop
    4004: 1001ffe0     	adr	x0, 0x8000
    4008: 140002a6     	b	0x4aa0 <__cxa_finalize@plt>
    400c: 00000000     	udf	#0x0
    4010: d65f03c0     	ret
		...
    4020: 17fffffc     	b	0x4010 <.text+0x10>
		...

0000000000004030 <convert_to_long>:
    4030: f9400000     	ldr	x0, [x0]
    4034: d65f03c0     	ret
		...

0000000000004040 <Java_com_freeme_factory_cradle_ExpandGpio_open>:
    4040: d10143ff     	sub	sp, sp, #0x50
    4044: a9017bfd     	stp	x29, x30, [sp, #0x10]
    4048: f90013f7     	str	x23, [sp, #0x20]
    404c: a90357f6     	stp	x22, x21, [sp, #0x30]
    4050: a9044ff4     	stp	x20, x19, [sp, #0x40]
    4054: 910043fd     	add	x29, sp, #0x10
    4058: d53bd056     	mrs	x22, TPIDR_EL0
    405c: aa0203f4     	mov	x20, x2
    4060: f94016c8     	ldr	x8, [x22, #0x28]
    4064: 910013e2     	add	x2, sp, #0x4
    4068: aa1403e1     	mov	x1, x20
    406c: aa0003f3     	mov	x19, x0
    4070: f90007e8     	str	x8, [sp, #0x8]
    4074: f9400008     	ldr	x8, [x0]
    4078: 390013ff     	strb	wzr, [sp, #0x4]
    407c: f942a508     	ldr	x8, [x8, #0x548]
    4080: d63f0100     	blr	x8
    4084: 52800041     	mov	w1, #0x2                // =2
    4088: aa0003f5     	mov	x21, x0
    408c: 9400029d     	bl	0x4b00 <__open_2@plt>
    4090: 90000037     	adrp	x23, 0x8000
    4094: 2a0003e3     	mov	w3, w0
    4098: 90ffffe1     	adrp	x1, 0x0
    409c: 9131f421     	add	x1, x1, #0xc7d
    40a0: d503201f     	nop
    40a4: 10fe5882     	adr	x2, 0xbb4
    40a8: f940f6f7     	ldr	x23, [x23, #0x1e8]
    40ac: aa1503e4     	mov	x4, x21
    40b0: b90002e0     	str	w0, [x23]
    40b4: 52800060     	mov	w0, #0x3                // =3
    40b8: 9400027e     	bl	0x4ab0 <__android_log_print@plt>
    40bc: f9400268     	ldr	x8, [x19]
    40c0: aa1303e0     	mov	x0, x19
    40c4: aa1403e1     	mov	x1, x20
    40c8: aa1503e2     	mov	x2, x21
    40cc: f942a908     	ldr	x8, [x8, #0x550]
    40d0: d63f0100     	blr	x8
    40d4: b94002f3     	ldr	w19, [x23]
    40d8: 3100067f     	cmn	w19, #0x1
    40dc: 540000e1     	b.ne	0x40f8 <Java_com_freeme_factory_cradle_ExpandGpio_open+0xb8>
    40e0: 90ffffe1     	adrp	x1, 0x0
    40e4: 9131f421     	add	x1, x1, #0xc7d
    40e8: 90ffffe2     	adrp	x2, 0x0
    40ec: 912f5842     	add	x2, x2, #0xbd6
    40f0: 528000c0     	mov	w0, #0x6                // =6
    40f4: 9400026f     	bl	0x4ab0 <__android_log_print@plt>
    40f8: f94016c8     	ldr	x8, [x22, #0x28]
    40fc: f94007e9     	ldr	x9, [sp, #0x8]
    4100: eb09011f     	cmp	x8, x9
    4104: 54000101     	b.ne	0x4124 <Java_com_freeme_factory_cradle_ExpandGpio_open+0xe4>
    4108: 2a1303e0     	mov	w0, w19
    410c: a9444ff4     	ldp	x20, x19, [sp, #0x40]
    4110: a94357f6     	ldp	x22, x21, [sp, #0x30]
    4114: f94013f7     	ldr	x23, [sp, #0x20]
    4118: a9417bfd     	ldp	x29, x30, [sp, #0x10]
    411c: 910143ff     	add	sp, sp, #0x50
    4120: d65f03c0     	ret
    4124: 9400027f     	bl	0x4b20 <__stack_chk_fail@plt>
		...

0000000000004130 <Java_com_freeme_factory_cradle_ExpandGpio_close>:
    4130: a9be7bfd     	stp	x29, x30, [sp, #-0x20]!
    4134: f9000bf3     	str	x19, [sp, #0x10]
    4138: 910003fd     	mov	x29, sp
    413c: 90000033     	adrp	x19, 0x8000
    4140: f940f673     	ldr	x19, [x19, #0x1e8]
    4144: b9400263     	ldr	w3, [x19]
    4148: 3100047f     	cmn	w3, #0x1
    414c: 54000160     	b.eq	0x4178 <Java_com_freeme_factory_cradle_ExpandGpio_close+0x48>
    4150: 90ffffe1     	adrp	x1, 0x0
    4154: 9131f421     	add	x1, x1, #0xc7d
    4158: 90ffffe2     	adrp	x2, 0x0
    415c: 9131b042     	add	x2, x2, #0xc6c
    4160: 52800060     	mov	w0, #0x3                // =3
    4164: 94000253     	bl	0x4ab0 <__android_log_print@plt>
    4168: b9400260     	ldr	w0, [x19]
    416c: 94000255     	bl	0x4ac0 <close@plt>
    4170: 12800008     	mov	w8, #-0x1               // =-1
    4174: b9000268     	str	w8, [x19]
    4178: f9400bf3     	ldr	x19, [sp, #0x10]
    417c: a8c27bfd     	ldp	x29, x30, [sp], #0x20
    4180: d65f03c0     	ret
		...

0000000000004190 <Java_com_freeme_factory_cradle_ExpandGpio_getPosition>:
    4190: d10183ff     	sub	sp, sp, #0x60
    4194: a9037bfd     	stp	x29, x30, [sp, #0x30]
    4198: f90023f5     	str	x21, [sp, #0x40]
    419c: a9054ff4     	stp	x20, x19, [sp, #0x50]
    41a0: 9100c3fd     	add	x29, sp, #0x30
    41a4: 90000029     	adrp	x9, 0x8000
    41a8: d53bd055     	mrs	x21, TPIDR_EL0
    41ac: f94016a8     	ldr	x8, [x21, #0x28]
    41b0: 528a6121     	mov	w1, #0x5309             // =21257
    41b4: 2a0203f3     	mov	w19, w2
    41b8: 72b80381     	movk	w1, #0xc01c, lsl #16
    41bc: f940f529     	ldr	x9, [x9, #0x1e8]
    41c0: f81f83a8     	stur	x8, [x29, #-0x8]
    41c4: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    41c8: b9400120     	ldr	w0, [x9]
    41cc: b9000fe2     	str	w2, [sp, #0xc]
    41d0: 910023e2     	add	x2, sp, #0x8
    41d4: b90023ff     	str	wzr, [sp, #0x20]
    41d8: f9000fff     	str	xzr, [sp, #0x18]
    41dc: 9400023d     	bl	0x4ad0 <ioctl@plt>
    41e0: 37f80060     	tbnz	w0, #0x1f, 0x41ec <Java_com_freeme_factory_cradle_ExpandGpio_getPosition+0x5c>
    41e4: b94017e0     	ldr	w0, [sp, #0x14]
    41e8: 1400000f     	b	0x4224 <Java_com_freeme_factory_cradle_ExpandGpio_getPosition+0x94>
    41ec: 2a0003f4     	mov	w20, w0
    41f0: 94000240     	bl	0x4af0 <__errno@plt>
    41f4: b9400000     	ldr	w0, [x0]
    41f8: 9400023a     	bl	0x4ae0 <strerror@plt>
    41fc: aa0003e5     	mov	x5, x0
    4200: 90ffffe1     	adrp	x1, 0x0
    4204: 9131f421     	add	x1, x1, #0xc7d
    4208: 90ffffe2     	adrp	x2, 0x0
    420c: 912ad042     	add	x2, x2, #0xab4
    4210: 52800060     	mov	w0, #0x3                // =3
    4214: 2a1303e3     	mov	w3, w19
    4218: 2a1403e4     	mov	w4, w20
    421c: 94000225     	bl	0x4ab0 <__android_log_print@plt>
    4220: 12800000     	mov	w0, #-0x1               // =-1
    4224: f94016a8     	ldr	x8, [x21, #0x28]
    4228: f85f83a9     	ldur	x9, [x29, #-0x8]
    422c: eb09011f     	cmp	x8, x9
    4230: 540000c1     	b.ne	0x4248 <Java_com_freeme_factory_cradle_ExpandGpio_getPosition+0xb8>
    4234: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    4238: f94023f5     	ldr	x21, [sp, #0x40]
    423c: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    4240: 910183ff     	add	sp, sp, #0x60
    4244: d65f03c0     	ret
    4248: 94000236     	bl	0x4b20 <__stack_chk_fail@plt>
    424c: 00000000     	udf	#0x0

0000000000004250 <Java_com_freeme_factory_cradle_ExpandGpio_setPower>:
    4250: d10183ff     	sub	sp, sp, #0x60
    4254: a9037bfd     	stp	x29, x30, [sp, #0x30]
    4258: f90023f5     	str	x21, [sp, #0x40]
    425c: a9054ff4     	stp	x20, x19, [sp, #0x50]
    4260: 9100c3fd     	add	x29, sp, #0x30
    4264: 90000029     	adrp	x9, 0x8000
    4268: d53bd055     	mrs	x21, TPIDR_EL0
    426c: f94016a8     	ldr	x8, [x21, #0x28]
    4270: 72001c7f     	tst	w3, #0xff
    4274: 1a9f07ea     	cset	w10, ne
    4278: 528a6021     	mov	w1, #0x5301             // =21249
    427c: f940f529     	ldr	x9, [x9, #0x1e8]
    4280: 72b80381     	movk	w1, #0xc01c, lsl #16
    4284: f81f83a8     	stur	x8, [x29, #-0x8]
    4288: 29020bea     	stp	w10, w2, [sp, #0x10]
    428c: 910023e2     	add	x2, sp, #0x8
    4290: b9400120     	ldr	w0, [x9]
    4294: f90007ff     	str	xzr, [sp, #0x8]
    4298: f9000fff     	str	xzr, [sp, #0x18]
    429c: b90023ff     	str	wzr, [sp, #0x20]
    42a0: 9400020c     	bl	0x4ad0 <ioctl@plt>
    42a4: 37f80060     	tbnz	w0, #0x1f, 0x42b0 <Java_com_freeme_factory_cradle_ExpandGpio_setPower+0x60>
    42a8: 52800020     	mov	w0, #0x1                // =1
    42ac: 14000010     	b	0x42ec <Java_com_freeme_factory_cradle_ExpandGpio_setPower+0x9c>
    42b0: b94013f4     	ldr	w20, [sp, #0x10]
    42b4: 2a0003f3     	mov	w19, w0
    42b8: 9400020e     	bl	0x4af0 <__errno@plt>
    42bc: b9400000     	ldr	w0, [x0]
    42c0: 94000208     	bl	0x4ae0 <strerror@plt>
    42c4: aa0003e5     	mov	x5, x0
    42c8: 90ffffe1     	adrp	x1, 0x0
    42cc: 9131f421     	add	x1, x1, #0xc7d
    42d0: 90ffffe2     	adrp	x2, 0x0
    42d4: 912b9842     	add	x2, x2, #0xae6
    42d8: 52800060     	mov	w0, #0x3                // =3
    42dc: 2a1403e3     	mov	w3, w20
    42e0: 2a1303e4     	mov	w4, w19
    42e4: 940001f3     	bl	0x4ab0 <__android_log_print@plt>
    42e8: 2a1f03e0     	mov	w0, wzr
    42ec: f94016a8     	ldr	x8, [x21, #0x28]
    42f0: f85f83a9     	ldur	x9, [x29, #-0x8]
    42f4: eb09011f     	cmp	x8, x9
    42f8: 540000c1     	b.ne	0x4310 <Java_com_freeme_factory_cradle_ExpandGpio_setPower+0xc0>
    42fc: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    4300: f94023f5     	ldr	x21, [sp, #0x40]
    4304: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    4308: 910183ff     	add	sp, sp, #0x60
    430c: d65f03c0     	ret
    4310: 94000204     	bl	0x4b20 <__stack_chk_fail@plt>
		...

0000000000004320 <Java_com_freeme_factory_cradle_ExpandGpio_getType>:
    4320: d10183ff     	sub	sp, sp, #0x60
    4324: a9037bfd     	stp	x29, x30, [sp, #0x30]
    4328: f90023f5     	str	x21, [sp, #0x40]
    432c: a9054ff4     	stp	x20, x19, [sp, #0x50]
    4330: 9100c3fd     	add	x29, sp, #0x30
    4334: 90000029     	adrp	x9, 0x8000
    4338: d53bd055     	mrs	x21, TPIDR_EL0
    433c: f94016a8     	ldr	x8, [x21, #0x28]
    4340: 528a6141     	mov	w1, #0x530a             // =21258
    4344: 2a0203f3     	mov	w19, w2
    4348: 72b80381     	movk	w1, #0xc01c, lsl #16
    434c: f940f529     	ldr	x9, [x9, #0x1e8]
    4350: f81f83a8     	stur	x8, [x29, #-0x8]
    4354: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    4358: b9400120     	ldr	w0, [x9]
    435c: b90017e2     	str	w2, [sp, #0x14]
    4360: 910023e2     	add	x2, sp, #0x8
    4364: b90023ff     	str	wzr, [sp, #0x20]
    4368: f9000fff     	str	xzr, [sp, #0x18]
    436c: 940001d9     	bl	0x4ad0 <ioctl@plt>
    4370: 37f80060     	tbnz	w0, #0x1f, 0x437c <Java_com_freeme_factory_cradle_ExpandGpio_getType+0x5c>
    4374: b9400fe0     	ldr	w0, [sp, #0xc]
    4378: 1400000f     	b	0x43b4 <Java_com_freeme_factory_cradle_ExpandGpio_getType+0x94>
    437c: 2a0003f4     	mov	w20, w0
    4380: 940001dc     	bl	0x4af0 <__errno@plt>
    4384: b9400000     	ldr	w0, [x0]
    4388: 940001d6     	bl	0x4ae0 <strerror@plt>
    438c: aa0003e5     	mov	x5, x0
    4390: 90ffffe1     	adrp	x1, 0x0
    4394: 9131f421     	add	x1, x1, #0xc7d
    4398: 90ffffe2     	adrp	x2, 0x0
    439c: 912c4442     	add	x2, x2, #0xb11
    43a0: 52800060     	mov	w0, #0x3                // =3
    43a4: 2a1303e3     	mov	w3, w19
    43a8: 2a1403e4     	mov	w4, w20
    43ac: 940001c1     	bl	0x4ab0 <__android_log_print@plt>
    43b0: 12800000     	mov	w0, #-0x1               // =-1
    43b4: f94016a8     	ldr	x8, [x21, #0x28]
    43b8: f85f83a9     	ldur	x9, [x29, #-0x8]
    43bc: eb09011f     	cmp	x8, x9
    43c0: 540000c1     	b.ne	0x43d8 <Java_com_freeme_factory_cradle_ExpandGpio_getType+0xb8>
    43c4: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    43c8: f94023f5     	ldr	x21, [sp, #0x40]
    43cc: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    43d0: 910183ff     	add	sp, sp, #0x60
    43d4: d65f03c0     	ret
    43d8: 940001d2     	bl	0x4b20 <__stack_chk_fail@plt>
    43dc: 00000000     	udf	#0x0

00000000000043e0 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo>:
    43e0: d10183ff     	sub	sp, sp, #0x60
    43e4: a9037bfd     	stp	x29, x30, [sp, #0x30]
    43e8: a90457f6     	stp	x22, x21, [sp, #0x40]
    43ec: a9054ff4     	stp	x20, x19, [sp, #0x50]
    43f0: 9100c3fd     	add	x29, sp, #0x30
    43f4: d53bd056     	mrs	x22, TPIDR_EL0
    43f8: 90000029     	adrp	x9, 0x8000
    43fc: f94016c8     	ldr	x8, [x22, #0x28]
    4400: 72001c9f     	tst	w4, #0xff
    4404: 528a6041     	mov	w1, #0x5302             // =21250
    4408: 2a0303f3     	mov	w19, w3
    440c: f940f529     	ldr	x9, [x9, #0x1e8]
    4410: 72b80381     	movk	w1, #0xc01c, lsl #16
    4414: f81f83a8     	stur	x8, [x29, #-0x8]
    4418: 1a9f07e8     	cset	w8, ne
    441c: 2901ffe3     	stp	w3, wzr, [sp, #0xc]
    4420: b9400120     	ldr	w0, [x9]
    4424: 29028be8     	stp	w8, w2, [sp, #0x14]
    4428: 910033e2     	add	x2, sp, #0xc
    442c: f801c3ff     	stur	xzr, [sp, #0x1c]
    4430: b90027ff     	str	wzr, [sp, #0x24]
    4434: 940001a7     	bl	0x4ad0 <ioctl@plt>
    4438: 37f80060     	tbnz	w0, #0x1f, 0x4444 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo+0x64>
    443c: 52800020     	mov	w0, #0x1                // =1
    4440: 14000011     	b	0x4484 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo+0xa4>
    4444: b94017f5     	ldr	w21, [sp, #0x14]
    4448: 2a0003f4     	mov	w20, w0
    444c: 940001a9     	bl	0x4af0 <__errno@plt>
    4450: b9400000     	ldr	w0, [x0]
    4454: 940001a3     	bl	0x4ae0 <strerror@plt>
    4458: aa0003e6     	mov	x6, x0
    445c: 90ffffe1     	adrp	x1, 0x0
    4460: 9131f421     	add	x1, x1, #0xc7d
    4464: 90ffffe2     	adrp	x2, 0x0
    4468: 912a0842     	add	x2, x2, #0xa82
    446c: 52800060     	mov	w0, #0x3                // =3
    4470: 2a1303e3     	mov	w3, w19
    4474: 2a1503e4     	mov	w4, w21
    4478: 2a1403e5     	mov	w5, w20
    447c: 9400018d     	bl	0x4ab0 <__android_log_print@plt>
    4480: 2a1f03e0     	mov	w0, wzr
    4484: f94016c8     	ldr	x8, [x22, #0x28]
    4488: f85f83a9     	ldur	x9, [x29, #-0x8]
    448c: eb09011f     	cmp	x8, x9
    4490: 540000c1     	b.ne	0x44a8 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo+0xc8>
    4494: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    4498: a94457f6     	ldp	x22, x21, [sp, #0x40]
    449c: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    44a0: 910183ff     	add	sp, sp, #0x60
    44a4: d65f03c0     	ret
    44a8: 9400019e     	bl	0x4b20 <__stack_chk_fail@plt>
    44ac: 00000000     	udf	#0x0

00000000000044b0 <Java_com_freeme_factory_cradle_ExpandGpio_readIo>:
    44b0: d10183ff     	sub	sp, sp, #0x60
    44b4: a9037bfd     	stp	x29, x30, [sp, #0x30]
    44b8: f90023f5     	str	x21, [sp, #0x40]
    44bc: a9054ff4     	stp	x20, x19, [sp, #0x50]
    44c0: 9100c3fd     	add	x29, sp, #0x30
    44c4: 90000029     	adrp	x9, 0x8000
    44c8: d53bd055     	mrs	x21, TPIDR_EL0
    44cc: f94016a8     	ldr	x8, [x21, #0x28]
    44d0: 528a6061     	mov	w1, #0x5303             // =21251
    44d4: 72b80381     	movk	w1, #0xc01c, lsl #16
    44d8: 2a0303f3     	mov	w19, w3
    44dc: f940f529     	ldr	x9, [x9, #0x1e8]
    44e0: f81f83a8     	stur	x8, [x29, #-0x8]
    44e4: b9001be2     	str	w2, [sp, #0x18]
    44e8: 910033e2     	add	x2, sp, #0xc
    44ec: b9400120     	ldr	w0, [x9]
    44f0: b9000fe3     	str	w3, [sp, #0xc]
    44f4: f9000bff     	str	xzr, [sp, #0x10]
    44f8: f801c3ff     	stur	xzr, [sp, #0x1c]
    44fc: b90027ff     	str	wzr, [sp, #0x24]
    4500: 94000174     	bl	0x4ad0 <ioctl@plt>
    4504: 37f800a0     	tbnz	w0, #0x1f, 0x4518 <Java_com_freeme_factory_cradle_ExpandGpio_readIo+0x68>
    4508: b94017e8     	ldr	w8, [sp, #0x14]
    450c: 7100011f     	cmp	w8, #0x0
    4510: 1a9f17e0     	cset	w0, eq
    4514: 1400000f     	b	0x4550 <Java_com_freeme_factory_cradle_ExpandGpio_readIo+0xa0>
    4518: 2a0003f4     	mov	w20, w0
    451c: 94000175     	bl	0x4af0 <__errno@plt>
    4520: b9400000     	ldr	w0, [x0]
    4524: 9400016f     	bl	0x4ae0 <strerror@plt>
    4528: aa0003e5     	mov	x5, x0
    452c: 90ffffe1     	adrp	x1, 0x0
    4530: 9131f421     	add	x1, x1, #0xc7d
    4534: 90ffffe2     	adrp	x2, 0x0
    4538: 91304042     	add	x2, x2, #0xc10
    453c: 52800060     	mov	w0, #0x3                // =3
    4540: 2a1303e3     	mov	w3, w19
    4544: 2a1403e4     	mov	w4, w20
    4548: 9400015a     	bl	0x4ab0 <__android_log_print@plt>
    454c: 2a1f03e0     	mov	w0, wzr
    4550: f94016a8     	ldr	x8, [x21, #0x28]
    4554: f85f83a9     	ldur	x9, [x29, #-0x8]
    4558: eb09011f     	cmp	x8, x9
    455c: 540000c1     	b.ne	0x4574 <Java_com_freeme_factory_cradle_ExpandGpio_readIo+0xc4>
    4560: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    4564: f94023f5     	ldr	x21, [sp, #0x40]
    4568: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    456c: 910183ff     	add	sp, sp, #0x60
    4570: d65f03c0     	ret
    4574: 9400016b     	bl	0x4b20 <__stack_chk_fail@plt>
		...

0000000000004580 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom>:
    4580: d101c3ff     	sub	sp, sp, #0x70
    4584: a9037bfd     	stp	x29, x30, [sp, #0x30]
    4588: a9045ff8     	stp	x24, x23, [sp, #0x40]
    458c: a90557f6     	stp	x22, x21, [sp, #0x50]
    4590: a9064ff4     	stp	x20, x19, [sp, #0x60]
    4594: 9100c3fd     	add	x29, sp, #0x30
    4598: 90000029     	adrp	x9, 0x8000
    459c: d53bd057     	mrs	x23, TPIDR_EL0
    45a0: f94016e8     	ldr	x8, [x23, #0x28]
    45a4: aa0003f3     	mov	x19, x0
    45a8: 528a60a1     	mov	w1, #0x5305             // =21253
    45ac: 910023f8     	add	x24, sp, #0x8
    45b0: f940f529     	ldr	x9, [x9, #0x1e8]
    45b4: 72b80381     	movk	w1, #0xc01c, lsl #16
    45b8: f81f83a8     	stur	x8, [x29, #-0x8]
    45bc: 52800108     	mov	w8, #0x8                // =8
    45c0: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    45c4: b9400120     	ldr	w0, [x9]
    45c8: b90017e2     	str	w2, [sp, #0x14]
    45cc: 910023e2     	add	x2, sp, #0x8
    45d0: b90023ff     	str	wzr, [sp, #0x20]
    45d4: f9000fff     	str	xzr, [sp, #0x18]
    45d8: 390083e8     	strb	w8, [sp, #0x20]
    45dc: 9400013d     	bl	0x4ad0 <ioctl@plt>
    45e0: 37f80720     	tbnz	w0, #0x1f, 0x46c4 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x144>
    45e4: f9400fe3     	ldr	x3, [sp, #0x18]
    45e8: 528a60a6     	mov	w6, #0x5305             // =21253
    45ec: 394087e4     	ldrb	w4, [sp, #0x21]
    45f0: 90ffffe1     	adrp	x1, 0x0
    45f4: 9131f421     	add	x1, x1, #0xc7d
    45f8: b9400fe5     	ldr	w5, [sp, #0xc]
    45fc: b94017e7     	ldr	w7, [sp, #0x14]
    4600: 90ffffe2     	adrp	x2, 0x0
    4604: 91283842     	add	x2, x2, #0xa0e
    4608: 52800060     	mov	w0, #0x3                // =3
    460c: 72b80386     	movk	w6, #0xc01c, lsl #16
    4610: 94000128     	bl	0x4ab0 <__android_log_print@plt>
    4614: f9400268     	ldr	x8, [x19]
    4618: 90ffffe1     	adrp	x1, 0x0
    461c: 91260021     	add	x1, x1, #0x980
    4620: aa1303e0     	mov	x0, x19
    4624: f9401908     	ldr	x8, [x8, #0x30]
    4628: d63f0100     	blr	x8
    462c: b4000660     	cbz	x0, 0x46f8 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x178>
    4630: f9400268     	ldr	x8, [x19]
    4634: aa0003f4     	mov	x20, x0
    4638: 90ffffe2     	adrp	x2, 0x0
    463c: 9130d842     	add	x2, x2, #0xc36
    4640: 90ffffe3     	adrp	x3, 0x0
    4644: 912eb063     	add	x3, x3, #0xbac
    4648: aa1303e0     	mov	x0, x19
    464c: aa1403e1     	mov	x1, x20
    4650: f9408508     	ldr	x8, [x8, #0x108]
    4654: d63f0100     	blr	x8
    4658: b40005a0     	cbz	x0, 0x470c <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x18c>
    465c: f9400268     	ldr	x8, [x19]
    4660: aa0003f5     	mov	x21, x0
    4664: aa1303e0     	mov	x0, x19
    4668: 52800101     	mov	w1, #0x8                // =8
    466c: f942c108     	ldr	x8, [x8, #0x580]
    4670: d63f0100     	blr	x8
    4674: b4000560     	cbz	x0, 0x4720 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1a0>
    4678: f9400268     	ldr	x8, [x19]
    467c: aa0003f6     	mov	x22, x0
    4680: 91004304     	add	x4, x24, #0x10
    4684: aa1303e0     	mov	x0, x19
    4688: aa1603e1     	mov	x1, x22
    468c: 2a1f03e2     	mov	w2, wzr
    4690: 52800103     	mov	w3, #0x8                // =8
    4694: f9434108     	ldr	x8, [x8, #0x680]
    4698: d63f0100     	blr	x8
    469c: f9400268     	ldr	x8, [x19]
    46a0: aa1303e0     	mov	x0, x19
    46a4: 394087e4     	ldrb	w4, [sp, #0x21]
    46a8: aa1403e1     	mov	x1, x20
    46ac: b9400fe5     	ldr	w5, [sp, #0xc]
    46b0: aa1503e2     	mov	x2, x21
    46b4: aa1603e3     	mov	x3, x22
    46b8: f9407108     	ldr	x8, [x8, #0xe0]
    46bc: d63f0100     	blr	x8
    46c0: 1400001f     	b	0x473c <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1bc>
    46c4: 2a0003f4     	mov	w20, w0
    46c8: 9400010a     	bl	0x4af0 <__errno@plt>
    46cc: b9400000     	ldr	w0, [x0]
    46d0: 94000104     	bl	0x4ae0 <strerror@plt>
    46d4: aa0003e4     	mov	x4, x0
    46d8: 90ffffe1     	adrp	x1, 0x0
    46dc: 9131f421     	add	x1, x1, #0xc7d
    46e0: 90ffffe2     	adrp	x2, 0x0
    46e4: 91279c42     	add	x2, x2, #0x9e7
    46e8: 52800060     	mov	w0, #0x3                // =3
    46ec: 2a1403e3     	mov	w3, w20
    46f0: 940000f0     	bl	0x4ab0 <__android_log_print@plt>
    46f4: 14000011     	b	0x4738 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1b8>
    46f8: 90ffffe1     	adrp	x1, 0x0
    46fc: 9131f421     	add	x1, x1, #0xc7d
    4700: 90ffffe2     	adrp	x2, 0x0
    4704: 91294842     	add	x2, x2, #0xa52
    4708: 1400000a     	b	0x4730 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1b0>
    470c: 90ffffe1     	adrp	x1, 0x0
    4710: 9131f421     	add	x1, x1, #0xc7d
    4714: 90ffffe2     	adrp	x2, 0x0
    4718: 912d0c42     	add	x2, x2, #0xb43
    471c: 14000005     	b	0x4730 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1b0>
    4720: 90ffffe1     	adrp	x1, 0x0
    4724: 9131f421     	add	x1, x1, #0xc7d
    4728: 90ffffe2     	adrp	x2, 0x0
    472c: 9126c042     	add	x2, x2, #0x9b0
    4730: 52800060     	mov	w0, #0x3                // =3
    4734: 940000df     	bl	0x4ab0 <__android_log_print@plt>
    4738: aa1f03e0     	mov	x0, xzr
    473c: f94016e8     	ldr	x8, [x23, #0x28]
    4740: f85f83a9     	ldur	x9, [x29, #-0x8]
    4744: eb09011f     	cmp	x8, x9
    4748: 540000e1     	b.ne	0x4764 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1e4>
    474c: a9464ff4     	ldp	x20, x19, [sp, #0x60]
    4750: a94557f6     	ldp	x22, x21, [sp, #0x50]
    4754: a9445ff8     	ldp	x24, x23, [sp, #0x40]
    4758: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    475c: 9101c3ff     	add	sp, sp, #0x70
    4760: d65f03c0     	ret
    4764: 940000ef     	bl	0x4b20 <__stack_chk_fail@plt>
		...

0000000000004770 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom>:
    4770: d10203ff     	sub	sp, sp, #0x80
    4774: a9037bfd     	stp	x29, x30, [sp, #0x30]
    4778: a90467fa     	stp	x26, x25, [sp, #0x40]
    477c: a9055ff8     	stp	x24, x23, [sp, #0x50]
    4780: a90657f6     	stp	x22, x21, [sp, #0x60]
    4784: a9074ff4     	stp	x20, x19, [sp, #0x70]
    4788: 9100c3fd     	add	x29, sp, #0x30
    478c: d53bd05a     	mrs	x26, TPIDR_EL0
    4790: 90ffffe1     	adrp	x1, 0x0
    4794: 91260021     	add	x1, x1, #0x980
    4798: f9401748     	ldr	x8, [x26, #0x28]
    479c: aa0303f4     	mov	x20, x3
    47a0: aa0003f5     	mov	x21, x0
    47a4: 2a0203f3     	mov	w19, w2
    47a8: f81f83a8     	stur	x8, [x29, #-0x8]
    47ac: f9400008     	ldr	x8, [x0]
    47b0: f9401908     	ldr	x8, [x8, #0x30]
    47b4: d63f0100     	blr	x8
    47b8: f94002a8     	ldr	x8, [x21]
    47bc: aa0003f6     	mov	x22, x0
    47c0: 90ffffe2     	adrp	x2, 0x0
    47c4: 9130f442     	add	x2, x2, #0xc3d
    47c8: 90ffffe3     	adrp	x3, 0x0
    47cc: 9131a463     	add	x3, x3, #0xc69
    47d0: aa1503e0     	mov	x0, x21
    47d4: aa1603e1     	mov	x1, x22
    47d8: f9417908     	ldr	x8, [x8, #0x2f0]
    47dc: d63f0100     	blr	x8
    47e0: f94002a8     	ldr	x8, [x21]
    47e4: 90fffff8     	adrp	x24, 0x0
    47e8: 9131ef18     	add	x24, x24, #0xc7b
    47ec: aa0003f7     	mov	x23, x0
    47f0: 90ffffe2     	adrp	x2, 0x0
    47f4: 912f3842     	add	x2, x2, #0xbce
    47f8: aa1503e0     	mov	x0, x21
    47fc: aa1603e1     	mov	x1, x22
    4800: f9417908     	ldr	x8, [x8, #0x2f0]
    4804: aa1803e3     	mov	x3, x24
    4808: d63f0100     	blr	x8
    480c: f94002a8     	ldr	x8, [x21]
    4810: aa0003f9     	mov	x25, x0
    4814: 90ffffe2     	adrp	x2, 0x0
    4818: 91319042     	add	x2, x2, #0xc64
    481c: aa1503e0     	mov	x0, x21
    4820: aa1603e1     	mov	x1, x22
    4824: aa1803e3     	mov	x3, x24
    4828: f9417908     	ldr	x8, [x8, #0x2f0]
    482c: d63f0100     	blr	x8
    4830: f94002a8     	ldr	x8, [x21]
    4834: aa0003f6     	mov	x22, x0
    4838: aa1503e0     	mov	x0, x21
    483c: aa1403e1     	mov	x1, x20
    4840: aa1703e2     	mov	x2, x23
    4844: f9417d08     	ldr	x8, [x8, #0x2f8]
    4848: d63f0100     	blr	x8
    484c: f94002a8     	ldr	x8, [x21]
    4850: aa0003f7     	mov	x23, x0
    4854: aa1503e0     	mov	x0, x21
    4858: aa1703e1     	mov	x1, x23
    485c: f942ad08     	ldr	x8, [x8, #0x558]
    4860: d63f0100     	blr	x8
    4864: f94002a8     	ldr	x8, [x21]
    4868: 2a0003f8     	mov	w24, w0
    486c: aa1503e0     	mov	x0, x21
    4870: aa1703e1     	mov	x1, x23
    4874: aa1f03e2     	mov	x2, xzr
    4878: f942e108     	ldr	x8, [x8, #0x5c0]
    487c: d63f0100     	blr	x8
    4880: f94002a8     	ldr	x8, [x21]
    4884: aa0003f7     	mov	x23, x0
    4888: aa1503e0     	mov	x0, x21
    488c: aa1403e1     	mov	x1, x20
    4890: aa1903e2     	mov	x2, x25
    4894: f9419108     	ldr	x8, [x8, #0x320]
    4898: d63f0100     	blr	x8
    489c: f94002a8     	ldr	x8, [x21]
    48a0: 2a0003f9     	mov	w25, w0
    48a4: aa1503e0     	mov	x0, x21
    48a8: aa1403e1     	mov	x1, x20
    48ac: aa1603e2     	mov	x2, x22
    48b0: f9419108     	ldr	x8, [x8, #0x320]
    48b4: d63f0100     	blr	x8
    48b8: 910033e8     	add	x8, sp, #0xc
    48bc: 290183ff     	stp	wzr, w0, [sp, #0xc]
    48c0: 91004100     	add	x0, x8, #0x10
    48c4: aa1703e1     	mov	x1, x23
    48c8: 52800183     	mov	w3, #0xc                // =12
    48cc: 93407f02     	sxtw	x2, w24
    48d0: 2902cfff     	stp	wzr, w19, [sp, #0x14]
    48d4: f801c3ff     	stur	xzr, [sp, #0x1c]
    48d8: 390093f8     	strb	w24, [sp, #0x24]
    48dc: 390097f9     	strb	w25, [sp, #0x25]
    48e0: 79004fff     	strh	wzr, [sp, #0x26]
    48e4: 9400008b     	bl	0x4b10 <__memcpy_chk@plt>
    48e8: 90000028     	adrp	x8, 0x8000
    48ec: 528a6081     	mov	w1, #0x5304             // =21252
    48f0: 910033e2     	add	x2, sp, #0xc
    48f4: 72b80381     	movk	w1, #0xc01c, lsl #16
    48f8: f940f508     	ldr	x8, [x8, #0x1e8]
    48fc: b9400100     	ldr	w0, [x8]
    4900: 94000074     	bl	0x4ad0 <ioctl@plt>
    4904: f841c3e3     	ldur	x3, [sp, #0x1c]
    4908: 528a6086     	mov	w6, #0x5304             // =21252
    490c: 394097e4     	ldrb	w4, [sp, #0x25]
    4910: 2a0003f3     	mov	w19, w0
    4914: b94013e5     	ldr	w5, [sp, #0x10]
    4918: 90ffffe1     	adrp	x1, 0x0
    491c: 9131f421     	add	x1, x1, #0xc7d
    4920: b9401be7     	ldr	w7, [sp, #0x18]
    4924: 90ffffe2     	adrp	x2, 0x0
    4928: 91283842     	add	x2, x2, #0xa0e
    492c: 52800060     	mov	w0, #0x3                // =3
    4930: 72b80386     	movk	w6, #0xc01c, lsl #16
    4934: 9400005f     	bl	0x4ab0 <__android_log_print@plt>
    4938: 37f80073     	tbnz	w19, #0x1f, 0x4944 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom+0x1d4>
    493c: 52800020     	mov	w0, #0x1                // =1
    4940: 1400000d     	b	0x4974 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom+0x204>
    4944: 9400006b     	bl	0x4af0 <__errno@plt>
    4948: b9400000     	ldr	w0, [x0]
    494c: 94000065     	bl	0x4ae0 <strerror@plt>
    4950: aa0003e4     	mov	x4, x0
    4954: 90ffffe1     	adrp	x1, 0x0
    4958: 9131f421     	add	x1, x1, #0xc7d
    495c: 90ffffe2     	adrp	x2, 0x0
    4960: 912fa042     	add	x2, x2, #0xbe8
    4964: 52800060     	mov	w0, #0x3                // =3
    4968: 2a1303e3     	mov	w3, w19
    496c: 94000051     	bl	0x4ab0 <__android_log_print@plt>
    4970: 2a1f03e0     	mov	w0, wzr
    4974: f9401748     	ldr	x8, [x26, #0x28]
    4978: f85f83a9     	ldur	x9, [x29, #-0x8]
    497c: eb09011f     	cmp	x8, x9
    4980: 54000101     	b.ne	0x49a0 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom+0x230>
    4984: a9474ff4     	ldp	x20, x19, [sp, #0x70]
    4988: a94657f6     	ldp	x22, x21, [sp, #0x60]
    498c: a9455ff8     	ldp	x24, x23, [sp, #0x50]
    4990: a94467fa     	ldp	x26, x25, [sp, #0x40]
    4994: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    4998: 910203ff     	add	sp, sp, #0x80
    499c: d65f03c0     	ret
    49a0: 94000060     	bl	0x4b20 <__stack_chk_fail@plt>
		...

00000000000049b0 <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule>:
    49b0: d10143ff     	sub	sp, sp, #0x50
    49b4: a9037bfd     	stp	x29, x30, [sp, #0x30]
    49b8: a9044ff4     	stp	x20, x19, [sp, #0x40]
    49bc: 9100c3fd     	add	x29, sp, #0x30
    49c0: 90000029     	adrp	x9, 0x8000
    49c4: d53bd054     	mrs	x20, TPIDR_EL0
    49c8: f9401688     	ldr	x8, [x20, #0x28]
    49cc: 528a6101     	mov	w1, #0x5308             // =21256
    49d0: 910023e2     	add	x2, sp, #0x8
    49d4: 72b80381     	movk	w1, #0xc01c, lsl #16
    49d8: f940f529     	ldr	x9, [x9, #0x1e8]
    49dc: f81f83a8     	stur	x8, [x29, #-0x8]
    49e0: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    49e4: b9400120     	ldr	w0, [x9]
    49e8: b90023ff     	str	wzr, [sp, #0x20]
    49ec: f9000fff     	str	xzr, [sp, #0x18]
    49f0: 94000038     	bl	0x4ad0 <ioctl@plt>
    49f4: 2a0003f3     	mov	w19, w0
    49f8: 528a6103     	mov	w3, #0x5308             // =21256
    49fc: 90ffffe1     	adrp	x1, 0x0
    4a00: 9131f421     	add	x1, x1, #0xc7d
    4a04: 90ffffe2     	adrp	x2, 0x0
    4a08: 91310042     	add	x2, x2, #0xc40
    4a0c: 52800060     	mov	w0, #0x3                // =3
    4a10: 72b80383     	movk	w3, #0xc01c, lsl #16
    4a14: 2a1303e4     	mov	w4, w19
    4a18: 94000026     	bl	0x4ab0 <__android_log_print@plt>
    4a1c: 37f80073     	tbnz	w19, #0x1f, 0x4a28 <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule+0x78>
    4a20: 52800020     	mov	w0, #0x1                // =1
    4a24: 1400000d     	b	0x4a58 <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule+0xa8>
    4a28: 94000032     	bl	0x4af0 <__errno@plt>
    4a2c: b9400000     	ldr	w0, [x0]
    4a30: 9400002c     	bl	0x4ae0 <strerror@plt>
    4a34: aa0003e4     	mov	x4, x0
    4a38: 90ffffe1     	adrp	x1, 0x0
    4a3c: 9131f421     	add	x1, x1, #0xc7d
    4a40: 90ffffe2     	adrp	x2, 0x0
    4a44: 912de442     	add	x2, x2, #0xb79
    4a48: 52800060     	mov	w0, #0x3                // =3
    4a4c: 2a1303e3     	mov	w3, w19
    4a50: 94000018     	bl	0x4ab0 <__android_log_print@plt>
    4a54: 2a1f03e0     	mov	w0, wzr
    4a58: f9401688     	ldr	x8, [x20, #0x28]
    4a5c: f85f83a9     	ldur	x9, [x29, #-0x8]
    4a60: eb09011f     	cmp	x8, x9
    4a64: 540000a1     	b.ne	0x4a78 <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule+0xc8>
    4a68: a9444ff4     	ldp	x20, x19, [sp, #0x40]
    4a6c: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    4a70: 910143ff     	add	sp, sp, #0x50
    4a74: d65f03c0     	ret
    4a78: 9400002a     	bl	0x4b20 <__stack_chk_fail@plt>

Disassembly of section .plt:

0000000000004a80 <.plt>:
    4a80: a9bf7bf0     	stp	x16, x30, [sp, #-0x10]!
    4a84: 90000030     	adrp	x16, 0x8000
    4a88: f9410211     	ldr	x17, [x16, #0x200]
    4a8c: 91080210     	add	x16, x16, #0x200
    4a90: d61f0220     	br	x17
    4a94: d503201f     	nop
    4a98: d503201f     	nop
    4a9c: d503201f     	nop

0000000000004aa0 <__cxa_finalize@plt>:
    4aa0: 90000030     	adrp	x16, 0x8000
    4aa4: f9410611     	ldr	x17, [x16, #0x208]
    4aa8: 91082210     	add	x16, x16, #0x208
    4aac: d61f0220     	br	x17

0000000000004ab0 <__android_log_print@plt>:
    4ab0: 90000030     	adrp	x16, 0x8000
    4ab4: f9410a11     	ldr	x17, [x16, #0x210]
    4ab8: 91084210     	add	x16, x16, #0x210
    4abc: d61f0220     	br	x17

0000000000004ac0 <close@plt>:
    4ac0: 90000030     	adrp	x16, 0x8000
    4ac4: f9410e11     	ldr	x17, [x16, #0x218]
    4ac8: 91086210     	add	x16, x16, #0x218
    4acc: d61f0220     	br	x17

0000000000004ad0 <ioctl@plt>:
    4ad0: 90000030     	adrp	x16, 0x8000
    4ad4: f9411211     	ldr	x17, [x16, #0x220]
    4ad8: 91088210     	add	x16, x16, #0x220
    4adc: d61f0220     	br	x17

0000000000004ae0 <strerror@plt>:
    4ae0: 90000030     	adrp	x16, 0x8000
    4ae4: f9411611     	ldr	x17, [x16, #0x228]
    4ae8: 9108a210     	add	x16, x16, #0x228
    4aec: d61f0220     	br	x17

0000000000004af0 <__errno@plt>:
    4af0: 90000030     	adrp	x16, 0x8000
    4af4: f9411a11     	ldr	x17, [x16, #0x230]
    4af8: 9108c210     	add	x16, x16, #0x230
    4afc: d61f0220     	br	x17

0000000000004b00 <__open_2@plt>:
    4b00: 90000030     	adrp	x16, 0x8000
    4b04: f9411e11     	ldr	x17, [x16, #0x238]
    4b08: 9108e210     	add	x16, x16, #0x238
    4b0c: d61f0220     	br	x17

0000000000004b10 <__memcpy_chk@plt>:
    4b10: 90000030     	adrp	x16, 0x8000
    4b14: f9412211     	ldr	x17, [x16, #0x240]
    4b18: 91090210     	add	x16, x16, #0x240
    4b1c: d61f0220     	br	x17

0000000000004b20 <__stack_chk_fail@plt>:
    4b20: 90000030     	adrp	x16, 0x8000
    4b24: f9412611     	ldr	x17, [x16, #0x248]
    4b28: 91092210     	add	x16, x16, #0x248
    4b2c: d61f0220     	br	x17
