# T865 expansion-pad DC map — user measurements, 2026-11-07

FOLLOW-UP: WK2 RX on pin 11 and TX on pin 12 now confirmed both directions.

See [UART-END-TO-END-2026-11-07.md](UART-END-TO-END-2026-11-07.md). Voltages below are earlier idle measurements.

UART state: WK2 held open at 9600/8N1; TX idle. DMD LoRa off.
T865UartTx v1.2 now polls/logs received bytes for the planned external-MCU test;
pin 11 is confirmed by the external ESP32 test. See [RX-PROBE-WIRING.md](../../android/T865UartTx/RX-PROBE-WIRING.md).
Reference: pin 1. Backside rowwise numbering: (1,2)..(11,12).
These are user-reported sequential multimeter readings, not simultaneous samples.

| Pin | Voltage relative to pin 1 | Established role / uncertainty |
| --- | --- | --- |
| 1 | Reference | Ground reference used for these tests |
| 2 | Initially 2.5 V, now falling | Unknown; final voltage/rate not supplied |
| 3 | 0 mV | Previously software-controlled high pulse; low now does not establish ground |
| 4 | 1.79 V | Unknown |
| 5 | 1.5 V | Unknown |
| 6 | 36 mV | Unknown; low does not establish ground |
| 7 | 3.3 V | Supply/high-level candidate; role unconfirmed |
| 8 | 1 mV | Unknown; ground unconfirmed |
| 9 | 3.3 V | Supply/high-level candidate; role unconfirmed |
| 10 | 39 mV | Unknown; low does not establish ground |
| 11 | 2.49 V | WK2 RX confirmed with ESP32 GPIO26 payloads |
| 12 | 2.5 V | WK2 TX confirmed by exact decoded frames |

Pin 12 separately read 2.464 V relative to a cradle GND pad. The apparent
~36 mV reference difference could be ground offset or measurement variation.
Pins 6/10 read similarly small offsets, but that resemblance does not establish
an electrical connection, especially because 2.5 V was reported with less
precision and measurements were sequential. No continuity/resistance test made.
CH4 also read Vmax 3.44 V on pin 7 in the user's probe/channel comparison.

Pin 2's falling reading is consistent with several possibilities, including an
un-driven/weakly biased node or stored charge being discharged by the meter;
none is established. Do not label pin 2 as a 2.5 V rail based on the initial value.
Do not label near-zero pads as ground. In particular, pin 3 already has a
reproduced software-controlled pulse, despite its current zero reading.

No new UART writes, expansion power/GPIO commands, loopback or RX injection
were performed for this measurement set. Exact bridge supply and input voltage tolerance remain unverified; RX is now
confirmed by the later ESP32 test. The low-level app remains in idle
hold; it must not be resumed until requested.
