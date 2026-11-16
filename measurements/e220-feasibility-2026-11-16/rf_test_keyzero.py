#!/usr/bin/env python3
"""Receive-only E220 vs two official Meshtastic radios. Restores both peers.
Requires meshtastic==2.7.11, pyserial==3.5. Run only on the documented bench.
"""
import json,pathlib,queue,subprocess,threading,time,sys,traceback
from meshtastic.serial_interface import SerialInterface
from meshtastic.protobuf import config_pb2,portnums_pb2
from pubsub import pub
from google.protobuf.json_format import MessageToDict
ROOT=pathlib.Path(__file__).resolve().parent
ADB='/Users/rambo/Library/Android/sdk/platform-tools/adb'
PORTS=['/dev/cu.usbserial-595D0026461','/dev/cu.usbserial-595D0012511']
BASEFILES=['peer-lora-original.pb','peer2-lora-original.pb']
PROFILES=[('ShortFast',250,7),('ShortSlow',250,8),('MediumFast',250,9),('MediumSlow',250,10),('CustomSF9BW125',125,9),('CustomSF8BW125',125,8),('CustomSF7BW125',125,7)]
log=open(ROOT/'rf2-experiment.jsonl','w',buffering=1)
def record(kind,**kwargs):
 row={'kind':kind,'utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),**kwargs}
 log.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
originals=[]
for file in BASEFILES:
 c=config_pb2.Config.LoRaConfig();c.ParseFromString((ROOT/file).read_bytes());originals.append(c)

def connect(port):return SerialInterface(devPath=port,noNodes=True,timeout=15)
def configure(index,target):
 port=PORTS[index]
 i=connect(port)
 i.localNode.localConfig.lora.CopyFrom(target)
 i.localNode.writeConfig('lora')
 time.sleep(.5);i.close();time.sleep(3)
 i=connect(port)
 actual=i.localNode.localConfig.lora
 if actual.SerializeToString()!=target.SerializeToString():
  record('config_mismatch',port=port,actual=MessageToDict(actual,preserving_proto_field_name=True),expected=MessageToDict(target,preserving_proto_field_name=True))
  i.close();raise RuntimeError('Peer config readback mismatch')
 record('peer_config_verified',port=port,lora=MessageToDict(actual,preserving_proto_field_name=True))
 return i

class Tablet:
 def __init__(self):
  self.q=queue.Queue();self.rows=[]
  self.file=open(ROOT/'rf2-tablet-uart.jsonl','w',buffering=1)
  self.p=subprocess.Popen([ADB,'-d','shell','/data/local/tmp/e220-probe','--power-on'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,bufsize=1)
  def reader():
   try:
    for line in self.p.stdout:
     self.file.write(line);row=json.loads(line);self.rows.append(row);self.q.put(row)
   finally:self.q.put({'kind':'eof'})
  threading.Thread(target=reader,daemon=True).start()
  self.wait_until('open',None,8)
 def wait_until(self,kind,label,timeout):
  end=time.monotonic()+timeout;rx=b''
  while time.monotonic()<end:
   r=self.q.get(timeout=max(.1,end-time.monotonic()))
   if r['kind']=='error' or r['kind']=='eof':raise RuntimeError(str(r))
   if r['kind']=='rx' and (label is None or r['label']==label):rx+=bytes.fromhex(r['hex'])
   if r['kind']==kind and (label is None or r.get('label')==label):return rx
  raise TimeoutError(label)
 def write_line(self,line):self.p.stdin.write(line+'\n');self.p.stdin.flush()
 def tx(self,label,b,wait=250):
  self.write_line(f'TX {label} {b.hex()} {wait}')
  return self.wait_until('rx_end',label,wait/1000+3)
 def mode(self,value):
  command=bytes.fromhex('c0c1c2c302')+bytes([value]);actual=self.tx('mode',command)
  if actual!=command:raise RuntimeError('E220 mode did not acknowledge '+actual.hex())
 def rate(self,rate):
  self.mode(3)
  expected=bytes([0x60|rate]);reply=self.tx('set_rate',bytes([0xc2,2,1])+expected)
  if reply!=bytes([0xc1,2,1])+expected:raise RuntimeError('temporary write not acknowledged '+reply.hex())
  reply=self.tx('read_rate',bytes([0xc1,2,1]))
  if reply!=bytes([0xc1,2,1])+expected:raise RuntimeError('temporary rate readback failed '+reply.hex())
  self.mode(0)
 def listen_start(self,ms):self.write_line('WAIT '+str(ms))
 def listen_end(self,ms):return self.wait_until('rx_end','wait',ms/1000+3)
 def close(self):
  try:
   self.mode(3)
   reply=self.tx('restore_rate',bytes.fromhex('c2020162'))
   self.mode(0)
   record('e220_volatile_rate_restored',reply_hex=reply.hex())
  finally:
   self.p.stdin.close();self.p.wait(timeout=8);self.file.close()
   if self.p.returncode:raise RuntimeError('Tablet cleanup failed')

received=[];receiver=None

def on_receive(packet,interface):
 if interface is receiver:
  raw=packet.get('raw');received.append({'id':packet.get('id'),'from':packet.get('from'),'rssi':getattr(raw,'rx_rssi',None),'snr':getattr(raw,'rx_snr',None),'port':packet.get('decoded',{}).get('portnum')})
pub.subscribe(on_receive,'meshtastic.receive')
interfaces=[];tablet=None;results=[];dirty=[False,False]
try:
 tablet=Tablet();tablet.mode(3)
 record('e220_initial_registers',hex=tablet.tx('baseline',bytes.fromhex('c10009')).hex())
 key_reply=tablet.tx('temporary_zero_key',bytes.fromhex('c206020000'))
 if key_reply!=bytes.fromhex('c106020000'):raise RuntimeError('Temporary zero-key command not acknowledged')
 record('temporary_zero_key_accepted',persistent_write=False,reply_hex=key_reply.hex())
 for label,bw,sf in PROFILES:
  record('profile_start',profile=label,bw_khz=bw,sf=sf,cr=5,frequency_mhz=868.125,tx_power_dbm=13)
  for i in interfaces:i.close()
  interfaces=[];receiver=None
  targets=[]
  for index in range(2):
   c=config_pb2.Config.LoRaConfig();c.CopyFrom(originals[index]);c.use_preset=False
   c.modem_preset=config_pb2.Config.LoRaConfig.SHORT_FAST
   c.bandwidth=bw;c.spread_factor=sf;c.coding_rate=5;c.override_frequency=868.125;c.tx_power=13;c.tx_enabled=True
   targets.append(c);dirty[index]=True;interfaces.append(configure(index,c))
  sender,receiver=interfaces
  if sender.localNode.channels[0].settings.psk!=receiver.localNode.channels[0].settings.psk:raise RuntimeError('Positive-control primary channel keys differ')
  for rate in range(2,8):
   tablet.rate(rate)
   before=len(received)
   token=f'E220_ZERO_KEY_{label}_RATE{rate}'.encode()
   samples=[];baseline_rssi=None
   if label=='CustomSF9BW125' and rate==2:
    baseline_rssi=tablet.tx('ambient_before',bytes.fromhex('c0c1c2c30002'),120).hex()
    packet=sender.sendData(token.ljust(200,b'.'),portNum=portnums_pb2.PRIVATE_APP,hopLimit=0,wantAck=False)
    rx=b''
    for j in range(14):
     data=tablet.tx('ambient_during',bytes.fromhex('c0c1c2c30002'),120)
     samples.append(data.hex())
     if len(data)==5 and data[:3]==bytes.fromhex('c10002'):continue
     rx+=data
    tablet.listen_start(400);rx+=tablet.listen_end(400)
   else:
    tablet.listen_start(2200)
    packet=sender.sendData(token,portNum=portnums_pb2.PRIVATE_APP,hopLimit=0,wantAck=False)
    rx=tablet.listen_end(2200)
   matched=[r for r in received[before:] if r['id']==packet.id and r['from']==sender.myInfo.my_node_num]
   result={'profile':label,'e220_rate_index':rate,'packet_id':packet.id,'control_received':bool(matched),'control_packets':matched,'e220_rx_hex':rx.hex()}
   if samples:result.update(ambient_before_hex=baseline_rssi,ambient_during_hex=samples)
   results.append(result);record('trial',**result)
  good=sum(r['control_received'] for r in results if r['profile']==label)
  if good<4:raise RuntimeError(f'Positive control too weak for {label}: {good}/6')
 record('complete',trials=len(results),positive_control=sum(r['control_received'] for r in results),e220_packets=sum(bool(r['e220_rx_hex']) for r in results))
except BaseException as e:
 record('failure',error=str(e));traceback.print_exc();raise
finally:
 if tablet:
  try:tablet.close()
  except BaseException as e:record('tablet_restore_error',error=str(e))
 for i in interfaces:
  try:i.close()
  except BaseException:pass
 receiver=None
 for index in range(2):
  if dirty[index]:
   try:
    restored=configure(index,originals[index]);restored.close();record('peer_restored',port=PORTS[index])
   except BaseException as e:record('peer_restore_error',port=PORTS[index],error=str(e))
 (ROOT/'rf2-results.json').write_text(json.dumps(results,indent=2)+'\n')
 log.close()
