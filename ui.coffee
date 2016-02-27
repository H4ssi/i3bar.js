_ = require 'lodash'

exports.bar = (maxWidth, percent, active = true) ->
  fillChar = if active then '\u2588' else '\u2591'
  full = ''
  width = Math.round percent / 100 * maxWidth
  avail = maxWidth - width
  if percent > 100
     width -= maxWidth
     full = '\u250a' + (_.repeat fillChar, maxWidth)
     avail = 0
  (_.repeat '\u2581', avail) + (_.repeat fillChar, width) + full