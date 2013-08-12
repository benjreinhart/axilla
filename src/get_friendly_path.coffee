Path = require 'path'
{isString} = require 'minutils'
{isPartial} = require './file_utils'

module.exports = (path, options = {}) ->
  {friendlyPath, baseDir} = options

  return friendlyPath if isString friendlyPath

  fp = removeMustacheExtension path

  if isString(baseDir) and baseDir isnt path
    fp = removeBasePath baseDir, fp

  if isPartial fp
    fp = removeUnderscore fp

  if 'function' is typeof friendlyPath
    fp = friendlyPath fp, path

  fp

removeBasePath = (baseDir, path) ->
  path.replace (new RegExp "^#{baseDir}#{Path.sep}"), ''

removeMustacheExtension = (path) ->
  path.replace /\.mustache$/, ''

removeUnderscore = (path) ->
  filename = Path.basename path
  base = filename.replace /^_/, ''

  path.replace (new RegExp "#{filename}$"), base
