# Current measurement index - 2026-11-07

This is the entry point for the electrical and mechanical measurements. Earlier
reports preserve the sequence of observations and corrections; use the latest
confirmed statements here when interpreting those historical records.

## Pin numbering and UART

Looking at the tablet back with the camera toward the top and USB exiting right:

```text
 1   2
 3   4
 5   6
 7   8
 9  10
11  12
```

Pin 1 is the user's ground reference. Pin 11 is /dev/ttysWK2 RX and pin 12 is
/dev/ttysWK2 TX, physically verified with exact payloads in both directions
using ESP32 GPIO26 TX and GPIO25 RX, at 9600/8N1. No new /dev/expand enable
command was used in that bench test; cold-boot behaviour without preceding DMD
enable cycles is untested. The radio module was not fitted.

| Pin | User's sequential multimeter reading relative to pin 1 |
| --- | --- |
| 2 | Initially about 2.5 V, falling; final level not established |
| 3 | 0 mV at that instant; separately observed to pulse high during LoRa enable |
| 4 | 1.79 V |
| 5 | 1.5 V |
| 6 | 36 mV |
| 7 | 3.3 V |
| 8 | 1 mV; not established as ground |
| 9 | 3.3 V |
| 10 | 39 mV |
| 11 | 2.49 V; confirmed UART RX |
| 12 | About 2.5 V idle; confirmed UART TX |

Pin 12 also measured 2.464 V relative to a cradle ground pad. The measurements
were sequential, so that difference does not establish a fixed ground offset.
Low readings do not identify a ground pin, and measured high levels do not
establish input tolerance, output current capability or a usable supply.

See [pin map](reports/EXPANSION-PIN-MAP-2026-11-07.txt),
[UART end-to-end test](reports/UART-END-TO-END-2026-11-07.txt),
[probe wiring](reports/RX-PROBE-WIRING-2026-11-07.txt),
[driver analysis](reports/EXPAND-DRIVER-ANALYSIS.txt) and
[full handoff](reports/EXPANSION-PORT-HANDOFF.txt).

## Connector and mounting geometry

Contact openings are approximately 1.6 mm diameter. Measured outside spans
4.6 mm across two holes and 16.4 mm across six support a nominal **3 x 3 mm**
contact grid, with a 15 x 3 mm contact-centre rectangle.

Four mounting locations form a rectangle; the upper-left screw also retains
the cap of the round screw-in connector. The screw measured 1.94 mm outside
diameter, consistent with M2; the threaded opening measured about 1.75 mm.
Thread pitch and usable engagement depth were not measured.

The mounting spans **33.55 and 41.37 mm** were measured across the farthest
edges of the **threaded openings**, not the brass insert OD. Subtracting 1.75
gives 31.80 x 39.62 mm centres. The gauges test provisional nominal **32 x 40 mm**
spacing. It is not a verified OEM pattern; the long-axis difference is 0.38 mm.

The brass insert visible OD is **3.3 mm**, surrounded by a roughly 4 mm plastic
ring. The later 8.58 and 15.01 mm pin-11 spans referenced the brass OD and contact
opening, giving rough offsets 6.13 x 12.56 mm. These have substantially larger
error because there was no hard measurement stop.

A later shortest diagonal gap between the threaded-opening edge and pin-11
opening edge was **11.86 mm**, with further readings 11.75 and 12.00 mm and
approximately +/-0.1 mm error. This implies **13.535 mm centre distance** for
the working 11.86 value. It constrains a radius, not a unique contact angle.

The four [labelled fit gauges](../cad/fit-check/README.md) vary the pin-11
X offset from 5.5 to 7.0 mm and derive Y to preserve that diagonal. Original
[HEIC photos](../measurements/photos/originals/) and
[JPEG previews](../measurements/photos/previews/) document the measurements.

See [reference index](../references/README.md) for individual pogo-pin candidates
and the earlier connector sourcing leads. No off-the-shelf 2x6/3 mm EU-stock
connector or final mechanical fit was established in that search.

## Evidence organization

First fit-check photos (IMG20261107175954 and IMG20261107180655): the user reports
slight top mounting-hole misalignment for P1 and good top-hole alignment for P2.
Their CAD mounting-hole coordinates are identical; printing, placement and seating
differences have not been isolated. The original contact inspection holes were too
small to judge alignment reliably. R2 enlarges those holes from 1.6 to 2.4 mm and
adds a raised revision label, while retaining all centres and offset variants.
The new R2 prints and the best contact-grid offset remain unverified.

Original versioned captures are under
[the port-probe analysis directory](../android/T865PortProbe/analysis/).
[measurements/scope-workspace](../measurements/scope-workspace/) preserves the
additional capture workspace with its original relative paths. Some files are
duplicates of the versioned bundles; this preserves bundle/script references.

[evidence-manifest.json](evidence-manifest.json) records source groups, repository
paths, byte sizes and SHA-256 hashes for supplementary imported evidence. It does
not enumerate the application files already preserved in their Git histories.
