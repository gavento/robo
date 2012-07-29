define (require, exports, module) ->

  BoardView = require 'cs!app/controllers/BoardView'

  class GameView extends Spine.Controller

    tag:
      'div'

    attributes:
      class: 'GameView'

    constructor: (options) ->
      super
      throw "@game required" unless @game
      @game.bind("create update", @render)
      @boardView = new BoardView board:@game.board(), tileW:68, tileH:68
      @game.bind("update:name", @renderName)
      @render()

    render: =>
      @html "<div class='GameViewName'></div>"
      @renderName()
      @append @boardView

    renderName: =>
      @$('.GameViewName').html "Game \"#{ @game.name }\""

  module.exports = GameView
