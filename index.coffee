
_ = require 'lodash'

child = require 'child_process'

oboe = require 'oboe'

proto = require './i3bar-proto'

sig = require 'get-signal'
EventEmitter = require 'events'

class Client extends EventEmitter
  constructor: (cmd_line) ->
    @process = child.spawn 'bash', ['-c', 'exec ' + cmd_line], {detached: true, stdio: ['pipe', 'pipe', process.stderr]}

    processHeader = (header) =>
      @version = header.version
      @stop_signal = if header.stop_signal? then sig.getSignalName(header.stop_signal) else 'SIGSTOP'
      @cont_signal = if header.cont_signal? then sig.getSignalName(header.cont_signal) else 'SIGCONT'
      @click_events = !!header.click_events
      @process.stdin.write '[' if @click_events
      @emit 'ready'

    processData = (boxes) =>
      @emit('msg', boxes...)

    o = oboe @process.stdout

    o.node '{version}', (header) ->
      @forget()
      processHeader header
      oboe.drop

    o.node '![*]', processData

  click: (event) -> @process.stdin.write JSON.stringify(event) + ',' if @click_events

  stop: -> @process.kill @stop_signal
  cont: -> @process.kill @cont_signal

class NodeClient extends EventEmitter
  constructor: (clientModule, exportedFnName = null) ->
    clientModule = require clientModule

    clientFn = if exportedFnName? then clientModule[exportedFnName] else clientModule

    @client = clientFn({cb: (msgs) => @emit 'msg', msgs...})

    @version = @client.header.version
    @click_events = !!@client.header.click_events

    process.nextTick => @emit 'ready'

  click: (event) -> @client.click event

  stop: -> @client.stop
  cont: -> @client.cont

colors =
  primary: "#3366ff"

clients = [
  (new NodeClient __dirname + '/brightness'),
  (new NodeClient __dirname + '/click_example'),
  (new NodeClient __dirname + '/clock', 'time'),
  (new NodeClient __dirname + '/clock', 'date'),
  (new Client 'i3status -c ~/.i3/status')]

cache = []
dirty = false
pending = false

flush = (p) ->
  if not pending
    pending = true
    setImmediate ->
      pending = false
      msgs = [].concat cache...
      p.send msgs...

readyCount = 0
for c, i in clients
  c.on 'ready', ->
    start() if ++readyCount == clients.length
  do (i) ->
    c.on 'msg', (msgs...) ->
      msgs = _.clone msgs, true
      for m in msgs
        m.color = colors[m.color] if m.color? and colors[m.color]?
      cache[i] = msgs
      dirty = true

start = ->
  version = Math.max (c.version for c in clients)...
  click_events = clients.some (c) -> c.click_events

  p = proto({version: version, click_events: click_events})

  p.on 'stop', -> c.stop() for c in clients
  p.on 'cont', -> c.cont() for c in clients
  p.on 'click', (e) -> c.click e for c in clients

  p.on 'connect', ->
    flush p if dirty
    for c in clients
      c.on 'msg', -> flush p

