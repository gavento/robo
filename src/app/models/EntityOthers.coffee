define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"

  class Conveyor extends Entity
    @configure {name:'Conveyor', subClass:true, registerAs: 'C'}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [20]

    # this is VERY simple and naive
    activate: (phase) ->
      super
      tx = @x + @dir().dx()
      ty = @y + @dir().dy()
      target = @board.getTile tx, ty
      if target
        for e in @tile.entities()
          if e.isMovable()
            @board.afterPhase.push ->
              e.place target

  class ExpressConveyor extends Conveyor
    @configure {name:'ExpressConveyor', subClass:true, registerAs: 'E'}

    getPhases: -> [18, 22]

  module.exports =
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
