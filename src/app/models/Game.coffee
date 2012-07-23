define (require, exports, module) ->

  class Game extends Spine.Model
    @configure 'Game', 'name', 'board', 'players'

  module.exports = Game
