# T865 WK2 two-way UART confirmed with ESP32-PICO-D4 — 2026-11-07

## CONFIRMED BACKSIDE CONNECTOR ASSIGNMENTS

Pin 1: ground reference / common ground used for the bench link.
Pin 11: tablet /dev/ttysWK2 RX (connects to ESP32 GPIO26 TX).
Pin 12: tablet /dev/ttysWK2 TX (connects to ESP32 GPIO25 RX).
Numbering remains the user's backside rowwise (1,2)..(11,12), not OEM numbering.

## EVIDENCE

ESP32UartProbe.ino compiled cleanly for ESP32 PICO-D4, core 3.3.12. It was
uploaded to /dev/tty.usbserial-21230; esptool identified ESP32-PICO-D4 rev v1.0
and verified written hashes. Final MCU mapping: TX GPIO26, RX GPIO25, UART1,
9600/8N1. Earlier proposed GPIO mappings were superseded before any upload.

ESP32 sends UUUU RX-PROBE &lt;8-digit counter&gt; plus CR/LF (24 bytes for current
counters) every ~1 second. Android T865UartTx v1.2 receives exact bytes through
WK2. Counters observed at the MCU USB console during the automated smoke check
all appear in Android RX logs. User confirms GPIO26 connects to tablet pad 11.
USB commands s/r were checked: pause stops frames, resume restarts them.

After the user connected GPIO25 to tablet pad 12, one brief tablet transmission
was performed. The MCU logged five exact UUUU T865 UART WK2&lt;CR&gt;&lt;LF&gt; frames
(100 received bytes). This checks the opposite physical direction as well.
The tablet transmitter was restored to receive-only idle in the test's finally
block, and no subsequent tablet TX frame appears after its last IDLE log.

## CURRENT STATE

ESP32 GPIO26 TX continues the numbered pattern once per second.
Tablet TX/pin 12 is idle; WK2 remains open with RX monitoring active.
DMD LoRa remains off. No new expansion power/GPIO ioctl or LoRa enable cycle
was used for this end-to-end test. Earlier DMD cycles preceded these experiments;
cold-boot behavior without those prior cycles remains untested.

## FILES

Separate Git project ESP32UartProbe/ contains the Arduino sketch, instructions,
runnable on-board checks and validation logs/JSON. Source ZIP includes Git.
T865UartTx/ provides the tablet RX logger and TX test app.

## LIMITS

The user wiring is confirmed at both endpoints; exact fitted resistor values
and loaded voltage margins were not captured by these tests. The earlier idle
meter levels (~2.5 V TX and 2.49 V RX) are observations, not universal connector
voltage ratings. This is a working bench link at 9600/8N1, not an established
power pinout, interface specification, radio test or Meshtastic integration.
