expect = require 'expect.js'
fs = require 'fs'
sysPath = require 'path'
brunch = require '../../src/brunch'

class Project
  constructor: (@path, nested = no) ->
    @buildPath = if nested then @path else sysPath.join @path, 'build'

  join: (UNIXPath) ->
    sysPath.join @path, sysPath.join (UNIXsysPath.split '/')...

  read: (path) ->
    fs.readFileSync @join path

  write: (path, data) ->
    fs.writeFileSync (@join path), data

  remove: (path) ->
    fs.unlinkSync path
  
  exists: (path) ->
    !!(fs.statSync @join path)

  build: (callback) ->
    brunch.build @path, @buildPath, callback
  
  watchCallback: ->
    null

  watch: ->
    @_watcher = brunch.watch @path, @buildPath, @watchCallback
  
  stopWatching: ->
    @_watcher?.close()

describe 'brunch', ->
  generic = new Project sysPath.join __dirname, '..', 'tmp', 'project'
  nested = new Project sysPath.join __dirname, '..', 'tmp', 'nested'
  
  after ->
    fs.rmdirSync sysPath.join __dirname, '..', 'tmp'

  describe '#getLanguagesFromConfig()', ->
    class Cls
      constructor: ->
        @initialized = yes

    config =
      files:
        'out1.js':
          languages:
            '\\.coffee$': Cls

    result = expect brunch.getLanguagesFromConfig config
    (expect result.regExp).to.eql /\.coffee/
    (expect result.destinationPath).to.equal 'out1.js'

  describe '#new()', ->
    it 'should create new project', ->
      brunch.new generic.path, ->
        (expect generic.exists 'config.coffee').to.be.ok()

    it 'should create new project with nested directories', ->
      brunch.new nested.path, nested.path, ->
        (expect nested.exists 'config.coffee').to.be.ok()
        (expect nested.exists 'index.html').to.be.ok()

  describe '#build()', ->
    describe 'should build', ->
      it 'in generic project', ->
        generic.write 'app/input.ext', 'test'
        generic.build ->
          (expect generic.read 'build/result.ext').to.equal 'test'

      it 'in project with nested directories', ->
        nested.write 'app/input.ext', 'test'
        nested.build ->
          (expect nested.read 'result.ext').to.equal 'test'

  describe '#watch()', ->
    describe 'should recompile files', ->
      describe 'in generic project', ->
        beforeEach ->
          generic.watch()

        afterEach ->
          generic.stopWatching()
          
        it 'when file has been added', (done) ->
          generic.write 'app/input.ext', 'test'
          generic.watchCallback = ->
            (expect generic.read 'build/output.ext').to.equal 'test'
            done()

        it 'when file has been changed', (done) ->
          generic.write 'app/input.ext', 'test14'
          generic.watchCallback = ->
            (expect generic.read 'build/output.ext').to.equal 'test14'
            done()

        it 'when file has been deleted', (done) ->
          generic.remove 'app/thing.ext'
          generic.watchCallback = ->
            (expect generic.read 'build/result.ext').to.equal ''
            done()

      describe 'in project with nested directories', ->
        beforeEach ->
          nested.watch()

        afterEach ->
          nested.stopWatching()
          
        it 'when file has been added', (done) ->
          nested.write 'app/input.ext', 'test'
          nested.watchCallback = ->
            (expect generic.read 'build/output.ext').to.equal 'test'
            done()

        it 'when file has been changed', (done) ->
          nested.write 'app/input.ext', 'test14'
          nested.watchCallback = ->
            (expect generic.read 'build/output.ext').to.equal 'test14'
            done()

        it 'when file has been deleted', (done) ->
          nested.remove 'app/thing.ext'
          nested.watchCallback = ->
            (expect generic.read 'build/result.ext').to.equal ''
            done()
      

  describe '#generate()', ->
    it 'should generate project collection', ->
    it 'should generate project model', ->
    it 'should generate project style', ->
    it 'should generate project view', ->
