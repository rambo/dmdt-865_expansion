# Remapped expansion-pad baseline - 2026-11-07

## CURRENT WIRING (user confirmed; viewed from tablet backside)

All probe grounds on pin 1. CH1 -> pin 6; CH2 -> pin 7; CH3 -> pin 3; CH4 -> pin 8.
Numbering remains row-wise: (1,2), (3,4), (5,6), (7,8), (9,10), (11,12).

## CLARIFIED REFERENCE OBSERVATION

Pin 7 is around 3.3 V relative to pin 1, but fluctuated when referenced to pin 8.
User explicitly states pin 7 was never referenced to pin 3; the earlier assistant
statement to that effect was incorrect and is not evidence.
Pin 8 is not established as ground. This observation alone does not identify it
as floating, a supply or a logic pin; probe/reference contact quality is another
possible cause. No continuity/resistance measurement was performed by the assistant.

## FRESH READ-ONLY SCOPE BASELINE, ALL GROUNDS ON PIN 1

Scope DS1074Z at 192.168.220.72:5555, AUTO, 5 ms/div; all channels DC coupled,
configured x10 and 1 V/div. Sequential live measurement queries, not a cycle capture.

| Pin | Channel | Average V | Peak-to-peak V |
| --- | --- | --- | --- |
| 6 | CH1 | 0.146 | 0.240 |
| 7 | CH2 | 3.316 | 0.200 |
| 3 | CH3 | -0.020 | 0.040 |
| 8 | CH4 | -0.047 | 0.240 |

Frequency queries were unavailable (9.9E37); these are not measured frequencies.
Pin 7 reads about 3.32 V relative to pin 1 in this snapshot. Pin 8 being close to
0 V relative to pin 1 does not establish that it is connected to ground.
Pin 3 was previously shown to pulse high during the authorized enable attempt;
its current low level is not evidence that it is ground.
No new LoRa enable/disable operation was performed with this remapped setup.
No scope configuration, power/GPIO, EEPROM or UART configuration/write changes
were made. Prior cycle waveforms retain their original channel-to-pin mapping.
