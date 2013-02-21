define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"
  Card = require "cs!app/models/Card"

  class Robot extends Entity
    @configure {name:'Robot', subClass: true, registerAs: 'Robot'}, 'name', 'dir', 'image', 'cards', 'health'
    @typedProperty 'dir', Direction, 'dir_'
    @typedPropertyArray 'cards', Card, 'cards_'

    constructor: ->
      @cards_ ?= []
      @dir_ ?= new Direction(0)
      @placed = true
      super
      @respawnX = @x
      @respawnY = @y
      @respawnDir = @dir().copy()

    damage: (opts, callback) ->
      throw 'opts.damage required' unless opts? and opts.damage?
      @health -= opts.damage
      @triggerLockedEvent('robot:damage', opts, callback)

    fall: (opts, callback) ->
      throw "opts.dir required" unless opts?
      optsC = Object.create opts
      optsC.entity = @
      optsC.dir = 8
      optsC.oldDir = (@get "dir").copy()
      (@get "dir").turnRight optsC.dir
      @placed = false
      @triggerLockedEvent('robot:fall', optsC, callback)

    # Returns true if the robot is currently placed on the board.
    # Returns false if the robot is not on the board. It happens
    # at the begining of the game, when the robot falls into a
    # hole or when it is heavily damaged.
    isPlaced: -> @placed

    # Place the robot at position `opts.x`, `opts.y`. If no coordinates are
    # specified than the robot will be placed on its respawn point.
    place: (opts, callback) ->
      if not @isPlaced()
        # Only robot that is not placed can be placed.
        optsC = Object.create opts
        optsC.entity = @
        optsC.oldX = @x
        optsC.oldY = @y
        if opts? and opts.x? and opts.y?
          @x = opts.x
          @y = opts.y
        else # TODO: respawn point
          @x = 3
          @y = 2
        @placed = true
        @triggerLockedEvent('robot:place', optsC, callback)
      else
        throw 'Placing robot that is already placed.'

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

    setRespawnDirection: (direction) ->
      @respawnDir = new Direction(direction)
      @triggerLockedEvent('robot:respawn:changed', {}, -> )

  module.exports = Robot
