# Actual validation — 2026-11-07

- Arduino CLI 1.5.1, Espressif Arduino core 3.3.12, FQBN `esp32:esp32:pico32`. `--warnings all` build PASS with no warnings. Program 269,964 bytes; global variables 22,124 bytes.
- Uploaded through `/dev/tty.usbserial-21230` at 115200 upload baud. esptool identified ESP32-PICO-D4 revision v1.0, verified written hashes, and reset into the sketch. Full-flash erase disabled.
- `python3 validate_serial.py` PASS on the real board's `/dev/cu.usbserial-21230` alias. Sequential 24-byte frames at approximately 1 Hz, USB `s` suppresses frames, `r` resumes. It leaves transmission running. Evidence: validation/serial-smoke.log and smoke-result.txt.
- Android received every numbered frame checked by the USB smoke test through WK2 RX. User confirms ESP32 GPIO26 is connected to tablet pad 11. Therefore pad 11 is electrically confirmed WK2 RX.
- User then connected ESP32 GPIO25 to tablet pad 12. `python3 validate_return_path.py` sent a brief tablet transmission and reassembled FIVE exact `UUUU T865 UART WK2\r\n` frames (100 bytes) from ESP32 UART1 RX, validating the return path. Its finally block restored tablet TX idle.
- `validation/end-to-end.json` records pin mapping and comparison results. Tablet RX remains active; ESP32 TX continues the numbered probe string at about 1 Hz. The tablet transmitter is idle.

This is a working two-way bench link at 9600/8N1. The exact fitted resistor values and loaded signal levels were not captured by this validation. Successful reception does not establish guaranteed voltage margins over supply, temperature or noise. Tablet cold-boot expansion enable behavior and E220/Meshtastic interoperability remain untested.

The validation scripts access real devices. `validate_serial.py` sends USB pause/resume commands; `validate_return_path.py` briefly starts the tablet transmitter, then restores receive-only idle. They are not hardware-free unit tests.
