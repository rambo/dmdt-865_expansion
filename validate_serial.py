#!/usr/bin/env python3
"""On-board smoke check. Sends USB s/r commands and leaves probe TX running."""
import array
import fcntl
import os
from pathlib import Path
import re
import select
import sys
import termios
import time
import tty

port = sys.argv[1] if len(sys.argv) > 1 else '/dev/cu.usbserial-21230'
fd = os.open(port, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
record = []
pending = b''


def collect(seconds):
    global pending
    lines = []
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        if not select.select([fd], [], [], max(0, deadline - time.monotonic()))[0]:
            break
        try:
            pending += os.read(fd, 4096)
        except BlockingIOError:
            continue
        while b'\n' in pending:
            raw, pending = pending.split(b'\n', 1)
            text = raw.rstrip(b'\r').decode('utf-8', errors='replace')
            item = (time.monotonic(), text)
            lines.append(item)
            record.append(item)
    return lines


def frames(lines):
    result = []
    for timestamp, line in lines:
        match = re.fullmatch(r'TX 24/24 bytes: UUUU RX-PROBE (\d{8,10})', line)
        if match:
            result.append((timestamp, int(match[1])))
    return result


try:
    tty.setraw(fd)
    config = termios.tcgetattr(fd)
    config[2] |= termios.CLOCAL | termios.CREAD
    config[2] &= ~(termios.CRTSCTS | termios.HUPCL)
    config[4] = config[5] = termios.B115200
    termios.tcsetattr(fd, termios.TCSANOW, config)
    fcntl.ioctl(fd, termios.TIOCMBIC, array.array('i', [termios.TIOCM_DTR | termios.TIOCM_RTS]))
    termios.tcflush(fd, termios.TCIFLUSH)
    initial = frames(collect(3.5))
    assert len(initial) >= 2, 'No running probe frames on the USB console'
    assert all(b[1] == a[1] + 1 for a, b in zip(initial, initial[1:])), initial
    assert all(0.7 < b[0] - a[0] < 1.3 for a, b in zip(initial, initial[1:])), initial
    os.write(fd, b's\n')
    stopped = collect(0.5)
    assert any('PAUSED:' in text for _, text in stopped), stopped
    assert not frames(collect(2.2)), 'Frames continued after pause'
    os.write(fd, b'r\n')
    resumed = collect(3.5)
    assert any('RESUMED:' in text for _, text in resumed), resumed
    assert len(frames(resumed)) >= 2, resumed
    assert frames(resumed)[0][1] > initial[-1][1]
    print('PASS: sequential 24-byte frames near 1 Hz, pause suppresses TX, resume restarts TX')
finally:
    os.close(fd)
    target = Path(__file__).resolve().parent / 'validation/serial-smoke.log'
    target.write_text('\n'.join(f'{timestamp:.6f} {text}' for timestamp, text in record) + '\n')
