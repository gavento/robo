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

    damage: (opts) ->
      throw "opts.damage required" unless opts? and opts.damage?
      @health -= opts.damage
      @trigger "damage", opts
      @trigger "update"

    fall: (opts) ->
      throw "opts.dir required" unless opts?
      optsC = Object.create opts
      optsC.entity = @
      optsC.dir = 8
      optsC.oldDir = (@get "dir").copy()
      (@get "dir").turnRight optsC.dir
      @placed = false
      @trigger "fall", optsC

    # Returns true if the robot is currently placed on the board.
    # Returns false if the robot is not on the board. It happens
    # at the begining of the game, when the robot falls into a
    # hole or when it is heavily damaged.
    isPlaced: -> @placed

    # Place the robot at position `opts.x`, `opts.y`. If no coordinates are
    # specified than the robot will be placed on its respawn point.
    place: (opts) ->
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
        @trigger "place", optsC
      else
        throw "Placing robot that is already placed."

    isMovable: -> true
    isRobot: -> true

    step: (opts) ->
      opts ?= {}
      tx = @x + @get('dir').dx()
      ty = @y + @get('dir').dy()
      if @board.inside tx, ty
        opts.x = tx
        opts.y = ty
        @move opts
  
    # Turning and the aliases. turn and turnRight are the same
    turn: (opts) ->
      @rotate opts

    turnRight: (opts) ->
      @turn opts

    turnLeft: (opts) ->
      optsC = Object.create opts
      optsC.dir = -opts.dir
      @turn optsC


  module.exports = Robot
