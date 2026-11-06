# T865 Port Probe

Minimal Android Studio project: Kotlin platform UI plus a small C/JNI inspector. No Compose, AndroidX, root, shell commands, network permission, storage permission, or runtime permission requests. Package: `dev.t865.portprobe`. Android 8.0/API 26 or later; APK includes `arm64-v8a` (T865/T865X) and `x86_64`.

## Start here

1. Extract the ZIP and open the **T865PortProbe** folder in Android Studio (the folder containing `settings.gradle.kts`).
2. Set **Settings → Build, Execution, Deployment → Build Tools → Gradle → Gradle JDK** to **JDK 17 or 21**. Some newer Studio releases bundle JDK 25: choose/download 17 or 21 for this pinned Gradle 8.13 project. Studio's own runtime can remain unchanged.
3. In **Tools → SDK Manager**, install Android SDK Platform **36**, Build Tools **35.0.0**, NDK (Side by side) **27.2.12479018**, and CMake **3.22.1**. Enable **Show Package Details** to select versions. Sync Gradle; accept SDK licenses if prompted. Initial sync/build needs internet access.
4. Enable USB debugging on the tablet, connect it and accept its computer authorization. Select the tablet in Studio and run `app`.
5. The app automatically performs **metadata inspection only**. Use **Copy report** to retain results. Reports are held in memory and reset on recreation/relaunch; copying places them on the Android clipboard.
6. Only if opening devices is acceptable, choose **Probe read-only opens… → Open and close**. It repeats metadata inspection and attempts one open/close per allowed device. It never reads data from a device descriptor.

If you have the supplied debug APK, install it with `adb install -r T865PortProbe-debug.apk`, then launch **T865 Port Probe**. This is a locally signed development APK, not a production release.

## Hardware boundary

**Metadata inspection never opens `/dev/ttysWK*` or `/dev/spidev*`.** It uses directory listings, `lstat`, symlink reads and SELinux label queries, plus reads of the specific proc/sysfs metadata files listed below. It does not change sysfs values or bind/unbind drivers.

The optional device probe uses exactly:

```c
open(path, O_RDONLY | O_NONBLOCK | O_NOCTTY | O_CLOEXEC | O_NOFOLLOW);
close(fd); /* only after successful open */
```

There are no device `read`, `write`, `ioctl`, `tcsetattr`, `tcgetattr`, flush, baud-rate, modem-control or SPI-transfer calls. No chmod, chown, su, root requests, policy changes or permission workarounds exist. SPI setting ioctls are intentionally omitted.

**Read-only does not mean electrically inert.** A vendor driver's open/close handlers can power up hardware or assert/deassert signals, and terminal close can apply an existing HUPCL setting. O_NOCTTY prevents acquiring a controlling terminal; it does not suppress driver side effects. O_NONBLOCK requests nonblocking semantics, but cannot guarantee that a vendor driver returns promptly. No application can guarantee zero hardware interaction while executing a real device open. Use metadata-only mode when that guarantee is required, especially if another app is using these ports.

Inspections run on one background worker. A stuck kernel open/close cannot be safely cancelled by Java thread interruption; no timeout or retry claims are made. Buttons remain disabled until it returns. There are no automatic device probes or retries. A successful descriptor is closed once, including when close reports an error (retrying close can close a reused descriptor on Linux).

## What the report contains

- Model, Android/API, ABIs, UTC timestamp, app PID, UID/GID and supplementary groups.
- `/proc/self/attr/current` for the **app's** SELinux context. This is different from the ADB shell context.
- `/sys/fs/selinux/enforce`: `1` means globally enforcing; `0` means globally permissive. If access is denied, status is **unknown**, not inferred. Global enforcing status does not identify domain-specific exceptions.
- `/dev/ttysWK0`, `/dev/ttysWK1`, `/dev/ttysWK2`, `/dev/ttysWK3`: `lstat`, type, octal mode, owner/group IDs, character device major:minor, and `security.selinux` label via `lgetxattr` when readable.
- All visible `/dev/spidev*` entries with the same metadata. Actual opens are allowed only for exact `/dev/spidev<digits>.<digits>` names and the four serial paths. Known symlinks and non-character nodes are skipped; O_NOFOLLOW also rejects a final symlink at open time. No arbitrary path entry exists.
- Nonrecursive listings of `/sys/class/spi_master`, `/sys/bus/spi/devices`, and `/sys/class/spidev`. For each visible entry: symlink target, `driver` link target, and read-only `modalias` and `dev` attributes. Attributes absent for that entry report ENOENT; this is normal.
- Exact numeric errno and a symbolic name for common errors, together with `strerror`, for failed system calls. Device-open success reports errno=0 explicitly; it does not display stale errno left by another call.

Directory listings distinguish failure from an empty visible listing. Reports are bounded to 128 KiB, with a truncation marker, and 256 matching entries per directory. Individual metadata reads are limited to 1 KiB. Control/non-ASCII bytes are escaped. Listings follow kernel directory order.

## Interpret results

| Result | Meaning |
| --- | --- |
| `device open: SUCCESS` | This app could obtain a read-only descriptor at that instant. It does not establish functional serial/SPI transfers, wiring, exclusivity, or the access rights of another app. |
| EACCES / EPERM | An access restriction. File ownership/mode, SELinux or another restriction may be involved; errno alone cannot identify which. |
| ENOENT | That path was missing or not visible in this process's namespace at that instant. |
| ENODEV / ENXIO | The node may exist but the backing driver/device is unavailable. |
| EBUSY | The driver rejected access as busy; an exclusive user may be present. |
| Empty or inaccessible SPI listings | No SPI entries were visible through that interface. This does not prove that the board has no SPI controller or SPI peripherals. |

An ordinary app UID does not inherit ADB shell groups or another vendor app's privileges. JNI reports the real native result but cannot bypass Android DAC/SELinux. Successful ADB access would not prove that this app can access the same node. A missing `/dev/spidev*` node can coexist with SPI peripherals bound to kernel-specific drivers.

To look for a **matching** SELinux denial without changing policy, run on your computer immediately after a probe:

```sh
adb logcat -b all -d > portprobe-logcat.txt
```

Search that file for `avc: denied`, the device basename (`ttysWK0`, etc.), the app PID/context from the report, and the probe time. A matching AVC can identify SELinux involvement. Production log access and rate limiting may hide denials; no visible AVC is inconclusive. The app does not claim to collect global audit logs. Logcat can contain unrelated private information: share only relevant excerpts.

## Command-line build

Set `JAVA_HOME` to a JDK 17/21 and `ANDROID_HOME` to your Android SDK, or let Android Studio create an untracked `local.properties` with `sdk.dir=...`.

```sh
./gradlew assembleDebug lintDebug
# Windows:
gradlew.bat assembleDebug lintDebug
```

APK: `app/build/outputs/apk/debug/app-debug.apk`.

The checked-in wrapper JAR/scripts pin **Gradle 8.13** and verify the distribution SHA-256. AGP is **8.13.2**, Kotlin is **2.2.21**, compile/target SDK are **36**; min SDK is **26**. These are fixed versions, not dynamic latest dependencies. Android Studio may suggest upgrading them; an upgrade is not required to build this project.

## Native self-check

On macOS or Linux with Clang/GCC and AddressSanitizer/UBSan support:

```sh
./tests/run-native-tests.sh
```

This compiles the actual production C source with fake `open`, `read`, `close` and `lstat`. It checks the device allowlist, metadata-only behavior, exact read-only/nonblocking flags, errno preservation, close-once behavior, symlink/non-character rejection, metadata reads, absence of device reads, and buffer bounds. It does not open real hardware or establish vendor driver behavior. See `VALIDATION.md` for the actual build results delivered with this project.

## Git

The delivered directory and ZIP include a local Git repository on branch `main` with the initial source and validation evidence committed. No remote is configured. Gradle caches, build outputs, IDE files and machine-specific SDK paths are ignored. The prebuilt APK is delivered separately.

```sh
git status
git log --oneline
```

## Primary references

- [AGP 8.13 compatibility and release notes](https://developer.android.com/build/releases/agp-8-13-0-release-notes)
- [Android Kotlin/AGP compatibility](https://developer.android.com/build/kotlin-support)
- [Linux SPI userspace API](https://www.kernel.org/doc/html/latest/spi/spidev.html)
- [Linux open(2) flag semantics](https://man7.org/linux/man-pages/man2/open.2.html)
- [AOSP SELinux diagnostics](https://source.android.com/docs/security/features/selinux/validate)
