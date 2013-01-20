define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"


  class Conveyor extends Entity
    @configure {name:'Conveyor', subClass:true, registerAs: 'C'}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [20]

    activate: (opts, callback) ->
      affectEntitiesOnNeighbouringTile = (effect, x, y, direction) =>
        tx = x + direction.dx()
        ty = y + direction.dy()
        for entity in @board.getPushableEntitiesAt(tx, ty)
          chainedEffect = Effect.newChainedEffect(entity, direction, effect)
          opts.effects.push(chainedEffect)
          affectEntitiesOnNeighbouringTile(chainedEffect, tx, ty, direction)
      affectEntitiesOnThisTile = () =>
        direction = @dir()
        for entity in @board.getMovableEntitiesAt(@x, @y)
          effect = Effect.newInitialEffect(entity, @, direction)
          opts.effects.push(effect)
          if entity.canPush()
            affectEntitiesOnNeighbouringTile(effect, @x, @y, direction)
      affectEntitiesOnThisTile()
      super opts, callback
    
      
    class Effect
      constructor: (@entity, @cause) ->
        @source = null
        @targets = []
        @direction = null

      @newInitialEffect: (entity, cause, direction) ->
        effect = new @(entity, cause)
        effect.direction = direction
        return effect

      @newChainedEffect: (entity, direction, source) ->
        effect = @newInitialEffect(entity, entity.cause, direction)
        effect.source = source
        source.targets.push(effect)
        return effect
    
      isFirst: ->
        return @source == null

      isLast: ->
        return @targets.length == 0

      applyEffect: (opts, callback) ->
        tx = @entity.x + @direction.dx()
        ty = @entity.y + @direction.dy()
        optsC = Object.create opts
        optsC.x = tx
        optsC.y = ty
        optsC.mover = @cause
        @entity.move(optsC, callback)

      # This is a dirty solution, it should be a static method
      # but this way it is easier, any effect can handle all effects.
      # It should be refactored after effects are functional.
      handleEffects: (effects, opts, callback) ->
        console.log effects
        applyEffects = (effects, cb) =>
          async.forEach(effects, applyEffect, cb)
        applyEffect = (effect, cb) =>
          effect.applyEffect(opts, cb)
        # This is the same as the previous behaviour, pushing is disabled.
        filteredEffects = (effect for effect in effects when effect.isFirst())
        applyEffects(filteredEffects, callback)


  class ExpressConveyor extends Conveyor
    @configure {name:'ExpressConveyor', subClass:true, registerAs: 'E'}

    getPhases: -> [18, 22]


  class Crusher extends Entity
    @configure {name:'Crusher', subClass:true, registerAs: 'X'}

    getPhases: -> [50]

    activate: (opts, callback) ->
      # Crush (damage) all entities on this turner.
      entities = @board.getRobotEntitiesAt(@x, @y)
      crushEntities = (cb) =>
        async.forEach(entities, crushEntity, cb)
      crushEntity = (entity, cb) =>
        optsC = Object.create opts
        optsC.damage = 1
        optsC.source = @
        entity.damage(optsC, cb)
      opts.afterHooks.push(crushEntities)
      super opts, callback


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
      # Change direction of the turner itself.
      dir.turn(@turnDirection)
      # Rotate all movable entities on this turner.
      entities = @board.getMovableEntitiesAt(@x, @y)
      rotateEntities = (cb) =>
        async.forEach(entities, rotateEntity, cb)
      rotateEntity = (entity, cb) =>
        optsC = Object.create opts
        optsC.mover = @
        optsC.dir = @turnDirection
        entity.rotate(optsC, cb)
      opts.afterHooks.push(rotateEntities)
      super optsC, callback


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
    @configure {name:'Wall', subClass:true, registerAs: 'W'}
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
