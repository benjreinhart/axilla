fs = require 'fs'
Path = require 'path'
glob = require 'glob'
async = require 'async'
Handlebars = require 'handlebars'

templates = {}
partials = {}

module.exports = axilla = (basePath, defaults) ->
  if (utils.isObject basePath) then defaults = basePath; basePath = null

  (path, viewObject, options) ->
    unless utils.isEmpty basePath
      path = Path.normalize "#{basePath}#{Path.sep}#{path}"

    render path, viewObject, (utils.defaults options, defaults)

axilla.handlebars = -> Handlebars
axilla.templates = -> {templates, partials}

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
  if utils.isObject options
    {baseDir} = options
  else
    baseDir = options
    options = {}

  unless 'function' is typeof cb
    cb = (err) -> throw err if err?

  unless isAbsolutePath baseDir
    throw new Error '`baseDir` must be an absolute path'

  glob (Path.normalize "#{baseDir}/**/*.mustache"), (err, paths) ->
    return cb err if err?
    async.each paths, (cacheTemplates baseDir, options), cb

  null

axilla.clearCache = ->
  templates = {}
  partials = {}

cacheTemplates = (baseDir, options) ->
  (absolutePath, cb) ->
    relativePath = removeBaseDir baseDir, absolutePath
    relativePath = removeExtensions relativePath

    opts = utils.clone options

    if isPartial (Path.basename relativePath)
      utils.extend opts, options, isPartial: true
      relativePath = removeUnderscore relativePath

    cacheTemplate [relativePath, absolutePath], opts, cb

cacheTemplate = (paths, options, cb) ->
  [relative, absolute] = paths

  templateCache = if options.isPartial then partials else templates
  templateCache[relative] =
    render: do ->
      return (readAndCompileSync absolute) unless options.cache is off
      (viewObject) -> (readAndCompileSync absolute)(viewObject)

  cb null

readAndCompileSync = (absolutePath) ->
  template = readFileSync absolutePath
  Handlebars.compile template

removeBaseDir = (baseDir, path) ->
  (path.split (new RegExp "^#{baseDir}#{Path.sep}"))[1]

removeExtensions = (path) ->
  filename = Path.basename path
  base = (filename.split '.')[0]

  "#{(path.split filename)[0]}#{base}"

removeUnderscore = (path) ->
  filename = Path.basename path
  base = (filename.split /^_/)[1]

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

  extend: (obj) ->
    (slice.call arguments, 1).forEach (source) ->
      for own key of source
        obj[key] = source[key]
      undefined
    obj

  defaults: (obj) ->
    (slice.call arguments, 1).forEach (source) ->
      for own key of source
        unless obj[key]?
          obj[key] = source[key]
      undefined
    obj

  clone: (obj) ->
    utils.extend {}, obj

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
