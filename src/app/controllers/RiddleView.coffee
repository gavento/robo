define (require, exports, module) ->

  Game = require 'cs!app/models/Game'
  GameView = require 'cs!app/controllers/GameView'

  class RiddleView extends Spine.Controller
    constructor: ->
      super
     
      # allowed riddles
      riddles = ["1", "2", "3", "4", "5", "6", "7", "8"]
      @riddleid = riddles[0] unless @riddleid in riddles
      json = "text!app/riddles/riddle_#{ @riddleid }.json"
      @log "Riddle: ", @riddleid, json
      
      require [json],  => (
        gameData = arguments[0]
        throw "Game data could not be read" unless gameData
        
        @game = Game.fromJSON gameData
        throw "Game not loaded" unless @game
        @log "loaded Game: ", @game
        @gameView = new GameView game:@game
        @bind "release", (=> @gameView.release())
        @append @gameView
      )

  module.exports = RiddleView


