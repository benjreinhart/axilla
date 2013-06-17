fs = require 'fs'
Path = require 'path'
glob = require 'glob'
async = require 'async'
Mustache = require 'mustache'

module.exports = axilla = (basePath, defaults) ->
  if (utils.isObject basePath) then defaults = basePath; basePath = null

  (path, viewObject, options) ->
    unless utils.isEmpty basePath
      path = Path.normalize "#{basePath}#{path.sep}#{path}"

    render path, viewObject, (utils.defaults options, defaults)

axilla.templates = templates = {}
axilla.partials = partials = {}

axilla.render = render = (path, viewObject, options={}) ->
  if templates[path]?
    return templates[path] viewObject

  unless (fs.existsSync path) and (fs.statSync path).isFile()
    throw new Error "Unable to resolve file at #{path}"

  template = readFileSync path
  Mustache.render template, viewObject

axilla.cache = (options, cb) ->
  baseDir = if (utils.isString options) then options else options.baseDir

  unless isAbsolutePath baseDir
    baseDir = Path.normalize "#{__dirname}#{Path.sep}#{baseDir}"

  glob (Path.normalize "#{baseDir}/**/*.mustache"), (err, paths) ->
    console.log (Path.normalize "#{baseDir}/**/*.mustache"), paths
    iterator = (path, cb) ->
      cacheTemplate [path, (removeBaseDir baseDir, path)], options, cb

    async.each paths, iterator, (err) ->
      return cb err if cb?
      throw err if err?

  null

axilla.clearCache = ->
  axilla.templates = templates = {}
  axilla.partials = partials = {}

cacheTemplate = (paths, options, cb) ->
  [absolute, relative] = paths

  readFile absolute, (err, contents) ->
    return cb err if err?

    base = stripPath relative

    if isPartial (Path.basename relative)
      cachePartial base, contents
    else
      cacheFunction base, contents

    cb()

cacheFunction = (path, template) ->
  templates[path] = (viewObject) ->
    Mustache.render template, viewObject, partials

cachePartial = (path, template) ->
  partials[path] = template

removeBaseDir = (baseDir, path) ->
  (path.split (new RegExp "^#{baseDir}/"))[1]

stripPath = (path) ->
  filename = Path.basename path

  base = (filename.split '.')[0]
  base = (base.split /^_/)[1] if isPartial base

  "#{(path.split filename)[0]}#{base}"

isPartial = (filename) ->
  (filename.match /^_/)?

isAbsolutePath = (path) ->
  (path.match (new RegExp "^#{Path.sep}"))?

readFile = (path, cb) ->
  fs.readFile path, 'utf8', cb

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