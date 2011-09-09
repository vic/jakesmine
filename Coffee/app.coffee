# -*- mode: coffee; tab-width: 2 -*-

Ti.UI.setBackgroundColor '#FFF'

newCard = Ti.UI.createButton
  title: 'Happy hacking!'
  borderColor: '#FFF'
  borderRadious: 0.0

win = Ti.UI.createWindow
  title: 'Tab 1'
  backgroundColor: '#fff'


win.add newCard
win.open()

Ti.include '/test/enabled.js'
