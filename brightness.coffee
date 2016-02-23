bar = require './i3bar-proto'
ipc = require './i3-proto'
ui = require './ui'

child = require 'child_process'

run = (decOrInc, cb) ->
  alter = child.spawn 'xbacklight', [decOrInc, '5']
  alter.on 'exit', ->
    read = child.execFile 'xbacklight', ['-get'], (err, stdout) ->
      cb parseFloat stdout

module.exports = exports = (options = {}) ->
  b = bar options

  i = ipc -> i.send 'SUBSCRIBE', JSON.stringify ['binding']

  clearTimeoutId = null
  clear = -> b.send()

  display = (percent) ->

    b.send {full_text: (ui.bar 10, percent)}

    clearTimeout clearTimeoutId if clearTimeoutId?
    clearTimeoutId = setTimeout clear, 1000

  i.on 'binding', (d) ->
    d = JSON.parse d

    if d.binding?.command?
      com = d.binding.command

      if com == 'nop i3barjs brightness up'
        run '-inc', display
      else if com == 'nop i3barjs brightness down'
        run '-dec', display

  b

exports() if require.main == module
