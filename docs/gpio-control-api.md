# GpioControl API trace - 2026-11-07

**The API takes logical expansion-interface I/O indices, not Linux GPIO numbers.**
No complete valid-index enumeration or GPIO-number-to-contact table was found.
The observed indices are **1 through 5**: I/O 1 is written by DMD and the factory
test, while the factory test reads I/O 2, 3, 4 and 5. Only the running-tablet
mapping **position 2 / I/O 1 -> kernel GPIO 566** is established by the captured
driver log. The connector contact mapping and GPIO roles need separate evidence.

The trace combines cached DMD SDK Java/Kotlin and ARM64 JNI with a freshly pulled
**Android 16 factory APK and JNI** from the connected tablet. Live firmware is
`mdt865_16_ngms_1.2.7 release-keys`, kernel `6.6.102-android15-8-4k`; factory
versionName is 16, versionCode 36. Both the earlier Android 14 and current
Android 16 factory clients use the same I/O list and test sequence below.
The live installed `com.thorkracing.dmdLora` APK and cached post-update copy
are byte-identical to the originally inspected APK (SHA-256
`616a2c0be5960a9b7925dbd1eadd0006b3e26c37af8250cc7b6bdc5907d2c1cf`).
Only metadata inspection and file retrieval ran; no GPIO read/write, power,
recognition, EEPROM or factory test was invoked.

## 1. Complete public wrapper surface

Class: `hk.topicon.control.driver.GpioControl`, compiled from Kotlin. It loads
`libexpand_jni.so` and forwards these operations:

| Java-visible method / Kotlin property | Return | Native operation |
| --- | --- | --- |
| `GpioControl(SystemProperties)` | constructor | Chooses a control device and immediately calls private `nativeOpen(path)`. |
| `getIsExist()` / `isExist` | boolean | Records whether the constructor opened the control device; no GPIO discovery call. |
| `getPosition(int typeId)` | int | `nativeGetPosition`, ioctl `0xC01C5309`. Module-type-to-position lookup. |
| `getType(int positionId)` | int | `nativeGetType`, ioctl `0xC01C530A`. Module type at a logical interface. |
| `setPower(int positionId, boolean state)` | boolean | `nativeSetPower`, ioctl `0xC01C5301`. Control-device operation. |
| `writeIo(int positionId, int io, boolean state)` | boolean | `nativeWriteIo`, ioctl `0xC01C5302`. Logical I/O request. |
| `readIo(int positionId, int io)` | boolean | `nativeReadIo`, ioctl `0xC01C5303`. Readback, with unusual boolean conversion below. |
| `reset()` | int | `nativeReset`, ioctl `0xC01C530B`; scope/physical side effects are not established. |
| `close()` | void / Unit | Private `nativeClose()`, followed by clearing `isExist`. |

Device selection is `/dev/elora` when `ro.product.device == "mdt781"`, otherwise
`/dev/expand`. The JNI open uses O_RDWR. The public constructor has no arbitrary
device-path argument. `getDeviceName()` and all `native*` methods are private.

There is no public method for enumerating GPIOs, querying an I/O count or valid
range, selecting a Linux GPIO chip/line, exporting a GPIO, setting direction,
changing pull-ups or configuring pin multiplexing. No SDK I/O enum was found.

The wrapper performs **no integer-range checks** on `positionId` or `io` before
JNI. That accepts an integer as a Java argument; it does not establish that the
kernel accepts or safely handles that integer.

[Wrapper evidence](evidence/gpio-control-api/GpioControl.decompiled.java.txt).

## 2. Positions and numbering namespaces

`Position` defines these routing IDs:

| ID | SDK name | Evidence / limit |
| --- | --- | --- |
| 1 | Left | Factory expansion test position; SDK associates it with WK3. |
| 2 | Right | Factory expansion test position; SDK associates it with WK2. This is the observed T865 LoRa interface. |
| 3 | TtyS1 | Separate serial routing option; not evidence of a third expansion bay or valid `/dev/expand` GPIO position. |
| 4 | External | External serial routing option; not evidence of a fourth expansion bay or valid GPIO position. |

`Position.fromId()` maps unknown IDs to `External`; it is not a driver-validity
check. Left/right are vendor logical interfaces, not our two connector columns.
Module type IDs are yet another namespace: the SDK defines ELora=38, Rfid=82 and
External=0. `getPosition` and `getType` concern module routing/identification,
not a list of GPIO numbers.

Keep these distinct:

* Connector contacts: our row-first 1..12 labels, or the hypothetical column-first numbering.
* Logical I/O: the `io` argument to `readIo` / `writeIo`.
* Kernel GPIO: e.g. 566 in the debug log.
* Logical position: e.g. 2 for the right expansion interface.

`writeIo(2, 566, true)` is therefore **not** the SDK equivalent of selecting kernel
GPIO 566. The recorded call selects logical I/O 1 at position 2. These calls are
evidence examples; they were not executed by this trace.

[Position evidence](evidence/gpio-control-api/Position.decompiled.java.txt).

## 3. The actual list found in the factory test

Class `com.freeme.factory.cradle.ExpandTest` initializes this list in both
inspected factory APK versions (Android 14 and current Android 16):

```text
allGpio = listOf(2, 3, 4, 5)
```

The ordinary JADX output failed to reconstruct `testGpioOpt`. A fresh **raw DEX
instruction fallback** recovers its argument flow and reads that list. It does
not write every listed index. Its effective sequence is:

```text
setPower(position, true)                  // enclosing testGpio method
for io in [2, 3, 4, 5]:
    writeIo(position, 1, false)
    wait 100 ms
    require readIo(position, io) == false
    writeIo(position, 1, true)
    wait 100 ms
    require readIo(position, io) == true
setPower(position, false)                 // normal enclosing-method continuation
```

The factory UI creates this test for positions 1 and 2. The state expectations
above are Java boolean results, not independently verified electrical levels.
The code is consistent with an output/readback fixture test; the fixture wiring
and kernel direction handling were not recovered. Do not treat `allGpio` as a
list of four general-purpose output pins.

| Logical I/O | What the callers establish | T865 physical mapping |
| --- | --- | --- |
| 1 | DMD initialization writes it high; factory test toggles it low/high. | Position 2 maps to GPIO 566 in the recorded kernel log. Pin 3 correlation remains unisolated. |
| 2 | Factory readback index; the SDK's MDT781-only mode branch writes it as M1. | No established mapping or write capability on this T865. |
| 3 | Factory readback index; the MDT781-only mode branch writes it as M0. | No established mapping or write capability on this T865. |
| 4 | Factory readback index. | No established mapping or write capability. |
| 5 | Factory readback index. | No established mapping or write capability. |

No observed caller establishes I/O 0 or 6 and above as supported or unsupported.
**The candidate set from callers is {1,2,3,4,5}; the complete valid set for the
running kernel remains unknown.**

[Current Android 16 DEX method and list](evidence/gpio-control-api/Factory16-GPIO-test-DEX-fallback.txt),
[historical Android 14 counterpart](evidence/gpio-control-api/Factory-GPIO-test-DEX-fallback.txt).

## 4. JNI argument path and return semantics

The DMD JNI code checks whether its control-device descriptor is open, copies
the supplied integers into a buffer, and calls ioctl. The inspected write/read
paths contain no I/O allowlist, chip lookup, GPIO-number translation or comparison
that bounds the `io` argument before ioctl. Mapping and validity decisions are
therefore left to the kernel implementation.

The requests encode a 28-byte argument. Recovered field offsets relative to the
argument pointer are:

| Byte offset | Value used by these callers |
| --- | --- |
| 0 | 32-bit logical I/O index for readIo/writeIo |
| 4 | 32-bit module type for type/position operations |
| 8 | 32-bit state (write argument / readback result) |
| 12 | 32-bit logical position |

The factory wrapper explicitly zero-initializes the full payload. The DMD write/
read assembly initializes the used fields and most of the tail; it is not an OEM
header or grounds to assume unused bytes are meaningful. `reset()` supplies no
explicit third ioctl argument in the inspected DMD native code; it is not an
enumeration operation or a validated harmless probe.

Crucially, after a successful ioctl, **nativeReadIo returns `true` when the state
field at offset 8 is ZERO** (`cmp ..., #0; cset ..., eq`). The current Android 16 factory JNI uses the same conversion. A failed read
returns `false` and logs an error. Therefore:

* `false` alone cannot distinguish a read failure from the nonzero-state result.
* Do not translate it to a raw high/low pin voltage without verifying driver semantics.
* `isExist` indicates an open attempt succeeded, not that a radio is attached or an index is valid.
* Write/setPower success indicates an accepted ioctl, not verified pad voltage or RF power.

The native library uses a process-global descriptor: nativeOpen closes an existing
one before opening again, and nativeClose clears it. Multiple Java instances in
one process can invalidate each other's descriptor despite an older instance's
`isExist` flag still being true. This does not mean FDs are shared across apps.

[DMD ARM64 evidence](evidence/gpio-control-api/GpioControl-native-arm64.asm),
[current Android 16 factory ARM64 evidence](evidence/gpio-control-api/Factory16-native-arm64.asm).

## 5. GPIO mode selection and the two power operations

`ExpandManager.powerOn` calls `GpioControl.setPower(position,true)` and then
`writeIo(position,1,true)`, waits 100 ms and opens the serial port. The first
operation targets `/dev/expand`, not the radio's TX-power register.
Radio TX-power configuration is separately represented by UART `AT+POWER`.

`ExpandManager.setMode` writes M0 through I/O 3 and M1 through I/O 2 **only when
the device property equals mdt781**. For the inspected MDT865 path it returns
false, and `EByteRepository.setWorkMode` uses its UART-mode command fallback.
The earlier scope capture decoded the six-byte configuration-mode command
`C0 C1 C2 C3 02 03`. The presence of the GPIO mode branch for another model does
not establish M0/M1 wiring on this tablet.

[Manager call sites](evidence/gpio-control-api/ExpandManager-call-sites.txt),
[radio protocol analysis](reports/DMD-LoRa-analysis.txt),
[captured runtime sequence](reports/POST-UPDATE-INVESTIGATION-2026-11-07.txt).

## 6. Other factory operations and remaining evidence needed

The current Android 16 factory `ExpandGpio` class publicly exposes:

```text
ExpandGpio()                        // immediately opens /dev/expand, O_RDWR
getIsExist(): boolean
close(): void
getPosition(int type): int
getType(int position): int
setPower(int position, boolean state): boolean
writeIo(int position, int io, boolean state): boolean
readIo(int position, int io): boolean
readEeprom(int position): EepromData
writeEeprom(int position, EepromData): boolean
recognizeModule(): boolean
```

`EepromData` has serial-number bytes, version and type fields; it is not an I/O
index list. EEPROM writes use ioctl `0xC01C5304`, reads `0xC01C5305`, and module
recognition `0xC01C5308`. None enumerates GPIOs. The earlier Android 14 Java class
did not declare close/type/position methods despite the corresponding native
exports. The current class does declare them. The factory EEPROM test writes a
generated serial number and is not a read-only GPIO discovery procedure. It was
not run.

The actual valid-index set, direction capabilities and physical mapping require
the matching kernel driver implementation, its ioctl header and device-tree GPIO
entries. The live T865 device tree exposes `right_gpio` and `right_power`, but reads of
those values return Permission denied. `/dev/expand` is `0666 root:system`,
SELinux label `gpio_ctrl_device`, major/minor `10:107`. These metadata alone do
not prove that an ordinary app is allowed each ioctl. `/dev/gpiochip0` is
`0600 root:root`; `gpioinfo` cannot open it, and `/sys/class/gpio` is absent.
The Android 16 `expand_module.ko` was also inaccessible. No assumptions about
arbitrary indices or Linux GPIO offsets fill that gap.

[Current factory wrapper](evidence/gpio-control-api/Factory16-ExpandGpio.decompiled.java.txt),
[live metadata and access failures](evidence/gpio-control-api/Live-Android16-metadata.txt),
[artifact hashes and trace scope](evidence/gpio-control-api/source-inventory.json).
