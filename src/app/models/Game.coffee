define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  Board = require "cs!app/models/Board"
  Player = require "cs!app/models/Player"
  Stateful = require "cs!app/stateful"

  class Game extends SimpleModel
    @configure {name: 'Game'}, 'name', 'board', 'players'
    @typedProperty 'board', Board
    @typedPropertyArrayEx 'players',
      (v) -> v instanceof Player,
      (v) -> v.game = @; new Player v

    constructor: ->
      super
      @state = new Stateful(@, "GameStarted", new Game::States)

  class Game::States

  class Game::States::GameStarted
    next: ->
      @state.transition("GameOver")

  class Game::States::GameOver
    next: ->
      @state.transition("GameStarted")

  module.exports = Game
