# E220 feasibility bench evidence — 2026-11-16

This bundle contains actual measurements from the attached original Thork/Topicon
E220 carrier and two official Meshtastic nodes. See the repository's
`docs/reports/E220-MESHTASTIC-FEASIBILITY-2026-11-16.md` for interpretation.

## Recorded runs

| Files | Meaning |
| --- | --- |
| `initial-probe.script`, `initial-probe.jsonl` | Rootless shell UID, exact expansion ioctls, software-mode acknowledgement, firmware identity and register readback |
| `query-capabilities.script`, `query-labels.json`, `query-capabilities.jsonl` | Vendor and candidate PHY-setting queries with raw replies |
| `post-probe.script`, `post-probe.jsonl` | Software-switch query, unreadable vendor-key query, ambient RSSI query |
| `rf_test.py`, `rf-*.json*` | First 42-trial RF matrix with the saved vendor key unchanged |
| `rf_test_keyzero.py`, `rf2-*.json*` | Repeated matrix with temporary zero vendor key |
| `rssi_control_test.py`, `rf3-*.json*` | Settled receiver, two focused transmissions and E220 RSSI samples during a long packet |
| `peer*-lora-original.pb`, `peer*-lora-original.json` | Full original LoRa configs, without channel keys, for exact restore/readback |
| `baseline-ui.xml`, `final-ui.xml` | DMD LoRa OFF and Open Mode ON before and after the test |
| `app-capture-logcat.txt`, `app-context.txt` | Ordinary installed Android app successfully powering expansion, opening WK2 and stopping/closing/powering off |
| `final-restoration-probe.jsonl` | Power-cycle readback identical to the original register response |
| `summary.json` | Aggregate counts and the focused RSSI/control result |
| `e220-probe.c`, `e220-probe-arm64` | Native utility source and the executed arm64 diagnostic executable |

All RF payloads are generated bench markers on PRIVATE_APP with zero requested
hops and no requested ACK. E220 receives only; it sends no application payload.
Its UART does receive mode/query commands and temporary register writes.
Radio command replies and RSSI-query responses are distinguished from RF payloads.

## Native utility reproduction

Use the known, initially-off module with DMD LoRa and every other WK2 reader
stopped. `--power-on` takes ownership of position-2 power for this run, raises
logical I/O 1, and on exit restores its original raw I/O value and powers off.
It does not map or sweep other GPIO indices. Normal exit restores termios.

The exact native executable used here was built with NDK 27.2.12479018:

```sh
"$ANDROID_HOME/ndk/27.2.12479018/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android26-clang" \
  -Wall -Wextra -Werror -O2 -Wl,-z,max-page-size=16384 \
  e220-probe.c -o e220-probe-arm64
adb -d push e220-probe-arm64 /data/local/tmp/e220-probe
adb -d shell chmod 755 /data/local/tmp/e220-probe
adb -d shell /data/local/tmp/e220-probe --selftest
adb -d shell /data/local/tmp/e220-probe --power-on < initial-probe.script
```

This executes as Android shell UID 2000, not root. The separate installed-app
capture check establishes app-domain power/open access; see its context/log.
The three RF helpers are archived **as executed on this bench**, including the
local ADB executable path and two serial-port names. They require Python
`meshtastic==2.7.11` and `pyserial==3.5` and a deployed native utility.

These helpers are hardware-changing experiments, not automatic tests. They
change and read back both USB nodes' LoRa configurations, and restore the `.pb`
snapshots in `finally`. Their outputs are written beside the scripts. To rerun,
use a fresh working copy and capture fresh peer baselines first; do not overwrite
this evidence or restore stale snapshots over newer user settings. The first
two sweep seven PHY tuples and six E220 air-rate indices. The focused helper
uses only SF9/BW125, a warm-up frame, then a 200-byte payload with RSSI sampling.

No script sends persistent E220 register writes. The mode command's `C0 C1 C2 C3`
prefix is the verified software-mode extension, not a `C0 address length data`
persistent-register write. Air-rate changes and zero key use `C2`; final power
off discards those temporary values. The vendor key is write-only according to
the manual, so restoring its saved value by power cycle cannot be independently
read back; no persistent key write was made.
