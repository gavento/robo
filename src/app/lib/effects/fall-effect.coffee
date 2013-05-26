define (require, exports, module) ->
  
  Effect = require 'cs!app/lib/effects/effect'
  
  class FallEffect extends Effect
      
    @createEffect: (board, entity, cause) ->
      effect = new @(entity, cause)
      return effect

    applyEffect: (opts, callback) ->
      fall = (cb) =>
        @entity.fall(opts, cb)
      damage = (cb) =>
        optsC = Object.create opts
        optsC.damage = 1
        optsC.source = @
        @entity.damage(optsC, cb)
      async.parallel([fall, damage], callback)

    constructor: (entity, cause) ->
      super entity, cause

    @handleEffects: (effects, opts, callback) ->
      @applyEffects(effects, opts, callback)

