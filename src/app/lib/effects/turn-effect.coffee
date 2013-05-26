define (require, exports, module) ->
  
  Effect = require 'cs!app/lib/effects/effect'
  
  class TurnEffect extends Effect
      
    @createEffect: (board, entity, cause, amount) ->
      effect = new @(entity, cause, amount)
      return effect

    applyEffect: (opts, callback) ->
      optsCopy = Object.create opts
      optsCopy.oldDir = @direction
      optsCopy.dir = @amount
      optsCopy.mover = @getPrimaryCause()
      @entity.rotate(optsCopy, callback)

    constructor: (entity, cause, @amount) ->
      @direction = entity.dir().copy()
      super entity, cause

    @handleEffects: (effects, opts, callback) ->
      @applyEffects(effects, opts, callback)

