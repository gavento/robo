define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"


  class Conveyor extends Entity
    @configure {name:'Conveyor', subClass:true, registerAs: 'C'}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [20]

    # this is VERY simple and naive
    activate: (opts) ->
      super
      tx = @x + @dir().dx()
      ty = @y + @dir().dy()
      if @board.inside tx, ty
        for e in @board.tile @x, @y
          if e.isMovable()
            opts.afterHooks.push =>
              oc = Object.create opts
              oc.x = tx
              oc.y = ty
              oc.mover = @
              e.move oc


  class ExpressConveyor extends Conveyor
    @configure {name:'ExpressConveyor', subClass:true, registerAs: 'E'}

    getPhases: -> [18, 22]


  class Crusher extends Entity
    @configure {name:'Crusher', subClass:true, registerAs: 'X'}

    getPhases: -> [50]

    activate: (phase) ->
      super
      for e in @board.tile @x, @y
        if e.isRobot()
          e.damage {damage: 1, source: @}


  module.exports =
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
    Crusher: Crusher
