
work/dmd-analysis/extracted/com.thorkracing.dmdLora/lib/arm64-v8a/libexpand_jni.so:	file format elf64-littleaarch64

Disassembly of section .text:

0000000000000de8 <.text>:
     de8:      	bti	c
     dec:      	nop
     df0:      	adr	x0, 0x5610
     df4:      	b	0x1570 <__cxa_finalize@plt>
     df8:      	bti	c
     dfc:      	ret
     e00:      	bti	c
     e04:      	b	0xdf8 <.text+0x10>
     e08:      	bti	c
     e0c:      	cbz	x0, 0xe18 <.text+0x30>
     e10:      	mov	x16, x0
     e14:      	br	x16
     e18:      	ret
     e1c:      	bti	c
     e20:      	mov	x1, x0
     e24:      	nop
     e28:      	adr	x0, 0xe08 <.text+0x20>
     e2c:      	nop
     e30:      	adr	x2, 0x5610
     e34:      	b	0x1580 <__cxa_atexit@plt>
     e38:      	bti	c
     e3c:      	nop
     e40:      	adr	x3, 0x5610
     e44:      	b	0x1590 <__register_atfork@plt>

0000000000000e48 <Java_hk_topicon_control_driver_GpioControl_nativeOpen>:
     e48:      	sub	sp, sp, #0x50
     e4c:      	stp	x29, x30, [sp, #0x10]
     e50:      	str	x23, [sp, #0x20]
     e54:      	stp	x22, x21, [sp, #0x30]
     e58:      	stp	x20, x19, [sp, #0x40]
     e5c:      	add	x29, sp, #0x10
     e60:      	mrs	x22, TPIDR_EL0
     e64:      	mov	x21, x2
     e68:      	add	x2, sp, #0x7
     e6c:      	ldr	x8, [x22, #0x28]
     e70:      	mov	x1, x21
     e74:      	mov	x20, x0
     e78:      	str	x8, [sp, #0x8]
     e7c:      	ldr	x8, [x0]
     e80:      	ldr	x8, [x8, #0x548]
     e84:      	blr	x8
     e88:      	adrp	x23, 0x5000 <ioctl@plt+0x3a00>
     e8c:      	mov	x19, x0
     e90:      	ldr	x23, [x23, #0x7c8]
     e94:      	ldr	w8, [x23]
     e98:      	cmn	w8, #0x1
     e9c:      	b.eq	0xea8 <Java_hk_topicon_control_driver_GpioControl_nativeOpen+0x60>
     ea0:      	mov	w0, w8
     ea4:      	bl	0x15a0 <close@plt>
     ea8:      	mov	x0, x19
     eac:      	mov	w1, #0x2                // =2
     eb0:      	bl	0x15b0 <__open_2@plt>
     eb4:      	mov	w3, w0
     eb8:      	str	w0, [x23]
     ebc:      	adrp	x1, 0x0
     ec0:      	add	x1, x1, #0xa83
     ec4:      	nop
     ec8:      	adr	x2, 0xad0
     ecc:      	mov	w0, #0x3                // =3
     ed0:      	mov	x4, x19
     ed4:      	bl	0x15c0 <__android_log_print@plt>
     ed8:      	ldr	x8, [x20]
     edc:      	mov	x0, x20
     ee0:      	mov	x1, x21
     ee4:      	mov	x2, x19
     ee8:      	ldr	x8, [x8, #0x550]
     eec:      	blr	x8
     ef0:      	ldr	w0, [x23]
     ef4:      	tbz	w0, #0x1f, 0xf28 <Java_hk_topicon_control_driver_GpioControl_nativeOpen+0xe0>
     ef8:      	bl	0x15d0 <__errno@plt>
     efc:      	ldr	w0, [x0]
     f00:      	bl	0x15e0 <strerror@plt>
     f04:      	mov	x4, x0
     f08:      	adrp	x1, 0x0
     f0c:      	add	x1, x1, #0xa83
     f10:      	adrp	x2, 0x0
     f14:      	add	x2, x2, #0xae8
     f18:      	mov	w0, #0x6                // =6
     f1c:      	mov	x3, x19
     f20:      	bl	0x15c0 <__android_log_print@plt>
     f24:      	mov	w0, #-0x1               // =-1
     f28:      	ldr	x8, [x22, #0x28]
     f2c:      	ldr	x9, [sp, #0x8]
     f30:      	cmp	x8, x9
     f34:      	b.ne	0xf50 <Java_hk_topicon_control_driver_GpioControl_nativeOpen+0x108>
     f38:      	ldp	x20, x19, [sp, #0x40]
     f3c:      	ldr	x23, [sp, #0x20]
     f40:      	ldp	x22, x21, [sp, #0x30]
     f44:      	ldp	x29, x30, [sp, #0x10]
     f48:      	add	sp, sp, #0x50
     f4c:      	ret
     f50:      	bl	0x15f0 <__stack_chk_fail@plt>

0000000000000f54 <Java_hk_topicon_control_driver_GpioControl_nativeClose>:
     f54:      	stp	x29, x30, [sp, #-0x20]!
     f58:      	str	x19, [sp, #0x10]
     f5c:      	mov	x29, sp
     f60:      	adrp	x19, 0x5000 <ioctl@plt+0x3a00>
     f64:      	ldr	x19, [x19, #0x7c8]
     f68:      	ldr	w3, [x19]
     f6c:      	cmn	w3, #0x1
     f70:      	b.eq	0xf9c <Java_hk_topicon_control_driver_GpioControl_nativeClose+0x48>
     f74:      	adrp	x1, 0x0
     f78:      	add	x1, x1, #0xa83
     f7c:      	adrp	x2, 0x0
     f80:      	add	x2, x2, #0xb2f
     f84:      	mov	w0, #0x3                // =3
     f88:      	bl	0x15c0 <__android_log_print@plt>
     f8c:      	ldr	w0, [x19]
     f90:      	bl	0x15a0 <close@plt>
     f94:      	mov	w8, #-0x1               // =-1
     f98:      	str	w8, [x19]
     f9c:      	ldr	x19, [sp, #0x10]
     fa0:      	ldp	x29, x30, [sp], #0x20
     fa4:      	ret

0000000000000fa8 <Java_hk_topicon_control_driver_GpioControl_nativeGetPosition>:
     fa8:      	sub	sp, sp, #0x60
     fac:      	stp	x29, x30, [sp, #0x30]
     fb0:      	str	x21, [sp, #0x40]
     fb4:      	stp	x20, x19, [sp, #0x50]
     fb8:      	add	x29, sp, #0x30
     fbc:      	mrs	x21, TPIDR_EL0
     fc0:      	adrp	x9, 0x5000 <ioctl@plt+0x3a00>
     fc4:      	ldr	x8, [x21, #0x28]
     fc8:      	ldr	x9, [x9, #0x7c8]
     fcc:      	stur	x8, [x29, #-0x8]
     fd0:      	ldr	w0, [x9]
     fd4:      	cmn	w0, #0x1
     fd8:      	b.eq	0x100c <Java_hk_topicon_control_driver_GpioControl_nativeGetPosition+0x64>
     fdc:      	mov	w1, #0x5309             // =21257
     fe0:      	mov	w19, w2
     fe4:      	stp	xzr, xzr, [sp, #0x8]
     fe8:      	str	w2, [sp, #0xc]
     fec:      	add	x2, sp, #0x8
     ff0:      	movk	w1, #0xc01c, lsl #16
     ff4:      	str	wzr, [sp, #0x20]
     ff8:      	str	xzr, [sp, #0x18]
     ffc:      	bl	0x1600 <ioctl@plt>
    1000:      	tbnz	w0, #0x1f, 0x1028 <Java_hk_topicon_control_driver_GpioControl_nativeGetPosition+0x80>
    1004:      	ldr	w0, [sp, #0x14]
    1008:      	b	0x1060 <Java_hk_topicon_control_driver_GpioControl_nativeGetPosition+0xb8>
    100c:      	adrp	x1, 0x0
    1010:      	add	x1, x1, #0xa83
    1014:      	adrp	x2, 0x0
    1018:      	add	x2, x2, #0xa21
    101c:      	mov	w0, #0x6                // =6
    1020:      	bl	0x15c0 <__android_log_print@plt>
    1024:      	b	0x105c <Java_hk_topicon_control_driver_GpioControl_nativeGetPosition+0xb4>
    1028:      	mov	w20, w0
    102c:      	bl	0x15d0 <__errno@plt>
    1030:      	ldr	w0, [x0]
    1034:      	bl	0x15e0 <strerror@plt>
    1038:      	mov	x5, x0
    103c:      	adrp	x1, 0x0
    1040:      	add	x1, x1, #0xa83
    1044:      	adrp	x2, 0x0
    1048:      	add	x2, x2, #0x992
    104c:      	mov	w0, #0x3                // =3
    1050:      	mov	w3, w19
    1054:      	mov	w4, w20
    1058:      	bl	0x15c0 <__android_log_print@plt>
    105c:      	mov	w0, #-0x1               // =-1
    1060:      	ldr	x8, [x21, #0x28]
    1064:      	ldur	x9, [x29, #-0x8]
    1068:      	cmp	x8, x9
    106c:      	b.ne	0x1084 <Java_hk_topicon_control_driver_GpioControl_nativeGetPosition+0xdc>
    1070:      	ldp	x20, x19, [sp, #0x50]
    1074:      	ldr	x21, [sp, #0x40]
    1078:      	ldp	x29, x30, [sp, #0x30]
    107c:      	add	sp, sp, #0x60
    1080:      	ret
    1084:      	bl	0x15f0 <__stack_chk_fail@plt>

0000000000001088 <Java_hk_topicon_control_driver_GpioControl_nativeReset>:
    1088:      	stp	x29, x30, [sp, #-0x20]!
    108c:      	str	x19, [sp, #0x10]
    1090:      	mov	x29, sp
    1094:      	adrp	x8, 0x5000 <ioctl@plt+0x3a00>
    1098:      	ldr	x8, [x8, #0x7c8]
    109c:      	ldr	w0, [x8]
    10a0:      	cmn	w0, #0x1
    10a4:      	b.eq	0x10c0 <Java_hk_topicon_control_driver_GpioControl_nativeReset+0x38>
    10a8:      	mov	w1, #0x530b             // =21259
    10ac:      	movk	w1, #0xc01c, lsl #16
    10b0:      	bl	0x1600 <ioctl@plt>
    10b4:      	tbnz	w0, #0x1f, 0x10dc <Java_hk_topicon_control_driver_GpioControl_nativeReset+0x54>
    10b8:      	mov	w0, wzr
    10bc:      	b	0x1110 <Java_hk_topicon_control_driver_GpioControl_nativeReset+0x88>
    10c0:      	adrp	x1, 0x0
    10c4:      	add	x1, x1, #0xa83
    10c8:      	adrp	x2, 0x0
    10cc:      	add	x2, x2, #0xa21
    10d0:      	mov	w0, #0x6                // =6
    10d4:      	bl	0x15c0 <__android_log_print@plt>
    10d8:      	b	0x110c <Java_hk_topicon_control_driver_GpioControl_nativeReset+0x84>
    10dc:      	mov	w19, w0
    10e0:      	bl	0x15d0 <__errno@plt>
    10e4:      	ldr	w0, [x0]
    10e8:      	bl	0x15e0 <strerror@plt>
    10ec:      	mov	x4, x0
    10f0:      	adrp	x1, 0x0
    10f4:      	add	x1, x1, #0xa83
    10f8:      	adrp	x2, 0x0
    10fc:      	add	x2, x2, #0xa62
    1100:      	mov	w0, #0x3                // =3
    1104:      	mov	w3, w19
    1108:      	bl	0x15c0 <__android_log_print@plt>
    110c:      	mov	w0, #-0x1               // =-1
    1110:      	ldr	x19, [sp, #0x10]
    1114:      	ldp	x29, x30, [sp], #0x20
    1118:      	ret

000000000000111c <Java_hk_topicon_control_driver_GpioControl_nativeSetPower>:
    111c:      	sub	sp, sp, #0x60
    1120:      	stp	x29, x30, [sp, #0x30]
    1124:      	str	x21, [sp, #0x40]
    1128:      	stp	x20, x19, [sp, #0x50]
    112c:      	add	x29, sp, #0x30
    1130:      	mrs	x21, TPIDR_EL0
    1134:      	adrp	x19, 0x5000 <ioctl@plt+0x3a00>
    1138:      	ldr	x8, [x21, #0x28]
    113c:      	ldr	x19, [x19, #0x7c8]
    1140:      	stur	x8, [x29, #-0x8]
    1144:      	ldr	w0, [x19]
    1148:      	cmn	w0, #0x1
    114c:      	b.eq	0x11ac <Java_hk_topicon_control_driver_GpioControl_nativeSetPower+0x90>
    1150:      	tst	w3, #0xff
    1154:      	mov	w1, #0x5301             // =21249
    1158:      	str	xzr, [sp, #0x8]
    115c:      	cset	w8, ne
    1160:      	movk	w1, #0xc01c, lsl #16
    1164:      	str	xzr, [sp, #0x18]
    1168:      	stp	w8, w2, [sp, #0x10]
    116c:      	add	x2, sp, #0x8
    1170:      	strh	wzr, [sp, #0x20]
    1174:      	bl	0x1600 <ioctl@plt>
    1178:      	ldr	w3, [x19]
    117c:      	ldr	w4, [sp, #0x10]
    1180:      	mov	w19, w0
    1184:      	adrp	x1, 0x0
    1188:      	add	x1, x1, #0xa83
    118c:      	adrp	x2, 0x0
    1190:      	add	x2, x2, #0x938
    1194:      	mov	w0, #0x3                // =3
    1198:      	mov	w5, w19
    119c:      	bl	0x15c0 <__android_log_print@plt>
    11a0:      	tbnz	w19, #0x1f, 0x11c8 <Java_hk_topicon_control_driver_GpioControl_nativeSetPower+0xac>
    11a4:      	mov	w0, #0x1                // =1
    11a8:      	b	0x1200 <Java_hk_topicon_control_driver_GpioControl_nativeSetPower+0xe4>
    11ac:      	adrp	x1, 0x0
    11b0:      	add	x1, x1, #0xa83
    11b4:      	adrp	x2, 0x0
    11b8:      	add	x2, x2, #0xa21
    11bc:      	mov	w0, #0x6                // =6
    11c0:      	bl	0x15c0 <__android_log_print@plt>
    11c4:      	b	0x11fc <Java_hk_topicon_control_driver_GpioControl_nativeSetPower+0xe0>
    11c8:      	ldr	w20, [sp, #0x10]
    11cc:      	bl	0x15d0 <__errno@plt>
    11d0:      	ldr	w0, [x0]
    11d4:      	bl	0x15e0 <strerror@plt>
    11d8:      	mov	x5, x0
    11dc:      	adrp	x1, 0x0
    11e0:      	add	x1, x1, #0xa83
    11e4:      	adrp	x2, 0x0
    11e8:      	add	x2, x2, #0x9c4
    11ec:      	mov	w0, #0x3                // =3
    11f0:      	mov	w3, w20
    11f4:      	mov	w4, w19
    11f8:      	bl	0x15c0 <__android_log_print@plt>
    11fc:      	mov	w0, wzr
    1200:      	ldr	x8, [x21, #0x28]
    1204:      	ldur	x9, [x29, #-0x8]
    1208:      	cmp	x8, x9
    120c:      	b.ne	0x1224 <Java_hk_topicon_control_driver_GpioControl_nativeSetPower+0x108>
    1210:      	ldp	x20, x19, [sp, #0x50]
    1214:      	ldr	x21, [sp, #0x40]
    1218:      	ldp	x29, x30, [sp, #0x30]
    121c:      	add	sp, sp, #0x60
    1220:      	ret
    1224:      	bl	0x15f0 <__stack_chk_fail@plt>

0000000000001228 <Java_hk_topicon_control_driver_GpioControl_nativeGetType>:
    1228:      	sub	sp, sp, #0x60
    122c:      	stp	x29, x30, [sp, #0x30]
    1230:      	str	x21, [sp, #0x40]
    1234:      	stp	x20, x19, [sp, #0x50]
    1238:      	add	x29, sp, #0x30
    123c:      	mrs	x21, TPIDR_EL0
    1240:      	adrp	x20, 0x5000 <ioctl@plt+0x3a00>
    1244:      	ldr	x8, [x21, #0x28]
    1248:      	ldr	x20, [x20, #0x7c8]
    124c:      	stur	x8, [x29, #-0x8]
    1250:      	ldr	w0, [x20]
    1254:      	cmn	w0, #0x1
    1258:      	b.eq	0x12b4 <Java_hk_topicon_control_driver_GpioControl_nativeGetType+0x8c>
    125c:      	mov	w1, #0x530a             // =21258
    1260:      	mov	w19, w2
    1264:      	stp	xzr, xzr, [sp, #0x8]
    1268:      	str	w2, [sp, #0x14]
    126c:      	add	x2, sp, #0x8
    1270:      	movk	w1, #0xc01c, lsl #16
    1274:      	str	wzr, [sp, #0x20]
    1278:      	str	xzr, [sp, #0x18]
    127c:      	bl	0x1600 <ioctl@plt>
    1280:      	ldr	w3, [x20]
    1284:      	mov	w20, w0
    1288:      	adrp	x1, 0x0
    128c:      	add	x1, x1, #0xa83
    1290:      	adrp	x2, 0x0
    1294:      	add	x2, x2, #0xb00
    1298:      	mov	w0, #0x3                // =3
    129c:      	mov	w4, w19
    12a0:      	mov	w5, w20
    12a4:      	bl	0x15c0 <__android_log_print@plt>
    12a8:      	tbnz	w20, #0x1f, 0x12d0 <Java_hk_topicon_control_driver_GpioControl_nativeGetType+0xa8>
    12ac:      	ldr	w0, [sp, #0xc]
    12b0:      	b	0x1304 <Java_hk_topicon_control_driver_GpioControl_nativeGetType+0xdc>
    12b4:      	adrp	x1, 0x0
    12b8:      	add	x1, x1, #0xa83
    12bc:      	adrp	x2, 0x0
    12c0:      	add	x2, x2, #0xa21
    12c4:      	mov	w0, #0x6                // =6
    12c8:      	bl	0x15c0 <__android_log_print@plt>
    12cc:      	b	0x1300 <Java_hk_topicon_control_driver_GpioControl_nativeGetType+0xd8>
    12d0:      	bl	0x15d0 <__errno@plt>
    12d4:      	ldr	w0, [x0]
    12d8:      	bl	0x15e0 <strerror@plt>
    12dc:      	mov	x5, x0
    12e0:      	adrp	x1, 0x0
    12e4:      	add	x1, x1, #0xa83
    12e8:      	adrp	x2, 0x0
    12ec:      	add	x2, x2, #0x9ef
    12f0:      	mov	w0, #0x3                // =3
    12f4:      	mov	w3, w19
    12f8:      	mov	w4, w20
    12fc:      	bl	0x15c0 <__android_log_print@plt>
    1300:      	mov	w0, #-0x1               // =-1
    1304:      	ldr	x8, [x21, #0x28]
    1308:      	ldur	x9, [x29, #-0x8]
    130c:      	cmp	x8, x9
    1310:      	b.ne	0x1328 <Java_hk_topicon_control_driver_GpioControl_nativeGetType+0x100>
    1314:      	ldp	x20, x19, [sp, #0x50]
    1318:      	ldr	x21, [sp, #0x40]
    131c:      	ldp	x29, x30, [sp, #0x30]
    1320:      	add	sp, sp, #0x60
    1324:      	ret
    1328:      	bl	0x15f0 <__stack_chk_fail@plt>

000000000000132c <Java_hk_topicon_control_driver_GpioControl_nativeWriteIo>:
    132c:      	sub	sp, sp, #0x60
    1330:      	stp	x29, x30, [sp, #0x30]
    1334:      	stp	x22, x21, [sp, #0x40]
    1338:      	stp	x20, x19, [sp, #0x50]
    133c:      	add	x29, sp, #0x30
    1340:      	mrs	x22, TPIDR_EL0
    1344:      	adrp	x20, 0x5000 <ioctl@plt+0x3a00>
    1348:      	ldr	x8, [x22, #0x28]
    134c:      	ldr	x20, [x20, #0x7c8]
    1350:      	stur	x8, [x29, #-0x8]
    1354:      	ldr	w0, [x20]
    1358:      	cmn	w0, #0x1
    135c:      	b.eq	0x13c4 <Java_hk_topicon_control_driver_GpioControl_nativeWriteIo+0x98>
    1360:      	tst	w4, #0xff
    1364:      	mov	w1, #0x5302             // =21250
    1368:      	mov	w19, w3
    136c:      	cset	w8, ne
    1370:      	movk	w1, #0xc01c, lsl #16
    1374:      	stp	w3, wzr, [sp, #0xc]
    1378:      	stp	w8, w2, [sp, #0x14]
    137c:      	add	x2, sp, #0xc
    1380:      	stur	xzr, [sp, #0x1c]
    1384:      	strh	wzr, [sp, #0x24]
    1388:      	bl	0x1600 <ioctl@plt>
    138c:      	ldr	w4, [x20]
    1390:      	ldr	w5, [sp, #0x14]
    1394:      	mov	w20, w0
    1398:      	adrp	x1, 0x0
    139c:      	add	x1, x1, #0xa83
    13a0:      	adrp	x2, 0x0
    13a4:      	add	x2, x2, #0xa33
    13a8:      	mov	w0, #0x3                // =3
    13ac:      	mov	w3, w19
    13b0:      	mov	w6, w20
    13b4:      	bl	0x15c0 <__android_log_print@plt>
    13b8:      	tbnz	w20, #0x1f, 0x13e0 <Java_hk_topicon_control_driver_GpioControl_nativeWriteIo+0xb4>
    13bc:      	mov	w0, #0x1                // =1
    13c0:      	b	0x141c <Java_hk_topicon_control_driver_GpioControl_nativeWriteIo+0xf0>
    13c4:      	adrp	x1, 0x0
    13c8:      	add	x1, x1, #0xa83
    13cc:      	adrp	x2, 0x0
    13d0:      	add	x2, x2, #0xa21
    13d4:      	mov	w0, #0x6                // =6
    13d8:      	bl	0x15c0 <__android_log_print@plt>
    13dc:      	b	0x1418 <Java_hk_topicon_control_driver_GpioControl_nativeWriteIo+0xec>
    13e0:      	ldr	w21, [sp, #0x14]
    13e4:      	bl	0x15d0 <__errno@plt>
    13e8:      	ldr	w0, [x0]
    13ec:      	bl	0x15e0 <strerror@plt>
    13f0:      	mov	x6, x0
    13f4:      	adrp	x1, 0x0
    13f8:      	add	x1, x1, #0xa83
    13fc:      	adrp	x2, 0x0
    1400:      	add	x2, x2, #0x960
    1404:      	mov	w0, #0x3                // =3
    1408:      	mov	w3, w19
    140c:      	mov	w4, w21
    1410:      	mov	w5, w20
    1414:      	bl	0x15c0 <__android_log_print@plt>
    1418:      	mov	w0, wzr
    141c:      	ldr	x8, [x22, #0x28]
    1420:      	ldur	x9, [x29, #-0x8]
    1424:      	cmp	x8, x9
    1428:      	b.ne	0x1440 <Java_hk_topicon_control_driver_GpioControl_nativeWriteIo+0x114>
    142c:      	ldp	x20, x19, [sp, #0x50]
    1430:      	ldp	x22, x21, [sp, #0x40]
    1434:      	ldp	x29, x30, [sp, #0x30]
    1438:      	add	sp, sp, #0x60
    143c:      	ret
    1440:      	bl	0x15f0 <__stack_chk_fail@plt>

0000000000001444 <Java_hk_topicon_control_driver_GpioControl_nativeReadIo>:
    1444:      	sub	sp, sp, #0x60
    1448:      	stp	x29, x30, [sp, #0x30]
    144c:      	str	x21, [sp, #0x40]
    1450:      	stp	x20, x19, [sp, #0x50]
    1454:      	add	x29, sp, #0x30
    1458:      	mrs	x21, TPIDR_EL0
    145c:      	adrp	x9, 0x5000 <ioctl@plt+0x3a00>
    1460:      	ldr	x8, [x21, #0x28]
    1464:      	ldr	x9, [x9, #0x7c8]
    1468:      	stur	x8, [x29, #-0x8]
    146c:      	ldr	w0, [x9]
    1470:      	cmn	w0, #0x1
    1474:      	b.eq	0x14d8 <Java_hk_topicon_control_driver_GpioControl_nativeReadIo+0x94>
    1478:      	mov	w1, #0x5303             // =21251
    147c:      	str	w2, [sp, #0x18]
    1480:      	add	x2, sp, #0xc
    1484:      	movk	w1, #0xc01c, lsl #16
    1488:      	mov	w19, w3
    148c:      	str	w3, [sp, #0xc]
    1490:      	str	xzr, [sp, #0x10]
    1494:      	stur	xzr, [sp, #0x1c]
    1498:      	strh	wzr, [sp, #0x24]
    149c:      	bl	0x1600 <ioctl@plt>
    14a0:      	mov	w20, w0
    14a4:      	adrp	x1, 0x0
    14a8:      	add	x1, x1, #0xa83
    14ac:      	adrp	x2, 0x0
    14b0:      	add	x2, x2, #0xa8f
    14b4:      	mov	w0, #0x3                // =3
    14b8:      	mov	w3, w19
    14bc:      	mov	w4, w20
    14c0:      	bl	0x15c0 <__android_log_print@plt>
    14c4:      	tbnz	w20, #0x1f, 0x14f4 <Java_hk_topicon_control_driver_GpioControl_nativeReadIo+0xb0>
    14c8:      	ldr	w8, [sp, #0x14]
    14cc:      	cmp	w8, #0x0
    14d0:      	cset	w0, eq
    14d4:      	b	0x1528 <Java_hk_topicon_control_driver_GpioControl_nativeReadIo+0xe4>
    14d8:      	adrp	x1, 0x0
    14dc:      	add	x1, x1, #0xa83
    14e0:      	adrp	x2, 0x0
    14e4:      	add	x2, x2, #0xa21
    14e8:      	mov	w0, #0x6                // =6
    14ec:      	bl	0x15c0 <__android_log_print@plt>
    14f0:      	b	0x1524 <Java_hk_topicon_control_driver_GpioControl_nativeReadIo+0xe0>
    14f4:      	bl	0x15d0 <__errno@plt>
    14f8:      	ldr	w0, [x0]
    14fc:      	bl	0x15e0 <strerror@plt>
    1500:      	mov	x5, x0
    1504:      	adrp	x1, 0x0
    1508:      	add	x1, x1, #0xa83
    150c:      	adrp	x2, 0x0
    1510:      	add	x2, x2, #0xaaa
    1514:      	mov	w0, #0x3                // =3
    1518:      	mov	w3, w19
    151c:      	mov	w4, w20
    1520:      	bl	0x15c0 <__android_log_print@plt>
    1524:      	mov	w0, wzr
    1528:      	ldr	x8, [x21, #0x28]
    152c:      	ldur	x9, [x29, #-0x8]
    1530:      	cmp	x8, x9
    1534:      	b.ne	0x154c <Java_hk_topicon_control_driver_GpioControl_nativeReadIo+0x108>
    1538:      	ldp	x20, x19, [sp, #0x50]
    153c:      	ldr	x21, [sp, #0x40]
    1540:      	ldp	x29, x30, [sp, #0x30]
    1544:      	add	sp, sp, #0x60
    1548:      	ret
    154c:      	bl	0x15f0 <__stack_chk_fail@plt>

Disassembly of section .plt:

0000000000001550 <.plt>:
    1550:      	stp	x16, x30, [sp, #-0x10]!
    1554:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    1558:      	ldr	x17, [x16, #0x7e0]
    155c:      	add	x16, x16, #0x7e0
    1560:      	br	x17
    1564:      	nop
    1568:      	nop
    156c:      	nop

0000000000001570 <__cxa_finalize@plt>:
    1570:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    1574:      	ldr	x17, [x16, #0x7e8]
    1578:      	add	x16, x16, #0x7e8
    157c:      	br	x17

0000000000001580 <__cxa_atexit@plt>:
    1580:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    1584:      	ldr	x17, [x16, #0x7f0]
    1588:      	add	x16, x16, #0x7f0
    158c:      	br	x17

0000000000001590 <__register_atfork@plt>:
    1590:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    1594:      	ldr	x17, [x16, #0x7f8]
    1598:      	add	x16, x16, #0x7f8
    159c:      	br	x17

00000000000015a0 <close@plt>:
    15a0:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    15a4:      	ldr	x17, [x16, #0x800]
    15a8:      	add	x16, x16, #0x800
    15ac:      	br	x17

00000000000015b0 <__open_2@plt>:
    15b0:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    15b4:      	ldr	x17, [x16, #0x808]
    15b8:      	add	x16, x16, #0x808
    15bc:      	br	x17

00000000000015c0 <__android_log_print@plt>:
    15c0:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    15c4:      	ldr	x17, [x16, #0x810]
    15c8:      	add	x16, x16, #0x810
    15cc:      	br	x17

00000000000015d0 <__errno@plt>:
    15d0:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    15d4:      	ldr	x17, [x16, #0x818]
    15d8:      	add	x16, x16, #0x818
    15dc:      	br	x17

00000000000015e0 <strerror@plt>:
    15e0:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    15e4:      	ldr	x17, [x16, #0x820]
    15e8:      	add	x16, x16, #0x820
    15ec:      	br	x17

00000000000015f0 <__stack_chk_fail@plt>:
    15f0:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    15f4:      	ldr	x17, [x16, #0x828]
    15f8:      	add	x16, x16, #0x828
    15fc:      	br	x17

0000000000001600 <ioctl@plt>:
    1600:      	adrp	x16, 0x5000 <ioctl@plt+0x3a00>
    1604:      	ldr	x17, [x16, #0x830]
    1608:      	add	x16, x16, #0x830
    160c:      	br	x17
