require('lib/setup')

Spine = require('spine')
GameView = require('controllers/gameview')

class App extends Spine.Controller
  constructor: ->
    super
    @game = new GameView
    @append @game

module.exports = App
    
