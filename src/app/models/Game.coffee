define (require, exports, module) ->

  Board = require "cs!app/models/Board"

  class Game extends Spine.Model
    @configure 'Game', 'name', 'board', 'players'

    load: (atts) ->
      if atts.board and atts.board not instanceof Board
        @board = new Board atts.board
        delete atts.board
      super atts

  module.exports = Game
