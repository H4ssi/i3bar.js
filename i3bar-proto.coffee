
EventEmitter = require 'events'
sig = require 'get-signal'
oboe = require 'oboe'

module.exports = (options = {}) ->
  header =
    version: options.version ? 1
    stop_signal: sig.getSignalNumber('SIGUSR2') # SIGSTOP (default) cannot be used in node
  header.stop_signal = options.stop_signal if options.stop_signal?
  header.cont_signal = options.cont_signal if options.cont_signal?
  header.click_events = options.click_events if options.click_events?

  e = new EventEmitter()

  output = options.output ? process.stdout
  output.write JSON.stringify(header) + '['

  e.send = (msg...) -> output.write JSON.stringify(msg) + ','

  stop_signal = sig.getSignalName(header.stop_signal)
  process.on(stop_signal, -> e.emit('stop'))

  cont_signal = if header.cont_signal? then sig.getSignalName(header.cont_signal) else 'SIGCONT'
  process.on(cont_signal, -> e.emit('cont'))

  if header.click_events
    input = options.input ? process.stdin

    o = oboe(input)

    o.node '![*]', (click) -> e.emit('click', click)

  e

