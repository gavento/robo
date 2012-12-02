define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"


  class Conveyor extends Entity
    @configure {name:'Conveyor', subClass:true, registerAs: 'C'}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [20]

    # this is VERY simple and naive
    activate: (opts, callback) ->
      super
      tx = @x + @dir().dx()
      ty = @y + @dir().dy()
      # For now, the conveyor can not move entity outside of the board.
      if not @board.inside tx, ty
        callback(null)
        return

      # Move all movable entities on this tile.
      # But not right now, just create functions to move them. These
      # functions will be executed after all entities are activated.
      # Otherwise a robot would be moved by all successive conveyors.
      for e in @board.tile @x, @y
        if e.isMovable()
          opts.afterHooks.push( (cb2) =>
            optsC = Object.create opts
            optsC.x = tx
            optsC.y = ty
            optsC.mover = @
            e.move optsC, cb2)


  class ExpressConveyor extends Conveyor
    @configure {name:'ExpressConveyor', subClass:true, registerAs: 'E'}

    getPhases: -> [18, 22]


  class Crusher extends Entity
    @configure {name:'Crusher', subClass:true, registerAs: 'X'}

    getPhases: -> [50]

    activate: (opts, callback) ->
      super

      # Crush (damage) all entities on this turner.
      for e in @board.tile @x, @y
        if e.isRobot()
          opts.afterHooks.push( (cb) =>
            optsC = Object.create opts
            optsC.damage = 1
            optsC.source = @
            e.damage optsC, cb)


  class Turner extends Entity
    @configure {name:'Turner', subClass:true}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [40]
    turnDirection: 0

    # this is simple and naive
    activate: (opts, callback) ->
      dir = (@get "dir")
      optsC = Object.create opts
      optsC.oldDir = dir.copy()
      optsC.dir = @turnDirection
      optsC.mover = @
      super optsC, callback

      # Change direction of the turner itself.
      dir.turn(@turnDirection)

      # Rotate all movable entities on this turner.
      for e in @board.tile @x, @y
        if e.isMovable()
          opts.afterHooks.push((cb) =>
            optsC = Object.create opts
            optsC.mover = @
            optsC.dir = @turnDirection
            e.rotate optsC, cb)


  class TurnerR extends Turner
    @configure {name:'TurnerR', subClass:true, registerAs: 'R'}
    turnDirection: 1


  class TurnerL extends Turner
    @configure {name:'TurnerL', subClass:true, registerAs: 'L'}
    turnDirection: -1


  class TurnerU extends Turner
    @configure {name:'TurnerU', subClass:true, registerAs: 'U'}
    turnDirection: 2


  class Hole extends Entity
    @configure {name:'Hole', subClass:true, registerAs: 'H'}

    isActivatedOnEnter: -> true

    activate: (opts, callback) ->
      super
      for e in @board.tile @x, @y
        if e.isMovable()
          optsC = Object.create opts
          optsC.duration = 500
          # Perform fall and damage in parallel.
          async.parallel(
            [ ((cb2) => e.fall(optsC, cb2)),
              ((cb2) => e.damage({damage:1, source: @}, cb2))],
            callback)


  module.exports =
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
    Crusher: Crusher
    Turner: Turner
    TurnerR: TurnerR
    TurnerL: TurnerL
    TurnerU: TurnerU
    Hole: Hole
