define (require, exports, module) ->
  
  class Effect
    constructor: (@entity, @cause) ->
      @source = null
      @targets = []
      @valid = true

    isFirst: ->
      return @source == null

    isLast: ->
      return @targets.length == 0

    isValid: ->
      return @valid

    invalidate: ->
      @valid = false
    
  module.exports = Effect
