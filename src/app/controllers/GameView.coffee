define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/SimpleController'
  BoardView = require 'cs!app/controllers/BoardView'
  PlayerView = require 'cs!app/controllers/PlayerView'

  class GameController extends SimpleController
    constructor: ->
      super
      throw "@game required" unless @game
 

  class GameView extends GameController
    tag: 'div'
    attributes: class: 'GameView'
    constructor: ->
      super
      @appendController new GameNameView game: @game
      @appendController new GameControlls game: @game
      @appendController new GameBoardAndPlayersView game: @game, tileW: 68, tileH: 68


  class GameNameView extends GameController
    tag: 'div'
    constructor: ->
      super
      @bindToModel @game, "update:name", @onUpdateName
      @render()

    render: => @html "Game \"#{ @game.name }\""
    onUpdateName: => @render()


  class GameControlls extends GameController
    tag: 'div'
    constructor: ->
      super
      @appendController new GameRestartButton game: @game
      @appendController new GameContinueButton game: @game

  
  class GameBoardAndPlayersView extends GameController
    tag: 'div'
    attributes: class: 'GameBoardAndPlayersView'
    constructor: ->
      super
      @appendController new BoardView board: @game.board(), tileW: @tileW, tileH: @tileH
      @appendController new GamePlayersView game: @game, tileW: @tileW, tileH: @tileH


  class GameRestartButton extends GameController
    tag: 'button'
    constructor: ->
      super
      @html("Restart")
    
    events: "click": "click"
    click: => @game.restart()


  class GameContinueButton extends GameController
    tag: 'button'
    constructor: ->
      super
      @bindToModel @game, "game:interrupt", @onGameInterrupt
      @bindToModel @game, "game:continue", @onGameContinue
      @html "Continue"
    
    events: "click": "click"
    click: => @game.continue()
    onGameInterrupt: => @el.show()
    onGameContinue: => @el.hide()


  class GamePlayersView extends GameController
    tag: 'div'
    attributes: class: 'GamePlayersView'
    constructor: ->
      super
      for player in @game.players()
        view = new PlayerView
          player: player
          tileW: @tileW
          tileH: @tileH
        @appendController view


  module.exports = GameView
