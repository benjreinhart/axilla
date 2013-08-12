# Given the following directory tree:
#
# * Users/ben/projects/todos/views/
#   * users/
#     * index.mustache
#   * todos/
#     * todo.mustache
#
#
# getTemplates('/Users/ben/projects/todos/views')
#
#    [
#      {
#        path: "/Users/ben/projects/todos/views/users/index.mustache",
#        contents: "<h1>There are {{users.count}} users!</h1>"
#      },
#      {
#        path: "/Users/ben/projects/todos/views/todos/todo.mustache",
#        contents: "<h1>{{todo.name}}</h1>"
#      }
#    ]
#
#
# getTemplate('/Users/ben/projects/todos/views/todos/todo.mustache')
#
#    {
#      path: "/Users/ben/projects/todos/views/todos/todo.mustache",
#      contents: "<h1>{{todo.name}}</h1>"
#    }

fs = require 'fs'
glob = require 'glob'
Path = require 'path'
{isAbsolutePath} = require './file_utils'

getTemplates = (basePath) ->
  glob.sync(Path.normalize("#{basePath}/**/*.mustache")).map getTemplate

getTemplate = (path) ->
  unless isAbsolutePath path
    throw new Error 'Path argument must be an absolute path'

  unless fs.existsSync path
    throw new Error "#{path} does not exist"

  {path, contents: readFileSync(path)}

# Only a function for stubbing `process.version` in tests
getNodeVersion = ->
  +process.version[1..].split('.')[1]

readFileSync = (path) ->
  options = if getNodeVersion() < 10 then 'utf8' else {encoding: 'utf8'}
  fs.readFileSync path, options

module.exports = {getTemplates, getTemplate}
