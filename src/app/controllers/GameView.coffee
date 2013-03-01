define (require, exports, module) ->

  BoardView = require 'cs!app/controllers/BoardView'
  PlayerView = require 'cs!app/controllers/PlayerView'

  class GameController extends Spine.Controller
    constructor: ->
      super
      throw "@game required" unless @game
 

  class GameView extends GameController
    tag: 'div'
    attributes: class: 'GameView'
    constructor: ->
      super
      @nameView = new GameNameView game: @game
      @bind "release", (=> @nameView.release())
      @controlls = new GameControlls game: @game
      @bind "release", (=> @controlls.release())
      @gameView = new GameBoardAndPlayersView game: @game, tileW: 68, tileH: 68
      @bind "release", (=> @gameView.release())
      @append @nameView
      @append @controlls
      @append @gameView


  class GameNameView extends GameController
    tag: 'div'
    constructor: ->
      super
      @game.bind "update:name", @onUpdateName
      @bind "release", (=> @game.unbind @onUpdateName)
      @render()

    render: => @html "Game \"#{ @game.name }\""
    onUpdateName: => @render()


  class GameControlls extends GameController
    tag: 'div'
    constructor: ->
      super
      @restartButton = new GameRestartButton game: @game
      @bind "release", (=> @restartButton.release())
      @continueButton = new GameContinueButton game: @game
      @bind "release", (=> @continueButton.release())
      @append @restartButton
      @append @continueButton

  
  class GameBoardAndPlayersView extends GameController
    tag: 'div'
    attributes: class: 'GameBoardAndPlayersView'
    constructor: ->
      super
      @boardView = new BoardView board: @game.board(), tileW: @tileW, tileH: @tileH
      @bind "release", (=> @boardView.release())
      @playerViews = new GamePlayersView game: @game, tileW: @tileW, tileH: @tileH
      @bind "release", (=> @playerViews.release())
      @append @boardView
      @append @playerViews


  class GameRestartButton extends GameController
    tag: 'button'
    constructor: ->
      super
      @html("Restart")
    
    events: "click": "click"
    click: -> @game.restart()


  class GameContinueButton extends GameController
    tag: 'button'
    constructor: ->
      super
      @game.bind "game:interrupt", @onGameInterrupt
      @bind "release", (=> @game.unbind(@onGameInterrupt))
      @game.bind "game:continue", @onGameContinue
      @bind "release", (=> @game.unbind(@onGameContinue))
      @html("Continue")
    
    events: "click": "click"
    click: -> @game.continue()
    onGameInterrupt: => @el.show()
    onGameContinue: => @el.hide()


  class GamePlayersView extends GameController
    tag: 'div'
    attributes: class: 'GamePlayersView'
    constructor: ->
      super
      @playerViews = []
      for player in @game.players()
        view = new PlayerView
          player: player
          tileW: @tileW
          tileH: @tileH
        @bind "release", (=> view.release())
        @playerViews.push view
      for view in @playerViews
        @append view


  module.exports = GameView
