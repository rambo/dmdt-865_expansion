# T865 Mesh Bench

Kotlin Android app with a Rust/JNI protocol engine, for the production T865X
without root. This is a working bench implementation, **not yet an independent
Meshtastic radio node through the E220**.

| Mode | What works | Where routing runs |
| --- | --- | --- |
| Computer USB peer | Official serial API handshake, configuration inventory, received messages, one-shot text sends and routing/queue reports | Official firmware on the external USB node |
| E220 UART capture | `/dev/ttysWK2`, selectable baud, raw 8N1, bounded nonblocking reads, errno/SELinux errors, normal-stop termios restoration | No packet routing: reads are byte-stream chunks |
| Native Rust bench | Legacy RF codec, channel AES-CTR, bounded CLIENT-role forwarding, retries, ACKs and basic next-hop learning/fallback | Rust, using synthetic complete RF frames |

The service remains active when the Activity goes into the background. A foreground
notification provides Stop; a partial wake lock exists only during a connection.
A process restart never automatically reconnects or retransmits messages.

## Install and inspect logs

From the repository root, using the committed debug APK:

```sh
adb -d install -r releases/T865Mesh-debug.apk
adb -d shell am start -n dev.t865.mesh/.MainActivity
adb -d logcat -v threadtime -s T865Mesh:I AndroidRuntime:E
```

Allow the notification permission to make Stop easily accessible. The report
contains received message text and node identifiers, but never channel PSKs or
node private keys. Treat copied reports as communications logs.

Copy report is available in the app. ADB can read the private saved report directly:

```sh
adb -d exec-out run-as dev.t865.mesh cat files/latest-report.md > T865Mesh-report.md
```

This avoids Android's restricted clipboard access.

## Test with the computer's USB node

Disconnect the Meshtastic desktop application from the serial port first. The
bridge checks for an existing opener and binds only to localhost. Python needs
only `pyserial==3.5`:

```sh
python3 -m venv /tmp/t865-mesh-bridge
/tmp/t865-mesh-bridge/bin/pip install pyserial==3.5
/tmp/t865-mesh-bridge/bin/python tools/meshtastic_usb_bridge.py \
  --port /dev/cu.usbserial-595D0026461
```

In another terminal:

```sh
adb -d reverse tcp:4403 tcp:4403
adb -d shell am start -n dev.t865.mesh/.MainActivity --es command connect
```

Wait for `config_complete` with `matched:true`. The app displays the peer's
firmware, node ID, channel indices and LoRa settings. Enter a hex destination
(`!ffffffff` broadcasts), channel index and message, then Send once. Text is
limited to 200 UTF-8 bytes. A successful socket write is **not** delivery;
inspect subsequent peer queue and routing events. The official node allocates
the packet ID, preserving its own encryption nonce namespace.

For the first API-only check, address the node itself; the validation used
`!f9b31230`. A local routing ACK proves API acceptance and local processing,
not transmission or reception through the E220.

```sh
adb -d shell am start -n dev.t865.mesh/.MainActivity \
  --es command send --es to '!f9b31230' --ei channel 0 \
  --es text T865_USB_API_loopback_test
```

For over-air testing through this **USB-node mode**, use a second official node
with matching settings. The tablet is a client of the USB node in this mode;
it is not replacing that node's routing firmware.

Stop in the app or run:

```sh
adb -d shell am start -n dev.t865.mesh/.MainActivity --es command stop
adb -d reverse --remove tcp:4403
```

Then stop the bridge with Ctrl-C; the serial port is released for the desktop app.

## Capture the original E220

Keep DMD LoRa and the earlier UART TX app stopped. Confirm exclusive ownership
in the UI, select the known UART baud (default 9600), and start capture. The
advisory UART lock protects cooperating applications only; it cannot exclude
DMD, which does not use this lock.

Capture makes no UART writes and sends no radio configuration commands. It
configures UART termios and restores the saved settings on normal Stop.
A successful open does not establish radio power or RF compatibility.

The additional, **off-by-default** power checkbox applies the traced DMD
sequence: `/dev/expand` position 2 power on, logical I/O 1 high, wait 100 ms.
It requires the module to start powered off and this app to be its sole owner.
On Stop, close/restore UART, lower I/O 1 and disable position-2 power. This is
power/enable control, not M0/M1 mapping or radio TX-power configuration. Failed
ioctls report errno and SELinux context. Accepted ioctls are not voltage readback.
The two unverified mode controls are never swept or driven.

If power was already enabled elsewhere, leave the power checkbox clear: the
app then neither claims nor disables that supply. Forced process death cannot
guarantee restoration of termios or GPIO/power state; use Manage to recover.

ADB capture, with no power operation:

```sh
adb -d shell am start -n dev.t865.mesh/.MainActivity \
  --es command capture --ei baud 9600 --ez exclusive true
```

Add `--ez power true` only for the explicitly owned, initially-off module.
`UART_STREAM` lines are read chunks, **not RF frame boundaries**. Native RF TX
has no override switch: it remains blocked until the firmware/PHY/framing gate
in [the compatibility record](../../rust/COMPATIBILITY.md) is satisfied.

## Run the Rust checks on the tablet

```sh
adb -d shell am start -n dev.t865.mesh/.MainActivity --es command selftest
```

This exercises the actual packaged JNI library, including an independent
AES-CTR known-answer vector, header codec, delayed relay, deduplication and split
client frames. No hardware is opened or transmitted to.

A synthetic complete RF frame can also be decoded on the tablet:

```sh
adb -d shell am start -n dev.t865.mesh/.MainActivity --es command decode \
  --es frame ffffffff785634122a000000630800789db4f0fc307cd0bf81698bfad51b \
  --es name LongFast --es key 01
```

Expected text: `T865 bench`. This is a synthetic fixture, not a capture from RF.

## Build in Android Studio or from the terminal

Open this directory in modern Android Studio. Install SDK platform 36, NDK
27.2.12479018 and JDK 17. Install Rust with the Android target; the validated
compiler was `rustc 1.98.1`, minimum Rust 1.88. Dependencies are locked in
[Cargo.lock](../../rust/Cargo.lock), including the vendored protoc compiler.

```sh
rustup target add aarch64-linux-android
export ANDROID_HOME="$HOME/Library/Android/sdk"
# Use your JDK 17 installation for JAVA_HOME.
cd android/T865Mesh
./gradlew assembleDebug lintDebug
```

Gradle invokes `build-native.sh`; source changes rebuild Rust automatically.
Cargo must be on PATH or in `$HOME/.cargo/bin`, or set `CARGO` to its executable.
The native library targets `arm64-v8a`, uses 16 KB ELF load alignment, and is
stripped with the pinned NDK's LLVM tool. Android Studio's `local.properties`
can supply `sdk.dir` instead of ANDROID_HOME. Native builds support macOS/Linux
(and WSL); there is no Windows-native build script yet.

Output: `app/build/outputs/apk/debug/app-debug.apk`. The generated JNI library,
Cargo targets and Gradle outputs are ignored by Git. Do not commit signing keys.

See [validation](VALIDATION.md), [Rust source and checks](../../rust/README.md),
and [the earlier implementation plan](../../docs/plans/MESHTASTIC-RUST-PLAN.md).
