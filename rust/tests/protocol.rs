use prost::Message;
use t865_mesh::{
    client::Client,
    mesh::{Event, Mesh},
    proto::{self, Data},
    radio::*,
    wire::*,
};
fn channel() -> Channel {
    Channel::new("LongFast", &[1]).unwrap()
}
fn packet(from: u32, to: u32, id: u32, hops: u8, ack: bool) -> Frame {
    channel()
        .packet(
            from,
            to,
            id,
            hops,
            ack,
            Data {
                portnum: 1,
                payload: b"hello".to_vec(),
                ..Default::default()
            },
        )
        .unwrap()
}
fn frames(events: Vec<Event>) -> Vec<Frame> {
    events
        .into_iter()
        .filter_map(|e| match e {
            Event::Transmit { frame_hex, .. } => {
                Some(Frame::decode(&unhex(&frame_hex).unwrap()).unwrap())
            }
            _ => None,
        })
        .collect()
}

#[test]
fn independent_crypto_vector_and_header() {
    // Python cryptography AES-CTR + official Python Data protobuf, 2026-11-16.
    let f = channel()
        .packet(
            0x12345678,
            u32::MAX,
            42,
            3,
            false,
            Data {
                portnum: 1,
                payload: b"T865 bench".to_vec(),
                ..Default::default()
            },
        )
        .unwrap();
    assert_eq!(hex(&f.payload), "9db4f0fc307cd0bf81698bfad51b");
    assert_eq!(
        hex(&f.encode().unwrap()),
        "ffffffff785634122a000000630800789db4f0fc307cd0bf81698bfad51b"
    );
    assert_eq!(channel().hash(), 8);
    assert_eq!(Frame::decode(&f.encode().unwrap()).unwrap(), f);
    assert!(!packet(1, u32::MAX, 1, 3, true).want_ack);
    for n in 0..17 {
        assert!(Frame::decode(&vec![0; n]).is_err());
    }
    assert!(Frame::decode(&vec![0; 256]).is_err());
    assert!(Channel::new("x", &[2; 15]).is_err());
    assert!(unhex("é").is_err());
}

#[test]
fn api_fragmentation_noise_and_bounds() {
    let payload = vec![0x94, 0xc3, 0, 0, 0xff];
    let f = api_frame(&payload).unwrap();
    for split in 0..=f.len() {
        let mut p = ApiFramer::default();
        let mut out = p.feed(b"boot noise\x94\x94");
        out.extend(p.feed(&f[..split]));
        out.extend(p.feed(&f[split..]));
        assert_eq!(out, vec![payload.clone()]);
    }
    let mut p = ApiFramer::default();
    let mut all = vec![0x94, 0xc3, 0xff, 0xff];
    all.extend(&f);
    all.extend(&f);
    assert_eq!(p.feed(&all), vec![payload.clone(), payload]);
    assert!(api_frame(&[0; 513]).is_err());
    let mut p = ApiFramer::default();
    let mut overlap = vec![0x94, 0xc3];
    overlap.extend(api_frame(b"overlap").unwrap());
    assert_eq!(p.feed(&overlap), vec![b"overlap".to_vec()]);
}

#[test]
fn line_delivery_hops_and_diamond_cancellation() {
    let mut b = Mesh::new(2, channel(), 5000).unwrap();
    let mut c = Mesh::new(3, channel(), 5000).unwrap();
    let a = packet(1, u32::MAX, 1, 2, false);
    assert!(matches!(
        b.receive(a.clone(), 0, 100, 10).unwrap()[0],
        Event::Deliver { .. }
    ));
    assert!(b.tick(99).unwrap().is_empty());
    let relay = frames(b.tick(100).unwrap()).pop().unwrap();
    assert_eq!(relay.hops, 1);
    assert!(matches!(
        c.receive(relay.clone(), 100, 200, 11).unwrap()[0],
        Event::Deliver { .. }
    ));
    let end = frames(c.tick(300).unwrap()).pop().unwrap();
    assert_eq!(end.hops, 0);
    assert!(b.receive(end, 301, 50, 12).unwrap().is_empty());
    let mut d = Mesh::new(4, channel(), 5000).unwrap();
    d.receive(a, 0, 200, 13).unwrap();
    assert!(d.receive(relay, 100, 200, 14).unwrap().is_empty());
    assert!(d.tick(400).unwrap().is_empty());
}

#[test]
fn destination_duplicate_ack_no_loops_and_retry_exhaustion() {
    let mut a = Mesh::new(1, channel(), 100).unwrap();
    let mut b = Mesh::new(2, channel(), 100).unwrap();
    let f = packet(1, 2, 1, 3, true);
    a.originate(f.clone(), 0).unwrap();
    let first = b.receive(f.clone(), 0, 50, 20).unwrap();
    assert_eq!(
        first
            .iter()
            .filter(|e| matches!(e, Event::Deliver { .. }))
            .count(),
        1
    );
    let ack = frames(first).pop().unwrap();
    assert!(!ack.want_ack);
    let duplicate = b.receive(f, 100, 50, 21).unwrap();
    assert_eq!(
        duplicate
            .iter()
            .filter(|e| matches!(e, Event::Deliver { .. }))
            .count(),
        0
    );
    assert_eq!(frames(duplicate).len(), 1); // Lost ACK recovery, new reserved nonce.
    assert!(a
        .receive(ack, 50, 50, 22)
        .unwrap()
        .iter()
        .any(|e| matches!(e,Event::Status{state,..} if state=="channel_ack")));
    assert!(a.tick(1000).unwrap().is_empty());
    a.originate(packet(1, 2, 2, 3, true), 1000).unwrap();
    assert_eq!(frames(a.tick(1100).unwrap()).len(), 1);
    assert_eq!(frames(a.tick(1200).unwrap()).len(), 1);
    assert!(
        matches!(&a.tick(1300).unwrap()[0],Event::Status{state,..} if state=="retry_exhausted")
    );
}

#[test]
fn unknown_port_forwarded_ciphertext_unchanged_and_zero_hop_local() {
    let c = channel();
    let mut r = Mesh::new(2, c.clone(), 100).unwrap();
    let f = c
        .packet(
            1,
            u32::MAX,
            30,
            1,
            false,
            Data {
                portnum: 65000,
                payload: vec![0, 255, 0],
                ..Default::default()
            },
        )
        .unwrap();
    let original = f.payload.clone();
    r.receive(f, 0, 10, 40).unwrap();
    assert_eq!(frames(r.tick(10).unwrap())[0].payload, original);
    let f = packet(1, u32::MAX, 31, 0, false);
    assert_eq!(r.receive(f, 20, 10, 41).unwrap().len(), 1);
    assert!(r.tick(100).unwrap().is_empty());
}

#[test]
fn client_handshake_matching_nonce_and_no_early_tx() {
    let mut c = Client::default();
    assert!(c.text(u32::MAX, 0, 3, "hello").is_err());
    let start = c.start(7).unwrap();
    assert_eq!(&start[..4], &[0x94; 4]);
    let msgs = [
        proto::from_radio::PayloadVariant::MyInfo(proto::MyNodeInfo {
            my_node_num: 2,
            ..Default::default()
        }),
        proto::from_radio::PayloadVariant::ConfigCompleteId(8),
    ];
    for p in msgs {
        let f = proto::FromRadio {
            id: 0,
            payload_variant: Some(p),
        };
        c.feed(&api_frame(&f.encode_to_vec()).unwrap());
    }
    assert!(c.text(u32::MAX, 0, 3, "hello").is_err());
    let f = proto::FromRadio {
        id: 0,
        payload_variant: Some(proto::from_radio::PayloadVariant::ConfigCompleteId(7)),
    };
    c.feed(&api_frame(&f.encode_to_vec()).unwrap());
    let b = c.text(3, 0, 3, "hello").unwrap();
    let p = proto::ToRadio::decode(&b[4..]).unwrap();
    assert!(
        matches!(p.payload_variant,Some(proto::to_radio::PayloadVariant::Packet(p)) if p.to==3 && p.want_ack && p.id==0)
    );
}

#[test]
fn vendor_parser_fragmentation_and_native_gate() {
    assert_eq!(read_registers(Model::E220, 0, 8).unwrap(), [0xc1, 0, 8]);
    assert!(read_registers(Model::E220, 8, 1).is_err());
    assert!(read_registers(Model::E22, 8, 1).is_ok());
    for split in 0..=5 {
        let mut p = RegisterReply::default();
        let b = [0xc1, 2, 2, 0x62, 0];
        let first = p.feed(&b[..split], 2, 2).unwrap();
        let last = p.feed(&b[split..], 2, 2).unwrap();
        assert_eq!(first.or(last), Some(vec![0x62, 0]));
    }
    assert!(RegisterReply::default()
        .feed(&[0xc0, 0, 1, 0], 0, 1)
        .is_err());
    assert!(RegisterReply::default()
        .feed(&[0xc1, 1, 1, 0], 0, 1)
        .is_err());
    assert_eq!(capabilities()["native_rf_tx"], false);
    let mut h = t865_mesh::Host::default();
    assert_eq!(h.command("{\"op\":\"native_tx\"}")["ok"], false);
    assert!(t865_mesh::selftest().is_ok());
}

#[test]
fn directed_route_learning_and_final_flood_fallback() {
    let mut a = Mesh::new(1, channel(), 100).unwrap();
    let f = packet(1, 3, 100, 3, true);
    a.originate(f.clone(), 0).unwrap();
    let mut overheard = f;
    overheard.relay = 2;
    overheard.hops = 2;
    a.receive(overheard, 10, 5, 200).unwrap();
    let d = Data {
        portnum: 5,
        request_id: 100,
        payload: proto::Routing {
            variant: Some(proto::routing::Variant::ErrorReason(0)),
        }
        .encode_to_vec(),
        ..Default::default()
    };
    let mut ack = channel().packet(3, 1, 201, 2, false, d).unwrap();
    ack.relay = 2;
    a.receive(ack, 20, 5, 202).unwrap();
    let next = frames(a.originate(packet(1, 3, 101, 3, true), 30).unwrap())
        .pop()
        .unwrap();
    assert_eq!(next.next_hop, 2);
    assert_eq!(frames(a.tick(130).unwrap())[0].next_hop, 2);
    assert_eq!(frames(a.tick(230).unwrap())[0].next_hop, 0);
}

#[test]
fn wrong_source_ack_and_history_limit() {
    let mut a = Mesh::new(1, channel(), 100).unwrap();
    a.originate(packet(1, 3, 1, 3, true), 0).unwrap();
    let data = Data {
        portnum: 5,
        request_id: 1,
        payload: proto::Routing {
            variant: Some(proto::routing::Variant::ErrorReason(0)),
        }
        .encode_to_vec(),
        ..Default::default()
    };
    a.receive(
        channel().packet(4, 1, 99, 1, false, data).unwrap(),
        0,
        5,
        20,
    )
    .unwrap();
    assert_eq!(frames(a.tick(100).unwrap()).len(), 1);
    let mut a = Mesh::new(1, channel(), 100).unwrap();
    for id in 1..=128 {
        a.receive(packet(2, u32::MAX, id, 0, false), 0, 5, 1000 + id)
            .unwrap();
    }
    assert!(a
        .receive(packet(2, u32::MAX, 129, 0, false), 0, 5, 1200)
        .is_err());
    assert!(a
        .receive(packet(2, u32::MAX, 129, 0, false), 600001, 5, 1201)
        .is_ok());
}

#[test]
fn expansion_abi_is_zeroed_and_uses_logical_not_physical_pin_number() {
    let a = ExpandArg::new(2, 1, true);
    assert_eq!(std::mem::size_of_val(&a), 28);
    assert_eq!(a.0, [1, 0, 1, 2, 0, 0, 0]);
    assert_eq!(ExpandArg::new(2, 0, false).0, [0, 0, 0, 2, 0, 0, 0]);
}
