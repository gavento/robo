define (require, exports, module) ->
  
  Effect = require 'cs!app/models/effects/Effect'
  
  class CrushEffect extends Effect
      
    @createEffect: (board, entity, cause, damage) ->
      effect = new @(entity, cause, damage)
      return effect

    applyEffect: (opts, callback) ->
      optsCopy = Object.create opts
      optsCopy.damage = @damage
      optsCopy.source = @getPrimaryCause()
      @entity.damage(optsCopy, callback)

    constructor: (entity, cause, @damage) ->
      super entity, cause

    @handleEffects: (effects, opts, callback) ->
      @applyEffects(effects, opts, callback)

