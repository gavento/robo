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

    activate: (opts) ->
      super
      for e in @board.tile @x, @y
        if e.isRobot()
          e.damage {damage: 1, source: @}


  class Turner extends Entity
    @configure {name:'Turner', subClass:true}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [40]
    turnDirection: 0

    # this is simple and naive
    activate: (opts) ->
      super
      for e in @board.tile @x, @y
        if e.isMovable()
          optsC = Object.create opts
          optsC.mover = @
          optsC.dir = @turnDirection
          e.rotate optsC
      optsC = Object.create opts
      optsC.dir = @turnDirection
      optsC.mover = @
      @rotate optsC


  class TurnerR extends Turner
    @configure {name:'TurnerR', subClass:true, registerAs: 'R'}
    turnDirection: 1


  class TurnerL extends Turner
    @configure {name:'TurnerL', subClass:true, registerAs: 'L'}
    turnDirection: -1


  class TurnerU extends Turner
    @configure {name:'TurnerU', subClass:true, registerAs: 'U'}
    turnDirection: 2


  module.exports =
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
    Crusher: Crusher
    Turner: Turner
    TurnerR: TurnerR
    TurnerL: TurnerL
    TurnerU: TurnerU
