define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/SimpleModel'
  Board = require 'cs!app/models/Board'
  Deck = require 'cs!app/models/Deck'
  Player = require 'cs!app/models/Player'
  Stateful = require 'cs!app/lib/Stateful'
  async = require 'async'

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
        json = 'text!json/default_deck.json'
        require [json], =>
          data = arguments[0]
          throw 'Default deck could not be read' unless data
          @deck_ = Deck.fromJSON data
          throw 'Default deck not loaded' unless @deck_
          # TODO: make sure that the game can not start before the deck
          #       is loaded
          @trigger 'game:loaded'

      # Current turn of the game.
      @turnIndex = 0
      # Robots sorted by priorities of currently active cards.
      @sortedRobots = []
      @started = false
      @state = new Stateful(@, 'GameStart', new Game::States)
      @bindEvent 'state:entered', @run

    # Run or the game from current state.
    run: ->
      if @isUserActionRequired()
        @trigger 'game:interrupt'
      else
        @trigger 'game:continue'
        async.nextTick => @next()

    # Continue the game after user interaction.
    continue: ->
      if not @started
        @started = true
      else if @state.current == 'ChooseCards'
        @confirmOrderOfCards()
      else if @state.current == 'PlaceRobot'
        robot = @getActiveRobot()
        if not robot.canBePlaced()
          robot.confirmRespawnDirection()
      @run()

    getActiveCard: (robot) ->
      robot ?= @getActiveRobot()
      if robot
        cards = robot.cards
        if cards? and @cardIndex >= 0 and @cardIndex < cards.length
          return cards.at @cardIndex
      return null

    getActiveRobot: ->
      @sortedRobots[0]
      if @sortedRobots.length > 0
        return @sortedRobots[0]
      else
        return null

    nextRobot: ->
      robot = @sortedRobots[0]
      @sortedRobots = @sortedRobots[1..]
      return robot

    sortRobots: ->
      getPriority = (robot, cardIndex) ->
        cards = robot.cards()
        card = cards.nextCard()
        if card
          return card.priority
        else
          return 0
      sortByPriority = (robot1, robot2) =>
        priority1 = getPriority(robot1, @cardIndex)
        priority2 = getPriority(robot2, @cardIndex)
        # Robot whose card has higher priority will play first.
        if priority1 < priority2
          return 1
        else if priority1 < priority2
          return -1
        else
          return 0 # TODO: What to do if the priorities are equal?
      # Get all robots that have at least one unplayed card
      # and sort them by priority of the first card.
      robots = @getRobotsWithNextCard()
      robots.sort(sortByPriority)
      @sortedRobots = robots
    
    getRobotsWithNextCard: ->
      robots = (r for r in @getPlayerRobots() when r.cards().nextCard())
      return robots

    getPlayerRobots: ->
      robots = []
      for player in @get 'players'
        for robot in player.get 'robots'
          robots.push robot
      return robots

    isGameOver: ->
      livingRobots = (r for r in @getPlayerRobots() when r.health > 0)
      return livingRobots.length <= 0

    isTurnOver: ->
      robots = @getRobotsWithNextCard()
      return robots.length <= 0

    isRoundOver: ->
      return @sortedRobots.length <= 0

    isRobotPlaced: ->
      return @sortedRobots[0].isPlaced()
    
    canRobotBePlaced: ->
      return @sortedRobots[0].canBePlaced()
    
    confirmOrderOfCards: ->
      robots = @getPlayerRobots()
      for robot in robots
        cards = robot.cards()
        cards.confirmOrder()

    isOrderOfCardsConfirmed: ->
      robots = @getPlayerRobots()
      for robot in robots
        cards = robot.cards()
        if not cards.isOrderConfirmed()
          return false
      return true


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
       @state.transition('NextTurn')

  class Game::States::GameOver extends Interface
    next: ->
      @started = false
      @state.transition('GameStart')



  class Game::States::NextTurn extends Interface
    next: ->
      if @isGameOver()
        @state.transition('GameOver')
      else
        @state.transition('DrawCards')

  # Discard old cards and draw new cards.
  class Game::States::DrawCards extends Interface
    next: ->
      robots = @getPlayerRobots()
      discardCards = (robot, cb) =>
        robot.cards().discardDrawnCards @deck_, {}, cb
      discardAllCards = (cb) =>
        async.forEach robots, discardCards, cb
      shuffle = (cb) =>
        @deck_.shuffle()
        cb()
      drawCards = (robot, cb) =>
        robot.cards().drawCards @deck_, {}, cb
      drawAllCards = (cb) =>
        async.forEach robots, drawCards, cb
      async.series [discardAllCards, shuffle, drawAllCards],
        => @state.transition('ChooseCards')

  # Let user to select some cards. Than discard the rest.
  class Game::States::ChooseCards extends Interface
    isUserActionRequired: ->
      return not @isOrderOfCardsConfirmed()
    
    next: ->
      robots = @getPlayerRobots()
      discardCards = (robot, cb) =>
        robot.cards().discardUnplannedCards @deck_, {}, cb
      async.forEach robots, discardCards, => @state.transition('NextRound')



  class Game::States::NextRound extends Interface
    next: ->
      @sortRobots()
      if @isTurnOver()
        @state.transition('NextTurn')
      else
        @state.transition('NextRobot')


  class Game::States::NextRobot extends Interface
    next: ->
      if @isRoundOver()
        @state.transition('ActivateBoard')
      else if @isRobotPlaced()
        @state.transition('PlayRobot')
      else
        @state.transition('PlaceRobot')
  
  class Game::States::PlaceRobot extends Interface
    isUserActionRequired: ->
      return not @isRobotPlaced() and not @canRobotBePlaced()

    next: ->
      robot = @getActiveRobot()
      robot.place {}, => @state.transition('PlayRobot')

  class Game::States::PlayRobot extends Interface
    next: ->
      robot = @nextRobot()
      cards = robot.cards()
      cards.playNextCard(robot, {}, => @state.transition('NextRobot'))

  class Game::States::ActivateBoard extends Interface
    next: ->
      @board().activateBoard {}, => @state.transition('NextRound')


  module.exports = Game
