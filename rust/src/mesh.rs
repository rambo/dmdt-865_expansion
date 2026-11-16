//! Bounded CLIENT-role bench router. No hardware or wall-clock dependencies.
//! Delay/retry intervals are injected bench policy, not qualified LoRa timing.
use crate::{
    proto::{routing, Data, Routing},
    wire::{hex, Channel, Frame, BROADCAST},
};
use prost::Message;
use serde::Serialize;
use std::collections::{BTreeMap, BTreeSet};
type Key = (u32, u32);
const LIMIT: usize = 128;
const HISTORY_MS: u64 = 600_000;

#[derive(Debug, Serialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum Event {
    Deliver {
        from: u32,
        to: u32,
        id: u32,
        port: i32,
        text: Option<String>,
        payload_hex: String,
    },
    Transmit {
        frame_hex: String,
        from: u32,
        id: u32,
        reason: String,
    },
    Status {
        id: u32,
        state: String,
    },
}
struct Seen {
    hops: u8,
    next: u8,
    expires: u64,
    relayers: BTreeSet<u8>,
}
struct Queued {
    frame: Frame,
    due: u64,
}
struct Pending {
    frame: Frame,
    due: u64,
    remaining: u8,
    forwarded: bool,
}
pub struct Mesh {
    node: u32,
    pub channel: Channel,
    history: BTreeMap<Key, Seen>,
    queue: BTreeMap<Key, Queued>,
    pending: BTreeMap<Key, Pending>,
    routes: BTreeMap<u32, u8>,
    retry_ms: u64,
}
impl Mesh {
    pub fn new(node: u32, channel: Channel, retry_ms: u64) -> Result<Self, String> {
        if node == 0 || node == BROADCAST || retry_ms < 100 {
            return Err("invalid node or retry interval".into());
        }
        Ok(Self {
            node,
            channel,
            history: BTreeMap::new(),
            queue: BTreeMap::new(),
            pending: BTreeMap::new(),
            routes: BTreeMap::new(),
            retry_ms,
        })
    }
    fn prune(&mut self, now: u64) {
        self.history.retain(|_, v| v.expires > now);
    }
    fn remember(&mut self, f: &Frame, now: u64) -> Result<(), String> {
        self.prune(now);
        let k = (f.from, f.id);
        if !self.history.contains_key(&k) && self.history.len() >= LIMIT {
            return Err("history full; packet rejected without early eviction".into());
        }
        let s = self.history.entry(k).or_insert(Seen {
            hops: f.hops,
            next: f.next_hop,
            expires: now.saturating_add(HISTORY_MS),
            relayers: BTreeSet::new(),
        });
        s.hops = s.hops.max(f.hops);
        s.next = f.next_hop;
        if s.relayers.len() < 4 {
            s.relayers.insert(f.relay);
        }
        Ok(())
    }
    pub fn originate(&mut self, mut f: Frame, now: u64) -> Result<Vec<Event>, String> {
        if f.from != self.node || self.history.contains_key(&(f.from, f.id)) {
            return Err("source mismatch or reused packet ID".into());
        }
        f.next_hop = self
            .routes
            .get(&f.to)
            .copied()
            .filter(|x| *x != self.node as u8)
            .unwrap_or(0);
        self.remember(&f, now)?;
        if f.want_ack {
            if self.pending.len() >= 32 {
                return Err("pending send limit".into());
            }
            self.pending.insert(
                (f.from, f.id),
                Pending {
                    frame: f.clone(),
                    due: now.saturating_add(self.retry_ms),
                    remaining: 2,
                    forwarded: false,
                },
            );
        }
        Ok(vec![Self::tx(&f, "origin")?])
    }
    fn tx(f: &Frame, reason: &str) -> Result<Event, String> {
        Ok(Event::Transmit {
            frame_hex: hex(&f.encode()?),
            from: f.from,
            id: f.id,
            reason: reason.into(),
        })
    }
    /// ack_id must be reserved by the host BEFORE this call; unused IDs can be skipped.
    pub fn receive(
        &mut self,
        f: Frame,
        now: u64,
        relay_delay: u64,
        ack_id: u32,
    ) -> Result<Vec<Event>, String> {
        self.prune(now);
        if f.channel != self.channel.hash() {
            return Ok(vec![]);
        }
        let mut out = vec![];
        let k = (f.from, f.id);
        if f.from == self.node {
            if let Some(seen) = self.history.get_mut(&k) {
                if seen.relayers.len() < 4 {
                    seen.relayers.insert(f.relay);
                }
            }
            if let Some(p) = self.pending.get_mut(&k) {
                p.forwarded = true;
                if p.frame.to == BROADCAST {
                    self.pending.remove(&k);
                    out.push(Event::Status {
                        id: f.id,
                        state: "implicit_ack".into(),
                    });
                }
            }
            return Ok(out);
        }
        let decoded = f.data(&self.channel).ok(); // Unknown ports/ciphertext may still be relayed.
        if let Some(d) = &decoded {
            if d.request_id != 0 && f.to != self.node && f.to != BROADCAST {
                self.queue.remove(&(f.to, d.request_id));
                self.pending.remove(&(f.to, d.request_id));
            }
            if d.request_id != 0 && f.to == self.node {
                let key = (self.node, d.request_id);
                if let Some(p) = self.pending.get(&key) {
                    if p.frame.to == f.from {
                        let routing_error = if d.portnum == 5 {
                            Routing::decode(d.payload.as_slice()).ok().and_then(|r| {
                                match r.variant {
                                    Some(routing::Variant::ErrorReason(e)) => Some(e),
                                    _ => None,
                                }
                            })
                        } else {
                            Some(0)
                        };
                        if let Some(error) = routing_error {
                            let relayed = self
                                .history
                                .get(&key)
                                .map(|s| s.relayers.contains(&f.relay))
                                .unwrap_or(false);
                            if error == 0
                                && (relayed || f.relay == f.from as u8)
                                && f.relay != self.node as u8
                                && f.relay != 0
                                && self.routes.len() < LIMIT
                            {
                                self.routes.insert(f.from, f.relay);
                            }
                            self.pending.remove(&key);
                            out.push(Event::Status {
                                id: d.request_id,
                                state: if error == 0 {
                                    "channel_ack".into()
                                } else {
                                    format!("nak_{error}")
                                },
                            });
                        }
                    }
                }
            }
        }
        let old = self.history.get(&k);
        let duplicate = old.is_some();
        let upgrade = old.map(|s| f.hops > s.hops).unwrap_or(false);
        let fallback = old
            .map(|s| {
                s.next != 0
                    && s.next != self.node as u8
                    && f.next_hop == 0
                    && s.relayers.contains(&f.relay)
            })
            .unwrap_or(false);
        let repeated = f.hop_start > 0 && f.hops == f.hop_start;
        self.remember(&f, now)?;
        // An overheard copy stops intermediate retries; it is not destination delivery.
        self.pending.remove(&k);
        if !duplicate && (f.to == self.node || f.to == BROADCAST) {
            if let Some(d) = &decoded {
                out.push(Event::Deliver {
                    from: f.from,
                    to: f.to,
                    id: f.id,
                    port: d.portnum,
                    text: if d.portnum == 1 {
                        String::from_utf8(d.payload.clone()).ok()
                    } else {
                        None
                    },
                    payload_hex: hex(&d.payload),
                });
            }
        }
        if let Some(d) = decoded.as_ref().filter(|_| f.to == self.node && f.want_ack) {
            // Do not ACK an ACK: prevents loops. Channel ACKs are not authenticated delivery proof.
            if d.portnum != 5 {
                if ack_id == 0 || self.history.contains_key(&(self.node, ack_id)) {
                    return Err("fresh reserved ACK ID required".into());
                }
                let r = Routing {
                    variant: Some(routing::Variant::ErrorReason(0)),
                };
                let data = Data {
                    portnum: 5,
                    payload: r.encode_to_vec(),
                    request_id: f.id,
                    ..Default::default()
                };
                let ack = self.channel.packet(
                    self.node,
                    f.from,
                    ack_id,
                    f.hop_start.max(1),
                    false,
                    data,
                )?;
                self.remember(&ack, now)?;
                out.push(Self::tx(&ack, "destination_ack")?);
            }
            return Ok(out);
        }
        if duplicate && !upgrade && !fallback && !repeated {
            if f.next_hop != self.node as u8 {
                self.queue.remove(&k);
            }
            return Ok(out);
        }
        if f.hops == 0 || f.to == self.node || (f.next_hop != 0 && f.next_hop != self.node as u8) {
            return Ok(out);
        }
        if self.queue.len() >= 32 && !self.queue.contains_key(&k) {
            out.push(Event::Status {
                id: f.id,
                state: "relay_queue_full".into(),
            });
            return Ok(out);
        }
        let mut relay = f.clone();
        relay.hops -= 1;
        relay.relay = self.node as u8;
        relay.next_hop = if relay.to == BROADCAST {
            0
        } else {
            self.routes
                .get(&relay.to)
                .copied()
                .filter(|x| *x != f.relay && *x != self.node as u8)
                .unwrap_or(0)
        };
        if !self.queue.contains_key(&k) || upgrade || fallback {
            self.queue.insert(
                k,
                Queued {
                    frame: relay,
                    due: now.saturating_add(relay_delay),
                },
            );
        }
        Ok(out)
    }
    pub fn tick(&mut self, now: u64) -> Result<Vec<Event>, String> {
        self.prune(now);
        let mut out = vec![];
        let due: Vec<_> = self
            .queue
            .iter()
            .filter(|(_, v)| v.due <= now)
            .map(|(k, _)| *k)
            .collect();
        for k in due {
            let q = self.queue.remove(&k).unwrap();
            if q.frame.next_hop != 0 && self.pending.len() < 32 {
                self.pending.insert(
                    k,
                    Pending {
                        frame: q.frame.clone(),
                        due: now.saturating_add(self.retry_ms),
                        remaining: 1,
                        forwarded: false,
                    },
                );
            }
            out.push(Self::tx(&q.frame, "relay")?);
        }
        let due: Vec<_> = self
            .pending
            .iter()
            .filter(|(_, v)| v.due <= now)
            .map(|(k, _)| *k)
            .collect();
        for k in due {
            let mut p = self.pending.remove(&k).unwrap();
            if p.remaining == 0 {
                out.push(Event::Status {
                    id: k.1,
                    state: "retry_exhausted".into(),
                });
                continue;
            }
            if p.remaining == 1 && !p.forwarded {
                p.frame.next_hop = 0;
                self.routes.remove(&p.frame.to);
            }
            p.remaining -= 1;
            p.due = now.saturating_add(self.retry_ms);
            out.push(Self::tx(&p.frame, "retry")?);
            self.pending.insert(k, p);
        }
        Ok(out)
    }
}
