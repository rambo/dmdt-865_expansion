#!/usr/bin/env python3
"""Local byte bridge to an official node. Does not configure its RF settings.

Requires pyserial==3.5. Launch this, then adb reverse tcp:4403 tcp:4403.
Only the Android app speaks ToRadio/FromRadio; routing stays on the USB node.
"""
import argparse
import select
import socket
import subprocess
import sys
import time
import serial


def bridge(port, listen_port, once=False):
    # Prevent competing readers, including the official desktop app.
    occupied = subprocess.run(["lsof", "-t", port], capture_output=True, text=True)
    if occupied.stdout.strip():
        raise RuntimeError(f"{port} already open by PID(s) {occupied.stdout.strip()}; disconnect other clients first")
    with socket.socket() as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind(("127.0.0.1", listen_port))
        server.listen(1)
        print(f"Listening on 127.0.0.1:{listen_port}; USB {port}", flush=True)
        while True:
            conn, addr = server.accept()
            tx = rx = 0
            try:
                # Set line states before open; do not deliberately reset ESP32 hardware.
                uart = serial.Serial(port=None, baudrate=115200, timeout=0, write_timeout=1, exclusive=True)
                uart.dtr = False
                uart.rts = False
                uart.port = port
                uart.open()
                with conn, uart:
                    conn.settimeout(1)
                    print("Tablet connected; forwarding official client API", flush=True)
                    while True:
                        readable, _, _ = select.select([conn, uart], [], [], 1)
                        if conn in readable:
                            data = conn.recv(4096)
                            if not data:
                                break
                            offset = 0
                            while offset < len(data):
                                n = uart.write(data[offset:])
                                if not n:
                                    raise OSError("zero-length USB write")
                                offset += n
                            tx += len(data)
                        if uart in readable:
                            data = uart.read(4096)
                            if data:
                                conn.sendall(data)
                                rx += len(data)
            except (OSError, serial.SerialException) as e:
                conn.close()
                print(f"Connection ended: {e}", file=sys.stderr, flush=True)
            finally:
                print(f"Session closed: tablet->USB {tx} bytes; USB->tablet {rx} bytes", flush=True)
            if once:
                return


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--port", required=True)
    p.add_argument("--listen", type=int, default=4403)
    p.add_argument("--once", action="store_true")
    args = p.parse_args()
    try:
        bridge(args.port, args.listen, args.once)
    except KeyboardInterrupt:
        pass
    except (RuntimeError, OSError) as e:
        p.exit(1, f"{e}\n")


if __name__ == "__main__":
    main()
