{exec} = require 'child_process'
helpers = require './src/helpers'

log = (error, stdout, stderr) ->
  helpers.logError stderr if error?
  helpers.log stdout if stdout

task 'build', 'Build the source', ->
  exec 'coffee -o lib src', log

task 'test', 'Run tests', ->
  exec '''node_modules/.bin/mocha "$(find test -name '*_test.coffee')" --reporter spec''', log
