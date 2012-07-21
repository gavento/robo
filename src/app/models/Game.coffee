define (require, exports, module) ->

#  require('spine')

  class Game extends Spine.Model
    @configure 'Game', 'name'

  module.exports = Game
