fs = require 'fs'
glob = require 'glob'
{expect} = require 'chai'
getFormattedTemplates = require '../lib/get_formatted_templates'

describe '#getFormattedTemplates', ->
  baseDir = '/Users/ben/projects/todos/views'
  partialPath = baseDir + '/users/_form.mustache'
  templatePath = baseDir + '/users/show.mustache'

  originalGlobSync = glob.sync
  originalFsStatSync = fs.statSync
  originalFsExistsSync = fs.existsSync
  originalFsReadFileSync = fs.readFileSync

  before ->
    glob.sync = -> [templatePath, partialPath]
    fs.existsSync = -> true
    fs.readFileSync = (path) ->
      if path is templatePath
        '<h1>{{user.name}}</h1>'
      else
        '<input type="text" id="username">'

  after ->
    glob.sync = originalGlobSync
    fs.existsSync = originalFsExistsSync
    fs.readFileSync = originalFsReadFileSync

  afterEach ->
    fs.statSync = originalFsStatSync

  describe 'first argument is a directory', ->
    beforeEach ->
      fs.statSync = -> {isFile: -> false}

    it 'returns an object with `partials` and `templates` properties', ->
      expect(getFormattedTemplates baseDir).to.eql
        partials: [
          {
            path: '/Users/ben/projects/todos/views/users/_form.mustache'
            contents: '<input type="text" id="username">'
            friendlyPath: 'users/form'
          }
        ]
        templates: [
          {
            path: '/Users/ben/projects/todos/views/users/show.mustache'
            contents: '<h1>{{user.name}}</h1>'
            friendlyPath: 'users/show'
          }
        ]

    it 'accepts a `friendlyPath` option to use for creating the `friendlyPath` property', ->
      friendlyPath = (friendlyPath) ->
        'dashboard/' + friendlyPath

      expect(getFormattedTemplates baseDir, {friendlyPath}).to.eql
        partials: [
          {
            path: '/Users/ben/projects/todos/views/users/_form.mustache'
            contents: '<input type="text" id="username">'
            friendlyPath: 'dashboard/users/form'
          }
        ]
        templates: [
          {
            path: '/Users/ben/projects/todos/views/users/show.mustache'
            contents: '<h1>{{user.name}}</h1>'
            friendlyPath: 'dashboard/users/show'
          }
        ]

  describe 'first argument is a file', ->
    beforeEach ->
      fs.statSync = -> {isFile: -> true}

    it 'returns an object with a `partials` and `templates` properties', ->
      expect(getFormattedTemplates templatePath, {friendlyPath: 'users/show'}).to.eql
        partials: []
        templates: [
          {
            path: '/Users/ben/projects/todos/views/users/show.mustache'
            contents: '<h1>{{user.name}}</h1>'
            friendlyPath: 'users/show'
          }
        ]

      expect(getFormattedTemplates partialPath, {friendlyPath: 'users/form'}).to.eql
        partials: [
          {
            path: '/Users/ben/projects/todos/views/users/_form.mustache'
            contents: '<input type="text" id="username">'
            friendlyPath: 'users/form'
          }
        ]
        templates: []

    it 'removes underscores and extensions if no `friendlyPath` option is provided', ->
      expect(getFormattedTemplates templatePath).to.eql
        partials: []
        templates: [
          {
            path: '/Users/ben/projects/todos/views/users/show.mustache'
            contents: '<h1>{{user.name}}</h1>'
            friendlyPath: '/Users/ben/projects/todos/views/users/show'
          }
        ]

      expect(getFormattedTemplates partialPath).to.eql
        partials: [
          {
            path: '/Users/ben/projects/todos/views/users/_form.mustache'
            contents: '<input type="text" id="username">'
            friendlyPath: '/Users/ben/projects/todos/views/users/form'
          }
        ]
        templates: []


