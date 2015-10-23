
os = require 'os'
net = require 'net'
child = require 'child_process'
EventEmitter = require 'events'

spawnChild = ->
  child.execFile 'i3', ['--get-socketpath'], (err, stdout, stderr) -> connectToSocket stdout.trim()

writeInt = if os.endianness() == 'LE' then (b, v, o) -> b.writeUInt32LE v,o else (b, v, o) -> b.writeUInt32BE v,o
readInt = if os.endianness() == 'LE' then (b, o) -> b.readUInt32LE o else (b, o) -> b.readUInt32BE o

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

requests =
  COMMAND: 0
  GET_WORKSPACES: 1
  SUBSCRIBE: 2
  GET_OUTPUTS: 3
  GET_TREE: 4
  GET_MARKS: 5
  GET_BAR_CONFIG: 6
  GET_VERSION: 7

responses =
  0: "COMMAND"
  1: "WORKSPACES"
  2: "SUBSCRIBE"
  3: "OUTPUTS"
  4: "TREE"
  5: "MARKS"
  6: "BAR_CONFIG"
  7: "VERSION"
  0x80000000: "workspace"
  0x80000001: "output"
  0x80000002: "mode"
  0x80000003: "window"
  0x80000004: "barconfig_update"
  0x80000005: "binding"

isEvent = (type) -> (0x80000000 & type) != 0

e = new EventEmitter()

connectToSocket = (path) ->
  socket = net.connect path, -> e.emit 'connected'

  socket.on 'data', (d) ->
    reply = unpack d
    typeName = responses[reply.type]
    event = typeName
    unless event?
      event = if isEvent reply.type then 'unknownEvent' + (0x80000000 ^ reply.type) else 'UNKNOWN_REPLY' + reply.type
      console.warn 'unknown reply type: ' + d.type + ' binding to "' + event + '"'
    e.emit event, reply.payload, reply.type

  e.send = (msgType, payload = '') ->
    type = requests[msgType]

    unless type?
      console.warn 'unknown msg type: ' + msgType + '... it will be used directly!'
      type = msgType

    socket.write (pack type, payload)

module.exports = exports = (connectListener = null) ->
  e.once 'connected', connectListener if connectListener?
  spawnChild()
  e
