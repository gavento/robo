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
    isPushable: -> false
    isRobot: -> false

    placed: (tile) ->
      @x = tile.x
      @y = tile.y
      @tile = tile
      @board = tile.board

    lifted: ->
      delete @x
      delete @y
      delete @tile
      # keep @board

    activate: (phase) ->
      console.log "activated #{@} in phase #{phase}"
      @trigger "activate"

  class Robot extends Entity
    @configure 'Robot', 'name', 'dir'
    @registerType "R"

    constructor: ->
      super

    isPushable: -> true
    isRobot: -> true


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
