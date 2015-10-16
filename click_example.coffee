
proto = require './i3bar-proto'

p = proto {click_events: true}

text = (t) -> {full_text: t}

def = text 'x'

p.on 'click', (e) ->
  p.send (text JSON.stringify(e)), def
  setTimeout (-> p.send def), 1000

p.send def
