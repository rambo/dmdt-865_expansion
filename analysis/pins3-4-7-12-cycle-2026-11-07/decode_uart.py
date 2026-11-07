"""Decoder used on CH4; DMD capture contains a different six-byte frame."""
import json
from pathlib import Path
import sys


def decode(data, dt, threshold_code, baud=9600):
    levels = bytes(v > threshold_code for v in data)
    samples_per_bit = 1 / (baud * dt)
    assert samples_per_bit >= 8
    result = []
    errors = 0
    i = 1
    while i + 10 * samples_per_bit < len(levels):
        if levels[i - 1] and not levels[i]:
            if levels[round(i + 0.5 * samples_per_bit)]:
                i += 1
                continue
            if not levels[round(i + 9.5 * samples_per_bit)]:
                errors += 1
                i += 1
                continue
            value = sum(levels[round(i + (1.5 + bit) * samples_per_bit)] << bit
                        for bit in range(8))
            result.append((i, value))
            i += int(9.5 * samples_per_bit) + 1
        else:
            i += 1
    return result, errors


def self_test():
    payload = b'UUUU T865 UART WK2\r\n'
    bits = [1] * 5
    for value in payload:
        bits += [0] + [(value >> bit) & 1 for bit in range(8)] + [1]
    bits += [1] * 5
    dt = 4e-6
    synthetic = bytes(bits[min(int(i * dt * 9600), len(bits)-1)] * 200
                      for i in range(int(len(bits) / (dt * 9600))))
    decoded, errors = decode(synthetic, dt, 100)
    assert bytes(v for _, v in decoded) == payload and errors == 0


if __name__ == '__main__':
    self_test()
    if sys.argv[1:] == ['self-test']:
        print('PASS: synthetic 9600/8N1 UART decoding')
    else:
        root = Path(__file__).resolve().parent
        f = json.loads((root / 'cycle-CH4.json').read_text())['fields']
        data = (root / 'cycle-CH4.bin').read_bytes()
        assert len(data) == f[2] and f[0] == 0 and f[1] == 2
        decoded, errors = decode(data, f[4], 1.2 / f[7] + f[8] + f[9])
        groups = []
        for i, value in decoded:
            t = (i - f[6]) * f[4] + f[5]
            if not groups or t - groups[-1]['last_byte_start_s'] > 0.02:
                groups.append({'first_byte_start_s': t, 'last_byte_start_s': t, 'bytes': []})
            groups[-1]['last_byte_start_s'] = t
            groups[-1]['bytes'].append(value)
        for group in groups:
            values = bytes(group.pop('bytes'))
            group['ascii'] = values.decode('ascii', errors='backslashreplace')
            group['hex'] = values.hex(' ')
            group['matches_sent_frame'] = values == b'UUUU T865 UART WK2\r\n'
        report = {'channel': 'CH4', 'pin': 12, 'ground_pin': 1, 'baud': 9600,
                  'format': '8N1 LSB first, noninverted', 'threshold_V': 1.2,
                  'framing_errors': errors, 'decoded_bytes': len(decoded), 'bursts': groups}
        assert bytes(v for _, v in decoded) == bytes.fromhex('c0 c1 c2 c3 02 03') and errors == 0, report
        (root / 'uart-decode.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(report, indent=2))
