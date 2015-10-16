
process = require 'process'
child_process = require 'child_process'

oboe = require 'oboe'

proto = require './i3bar-proto'

p = proto()

c = child_process.spawn 'bash', ['-c', 'i3status -c ~/.i3/status']

o = oboe(c.stdout)

o.node('{version}', ->
  @forget()
  o.node('![*]', (e) -> p.send(e...))
  oboe.drop)
