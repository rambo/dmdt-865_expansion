# Validation — 2026-11-06

## Actual Android build

**PASS** — Gradle wrapper `assembleDebug lintDebug` completed successfully on macOS/Apple Silicon with Temurin JDK **17.0.21+9**, Gradle **8.13**, AGP **8.13.2**, Kotlin **2.2.21**, Platform **36**, Build Tools **35.0.0**, NDK **27.2.12479018** and CMake **3.22.1**.

Both `arm64-v8a` and `x86_64` native libraries compiled with `-Wall -Wextra -Werror`. The final build completed with 52 tasks (19 executed, 33 up to date), after a successful initial build that executed all 52 tasks. The final source has no Kotlin compiler deprecation warning.

Lint: **0 errors, 8 warnings**. Remaining warnings concern the pinned Gradle version (newer available), backup metadata (the app persists no reports), and six English-only UI strings. They are preserved in `validation/lint.txt`, not suppressed. `validation/build.log` contains the final build output with the local project path replaced by `<project>`.

The resulting debug APK passed `apksigner verify` (APK Signature Scheme v2) and `zipalign -c -P 16 4`. It includes both native ABIs and has min/target SDK 26/36. The merged manifest requests no permissions. Native undefined-symbol inspection found no write, ioctl or termios calls. Zip alignment is a packaging check; a 16 KiB-page runtime was not tested.

## Native self-check

**PASS** — `./tests/run-native-tests.sh` with AddressSanitizer and UndefinedBehaviorSanitizer. Checks the allowlist, metadata-only behavior, exact open flags, numeric/symbolic errno reporting, successful-close/error-close paths without retries, symlink/non-character rejection, metadata reads and absence of device reads, and report buffer bounds. System-call fakes mean successful device opens in this test do not involve hardware.

## Emulator UI/JNI smoke test

**PASS** — installed and launched the final APK on an Android **14/API 34 arm64** Pixel 7 emulator running in a read-only, no-snapshot session:

- Startup completed and produced the JNI metadata report with all four serial paths and SPI sysfs directories.
- Default mode reported `device open: NOT REQUESTED` for all four serial paths.
- The app reported its real `untrusted_app` SELinux context. Reading global enforcing status failed with EACCES and remained unknown.
- The open-probe confirmation was displayed and visually inspected. After explicit confirmation **in the emulator**, JNI reported native `open` errno **2/ENOENT** for all four serial paths, which do not exist on this emulator.
- The probe completed and re-enabled the inspection controls.

The final emulator reports are retained as `validation/emulator-metadata.txt` and `validation/emulator-probe.txt`. They are examples from an emulator, **not T865 hardware results**.

## Scope not validated

No app installation or device-node open probe was performed on the connected physical tablet. Only its basic properties were read: model T865, API 34, production `user` build, arm64 support. T865X-specific kernel behavior, successful access to its device nodes, real electrical effects, real SPI/serial transfers, and Windows/Linux builds were not tested. There are intentionally no transfer or configuration operations to validate.

A read-only open/close can invoke vendor driver side effects. Use metadata-only inspection if zero device-open interaction is required.
