# Compatibility record

Updated 2026-11-16. This record separates implemented software, synthetic checks,
USB client interoperability and the subsequently tested negative E220 RF result.

## Reference profile and actual peer

| Item | Version / evidence |
| --- | --- |
| Algorithm/header/legacy channel-crypto reference | Meshtastic firmware `6d41e279f1f51bd59f687b9d441c1bf47b1594fc`, version 2.7.27 |
| Archived protobuf source | `cf0a84ede1e7a0b7479e90a5e496d30c5dfba707` under `rust/proto/` |
| Actual USB peer | `!f9b31230`, `rambo-ttgo-1`, hardware enum 3, official firmware `2.7.26.54e0d8d` |
| Actual peer baseline | EU868, LongFast, SF11, BW250 kHz, CR4/5, channel slot 0, no frequency override |
| Tablet carrier | Attached E220-900T30S, firmware `7463-0-17`, read directly in the 2026-11-16 bench test |
| Compiler/build | Rust 1.98.1; AGP 8.13.2, Kotlin 2.2.21, Gradle 8.13, NDK 27.2.12479018, SDK 36, JDK 17 |

The actual peer is older than the algorithm reference. Its stable client API
was tested directly. That does not qualify our raw RF routing behavior against
either firmware version. The live documentation's later AEAD/ACK-proof changes
are outside this implementation.

## Implemented and tested

- Legacy 16-byte RF header and pinned generated Data protobuf, 255-byte RF bound.
- Channel PSK aliases, name/key XOR hash, no encryption / AES-128 CTR / AES-256 CTR.
  Independent AES-128 known-answer fixture; round-trip tests are additional evidence.
- Bounded CLIENT-role bench forwarding with delayed relays, hop exhaustion,
  deduplicated application delivery, duplicate cancellation, higher-hop replacement,
  channel destination ACKs, retries and basic directed-route learning/fallback.
- Separate official serial client framing, config nonce matching, text, peer
  inventory and routing/queue reporting.
- Android service/JNI packaging and live official USB API handshake; local
  self-addressed message accepted and acknowledged by official firmware.
- UART byte-stream capture; exact recovered expansion ioctl packing. Power/GPIO
  controls are opt-in and are not electrically qualified by synthetic tests.

## Deliberate limits

| Area | Current limit |
| --- | --- |
| Native over-air routing | Bench implementation only; no differential qualification against the full firmware router |
| Roles | CLIENT baseline only; favorite-node and ROUTER/ROUTER_LATE/CLIENT_BASE rules not implemented |
| Scheduling | Injected test delays/retry interval, not measured airtime/SNR/CAD scheduling |
| Reliability | Legacy channel ACK baseline; no claim of cryptographic delivery proof; broadcast origin retry and reliable-text-ACK exceptions not fully ported |
| Next hop | Basic relayer intersection and final fallback; no complete collision/stale-neighbor policy qualification |
| Private messages | Raw endpoint PKI X25519/AES-CCM is not implemented. USB mode delegates that decision to official firmware |
| Modern crypto | No 2.8.1 AEAD, signatures, or ACK proofs |
| Identity persistence | Raw test caller supplies IDs; native RF remains disabled until durable identity/nonce allocation exists |
| Radio driver | Capture, power ABI and read-register codec; no automatic configuration-mode commands or permanent register writes |
| M0/M1 | Tablet logical control mapping/polarity not verified; no GPIO sweep |
| Process death | Normal stop closes/restores; force-stop/crash cannot guarantee hardware restoration |

## E220 RF gate

**Native RF transmission remains disabled. No user override is provided.**

1. No verified way to expose complete raw LoRa frames through the vendor UART
   interface, select the Meshtastic sync word, or recover RX packet boundaries.
2. E220 documented payload ceiling is 200 bytes; Meshtastic RF permits 255 bytes.
3. UART drained does not mean RF TX complete. AUX/CAD/SNR are not available here.
4. The current peer's LongFast SF11/BW250 is outside the LLCC68 envelope.
5. Changing the peer to ShortFast removes only the SF/BW mismatch; exact center
   frequency, coding rate, sync word, headers, CRC, preamble and vendor framing
   still need independent verification. A preset change cannot solve opaque framing.

The LLCC68 chip envelope fits ShortTurbo, ShortFast, ShortSlow, MediumFast,
MediumSlow and LongTurbo. This is **not a list of qualified UART-module presets**.
The chip excludes LongFast, LongModerate and LongSlow. Region-specific preset
availability is another independent constraint.

### Attached-radio follow-up

The [actual E220 bench test](../docs/reports/E220-MESHTASTIC-FEASIBILITY-2026-11-16.md)
now establishes direct rootless power/enable, UART, software-mode acknowledgements
and firmware `7463-0-17`. Normal app-domain power/open access also passed.
The module rejected the tested SF/BW/CR/sync/frequency query forms. Two full
RF sweeps, including a temporary zero vendor key, plus a focused RSSI test
produced **0 E220 deliveries / 86 submissions**; a second official node decoded
79 exact packets. The E220 detected RF energy (−74 to −28 dBm) without delivering
the confirmed long packet. Its actual sync word/rejection stage remains unknown.

The peers were temporarily reconfigured for this follow-up and their complete
original LoRa protobufs restored/read back after every phase. E220 C2 changes
were temporary and discarded by power off; no saved-register write was made.

## Current hardware decision

The supplied UART firmware has not demonstrated a usable native Meshtastic
path. Prefer a supported MCU + SX1262 running official Meshtastic and exposing
the PROTO client API on UART. The existing client codec can then use WK2
directly. A stock E22-T UART substitution would still need a raw-interface
qualification; its SX1262 chip alone does not solve the controller boundary.

Further native routing work for this E220 backend should await new firmware
or raw-radio evidence. The Rust core remains a bench implementation with the
PKI, persistence, timing and policy limits listed above.

Sources: [implementation plan](../docs/plans/MESHTASTIC-RUST-PLAN.md),
[radio driver plan](../docs/plans/EBYTE-RADIO-DRIVER.md),
[Semtech LLCC68](https://www.semtech.com/products/wireless-rf/lora-connect/llcc68),
[pinned firmware](https://github.com/meshtastic/firmware/tree/6d41e279f1f51bd59f687b9d441c1bf47b1594fc),
[pinned schema](https://github.com/meshtastic/protobufs/tree/cf0a84ede1e7a0b7479e90a5e496d30c5dfba707).
