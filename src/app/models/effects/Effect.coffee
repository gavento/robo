define (require, exports, module) ->
  
  class Effect
    constructor: (@entity, @cause) ->
      @source = null
      @targets = []
      @valid = true

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
    
  module.exports = Effect
