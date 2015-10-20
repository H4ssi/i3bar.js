
proto = require './i3bar-proto'

module.exports = exports = (options = {}) ->
  p = proto options

  time = () ->
    d = new Date()
    h = d.getHours()
    m = d.getMinutes()
    p.send {full_text: h + ":" + m}

    s = d.getSeconds()
    setTimeout time, (60 - s) * 1000

  process.nextTick time

  p

exports() if require.main == module
