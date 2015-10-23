
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

  i.on 'binding', (d) ->
    d = JSON.parse d

    if d.binding?.command?
      com = d.binding.command

      if com == 'exec true i3barjs brightness up'
        run '-inc', console.log.bind console
      else if com == 'exec true i3barjs brightness down'
        run '-dec', console.log.bind console

exports() if module.main = module
