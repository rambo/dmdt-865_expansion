# Unpowered radio PCB probing plan - 2026-11-11

Goal: recover the carrier's connector net map while its connector-side
components are accessible. Later, use the FPC adapter for live connector
measurements. The original plan is dated 2026-11-11; user measurements from
2026-11-13 are recorded in the worksheet and interpretation sections below.

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

### U1 orientation in the PCB close-up

In [IMG20261111200420](../../measurements/photos/lora-teardown-2026-11-11/previews/IMG20261111200420.jpg),
viewed from the component side with the `3R3` inductor below U1, the three-lead
side is on the left and the two-lead side is on the right. The small dot beside
the upper-left lead marks pin 1. This matches the manufacturer's top-view
package drawing on page 2 of the archived LP3987H datasheet.

| Position in that photograph | U1 pin | Signal |
| --- | --- | --- |
| Upper left, beside dot | 1 | VIN |
| Middle left | 2 | GND |
| Lower left, nearest inductor | 3 | EN |
| Lower right, nearest inductor | 4 | NC |
| Upper right | 5 | VOUT |

User reports P1 to U1 pin 2 (middle lead on the three-lead side) below 1 Ω
on 2026-11-13. Together with the two 0.8 Ω readings below, this supports a
common ground connection between P1, U1 GND, U2 GND and the U.FL shield.
Shorted-lead/contact resistance and reverse-probe readings remain unreported.

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

### EBYTE E220-900T30S — user-confirmed 18-pad package

Use the [exact module manual supplied by the user](../../references/lora-teardown/E220-900T30S_UserManual_EN_v1.0.pdf),
section 3, printed pages 6–7 (PDF pages 7–8). The package drawing and pin table
confirm **radio pin 6 = VCC**. The older archived E220-900T30S.pdf describes a
**different 24-pad layout** and is not the probing reference for this module.
Radio pin numbers remain distinct from connector contacts P1–P12.

| Radio pin | Signal |
| --- | --- |
| 1 | M0 |
| 2 | M1 |
| 3 | RXD |
| 4 | TXD |
| 5 | AUX |
| 6 | VCC |
| 7 | GND |
| 8 | NC |
| 9 | GND |
| 10–14 | NC |
| 15–17 | GND |
| 18 | ANT |

In the manual's shield-side drawing, with the antenna connector at the lower
left, pins 7 down to 1 run down the left edge; pins 8 through 14 run down the
right edge. The opposite-side drawing is mirrored. Use the matching view when
probing the mounted board.

## Minimal measurement worksheet (duplicate rows for multiple connections)

| Connector | Endpoint/component pad | Ohms | Reversed probes | Notes |
| --- | --- | --- | --- | --- |
| P1 | U2 pin 4 (GND) | 0.8 Ω | Not reported | User measurement, 2026-11-13; shorted-lead baseline not yet reported. |
| P1 | U.FL shield | 0.8 Ω | Not reported | User measurement, 2026-11-13; shorted-lead baseline not yet reported. |
| P1 | U1 pin 2 (GND) | <1 Ω | Not reported | User measurement, 2026-11-13; shorted-lead baseline not yet reported. |
| P2 | U2 pin 4 (GND) | ≈500 Ω | Not reported | User measurement, 2026-11-13. |
| P2 | U1 pin 1 (VIN) | <1 Ω | Not reported | User measurement, 2026-11-13. |
| P2 | U1 pin 5 (VOUT) | ≈570 Ω, red on U1 pin 5 | Open or ≈1.2 kΩ on re-probing; stable while held, black on U1 pin 5 | User measurement, 2026-11-13; see polarity-check table below. |
| P2 | U2 pin 8 (VCC) | Open | Not reported | User measurement, 2026-11-13. |
| P2 | Radio pin 6 (VCC) | Open | Not reported | User measurement, 2026-11-13. |
| P3 | U2 pin 4 (GND) | Open | Not reported | User measurement, 2026-11-13. From “others open”. |
| P4 | U2 pin 4 (GND) | Open | Not reported | User measurement, 2026-11-13. From “others open”. |
| P5 | U2 pin 4 (GND) | <1 Ω | <1 Ω | User measurement, 2026-11-13; low resistance in both directions strongly supports a shared board ground. |
| P6 | U2 pin 4 (GND) | Open | Not reported | User measurement, 2026-11-13. From “others open”. |
| P7 | U2 pin 4 (GND) | ≈640 Ω | Not reported | User measurement, 2026-11-13. |
| P8 | U2 pin 4 (GND) | Open | Not reported | User measurement, 2026-11-13. |
| P9 | U2 pin 4 (GND) | ≈722 Ω | Not reported | User measurement, 2026-11-13. |
| P10 | U2 pin 4 (GND) | Open | Not reported | User measurement, 2026-11-13. From “others open”. |
| P11 | U2 pin 4 (GND) | ≈833 Ω | Not reported | User measurement, 2026-11-13. |
| P12 | U2 pin 4 (GND) | ≈833 Ω | Not reported | User measurement, 2026-11-13. |

Minimum useful completion: confirmed ground, P2's destination, P3's destination,
UART endpoints, radio M0/M1/AUX routing, EEPROM SDA/SCL/VCC, and FPC map.
Unresolved paths should remain marked unknown rather than guessed.

### Ground survey interpretation (2026-11-13)

The user confirms that U2 pin 4 was the accessible ground reference for this
connector survey; the pogo contacts are difficult to probe, so one connector
contact is measured at a time. “Others open” is interpreted as P3, P4, P6 and
P10. P1 already has the three ground-continuity measurements above. Meter range,
settling behaviour and shorted-lead baseline were not supplied. Reverse-probe
results are reported for P5 only. “Open” records the meter indication, not proof
that a contact has no circuit connection.

P5 to U2 pin 4 measures below 1 Ω in both probe directions, strongly supporting
P5 sharing the radio PCB ground. This establishes board-side continuity, not
the tablet-side contact's circuitry. The user suggests that the earlier unloaded
tablet-side P5 reading of 1.5 V could come from a weak pull-up. That is plausible
but unverified: no loaded tablet-side measurement or pull-up circuit trace exists.
Preserve the established mating-face numbering; the voltage difference alone
neither disproves the measured board ground nor proves a numbering error.

The finite 500–833 Ω readings are in-circuit resistance observations. They do
not identify discrete resistor values, supply voltage, input/output direction
or powered current consumption. Equal P11/P12 readings do not establish that
the two UART contacts are shorted together. The subsequent P2 trace below
establishes a low-resistance connection to U1 VIN; P3-to-U1 EN tracing remains outstanding.

### P2 power-path trace (2026-11-13)

P2 to U1 pin 1 (VIN) measures below 1 Ω, establishing a low-resistance path
from the connector to the LDO input. P2 to U1 pin 5 (VOUT) reads approximately
570 Ω; P2 to U2 pin 8 (VCC) and to the radio pin 6 (VCC) read
open. Reverse-probe results and settling behaviour were not reported.
These readings do not establish the applied supply voltage, whether the tablet
switches P2, or which loads receive power through a regulator when enabled.
The 570 Ω value is an in-circuit measurement, not an identified discrete resistor.

**Radio pin-number resolution:** on 2026-11-13 the user supplied the exact
18-pad module manual. Its pin table confirms the measured radio VCC pad is pin 6.
The previous discrepancy came from the archived manual for a different 24-pad
layout; the reference table above now uses the correct 18-pad manual.

### U1 output trace (2026-11-13)

| From | To | Reported resistance |
| --- | --- | --- |
| U1 pin 5 (VOUT) | U2 pin 8 (VCC) | <1 Ω |
| U1 pin 5 (VOUT) | Radio pin 6 (VCC) | ≈650 Ω |

The low-resistance connection establishes that U2 EEPROM VCC shares U1's output
net. U1's marking identifies the nominal 3.3 V LDO variant; no powered output
voltage has been measured. The 650 Ω in-circuit reading does not establish a
shared rail with radio VCC or a discrete 650 Ω resistor. Radio supply routing
remains unresolved. Reverse-probe readings and settling behaviour were not reported.

### U1 input/output probe-polarity check (2026-11-13)

| Red probe | Black probe | Reported resistance |
| --- | --- | --- |
| U1 pin 5 (VOUT) | P2 (connected to U1 VIN) | ≈570 Ω |
| P2 (connected to U1 VIN) | U1 pin 5 (VOUT) | Open or ≈1.2 kΩ on separate probe placements; stable while held |

The user now reports polarity-dependent readings between the LDO input and
output nets. This is consistent with semiconductor paths in the unpowered
circuit; it does not identify a fixed 570 Ω resistor or a particular internal
diode. The user clarifies that the reverse result changes only on re-probing:
each placement reads either open or approximately 1.2 kΩ, and the reading holds
while the probes remain in place. This is not a fluctuating reading under held
contact. The reason for the difference between placements has not been isolated;
the observation does not establish charging or meter-range changes.

Polarity dependence provides a plausible explanation for the earlier 570 Ω
P2-to-U1 pin 5 reading versus the open P2-to-U2 pin 8 reading, despite the
below-1 Ω connection between U1 pin 5 and U2 pin 8. The earlier probe polarity
was not recorded, and a matched-polarity repeat using U2 pin 8 has not been
reported, so retain both original observations. The direct low-resistance
connections still establish P2-to-U1 VIN and U1 VOUT-to-EEPROM VCC.

Next tracing target: P3 to U1 pin 3 (EN), with the board unpowered.
