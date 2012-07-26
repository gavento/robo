define (require, exports, module) ->

  SubclassTypes = require "cs!app/lib/SubclassTypes"
  Direction = require "cs!app/lib/Direction"


  class Entity extends Spine.Model
    @configure 'Entity'
    @extend SubclassTypes
    @typeMap = {}
    @registerType "_"

    constructor: ->
      super

    getPhases: -> []
    isMovable: -> false
    isRobot: -> false

    # adds Entity to tile
    place: (tile) ->
      if @tile
        @lift()
      @x = tile.x
      @y = tile.y
      @tile = tile
      @board = tile.board
      tile.addEntity @
      @trigger 'update'
      @trigger 'place'

    # removes entity from @tile
    lift: ->
      throw 'entity not placed' unless @tile
      @tile.delEntity @
      delete @x
      delete @y
      delete @tile
      # keep @board
      @trigger 'update'
      @trigger 'lift'

    destroy: ->
      if @tile
        throw 'destroying a placed tile'
      super

    activate: (phase) ->
      console.log "activated #{@} in phase #{phase}"
      @trigger "activate"

  class Robot extends Entity
    @configure 'Robot', 'name', 'dir'
    @registerType "Robot"

    constructor: ->
      super

    isMovable: -> true
    isRobot: -> true

    dir: (val) ->
      if not val
        return @dir
      if val instanceof Direction
        @dir = val
      @dir = new Direction val



  class Conveyor extends Entity
    @configure 'Conveyor', 'dir'
    @registerType "C"

    getPhases: -> [20]

    dir: (val) ->
      if not val
        return @dir
      if val instanceof Direction
        @dir = val
      @dir = new Direction val

    activate: (phase) ->
      super
      tx = @x + @dir.dx()
      ty = @y + @dir.dy()
      target = @board.getTile tx, ty
      if target
        for e in @tile.entities()
          if e.isMovable()
            e.place target

  class ExpressConveyor extends Conveyor
    @configure 'ExpressConveyor', 'dir'
    @registerType "E"

    getPhases: -> [18, 22]


  load = (attr) ->
    throw "type required" unless attr.type
    con = Entity.getType attr.type
    delete attr.type
    return new con attr


  module.exports =
    load: load
    Entity: Entity
    Robot: Robot
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
