#[allow(
    clippy::large_enum_variant,
    clippy::doc_overindented_list_items,
    clippy::doc_lazy_continuation
)]
pub mod proto {
    include!(concat!(env!("OUT_DIR"), "/meshtastic.rs"));
}
pub mod client;
pub mod mesh;
pub mod radio;
pub mod wire;
use prost::Message;
use serde_json::{json, Value};
use wire::{hex, unhex, Channel, Frame};

#[derive(Default)]
pub struct Host {
    client: client::Client,
    uart: Option<radio::Uart>,
    expansion: Option<radio::Expansion>,
    mesh: Option<mesh::Mesh>,
}
fn num(v: &Value, k: &str) -> Result<u32, String> {
    v[k].as_u64()
        .filter(|n| *n <= u32::MAX as u64)
        .map(|n| n as u32)
        .ok_or_else(|| format!("missing/invalid {k}"))
}
fn strval<'a>(v: &'a Value, k: &str) -> Result<&'a str, String> {
    v[k].as_str().ok_or_else(|| format!("missing {k}"))
}
fn channel(v: &Value) -> Result<Channel, String> {
    Channel::new(strval(v, "name")?, &unhex(strval(v, "key_hex")?)?)
}
impl Host {
    pub fn command(&mut self, input: &str) -> Value {
        let result = if input.len() > 32768 {
            Err("command too large".into())
        } else {
            serde_json::from_str(input)
                .map_err(|e| e.to_string())
                .and_then(|v| self.dispatch(&v))
        };
        match result {
            Ok(mut value) => {
                value["ok"] = json!(true);
                value
            }
            Err(error) => json!({"ok": false, "error": error}),
        }
    }

    fn dispatch(&mut self, v: &Value) -> Result<Value, String> {
        match strval(v, "op")? {
            "capabilities" => Ok(radio::capabilities()),
            "api_start" => Ok(client::bytes(self.client.start(num(v, "nonce")?)?)),
            "api_feed" => Ok(json!({"events": self.client.feed(&unhex(strval(v, "hex")?)?)})),
            "api_text" => Ok(client::bytes(self.client.text(
                num(v, "to")?, num(v, "channel")?, num(v, "hops")?, strval(v, "text")?
            )?)),
            "api_heartbeat" => Ok(client::bytes(self.client.heartbeat()?)),
            "api_disconnect" => Ok(client::bytes(self.client.disconnect()?)),
            "power_on" => {
                if self.expansion.is_some() { return Err("expansion already owned".into()); }
                self.expansion = Some(radio::Expansion::power_on()?);
                Ok(json!({"position": 2, "io": 1, "state": "owned_power_on", "mode_controls": "unverified"}))
            }
            "power_off" => {
                if let Some(mut e) = self.expansion.take() { e.power_off()?; }
                Ok(json!({"state": "power_off"}))
            }
            "uart_open" => {
                if self.uart.is_some() { return Err("UART already open".into()); }
                self.uart = Some(radio::Uart::open(num(v, "baud")?)?);
                Ok(json!({"state": "uart_capture", "writes": false}))
            }
            "uart_read" => {
                let bytes = self.uart.as_ref().ok_or("UART closed")?.read()?;
                Ok(json!({"stream_hex": hex(&bytes)}))
            }
            "uart_close" => {
                if let Some(u) = self.uart.take() { u.close()?; }
                Ok(json!({"state": "stopped"}))
            }
            "native_tx" => Err("E220 native RF TX blocked: opaque air framing, unverified sync word and RX boundaries".into()),
            "raw_decode" => {
                let f = Frame::decode(&unhex(strval(v, "hex")?)?)?;
                let d = f.data(&channel(v)?)?;
                let text = if d.portnum == 1 { String::from_utf8(d.payload.clone()).ok() } else { None };
                Ok(json!({"from": f.from, "to": f.to, "id": f.id, "hops": f.hops,
                    "channel_hash": f.channel, "port": d.portnum, "payload_hex": hex(&d.payload), "text": text}))
            }
            "raw_encode" => {
                let data = proto::Data { portnum: 1, payload: strval(v, "text")?.as_bytes().into(), ..Default::default() };
                let f = channel(v)?.packet(num(v,"from")?, num(v,"to")?, num(v,"id")?,
                    u8::try_from(num(v,"hops")?).map_err(|_| "invalid hops")?,
                    v["want_ack"].as_bool().unwrap_or(false), data)?;
                Ok(json!({"frame_hex": hex(&f.encode()?), "rf_sent": false}))
            }
            "mesh_start" => {
                self.mesh = Some(mesh::Mesh::new(num(v,"node")?, channel(v)?, v["retry_ms"].as_u64().unwrap_or(5000))?);
                Ok(json!({"state": "bench_mesh", "rf_enabled": false}))
            }
            "mesh_send" => {
                let f = Frame::decode(&unhex(strval(v,"hex")?)?)?;
                let events = self.mesh.as_mut().ok_or("mesh stopped")?.originate(f, time(v)?)?;
                Ok(json!({"events": events}))
            }
            "mesh_rx" => {
                let f = Frame::decode(&unhex(strval(v,"hex")?)?)?;
                let events = self.mesh.as_mut().ok_or("mesh stopped")?.receive(f, time(v)?,
                    v["delay_ms"].as_u64().unwrap_or(100), num(v,"ack_id")?)?;
                Ok(json!({"events": events}))
            }
            "mesh_tick" => {
                let events = self.mesh.as_mut().ok_or("mesh stopped")?.tick(time(v)?)?;
                Ok(json!({"events": events}))
            }
            "selftest" => selftest(),
            _ => Err("unknown operation".into()),
        }
    }
}
fn time(v: &Value) -> Result<u64, String> {
    v["now_ms"].as_u64().ok_or_else(|| "missing now_ms".into())
}
/// Runs on desktop and in the exact shared library loaded by Android.
pub fn selftest() -> Result<Value, String> {
    let c = Channel::new("LongFast", &[1])?;
    let data = proto::Data {
        portnum: 1,
        payload: b"T865 bench".to_vec(),
        ..Default::default()
    };
    let f = c.packet(0x12345678, u32::MAX, 42, 3, false, data.clone())?;
    let bytes = f.encode()?;
    if hex(&f.payload) != "9db4f0fc307cd0bf81698bfad51b" {
        return Err("independent AES-CTR vector failed".into());
    }
    if Frame::decode(&bytes)?.data(&c)? != data {
        return Err("wire/crypto self-test failed".into());
    }
    let mut relay = mesh::Mesh::new(0x87654321, c, 5000)?;
    let delivered = relay.receive(f.clone(), 0, 100, 99)?;
    if delivered.len() != 1 || !relay.tick(99)?.is_empty() || relay.tick(100)?.len() != 1 {
        return Err("relay deadline self-test failed".into());
    }
    if !relay.receive(f, 101, 100, 100)?.is_empty() {
        return Err("dedup self-test failed".into());
    }
    let mut framer = wire::ApiFramer::default();
    let msg = wire::api_frame(&data.encode_to_vec())?;
    let mut count = 0;
    for b in msg {
        count += framer.feed(&[b]).len();
    }
    if count != 1 {
        return Err("stream framing self-test failed".into());
    }
    Ok(
        json!({"checks":["RF header","AES-CTR known-answer vector","delayed relay","deduplication","split API frames"],"synthetic_frame_hex":hex(&bytes),"rf_sent":false}),
    )
}

#[cfg(target_os = "android")]
mod android_jni {
    use super::*;
    use jni::{
        objects::{JClass, JString},
        sys::jstring,
        JNIEnv,
    };
    use std::sync::{Mutex, OnceLock};
    static HOST: OnceLock<Mutex<Host>> = OnceLock::new();
    #[no_mangle]
    pub extern "system" fn Java_dev_t865_mesh_Native_command(
        mut env: JNIEnv,
        _class: JClass,
        input: JString,
    ) -> jstring {
        let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
            let text: String = env.get_string(&input).map_err(|e| e.to_string())?.into();
            let mut host = HOST
                .get_or_init(|| Mutex::new(Host::default()))
                .lock()
                .map_err(|_| "native host poisoned")?;
            Ok::<_, String>(host.command(&text).to_string())
        }));
        let text = match result {
            Ok(Ok(t)) => t,
            Ok(Err(e)) => json!({"ok":false,"error":e}).to_string(),
            Err(_) => json!({"ok":false,"error":"native panic; restart session"}).to_string(),
        };
        env.new_string(text)
            .map(|s| s.into_raw())
            .unwrap_or(std::ptr::null_mut())
    }
}
