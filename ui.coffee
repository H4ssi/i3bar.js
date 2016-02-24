_ = require 'lodash'

wrap = (active, bar) ->
  if active
    bar
  else
    "(" + bar + ")"

exports.bar = (maxWidth, percent, active = true) ->
  width = Math.round percent / 100 * maxWidth
  wrap active, (_.repeat ' ', maxWidth - width) + (_.repeat '#', width)