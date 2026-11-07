#include <Arduino.h>

constexpr int TX_PIN = 26;
constexpr int RX_PIN = 25;
constexpr uint32_t UART_BAUD = 9600;
constexpr uint32_t PERIOD_MS = 1000;

bool sending = true;
uint32_t sequence = 0;
uint32_t lastSend = 0;

void setup() {
  Serial.begin(115200);                         // USB bridge / UART0 console.
  Serial1.begin(UART_BAUD, SERIAL_8N1, RX_PIN, TX_PIN);
  Serial.println("READY: UART1 TX=GPIO26 RX=GPIO25 9600/8N1; USB=115200");
  Serial.println("Commands: s = stop sending (TX idle); r = resume sending");
  lastSend = millis();
}

void loop() {
  while (Serial.available()) {
    const int command = Serial.read();
    if (command == 's') {
      sending = false;
      Serial.println("PAUSED: TX idle; RX remains active");
    } else if (command == 'r') {
      sending = true;
      lastSend = millis();
      Serial.println("RESUMED: one frame per second");
    }
  }

  const uint32_t now = millis();
  if (sending && uint32_t(now - lastSend) >= PERIOD_MS) {
    lastSend = now;
    char frame[48];
    const int length = snprintf(frame, sizeof(frame), "UUUU RX-PROBE %08lu\r\n",
                                static_cast<unsigned long>(++sequence));
    if (length <= 0 || size_t(length) >= sizeof(frame)) {
      sending = false;
      Serial.println("ERROR: frame formatting failed; TX paused");
    } else {
      const size_t written = Serial1.write(reinterpret_cast<const uint8_t *>(frame), length);
      Serial.printf("TX %u/%d bytes: %s", unsigned(written), length, frame);
      if (written != size_t(length)) {
        sending = false;
        Serial.println("ERROR: incomplete write; TX paused");
      }
    }
  }

  uint8_t received[32];
  size_t count = 0;
  while (Serial1.available() && count < sizeof(received)) {
    const int value = Serial1.read();
    if (value < 0) break;
    received[count++] = uint8_t(value);
  }
  if (count) {
    Serial.printf("RX %u bytes hex=[", unsigned(count));
    for (size_t i = 0; i < count; ++i) Serial.printf("%s%02X", i ? " " : "", received[i]);
    Serial.print("] ascii=[");
    for (size_t i = 0; i < count; ++i) {
      const uint8_t value = received[i];
      if (value >= 32 && value <= 126 && value != '\\') Serial.write(value);
      else Serial.printf("\\x%02X", value);
    }
    Serial.println("]");
  }
  delay(1);
}
