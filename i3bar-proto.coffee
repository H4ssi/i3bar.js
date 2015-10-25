
_ = require 'lodash'
EventEmitter = require 'events'
sig = require 'get-signal'
oboe = require 'oboe'

module.exports = (options = {}, connectListener = null) ->
  if _.isFunction options
    connectListener = options
    options = {}

  header =
    version: options.version ? 1
  header.click_events = !!options.click_events if options.click_events?

  e = new EventEmitter()
  e.header = header
  e.stop = -> e.emit 'stop'
  e.cont = -> e.emit 'cont'
  e.click = (event) -> e.emit 'click', event

  e.once 'connect', connectListener if connectListener?

  if options.cb? # callback given, use js as interface
    e.send = (msg...) -> options.cb msg
  else # no callback given, this is a regular process
    stop_signal = options.stop_signal ? 'SIGUSR2' # SIGSTOP (default) cannot be used in node
    cont_signal = options.cont_signal ? 'SIGCONT'

    process.on stop_signal, e.stop.bind e
    process.on cont_signal, e.cont.bind e

    # i3bar needs signal numbers, not names
    header.stop_signal = sig.getSignalNumber stop_signal unless stop_signal == 'SIGSTOP'
    header.cont_signal = sig.getSignalNumber cont_signal unless cont_signal == 'SIGCONT'

    output = options.output ? process.stdout
    output.write (JSON.stringify header) + '['

    e.send = (msg...) -> output.write (JSON.stringify msg) + ','

    if header.click_events
      input = options.input ? process.stdin

      o = oboe input

      o.node '![*]', e.click.bind e

  process.nextTick -> e.emit 'connect'
  e

