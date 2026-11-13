# Current measurement index - 2026-11-13

This is the entry point for the electrical and mechanical measurements. Earlier
reports preserve the sequence of observations and corrections; use the latest
confirmed statements here when interpreting those historical records.

## Pin numbering and UART

Looking at the tablet back with the camera toward the top and USB exiting right:

| Left | Right |
| --- | --- |
| 1 | 2 |
| 3 | 4 |
| 5 | 6 |
| 7 | 8 |
| 9 | 10 |
| 11 | 12 |

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

See [pin map](reports/EXPANSION-PIN-MAP-2026-11-07.md),
[UART end-to-end test](reports/UART-END-TO-END-2026-11-07.md),
[probe wiring](reports/RX-PROBE-WIRING-2026-11-07.md),
[driver analysis](reports/EXPAND-DRIVER-ANALYSIS.md) and
[full handoff](reports/EXPANSION-PORT-HANDOFF.md).

The [GpioControl API trace](gpio-control-api.md) identifies logical I/O indices
used by the SDK/factory client. Position 2 / I/O 1 maps to kernel GPIO 566 in the
recorded log. Factory indices 2..5 are readback inputs in its test sequence;
their current-kernel validity, direction capabilities and contact mapping remain
unverified. Connector numbering, logical I/O indices and kernel GPIO numbers are
separate namespaces.

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

**Selected fit baseline: P1 R2**, based on the later physical comparison on
2026-11-07. User reports P1 alignment "just about perfect", P2 visibly misaligned,
and P3/P4 very badly aligned. The photographs show the same progression. Pin 11
is **(5.500, 12.367) mm** relative to lower-left mounting centre A; pin 12 is
**(8.500, 12.367) mm**, and pin 1 is **(5.500, 27.367) mm** in the model's rear-view
coordinate system. Keep the existing 32 x 40 mm mount pattern and 3 mm grid for
the selected prototype. The CAD values do not establish sub-millimetre accuracy:
2.4 mm inspection windows, seating and photograph perspective limit that claim.
Recess depth, working compression and an electrical pogo-pin contact fit remain
unmeasured. The other offsets are retained as rejected test variants.

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
This was the earlier first-print observation. The subsequent R2 comparison selects
P1: IMG20261107221537 (P1), IMG20261107221707 (P2), IMG20261107221817 (P3) and
IMG20261107221926 (P4). See the CAD README for the comparison table.

Original versioned captures are under
[the port-probe analysis directory](../android/T865PortProbe/analysis/).
[measurements/scope-workspace](../measurements/scope-workspace/) preserves the
additional capture workspace with its original relative paths. Some files are
duplicates of the versioned bundles; this preserves bundle/script references.

[evidence-manifest.json](evidence-manifest.json) records source groups, repository
paths, byte sizes and SHA-256 hashes for supplementary imported evidence. It does
not enumerate the application files already preserved in their Git histories.

## LoRa module teardown (2026-11-11)

[Disassembly analysis](reports/LORA-MODULE-TEARDOWN-2026-11-11.md) identifies
the shielded module as **EBYTE E220-900T30S** and U2 as an **AT24C02C** EEPROM.
The `ADRS / 883` power-stage IC is a high-confidence **MP2155GQ buck-boost**
match (manufacturer top mark `ADR`, ten-pad package, adjacent `3R3` inductor).
Its output voltage and enable wiring remain unmeasured. The EEPROM's `0x56`
board label likely denotes its I2C address; no contents were read.
[Original photos and previews](../measurements/photos/lora-teardown-2026-11-11/)
preserve the evidence. These photos do not yet establish a carrier schematic
or prove the absence of an MCU.

Follow-up close-ups identify U1 as a strong **LP3987H-33B5F (3.3 V LDO)**
match using the manufacturer's `LPS / 1eYWX` marking table. The paired `KN`
transistors are candidate **2SK3018-family MOSFETs**; exact manufacturer and
signal connections remain unverified. U1 has five pins, correcting the
initial impression from the wider photo.

## Contact relocation adapter (2026-11-11)

[Adapter photos and assessment](reports/EXPANSION-ADAPTER-2026-11-11.md) show
a passive-looking flex between two 2 x 6 contact arrays, with pogo contacts
at one end and flat lands at the other. User reports four mounting screws
at one end and two at the other. Flex text includes `MDT65-barometer-FPC`
and `JFHD-MDT865`; the presumed phone association is unconfirmed.
No contact mapping or mechanical dimensions have been derived from the photos.

Caliper photos now record the FPC pogo block's black body as **18.67 x 6.67 mm**
(length x width). Body height, pin protrusion/travel, corner radii and flex-exit
clearance remain unmeasured; printer fit allowance is separate from these dimensions.

The [unpowered radio PCB probing plan](reports/RADIO-PCB-PROBE-PLAN-2026-11-11.md)
prioritizes ground, supply paths, enables/mode pins, UART and EEPROM mapping
before the connector side becomes inaccessible. Pin 2 as switched supply
is a working hypothesis from the wider FPC trace and earlier voltage decay,
not a confirmed electrical assignment.

## Radio PCB resistance measurements (2026-11-13)

| From | To | Reported resistance |
| --- | --- | --- |
| P1 | U2 EEPROM pin 4 (GND) | 0.8 Ω |
| P1 | U.FL shield | 0.8 Ω |
| P1 | U1 pin 2 (GND) | <1 Ω |

These user readings support P1 sharing ground with U1, the EEPROM and the
antenna connector shield. Shorted-lead/contact resistance and reverse-probe
readings were not supplied; the values include lead/contact resistance.
The [probing worksheet](reports/RADIO-PCB-PROBE-PLAN-2026-11-11.md)
records all three readings and the photo-based U1 pin orientation.
