"""One-shot scope capture only; never opens tablet device nodes."""
import io
import json
import socket
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def utc():
    return datetime.now(timezone.utc).isoformat()


def read_exact(stream, count):
    result = bytearray()
    while len(result) < count:
        part = stream.read(count - len(result))
        if not part:
            raise EOFError("Truncated scope response")
        result.extend(part)
    return bytes(result)


def read_block(stream):
    marker = read_exact(stream, 1)
    for _ in range(3):
        if marker not in (b"\r", b"\n"):
            break
        marker = read_exact(stream, 1)
    if marker != b"#":
        raise ValueError(f"Expected binary block, got {marker!r}")
    digits = read_exact(stream, 1)
    if digits not in tuple(bytes([x]) for x in b"123456789"):
        raise ValueError("Invalid binary-block length header")
    count = int(read_exact(stream, int(digits)))
    if not 0 < count <= 10_000_000:
        raise ValueError("Invalid binary-block payload length")
    return read_exact(stream, count)


class Scope:
    def __init__(self, phase):
        self.phase = phase
        self.log = []
        self.sock = socket.create_connection(("192.168.220.72", 5555), timeout=5)
        self.sock.settimeout(15)
        self.stream = self.sock.makefile("rb")

    def write(self, command):
        if "\n" in command or ";" in command:
            raise ValueError("Expected one SCPI command")
        self.log.append({"utc": utc(), "command": command})
        self.sock.sendall((command + "\n").encode("ascii"))

    def query(self, command):
        self.write(command)
        for _ in range(4):
            line = self.stream.readline(100000)
            if not line:
                raise EOFError("Missing scope response")
            if line.strip():
                value = line.decode("ascii").strip()
                self.log[-1]["response"] = value
                return value
        raise ValueError("Missing nonempty scope response")

    def binary(self, command):
        self.write(command)
        result = read_block(self.stream)
        self.log[-1]["payload_bytes"] = len(result)
        return result

    def close(self):
        (ROOT / f"cycle-scope-{self.phase}-commands.json").write_text(
            json.dumps(self.log, indent=2) + "\n")
        self.stream.close()
        self.sock.close()


def restore(scope):
    saved = json.loads((ROOT / "pre-cycle-scope-settings.json").read_text())["settings"]
    for setter, key in ((":WAV:MODE", ":WAV:MODE?"),
                        (":WAV:FORM", ":WAV:FORM?"),
                        (":WAV:SOUR", ":WAV:SOUR?"),
                        (":WAV:STAR", ":WAV:STAR?"),
                        (":WAV:STOP", ":WAV:STOP?"),
                        (":TIM:MAIN:SCAL", ":TIM:MAIN:SCAL?"),
                        (":TIM:MAIN:OFFS", ":TIM:MAIN:OFFS?"),
                        (":TRIG:MODE", ":TRIG:MODE?"),
                        (":TRIG:EDGE:SOUR", ":TRIG:EDGE:SOUR?"),
                        (":TRIG:EDGE:SLOP", ":TRIG:EDGE:SLOP?"),
                        (":TRIG:EDGE:LEV", ":TRIG:EDGE:LEV?")):
        scope.write(setter + " " + saved[key])
    scope.write(":TRIG:SWE " + saved[":TRIG:EDGE:SWE?"])
    if saved[":TRIG:STAT?"] != "STOP":
        scope.write(":RUN")


def main(phase):
    scope = Scope(phase)
    try:
        if phase == "arm":
            scope.write(":TIM:MAIN:SCAL 1")
            scope.write(":TIM:MAIN:OFFS 4.8")
            scope.write(":TRIG:MODE EDGE")
            scope.write(":TRIG:EDGE:SOUR CHAN2")
            scope.write(":TRIG:EDGE:SLOP POS")
            scope.write(":TRIG:EDGE:LEV 1.65")
            scope.write(":SING")
            deadline = time.monotonic() + 25
            while scope.query(":TRIG:STAT?") != "WAIT":
                if time.monotonic() > deadline:
                    restore(scope)
                    raise TimeoutError("Scope did not finish filling its pretrigger buffer")
                time.sleep(0.5)
            scope.write(":TFOR")
            state = scope.query(":TRIG:STAT?")
            if state not in ("TD", "STOP"):
                restore(scope)
                raise RuntimeError(f"Forced trigger was not accepted: {state}")
            print("Forced capture trigger at", utc(), flush=True)
        elif phase == "read":
            deadline = time.monotonic() + 25
            while scope.query(":TRIG:STAT?") != "STOP":
                if time.monotonic() > deadline:
                    raise TimeoutError("Capture did not complete")
                time.sleep(1)
            png = scope.binary(":DISP:DATA? ON,OFF,PNG")
            assert png.startswith(b"\x89PNG\r\n\x1a\n")
            (ROOT / "cycle-scope.png").write_bytes(png)
            for channel in range(1, 5):
                scope.write(f":WAV:SOUR CHAN{channel}")
                scope.write(":WAV:MODE RAW")
                scope.write(":WAV:FORM BYTE")
                preamble = scope.query(":WAV:PRE?")
                fields = [float(x) for x in preamble.replace(";", ",").split(",")]
                assert len(fields) == 10 and fields[0] == 0 and fields[1] == 2
                count = int(fields[2])
                assert 1200 <= count <= 24_000_000 and fields[4] > 0
                stem = ROOT / f"cycle-CH{channel}"
                stem.with_suffix(".json").write_text(json.dumps(
                    {"utc": utc(), "channel": channel, "preamble": preamble,
                     "fields": fields, "points": count}, indent=2) + "\n")
                with stem.with_suffix(".bin").open("wb") as output:
                    for start in range(1, count + 1, 250000):
                        stop = min(start + 249999, count)
                        scope.write(f":WAV:STAR {start}")
                        scope.write(f":WAV:STOP {stop}")
                        block = scope.binary(":WAV:DATA?")
                        assert len(block) == stop - start + 1
                        output.write(block)
                assert stem.with_suffix(".bin").stat().st_size == count
                print("Saved CH", channel, count, "points; dt", fields[4], flush=True)
        elif phase != "restore":
            raise ValueError("Expected arm, read, restore or self-test")
    finally:
        try:
            if phase in ("read", "restore"):
                restore(scope)
        finally:
            scope.close()


if __name__ == "__main__":
    if sys.argv[1:] == ["self-test"]:
        assert read_block(io.BytesIO(b"#13abc\n")) == b"abc"
        assert read_block(io.BytesIO(b"\r\n#2100123456789")) == b"0123456789"
        for payload in (b"", b"bad", b"#0", b"#15abc"):
            try:
                read_block(io.BytesIO(payload))
            except (ValueError, EOFError):
                pass
            else:
                raise AssertionError("Invalid/truncated block accepted")
        print("Binary-block validation self-checks passed")
    else:
        main(sys.argv[1])
