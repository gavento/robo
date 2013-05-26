define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/simple-controller'
  Game = require 'cs!app/models/game'
  GameView = require 'cs!app/controllers/game-view'

  # # App controller #
  # Provisional loader class, used for development.
  #
  class TestingView extends SimpleController
    constructor: ->
      super
      
      throw "@json required" unless @json
      
      require [@json],  => (
        gameData = arguments[0]
        throw "Game data could not be read" unless gameData
        
        @game = Game.fromJSON gameData
        throw "Game not loaded" unless @game
        @log "loaded Game: ", @game
        #@log JSON.stringify @game, null, 2
  
        @append "<div class='TestInputBox'><button class='button-activate'>Activate board</button></div>"
        @appendController new GameView game: @game
        @appendController new TestSizeInput model: @game.board()
        @appendController new TestInputBox model: @game, propName: 'name'
  
        @append "<div class='TestInputBox'><button class='button-activate'>Activate board</button></div>"
        @appendController new GameView game: @game
  
  
        b = @$('.button-activate')
        b.click( @activate )
      )

    # Activate all entities on the board.
    activate: =>
      board = @game.board()
      buttons = $('.button-activate')
      buttons.attr "disabled", "disabled"
      board.activateBoard({}, -> buttons.removeAttr "disabled")
    
  # Experimental class for synchronous sync of inputbox contents.
  class TestInputBox extends SimpleController
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
      @bindToModel @model, @eventName, @updateValue

    updateValue: =>
      if @input.val() != @model[@propName]
        @input.val(@model[@propName])

    keyPress: ->
      @model[@propName] = @input.val()
      @model.trigger(@eventName)

  # Experimental class for semi-synchronous updates to board size.
  class TestSizeInput extends SimpleController
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
      @bindToModel @model, "update", @updateValue

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

  module.exports = TestingView

