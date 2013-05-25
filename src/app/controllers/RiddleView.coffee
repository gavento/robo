define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/SimpleController'
  Game = require 'cs!app/models/Game'
  GameView = require 'cs!app/controllers/GameView'

  class RiddleView extends SimpleController
    constructor: ->
      super
      # allowed riddles
      riddles = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
      @riddleid = riddles[0] unless @riddleid in riddles
      json = "text!json/riddles/riddle-#{ @riddleid }.json"
      displayGame = =>
        gameData = arguments[0]
        throw "Game data could not be read" unless gameData
        @game = Game.fromJSON gameData
        throw "Game not loaded" unless @game
        @appendController new GameView game:@game
      require [json], displayGame

  module.exports = RiddleView


