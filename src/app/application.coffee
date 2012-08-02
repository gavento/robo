define (require, exports, module) ->

#  require "spine"

  Game = require 'cs!app/models/Game'
  GameView = require 'cs!app/controllers/GameView'

  class App extends Spine.Controller
    constructor: ->
      super
      gameData =
        name: "Testovaci desticka"
        players: [
          {name: 'Alice', robotIds: ['Robot-1']},
          {name: 'Bob', robotIds: ['Robot-2', 'Robot-3']}
          ]
        board:
          width: 8
          height: 8
          entities: [
            {type: 'C', dir: 'E', x: 0, y: 0},
            {type: 'C', dir: 'E', x: 1, y: 0},
            {type: 'C', dir: 'E', x: 2, y: 0},
            {type: 'C', dir: 'E', x: 3, y: 0},
            {type: 'C', dir: 'E', x: 4, y: 0},
            {type: 'C', dir: 'E', x: 5, y: 0},
            {type: 'C', dir: 'E', x: 6, y: 0},
            {type: 'E', dir: 'S', x: 7, y: 0},

            {type: 'E', dir: 'N', x: 0, y: 1},
            {type: 'E', dir: 'S', x: 1, y: 1},
            {type: 'E', dir: 'W', x: 2, y: 1},
            {type: 'C', dir: 'E', x: 3, y: 1},
            {type: 'E', dir: 'S', x: 4, y: 1},
            {type: 'E', dir: 'N', x: 5, y: 1},
            {type: 'C', dir: 'E', x: 6, y: 1},
            {type: 'E', dir: 'S', x: 7, y: 1},

            {type: 'E', dir: 'N', x: 0, y: 2},
            {type: 'C', dir: 'W', x: 1, y: 2},
            {type: 'E', dir: 'E', x: 2, y: 2},
            {type: 'E', dir: 'S', x: 3, y: 2},
            {type: 'C', dir: 'N', x: 4, y: 2},
            {type: 'E', dir: 'N', x: 5, y: 2},
            {type: 'E', dir: 'E', x: 6, y: 2},
            {type: 'E', dir: 'S', x: 7, y: 2},

            {type: 'E', dir: 'N', x: 0, y: 3},
            {type: 'C', dir: 'N', x: 1, y: 3},
            {type: 'C', dir: 'W', x: 2, y: 3},
            {type: 'C', dir: 'W', x: 3, y: 3},
            {type: 'C', dir: 'E', x: 4, y: 3},
            {type: 'C', dir: 'E', x: 5, y: 3},
            {type: 'E', dir: 'S', x: 6, y: 3},
            {type: 'E', dir: 'S', x: 7, y: 3},

            {type: 'E', dir: 'N', x: 0, y: 4},
            {type: 'C', dir: 'N', x: 1, y: 4},
            {type: 'C', dir: 'E', x: 2, y: 4},
            {type: 'C', dir: 'N', x: 3, y: 4},
            {type: 'E', dir: 'N', x: 4, y: 4},
            {type: 'E', dir: 'W', x: 5, y: 4},
            {type: 'C', dir: 'W', x: 6, y: 4},
            {type: 'E', dir: 'S', x: 7, y: 4},

            {type: 'E', dir: 'N', x: 0, y: 5},
            {type: 'E', dir: 'W', x: 1, y: 5},
            {type: 'C', dir: 'E', x: 2, y: 5},
            {type: 'E', dir: 'E', x: 3, y: 5},
            {type: 'E', dir: 'S', x: 4, y: 5},
            {type: 'C', dir: 'S', x: 5, y: 5},
            {type: 'C', dir: 'N', x: 6, y: 5},
            {type: 'E', dir: 'S', x: 7, y: 5},

            {type: 'E', dir: 'N', x: 0, y: 6},
            {type: 'C', dir: 'S', x: 1, y: 6},
            {type: 'C', dir: 'E', x: 2, y: 6},
            {type: 'E', dir: 'S', x: 3, y: 6},
            {type: 'C', dir: 'W', x: 4, y: 6},
            {type: 'E', dir: 'S', x: 5, y: 6},
            {type: 'C', dir: 'W', x: 6, y: 6},
            {type: 'E', dir: 'S', x: 7, y: 6},

            {type: 'E', dir: 'N', x: 0, y: 7},
            {type: 'C', dir: 'W', x: 1, y: 7},
            {type: 'C', dir: 'W', x: 2, y: 7},
            {type: 'C', dir: 'W', x: 3, y: 7},
            {type: 'C', dir: 'W', x: 4, y: 7},
            {type: 'C', dir: 'W', x: 5, y: 7},
            {type: 'C', dir: 'W', x: 6, y: 7},
            {type: 'C', dir: 'W', x: 7, y: 7},

            {type: 'Robot', dir: 'W', x: 2, y: 2, image:'roombo-r.png', id: 'Robot-1', health: 7, name: 'Cervenacek'},
            {type: 'Robot', dir: 'N', x: 2, y: 5, image:'roombo-g.png', id: 'Robot-2', health: 7, name: 'Zelenik'},
            {type: 'Robot', dir: 'S', x: 5, y: 4, image:'roombo-b.png', id: 'Robot-3', health: 7, name: 'Modracek'},
            {type: 'Robot', dir: 'S', x: 4, y: 0, image:'roombo-y.png', id: 'Robot-4', health: 7, name: 'Zlutasek'},
            {type: 'Robot', dir: 'E', x: 4, y: 1, image:'roombo-m.png', id: 'Robot-5', health: 7, name: 'Fialka'},
          ]

      @game = Game.fromJSON gameData
      @log "loaded Game: ", @game



      @append "<div class='TestInputBox'><button id='button-activate'>Activate board</button></div>"
      @append new GameView game:@game

      @append new TestSizeInput model:@game.board()
      #@append new TestSizeInput model:@game.board()

      @append new TestInputBox model:@game, propName:'name'
      #@append new TestInputBox model:@game, propName:'name'

      @append "<div class='TestInputBox'><button id='button-activate'>Activate board</button></div>"
      @append new GameView game:@game


      b = @$('#button-activate')
      b.click( @activate )

    activate: =>
      @log "Activating"
      board = @game.board()
      board.activateAllPhases()

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

  module.exports = App
