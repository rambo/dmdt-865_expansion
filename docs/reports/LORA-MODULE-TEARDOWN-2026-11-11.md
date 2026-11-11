# Thork/Topicon LoRa module teardown - 2026-11-11

Scope: eight user-supplied disassembly photographs; visual inspection and
manufacturer-datasheet comparison only. No hardware operations performed.
Original HEIC photos and JPEG previews: [photos and previews](../../measurements/photos/lora-teardown-2026-11-11/)

## IDENTIFICATIONS

### 1. Shielded radio: EBYTE E220-900T30S, directly legible in photo

IMG20261111193432. FCC ID reads 2ALPH-E220. Carrier reads
TH-Lora-E220-900T30S, V10-20251231--0x56, BC2602 (IMG20261111195254).
Enclosure label: MOD-LORA-02; input DC 5 V / 200 mA.
This identifies the actual T30S variant; earlier T22D documentation was a
family reference. The label is not a measured maximum TX current.

### 2. U2 EEPROM: ATMLH539 / 02CM TH / 2539V77 (IMG20261111195358).

The 02CM marking matches Atmel/Microchip AT24C02C: 2 Kbit / 256 bytes,
I2C, eight-pin package. Identification storage is consistent with the
previously traced vendor EEPROM API, but its contents have not been read.
The adjacent 0x56 silkscreen is consistent with a 7-bit I2C address: the
AT24C02C address format is 1010 A2 A1 A0, so 0x56 implies A2=1,A1=1,A0=0.
This remains a board-label inference, not an observed I2C response. It is
separate from SDK module-type identifiers.
Manufacturer datasheet (markings, address format and pinout):
https://ww1.microchip.com/downloads/en/DeviceDoc/AT24C01C-AT24C02C-I2C-Compatible-Two-Wire-Serial-EEPROM-1Kbit-2Kbit-20006111A.pdf

### 3. Chip marked ADRS / 883 (IMG20261111195406): high-confidence candidate

Monolithic Power Systems MP2155GQ buck-boost DC/DC converter. Manufacturer
ordering table specifies ADR top marking and QFN10 3 x 3 mm package. Ten
pads, adjacent L1 marked 3R3 (consistent with 3.3 uH), and surrounding
capacitors support that match. The trailing S / 883 has not been decoded;
full identification still needs electrical pinout/continuity confirmation.
The IC supports 2-5.5 V input, adjustable 1.5-5 V output, and an enable
input with load disconnect during shutdown. The actual board output
voltage and enable routing have NOT been established. The 2.2 A figure
in the IC title describes switches, not guaranteed board output current.
Manufacturer datasheet, especially ordering table on page 2:
https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MP2155GQ/document_id/1760/

### 4. U1: LPS / 1EDW1 (IMG20261111200420). Five pins, not six as

initially inferred from the wider photo. Strong match to Lowpower Semiconductor
LP3987H-33B5F, a 3.3 V / 600 mA-rated LDO. The manufacturer datasheet explicitly
lists LPS / 1eYWX for that variant; Y/W/X are production codes. This is a
marking-based identification; actual output voltage/load has not been measured.
Pinout from the datasheet: 1 VIN, 2 GND, 3 EN, 4 NC, 5 VOUT. EN is active high.
The board contains both this LDO and the candidate MP2155 buck-boost stage;
their interconnection and which loads they supply remain unknown.
Primary source, archived at references/lora-teardown/LP3987H.pdf:
https://admin.lowpowersemi.com/storage/files/2026-04/e58e13cbb5f9c58580aceb91f943f14e.pdf

### 5. Q1 and adjacent matching three-pin device: KN with a smaller trailing

character (IMG20261111200430). Candidate 2SK3018-family small N-channel
MOSFETs. ROHM's datasheet explicitly associates KN with 2SK3018 in UMT3/
SC-70, a 2.5 V-drive, 30 V / 100 mA device. KN markings are not unique,
so maker, exact model and package must still be verified. Do not infer
polarity or replacement compatibility solely from this short code.
ROHM manufacturer datasheet mirrored here:
https://www.alldatasheet.com/html-pdf/35912/ROHM/2SK3018/81/1/2SK3018.html
The repeated resistor/transistor layout is consistent with two signal
conditioning or level-shifting channels. Assigning them to UART, I2C,
mode control or another net requires continuity tracing.

### 6. Smaller devices beside RV-labelled footprints: likely transient/ESD

protection from the reference designators and placement. Their tiny marks
are insufficient for reliable part-number, topology or voltage identification.

## INTERPRETATION

The visible carrier is consistent with a UART radio adapter, identification
EEPROM, power conversion and signal-conditioning components. These photos
provide no positive evidence of a separate carrier MCU; they do not prove
one absent. U1 now has a strong regulator identification, strengthening the
simple-carrier interpretation. The EBYTE shield remains fitted, so no claim
about its internal processor can be made from these exterior images.

The converter and LDO enable inputs are useful candidates for tracing: a supply contact
could remain live while a GPIO enables the local radio power rail. This
could explain some earlier power-control observations, but does not prove
that GPIO 566 / logical I/O 1 / physical pin 3 reaches EN. UART voltage
translation, converter output, and M0/M1 routing remain unknown.

Next useful checks on the disconnected, unpowered carrier:

- Continuity from the carrier contacts to EEPROM SDA/SCL and address straps.
- Continuity from contacts to EBYTE RXD/TXD, M0/M1 and AUX, allowing for
  series parts or transistor stages that will prevent a direct beep.
- Verify the candidate converter pinout, then trace VIN/VOUT/EN.

Keep carrier contact orientation distinct from our tablet-back pin labels:
the two mating faces mirror one another.

No EEPROM writes, power injection, GPIO cycles or radio transmissions were
performed. This report records identifications and hypotheses, not a schematic.
