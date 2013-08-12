{expect} = require 'chai'
{isPartial, isAbsolutePath} = require '../lib/file_utils'

describe '#isPartial', ->
  it 'is true if the filename is prefixed with an underscore', ->
    expect(isPartial '_filename.mustache').to.be.true
    expect(isPartial 'filename.mustache').to.be.false

describe '#isAbsolutePath', ->
  it 'is true if the path is prefixed with a slash', ->
    expect(isAbsolutePath '/path/to/filename.mustache').to.be.true
    expect(isAbsolutePath 'relative/path/to/filename.mustache').to.be.false