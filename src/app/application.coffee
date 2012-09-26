define (require, exports, module) ->


  Game = require 'cs!app/models/Game'
  GameView = require 'cs!app/controllers/GameView'

  # # App controller #
  #
  # Provisional loader class, used for development.
  #
  class App extends Spine.Controller
    constructor: ->
      super

      gameData = require 'text!app/game_test.json'
      throw "Game data could not be read" unless gameData
      @game = Game.fromJSON gameData
      throw "Game not loaded" unless @game
      @log "loaded Game: ", @game

      @append "<div class='TestInputBox'><button class='button-activate'>Activate board</button></div>"
      @append new GameView game:@game

      @append new TestSizeInput model:@game.board()

      @append new TestInputBox model:@game, propName:'name'

      @append "<div class='TestInputBox'><button class='button-activate'>Activate board</button></div>"
      @append new GameView game:@game


      b = @$('.button-activate')
      b.click( @activate )

    # Activate all entities on the board.
    activate: =>
      board = @game.board()
      buttons = $('.button-activate')
      buttons.attr "disabled", "disabled"
      board.activateBoardLocking {}, ->
        buttons.removeAttr "disabled"

  # Experimental class for synchronous sync of inputbox contents.
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

  # Experimental class for semi-synchronous updates to board size.
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


  module.exports = App
