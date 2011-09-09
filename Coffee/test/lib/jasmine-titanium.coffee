# -*- mode: coffee; tab-width: 2 -*-

###
# This is port of Guilherme's titanium reporter to cofeescript.
#
###
#
# TitaniumReporter, by Guilherme Chapiewski - http://guilhermechapiewski.com
#
# TitaniumReporter is a Jasmine reporter that outputs spec results to a new
# window inside your iOS application. It helps you develop Titanium Mobile
# applications with proper unit testing.
#
# More info at http://github.com/guilhermechapiewski/titanium-jasmine
#
# Usage:
#
# jasmine.getEnv().addReporter(new jasmine.TitaniumReporter());
# jasmine.getEnv().execute();
#


unless jasmine
  throw new Exception("jasmine library does not exist in global namespace!")

class TitaniumReporter

  window = Ti.UI.createWindow
    title: 'Application Tests'
    backgroundColor: 'white'
    zIndex: 999
  webView = Ti.UI.createWebView {html: ''}
  window.add webView
  window.open()

  results = ''
  header = '<html><head><style type="text/css">body{font-size:10px;font-family:helvetica;}</style></head><body>'
  footer = '</body></html>'

  updateTestResults: (message)->
    results += message
    webView.html = header + results + footer

  log: @updateTestResults

  reportRunnerResults: (runner)->

  reportRunnerStarting: (runner)-> @log('<h3>Test Runner Started.</h3>')

  reportSpecResults: (spec)->
    color = '#009900'
    pass = spec.results().passesCount + ' pass'
    unless spec.results().passed()
      color = '#FF0000'
      fail = spec.results().failedCount + ' fail'
    msg = fail and "(#{pass}, #{fail})" or "(#{pass})"
    @log "• <font color=\"#{color}\">#{spec.description}</font>#{msg}<br/>"
    unless spec.results().passed()
      a = 1
      for it in spec.results().items_ when !it.passed_
        @log "&nbsp;&nbsp;&nbsp;&nbsp;(#{a++}) <i>#{it.message}</i><br/>"
        if it.expected
          @log "&nbsp;&nbsp;&nbsp;&nbsp;• Expected: #{it.expected}<br/>"
        @log "&nbsp;&nbsp;&nbsp;&nbsp;• Actual result: #{it.actual}<br/>"
        @log "<br/>"

  reportSpecStarting: (spec)->

  reportSuiteResults: (suite)->
    results = suite.results
    @log "<b>[#{suite.description}] #{results.passedCount} of #{results.totalCount} assertions passed.</b><br /><br />"

jasmine.TitaniumReporter = TitaniumReporter
