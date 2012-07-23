define (require, exports, module) ->

#  require "spine"

  Game = require 'cs!app/models/Game'
  Board = require 'cs!app/models/Board'
  GameView = require 'cs!app/controllers/GameView'

  class App extends Spine.Controller
    constructor: ->
      super
      @game = new Game name:"G1"
      @game.board = new Board
      @game.board.resize 7,3

      @append new TestInputBox model:@game, propName:'name'
      @append new TestInputBox model:@game, propName:'name'

      @append new TestSizeInput model:@game.board
      @append new TestSizeInput model:@game.board

      @append new GameView game:@game
      @append new GameView game:@game



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
