//! Official node client API. All RF/routing in this mode remains on that node.
use crate::{
    proto::{self, from_radio, mesh_packet, to_radio},
    wire::{api_frame, hex, ApiFramer},
};
use prost::Message;
use serde_json::{json, Value};
#[derive(Default)]
pub struct Client {
    framer: ApiFramer,
    nonce: u32,
    node: u32,
    ready: bool,
}
impl Client {
    pub fn start(&mut self, nonce: u32) -> Result<Vec<u8>, String> {
        if nonce == 0 {
            return Err("nonzero configuration nonce required".into());
        }
        *self = Self::default();
        self.nonce = nonce;
        let mut b = vec![0x94; 4];
        b.extend(encode(to_radio::PayloadVariant::WantConfigId(nonce))?);
        Ok(b)
    }
    pub fn heartbeat(&self) -> Result<Vec<u8>, String> {
        encode(to_radio::PayloadVariant::Heartbeat(proto::Heartbeat {
            nonce: 0,
        }))
    }
    pub fn disconnect(&self) -> Result<Vec<u8>, String> {
        encode(to_radio::PayloadVariant::Disconnect(true))
    }
    pub fn text(&self, to: u32, channel: u32, hops: u32, text: &str) -> Result<Vec<u8>, String> {
        if !self.ready || self.node == 0 {
            return Err("wait for matching config_complete and MyNodeInfo".into());
        }
        if to == 0 || text.is_empty() || text.len() > 200 || channel > 7 || hops > 7 {
            return Err("invalid text/destination/channel/hops".into());
        }
        let d = proto::Data {
            portnum: 1,
            payload: text.as_bytes().to_vec(),
            ..Default::default()
        };
        let p = proto::MeshPacket {
            to,
            // Firmware owns packet ID allocation and its encryption nonce namespace.
            id: 0,
            channel,
            hop_limit: hops,
            want_ack: to != u32::MAX,
            payload_variant: Some(mesh_packet::PayloadVariant::Decoded(d)),
            ..Default::default()
        };
        encode(to_radio::PayloadVariant::Packet(p))
    }
    pub fn feed(&mut self, b: &[u8]) -> Vec<Value> {
        let mut events = vec![];
        for payload in self.framer.feed(b) {
            let msg = match proto::FromRadio::decode(payload.as_slice()) {
                Ok(m) => m,
                Err(e) => {
                    events.push(json!({"kind":"invalid_protobuf","error":e.to_string()}));
                    continue;
                }
            };
            use from_radio::PayloadVariant as P;
            let event = match msg.payload_variant {
                Some(P::MyInfo(i)) => {
                    self.node = i.my_node_num;
                    json!({"kind":"my_info","node":format!("!{:08x}",self.node)})
                }
                Some(P::Metadata(m)) => {
                    json!({"kind":"metadata","firmware":m.firmware_version,"hardware":m.hw_model})
                }
                Some(P::ConfigCompleteId(n)) => {
                    self.ready = n == self.nonce;
                    json!({"kind":"config_complete","nonce":n,"matched":self.ready})
                }
                Some(P::Channel(c)) => {
                    json!({"kind":"channel","index":c.index,"role":c.role,"name":c.settings.map(|s|s.name)})
                }
                Some(P::NodeInfo(n)) => {
                    json!({"kind":"node","node":format!("!{:08x}",n.num),"name":n.user.map(|u|u.long_name)})
                }
                Some(P::Config(c)) => match c.payload_variant {
                    Some(proto::config::PayloadVariant::Lora(l)) => {
                        json!({"kind":"lora","region":l.region,"use_preset":l.use_preset,"preset":l.modem_preset,"bandwidth":l.bandwidth,"sf":l.spread_factor,"cr":l.coding_rate,"frequency_override":l.override_frequency,"channel_num":l.channel_num,"tx_enabled":l.tx_enabled})
                    }
                    _ => json!({"kind":"config"}),
                },
                Some(P::Packet(p)) => {
                    let mut e = json!({"kind":"packet","from":format!("!{:08x}",p.from),"to":format!("!{:08x}",p.to),"id":p.id,"channel":p.channel,"snr":p.rx_snr,"rssi":p.rx_rssi,"hop_limit":p.hop_limit,"hop_start":p.hop_start,"via_mqtt":p.via_mqtt});
                    match p.payload_variant {
                        Some(mesh_packet::PayloadVariant::Decoded(d)) => {
                            e["port"] = json!(d.portnum);
                            e["request_id"] = json!(d.request_id);
                            if d.portnum == 1 {
                                e["text"] = json!(String::from_utf8_lossy(&d.payload));
                            }
                            if d.portnum == 5 {
                                e["routing"] = json!(proto::Routing::decode(d.payload.as_slice())
                                    .ok()
                                    .map(|r| format!("{:?}", r.variant)));
                            }
                        }
                        Some(mesh_packet::PayloadVariant::Encrypted(b)) => {
                            e["encrypted_bytes"] = json!(b.len());
                        }
                        _ => {}
                    };
                    e
                }
                Some(P::QueueStatus(q)) => {
                    json!({"kind":"queue_status","id":q.mesh_packet_id,"result":q.res,"free":q.free})
                }
                Some(P::Rebooted(b)) => {
                    if b {
                        self.ready = false;
                    }
                    json!({"kind":"rebooted","value":b})
                }
                Some(P::ClientNotification(n)) => {
                    json!({"kind":"notification","message":n.message})
                }
                Some(P::LogRecord(_)) => continue,
                _ => json!({"kind":"other"}),
            };
            events.push(event);
        }
        events
    }
}
fn encode(p: to_radio::PayloadVariant) -> Result<Vec<u8>, String> {
    api_frame(
        &proto::ToRadio {
            payload_variant: Some(p),
        }
        .encode_to_vec(),
    )
}
pub fn bytes(b: Vec<u8>) -> Value {
    json!({"bytes_hex":hex(&b)})
}
