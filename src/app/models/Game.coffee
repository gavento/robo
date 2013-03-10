define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/SimpleModel'
  Board = require 'cs!app/models/Board'
  Deck = require 'cs!app/models/Deck'
  Player = require 'cs!app/models/Player'
  Stateful = require 'cs!app/lib/Stateful'

  class Game extends SimpleModel
    @configure {name: 'Game'}, 'name', 'board', 'players'
    @typedProperty 'board', Board
    @typedProperty 'deck', Deck
    @typedPropertyArrayEx 'players',
      (v) -> v instanceof Player,
      (v) -> v.game = @; new Player v

    constructor: ->
      super
      if not @deck_
        # if no deck is specified, load the default deck
        json = 'text!app/default_deck.json'
        require [json], =>
          data = arguments[0]
          throw "Default deck could not be read" unless data
          @deck_ = Deck.fromJSON data
          throw "Default deck not loaded" unless @deck_
          # TODO: make sure that the game can not start before the deck
          #       is loaded
          @trigger 'game:loaded'

      # Current turn of the game.
      @turnIndex = 0
      # Index of currently played card.
      @cardIndex = 0
      # Index of currently active robot.
      @robotIndex = 0
      @started = false
      @state = new Stateful(@, 'GameStart', new Game::States)
      @bindEvent 'state:entered', @run

    # Run or the game from current state.
    run: ->
      if @isUserActionRequired()
        @trigger 'game:interrupt'
      else
        @trigger 'game:continue'
        @next()

    # Continue the game after user interaction.
    continue: ->
      if not @started
        @started = true
      @run()

    getActiveCard: (robot) ->
      robot ?= @getActiveRobot()
      if robot
        cards = robot.get('cards')
        if cards? and @cardIndex >= 0 and @cardIndex < cards.length
          return cards[@cardIndex]
      return null

    getActiveRobot: ->
      robots = @getSortedRobots()
      if @robotIndex >= 0 and @robotIndex < robots.length
        return robots[@robotIndex]
      return null

    getSortedRobots: ->
      # Get all robots of all players.
      robots = @getPlayerRobots()
      getPriority = (robot, cardIndex) ->
        cards = robot.get('cards')
        if cards? and cards.length > cardIndex
          return cards[cardIndex].get('priority')
        else
          return 0
      # Sort robots according to priority of current card.
      robots.sort( (robot1, robot2) =>
        priority1 = getPriority(robot1, @cardIndex)
        priority2 = getPriority(robot2, @cardIndex)
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
    
    getRobotsWithDynamicCards: ->
      return (r for r in @getPlayerRobots() when not r.hasFixedCards())

    getPlayerRobots: ->
      robots = []
      for player in @get 'players'
        for robot in player.get 'robots'
          robots.push robot
      return robots

    isGameOver: ->
      return true

    isTurnOver: ->
      robots = @getSortedRobots()
      lengths = (robot.get('cards').length for robot in robots)
      lengths.push(0) # to ensure that the array is not empty
      maximum = Math.max(lengths...)
      return @cardIndex >= maximum # number of selected cards

    isCardOver: ->
      return @robotIndex >= @getSortedRobots().length

    isRobotPlaced: ->
      return @getSortedRobots()[@robotIndex].isPlaced()
    
    canRobotBePlaced: ->
      return @getSortedRobots()[@robotIndex].canBePlaced()


  class Interface
    isUserActionRequired: -> return false
    next: ->

  class Game::States

  # Initial game state. This state is active only immediately after the game 
  # is loaded.
  class Game::States::GameStart extends Interface
    isUserActionRequired: ->
      return not @started

    next: ->
       @state.transition("TurnNext")

  class Game::States::GameOver extends Interface
    next: ->
      @started = false
      @state.transition("GameStart")



  # Discard old cards and draw new cards.
  class Game::States::TurnNext extends Interface
    next: ->
      @cardIndex = 0
      robots = @getRobotsWithDynamicCards()
      if robots.length > 0
        discardCards = (robot, cb) =>
          robot.discardCards @deck_, {}, cb
        drawCards = (robot, cb) =>
          robot.drawCards @deck_, {}, cb
        discardAllCards = (cb) =>
          async.forEach robots, discardCards, cb
        drawAllCards = (cb) =>
          async.forEach robots, drawCards, cb
        shuffle = (cb) =>
          @deck_.shuffle()
          cb()
        async.series [discardAllCards, shuffle, drawAllCards],
          => @state.transition("TurnPlay")
      else
        @state.transition("TurnPlay")

  # Let user to select cards. 
  # Repeat the process until all cards of all robots have been played.
  class Game::States::TurnPlay extends Interface
    next: ->
      @state.transition("CardNext")

  class Game::States::TurnOver extends Interface
    next: ->
      if @isGameOver
        @state.transition("GameOver")
      else
        @state.transition("TurnNext")



  class Game::States::CardNext extends Interface
    next: ->
      @robotIndex = 0
      if @isCardOver()
        @state.transition("BoardStart")
      else
        @state.transition("CardPlay")

  class Game::States::CardPlay extends Interface
    next: ->
      @state.transition("RobotNext")

  class Game::States::CardOver extends Interface
    next: ->
      @cardIndex++
      if @isTurnOver()
        @state.transition("TurnOver")
      else
        @state.transition("CardNext")



  class Game::States::RobotNext extends Interface
    next: ->
      if @isRobotPlaced()
        @state.transition("RobotPlay")
      else
        @state.transition("RobotPlace")
  
  class Game::States::RobotPlace extends Interface
    isUserActionRequired: ->
      return not @isRobotPlaced() and not @canRobotBePlaced()

    next: ->
      robot = @getSortedRobots()[@robotIndex]
      robot.place({}, => @state.transition("RobotPlay"))

  class Game::States::RobotPlay extends Interface
    next: ->
      robot = @getActiveRobot()
      if robot
        card = @getActiveCard(robot)
        if card
          card.playOnRobot(robot, {}, => @state.transition("RobotOver"))
        else
          @state.transition("RobotOver")
      else
        @state.transition("RobotOver")

  class Game::States::RobotOver extends Interface
    next: ->
      @robotIndex++
      if @isCardOver()
        @state.transition("BoardStart")
      else
        @state.transition("RobotNext")
  


  class Game::States::BoardStart extends Interface
    next: ->
      @state.transition("BoardActive")
  
  class Game::States::BoardActive extends Interface
    next: ->
      @board().activateBoard({}, (=> @state.transition("BoardOver")))
  
  class Game::States::BoardOver extends Interface
    next: ->
      if @isCardOver
        @state.transition("CardOver")
      else
        @state.transition("CardNext")

  module.exports = Game
