define (require, exports, module) ->
  
  class Effect
    constructor: (@entity, @cause) ->
      @source = null
      @targets = []
      @valid = true

    appendTo: (effect) ->
      @source = effect
      effect.targets.push(@)

    invalidate: ->
      @valid = false

    isFirst: ->
      return @source == null

    isLast: ->
      return @targets.length == 0

    isValid: ->
      return @valid

    isInvalid: ->
      return not @valid

    getEntityId: ->
      return @entity.id

    getDirectionAsNumber: ->
      return @direction.getNumber()

    getPrimaryCause: ->
      effect = @
      until effect.isFirst()
        effect = effect.source
      return effect.cause
   
    @applyEffects: (effects, opts, callback) ->
      applyOneEffect = (effect, cb) =>
        effect.applyEffect(opts, cb)
      async.forEach(effects, applyOneEffect, callback)

    @invalidateEffectChains: (effects) ->
      for effect in effects
        @invalidateEffectChainOf(effect)

    @invalidateEffectChainOf: (effect) ->
      return unless effect.isValid()
      effect.invalidate()
      @invalidateSourceEffectsOf(effect)
      @invalidateTargetEffectsOf(effect)
    
    @invalidateForwardEffects: (effects) ->
      for effect in effects
        effect.invalidate()
        @invalidateTargetEffectsOf(effect)

    @invalidateSourceEffectsOf: (effect) ->
      return unless not effect.isFirst()
      @invalidateEffectChainOf(effect.source)

    @invalidateTargetEffectsOf: (effect) ->
      return unless not effect.isLast()
      for e in effect.targets
        @invalidateEffectChainOf(e)
    
    @filterOutInvalidEffects: (effects) ->
      return (e for e in effects when e.isValid())

  module.exports = Effect
