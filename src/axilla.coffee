fs = require 'fs'
Path = require 'path'
glob = require 'glob'
Handlebars = require 'handlebars'

templates = {}
partials = {}

module.exports = axilla = (basePath, defaults) ->
  if (utils.isObject basePath) then defaults = basePath; basePath = null

  (path, viewObject, options) ->
    unless utils.isEmpty basePath
      path = Path.normalize "#{basePath}#{Path.sep}#{path}"

    render path, viewObject, (utils.defaults options, defaults)

axilla.configure = (path, options={}) ->
  unless isAbsolutePath path
    throw new Error 'First argument must be an absolute path'

  unless fs.existsSync path
    throw new Error "#{path} does not exist"

  (glob.sync (Path.normalize "#{path}/**/*.mustache")).forEach (file) ->
    relativePath = getTemplateReference file, path

    opts = utils.clone options
    if isPartial (Path.basename file)
      opts.isPartial = true
      relativePath = removeUnderscore relativePath

    cacheTemplate file, (utils.extend opts, as: relativePath)

axilla.render = render = (path, viewObject) ->
  unless (template = templates[path])?
    throw new Error "Unable to resolve template at #{path}"

  template.render viewObject

axilla.clearCache = ->
  templates = {}
  partials = {}

axilla.handlebars = -> Handlebars
axilla.templates = -> {templates, partials}


###########
# PRIVATE #
###########

renderPartial = (path, viewObject) ->
  unless (partial = partials[path])?
    throw new Error "Unable to resolve partial at #{path}"

  partial.render viewObject

getTemplateReference = (file, dirname) ->
  removeBasePath dirname, (removeExtensions file)

cacheTemplate = (path, options) ->
  templateCache = if options.isPartial then partials else templates
  templateCache[options.as] =
    render: do ->
      return (readAndCompileSync path) unless options.cache is off
      (viewObject) -> (readAndCompileSync path)(viewObject)
  undefined

readAndCompileSync = (absolutePath) ->
  template = readFileSync absolutePath
  Handlebars.compile template

removeBasePath = (dirname, path) ->
  (path.split (new RegExp "^#{dirname}#{Path.sep}"))[1]

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


######################
# Handlebars Helpers #
######################

Handlebars.registerHelper 'partial', (path) ->
  new Handlebars.SafeString (renderPartial path, this)
