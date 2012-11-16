define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  Board = require "cs!app/models/Board"
  Player = require "cs!app/models/Player"
  MultiLock = require "cs!app/lib/MultiLock"
  Stateful = require "cs!app/lib/Stateful"

  class Game extends SimpleModel
    @configure {name: 'Game'}, 'name', 'board', 'players'
    @typedProperty 'board', Board
    @typedPropertyArrayEx 'players',
      (v) -> v instanceof Player,
      (v) -> v.game = @; new Player v

    constructor: ->
      super
      # Current turn of the game.
      @turnIndex = 0
      # Index of currently played card.
      @cardIndex = 0
      # Index of currently active robot.
      @robotIndex = 0
      @started = false
      @state = new Stateful(@, "GameStart", new Game::States)
      @bind "state:entered", @run
      @bind "release", (=> @unbind "state:entered")

    # Run or the game from current state.
    run: ->
      if not @isUserActionRequired()
        # Continue only if no user action is required (eg. selecting
        # cards or choosing rotation on a flag).
        @next()

    # Continue the game after user interaction.
    continue: ->
      if not @started
        @started = true
        @run()

    
    getSortedRobots: ->
      # Get all robots of all players.
      robots = []
      for player in @get 'players'
        for robot in player.get 'robots'
          robots.push robot
      # Sort robots according to priority of current card.
      robots.sort( (robot1, robot2) =>
        priority1 = robot1.get('cards')[@cardIndex].get('priority')
        priority2 = robot2.get('cards')[@cardIndex].get('priority')
        # Robot whose card has higher priority will play first.
        if priority1 < priority2
          return 1 
        else if priority1 < priority2
          return -1
        else
          return 0 # TODO: What to do if the priorities are equal?
      )
      # Return sorted array of robots.
      return robots

    isGameOver: ->
      return true

    isTurnOver: ->
      return @cardIndex >= 4 # number of selected cards

    isCardOver: ->
      return @robotIndex >= @getSortedRobots().length

    isRobotPlaced: ->
      return @getSortedRobots()[@robotIndex].isPlaced()



  class Game::States
    isUserActionRequired: ->
      return false

  # Initial game state. This state is active only immediately after the game 
  # is loaded.
  class Game::States::GameStart
    isUserActionRequired: ->
      return not @started

    next: ->
       @state.transition("TurnNext")

  class Game::States::GameOver
    next: ->
      @started = false
      @state.transition("GameStart")



  # Deal cards and let player to select some.
  class Game::States::TurnNext
    next: ->
      @cardIndex = 0
      @state.transition("TurnPlay")
  
  # Cards are selected, play the turn. 
  # Move robots according to their cards and than move the board.  
  # Repeat the process until all cards of all robots have been played.
  class Game::States::TurnPlay
    next: ->
      @state.transition("CardNext")

  class Game::States::TurnOver
    next: ->
      if @isGameOver
        @state.transition("GameOver")
      else
        @state.transition("TurnNext")



  class Game::States::CardNext
    next: ->
      @robotIndex = 0
      @state.transition("CardPlay")

  class Game::States::CardPlay
    next: ->
      @state.transition("RobotNext")

  class Game::States::CardOver
    next: ->
      @cardIndex++
      if @isTurnOver()
        @state.transition("TurnOver")
      else
        @state.transition("CardNext")



  class Game::States::RobotNext
    next: ->
      if @isRobotPlaced()
        @state.transition("RobotPlay")
      else
        @state.transition("RobotPlace")
  
  class Game::States::RobotPlace
    isUserActionRequired: ->
      return not @isRobotPlaced()

    next: ->
      @state.transition("RobotPlay")

  class Game::States::RobotPlay
    next: ->
      robot = @getSortedRobots()[@robotIndex]
      cards = robot.get 'cards'
      card = cards[@cardIndex]
      ml = new MultiLock (=> @state.transition("RobotOver") ), 5000
      unlock = ml.getLock "Card"
      card.playOnRobot robot, {lock: ml.getLock}
      unlock()
  
  class Game::States::RobotOver
    next: ->
      @robotIndex++
      if @isCardOver()
        @state.transition("BoardStart")
      else
        @state.transition("RobotNext")
  


  class Game::States::BoardStart
    next: ->
      @state.transition("BoardActive")
  
  class Game::States::BoardActive
    next: ->
      @board().activateBoardLocking({}, (=> @state.transition("BoardOver")), 5000)
  
  class Game::States::BoardOver
    next: ->
      if @isCardOver
        @state.transition("CardOver")
      else
        @state.transition("CardNext")

  module.exports = Game
