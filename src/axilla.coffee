fs = require 'fs'
Path = require 'path'
glob = require 'glob'
async = require 'async'
Handlebars = require 'handlebars'

module.exports = axilla = (basePath, defaults) ->
  if (utils.isObject basePath) then defaults = basePath; basePath = null

  (path, viewObject, options) ->
    unless utils.isEmpty basePath
      path = Path.normalize "#{basePath}#{Path.sep}#{path}"

    render path, viewObject, (utils.defaults options, defaults)

axilla.templates = templates = {}
axilla.partials = partials = {}

Handlebars.registerHelper 'partial', (path) ->
  renderPartial path, this

axilla.render = render = (path, viewObject) ->
  unless (template = templates[path])?
    throw new Error "Unable to resolve template at #{path}"

  template.render viewObject

axilla.renderPartial = renderPartial = (path, viewObject) ->
  unless (partial = partials[path])?
    throw new Error "Unable to resolve partial at #{path}"

  partial.render viewObject

axilla.configure = (options, cb) ->
  if utils.isString options
    baseDir = options
    options = {}
  else
    {baseDir} = options

  unless isAbsolutePath baseDir
    throw new Error "Path to baseDir is not an absolute path"

  glob (Path.normalize "#{baseDir}/**/*.mustache"), (err, paths) ->
    iterator = (absolutePath, cb) ->
      relativePath = removeBaseDir baseDir, absolutePath
      base = stripPath relativePath

      options.isPartial = isPartial (Path.basename relativePath)
      cacheTemplate [base, absolutePath], options, cb

    async.each paths, iterator, (err) ->
      return cb err if cb?
      throw err if err?

  null

axilla.clearCache = ->
  axilla.templates = templates = {}
  axilla.partials = partials = {}

cacheTemplate = (paths, options, cb) ->
  [relative, absolute] = paths

  templateCache = if options.isPartial then partials else templates
  templateCache[relative] =
    render: do (shouldReload = (options.cache is off)) ->
      if shouldReload
        (viewObject) -> (readAndCompileSync absolute)(viewObject)
      else
        template = readAndCompileSync absolute
        (viewObject) -> template viewObject

  cb null

readAndCompileSync = (absolutePath) ->
  template = readFileSync absolutePath
  Handlebars.compile template

removeBaseDir = (baseDir, path) ->
  (path.split (new RegExp "^#{baseDir}#{Path.sep}"))[1]

stripPath = (path) ->
  filename = Path.basename path

  base = (filename.split '.')[0]
  base = (base.split /^_/)[1] if isPartial base

  "#{(path.split filename)[0]}#{base}"

isPartial = (filename) ->
  (filename.match /^_/)?

isAbsolutePath = (path) ->
  (path.match (new RegExp "^#{Path.sep}"))?

readFileSync = (path, options={}) ->
  fs.readFileSync path, (utils.defaults options, {encoding: 'utf8'})


#############
# Utilities #
#############

utils = do ->
  {slice} = Array.prototype
  {toString} = Object.prototype

  defaults: (obj) ->
    (slice.call arguments, 1).forEach (source) ->
      for own key of source
        unless obj[key]?
          obj[key] = source[key]
      undefined
    obj

  isArray: Array.isArray

  isObject: (obj) ->
    obj is (Object obj)

  isString: (obj) ->
    (toString.call obj) is '[object String]'

  isEmpty: (obj) ->
    return true unless obj?
    if (utils.isArray obj) or (utils.isString obj)
      return obj.length is 0
    return false for own key of obj
    true
