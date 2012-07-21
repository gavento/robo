define (require, exports, module) ->

#  require "spine"

  Game = require 'cs!app/models/Game'
  GameView = require 'cs!app/controllers/GameView'

  class App extends Spine.Controller
    constructor: ->
      super
      @game = new Game name:"G1"
      @append new GameView game:@game
      @append $("<div>Tralala!</div>")

  module.exports = App
