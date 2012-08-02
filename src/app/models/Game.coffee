define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  Board = require "cs!app/models/Board"
  Player = require "cs!app/models/Player"

  class Game extends SimpleModel
    @configure {name: 'Game'}, 'name', 'board', 'players'
    @typedProperty 'board', Board
    @typedPropertyArrayEx 'players',
      (v) -> v instanceof Player,
      (v) -> v.game = @; new Player v

  module.exports = Game
