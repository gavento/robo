define (require, exports, module) ->
  
  MoveEffect = require 'cs!app/models/effects/MoveEffect'
  TurnEffect = require 'cs!app/models/effects/TurnEffect'
  CrushEffect = require 'cs!app/models/effects/CrushEffect'
  FallEffect = require 'cs!app/models/effects/FallEffect'
  
  class EffectFactory
    @createMoveEffectChain: (board, entity, cause, direction) ->
      return MoveEffect.createEffect(board, entity, cause, direction)

    @createTurnEffectChain: (board, entity, cause, amount) ->
      return TurnEffect.createEffect(board, entity, cause, amount)

    @createCrushEffectChain: (board, entity, cause, damage) ->
      return CrushEffect.createEffect(board, entity, cause, damage)
    
    @createFallEffectChain: (board, entity, cause) ->
      return FallEffect.createEffect(board, entity, cause)

    @handleAllEffects: (effects, opts, callback) ->
      effectsByType = @divideEffectByType(effects)
      handleEffectsOfAllTypes = (effects, cb) =>
        async.forEach(effects, handleEffectsOfSingleType, cb)
      handleEffectsOfSingleType = (effects, cb) =>
        effects[0].constructor.handleEffects(effects, opts, cb)
      handleEffectsOfAllTypes(effectsByType, callback)

    @divideEffectByType: (effects) ->
      effectsByType = []
      while effects.length > 0
        firstEffectType = effects[0].constructor
        effectsOfOneType = @filterEffectsOfSameTypes(effects, firstEffectType)
        effects = @filterEffectsOfDifferentTypes(effects, firstEffectType)
        effectsOfOneType = @splitEffects(effectsOfOneType)
        effectsByType.push(effectsOfOneType)
      return effectsByType

    @filterEffectsOfSameTypes: (effects, type) ->
      return (e for e in effects when e instanceof type)
    
    @filterEffectsOfDifferentTypes: (effects, type) ->
      return (e for e in effects when e not instanceof type)

    @splitEffects: (effects) ->
      splittedEffects = []
      for effect in effects
        splittedEffects.push(@splitEffect(effect)...)
      return splittedEffects

    @splitEffect: (effect) ->
      splittedEffects = [effect]
      for targetEffect in effect.targets
        splittedEffects.push(@splitEffect(targetEffect)...)
      return splittedEffects


  module.exports = EffectFactory

