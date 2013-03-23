define (require, exports, module) ->

  EffectFactory = require 'cs!app/models/effects/EffectFactory'
  Entity = require 'cs!app/models/Entity'
  Direction = require 'cs!app/lib/Direction'


  class Conveyor extends Entity
    @configure {name:'Conveyor', subClass:true, registerAs: 'C'}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [20]

    activate: (opts, callback) ->
      for entity in @board.getMovableEntitiesAt(@x, @y)
        effect = EffectFactory.createMoveEffectChain(@board, entity, @, @dir())
        opts.effects.push(effect)
      super opts, callback


  class ExpressConveyor extends Conveyor
    @configure {name:'ExpressConveyor', subClass:true, registerAs: 'E'}

    getPhases: -> [18, 22]


  class Crusher extends Entity
    @configure {name:'Crusher', subClass:true, registerAs: 'X'}

    getPhases: -> [50]

    activate: (opts, callback) ->
      for entity in @board.getCrushableEntitiesAt(@x, @y)
        effect = EffectFactory.createCrushEffectChain(@board, entity, @, 1)
        opts.effects.push(effect)
      super opts, callback


  class Turner extends Entity
    @configure {name:'Turner', subClass:true}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [40]
    turnDirection: 0

    activate: (opts, callback) ->
      for entity in @board.getTurnableEntitiesAt(@x, @y)
        effect = EffectFactory.createTurnEffectChain(
          @board, entity, @, @turnDirection)
        opts.effects.push(effect)
      # Rotate the turner itself.
      optsCopy = Object.create opts
      optsCopy.oldDir = @dir().copy()
      optsCopy.dir = @turnDirection
      optsCopy.mover = @
      @dir().turn(@turnDirection)
      super optsCopy, callback


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

    hasImmediateEffect: -> true

    activate: (opts, callback) ->
      x = opts.x
      y = opts.y
      entities = @board.getMovableEntitiesAt(x, y)
      fallEntities = (cb) =>
        async.forEach(entities, fallEntity, cb)
      fallEntity = (entity, cb) =>
        optsC = Object.create opts
        optsC.duration = 500
        async.parallel([
          (cb2) => entity.fall(optsC, cb2),
          (cb2) => entity.damage({damage:1, source: @}, cb2)],
          cb)
      opts.afterHooks.push(fallEntities)
      super opts, callback

  class Wall extends Entity
    @configure {name:'Wall', subClass:true, registerAs: 'W'}, 'dir'
    @typedProperty 'dir', Direction

  module.exports =
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
    Crusher: Crusher
    Turner: Turner
    TurnerR: TurnerR
    TurnerL: TurnerL
    TurnerU: TurnerU
    Hole: Hole
    Wall: Wall
