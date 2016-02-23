_ = require 'lodash'

exports.bar = (maxWidth, percent) ->
  width = Math.round percent / 100 * maxWidth
  (_.repeat ' ', maxWidth - width) + (_.repeat '#', width)