expect = require 'expect.js'
command = require '../../src/command'

describe 'command', ->
  describe '#readPackageVersion()', ->
    it 'should return correct brunch version', ->
      (expect typeof command.readPackageVersion()).to.equal 'string'
      (expect command.readPackageVersion()).to.equal '1.0.0-beta2'
