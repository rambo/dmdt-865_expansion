# Validation — 2026-11-16

This is validation of an Android mesh **bench implementation** and official
USB-node client. It does not qualify the E220 as a Meshtastic RF backend.

| Check | Result |
| --- | --- |
| Rust desktop tests | 10 passed |
| Rust Clippy | `--all-targets -- -D warnings` passed |
| Rust formatting | `cargo fmt --check` passed |
| Android `assembleDebug lintDebug` | Build succeeded; zero lint errors, six warnings |
| APK signature / alignment | Signature verified; ZIP 16 KB alignment passed; native ELF LOAD alignment 0x4000 |
| Actual device | Installed and launched on T865, serial `865025220042`, arm64-v8a, without root |
| Packaged Rust/JNI | Independent AES-CTR known-answer fixture, RF header, relay delay, deduplication, stream-framing self-test passed |
| Synthetic RF input | Decoded expected `T865 bench` text on the tablet |
| Rapid ADB lifecycle regression | Burst of selftest, decode and connect remained connected and reached config complete |
| Actual official USB node | `!f9b31230`, firmware `2.7.26.54e0d8d`, hardware enum 3 |
| Client handshake | MyNodeInfo, metadata, channels, LoRa settings, node DB and matching config nonce received |
| Client transmit | Self-addressed text accepted; firmware allocated ID `3721096796`; queue result 0 and routing ACK `ErrorReason(None)` correlated to it |
| Background operation | Foreground service and active partial wake lock verified after HOME |
| Normal Stop | Service disappeared and active wake lock was released |
| Peer RF configuration | Remained EU868 LongFast; no preset/frequency/power/key changes |
| Native E220 RF exchange | **Not tested or enabled** |
| New UART/power path on hardware | **Not exercised**: DMD's LoRa process was still running; no competing UART reader or unverified GPIO operation was introduced |

The self-addressed routing ACK is local official-firmware processing. It is not
an over-air test or proof that another node received anything. Its zero-valued
RSSI/SNR fields are protobuf defaults/local metadata, not measurements of an
RF link.

The first live connection revealed an initial `FromRadio.rebooted` marker before
configuration; this startup marker is accepted while waiting for initial config.
A reboot after an established connection invalidates the session and requires
reconnection. A separate rapid-command check exposed teardown of a newly queued
connection by an older one-shot test. Idle teardown now checks the latest start
request, and the final rapid-command/device check passed.

## Evidence

- [Build log](validation/build.log)
- [Build summary and APK SHA-256](validation/build-summary.json)
- [Final-device checks](validation/device-summary.json)
- [Final-device logcat](validation/device-logcat.txt)
- [Background service evidence](validation/background-service.txt)
- [Signature verification](validation/apksigner.txt), [ZIP alignment](validation/zipalign.txt)
- [Actual app screen](validation/app-screen.png)
- [Runnable Rust protocol tests](../../rust/tests/protocol.rs)

The six lint warnings concern a newer Gradle version, no ChromeOS x86_64 ABI,
backup-rule guidance, an active-session wake lock without a timeout, and two
untranslated-string occurrences. This is an English bench app for the tablet's
arm64 ABI. The wake lock's verified cleanup is tied to explicit session stop,
IO failure and service destruction. Screen-off/Doze endurance, process-death
hardware restoration and a full mixed-node RF mesh have not been validated.

The local Rust installation emitted a host `rust-objcopy`/LLVM warning on its
initial native compile; Android ELF output was produced successfully and is
explicitly stripped by the NDK tool. Final incremental build completed normally.
These SDK/toolchain warnings are distinct from app runtime failures.

## Remaining native-radio acceptance work

See [COMPATIBILITY.md](../../rust/COMPATIBILITY.md). In particular, identify the
actual E220 firmware, verify M0/M1 control and loaded voltage levels, establish
raw packet boundaries and exact PHY/sync/framing, add durable native node/packet
identity and PKI, and qualify the routing/timing policy against reference traces.
The current app has no switch that bypasses this gate.
