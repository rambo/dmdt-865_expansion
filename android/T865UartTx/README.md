# T865 UART TX

A separate bench app for identifying `/dev/ttysWK2` TX/RX on the T865/T865X. Package `dev.t865.uarttx`. The read-only T865PortProbe app is unchanged.

**Confirmed on this tablet: backside pin 11 is WK2 RX, pin 12 is WK2 TX, and pin 1 is the ground reference.** Scope CH4 decoded eight exact 20-byte frames at 9600/8N1 with zero framing errors. Scope idle level was about 2.45 V. The user subsequently measured pin 12 at 2.5 V relative to pin 1 and 2.464 V relative to a cradle GND pad, confirming an idle level around 2.5 V; this is not a 5 V interface rating. RX location is now confirmed by exact numbered ESP32 payloads; guaranteed input voltage tolerance remains unknown.

## Install and run through ADB

```sh
adb -d install -r T865UartTx-debug.apk
adb -d shell am start -n dev.t865.uarttx/.MainActivity --ez start true
adb -d logcat -v threadtime -s T865UartTx:I AndroidRuntime:E
```

It sends ASCII `UUUU T865 UART WK2` followed by CR/LF (20 bytes) once per second. The leading `U` bytes are 0x55: alternating bits are easy to recognize. At 9600 baud a bit is about 104.17 us and a frame about 20.83 ms. The interval uses a scheduled worker, so it is approximate rather than a timing reference.

Stop normally and restore the original serial settings:

```sh
adb -d shell am start -n dev.t865.uarttx/.MainActivity --ez stop true
```

Hold TX idle, keeping the descriptor open at 9600/8N1 while cancelling all repeating writes. Version 1.2 also reads and logs available RX bytes in this mode:

```sh
adb -d shell am start -n dev.t865.uarttx/.MainActivity --ez idle true
```

RX logs contain byte counts, hex and escaped ASCII. Chunks may split a received string. The screen has a Receive only / TX idle button. See [RX-PROBE-WIRING.txt](RX-PROBE-WIRING.txt) for the ESP32 probe circuit and procedure; pin 11 is now confirmed RX by the ESP32 GPIO26 test.

Start resumes transmission from idle hold. Stop restores termios and closes the descriptor. Idle hold also ends when the activity leaves the foreground.

The screen also has Start and Stop buttons. Launching from the launcher does not start a new transmission automatically. Returning Home, locking the device, or otherwise leaving the foreground stops transmission and closes the descriptor. The activity keeps the screen awake during transmission. There is no background service or automatic boot start.

Emergency process stop:

```sh
adb -d shell am force-stop dev.t865.uarttx
```

A process kill closes descriptors but cannot guarantee restoration of saved termios. Prefer normal Stop. Check logcat for any restore/close error.

The tablet has separately been configured, at the user's request, to stay awake on all external-power types:

```sh
adb -d shell svc power stayon true
# Current global stay_on_while_plugged_in = 15; tablet reports AC, not USB power.
# To disable this setting later:
adb -d shell svc power stayon false
```

## What it changes

Explicit Start or receive-only Idle opens only `/dev/ttysWK2` with `O_RDWR|O_NONBLOCK|O_NOCTTY|O_CLOEXEC|O_NOFOLLOW`, checks for a character device, saves termios, selects raw 9600/8N1, disables hardware/software flow control and temporarily clears HUPCL. Start writes the fixed 20-byte string. Start and Idle poll up to 256 available RX bytes every 50 ms without echoing them. The app does not flush queues or wait indefinitely for a stuck output queue. Partial writes are completed with a 250 ms deadline; an error stops the loop and reports numeric errno.

Normal Stop cancels future frames, restores saved termios, and closes once. Vendor open/close behavior can still affect hardware. Kernel calls themselves are not guaranteed cancellable. The app has no permissions, root access, network, `/dev/expand` access, expansion power/GPIO commands, SPI operations or radio protocol implementation.

Keep DMD LoRa and other WK2 consumers off. There is no cross-app lock; another process can interfere with serial settings. On this unit, the signal appeared with DMD off and without new expansion-enable calls, after earlier DMD cycles. This does not establish cold-boot behavior. Do not attach an external transmitter to the TX pad or infer RX voltage tolerance from this test.

## Build in Android Studio

Open this directory. Use JDK 17 or 21, SDK Platform 36, Build Tools 35.0.0, NDK 27.2.12479018, and CMake 3.22.1. Gradle 8.13, AGP 8.13.2, Kotlin 2.2.21 are pinned; both arm64-v8a and x86_64 are built. API 26 minimum, target 36.

```sh
./gradlew assembleDebug lintDebug
./tests/run-native-tests.sh
```

Set `ANDROID_HOME` and `JAVA_HOME` for CLI builds. APK: `app/build/outputs/apk/debug/app-debug.apk`. The native check uses a real host pseudo-terminal, not tablet hardware. See `VALIDATION.md` for the actual build/device results.

This directory and the ZIP contain a local Git repository; no remote is configured. Build outputs and SDK-specific paths are ignored.
