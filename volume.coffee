bar = require './i3bar-proto'
ipc = require './i3-proto'
ui = require './ui'

child = require 'child_process'

volumeRx = /Volume:.*?((\d+\.)?\d+)%/

parseVolume = (input) ->
  res = volumeRx.exec input
  if res?
    parseFloat res[1]
  else
    0

muteRx = /Mute: (yes|no)/

parseMute = (input) ->
  res = muteRx.exec input
  if res?
    return res[1] == 'yes'
  else
    false

volumeChange = (plusOrMinus) ->
  ['set-sink-volume', '0', plusOrMinus + '5%']

run = (args, cb) ->
  alter = child.spawn 'pactl', args
  alter.on 'exit', ->
    read = child.execFile 'pactl', ['list', 'sinks'], (err, stdout) ->
      cb
        volume: parseVolume stdout
        mute: parseMute stdout

module.exports = exports = (options = {}) ->
  b = bar options

  i = ipc -> i.send 'SUBSCRIBE', JSON.stringify ['binding']

  clearTimeoutId = null
  clear = -> b.send()

  display = (data) ->
    {volume: percent, mute} = data
    bar = ui.bar 10, percent

    bar = '(' + bar + ')' if mute

    b.send {full_text: bar}

    clearTimeout clearTimeoutId if clearTimeoutId?
    clearTimeoutId = setTimeout clear, 1000

  i.on 'binding', (d) ->
    d = JSON.parse d

    if d.binding?.command?
      com = d.binding.command

      if com == 'nop i3barjs volume up'
        run (volumeChange '+'), display
      else if com == 'nop i3barjs volume down'
        run (volumeChange '-'), display
      else if com == 'nop i3barjs volume toggle'
        run ['set-sink-mute', '0', 'toggle'], display

  b

exports() if require.main == module
