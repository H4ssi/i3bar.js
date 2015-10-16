
process = require 'process'
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

    processData = (boxes) =>
      @emit('msg', boxes...)

    o = oboe(@process.stdout)
    o.node('{version}', (header) ->
      @forget()
      processHeader(header)
      o.node('![*]', processData)
      oboe.drop)

  click: (event) -> @process.stdin.write JSON.stringify(event) + ',' if @click_events

  stop: () -> process.kill @process.pid, @stop_signal
  cont: () -> process.kill @process.pid, @cont_signal

c = new Client 'i3status -c ~/.i3/status'

p = proto({version: c.version, click_events: c.click_events})

p.on 'stop', -> c.stop()
p.on 'cont', -> c.cont()
p.on 'click', (e) -> c.click(e)
c.on 'msg', (boxes...) -> p.send(boxes...)
