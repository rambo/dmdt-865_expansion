# DMD T865/T865X expansion-port investigation

Android Kotlin/C/JNI tools, an ESP32 UART probe, measurements, driver research,
reference documents and printable connector fit gauges in one Git repository.

```sh
git lfs install
git clone git@github.com:rambo/dmdt-865_expansion.git
cd dmdt-865_expansion
```

Files over **1 MB** are stored in Git LFS throughout history. Run `git lfs pull`
if an existing checkout contains pointer text instead of waveforms, PDFs or models.
This repository has one Git root; the project directories are not submodules.

| Directory | Contents |
| --- | --- |
| [android/T865PortProbe](android/T865PortProbe/) | Kotlin UI and C/JNI metadata/read-only open probe for serial and SPI devices; Android Studio project. |
| [android/T865UartTx](android/T865UartTx/) | Kotlin UI and C/JNI WK2 UART transmitter and receive-only monitor; Android Studio project. |
| [firmware/ESP32UartProbe](firmware/ESP32UartProbe/) | ESP32-PICO-D4 sketch, GPIO26 TX / GPIO25 RX, plus serial validation scripts and logs. |
| [cad/fit-check](cad/fit-check/) | Four raised-label STL/DXF fit gauges, dimensions, generator and CAD validation. |
| [docs/measurements.md](docs/measurements.md) | Current electrical and mechanical findings, assumptions and measurement references. |
| [docs/reports](docs/reports/) | Driver/LoRa analysis, handoff, pin maps, scope summaries and app reports. |
| [android/T865PortProbe/analysis](android/T865PortProbe/analysis/) | Versioned original measurement bundles, raw scope channels, capture/decoding scripts, logcat, UI snapshots and earlier investigation evidence. |
| [measurements](measurements/) | Additional original scope workspace, SELinux/driver discovery, validation captures and measurement photos. |
| [references](references/) | Radio/connector datasheets, FCC photos, sourcing catalogues and reviewed reference images. |
| [releases](releases/) | Previously validated debug APKs for the two Android apps. |

The bench test established **tablet pin 11 = WK2 RX, pin 12 = WK2 TX**, with pin 1
as the common ground reference, at 9600/8N1. See the
[end-to-end evidence](docs/reports/UART-END-TO-END-2026-11-07.txt).
The LoRa radio itself was not attached or tested. Older reports are dated records;
their descriptions of live device state are not a claim about the device now.

## Build and use

Open either Android project directory directly in Android Studio. Its README and
`VALIDATION.md` describe the pinned JDK/SDK/NDK/Gradle versions and completed checks.
The projects include their Gradle wrappers. Machine-specific `local.properties`,
Gradle/NDK caches and build output are ignored.

The port-probe app defaults to metadata inspection and offers explicit read-only
open/close probes. The UART app changes serial settings and transmits only after
its Start action; receive-only idle is an explicit separate mode. Read each app's
hardware-boundary notes before using it. The ESP32 sketch starts transmitting on
boot. Hardware capture/validation scripts are retained as evidence and are not
automatically run by cloning or building this repository.

Install an existing debug APK from the repository root:

```sh
adb -d install -r releases/T865PortProbe-debug.apk
adb -d install -r releases/T865UartTx-debug.apk
```

Host native checks, which do not access the tablet:

```sh
android/T865PortProbe/tests/run-native-tests.sh
android/T865UartTx/tests/run-native-tests.sh
```

For the fit test, print [all four plates](cad/fit-check/T865-four-plates.stl) at
100% scale in millimetres. The [CAD README](cad/fit-check/README.md) explains the
32 x 40 mm provisional mounting pattern, offset variants and raised labels.

The three application histories were imported without squashing. The original
CAD history is also retained. Commit IDs affected by the large-file conversion
were rewritten before publishing the consolidated history. See
[source history](docs/source-history.json),
[evidence inventory](docs/evidence-manifest.json) and
[consolidation checks](docs/consolidation-validation.txt).
