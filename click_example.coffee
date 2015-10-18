
proto = require './i3bar-proto'

module.exports = exports = (options = {}) ->
  options.click_events = true

  p = proto options

  text = (t) -> {full_text: t}

  def = text 'x'

  p.on 'click', (e) ->
    p.send (text JSON.stringify e), def
    setTimeout (-> p.send def), 1000

  process.nextTick -> p.send def

  p

exports() if require.main == module
