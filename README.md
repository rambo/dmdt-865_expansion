# ESP32 UART probe

ESP32-PICO-D4 / ESP32 PICO Kit, Arduino board `esp32:esp32:pico32`.

- **GPIO26 TX, GPIO25 RX**, UART1, **9600/8N1**, normal push-pull output.
- USB console on `/dev/tty.usbserial-21230`, **115200 baud**.
- Sends `UUUU RX-PROBE 00000001` + CR/LF once per second, increasing the counter.
- USB command `s` pauses transmission with TX idle and RX active; `r` resumes.
- RX bytes are printed to USB as hex and escaped ASCII. They are never echoed to TX.
- Starts sending automatically after boot. No Wi-Fi, Bluetooth, or libraries beyond the ESP32 Arduino core.

Open `ESP32UartProbe.ino` in Arduino IDE. Choose **ESP32 PICO-D4** and the connected port. The checked build uses Espressif Arduino core **3.3.12**.

```sh
arduino-cli compile --fqbn esp32:esp32:pico32 --output-dir build .
arduino-cli upload --fqbn esp32:esp32:pico32 --board-options UploadSpeed=115200 --port /dev/tty.usbserial-21230 --input-dir build .
arduino-cli monitor --port /dev/tty.usbserial-21230 --config baudrate=115200
```

On macOS `/dev/cu.usbserial-21230` is the callout alias of the same USB interface; it may be preferable for a monitor. Close the monitor before uploading.

For the tablet RX search, connect GPIO26 through the proposed **3.3 kΩ / 10 kΩ divider plus 4.7 kΩ probe resistor** to candidate tablet pin 11. Connect ESP32 GND to tablet pin 1. Keep GPIO25 disconnected for the initial one-way test. See `../T865UartTx/RX-PROBE-WIRING.txt` for the full circuit and voltage checks. GPIO numbers here are ESP32 GPIOs, not tablet pad numbers.

GPIO25/26 avoid the GPIO12 flash-voltage strap from the earlier proposed mapping. The sketch does not alter GPIO12/13/15 or any eFuse. The completed bench test received five exact tablet frames on GPIO25; guaranteed voltage margins for permanent wiring remain unverified.

Sources: [ESP32 Arduino Serial API](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/serial.html), [PICO-KIT pin descriptions](https://docs.espressif.com/projects/esp-idf/en/v3.2.5/get-started/get-started-pico-kit.html#pin-descriptions).

This directory is a separate local Git repository. Build output is ignored; actual validation logs are retained under `validation/`.

## Verified wiring

- ESP32 GPIO26 TX -> user probe connection -> tablet **pin 11 / WK2 RX**.
- Tablet **pin 12 / WK2 TX** -> ESP32 GPIO25 RX.
- Common ground: tablet pin 1.

Both directions were checked with exact payloads at 9600/8N1. The ESP32 is left sending; the tablet is left receive-only. See [VALIDATION.md](VALIDATION.md).

Repeat the on-board checks only with the appropriate wiring connected:

```sh
python3 validate_serial.py
python3 validate_return_path.py
```

The first uses USB `s`/`r`; the second briefly enables tablet TX and restores it to idle. Both use Python's standard library and the macOS callout alias. No extra Python packages are required.
