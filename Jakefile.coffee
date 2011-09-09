# -*- mode: coffee; tab-width: 2 -*-
HELP = '''
  Jakesmine is a coffee-script based tool for Titanium development.

  TASKS

    jake -T # displays help


  ENVIRONMENT VARIABLES

  Normally this Jakefile will try to guess your current environment you can
  however force a particular setting by exporting one of the following variables:

    TI_PLATFORM   - The platform for mobile development: 'android' or 'iphone'

                    By default if your OS is Linux, android will be used,
                    on Mac iphone will be selected by default.


    TI_HOME       - The Titanium directory containing mobilesdk/ subdir.

                    On Linux, ~/.titanium if found.
                    On Mac /Library/Application Support/Titanium


    TI_SDK        - The version of the Titanium SDK to use.

                    By default the greatest version installed on $TI_HOME/mobilesdk


    TI_PYTHON     - The python executable to run Titanium scripts.

                    By default the python found in PATH


    ANDROID_SDK   - The location of the Android development kit.

                    Default: none.


    AVD           - The Android virtual device to use for development.

                    Default: none.

'''

env = process.env
spawn = require('child_process').spawn
path = require 'path'
join = path.join
fs = require 'fs'

mem = (fn) -> ->
    arguments.callee['memo'] ||= {}
    arguments.callee['memo'][[].concat(arguments)] ||= fn.apply(this, arguments)

pathSearch = (bin, p = env['PATH'].split(':'))->
  return join(d, bin) for d in p when path.existsSync join(d, bin)

compilerMap = (map, root, rexp, transform, base = [])->
  dir = join.apply(join, [root].concat(base))
  fs.readdirSync(dir).forEach (f)->
    if fs.statSync(join(dir, f)).isDirectory()
      compilerMap(map, root, rexp, transform, base.concat(f))
    else
      if rexp.test(f)
        map[join(dir, f)] = transform(join.apply(join, base), f)
  map

class Titanium

  OSX_TI_HOME = '/Library/Application Support/Titanium'

  os = require('os').type() == 'Linux' and 'linux' or 'osx'

  os: -> os

  home: mem ->
    env['TI_HOME'] || do ->
      join(env['HOME'], '.titanium/mobilesdk')
      if path.existsSync join(env['HOME'], '.titanium/mobilesdk')
         join(env['HOME'], '.titanium')
      else if path.existsSync OSX_TI_HOME
         OSX_TI_HOME

  sdk: mem ->
    env['TI_SDK'] || do =>
      sdk = fs.readdirSync(join(@home(), 'mobilesdk', @os())).sort()
      sdk[sdk.length - 1]

  tiCmd: mem ->
    join(@home(), 'mobilesdk', @os(), @sdk(), 'titanium.py')

  pyCmd: mem ->
    env['TI_PYTHON'] || pathSearch('python')

  titan: (args ...) ->
    p = spawn(@pyCmd(), [@tiCmd()].concat(args))
    p.stdout.on 'data', (data) -> console.log data.toString 'utf8'
    p.stderr.on 'data', (data) -> console.error data.toString 'utf8'

  fastdev: (args ...) ->
    @titan.apply(this, ['fastdev'].concat(args))

  defaultPlatform: mem ->
    env['TI_PLATFORM'] || (os == 'osx' and 'iphone' or 'android')


ti = new Titanium()

run = (plat, opt = {}) ->
  jake.Task['coffee'].invoke()
  testEnabled = join __dirname, 'Resources', 'test', 'enabled.js'
  testSelected = if opt.test
      rep = if opt.headless
              ''
            else
              'jasmine.getEnv().addReporter(new jasmine.TitaniumReporter());'

      "
      (function(){
    		Ti.include('/test/lib/jasmine-1.0.2.js');
    		Ti.include('/test/lib/jasmine-titanium.js');

        Ti.include('/test/#{opt.test}.js');

        #{rep}

    		jasmine.getEnv().execute();
      })();
      "
    else
      ';'
  fs.writeFile testEnabled, testSelected, (err) ->
      if err
        console.error err
      else
        ti.titan 'run', "--platform=#{plat}"

desc "Start Titanium Fastdev daemon"
task 'start', -> ti.fastdev 'start'

desc "Stop Titanium Fastdev daemon"
task 'stop', -> ti.fastdev 'stop'

desc "Run application in emulator"
task 'run', (plat = ti.defaultPlatform()) -> run(plat)

desc "Test application in emulator"
task 'test', (plat = ti.defaultPlatform(), test = 'all') ->
  run(plat, {test: test})

desc "Run tests on headless android"
task 'headless', (test='all')->
  console.error 'HELP: Not implemented.'

desc "Run the android tool"
task 'android', ->
  spawn(join(env['ANDROID_SDK'], 'tools', 'android'))

desc "Run the emulator"
task 'emulator', (plat = ti.defaultPlatform()) ->
  ti.titan 'emulator', "--platform=#{plat}"

desc "Run the Android Virtual Device (emulator)"
task 'avd', (name = env['AVD'])->
  if name
    spawn(join(env['ANDROID_SDK'], 'tools', 'emulator'), ['-avd', name])
  else
    console.error 'No ADV environment variable'

coffee_sources = do ->
  trans = (dir, fname) ->
    join(__dirname, 'Resources', dir, fname.replace('.coffee', '.js'))
  compilerMap({}, join(__dirname, 'Coffee'), /\.coffee$/, trans)

desc "Compile files from Coffee into Resources"
do => task coffee: v for own k, v of coffee_sources

coffee_compile = (src, js)->
 dep = {}
 dep[js] = src
 file dep, ->
   spawn(pathSearch('coffee'), ['-c', '-o', path.dirname(js), src])

do => coffee_compile(k, v) for own k, v of coffee_sources

desc "Remove all javascript Resources compiled from Coffee"
task 'decafe', ->
  fs.unlink f for f in (v for own k, v of coffee_sources)

desc "Remove generated files"
task 'clean', ->
  jake.Task['decafe'].invoke()

desc 'Display usage'
task 'help', -> console.log HELP

