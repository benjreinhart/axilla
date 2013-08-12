sinon = require 'sinon'
{expect} = require 'chai'
getFriendlyPath = require '../lib/get_friendly_path'

describe '#getFriendlyPath', ->
  baseDir = '/Users/ben/projects/todos/views'
  partialPath = baseDir + '/users/_form.mustache'
  templatePath = baseDir + '/users/show.mustache'

  describe 'with a `baseDir` option', ->
    it 'removes the `baseDir` and extensions', ->
      expect(getFriendlyPath templatePath, {baseDir}).to.equal 'users/show'

    it 'removes the `baseDir` and extensions and strips away the leading underscore if the filename is a partial', ->
      expect(getFriendlyPath partialPath, {baseDir}).to.equal 'users/form'

    it 'invokes the third argument and passes it the `friendlyPath` and the absolute path', ->
      friendlyPath = sinon.stub()

      getFriendlyPath templatePath, {baseDir, friendlyPath}
      getFriendlyPath partialPath, {baseDir, friendlyPath}

      expect(friendlyPath.callCount).to.equal 2
      expect(friendlyPath.firstCall.args).to.eql [
        'users/show'
        '/Users/ben/projects/todos/views/users/show.mustache'
      ]

      expect(friendlyPath.secondCall.args).to.eql [
        'users/form'
        '/Users/ben/projects/todos/views/users/_form.mustache'
      ]

  describe 'without a `baseDir` option', ->
    it 'removes extensions and underscores', ->
      expect(getFriendlyPath templatePath).to.equal '/Users/ben/projects/todos/views/users/show'
      expect(getFriendlyPath partialPath).to.equal '/Users/ben/projects/todos/views/users/form'

  describe '`friendlyPath` option', ->
    it 'returns the `friendlyPath` option if it is a string', ->
      friendlyPath = 'friendly/path'

      optionsWithBaseDir = {baseDir, friendlyPath}
      optionsWithoutBaseDir = {friendlyPath}

      expect(getFriendlyPath templatePath, optionsWithBaseDir).to.equal 'friendly/path'
      expect(getFriendlyPath templatePath, optionsWithoutBaseDir).to.equal 'friendly/path'

    it 'uses the result of the `fn` argument as the return value', ->
      friendlyPath = -> 'poop/sauce'

      optionsWithBaseDir = {baseDir, friendlyPath}
      optionsWithoutBaseDir = {friendlyPath}

      expect(getFriendlyPath templatePath, optionsWithBaseDir).to.equal 'poop/sauce'
      expect(getFriendlyPath templatePath, optionsWithoutBaseDir).to.equal 'poop/sauce'
