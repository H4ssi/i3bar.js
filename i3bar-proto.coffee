
EventEmitter = require 'events'
sig = require 'get-signal'
oboe = require 'oboe'

module.exports = (options = {}) ->
  header =
    version: options.version ? 1
    stop_signal: 'SIGUSR2' # SIGSTOP (default) cannot be used in node
  header.stop_signal = options.stop_signal if options.stop_signal?
  header.cont_signal = options.cont_signal if options.cont_signal?
  header.click_events = options.click_events if options.click_events?

  e = new EventEmitter()
  e.stop = -> e.emit 'stop'
  e.cont = -> e.emit 'cont'

  if options.signals ? true
    stop_signal = header.stop_signal
    cont_signal = header.cont_signal ? 'SIGCONT'

    process.on stop_signal, e.stop.bind e
    process.on cont_signal, e.cont.bind e

  # i3bar needs signal numbers, not names
  header.stop_signal = sig.getSignalNumber header.stop_signal
  header.cont_signal = sig.getSignalNumber header.cont_signal if header.cont_signal?

  output = options.output ? process.stdout
  output.write JSON.stringify(header) + '['

  e.send = (msg...) -> output.write JSON.stringify(msg) + ','

  if header.click_events
    input = options.input ? process.stdin

    o = oboe(input)

    o.node '![*]', (click) -> e.emit('click', click)

  e

