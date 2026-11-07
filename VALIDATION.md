# Validation — 2026-11-07

- `assembleDebug lintDebug`: PASS with JDK 17.0.21, Gradle 8.13, AGP 8.13.2, Kotlin 2.2.21, SDK 36, NDK 27.2.12479018, CMake 3.22.1. arm64-v8a and x86_64 compile with `-Wall -Wextra -Werror`.
- Lint: 0 errors, 17 warnings (pinned Gradle version, backup metadata, English-only UI text). Full report retained; no issue suppressed.
- Native ASan/UBSan test: PASS. Actual pseudo-terminal verifies exact bytes, 9600/8N1/raw/no flow control, descriptor flags, missing/non-character/non-TTY errors, duplicate-open rejection, bounded write timeout, close-once behavior and requested termios restoration. macOS returns ENODEV for `/dev/null`, and may add the transient PENDIN flag when canonical mode returns; the check handles those host differences.
- Debug APK: v2 signature and 16 KiB ZIP alignment verified. No requested permissions. A 16 KiB-page runtime was not tested.
- Installed on the physical Android 16 T865, ordinary app UID 10204, with production SELinux policy. Native open/configure and repeated full 20-byte writes succeeded without root or expansion ioctls.
- ADB normal Stop succeeded, no frames continued after Stop, and Start resumed. Final build was reinstalled after normal Stop. Device UI and filtered app logcat are retained.
- Scope: pin 12 / CH4 decoded eight exact copies of `UUUU T865 UART WK2\r\n`, 160 bytes, 9600/8N1 noninverted, zero framing errors. Ground pin 1. Separate raw capture and decoder are retained in T865PortProbe/analysis/uart-wk2-pins3-4-7-12-2026-11-07/.

No UART RX, external module compatibility, voltage tolerance, cold-boot power sequencing, other UARTs, or Meshtastic traffic was tested. That initial session transmitted in the foreground for live probing; current state is recorded below. Scope identification relies on the user's stated physical pad placement.

## Version 1.1: UART idle hold

Actual `assembleDebug lintDebug` PASS. Added ADB `--ez idle true`: cancels periodic writes and keeps WK2 open/configured, or opens it without sending if initially stopped. Start resumes using that open session; Stop restores/closes as before. Native code is unchanged.

Installed on the tablet after normal Stop. UI and logcat show UART IDLE, with no TX frames from the new process. ADB `run-as` descriptor readback confirms fd 111 points to `/dev/ttysWK2`. It remains open in the foreground, with no repeating writes, for the user's multimeter measurement. Active-TX-to-idle cancellation was not exercised on hardware in this update, to avoid sending new frames during the requested idle measurement. Existing source closes the session on leaving the foreground.

User reports CH4 Vmax 3.44 V on pin 7. The scope is now in Auto sweep for current DC levels. The user then measured pin 12 at 2.5 V against pin 1 and 2.464 V against a cradle GND pad. These are user-reported meter readings, not remotely acquired samples. The approximately 36 mV difference may reflect ground offset or measurement variation; the UART bridge supply itself remains unmeasured. All-external-power keep-awake remains 15.
