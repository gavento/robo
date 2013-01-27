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
    
  module.exports = Effect
