fs = require 'fs'
{partition} = require 'minutils'
{isPartial} = require './file_utils'
{getTemplates, getTemplate} = require './get_templates'
getFriendlyPath = require './get_friendly_path'

module.exports = (baseDir, options = {}) ->
  options =
    baseDir: baseDir
    friendlyPath: options.friendlyPath

  if fs.statSync(baseDir).isFile()
    result = {partials: [], templates: []}
    template = getTemplate baseDir
    template.friendlyPath = getFriendlyPath baseDir, options
    (if isPartial template.path then result.partials else result.templates).push template
    result
  else
    [partials, templates] = partition getTemplates(baseDir), (template) ->
      isPartial template.path

    for object in [partials, templates]
      object.forEach (template) ->
        template.friendlyPath = getFriendlyPath template.path, options

    {partials, templates}
