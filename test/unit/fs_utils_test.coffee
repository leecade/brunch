expect = require 'expect.js'
fs = require 'fs'
sysPath = require 'path'
fs_utils = require '../../src/fs_utils'

describe 'fs_utils', ->
  tmpDir = sysPath.join __dirname, '..', 'tmp'

  describe 'FSWatcher', ->
    watcher = null

    before ->
      fs.mkdirSync tmpDir

    after ->
      fs.rmdirSync tmpDir
    
    beforeEach ->
      watcher = new fs_utils.FSWatcher [tmpDir]
      
    afterEach ->
      watcher.close()
      watcher = null

    it 'should trigger "change" event when file has been changed', (done) ->
      path = sysPath.join tmpDir, 'file'
      watcher.on 'change', (file) ->
        (expect file).to.equal path
        fs.unlinkSync path
        done()
      fs.writeFileSync path, 'test'

    it 'should trigger "remove" event when file has been removed', (done) ->
      path = sysPath.join tmpDir, 'file'
      fs.writeFileSync path, 'test'
      watcher.on 'remove', (file) ->
        console.log 'unlink'
        (expect file).to.equal path
      setTimeout ->
        console.log 1599, sysPath.existsSync path
        fs.unlink path, ->
          console.log 1599, sysPath.existsSync path
      , 100

  describe 'FileWriter', ->
    writer = null
    before -> 
      fs.mkdirSync tmpDir
      writer = new fs_utils.FileWriter tmpDir

    after ->
      writer.removeAllListeners 'write'
      writer = null
      fs.rmdirSync tmpDir

    it 'should recompile result when file has been changed', (done) ->
      fs.writeFileSync (sysPath.join tmpDir, 'file'), 'fileData'
      writer.emit 'change',
        destinationPath: 'result',
        path: 'file',
        data: 'fileData'
      writer.on 'write', ->
        data = fs.readFileSync sysPath.join tmpDir, 'result'
        (expect data.toString()).to.equal 'fileData'
        fs.unlinkSync sysPath.join tmpDir, 'file'
        done()
        
    it 'should recompile result when file has been removed', (done) ->
      writer.on 'remove', (path) ->
        console.log 1488
        (expect path).to.equal 'result'
        done()
      fs.unlinkSync sysPath.join tmpDir, 'result'

    it 'should emit error on invalid file', (done) ->
      expect(yes).to.be.ok()
