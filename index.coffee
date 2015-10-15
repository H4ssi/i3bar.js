
process = require 'process'
child_process = require 'child_process'

oboe = require 'oboe'

process.stdout.write '{"version":1,"click_events":true}['

c = child_process.spawn 'bash', ['-c', 'i3status -c ~/.i3/status']

o = oboe(c.stdout)

o.node('{version}', ->
  @forget()
  o.node('![*]', (e) -> process.stdout.write(JSON.stringify(e) + ','))
  oboe.drop)
