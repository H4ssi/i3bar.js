_ = require 'lodash'
bar = require './i3bar-proto'
ipc = require './i3-proto'

child = require 'child_process'

volumeRx = /Volume:.*?((\d+\.)?\d+)%/

parseVolume = (input) ->
  res = volumeRx.exec input
  if res?
    parseFloat res[1]
  else
    0

run = (plusOrMinus, cb) ->
  alter = child.spawn 'pactl', ['set-sink-volume', '0', plusOrMinus + '5%']
  alter.on 'exit', ->
    read = child.execFile 'pactl', ['list', 'sinks'], (err, stdout) ->
      cb parseVolume stdout

module.exports = exports = (options = {}) ->
  b = bar options

  i = ipc -> i.send 'SUBSCRIBE', JSON.stringify ['binding']

  clearTimeoutId = null
  clear = -> b.send()

  display = (percent) ->
    max = 10
    dots = Math.round percent / 100 * max

    bar = (_.repeat ' ', max - dots) + (_.repeat '#', dots)

    b.send {full_text: bar}

    clearTimeout clearTimeoutId if clearTimeoutId?
    clearTimeoutId = setTimeout clear, 1000

  i.on 'binding', (d) ->
    d = JSON.parse d

    if d.binding?.command?
      com = d.binding.command

      if com == 'nop i3barjs volume up'
        run '+', display
      else if com == 'nop i3barjs volume down'
        run '-', display

  b

exports() if require.main == module
