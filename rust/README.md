# T865 Rust mesh bench implementation

The same library builds as a desktop Rust crate and an Android JNI library.
[Compatibility and limitations](COMPATIBILITY.md) define what is implemented;
this is not a production Meshtastic routing implementation.

| Module | Responsibility |
| --- | --- |
| `wire.rs` | Bounded 16-byte legacy RF header, generated Data protobuf, channel hash, PSK alias expansion, AES-128/256 CTR, independent serial-client framing |
| `mesh.rs` | Deterministic CLIENT-role bench router: delayed relay, duplicate cancellation, hop limits, destination channel ACKs, bounded retries, basic next-hop learning/fallback |
| `radio.rs` | E220/E22 register read codecs, native capability gate, UART capture, recovered expansion power ABI; no routing or channel keys |
| `client.rs` | Official ToRadio/FromRadio client protocol and redacted configuration summaries |
| `lib.rs` | Host command boundary and JNI panic/error containment; one mutex-protected host |

The core has no Android, UART or wall-clock dependency. The caller injects
monotonic milliseconds and relay delays. It accepts only complete RF frames.
The host must reserve fresh source/packet IDs before originating or ACKing;
raw native RF transmit is not enabled, so production identity/nonce persistence
is deliberately not exposed as a working feature.

The Android host supplies the foreground service and native session ownership;
see [the app](../android/T865Mesh/README.md).

## Desktop checks

From the repository root:

```sh
cargo test --locked --manifest-path rust/Cargo.toml
cargo clippy --locked --manifest-path rust/Cargo.toml --all-targets -- -D warnings
cargo fmt --manifest-path rust/Cargo.toml --check
```

An independent vector was generated with the official Python `Data` schema and
Python cryptography's AES-CTR. It is checked byte-for-byte, not merely by
round-tripping our own encoder. Further tests cover line/diamond relaying,
zero hops, repeated ACK requests, retry exhaustion, route fallback, mismatched
ACK sources, table bounds, unknown ports, stream corruption and fragmented
vendor replies. Tests open no hardware and send no RF traffic.

## JSON-line bench runner

```sh
cargo run --locked --manifest-path rust/Cargo.toml <<'JSON'
{"op":"selftest"}
{"op":"capabilities"}
{"op":"raw_decode","name":"LongFast","key_hex":"01","hex":"ffffffff785634122a000000630800789db4f0fc307cd0bf81698bfad51b"}
JSON
```

Each input line yields one JSON object with `ok` and either results or `error`.
`raw_encode` makes a complete legacy channel text frame but never sends it.
For deterministic routing experiments use `mesh_start` (`node`, `name`,
`key_hex`, optional `retry_ms`), `mesh_send` (`hex`, `now_ms`), `mesh_rx`
(`hex`, `now_ms`, `delay_ms`, fresh `ack_id`), and `mesh_tick` (`now_ms`).
Events distinguish delivery, transmit intentions and routing status. Transmit
intentions are not wired to the E220. A simulator can deliver the returned
`frame_hex` to another instance; its transport must supply actual packet boundaries.

`api_start`, `api_feed`, `api_text`, and `api_heartbeat` implement the official
client protocol; they do not put our routing core in control of the external
node's RF stack. `native_tx` always returns a capability error for the current
unqualified backend.

`uart_open/read/close` and `power_on/off` operate real fixed device paths when
called on the tablet. They are not part of the offline checks. Do not issue
them casually from a runner connected to actual hardware.

## Sources and licensing

The generated protobuf source is compiled from the archived schema at
`cf0a84ede1e7a0b7479e90a5e496d30c5dfba707`; [proto/LICENSE](proto/LICENSE)
is retained. The reference algorithms are from GPLv3 Meshtastic firmware
`6d41e279f1f51bd59f687b9d441c1bf47b1594fc`. New Rust and Android mesh-bench code
is GPL-3.0-only; [LICENSE](LICENSE) contains the license. Rust dependencies
retain their own licenses, recorded in Cargo.lock/package metadata. No DMD
binary/library or proprietary SDK is bundled in this app.
