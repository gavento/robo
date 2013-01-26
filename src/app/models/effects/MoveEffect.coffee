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
      @targets.push(effect)

    affectEntitiesOnNeighbouringTile: (board) ->
      nx = @entity.x + @direction.dx()
      ny = @entity.y + @direction.dy()
      for entity in board.getPushableEntitiesAt(nx, ny)
        effect = new MoveEffect(board, entity, @entity, @direction)
        effect.appendTo(@)
        effect.affectEntitiesOnNeighbouringTile(board)

    applyEffect: (opts, callback) ->
      tx = @entity.x + @direction.dx()
      ty = @entity.y + @direction.dy()
      optsC = Object.create opts
      optsC.x = tx
      optsC.y = ty
      optsC.mover = @cause
      @entity.move(optsC, callback)

    @handleEffects: (effects, opts, callback) ->
      console.log effects
      applyEffects = (effects, cb) =>
        async.forEach(effects, applyEffect, cb)
      applyEffect = (effect, cb) =>
        effect.applyEffect(opts, cb)
      # This is the same as the previous behaviour, pushing is disabled.
      filteredEffects = (effect for effect in effects when effect.isFirst())
      applyEffects(filteredEffects, callback)

  module.exports = MoveEffect
