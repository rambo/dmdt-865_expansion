# T865 post-update expansion investigation - 2026-11-07

## RESULT: SUCCESSFUL ADDITIONAL CAPTURE

The user separately approved one additional cycle after the first missed scope
trigger. The second capture succeeded: pin 3 / CH2 rose from approximately 0 V
to a median 3.34 V for 708.136 ms, then returned low as DMD's initialization
failed and its power-off/GPIO-release path ran. Pin 3 is software controlled.
Because DMD calls both setPower and writeIo(1,true), this experiment does not
distinguish a switched supply from a GPIO/enable output, nor uniquely identify
pin 3 as kernel GPIO 566. Those remain hypotheses requiring an isolated test.
No UART byte waveform was found on the four probed pads during the capture.
LoRa was restored to its original OFF setting, scope settings were restored,
and the temporary stay-awake setting was restored to its original value 0.

## FIRMWARE / DRIVER CHANGE

User installed the update and reconnected probes before resuming.
Old: Android 14, mdt865_14_ngms_2.8.6, kernel 4.14.186, built-in expand driver.
New display ID: mdt865_16_ngms_1.2.7 release-keys
New fingerprint:

```text
Topicon/mdt750_gms_lite/mdt750:16/mdt865_16_ngms_1.2.7/14ea5a25530:user/dev-keys
```

New kernel: 6.6.102-android15-8-4k #1 SMP PREEMPT, aarch64.
Its build timestamp reports 1970-01-01; do not interpret that as a release date.

The expand platform driver is now provided by the loaded module expand_module:

```text
/sys/bus/platform/drivers/expand/module -> /sys/module/expand_module
/vendor/lib/modules -> /vendor_dlkm/lib/modules
/vendor_dlkm/lib/modules/expand_module.ko is listed but unreadable.
```

Read-only adb pull and run-as cat attempts both returned Permission denied.
No kernel module binary was obtained. The run-as result file is error text,
not an ELF file. /proc/kallsyms, kernel/module BTF and DT property values remain
unreadable. The exported running kernel config is the GKI config and does not
list vendor CONFIG_EXPAND; that is not evidence the loaded driver is absent.
The old built-in-driver conclusions apply to the old firmware only.

/dev/expand is still 0666 root:system, gpio_ctrl_device, now character 10:107
(formerly 10:106). WK1-3 remain 0666 user_tty_device; WK0 is 0660 root:system
and now also user_tty_device (previously ttyMT_device). Ordinary-app open/access
checks have not yet been rerun. Installed system_ext policy lines 1165-1166 still
grant appdomain chr_file open/read/write/ioctl access to user_tty_device and
gpio_ctrl_device. This is policy evidence, not execution proof for our app.

## PIN LABELS / CONNECTED-PROBE BASELINE

Viewed from tablet backside, local investigation labels:

| Left | Right | Probe mapping |
| --- | --- | --- |
| 1 | 2 | CH3 → pin 2 |
| 3 | 4 | CH2 → pin 3; CH1 → pin 4 |
| 5 | 6 | CH4 → pin 5 |
| 7 | 8 |  |
| 9 | 10 |  |
| 11 | 12 |  |

User reports pin 1 as probe ground, cross-checked against known cradle power/
ground pads; pin 7 remains about +3.3 V. User later reports pin 8 also looks like
ground. Pin 8 is a candidate, not independently verified. Pins 7 and 8 are not
scope channels in this setup. Constant pin-7 voltage alone cannot establish
whether another rail, enable, GPIO direction or bus routing is switched.

Rigol DS1074Z, 192.168.220.72:5555, firmware 00.04.05.SP2.
Initial connected baseline (sequential live SCPI queries):

```text
pin 2 / CH3: mean -0.020 V, approximately ground level
pin 3 / CH2: mean -0.023 V, approximately ground level
pin 4 / CH1: mean +1.798 V
pin 5 / CH4: mean +1.530 V
```

All scope inputs DC-coupled, configured x10, 1 V/div, no inversion/BW limit;
5 ms/div and acquisition running. Physical probe multiplier switches have not
been independently checked. The scope screen showed no obvious full-amplitude
logic transitions during that baseline. Frequency readouts were unavailable
(9.9E37), not measured frequencies. Baseline values do not identify pin roles.

## MANAGE APP AND SWITCH IMPLEMENTATION

Manage = com.thorkracing.wireddevices, version 3.28 (137).
Its LoRa button opens com.thorkracing.dmdLora.StatusActivity (LoRa Settings).
The enable switch writes dmdlora_prefs/lora_enabled, then starts LoraService
with action com.thorkracing.dmdlora.START, or starts it with STOP when disabled.
This is service control, not a separate power-only API. Opening StatusActivity
can itself initialize LoRa when that saved preference is enabled.
Current DMD LoRa version 1.0.14 (14) has the same SHA256 as the earlier analyzed
APK: 616a2c0be5960a9b7925dbd1eadd0006b3e26c37af8250cc7b6bdc5907d2c1cf
Manage also matches the earlier APK hash:

```text
3252a1cb505184e49c92bdae5e17d51f9b097c9286cfc113e9e4a28e5072a45e
```

Thus the Android/kernel upgrade changed the driver environment while these
examined application binaries remained identical to the earlier copies.
Sources: Manage Main.java launch callback; DMD StatusActivity.java and t1/j.java.

## AUTHORIZED FIRST ENABLE ATTEMPT / RESTORATION

User explicitly approved a single controlled off/on cycle and restoration.
Actual original switch state, read from UIAutomator: OFF. We enabled once,
observed initialization, then restored OFF and verified the switch readback.
No raw GPIO ioctl, UART write, EEPROM operation or custom probe was executed
by our tools; the supported DMD app performed its normal initialization.

Host event timestamps (UTC; see cycle-events.json for exact timings):

```text
09:21:28.463  begin ADB tap to enable LoRa
09:21:28.575  ADB tap returned
09:21:32.345  UI readback enabled=true
09:22:00.633  begin ADB tap restoring OFF
09:22:03.426  UI readback enabled=false
```

The logcat stream records application calls plus expansion-driver debug messages:

```text
09:21:29.007  open /dev/expand, fd 134
09:21:29.018  expand_fops_ioctl cmd 3223081729 (0xC01C5301), position 2
09:21:29.027  native setPower(true) returned 0; writeIo(1,true) returned 0
09:21:29.031  expand_power_on, iface(right)->user: 1
09:21:29.031  ioctl 3223081730 (0xC01C5302), position 2
09:21:29.031  expandio_set_gpio_value: iface(right), io=1, state=1
09:21:29.031  expandio: gpio(566) set to 1 SUCCESS
09:21:29.133  open /dev/ttysWK2, 9600 baud, flags 0, 8N1
09:21:29.196  setMode SleepConfig, currentPosition right
09:21:29.700  failed to enter config mode (module attached?)
09:21:29.732  native setPower(false) returned 0
09:21:29.736  expandio_release_gpio: iface(right) release gpio
09:21:29.736  expand_power_off, iface(right)->user: 0
```

These observations confirm that the driver accepts the power and GPIO requests
on the new firmware and reveal logical I/O 1 -> kernel GPIO 566. GPIO 566 is not
a physical connector number, and its current-chip offset/voltage are unknown.
The user field going 1 -> 0 is consistent with reference counting, but the
handler implementation is still unavailable and this is an interpretation.
Request success does not establish an electrical voltage change on a given pad.
No UART response or connected radio was established; this failure is expected
to be possible without the Thork module. The app ran its power-off path itself
roughly 0.7 seconds after requesting power on, before our later switch restore.

## FIRST-CYCLE SCOPE LIMITATION / CAPTURE VALIDATION

The scope was configured for a 12-second capture, but FORCE was sent before its
pretrigger buffer was ready. It stayed in WAIT throughout the authorized attempt.
Therefore no waveform of that attempt was captured. Do not infer pin transitions
from the later off-state data. The scope's error query reported no error, so the
new helper explicitly waits for WAIT and confirms TD after FORCE before allowing
an ADB enable tap. That corrected arming sequence was tested without operating
the tablet switch; successful trigger acceptance and restoration were recorded.
A separate steady-OFF capture retrieved 3,000,000 BYTE samples per channel with
4 us spacing, spanning -1.2 to +10.8 seconds relative to its later force trigger.
The block reader checks headers, lengths, incomplete payloads and saved counts;
its local self-checks passed. Acquisition/channel settings are restored afterward.
An additional tablet cycle required separate approval because the first user
authorization explicitly limited us to one cycle. That approval was received,
and the second capture below was performed. Scope validation alone did not
operate the tablet switch.

## SECOND EXPLICITLY AUTHORIZED CYCLE: CONNECTED TRANSITION CAPTURE

The corrected arming sequence confirmed TD before sending the enable tap.

```text
09:29:29.110 UTC  scope trigger accepted / confirmed
09:29:29.113 UTC  begin ADB enable tap
09:29:32.585 UTC  UI readback enabled=true
09:29:40.138 UTC  scope readback STOP, frozen capture complete
09:29:42.820 UTC  begin ADB restore-OFF tap
09:29:45.657 UTC  UI readback enabled=false
```

The driver again logged successful power enable and I/O 1 -> GPIO 566 high,
WK2 open at 9600/8N1, configuration-mode failure, then GPIO release/power off.
The driver's power-on and power-off log timestamps differ by 708 ms, matching
the approximately 708 ms scope pulse. Host, device and instrument clocks are
not assumed synchronized; this comparison uses durations, not absolute times.

Frozen raw data: 3,000,000 8-bit samples on each of CH1-4, 4 us interval
(250 kSa/s), covering -1.2 to +10.799996 seconds relative to scope trigger.
Using each channel's returned preamble, conversion is:

```text
volts = (raw_byte - yorigin - yreference) * yincrement
time = (sample_index - xreference) * xincrement + xorigin
```

| Pad | Channel | Raw-capture finding |
| --- | --- | --- |
| 2 | CH3 | 0 V, no logic-level transitions in this capture |
| 3 | CH2 | low -> median 3.34 V -> low, width 708.136 ms |
| 4 | CH1 | approximately 1.87 V median; range 1.77-1.97 V |
| 5 | CH4 | approximately 1.54 V median; range 1.44-1.63 V |

The earlier live measurement averages and raw-capture conversion are different
readout paths/times; do not interpret their small differences as a state change.
All reported levels depend on the scope's configured x10 probe factor.
For pin 3, crossings at 1.65 V identify the first high sample at +0.444500 s
and first low sample at +1.152636 s. Exactly two crossings were found; thresholds
1.0, 2.0 and 2.5 V independently give the same width within 0.1 ms. No additional
logic-scale transitions (>0.6 V total excursion) were found on CH1/CH3/CH4.
The pulse is not a 9600-baud UART frame. UART pads may be among unprobed contacts,
or require other conditions; this capture does not establish either explanation.

## SUPPLY / PIN-7 CONTEXT

Read-only metadata also revealed separate fixed-regulator platform devices:

```text
odm:fixed_vdd_33v -> reg-fixed-voltage driver
odm:fixed_wk_33v@0 -> reg-fixed-voltage driver
```

The second node has regulator-always-on and regulator-boot-on property names.
Its name suggests a WK-related rail; physical association with pin 7 is NOT
established, and property values remain unreadable. This is an always-on-rail
lead, not proof that pin 7 is that rail or that the expansion bay has no switch.

## OPERATING STATE / OPEN ITEMS

Android reported this cable as AC powered, not USB powered. A temporary stay-awake
setting was needed to prevent PIN relocking during authorized ADB UI operation.
Its original stay_on_while_plugged_in value is 0; it was restored and reread as 0.
The user entered their own PIN; no PIN was provided to or retained by the assistant.
At the end of the first attempt the LoRa switch is OFF and no LoraService is listed.
The same OFF/no-service state was restored and verified after the second attempt.
Scope readback confirms 5 ms/div, zero time offset, AUTO trigger/running, waveform
source CH1, NORM/BYTE, start 1/stop 1200. Channel gains/coupling were never changed.
Pin 4 is not yet proven UART TX; pin 5 is not yet proven an enable or other signal.
Pin 7 being constant does not prove that the port has no separately controlled
power/enable. Neither pad assignments nor logic-voltage compatibility are settled.

## EVIDENCE

post-update-2026-11-07/ contains the new firmware/kernel metadata, module listing,
policy excerpt, connected baseline queries/PNG, cycle timestamps, UI switch state
and focused logcat evidence. Earlier documents must be read with this update.
successful-cycle/ contains the valid second capture, preambles, raw bytes,
command transcripts, scope PNG, event/readback evidence and waveform analysis.
off-state-trigger-validation/ is a separate steady-OFF capture; it must never
be substituted for the successful transition capture.
