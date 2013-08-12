Path = require 'path'

exports.isPartial = (path) ->
  /^_/.test Path.basename(path)

exports.isAbsolutePath = (path) ->
  (new RegExp "^#{Path.sep}").test path