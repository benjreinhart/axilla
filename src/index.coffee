Path = require 'path'
Mustache = require 'mustache'

$cache =
  layouts: {}
  partials: {}
  templates: {}

module.exports = axilla = (basePath, defaults) ->
  if (utils.isObject basePath) then defaults = basePath; basePath = null

  (path, viewObject, options) ->
    unless utils.isEmpty basePath
      path = Path.normalize "#{basePath}#{Path.sep}#{path}"

    render path, viewObject, (utils.defaults options, defaults)


axilla.configure = (path, options) ->
  (glob.sync (Path.normalize "#{path}/**/*.mustache")).forEach (file) ->
    relativePath = getTemplateReference file, path

    opts = utils.clone options
    opts.cacheType = 'layouts' if opts.layouts is true

    if isPartial (Path.basename file)
      opts.cacheType = 'partials'
      relativePath = removeUnderscore relativePath

    cacheTemplate file, (utils.extend opts, as: relativePath)


axilla.getTemplates = ->
  templates = {}
  for own templateType, templateObject of $cache
    for own path, template of templateObject
      do (templateType, path, template) ->
        (templates[templateType] ?= {})[path] = template
  templates


axilla.clearCache = ->
  $cache =
    layouts: {}
    partials: {}
    templates: {}
  undefined

###########
# PRIVATE #
###########

cacheTemplate = (path, options) ->
  $cache[options.cacheType ? 'templates'][options.as] =
    original: readFileSync path
