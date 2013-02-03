define (require, exports, module) ->
  
  Effect = require 'cs!app/models/effects/Effect'
  
  class MoveEffect extends Effect
      
    @createEffect: (board, entity, cause, direction) ->
      effect = new @(entity, cause, direction)
      effect.propagate(board)
      return effect

    constructor: (entity, cause, @direction) ->
      @blocked = false
      super entity, cause

    propagate: (board) ->
      if board.isPassable(@entity.x, @entity.y, @direction)
        if @entity.canPush()
          @affectEntitiesOnNeighbouringTile(board)
      else
        @blocked = true

    affectEntitiesOnNeighbouringTile: (board) ->
      nx = @entity.x + @direction.dx()
      ny = @entity.y + @direction.dy()
      for entity in board.getPushableEntitiesAt(nx, ny)
        effect = MoveEffect.createEffect(board, entity, @entity, @direction)
        effect.appendTo(@)

    isBlocked: ->
      return @blocked

    @handleEffects: (effects, opts, callback) ->
      finalEffects = @filterEffects(effects)
      applyEffects = (effects, cb) =>
        async.forEach(effects, applyEffect, cb)
      applyEffect = (effect, cb) =>
        effect.applyEffect(opts, cb)
      applyEffects(finalEffects, callback)

    @filterEffects: (effects) ->
      effects = @filterOutOppositeEffects(effects)
      effects = @filterOutEffectsTargetingSameTile(effects)
      effects = @filterOutBlockedEffects(effects)
      effects = @filterOutOneOfOrthogonalEffects(effects)
      effects = @filterOutDuplicateEffects(effects)
      #effects = (effect for effect in effects when effect.isFirst())
      return effects

    @filterOutOppositeEffects: (effects) ->
      effectsByEntityId = @getEffectsByEntityId(effects)
      for id of effectsByEntityId
        @invalidateOppositeEffects(effectsByEntityId[id])
      effects = @filterOutInvalidEffects(effects)
      return effects

    @filterOutEffectsTargetingSameTile: (effects) ->
      effectsByTargetTile = @getEffectsByTargetTile(effects)
      for e in effectsByTargetTile
        @invalidateEffectsTargetingOneTile(e)
      effects = @filterOutInvalidEffects(effects)
      return effects

    @filterOutOneOfOrthogonalEffects: (effects) ->
      effectsByEntityId = @getEffectsByEntityId(effects)
      for id of effectsByEntityId
        @invalidateOneOfOrthogonalEffects(effectsByEntityId[id])
      effects = @filterOutInvalidEffects(effects)
      return effects

    @filterOutBlockedEffects: (effects) ->
      effectsByEntityId = @getEffectsByEntityId(effects)
      changed = true
      invalidateEffect = (effect) =>
        effect.invalidate()
        changed = true
      targetsBlockedEntity = (effect) =>
        if effect.isLast()
          return false
        for target in effect.targets
          id = target.getEntityId()
          if effectsByEntityId[id]? # only entities with valid effects
            validEffects = (e for e in effectsByEntityId[id] when e.isValid())
            if validEffects.length > 0
              return false
        return true
      while changed
        changed = false
        for effect in effects
          if effect.isInvalid()
            continue
          if effect.isBlocked()
            invalidateEffect(effect)
            continue
          if targetsBlockedEntity(effect)
            invalidateEffect(effect)
            continue
        effects = @filterOutInvalidEffects(effects)
      return effects

    @filterOutDuplicateEffects: (effects) ->
      effectsByEntityId = @getEffectsByEntityId(effects)
      for id of effectsByEntityId
        @invalidateDuplicateEffectsOnOneEntity(effectsByEntityId[id])
      effects = @filterOutInvalidEffects(effects)
      return effects

    @invalidateEffectsTargetingOneTile: (effects) ->
      @invalidateOppositeEffects(effects)
      @invalidateOrthogonalEffects(effects)

    @invalidateOppositeEffects: (effects) ->
      effectsByDirection = @getEffectsByDirection(effects)
      north = effectsByDirection[0]
      east = effectsByDirection[1]
      south = effectsByDirection[2]
      west = effectsByDirection[3]
      @invalidateEffectsOfTwoDirectionsIfBothExist(north, south)
      @invalidateEffectsOfTwoDirectionsIfBothExist(east, west)
    
    @invalidateOrthogonalEffects: (effects) ->
      effectsByDirection = @getEffectsByDirection(effects)
      north = effectsByDirection[0]
      east = effectsByDirection[1]
      south = effectsByDirection[2]
      west = effectsByDirection[3]
      @invalidateEffectsOfTwoDirectionsIfBothExist(north, east)
      @invalidateEffectsOfTwoDirectionsIfBothExist(east, south)
      @invalidateEffectsOfTwoDirectionsIfBothExist(south, west)
      @invalidateEffectsOfTwoDirectionsIfBothExist(west, north)
    
    @invalidateOneOfOrthogonalEffects: (effects) ->
      effectsByDirection = @getEffectsByDirection(effects)
      north = effectsByDirection[0]
      east = effectsByDirection[1]
      south = effectsByDirection[2]
      west = effectsByDirection[3]
      @invalidateNonFirstEffectsOfTwoDirectionsIfBothExist(north, east)
      @invalidateNonFirstEffectsOfTwoDirectionsIfBothExist(east, south)
      @invalidateNonFirstEffectsOfTwoDirectionsIfBothExist(south, west)
      @invalidateNonFirstEffectsOfTwoDirectionsIfBothExist(west, north)
      
    @invalidateEffectsOfTwoDirectionsIfBothExist: (first, second) ->
      if first.length > 0 and second.length > 0
        @invalidateEffectChains(first)
        @invalidateEffectChains(second)

    @invalidateNonFirstEffectsOfTwoDirectionsIfBothExist: (first, second) ->
      if first.length > 0 and second.length > 0
        effects = first.concat(second)
        for effect in effects
          if not effect.isFirst()
            effect.invalidate()
            @invalidateTargetEffectsOf(effect)

    @invalidateDuplicateEffectsOnOneEntity: (effects) ->
      effectsByDirection = @getEffectsByDirection(effects)
      for effects in effectsByDirection
        if effects.length > 1
          @invalidateForwardEffects(effects[1..])

    @getEffectsByDirection: (effects) ->
      effectsByDirection = [[],[],[],[]]
      for effect in effects
        dir = effect.getDirectionAsNumber()
        effectsByDirection[dir].push(effect)
      return effectsByDirection

    @getEffectsByEntityId: (effects) ->
      effectsByEntityId = {}
      for effect in effects
        id = effect.getEntityId()
        effectsByEntityId[id] ?= []
        effectsByEntityId[id].push(effect)
      return effectsByEntityId

    @getEffectsByTargetTile: (effects) ->
      effectsByTargetTile = {}
      for effect in effects
        if not effect.isBlocked()
          tx = effect.entity.x + effect.direction.dx()
          ty = effect.entity.y + effect.direction.dy()
          effectsByTargetTile[tx] ?= {}
          effectsByTargetTile[tx][ty] ?= []
          effectsByTargetTile[tx][ty].push(effect)
      effectsByTargetTileLinear = []
      for x of effectsByTargetTile
        for y of effectsByTargetTile[x]
          effectsByTargetTileLinear.push(effectsByTargetTile[x][y][..])
      return effectsByTargetTileLinear
    
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

    applyEffect: (opts, callback) ->
      tx = @entity.x + @direction.dx()
      ty = @entity.y + @direction.dy()
      optsC = Object.create opts
      optsC.x = tx
      optsC.y = ty
      optsC.mover = @getPrimaryCause()
      @entity.move(optsC, callback)

  module.exports = MoveEffect
