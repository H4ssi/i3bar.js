
child = require 'child_process'

oboe = require 'oboe'

proto = require './i3bar-proto'

sig = require 'get-signal'
EventEmitter = require 'events'

class Client extends EventEmitter
  constructor: (cmd_line) ->
    @process = child.spawn 'bash', ['-c', cmd_line]

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

  stop: -> process.kill @process.pid, @stop_signal
  cont: -> process.kill @process.pid, @cont_signal

class NodeClient extends EventEmitter
  constructor: (clientModule) ->
    clientModule = require clientModule

    @client = clientModule({cb: (msgs) => @emit 'msg', msgs...})

    @version = @client.header.version
    @click_events = !!@client.header.click_events

    process.nextTick => @emit 'ready'

  click: (event) -> @client.click event

  stop: -> @client.stop
  cont: -> @client.cont

clients = [(new NodeClient __dirname + '/click_example'), (new NodeClient __dirname + '/clock'), (new Client 'i3status -c ~/.i3/status')]

p = null

cache = []
pending = false
send = ->
  if p == null
    setImmediate -> send()
  else if not pending
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
      cache[i] = msgs
      send()

start = ->
  version = Math.max (c.version for c in clients)...
  click_events = clients.some (c) -> c.click_events

  p = proto({version: version, click_events: click_events})

  p.on 'stop', -> c.stop() for c in clients
  p.on 'cont', -> c.cont() for c in clients
  p.on 'click', (e) -> c.click e for c in clients

