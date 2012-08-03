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
      super

    damage: (opts) ->
      throw "opts.damage required" unless opts? and opts.damage?
      @health -= opts.damage
      @trigger "damage", opts
      @trigger "update"

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

    turn: (opts) ->
      console.log @, " turns ", opts
      throw "opts.dir required" unless opts? and opts.dir?
      @get('dir').turnRight(opts.dir)
      # todo: animate
      @trigger "update"


  module.exports = Robot
