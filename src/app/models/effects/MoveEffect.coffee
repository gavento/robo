define (require, exports, module) ->
  
  Effect = require 'cs!app/models/effects/Effect'
  
  class MoveEffect extends Effect
      
    @createEffect: (board, entity, cause, direction) ->
      effect = new @(entity, cause, direction)
      effect.propagate(board)
      return effect

    constructor: (entity, cause, @direction) ->
      super entity, cause

    propagate: (board) ->
      if @entity.canPush()
        @affectEntitiesOnNeighbouringTile(board)

    appendTo: (effect) ->
      @source = effect
      effect.targets.push(@)

    affectEntitiesOnNeighbouringTile: (board) ->
      nx = @entity.x + @direction.dx()
      ny = @entity.y + @direction.dy()
      for entity in board.getPushableEntitiesAt(nx, ny)
        effect = MoveEffect.createEffect(board, entity, @entity, @direction)
        effect.appendTo(@)

    @handleEffects: (effects, opts, callback) ->
      finalEffects = @filterEffects(effects)
      applyEffects = (effects, cb) =>
        async.forEach(effects, applyEffect, cb)
      applyEffect = (effect, cb) =>
        effect.applyEffect(opts, cb)
      applyEffects(finalEffects, callback)

    @filterEffects: (effects) ->
      effects = @filterOutOppositeEffects(effects)
      finalEffects = (effect for effect in effects when effect.isFirst())
      return finalEffects

    @filterOutOppositeEffects: (effects) ->
      effectsByEntityId = {}
      for effect in effects
        id = effect.getEntityId()
        effectsByEntityId[id] ?= []
        effectsByEntityId[id].push(effect)
      for id of effectsByEntityId
        @invalidateOppositeEffectsOnOneEntity(effectsByEntityId[id])
      effects = @filterOutInvalidEffects(effects)
      return effects

    @invalidateOppositeEffectsOnOneEntity: (effects) ->
      effectsByDirection = [[],[],[],[]]
      for effect in effects
        dir = effect.getDirectionAsNumber()
        effectsByDirection[dir].push(effect)
      north = effectsByDirection[0]
      east = effectsByDirection[1]
      south = effectsByDirection[2]
      west = effectsByDirection[3]
      if north.length > 0 and south.length > 0
        @invalidateEffectChains(north)
        @invalidateEffectChains(south)
      if east.length > 0 and west.length > 0
        @invalidateEffectChains(east)
        @invalidateEffectChains(west)
    
    @invalidateEffectChains: (effects) ->
      for effect in effects
        @invalidateEffectChain(effect)

    @invalidateEffectChain: (effect) ->
      return unless effect.isValid()
      effect.invalidate()
      @invalidateSourceEffectsOf(effect)
      @invalidateTargetEffectsOf(effect)

    @invalidateSourceEffectsOf: (effect) ->
      return unless not effect.isFirst()
      @invalidateEffectChain(effect.source)

    @invalidateTargetEffectsOf: (effect) ->
      return unless not effect.isLast()
      for e in effect.targets
        @invalidateEffectChain(e)
    
    @filterOutInvalidEffects: (effects) ->
      return (e for e in effects when e.isValid())

    applyEffect: (opts, callback) ->
      tx = @entity.x + @direction.dx()
      ty = @entity.y + @direction.dy()
      optsC = Object.create opts
      optsC.x = tx
      optsC.y = ty
      optsC.mover = @cause
      @entity.move(optsC, callback)

  module.exports = MoveEffect
