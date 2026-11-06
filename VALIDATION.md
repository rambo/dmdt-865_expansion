# Validation — version 1.1, 2026-11-06

## Actual Android build

**PASS** — Gradle wrapper `assembleDebug lintDebug` completed successfully on macOS/Apple Silicon with Temurin JDK **17.0.21+9**, Gradle **8.13**, AGP **8.13.2**, Kotlin **2.2.21**, Platform **36**, Build Tools **35.0.0**, NDK **27.2.12479018** and CMake **3.22.1**.

Both `arm64-v8a` and `x86_64` native libraries compiled with `-Wall -Wextra -Werror`. The version 1.1 build completed in 13 seconds with 52 tasks (25 executed, 27 up to date). The source has no Kotlin compiler deprecation warning. APK versionCode is 2, versionName is 1.1.

Lint: **0 errors, 8 warnings**. Remaining warnings concern the pinned Gradle version (newer available), backup metadata (the app persists no reports), and six English-only UI strings. They are preserved in `validation/lint.txt`, not suppressed. `validation/build.log` contains the final build output with the local project path replaced by `<project>`.

The resulting debug APK passed `apksigner verify` (APK Signature Scheme v2) and `zipalign -c -P 16 4`. It includes both native ABIs and has min/target SDK 26/36. The merged manifest requests no permissions. Native undefined-symbol inspection found no write, ioctl or termios calls. Zip alignment is a packaging check; a 16 KiB-page runtime was not tested.

## Native self-check

**PASS** — `./tests/run-native-tests.sh` with AddressSanitizer and UndefinedBehaviorSanitizer. Checks the allowlist, metadata-only behavior, exact open flags, numeric/symbolic errno reporting, successful-close/error-close paths without retries, symlink/non-character rejection, metadata reads and absence of device reads, and report buffer bounds. System-call fakes mean successful device opens in this test do not involve hardware.

The expanded regression check failed against the previous code, then passed with this change. Mocked directory calls verify all six `/dev/spidev0.1` through `/dev/spidev0.6` opens even when `/dev` listing returns EACCES. A successful mocked listing includes those same six paths, `/dev/spidev0.0`, and an additional `/dev/spidev1.0`: the six explicit targets are opened only once each, 1.0 retains its existing discovery/probe behavior, and opening 0.0 is rejected. The fake open function asserts that it never receives `/dev/spidev0.0`.

## Emulator UI/JNI smoke test

**PASS** — installed and launched the final APK on an Android **14/API 34 arm64** Pixel 7 emulator running in a read-only, no-snapshot session:

- Startup completed and produced the version 1.1 JNI metadata report with all four serial paths, six explicit SPI paths and SPI sysfs directories.
- Default mode reported `device open: NOT REQUESTED` for all ten explicit paths.
- The app reported its real `untrusted_app` SELinux context. Reading global enforcing status failed with EACCES and remained unknown.
- The open-probe confirmation names the new SPI range and explicitly excludes 0.0. After confirmation **in the emulator**, JNI reported native `open` errno **2/ENOENT** for all four serial paths and all six SPI paths, which do not exist on this emulator. The six SPI sections each appear once. SPI 0.0 is mentioned only as an exclusion, with no device probe section.
- The probe completed and re-enabled the inspection controls.

The final emulator reports are retained as `validation/emulator-metadata.txt` and `validation/emulator-probe.txt`. They are examples from an emulator, **not T865 hardware results**.

## Scope not validated

Version 1.1 has not been installed or probed on the physical tablet. The user's earlier version 1.0 report showed successful read-only serial opens for WK1–3 and denied SPI directory enumeration; this update adds direct SPI paths to test independently of enumeration. Actual SPI access, T865X-specific kernel behavior, real electrical effects, real SPI/serial transfers, and Windows/Linux builds remain untested. There are intentionally no transfer or configuration operations to validate.

A read-only open/close can invoke vendor driver side effects. Use metadata-only inspection if zero device-open interaction is required.
