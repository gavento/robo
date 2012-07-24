define (require, exports, module) ->

#  require "spine"

  Game = require 'cs!app/models/Game'
  Board = require 'cs!app/models/Board'
  GameView = require 'cs!app/controllers/GameView'
  cards = require 'cs!app/models/cards'

  class App extends Spine.Controller
    constructor: ->
      super
      gameData =
        name: "Testovaci desticka"
        board:
          width: 8
          height: 2
          entities: [
            {type: 'C', dir: 'S', x: 0, y: 1},
            {type: 'C', dir: 'E', x: 1, y: 1},
            {type: 'C', dir: 'N', x: 2, y: 1},
            {type: 'C', dir: 'W', x: 3, y: 1},
            {type: 'C', dir: 'S', x: 4, y: 1},
            {type: 'C', dir: 'E', x: 5, y: 1},
            {type: 'C', dir: 'N', x: 6, y: 1},
            {type: 'C', dir: 'W', x: 7, y: 1},
            {type: 'E', dir: 'W', x: 0, y: 0},
            {type: 'E', dir: 'W', x: 1, y: 0},
            {type: 'E', dir: 'W', x: 2, y: 0},
            {type: 'E', dir: 'S', x: 3, y: 0},
            {type: 'E', dir: 'S', x: 4, y: 0},
            {type: 'E', dir: 'E', x: 5, y: 0},
            {type: 'E', dir: 'E', x: 6, y: 0},
            {type: 'E', dir: 'E', x: 7, y: 0},
          ]

      @append "<div class='TestInputBox'><button id='button-activate'>Activate board</button></div>"
      b = @$('#button-activate')
      b.click( @activate )

      @game = new Game gameData

      @append new TestInputBox model:@game, propName:'name'
      @append new TestInputBox model:@game, propName:'name'

      @append new TestSizeInput model:@game.board
      #@append new TestSizeInput model:@game.board

      @append new GameView game:@game
      @append new GameView game:@game


    activate: =>
      @log "Activating"
      @game.board.activateAllPhases()

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
      if @inWidth.val() != @model.width
        @inWidth.val(@model.width)
      if @inHeight.val() != @model.height
        @inHeight.val(@model.height)

    submit: ->
      @model.resize @inWidth.val(), @inHeight.val()
      @model.trigger("update")

  module.exports = App
