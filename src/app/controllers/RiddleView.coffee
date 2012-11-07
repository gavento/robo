define (require, exports, module) ->

#  require "spine"

  Game = require 'cs!app/models/Game'
  GameView = require 'cs!app/controllers/GameView'

  class RiddleView extends Spine.Controller
    constructor: ->
      super
     
      # allowed riddles
      riddles = ["1", "2", "3"]
      @riddleid = riddles[0] unless @riddleid in riddles
      json = "text!app/riddles/riddle_#{ @riddleid }.json"
      @log "Riddle: ", @riddleid, json
      
      #@json = "text!app/game_test.json"

      require [json],  => (
        gameData = arguments[0]
        throw "Game data could not be read" unless gameData
        
        @game = Game.fromJSON gameData
        throw "Game not loaded" unless @game
        @log "loaded Game: ", @game
        #@log JSON.stringify @game, null, 2
  
        @append "<div class='TestInputBox'><button class='button-activate'>Activate board</button></div>"
        @append new GameView game:@game
  
        @append new TestSizeInput model:@game.board()
  
        @append new TestInputBox model:@game, propName:'name'
  
        b = @$('.button-activate')
        b.click( @activate )
      )

    activate: =>
      @log "Activating"
      @game.continue()
    
  class TestInputBox extends Spine.Controller
    events:
      'keyup input': 'keyPress'
    tag:
      'div'
    attributes:
      'class': 'TestInputBox'

    constructor: ->
      super
      throw "@model required" unless @model
      throw "@propName required" unless @propName
      @eventName ?= "update:#{ @propName }"

      @html "Interactive \"@model.#{ @propName }\" <input> (triggers event \"#{ @eventName }\")"
      @input = @$("input")
      @updateValue()
      @model.bind(@eventName, @updateValue)

    updateValue: =>
      if @input.val() != @model[@propName]
        @input.val(@model[@propName])

    keyPress: ->
      @model[@propName] = @input.val()
      @model.trigger(@eventName)


  class TestSizeInput extends Spine.Controller
    events:
      'click button': 'submit'
    tag:
      'div'
    attributes:
      'class': 'TestInputBox'

    constructor: ->
      super
      throw "@model required" unless @model
      @eventName ?= "update:#{ @propName }"

      @html "Half-interactive resizer <input class='width'>x<input class='height'> <button>Update</button>"
      @inWidth = @$ ".width"
      @inHeight = @$ ".height"
      @updateValue()
      @model.bind("update", @updateValue)

    updateValue: =>
      w = @model.get 'width'
      if @inWidth.val() != w
        @inWidth.val w
      h = @model.get 'height'
      if @inHeight.val() != h
        @inHeight.val h

    submit: ->
      @model.set 'width', Number @inWidth.val()
      @model.set 'height', Number @inHeight.val()

  module.exports = RiddleView

