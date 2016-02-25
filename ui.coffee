_ = require 'lodash'

exports.bar = (maxWidth, percent, active = true) ->
  width = Math.round percent / 100 * maxWidth
  (_.repeat '\u2581', maxWidth - width) + (_.repeat (if active then '\u2588' else '\u2591'), width)