# Validation — 2026-11-07

- `assembleDebug lintDebug`: PASS with JDK 17.0.21, Gradle 8.13, AGP 8.13.2, Kotlin 2.2.21, SDK 36, NDK 27.2.12479018, CMake 3.22.1. arm64-v8a and x86_64 compile with `-Wall -Wextra -Werror`.
- Lint: 0 errors, 17 warnings (pinned Gradle version, backup metadata, English-only UI text). Full report retained; no issue suppressed.
- Native ASan/UBSan test: PASS. Actual pseudo-terminal verifies exact bytes, 9600/8N1/raw/no flow control, descriptor flags, missing/non-character/non-TTY errors, duplicate-open rejection, bounded write timeout, close-once behavior and requested termios restoration. macOS returns ENODEV for `/dev/null`, and may add the transient PENDIN flag when canonical mode returns; the check handles those host differences.
- Debug APK: v2 signature and 16 KiB ZIP alignment verified. No requested permissions. A 16 KiB-page runtime was not tested.
- Installed on the physical Android 16 T865, ordinary app UID 10204, with production SELinux policy. Native open/configure and repeated full 20-byte writes succeeded without root or expansion ioctls.
- ADB normal Stop succeeded, no frames continued after Stop, and Start resumed. Final build was reinstalled after normal Stop. Device UI and filtered app logcat are retained.
- Scope: pin 12 / CH4 decoded eight exact copies of `UUUU T865 UART WK2\r\n`, 160 bytes, 9600/8N1 noninverted, zero framing errors. Ground pin 1. Separate raw capture and decoder are retained in T865PortProbe/analysis/uart-wk2-pins3-4-7-12-2026-11-07/.

No UART RX, external module compatibility, voltage tolerance, cold-boot power sequencing, other UARTs, or Meshtastic traffic was tested. The app is left transmitting in the foreground for live probing. Scope identification relies on the user's stated physical pad placement.
