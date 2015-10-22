
os = require 'os'
net = require 'net'

child = require 'child_process'

child.execFile 'i3', ['--get-socketpath'], (err, stdout, stderr) -> start stdout.trim()

writeInt = if os.endianness() == 'LE' then (b, v, o) -> b.writeInt32LE v,o else (b, v, o) -> b.writeInt32BE v,o
readInt = if os.endianness() == 'LE' then (b, o) -> b.readInt32LE o else (b, o) -> b.readInt32BE o

magicString = 'i3-ipc'
magicLen = Buffer.byteLength magicString

msgLen = (payloadLen) -> magicLen + 4 + 4 + payloadLen

pack = (msgType, payload) ->
  payloadLen = Buffer.byteLength payload
  b = new Buffer msgLen payloadLen

  b.write magicString, 0
  writeInt b, payloadLen, 0 + magicLen
  writeInt b, msgType, 0 + magicLen + 4
  b.write payload, 0 + magicLen + 4 + 4

  b

unpack = (b) ->
  len = readInt b, 0 + magicLen
  msgType = readInt b, 0 + magicLen + 4
  {
    type: msgType
    payload: b.toString 'utf8', 0 + magicLen + 4 + 4, 0 + magicLen + 4 + 4 + len
  }

start = (path) ->
  socket = net.connect path , -> socket.write (pack 4, "")


  socket.on 'data', (d) -> console.log unpack d
