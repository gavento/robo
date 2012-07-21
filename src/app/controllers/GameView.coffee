define (require, exports, module) ->

#  require('jquery')
#  require('spine')

  class GameView extends Spine.Controller
    tag:
      'div'
    constructor: (options) ->
      super()
      @game = options.game
      @html(@game.name)

  module.exports = GameView
