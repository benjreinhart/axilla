fs = require 'fs'
glob = require 'glob'
sinon = require 'sinon'
{expect} = require 'chai'
{getTemplates, getTemplate} = require '../lib/get_templates'


describe '#getTemplates', ->
  beforeEach ->
    fakeReadFileSync = (path) ->
      if path is '/path/to/file1.mustache'
        '<h1>File 1!</h1>'
      else
        '<h2>File 2!</h2>'

    sinon.stub(fs, 'readFileSync', fakeReadFileSync)
    sinon.stub(fs, 'existsSync').returns true

  afterEach ->
    glob.sync.restore()
    fs.existsSync.restore()
    fs.readFileSync.restore()

  it 'is an array of template objects', ->
    sinon.stub(glob, 'sync').returns ['/path/to/file1.mustache', '/path/to/file2.mustache']
    templates = getTemplates '/path/to'

    expect(templates).to.eql [
      {
        path: '/path/to/file1.mustache'
        contents: '<h1>File 1!</h1>'
      }
      {
        path: '/path/to/file2.mustache'
        contents: '<h2>File 2!</h2>'
      }
    ]

  it 'is an empty array if no files were found', ->
    sinon.stub(glob, 'sync').returns []
    expect(getTemplates '/some/path/with/no/templates').to.eql []

describe '#getTemplate', ->
  describe 'with invalid arguments', ->
    afterEach ->
      fs.existsSync.restore?()

    it 'throws an error when the `path` argument is not an absolute path', ->
      fn = -> getTemplate 'relative/path.mustache'
      expect(fn).to.throw 'Path argument must be an absolute path'

    it "throws an error if the file doesn't exist", ->
      stub = sinon.stub(fs, 'existsSync').returns false
      fn = -> getTemplate '/non-existent/path.mustache'
      expect(fn).to.throw '/non-existent/path.mustache does not'


  describe 'with valid arguments', ->
    beforeEach ->
      sinon.stub(fs, 'existsSync').returns true
      @fsReadFileSync = sinon.stub(fs, 'readFileSync').returns '<p>{{name}}</p>'

    afterEach ->
      fs.existsSync.restore()
      fs.readFileSync.restore()

    it 'returns an object with a `contents` and `path` properties', ->
      template = getTemplate '/path/to/file.mustache'

      expect(@fsReadFileSync.calledOnce).to.be.true
      expect(@fsReadFileSync.calledWith '/path/to/file.mustache').to.be.true

      expect(template).to.deep.equal
        path: '/path/to/file.mustache'
        contents: '<p>{{name}}</p>'

    describe 'fs.readFileSync second argument', ->
      beforeEach ->
        @originalNodeVersion = process.version
      afterEach ->
        process.version = @originalNodeVersion

      it 'is an object with an `encoding` attribute if the node version is 10 or greater', ->
        process.version = 'v0.10.0'
        getTemplate '/path/to/file.mustache'
        expect(@fsReadFileSync.firstCall.args[1]).to.eql {encoding: 'utf8'}

        process.version = 'v0.11.0'
        getTemplate '/path/to/file.mustache'
        expect(@fsReadFileSync.secondCall.args[1]).to.eql {encoding: 'utf8'}

      it 'is the string "utf8" if version is less than 10', ->
        process.version = "v0.8.0"
        getTemplate '/path/to/file.mustache'
        expect(@fsReadFileSync.firstCall.args[1]).to.equal 'utf8'

        process.version = "v0.9.12"
        getTemplate '/path/to/file.mustache'
        expect(@fsReadFileSync.secondCall.args[1]).to.equal 'utf8'
