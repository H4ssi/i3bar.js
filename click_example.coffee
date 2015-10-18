
proto = require './i3bar-proto'

module.exports = exports = (options = {}) ->
  o =
    click_events: true
  o.output = options.output if options.output?
  o.input = options.input if options.input?

  p = proto o

  text = (t) -> {full_text: t}

  def = text 'x'

  p.on 'click', (e) ->
    p.send (text JSON.stringify e), def
    setTimeout (-> p.send def), 1000

  p.send def

exports() if require.main == module
