define (require, exports, module) ->

  BoardView = require 'cs!app/controllers/BoardView'
  PlayerView = require 'cs!app/controllers/PlayerView'

  class GameView extends Spine.Controller

    tag:
      'div'

    attributes:
      class: 'GameView'

    constructor: (options) ->
      super
      throw "@game required" unless @game
      @game.bind("update", @render)
      @game.bind("update:name", @renderName)
      @render()

    render: =>
      @html "<div class='GameViewName'></div><table><tr><td class='GameViewBoard'></td><td class='GameViewPlayers'></td></tr></table>"
      @renderName()

      if @boardView? then @boardView.release() 
      @boardView = new BoardView board:@game.board(), tileW:68, tileH:68
      @$('.GameViewBoard').append @boardView.el

      if @playerViews? then (pv.release() for pv in @playerViews)
      @playerViews = []
      for p in @game.get 'players'
        pv = new PlayerView player:p
        @playerViews.push pv
        @$('.GameViewPlayers').append pv.el

    renderName: =>
      @$('.GameViewName').html "Game \"#{ @game.name }\""

  module.exports = GameView
