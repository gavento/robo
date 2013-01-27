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
      effect.targets.push(@)

    affectEntitiesOnNeighbouringTile: (board) ->
      console.log "dir", @direction
      nx = @entity.x + @direction.dx()
      ny = @entity.y + @direction.dy()
      for entity in board.getPushableEntitiesAt(nx, ny)
        console.log 'entity', entity
        effect = MoveEffect.createEffect(board, entity, @entity, @direction)
        effect.appendTo(@)
        console.log 'effect', effect

    @handleEffects: (effects, opts, callback) ->
      console.log effects.length
      # This is the same as the previous behaviour, pushing is disabled.
      filteredEffects = (effect for effect in effects when effect.isFirst())
      applyEffects = (effects, cb) =>
        async.forEach(effects, applyEffect, cb)
      applyEffect = (effect, cb) =>
        effect.applyEffect(opts, cb)
      applyEffects(filteredEffects, callback)

    applyEffect: (opts, callback) ->
      tx = @entity.x + @direction.dx()
      ty = @entity.y + @direction.dy()
      optsC = Object.create opts
      optsC.x = tx
      optsC.y = ty
      optsC.mover = @cause
      @entity.move(optsC, callback)

  module.exports = MoveEffect
