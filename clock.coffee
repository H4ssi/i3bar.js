
proto = require './i3bar-proto'
moment = require 'moment'

module.exports = exports = (options = {}) ->
  p = proto options

  time = () ->
    now = moment()
    p.send {full_text: now.format 'HH:mm'}

    next = moment now
    (next.startOf 'minute').add 1, 'minutes'
    setTimeout time, (next.diff now)

  process.nextTick time

  p

exports() if require.main == module
