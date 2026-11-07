"""One requested DMD UI cycle; no retries and no direct device-node operations."""
import json
from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET

from capture_scope import Scope, restore, utc

ROOT = Path(__file__).resolve().parent
ADB = '/Users/rambo/Library/Android/sdk/platform-tools/adb'
events = []


def adb(*args):
    return subprocess.check_output([ADB, '-d', *args], timeout=20)


def event(name, **fields):
    events.append({'utc': utc(), 'event': name, **fields})
    (ROOT / 'events.json').write_text(json.dumps(events, indent=2) + '\n')


def switch(name):
    remote = '/data/local/tmp/portprobe-cycle-ui.xml'
    adb('shell', 'uiautomator', 'dump', remote)
    data = adb('exec-out', 'cat', remote)
    (ROOT / (name + '-ui.xml')).write_bytes(data)
    nodes = [n for n in ET.fromstring(data).iter('node')
             if n.get('resource-id', '').endswith('/switchLoraEnabled')]
    assert len(nodes) == 1, 'LoRa switch missing or ambiguous'
    node = nodes[0]
    bounds = list(map(int, re.findall(r'\d+', node.get('bounds'))))
    assert len(bounds) == 4 and node.get('checked') in ('true', 'false')
    return node.get('checked') == 'true', ((bounds[0]+bounds[2])//2,
                                           (bounds[1]+bounds[3])//2)


def tap(point):
    adb('shell', 'input', 'tap', *map(str, point))


def main():
    logger = None
    enabled = False
    try:
        policy = adb('shell', 'dumpsys', 'window', 'policy').decode()
        assert 'showing=false' in policy, 'Tablet locked; no cycle attempted'
        adb('shell', 'am', 'start', '-n', 'com.thorkracing.dmdLora/.StatusActivity')
        state, point = switch('original')
        assert not state, 'Original state is not OFF; abort without toggling'
        event('original_switch_readback', checked=state)
        log = (ROOT / 'lora-logcat.txt').open('wb')
        logger = subprocess.Popen([ADB, '-d', 'logcat', '-v', 'epoch', '-T', '1'], stdout=log, stderr=subprocess.STDOUT)
        subprocess.run(['python3', str(ROOT / 'capture_scope.py'), 'arm'], check=True, timeout=35)
        event('scope_trigger_confirmed_TD')
        event('tap_enable_begin')
        enabled = True
        tap(point)
        event('tap_enable_end')
        state, _ = switch('enabled')
        event('enabled_view_readback', checked=state)
        scope = Scope('wait')
        try:
            deadline = time.monotonic() + 25
            while scope.query(':TRIG:STAT?') != 'STOP':
                if time.monotonic() > deadline:
                    raise TimeoutError('Scope did not stop')
                time.sleep(0.5)
            event('scope_capture_stopped')
        finally:
            scope.close()
        state, point = switch('before-restore')
        if state:
            event('tap_restore_off_begin')
            tap(point)
        state, _ = switch('restored')
        assert not state, 'OFF restoration failed'
        enabled = False
        event('restored_state_readback', checked=state)
        subprocess.run(['python3', str(ROOT / 'capture_scope.py'), 'read'], check=True, timeout=100)
        event('waveforms_saved_and_scope_restored')
    finally:
        if enabled:
            state, point = switch('failure-restore')
            if state:
                tap(point)
            state, _ = switch('failure-restored')
            assert not state, 'Failed to restore LoRa OFF'
        try:
            scope = Scope('final-restore')
            try:
                restore(scope)
            finally:
                scope.close()
        finally:
            adb('shell', 'settings', 'put', 'global', 'stay_on_while_plugged_in', '0')
            adb('shell', 'input', 'keyevent', 'KEYCODE_HOME')
            event('display_setting_restored', value='0')
            if logger:
                logger.terminate()
                logger.wait(timeout=10)
                log.close()


if __name__ == '__main__':
    main()
