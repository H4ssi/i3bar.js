
pr = require './i3-proto'

p = pr ->
  p.send 7
  p.send 'SUBSCRIBE', JSON.stringify ['binding']

p.on 'VERSION', (q) -> console.log q
p.on 'binding', (q) -> console.log q
