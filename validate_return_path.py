#!/usr/bin/env python3
"""Brief tablet TX test; restores receive-only idle in finally. Requires wiring."""
import array
import fcntl
import os
from pathlib import Path
import re
import select
import subprocess
import sys
import termios
import time
import tty

adb = os.environ.get('ADB', '/Users/rambo/Library/Android/sdk/platform-tools/adb')
port = sys.argv[1] if len(sys.argv) > 1 else '/dev/cu.usbserial-21230'
fd = os.open(port, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
record = []
received = bytearray()
pending = b''
try:
    tty.setraw(fd)
    config = termios.tcgetattr(fd)
    config[2] |= termios.CLOCAL | termios.CREAD
    config[2] &= ~(termios.CRTSCTS | termios.HUPCL)
    config[4] = config[5] = termios.B115200
    termios.tcsetattr(fd, termios.TCSANOW, config)
    fcntl.ioctl(fd, termios.TIOCMBIC, array.array('i', [termios.TIOCM_DTR | termios.TIOCM_RTS]))
    termios.tcflush(fd, termios.TCIFLUSH)
    subprocess.run([adb, '-d', 'shell', 'am', 'start', '-n',
                    'dev.t865.uarttx/.MainActivity', '--ez', 'start', 'true'], check=True)
    deadline = time.monotonic() + 4.5
    while time.monotonic() < deadline:
        if not select.select([fd], [], [], max(0, deadline - time.monotonic()))[0]:
            break
        pending += os.read(fd, 4096)
        while b'\n' in pending:
            raw, pending = pending.split(b'\n', 1)
            line = raw.rstrip(b'\r').decode('utf-8', errors='replace')
            record.append(line)
            match = re.fullmatch(r'RX (\d+) bytes hex=\[([0-9A-F ]*)\] ascii=\[.*\]', line)
            if match:
                data = bytes.fromhex(match[2])
                assert len(data) == int(match[1])
                received.extend(data)
    frame = b'UUUU T865 UART WK2\r\n'
    count = received.count(frame)
    assert count >= 2, f'Only {count} exact tablet frames; received {received!r}'
    print(f'PASS: ESP32 GPIO25 received {count} exact tablet UART frames ({len(received)} bytes)')
finally:
    try:
        subprocess.run([adb, '-d', 'shell', 'am', 'start', '-n',
                        'dev.t865.uarttx/.MainActivity', '--ez', 'idle', 'true'], check=True)
    finally:
        os.close(fd)
        (Path(__file__).resolve().parent / 'validation/return-path.log').write_text(
            '\n'.join(record) + '\n')
