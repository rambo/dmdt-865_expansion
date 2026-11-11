# Unpowered radio PCB probing plan - 2026-11-11

Goal: recover the carrier's connector net map while its connector-side
components are accessible. Later, use the FPC adapter for live connector
measurements. This is a plan only: none of these measurements has been run.

## Preparation and notation

Detach the radio PCB and FPC from the tablet and every power source. First
check DC voltage between the candidate supply and ground and allow stored
charge to decay before selecting resistance/continuity. Do not short rails
with a probe to discharge them. Use ordinary low-power resistance measurements;
avoid high-current low-ohms or insulation-test modes.

Label connector contacts P1..P12 by the tablet-back row-first convention:

| Left | Right |
| --- | --- |
| P1 | P2 |
| P3 | P4 |
| P5 | P6 |
| P7 | P8 |
| P9 | P10 |
| P11 | P12 |

Transfer this convention to a photo of the PCB by physical mating orientation,
not by counting left-to-right on the flipped board. Label both FPC ends too.
IC pin numbers below are a separate numbering system.

Measure shorted-lead resistance first. Record actual ohms, not just a beep.
A stable value close to the lead/contact baseline, in both probe directions,
supports a copper/zero-ohm connection. A higher stable value may be a resistor;
a rising value may be capacitor charging; polarity dependence suggests a
semiconductor path. A beep by itself is not proof of a direct net. Inductor
windings also measure almost zero ohms between electrically distinct switch
nodes. Prefer accessible resistor/capacitor pads connected to a chip pin over
balancing probes on adjacent fine-pitch IC pins.

## 1. Establish ground and check every contact against it

Start with P1 to U2 EEPROM pin 4 (GND), U1 LDO pin 2 (GND), and the radio's
GND pad identified from its package drawing. Check connector plane, antenna
connector outer/shield and RF shield can against the same reference rather
than assuming they all share DC ground.
Then measure P2..P12 to confirmed ground. Record stable low-resistance contacts
as candidate additional grounds; record changing readings separately.
Outcome: known meter reference and a ground-contact list. This can resolve
whether P8 is genuinely ground, unlike the earlier near-zero voltage alone.

## 2. Trace the power topology, starting with P2

Working hypothesis: P2 is the wide supply trace and may be switched upstream.
Check P2 to:

- U1 pin 1 VIN and pin 5 VOUT.
- Candidate MP2155 pin 5 VIN, pin 8 VCC, and pin 1 VOUT.
- Radio VCC pad.
- U2 EEPROM pin 8 VCC.

Repeat those checks for P7 and P9, which previously measured about 3.3 V.
Trace U1 VOUT and MP2155 VOUT to radio VCC and EEPROM VCC to determine which
regulator supplies which load. Follow series resistors, beads or diodes if
there is no direct continuity. Do not infer 3.3/5 V just from continuity.

Also record supply-to-ground resistance after several seconds, noting whether
it rises. In-circuit capacitance readings are not needed: the parallel circuitry
makes them ambiguous. This test cannot by itself prove that the tablet switches
P2, but it can establish whether P2 is a carrier supply input.

## 3. Find enable inputs and radio mode connections

Prioritize P3, since it previously pulsed during LoRa initialization. Check
P3 to U1 EN (pin 3), candidate MP2155 EN (pin 6), and radio M0/M1.
Then trace each of those four endpoints to all connector contacts, not only P3.
For each endpoint record whether it is:

- Directly connected to a contact.
- Connected through a resistor or transistor.
- Tied to a local supply or ground.
- Connected to another mode/enable endpoint.

Measure resistance to ground and to its associated supply to look for bias
resistors, but record in-circuit readings as approximate circuit resistance.
Specifically check M0-to-M1 continuity; they may be independent, joined, or
locally controlled. Do not confuse MP2155 MODE/SYNC with the radio's M0/M1.
Outcome: distinguish a power-enable signal from radio mode selection.

## 4. Trace UART and assign the paired KN devices

Existing bench result: P11 is tablet RX; P12 is tablet TX.
Expected endpoint pairing if this carrier uses that same UART:

- P11 -> radio TXD (radio output into tablet RX).
- P12 -> radio RXD (tablet output into radio RX).

Check direct resistance first. If there is no direct connection, work inward
from each endpoint through nearby resistors and the two KN devices. On a photo,
label their three terminals A/B/C until the transistor pinout is verified;
the short marking is not enough to assume a BSS138 or ROHM pin order.
Map each terminal to connector contacts, radio UART endpoints, and local rails.
Record resistor markings and whether the paired circuits instead connect to
EEPROM SDA/SCL. This distinguishes UART translation from I2C translation.
Do not use in-circuit diode readings alone to identify the transistor.
Outcome: UART paths and any carrier-side voltage translation/bias network.

## 5. Map EEPROM and AUX

Trace U2 pin 5 SDA and pin 6 SCL to every connector contact, including through
series resistors or KN devices. Trace their pull-up resistor supply ends.
Check U2 pin 8 VCC against the already mapped rails.
Check address pins 1 A0, 2 A1, 3 A2 and pin 7 WP against GND and VCC.
The board's 0x56 label predicts A0 low, A1 high, A2 high if it is a 7-bit I2C
address; that remains a hypothesis until the straps or bus traffic confirm it.
Trace radio AUX to connector contacts and note any resistor/pull-up.
Outcome: identification bus, EEPROM supply/address/write-protect wiring and
radio busy/status output. No EEPROM programming or I2C scanning is needed now.

## 6. Verify the bare FPC and prepare the later live adapter

With BOTH ends disconnected, map each of its 12 contacts end-to-end and record
any contacts intentionally commoned together. Confirm the wide trace and plane
assignments. Check adjacent contacts for unintended solder bridges after any
adapter work. Do not assume straight-through numbering across mirrored faces.
Bring out all 12 contacts to labelled accessible pads/header terminals; provide
a verified ground connection beside signal access points. Preserve the original
supply/ground conductor capacity and mechanically support the flex and wires.
Keep signal branches short for later scope/logic-analyser use.

Before reassembly, take one labelled photo recording every confirmed endpoint.
If a necessary internal rail/EN is not exposed at the connector, either record
it as unavailable to the later connector-only test, or add an individually
insulated, strain-relieved test lead while unpowered if physically practical.
No internal powered probing is required for the present plan.

## Later powered observations (deferred, no commands executed)

- Measure P2 before/during/after a controlled LoRa enable cycle, including decay.
- Compare P3 and any mapped enable/mode/AUX signals with UART initialization.
- Capture EEPROM SDA/SCL to identify address and read traffic passively.
- Measure connector logic levels before attaching a logic analyser; regulator
  markings do not establish voltage at the tablet-facing signal contacts.

## Pinout references

IC pins below are separate from connector contacts P1–P12. Confirm package orientation before probing.

### U1: LP3987H-33B5F candidate

Verified manufacturer marking match; actual board output remains unmeasured.
See [LP3987H datasheet](../../references/lora-teardown/LP3987H.pdf), pages 1–2.

| IC pin | Signal |
| --- | --- |
| 1 | VIN |
| 2 | GND |
| 3 | EN |
| 4 | NC |
| 5 | VOUT |

### U2: AT24C02C, eight-pin package

See the [Microchip datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/AT24C01C-AT24C02C-I2C-Compatible-Two-Wire-Serial-EEPROM-1Kbit-2Kbit-20006111A.pdf).

| IC pin | Signal |
| --- | --- |
| 1 | A0 |
| 2 | A1 |
| 3 | A2 |
| 4 | GND |
| 5 | SDA |
| 6 | SCL |
| 7 | WP |
| 8 | VCC |

### Candidate MP2155GQ

Confirm ground and inductor connections before relying on this identification.
See [MP2155 datasheet](../../references/lora-teardown/MP2155.pdf), pages 2 and 11.
L1 should connect between SW1/SW2. Its DC continuity does not make these
pins suitable supply-voltage measurement points.

| IC pin | Signal |
| --- | --- |
| 1 | VOUT |
| 2 | SW2 |
| 3 | PGND |
| 4 | SW1 |
| 5 | VIN |
| 6 | EN |
| 7 | MODE/SYNC |
| 8 | VCC |
| 9 | AGND |
| 10 | FB |

### EBYTE E220-900T30S

Use the actual package drawing, not the earlier T22D manual or connector Pn.
The [archived 2022-hosted T30S manual](../../references/lora-teardown/E220-900T30S.pdf)
gives the following group on PDF pages 7–8 (printed pages 6–7).
**Other T30S manual versions number this group differently.** Confirm package
orientation and ground placement before applying these numbers; the checklist
therefore names radio signals instead of relying on numbers.

| Module pin in archived drawing | Signal |
| --- | --- |
| 1 | GND |
| 2 | VCC |
| 3 | AUX |
| 4 | TXD |
| 5 | RXD |
| 6 | M1 |
| 7 | M0 |

## Minimal measurement worksheet (duplicate rows for multiple connections)

| Connector | Endpoint/component pad | Ohms | Reversed probes | Notes |
| --- | --- | --- | --- | --- |
| P1 |  |  |  |  |
| P2 |  |  |  |  |
| P3 |  |  |  |  |
| P4 |  |  |  |  |
| P5 |  |  |  |  |
| P6 |  |  |  |  |
| P7 |  |  |  |  |
| P8 |  |  |  |  |
| P9 |  |  |  |  |
| P10 |  |  |  |  |
| P11 |  |  |  |  |
| P12 |  |  |  |  |

Minimum useful completion: confirmed ground, P2's destination, P3's destination,
UART endpoints, radio M0/M1/AUX routing, EEPROM SDA/SCL/VCC, and FPC map.
Unresolved paths should remain marked unknown rather than guessed.
