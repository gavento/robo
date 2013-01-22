define (require, exports, module) ->
  
  MoveEffect = require 'cs!app/models/effects/MoveEffect'
  
  class EffectFactory
    @createMoveEffectChain: (board, entity, cause, direction) ->
      return MoveEffect.createEffect(board, entity, cause, direction)

    @handleEffects: (effects, opts, callback) ->
      # For now assume that all effects are MoveEffects
      console.log effects
      applyEffects = (effects, cb) =>
        async.forEach(effects, applyEffect, cb)
      applyEffect = (effect, cb) =>
        effect.applyEffect(opts, cb)
      # This is the same as the previous behaviour, pushing is disabled.
      filteredEffects = (effect for effect in effects when effect.isFirst())
      applyEffects(filteredEffects, callback)

  module.exports = EffectFactory

