# T865 pins 9–11 LoRa cycle — 2026-11-07 11:54 EET (09:54 UTC)

One further cycle was explicitly requested after the probe remap. It completed.
LoRa OFF, no running LoraService, display keep-awake setting 0 and original scope
settings were restored and checked. No extra retry was made.

## SETUP AND RESULTS

Ground remains pin 1. Numbering is rowwise from tablet backside, (1,2)..(11,12).

| Channel | Stated pad | Min V | Median V | Max V |
| --- | --- | --- | --- | --- |
| CH1 | pin 10 | 0.144 | 0.240 | 0.336 |
| CH2 | pin 9 | 3.198 | 3.341 | 3.437 |
| CH3 | pin 3 | 0.000 | 0.000 | 0.000 CONTACT STILL UNVERIFIED |
| CH4 | pin 11 | 2.356 | 2.452 | 2.597 |

Pin 9 appears continuously near 3.3 V; pin 11 near 2.45 V; pin 10 near 0.24 V.
No channel spans even 0.3 V; no normal 3.3 V UART transitions are visible.
These DC levels alone do not identify power, UART, input, output or ground pins.
Pin 11's approximately 2.45 V could have several causes; do not label it TX/RX
without further evidence. All scope channels are enabled, DC, 10x factor, 1 V/div.
Physical tip contact and probe attenuation switches were not independently checked.

CH3 remained exactly one ADC code. The user reported possible CH3 misalignment
in the preceding cycle. Its contact remains unverified; do not infer pin-3
behavior from this flat trace. The earlier CH2/pin-3 capture of a 708 ms pulse
remains the stronger evidence. A channel/probe contact check is the next useful
step before interpreting or repeating pin-3 measurements. Pin 8 is not ground
by assumption; earlier pin-7 fluctuation was relative to pin 8, never pin 3.

## CAPTURE AND SOFTWARE ACTIVITY

12 seconds/channel: 3,000,000 BYTE samples at 4 us/sample, -1.2..+10.799996 s.
Arming waited for WAIT, forced the trigger, and verified TD before the enable
tap (09:54:39.238–09:54:39.344 UTC). Trigger source CH2 level -4 V was solely a
scope setting to avoid spontaneous triggers; no voltage was applied to a pad.
Scope STOP confirmed 09:54:50.151; restored OFF read back 09:54:55.646 UTC.
Host UTC and tablet epoch clocks were not independently synchronized.

DMD opened /dev/expand, set expansion position 2 power on and I/O 1 high with
native return value 0. Driver reported right-position user=1 and GPIO566 high
SUCCESS. It opened /dev/ttysWK2 at 9600/8N1; SleepConfig failed without a module.
Power-off and GPIO release followed about 691 ms after the driver's power-on.
This was the sixth consecutive initialization failure with no prior success;
DMD again saved lora_enabled=false. That automatic preference change does not
establish an irreversible lockout. Failure counters were left intact.
Software success logs do not prove a particular contact voltage or assign GPIO566
to a physical pad. No custom /dev/expand ioctl or independent UART write was sent;
the authorized DMD switch invokes its normal GPIO/power/UART initialization.

## FILES AND LIMITATIONS

pins9-11-lora-cycle-2026-11-07/ contains raw BYTE samples, per-channel preambles,
scope screenshot, command transcripts, UI OFF/ON/OFF evidence, filtered logcat,
settings, UTC events and one-shot scripts. SHA256SUMS.txt covers saved artifacts.
Voltage = (BYTE - preamble[8] - preamble[9]) * preamble[7].
Time = (index - preamble[6]) * preamble[4] + preamble[5].
Scope quantization is about 48 mV/count: these are approximate voltages.
UART contacts and pin 8's role remain unknown; no radio module was attached.
The scripts are records of this one authorized experiment, not autonomous tests.
