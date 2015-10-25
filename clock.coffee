
proto = require './i3bar-proto'
moment = require 'moment'

clock = (format, advance) ->
  (options = {}) ->
    time = () ->
      now = moment()
      p.send {full_text: format now}

      next = advance moment now
      setTimeout time, (next.diff now)

    p = proto options, time

exports.time = clock ((m) -> m.format 'HH:mm'), ((m) -> (m.startOf 'minute').add 1, 'minutes')
exports.date = clock ((m) -> m.format 'D.M.YYYY'), ((m) -> (m.startOf 'day').add 1, 'days')

if require.main == module
  if process.argv[2] == 'date'
    exports.date()
  else
    exports.time()
