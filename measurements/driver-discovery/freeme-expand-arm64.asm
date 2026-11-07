
work/expand-driver/libjni_freeme_expand.so:	file format elf64-littleaarch64

Disassembly of section .text:

0000000000001000 <.text>:
    1000: d503201f     	nop
    1004: 10007fe0     	adr	x0, 0x2000
    1008: 140002aa     	b	0x1ab0 <__cxa_finalize@plt>
    100c: 00000000     	udf	#0x0
    1010: d65f03c0     	ret
		...
    1020: 17fffffc     	b	0x1010 <.text+0x10>
		...

0000000000001030 <convert_to_long>:
    1030: f9400000     	ldr	x0, [x0]
    1034: d65f03c0     	ret
		...

0000000000001040 <Java_com_freeme_factory_cradle_ExpandGpio_open>:
    1040: d10143ff     	sub	sp, sp, #0x50
    1044: a9017bfd     	stp	x29, x30, [sp, #0x10]
    1048: f90013f7     	str	x23, [sp, #0x20]
    104c: a90357f6     	stp	x22, x21, [sp, #0x30]
    1050: a9044ff4     	stp	x20, x19, [sp, #0x40]
    1054: 910043fd     	add	x29, sp, #0x10
    1058: d53bd056     	mrs	x22, TPIDR_EL0
    105c: aa0203f4     	mov	x20, x2
    1060: f94016c8     	ldr	x8, [x22, #0x28]
    1064: 910013e2     	add	x2, sp, #0x4
    1068: aa1403e1     	mov	x1, x20
    106c: aa0003f3     	mov	x19, x0
    1070: f90007e8     	str	x8, [sp, #0x8]
    1074: f9400008     	ldr	x8, [x0]
    1078: 390013ff     	strb	wzr, [sp, #0x4]
    107c: f942a508     	ldr	x8, [x8, #0x548]
    1080: d63f0100     	blr	x8
    1084: 52800041     	mov	w1, #0x2                // =2
    1088: aa0003f5     	mov	x21, x0
    108c: 9400028d     	bl	0x1ac0 <__open_2@plt>
    1090: b0000017     	adrp	x23, 0x2000
    1094: 2a0003e3     	mov	w3, w0
    1098: f0ffffe1     	adrp	x1, 0x0
    109c: 9125a021     	add	x1, x1, #0x968
    10a0: d503201f     	nop
    10a4: 70ffcec2     	adr	x2, 0xa7f
    10a8: f940f6f7     	ldr	x23, [x23, #0x1e8]
    10ac: aa1503e4     	mov	x4, x21
    10b0: b90002e0     	str	w0, [x23]
    10b4: 52800060     	mov	w0, #0x3                // =3
    10b8: 94000286     	bl	0x1ad0 <__android_log_print@plt>
    10bc: f9400268     	ldr	x8, [x19]
    10c0: aa1303e0     	mov	x0, x19
    10c4: aa1403e1     	mov	x1, x20
    10c8: aa1503e2     	mov	x2, x21
    10cc: f942a908     	ldr	x8, [x8, #0x550]
    10d0: d63f0100     	blr	x8
    10d4: b94002f3     	ldr	w19, [x23]
    10d8: 3100067f     	cmn	w19, #0x1
    10dc: 540000e1     	b.ne	0x10f8 <Java_com_freeme_factory_cradle_ExpandGpio_open+0xb8>
    10e0: f0ffffe1     	adrp	x1, 0x0
    10e4: 9125a021     	add	x1, x1, #0x968
    10e8: f0ffffe2     	adrp	x2, 0x0
    10ec: 912a6442     	add	x2, x2, #0xa99
    10f0: 528000c0     	mov	w0, #0x6                // =6
    10f4: 94000277     	bl	0x1ad0 <__android_log_print@plt>
    10f8: f94016c8     	ldr	x8, [x22, #0x28]
    10fc: f94007e9     	ldr	x9, [sp, #0x8]
    1100: eb09011f     	cmp	x8, x9
    1104: 54000101     	b.ne	0x1124 <Java_com_freeme_factory_cradle_ExpandGpio_open+0xe4>
    1108: 2a1303e0     	mov	w0, w19
    110c: a9444ff4     	ldp	x20, x19, [sp, #0x40]
    1110: a94357f6     	ldp	x22, x21, [sp, #0x30]
    1114: f94013f7     	ldr	x23, [sp, #0x20]
    1118: a9417bfd     	ldp	x29, x30, [sp, #0x10]
    111c: 910143ff     	add	sp, sp, #0x50
    1120: d65f03c0     	ret
    1124: 9400026f     	bl	0x1ae0 <__stack_chk_fail@plt>
		...

0000000000001130 <Java_com_freeme_factory_cradle_ExpandGpio_close>:
    1130: a9be7bfd     	stp	x29, x30, [sp, #-0x20]!
    1134: f9000bf3     	str	x19, [sp, #0x10]
    1138: 910003fd     	mov	x29, sp
    113c: b0000013     	adrp	x19, 0x2000
    1140: f940f673     	ldr	x19, [x19, #0x1e8]
    1144: b9400263     	ldr	w3, [x19]
    1148: 3100047f     	cmn	w3, #0x1
    114c: 54000160     	b.eq	0x1178 <Java_com_freeme_factory_cradle_ExpandGpio_close+0x48>
    1150: f0ffffe1     	adrp	x1, 0x0
    1154: 9125a021     	add	x1, x1, #0x968
    1158: f0ffffe2     	adrp	x2, 0x0
    115c: 9126c042     	add	x2, x2, #0x9b0
    1160: 52800060     	mov	w0, #0x3                // =3
    1164: 9400025b     	bl	0x1ad0 <__android_log_print@plt>
    1168: b9400260     	ldr	w0, [x19]
    116c: 94000261     	bl	0x1af0 <close@plt>
    1170: 12800008     	mov	w8, #-0x1               // =-1
    1174: b9000268     	str	w8, [x19]
    1178: f9400bf3     	ldr	x19, [sp, #0x10]
    117c: a8c27bfd     	ldp	x29, x30, [sp], #0x20
    1180: d65f03c0     	ret
		...

0000000000001190 <Java_com_freeme_factory_cradle_ExpandGpio_getPosition>:
    1190: d10183ff     	sub	sp, sp, #0x60
    1194: a9037bfd     	stp	x29, x30, [sp, #0x30]
    1198: f90023f5     	str	x21, [sp, #0x40]
    119c: a9054ff4     	stp	x20, x19, [sp, #0x50]
    11a0: 9100c3fd     	add	x29, sp, #0x30
    11a4: b0000009     	adrp	x9, 0x2000
    11a8: d53bd055     	mrs	x21, TPIDR_EL0
    11ac: f94016a8     	ldr	x8, [x21, #0x28]
    11b0: 528a6121     	mov	w1, #0x5309             // =21257
    11b4: 2a0203f3     	mov	w19, w2
    11b8: 72b80381     	movk	w1, #0xc01c, lsl #16
    11bc: f940f529     	ldr	x9, [x9, #0x1e8]
    11c0: f81f83a8     	stur	x8, [x29, #-0x8]
    11c4: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    11c8: b9400120     	ldr	w0, [x9]
    11cc: b9000fe2     	str	w2, [sp, #0xc]
    11d0: 910023e2     	add	x2, sp, #0x8
    11d4: b90023ff     	str	wzr, [sp, #0x20]
    11d8: f9000fff     	str	xzr, [sp, #0x18]
    11dc: 94000249     	bl	0x1b00 <ioctl@plt>
    11e0: 37f80060     	tbnz	w0, #0x1f, 0x11ec <Java_com_freeme_factory_cradle_ExpandGpio_getPosition+0x5c>
    11e4: b94017e0     	ldr	w0, [sp, #0x14]
    11e8: 1400000f     	b	0x1224 <Java_com_freeme_factory_cradle_ExpandGpio_getPosition+0x94>
    11ec: 2a0003f4     	mov	w20, w0
    11f0: 94000248     	bl	0x1b10 <__errno@plt>
    11f4: b9400000     	ldr	w0, [x0]
    11f8: 9400024a     	bl	0x1b20 <strerror@plt>
    11fc: aa0003e5     	mov	x5, x0
    1200: f0ffffe1     	adrp	x1, 0x0
    1204: 9125a021     	add	x1, x1, #0x968
    1208: f0ffffe2     	adrp	x2, 0x0
    120c: 912f7842     	add	x2, x2, #0xbde
    1210: 52800060     	mov	w0, #0x3                // =3
    1214: 2a1303e3     	mov	w3, w19
    1218: 2a1403e4     	mov	w4, w20
    121c: 9400022d     	bl	0x1ad0 <__android_log_print@plt>
    1220: 12800000     	mov	w0, #-0x1               // =-1
    1224: f94016a8     	ldr	x8, [x21, #0x28]
    1228: f85f83a9     	ldur	x9, [x29, #-0x8]
    122c: eb09011f     	cmp	x8, x9
    1230: 540000c1     	b.ne	0x1248 <Java_com_freeme_factory_cradle_ExpandGpio_getPosition+0xb8>
    1234: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    1238: f94023f5     	ldr	x21, [sp, #0x40]
    123c: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    1240: 910183ff     	add	sp, sp, #0x60
    1244: d65f03c0     	ret
    1248: 94000226     	bl	0x1ae0 <__stack_chk_fail@plt>
    124c: 00000000     	udf	#0x0

0000000000001250 <Java_com_freeme_factory_cradle_ExpandGpio_setPower>:
    1250: d10183ff     	sub	sp, sp, #0x60
    1254: a9037bfd     	stp	x29, x30, [sp, #0x30]
    1258: f90023f5     	str	x21, [sp, #0x40]
    125c: a9054ff4     	stp	x20, x19, [sp, #0x50]
    1260: 9100c3fd     	add	x29, sp, #0x30
    1264: d53bd055     	mrs	x21, TPIDR_EL0
    1268: 528a6021     	mov	w1, #0x5301             // =21249
    126c: f94016a8     	ldr	x8, [x21, #0x28]
    1270: 72001c7f     	tst	w3, #0xff
    1274: 1a9f07e9     	cset	w9, ne
    1278: 72b80381     	movk	w1, #0xc01c, lsl #16
    127c: f81f83a8     	stur	x8, [x29, #-0x8]
    1280: b0000008     	adrp	x8, 0x2000
    1284: f940f508     	ldr	x8, [x8, #0x1e8]
    1288: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    128c: 29020be9     	stp	w9, w2, [sp, #0x10]
    1290: 910023e2     	add	x2, sp, #0x8
    1294: b90023ff     	str	wzr, [sp, #0x20]
    1298: b9400100     	ldr	w0, [x8]
    129c: f9000fff     	str	xzr, [sp, #0x18]
    12a0: 390083ff     	strb	wzr, [sp, #0x20]
    12a4: 94000217     	bl	0x1b00 <ioctl@plt>
    12a8: 37f80060     	tbnz	w0, #0x1f, 0x12b4 <Java_com_freeme_factory_cradle_ExpandGpio_setPower+0x64>
    12ac: 52800020     	mov	w0, #0x1                // =1
    12b0: 14000010     	b	0x12f0 <Java_com_freeme_factory_cradle_ExpandGpio_setPower+0xa0>
    12b4: b94013f4     	ldr	w20, [sp, #0x10]
    12b8: 2a0003f3     	mov	w19, w0
    12bc: 94000215     	bl	0x1b10 <__errno@plt>
    12c0: b9400000     	ldr	w0, [x0]
    12c4: 94000217     	bl	0x1b20 <strerror@plt>
    12c8: aa0003e5     	mov	x5, x0
    12cc: f0ffffe1     	adrp	x1, 0x0
    12d0: 9125a021     	add	x1, x1, #0x968
    12d4: f0ffffe2     	adrp	x2, 0x0
    12d8: 91304042     	add	x2, x2, #0xc10
    12dc: 52800060     	mov	w0, #0x3                // =3
    12e0: 2a1403e3     	mov	w3, w20
    12e4: 2a1303e4     	mov	w4, w19
    12e8: 940001fa     	bl	0x1ad0 <__android_log_print@plt>
    12ec: 2a1f03e0     	mov	w0, wzr
    12f0: f94016a8     	ldr	x8, [x21, #0x28]
    12f4: f85f83a9     	ldur	x9, [x29, #-0x8]
    12f8: eb09011f     	cmp	x8, x9
    12fc: 540000c1     	b.ne	0x1314 <Java_com_freeme_factory_cradle_ExpandGpio_setPower+0xc4>
    1300: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    1304: f94023f5     	ldr	x21, [sp, #0x40]
    1308: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    130c: 910183ff     	add	sp, sp, #0x60
    1310: d65f03c0     	ret
    1314: 940001f3     	bl	0x1ae0 <__stack_chk_fail@plt>
		...

0000000000001320 <Java_com_freeme_factory_cradle_ExpandGpio_getType>:
    1320: d10183ff     	sub	sp, sp, #0x60
    1324: a9037bfd     	stp	x29, x30, [sp, #0x30]
    1328: f90023f5     	str	x21, [sp, #0x40]
    132c: a9054ff4     	stp	x20, x19, [sp, #0x50]
    1330: 9100c3fd     	add	x29, sp, #0x30
    1334: b0000009     	adrp	x9, 0x2000
    1338: d53bd055     	mrs	x21, TPIDR_EL0
    133c: f94016a8     	ldr	x8, [x21, #0x28]
    1340: 528a6141     	mov	w1, #0x530a             // =21258
    1344: 2a0203f3     	mov	w19, w2
    1348: 72b80381     	movk	w1, #0xc01c, lsl #16
    134c: f940f529     	ldr	x9, [x9, #0x1e8]
    1350: f81f83a8     	stur	x8, [x29, #-0x8]
    1354: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    1358: b9400120     	ldr	w0, [x9]
    135c: b90017e2     	str	w2, [sp, #0x14]
    1360: 910023e2     	add	x2, sp, #0x8
    1364: b90023ff     	str	wzr, [sp, #0x20]
    1368: f9000fff     	str	xzr, [sp, #0x18]
    136c: 940001e5     	bl	0x1b00 <ioctl@plt>
    1370: 37f80060     	tbnz	w0, #0x1f, 0x137c <Java_com_freeme_factory_cradle_ExpandGpio_getType+0x5c>
    1374: b9400fe0     	ldr	w0, [sp, #0xc]
    1378: 1400000f     	b	0x13b4 <Java_com_freeme_factory_cradle_ExpandGpio_getType+0x94>
    137c: 2a0003f4     	mov	w20, w0
    1380: 940001e4     	bl	0x1b10 <__errno@plt>
    1384: b9400000     	ldr	w0, [x0]
    1388: 940001e6     	bl	0x1b20 <strerror@plt>
    138c: aa0003e5     	mov	x5, x0
    1390: f0ffffe1     	adrp	x1, 0x0
    1394: 9125a021     	add	x1, x1, #0x968
    1398: f0ffffe2     	adrp	x2, 0x0
    139c: 9130ec42     	add	x2, x2, #0xc3b
    13a0: 52800060     	mov	w0, #0x3                // =3
    13a4: 2a1303e3     	mov	w3, w19
    13a8: 2a1403e4     	mov	w4, w20
    13ac: 940001c9     	bl	0x1ad0 <__android_log_print@plt>
    13b0: 12800000     	mov	w0, #-0x1               // =-1
    13b4: f94016a8     	ldr	x8, [x21, #0x28]
    13b8: f85f83a9     	ldur	x9, [x29, #-0x8]
    13bc: eb09011f     	cmp	x8, x9
    13c0: 540000c1     	b.ne	0x13d8 <Java_com_freeme_factory_cradle_ExpandGpio_getType+0xb8>
    13c4: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    13c8: f94023f5     	ldr	x21, [sp, #0x40]
    13cc: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    13d0: 910183ff     	add	sp, sp, #0x60
    13d4: d65f03c0     	ret
    13d8: 940001c2     	bl	0x1ae0 <__stack_chk_fail@plt>
    13dc: 00000000     	udf	#0x0

00000000000013e0 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo>:
    13e0: d10183ff     	sub	sp, sp, #0x60
    13e4: a9037bfd     	stp	x29, x30, [sp, #0x30]
    13e8: a90457f6     	stp	x22, x21, [sp, #0x40]
    13ec: a9054ff4     	stp	x20, x19, [sp, #0x50]
    13f0: 9100c3fd     	add	x29, sp, #0x30
    13f4: d53bd056     	mrs	x22, TPIDR_EL0
    13f8: 528a6041     	mov	w1, #0x5302             // =21250
    13fc: f94016c8     	ldr	x8, [x22, #0x28]
    1400: 72001c9f     	tst	w4, #0xff
    1404: 1a9f07e9     	cset	w9, ne
    1408: 72b80381     	movk	w1, #0xc01c, lsl #16
    140c: 2a0303f3     	mov	w19, w3
    1410: f81f83a8     	stur	x8, [x29, #-0x8]
    1414: b0000008     	adrp	x8, 0x2000
    1418: f940f508     	ldr	x8, [x8, #0x1e8]
    141c: 29020be9     	stp	w9, w2, [sp, #0x10]
    1420: 910023e2     	add	x2, sp, #0x8
    1424: b90023ff     	str	wzr, [sp, #0x20]
    1428: 29017fe3     	stp	w3, wzr, [sp, #0x8]
    142c: b9400100     	ldr	w0, [x8]
    1430: f9000fff     	str	xzr, [sp, #0x18]
    1434: 390087ff     	strb	wzr, [sp, #0x21]
    1438: 940001b2     	bl	0x1b00 <ioctl@plt>
    143c: 37f80060     	tbnz	w0, #0x1f, 0x1448 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo+0x68>
    1440: 52800020     	mov	w0, #0x1                // =1
    1444: 14000011     	b	0x1488 <Java_com_freeme_factory_cradle_ExpandGpio_writeIo+0xa8>
    1448: b94013f5     	ldr	w21, [sp, #0x10]
    144c: 2a0003f4     	mov	w20, w0
    1450: 940001b0     	bl	0x1b10 <__errno@plt>
    1454: b9400000     	ldr	w0, [x0]
    1458: 940001b2     	bl	0x1b20 <strerror@plt>
    145c: aa0003e6     	mov	x6, x0
    1460: f0ffffe1     	adrp	x1, 0x0
    1464: 9125a021     	add	x1, x1, #0x968
    1468: f0ffffe2     	adrp	x2, 0x0
    146c: 912eb042     	add	x2, x2, #0xbac
    1470: 52800060     	mov	w0, #0x3                // =3
    1474: 2a1303e3     	mov	w3, w19
    1478: 2a1503e4     	mov	w4, w21
    147c: 2a1403e5     	mov	w5, w20
    1480: 94000194     	bl	0x1ad0 <__android_log_print@plt>
    1484: 2a1f03e0     	mov	w0, wzr
    1488: f94016c8     	ldr	x8, [x22, #0x28]
    148c: f85f83a9     	ldur	x9, [x29, #-0x8]
    1490: eb09011f     	cmp	x8, x9
    1494: 540000c1     	b.ne	0x14ac <Java_com_freeme_factory_cradle_ExpandGpio_writeIo+0xcc>
    1498: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    149c: a94457f6     	ldp	x22, x21, [sp, #0x40]
    14a0: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    14a4: 910183ff     	add	sp, sp, #0x60
    14a8: d65f03c0     	ret
    14ac: 9400018d     	bl	0x1ae0 <__stack_chk_fail@plt>

00000000000014b0 <Java_com_freeme_factory_cradle_ExpandGpio_readIo>:
    14b0: d10183ff     	sub	sp, sp, #0x60
    14b4: a9037bfd     	stp	x29, x30, [sp, #0x30]
    14b8: f90023f5     	str	x21, [sp, #0x40]
    14bc: a9054ff4     	stp	x20, x19, [sp, #0x50]
    14c0: 9100c3fd     	add	x29, sp, #0x30
    14c4: b0000009     	adrp	x9, 0x2000
    14c8: d53bd055     	mrs	x21, TPIDR_EL0
    14cc: f94016a8     	ldr	x8, [x21, #0x28]
    14d0: 528a6061     	mov	w1, #0x5303             // =21251
    14d4: 72b80381     	movk	w1, #0xc01c, lsl #16
    14d8: 2a0303f3     	mov	w19, w3
    14dc: f940f529     	ldr	x9, [x9, #0x1e8]
    14e0: f81f83a8     	stur	x8, [x29, #-0x8]
    14e4: 29020bff     	stp	wzr, w2, [sp, #0x10]
    14e8: 910023e2     	add	x2, sp, #0x8
    14ec: b9400120     	ldr	w0, [x9]
    14f0: b90023ff     	str	wzr, [sp, #0x20]
    14f4: 29017fe3     	stp	w3, wzr, [sp, #0x8]
    14f8: f9000fff     	str	xzr, [sp, #0x18]
    14fc: 390087ff     	strb	wzr, [sp, #0x21]
    1500: 94000180     	bl	0x1b00 <ioctl@plt>
    1504: 37f800a0     	tbnz	w0, #0x1f, 0x1518 <Java_com_freeme_factory_cradle_ExpandGpio_readIo+0x68>
    1508: b94013e8     	ldr	w8, [sp, #0x10]
    150c: 7100011f     	cmp	w8, #0x0
    1510: 1a9f17e0     	cset	w0, eq
    1514: 1400000f     	b	0x1550 <Java_com_freeme_factory_cradle_ExpandGpio_readIo+0xa0>
    1518: 2a0003f4     	mov	w20, w0
    151c: 9400017d     	bl	0x1b10 <__errno@plt>
    1520: b9400000     	ldr	w0, [x0]
    1524: 9400017f     	bl	0x1b20 <strerror@plt>
    1528: aa0003e5     	mov	x5, x0
    152c: f0ffffe1     	adrp	x1, 0x0
    1530: 9125a021     	add	x1, x1, #0x968
    1534: f0ffffe2     	adrp	x2, 0x0
    1538: 912c9842     	add	x2, x2, #0xb26
    153c: 52800060     	mov	w0, #0x3                // =3
    1540: 2a1303e3     	mov	w3, w19
    1544: 2a1403e4     	mov	w4, w20
    1548: 94000162     	bl	0x1ad0 <__android_log_print@plt>
    154c: 2a1f03e0     	mov	w0, wzr
    1550: f94016a8     	ldr	x8, [x21, #0x28]
    1554: f85f83a9     	ldur	x9, [x29, #-0x8]
    1558: eb09011f     	cmp	x8, x9
    155c: 540000c1     	b.ne	0x1574 <Java_com_freeme_factory_cradle_ExpandGpio_readIo+0xc4>
    1560: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    1564: f94023f5     	ldr	x21, [sp, #0x40]
    1568: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    156c: 910183ff     	add	sp, sp, #0x60
    1570: d65f03c0     	ret
    1574: 9400015b     	bl	0x1ae0 <__stack_chk_fail@plt>
		...

0000000000001580 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom>:
    1580: d101c3ff     	sub	sp, sp, #0x70
    1584: a9037bfd     	stp	x29, x30, [sp, #0x30]
    1588: a9045ff8     	stp	x24, x23, [sp, #0x40]
    158c: a90557f6     	stp	x22, x21, [sp, #0x50]
    1590: a9064ff4     	stp	x20, x19, [sp, #0x60]
    1594: 9100c3fd     	add	x29, sp, #0x30
    1598: b0000009     	adrp	x9, 0x2000
    159c: d53bd057     	mrs	x23, TPIDR_EL0
    15a0: f94016e8     	ldr	x8, [x23, #0x28]
    15a4: aa0003f3     	mov	x19, x0
    15a8: 528a60a1     	mov	w1, #0x5305             // =21253
    15ac: 910023f8     	add	x24, sp, #0x8
    15b0: f940f529     	ldr	x9, [x9, #0x1e8]
    15b4: 72b80381     	movk	w1, #0xc01c, lsl #16
    15b8: f81f83a8     	stur	x8, [x29, #-0x8]
    15bc: 52800108     	mov	w8, #0x8                // =8
    15c0: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    15c4: b9400120     	ldr	w0, [x9]
    15c8: b90017e2     	str	w2, [sp, #0x14]
    15cc: 910023e2     	add	x2, sp, #0x8
    15d0: b90023ff     	str	wzr, [sp, #0x20]
    15d4: f9000fff     	str	xzr, [sp, #0x18]
    15d8: 390083e8     	strb	w8, [sp, #0x20]
    15dc: 94000149     	bl	0x1b00 <ioctl@plt>
    15e0: 37f80720     	tbnz	w0, #0x1f, 0x16c4 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x144>
    15e4: f9400fe3     	ldr	x3, [sp, #0x18]
    15e8: 528a60a6     	mov	w6, #0x5305             // =21253
    15ec: 394087e4     	ldrb	w4, [sp, #0x21]
    15f0: f0ffffe1     	adrp	x1, 0x0
    15f4: 9125a021     	add	x1, x1, #0x968
    15f8: b9400fe5     	ldr	w5, [sp, #0xc]
    15fc: b94017e7     	ldr	w7, [sp, #0x14]
    1600: f0ffffe2     	adrp	x2, 0x0
    1604: 912b8842     	add	x2, x2, #0xae2
    1608: 72b80386     	movk	w6, #0xc01c, lsl #16
    160c: 52800060     	mov	w0, #0x3                // =3
    1610: 94000130     	bl	0x1ad0 <__android_log_print@plt>
    1614: f9400268     	ldr	x8, [x19]
    1618: f0ffffe1     	adrp	x1, 0x0
    161c: 912d3021     	add	x1, x1, #0xb4c
    1620: aa1303e0     	mov	x0, x19
    1624: f9401908     	ldr	x8, [x8, #0x30]
    1628: d63f0100     	blr	x8
    162c: b4000660     	cbz	x0, 0x16f8 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x178>
    1630: f9400268     	ldr	x8, [x19]
    1634: aa0003f4     	mov	x20, x0
    1638: f0ffffe2     	adrp	x2, 0x0
    163c: 91287842     	add	x2, x2, #0xa1e
    1640: f0ffffe3     	adrp	x3, 0x0
    1644: 91268c63     	add	x3, x3, #0x9a3
    1648: aa1303e0     	mov	x0, x19
    164c: aa1403e1     	mov	x1, x20
    1650: f9408508     	ldr	x8, [x8, #0x108]
    1654: d63f0100     	blr	x8
    1658: b40005a0     	cbz	x0, 0x170c <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x18c>
    165c: f9400268     	ldr	x8, [x19]
    1660: aa0003f5     	mov	x21, x0
    1664: aa1303e0     	mov	x0, x19
    1668: 52800101     	mov	w1, #0x8                // =8
    166c: f942c108     	ldr	x8, [x8, #0x580]
    1670: d63f0100     	blr	x8
    1674: b4000560     	cbz	x0, 0x1720 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1a0>
    1678: f9400268     	ldr	x8, [x19]
    167c: aa0003f6     	mov	x22, x0
    1680: 91004304     	add	x4, x24, #0x10
    1684: aa1303e0     	mov	x0, x19
    1688: aa1603e1     	mov	x1, x22
    168c: 2a1f03e2     	mov	w2, wzr
    1690: 52800103     	mov	w3, #0x8                // =8
    1694: f9434108     	ldr	x8, [x8, #0x680]
    1698: d63f0100     	blr	x8
    169c: f9400268     	ldr	x8, [x19]
    16a0: aa1303e0     	mov	x0, x19
    16a4: 394087e4     	ldrb	w4, [sp, #0x21]
    16a8: aa1403e1     	mov	x1, x20
    16ac: b9400fe5     	ldr	w5, [sp, #0xc]
    16b0: aa1503e2     	mov	x2, x21
    16b4: aa1603e3     	mov	x3, x22
    16b8: f9407108     	ldr	x8, [x8, #0xe0]
    16bc: d63f0100     	blr	x8
    16c0: 1400001f     	b	0x173c <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1bc>
    16c4: 2a0003f4     	mov	w20, w0
    16c8: 94000112     	bl	0x1b10 <__errno@plt>
    16cc: b9400000     	ldr	w0, [x0]
    16d0: 94000114     	bl	0x1b20 <strerror@plt>
    16d4: aa0003e4     	mov	x4, x0
    16d8: f0ffffe1     	adrp	x1, 0x0
    16dc: 9125a021     	add	x1, x1, #0x968
    16e0: f0ffffe2     	adrp	x2, 0x0
    16e4: 91289442     	add	x2, x2, #0xa25
    16e8: 52800060     	mov	w0, #0x3                // =3
    16ec: 2a1403e3     	mov	w3, w20
    16f0: 940000f8     	bl	0x1ad0 <__android_log_print@plt>
    16f4: 14000011     	b	0x1738 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1b8>
    16f8: f0ffffe1     	adrp	x1, 0x0
    16fc: 9125a021     	add	x1, x1, #0x968
    1700: f0ffffe2     	adrp	x2, 0x0
    1704: 9125cc42     	add	x2, x2, #0x973
    1708: 1400000a     	b	0x1730 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1b0>
    170c: f0ffffe1     	adrp	x1, 0x0
    1710: 9125a021     	add	x1, x1, #0x968
    1714: f0ffffe2     	adrp	x2, 0x0
    1718: 9126fc42     	add	x2, x2, #0x9bf
    171c: 14000005     	b	0x1730 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1b0>
    1720: f0ffffe1     	adrp	x1, 0x0
    1724: 9125a021     	add	x1, x1, #0x968
    1728: f0ffffe2     	adrp	x2, 0x0
    172c: 912aac42     	add	x2, x2, #0xaab
    1730: 52800060     	mov	w0, #0x3                // =3
    1734: 940000e7     	bl	0x1ad0 <__android_log_print@plt>
    1738: aa1f03e0     	mov	x0, xzr
    173c: f94016e8     	ldr	x8, [x23, #0x28]
    1740: f85f83a9     	ldur	x9, [x29, #-0x8]
    1744: eb09011f     	cmp	x8, x9
    1748: 540000e1     	b.ne	0x1764 <Java_com_freeme_factory_cradle_ExpandGpio_readEeprom+0x1e4>
    174c: a9464ff4     	ldp	x20, x19, [sp, #0x60]
    1750: a94557f6     	ldp	x22, x21, [sp, #0x50]
    1754: a9445ff8     	ldp	x24, x23, [sp, #0x40]
    1758: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    175c: 9101c3ff     	add	sp, sp, #0x70
    1760: d65f03c0     	ret
    1764: 940000df     	bl	0x1ae0 <__stack_chk_fail@plt>
		...

0000000000001770 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom>:
    1770: d10203ff     	sub	sp, sp, #0x80
    1774: a9037bfd     	stp	x29, x30, [sp, #0x30]
    1778: a90467fa     	stp	x26, x25, [sp, #0x40]
    177c: a9055ff8     	stp	x24, x23, [sp, #0x50]
    1780: a90657f6     	stp	x22, x21, [sp, #0x60]
    1784: a9074ff4     	stp	x20, x19, [sp, #0x70]
    1788: 9100c3fd     	add	x29, sp, #0x30
    178c: d53bd05a     	mrs	x26, TPIDR_EL0
    1790: f0ffffe1     	adrp	x1, 0x0
    1794: 912d3021     	add	x1, x1, #0xb4c
    1798: f9401748     	ldr	x8, [x26, #0x28]
    179c: aa0303f4     	mov	x20, x3
    17a0: aa0003f5     	mov	x21, x0
    17a4: 2a0203f3     	mov	w19, w2
    17a8: f81f83a8     	stur	x8, [x29, #-0x8]
    17ac: f9400008     	ldr	x8, [x0]
    17b0: f9401908     	ldr	x8, [x8, #0x30]
    17b4: d63f0100     	blr	x8
    17b8: f94002a8     	ldr	x8, [x21]
    17bc: aa0003f6     	mov	x22, x0
    17c0: f0ffffe2     	adrp	x2, 0x0
    17c4: 9125c042     	add	x2, x2, #0x970
    17c8: f0ffffe3     	adrp	x3, 0x0
    17cc: 9126ac63     	add	x3, x3, #0x9ab
    17d0: aa1503e0     	mov	x0, x21
    17d4: aa1603e1     	mov	x1, x22
    17d8: f9417908     	ldr	x8, [x8, #0x2f0]
    17dc: d63f0100     	blr	x8
    17e0: f94002a8     	ldr	x8, [x21]
    17e4: f0fffff8     	adrp	x24, 0x0
    17e8: 9126bb18     	add	x24, x24, #0x9ae
    17ec: aa0003f7     	mov	x23, x0
    17f0: f0ffffe2     	adrp	x2, 0x0
    17f4: 912df042     	add	x2, x2, #0xb7c
    17f8: aa1503e0     	mov	x0, x21
    17fc: aa1603e1     	mov	x1, x22
    1800: f9417908     	ldr	x8, [x8, #0x2f0]
    1804: aa1803e3     	mov	x3, x24
    1808: d63f0100     	blr	x8
    180c: f94002a8     	ldr	x8, [x21]
    1810: aa0003f9     	mov	x25, x0
    1814: f0ffffe2     	adrp	x2, 0x0
    1818: 9127d442     	add	x2, x2, #0x9f5
    181c: aa1503e0     	mov	x0, x21
    1820: aa1603e1     	mov	x1, x22
    1824: aa1803e3     	mov	x3, x24
    1828: f9417908     	ldr	x8, [x8, #0x2f0]
    182c: d63f0100     	blr	x8
    1830: f94002a8     	ldr	x8, [x21]
    1834: aa0003f6     	mov	x22, x0
    1838: aa1503e0     	mov	x0, x21
    183c: aa1403e1     	mov	x1, x20
    1840: aa1703e2     	mov	x2, x23
    1844: f9417d08     	ldr	x8, [x8, #0x2f8]
    1848: d63f0100     	blr	x8
    184c: f94002a8     	ldr	x8, [x21]
    1850: aa0003f7     	mov	x23, x0
    1854: aa1503e0     	mov	x0, x21
    1858: aa1703e1     	mov	x1, x23
    185c: f942ad08     	ldr	x8, [x8, #0x558]
    1860: d63f0100     	blr	x8
    1864: f94002a8     	ldr	x8, [x21]
    1868: 2a0003f8     	mov	w24, w0
    186c: aa1503e0     	mov	x0, x21
    1870: aa1703e1     	mov	x1, x23
    1874: aa1f03e2     	mov	x2, xzr
    1878: f942e108     	ldr	x8, [x8, #0x5c0]
    187c: d63f0100     	blr	x8
    1880: f94002a8     	ldr	x8, [x21]
    1884: aa0003f7     	mov	x23, x0
    1888: aa1503e0     	mov	x0, x21
    188c: aa1403e1     	mov	x1, x20
    1890: aa1903e2     	mov	x2, x25
    1894: f9419108     	ldr	x8, [x8, #0x320]
    1898: d63f0100     	blr	x8
    189c: f94002a8     	ldr	x8, [x21]
    18a0: 2a0003f9     	mov	w25, w0
    18a4: aa1503e0     	mov	x0, x21
    18a8: aa1403e1     	mov	x1, x20
    18ac: aa1603e2     	mov	x2, x22
    18b0: f9419108     	ldr	x8, [x8, #0x320]
    18b4: d63f0100     	blr	x8
    18b8: 910023e8     	add	x8, sp, #0x8
    18bc: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    18c0: b9000fe0     	str	w0, [sp, #0xc]
    18c4: 91004100     	add	x0, x8, #0x10
    18c8: aa1703e1     	mov	x1, x23
    18cc: 52800183     	mov	w3, #0xc                // =12
    18d0: 93407f02     	sxtw	x2, w24
    18d4: b90023ff     	str	wzr, [sp, #0x20]
    18d8: f9000fff     	str	xzr, [sp, #0x18]
    18dc: b90017f3     	str	w19, [sp, #0x14]
    18e0: 390083f8     	strb	w24, [sp, #0x20]
    18e4: 390087f9     	strb	w25, [sp, #0x21]
    18e8: 94000092     	bl	0x1b30 <__memcpy_chk@plt>
    18ec: b0000008     	adrp	x8, 0x2000
    18f0: 528a6094     	mov	w20, #0x5304            // =21252
    18f4: 72b80394     	movk	w20, #0xc01c, lsl #16
    18f8: 910023e2     	add	x2, sp, #0x8
    18fc: 2a1403e1     	mov	w1, w20
    1900: f940f508     	ldr	x8, [x8, #0x1e8]
    1904: b9400100     	ldr	w0, [x8]
    1908: 9400007e     	bl	0x1b00 <ioctl@plt>
    190c: f9400fe3     	ldr	x3, [sp, #0x18]
    1910: 2a0003f3     	mov	w19, w0
    1914: 394087e4     	ldrb	w4, [sp, #0x21]
    1918: f0ffffe1     	adrp	x1, 0x0
    191c: 9125a021     	add	x1, x1, #0x968
    1920: b9400fe5     	ldr	w5, [sp, #0xc]
    1924: b94017e7     	ldr	w7, [sp, #0x14]
    1928: f0ffffe2     	adrp	x2, 0x0
    192c: 912b8842     	add	x2, x2, #0xae2
    1930: 52800060     	mov	w0, #0x3                // =3
    1934: aa1403e6     	mov	x6, x20
    1938: 94000066     	bl	0x1ad0 <__android_log_print@plt>
    193c: 37f80073     	tbnz	w19, #0x1f, 0x1948 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom+0x1d8>
    1940: 52800020     	mov	w0, #0x1                // =1
    1944: 1400000d     	b	0x1978 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom+0x208>
    1948: 94000072     	bl	0x1b10 <__errno@plt>
    194c: b9400000     	ldr	w0, [x0]
    1950: 94000074     	bl	0x1b20 <strerror@plt>
    1954: aa0003e4     	mov	x4, x0
    1958: f0ffffe1     	adrp	x1, 0x0
    195c: 9125a021     	add	x1, x1, #0x968
    1960: f0ffffe2     	adrp	x2, 0x0
    1964: 912e1042     	add	x2, x2, #0xb84
    1968: 52800060     	mov	w0, #0x3                // =3
    196c: 2a1303e3     	mov	w3, w19
    1970: 94000058     	bl	0x1ad0 <__android_log_print@plt>
    1974: 2a1f03e0     	mov	w0, wzr
    1978: f9401748     	ldr	x8, [x26, #0x28]
    197c: f85f83a9     	ldur	x9, [x29, #-0x8]
    1980: eb09011f     	cmp	x8, x9
    1984: 54000101     	b.ne	0x19a4 <Java_com_freeme_factory_cradle_ExpandGpio_writeEeprom+0x234>
    1988: a9474ff4     	ldp	x20, x19, [sp, #0x70]
    198c: a94657f6     	ldp	x22, x21, [sp, #0x60]
    1990: a9455ff8     	ldp	x24, x23, [sp, #0x50]
    1994: a94467fa     	ldp	x26, x25, [sp, #0x40]
    1998: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    199c: 910203ff     	add	sp, sp, #0x80
    19a0: d65f03c0     	ret
    19a4: 9400004f     	bl	0x1ae0 <__stack_chk_fail@plt>
		...

00000000000019b0 <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule>:
    19b0: d10183ff     	sub	sp, sp, #0x60
    19b4: a9037bfd     	stp	x29, x30, [sp, #0x30]
    19b8: f90023f5     	str	x21, [sp, #0x40]
    19bc: a9054ff4     	stp	x20, x19, [sp, #0x50]
    19c0: 9100c3fd     	add	x29, sp, #0x30
    19c4: b0000009     	adrp	x9, 0x2000
    19c8: d53bd055     	mrs	x21, TPIDR_EL0
    19cc: f94016a8     	ldr	x8, [x21, #0x28]
    19d0: 528a6114     	mov	w20, #0x5308            // =21256
    19d4: 72b80394     	movk	w20, #0xc01c, lsl #16
    19d8: 910023e2     	add	x2, sp, #0x8
    19dc: f940f529     	ldr	x9, [x9, #0x1e8]
    19e0: 2a1403e1     	mov	w1, w20
    19e4: f81f83a8     	stur	x8, [x29, #-0x8]
    19e8: a900ffff     	stp	xzr, xzr, [sp, #0x8]
    19ec: b9400120     	ldr	w0, [x9]
    19f0: b90023ff     	str	wzr, [sp, #0x20]
    19f4: f9000fff     	str	xzr, [sp, #0x18]
    19f8: 94000042     	bl	0x1b00 <ioctl@plt>
    19fc: 2a0003f3     	mov	w19, w0
    1a00: f0ffffe1     	adrp	x1, 0x0
    1a04: 9125a021     	add	x1, x1, #0x968
    1a08: f0ffffe2     	adrp	x2, 0x0
    1a0c: 9127e842     	add	x2, x2, #0x9fa
    1a10: 52800060     	mov	w0, #0x3                // =3
    1a14: aa1403e3     	mov	x3, x20
    1a18: 2a1303e4     	mov	w4, w19
    1a1c: 9400002d     	bl	0x1ad0 <__android_log_print@plt>
    1a20: 37f80073     	tbnz	w19, #0x1f, 0x1a2c <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule+0x7c>
    1a24: 52800020     	mov	w0, #0x1                // =1
    1a28: 1400000d     	b	0x1a5c <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule+0xac>
    1a2c: 94000039     	bl	0x1b10 <__errno@plt>
    1a30: b9400000     	ldr	w0, [x0]
    1a34: 9400003b     	bl	0x1b20 <strerror@plt>
    1a38: aa0003e4     	mov	x4, x0
    1a3c: f0ffffe1     	adrp	x1, 0x0
    1a40: 9125a021     	add	x1, x1, #0x968
    1a44: f0ffffe2     	adrp	x2, 0x0
    1a48: 91293042     	add	x2, x2, #0xa4c
    1a4c: 52800060     	mov	w0, #0x3                // =3
    1a50: 2a1303e3     	mov	w3, w19
    1a54: 9400001f     	bl	0x1ad0 <__android_log_print@plt>
    1a58: 2a1f03e0     	mov	w0, wzr
    1a5c: f94016a8     	ldr	x8, [x21, #0x28]
    1a60: f85f83a9     	ldur	x9, [x29, #-0x8]
    1a64: eb09011f     	cmp	x8, x9
    1a68: 540000c1     	b.ne	0x1a80 <Java_com_freeme_factory_cradle_ExpandGpio_recognizeModule+0xd0>
    1a6c: a9454ff4     	ldp	x20, x19, [sp, #0x50]
    1a70: f94023f5     	ldr	x21, [sp, #0x40]
    1a74: a9437bfd     	ldp	x29, x30, [sp, #0x30]
    1a78: 910183ff     	add	sp, sp, #0x60
    1a7c: d65f03c0     	ret
    1a80: 94000018     	bl	0x1ae0 <__stack_chk_fail@plt>

Disassembly of section .plt:

0000000000001a90 <.plt>:
    1a90: a9bf7bf0     	stp	x16, x30, [sp, #-0x10]!
    1a94: b0000010     	adrp	x16, 0x2000
    1a98: f9410211     	ldr	x17, [x16, #0x200]
    1a9c: 91080210     	add	x16, x16, #0x200
    1aa0: d61f0220     	br	x17
    1aa4: d503201f     	nop
    1aa8: d503201f     	nop
    1aac: d503201f     	nop

0000000000001ab0 <__cxa_finalize@plt>:
    1ab0: b0000010     	adrp	x16, 0x2000
    1ab4: f9410611     	ldr	x17, [x16, #0x208]
    1ab8: 91082210     	add	x16, x16, #0x208
    1abc: d61f0220     	br	x17

0000000000001ac0 <__open_2@plt>:
    1ac0: b0000010     	adrp	x16, 0x2000
    1ac4: f9410a11     	ldr	x17, [x16, #0x210]
    1ac8: 91084210     	add	x16, x16, #0x210
    1acc: d61f0220     	br	x17

0000000000001ad0 <__android_log_print@plt>:
    1ad0: b0000010     	adrp	x16, 0x2000
    1ad4: f9410e11     	ldr	x17, [x16, #0x218]
    1ad8: 91086210     	add	x16, x16, #0x218
    1adc: d61f0220     	br	x17

0000000000001ae0 <__stack_chk_fail@plt>:
    1ae0: b0000010     	adrp	x16, 0x2000
    1ae4: f9411211     	ldr	x17, [x16, #0x220]
    1ae8: 91088210     	add	x16, x16, #0x220
    1aec: d61f0220     	br	x17

0000000000001af0 <close@plt>:
    1af0: b0000010     	adrp	x16, 0x2000
    1af4: f9411611     	ldr	x17, [x16, #0x228]
    1af8: 9108a210     	add	x16, x16, #0x228
    1afc: d61f0220     	br	x17

0000000000001b00 <ioctl@plt>:
    1b00: b0000010     	adrp	x16, 0x2000
    1b04: f9411a11     	ldr	x17, [x16, #0x230]
    1b08: 9108c210     	add	x16, x16, #0x230
    1b0c: d61f0220     	br	x17

0000000000001b10 <__errno@plt>:
    1b10: b0000010     	adrp	x16, 0x2000
    1b14: f9411e11     	ldr	x17, [x16, #0x238]
    1b18: 9108e210     	add	x16, x16, #0x238
    1b1c: d61f0220     	br	x17

0000000000001b20 <strerror@plt>:
    1b20: b0000010     	adrp	x16, 0x2000
    1b24: f9412211     	ldr	x17, [x16, #0x240]
    1b28: 91090210     	add	x16, x16, #0x240
    1b2c: d61f0220     	br	x17

0000000000001b30 <__memcpy_chk@plt>:
    1b30: b0000010     	adrp	x16, 0x2000
    1b34: f9412611     	ldr	x17, [x16, #0x248]
    1b38: 91092210     	add	x16, x16, #0x248
    1b3c: d61f0220     	br	x17
