use crate::proto::Data;
use aes::cipher::{KeyIvInit, StreamCipher};
use prost::Message;

pub const BROADCAST: u32 = u32::MAX;
pub const DEFAULT_KEY: [u8; 16] = [
    0xd4, 0xf1, 0xbb, 0x3a, 0x20, 0x29, 0x07, 0x59, 0xf0, 0xbc, 0xff, 0xab, 0xcf, 0x4e, 0x69, 0x01,
];

pub fn unhex(s: &str) -> Result<Vec<u8>, String> {
    let s: Vec<_> = s.bytes().filter(|x| !x.is_ascii_whitespace()).collect();
    if s.len() % 2 != 0 || s.len() > 8192 {
        return Err("invalid hex length".into());
    }
    s.as_chunks::<2>()
        .0
        .iter()
        .map(|x| {
            let a = (x[0] as char).to_digit(16).ok_or("invalid hex")?;
            let b = (x[1] as char).to_digit(16).ok_or("invalid hex")?;
            Ok((a * 16 + b) as u8)
        })
        .collect()
}
pub fn hex(b: &[u8]) -> String {
    b.iter().map(|b| format!("{b:02x}")).collect()
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Frame {
    pub to: u32,
    pub from: u32,
    pub id: u32,
    pub hops: u8,
    pub want_ack: bool,
    pub via_mqtt: bool,
    pub hop_start: u8,
    pub channel: u8,
    pub next_hop: u8,
    pub relay: u8,
    pub payload: Vec<u8>,
}
impl Frame {
    pub fn decode(b: &[u8]) -> Result<Self, String> {
        if !(17..=255).contains(&b.len()) {
            return Err("RF frame must be 17..255 bytes".into());
        }
        let u32at = |p| u32::from_le_bytes(b[p..p + 4].try_into().unwrap());
        let f = Self {
            to: u32at(0),
            from: u32at(4),
            id: u32at(8),
            hops: b[12] & 7,
            want_ack: b[12] & 8 != 0,
            via_mqtt: b[12] & 16 != 0,
            hop_start: b[12] >> 5,
            channel: b[13],
            next_hop: b[14],
            relay: b[15],
            payload: b[16..].into(),
        };
        if f.from == 0 || f.from == BROADCAST || f.id == 0 {
            return Err("invalid source or packet ID".into());
        }
        Ok(f)
    }
    pub fn encode(&self) -> Result<Vec<u8>, String> {
        if self.hops > 7 || self.hop_start > 7 {
            return Err("hop limit exceeds 7".into());
        }
        let mut b = Vec::with_capacity(16 + self.payload.len());
        for n in [self.to, self.from, self.id] {
            b.extend(n.to_le_bytes());
        }
        b.extend([
            self.hops
                | ((self.want_ack as u8) << 3)
                | ((self.via_mqtt as u8) << 4)
                | (self.hop_start << 5),
            self.channel,
            self.next_hop,
            self.relay,
        ]);
        b.extend(&self.payload);
        Self::decode(&b)?;
        Ok(b)
    }
    pub fn data(&self, c: &Channel) -> Result<Data, String> {
        if self.channel != c.hash() {
            return Err("channel hash mismatch".into());
        }
        let mut b = self.payload.clone();
        c.crypt(self.from, self.id, &mut b)?;
        let d = Data::decode(b.as_slice())
            .map_err(|_| "invalid Data protobuf (wrong key or unsupported crypto)")?;
        if d.portnum <= 0 || d.payload.len() > 233 {
            return Err("invalid application data".into());
        }
        Ok(d)
    }
}

#[derive(Clone)]
pub struct Channel {
    pub name: String,
    key: Vec<u8>,
}
impl Channel {
    pub fn new(name: &str, key: &[u8]) -> Result<Self, String> {
        let key = match key {
            [] | [0] => vec![],
            [alias] => {
                let mut k = DEFAULT_KEY.to_vec();
                k[15] = k[15].wrapping_add(*alias - 1);
                k
            }
            k if k.len() == 16 || k.len() == 32 => k.to_vec(),
            _ => return Err("PSK must be empty, a one-byte alias, 16 or 32 bytes".into()),
        };
        if name.len() > 32 {
            return Err("channel name too long".into());
        }
        Ok(Self {
            name: name.into(),
            key,
        })
    }
    pub fn hash(&self) -> u8 {
        self.name
            .bytes()
            .chain(self.key.iter().copied())
            .fold(0, |a, b| a ^ b)
    }
    pub fn crypt(&self, from: u32, id: u32, b: &mut [u8]) -> Result<(), String> {
        let mut nonce = [0; 16];
        nonce[..8].copy_from_slice(&(id as u64).to_le_bytes());
        nonce[8..12].copy_from_slice(&from.to_le_bytes());
        match self.key.len() {
            0 => {}
            16 => ctr::Ctr128BE::<aes::Aes128>::new_from_slices(&self.key, &nonce)
                .unwrap()
                .apply_keystream(b),
            32 => ctr::Ctr128BE::<aes::Aes256>::new_from_slices(&self.key, &nonce)
                .unwrap()
                .apply_keystream(b),
            _ => return Err("unsupported key length".into()),
        };
        Ok(())
    }
    pub fn packet(
        &self,
        from: u32,
        to: u32,
        id: u32,
        hops: u8,
        want_ack: bool,
        data: Data,
    ) -> Result<Frame, String> {
        if data.payload.len() > 233 {
            return Err("payload exceeds 233 bytes".into());
        }
        let mut payload = data.encode_to_vec();
        self.crypt(from, id, &mut payload)?;
        let f = Frame {
            to,
            from,
            id,
            hops,
            want_ack: want_ack && to != BROADCAST,
            via_mqtt: false,
            hop_start: hops,
            channel: self.hash(),
            next_hop: 0,
            relay: from as u8,
            payload,
        };
        f.encode()?;
        Ok(f)
    }
}

/// Meshtastic CLIENT API stream framing, never the on-air packet format.
#[derive(Default)]
pub struct ApiFramer {
    buffer: Vec<u8>,
}
impl ApiFramer {
    pub fn feed(&mut self, b: &[u8]) -> Vec<Vec<u8>> {
        let mut out = vec![];
        for &byte in b {
            self.buffer.push(byte);
            loop {
                match self.buffer.windows(2).position(|w| w == [0x94, 0xc3]) {
                    Some(offset) => {
                        self.buffer.drain(..offset);
                    }
                    None => {
                        let last = self.buffer.last().copied();
                        self.buffer.clear();
                        if last == Some(0x94) {
                            self.buffer.push(0x94);
                        }
                        break;
                    }
                }
                if self.buffer.len() < 4 {
                    break;
                }
                let n = u16::from_be_bytes([self.buffer[2], self.buffer[3]]) as usize;
                if n == 0 || n > 512 {
                    self.buffer.remove(0);
                    continue;
                }
                if self.buffer.len() < 4 + n {
                    break;
                }
                out.push(self.buffer[4..4 + n].to_vec());
                self.buffer.drain(..4 + n);
            }
        }
        out
    }
}
pub fn api_frame(b: &[u8]) -> Result<Vec<u8>, String> {
    if b.is_empty() || b.len() > 512 {
        return Err("API payload must be 1..512 bytes".into());
    }
    let mut v = vec![0x94, 0xc3];
    v.extend((b.len() as u16).to_be_bytes());
    v.extend(b);
    Ok(v)
}
