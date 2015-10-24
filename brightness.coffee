_ = require 'lodash'
bar = require './i3bar-proto'
ipc = require './i3-proto'

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
    max = 10
    dots = Math.round percent / 100 * max

    bar = (_.repeat ' ', max - dots) + (_.repeat '#', dots)

    b.send {full_text: bar}

    clearTimeout clearTimeoutId if clearTimeoutId?
    clearTimeoutId = setTimeout clear, 1000

  i.on 'binding', (d) ->
    return if d.startsWith 'undefined:' # sometimes ipc sends 'undefined:1' message?
    d = JSON.parse d

    if d.binding?.command?
      com = d.binding.command

      if com == 'exec true i3barjs brightness up'
        run '-inc', display
      else if com == 'exec true i3barjs brightness down'
        run '-dec', display

  b

exports() if require.main == module
