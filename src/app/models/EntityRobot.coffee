define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"
  RespawnPosition = require "cs!app/models/RespawnPosition"
  Card = require "cs!app/models/Card"

  class Robot extends Entity
    @configure {name:'Robot', subClass: true, registerAs: 'Robot'},
      'name', 'dir', 'image', 'cards', 'health', 'fixedCards'
    @typedProperty 'dir', Direction, 'dir_'
    @typedProperty 'respawnPosition', RespawnPosition, 'respawnPosition_'
    @typedPropertyArray 'cards', Card, 'cards_'

    constructor: ->
      super
      @fixedCards ?= @cards_?
      @cards_ ?= []
      @dir_ ?= new Direction(0)
      @respawnPosition_ ?= new RespawnPosition({x: @x, y: @y, dir: @dir()})
      @placed = true

    damage: (opts, callback) ->
      throw 'opts.damage required' unless opts? and opts.damage?
      @health -= opts.damage
      @triggerLockedEvent('robot:damage', opts, callback)

    fall: (opts, callback) ->
      throw "opts.dir required" unless opts?
      optsC = Object.create opts
      optsC.entity = @
      optsC.oldX = @x
      optsC.oldY = @y
      optsC.oldDir = (@get "dir").copy()
      @x = @respawnPosition_.x
      @y = @respawnPosition_.y
      @dir_.set(@respawnPosition_.dir())
      @placed = false
      @triggerLockedEvent('robot:fall', optsC, callback)

    # Returns true if the robot is currently placed on the board.
    # Returns false if the robot is not on the board. It happens
    # at the begining of the game, when the robot falls into a
    # hole or when it is heavily damaged.
    isPlaced: -> @placed
    canBePlaced: -> @respawnPosition_.isConfirmed()

    # Place the robot at its respawn point.
    # Robot must not be already placed.
    place: (opts, callback) ->
      if not @isPlaced()
        @placed = true
        @respawnPosition_.unconfirm()
        # Only robot that is not placed can be placed.
        optsC = Object.create opts
        optsC.entity = @
        @triggerLockedEvent('robot:place', optsC, callback)
      else
        throw 'Placing robot that is already placed.'

    confirmRespawnDirection: (direction) ->
      @respawnPosition_.confirmDirection(direction)
      opts =
        oldDir: @dir_.copy()
      @dir_.set(direction)
      @triggerLockedEvent('robot:respawn:confirmed', opts, -> )

    isMovable: -> true
    isPushable: -> true
    isTurnable: -> true
    isRobot: -> true

    step: (opts, callback) ->
      opts ?= {}
      tx = @x + @get('dir').dx()
      ty = @y + @get('dir').dy()
      # The computed position may be outside of the board. In that
      # case the robot will fall.
      opts.x = tx
      opts.y = ty
      @move opts, callback
  
    # Turning and the aliases. turn and turnRight are the same
    turn: (opts, callback) ->
      @rotate opts, callback

    turnRight: (opts, callback) ->
      @turn opts, callback

    turnLeft: (opts, callback) ->
      optsC = Object.create opts
      optsC.dir = -opts.dir
      @turn optsC, callback

    hasFixedCards: ->
      return @fixedCards

    drawCards: (deck, opts, callback) ->
      cards = deck.drawCards 4
      @cards_.push cards...
      @triggerLockedEvent 'robot:cards:drawn', opts, callback

    discardCards: (deck, opts, callback) ->
      cards = @cards_
      @cards_ = []
      deck.discardCards cards
      @triggerLockedEvent 'robot:cards:discarded', opts, callback

  module.exports = Robot
