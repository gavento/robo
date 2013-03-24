define (require, exports, module) ->

  EffectFactory = require 'cs!app/models/effects/EffectFactory'
  Entity = require 'cs!app/models/Entity'
  Direction = require 'cs!app/lib/Direction'


  class Conveyor extends Entity
    @configure {name:'Conveyor', subClass:true, registerAs: 'C'}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [20]

    effects: ->
      effects = []
      for entity in @board.getMovableEntitiesAt(@x, @y)
        effect = EffectFactory.createMoveEffectChain(@board, entity, @, @dir())
        effects.push(effect)
      return effects


  class ExpressConveyor extends Conveyor
    @configure {name:'ExpressConveyor', subClass:true, registerAs: 'E'}

    getPhases: -> [18, 22]


  class Crusher extends Entity
    @configure {name:'Crusher', subClass:true, registerAs: 'X'}

    getPhases: -> [50]

    effects: ->
      effects = []
      for entity in @board.getCrushableEntitiesAt(@x, @y)
        effect = EffectFactory.createCrushEffectChain(@board, entity, @, 1)
        effects.push(effect)
      return effects


  class Turner extends Entity
    @configure {name:'Turner', subClass:true}, 'dir'
    @typedProperty 'dir', Direction

    getPhases: -> [40]
    turnDirection: 0

    effects: ->
      effects = []
      for entity in @board.getTurnableEntitiesAt(@x, @y)
        effect = EffectFactory.createTurnEffectChain(
          @board, entity, @, @turnDirection)
        effects.push(effect)
      return effects
    
    activate: (opts, callback) ->
      optsCopy = Object.create opts
      optsCopy.oldDir = @dir().copy()
      optsCopy.dir = @turnDirection
      optsCopy.mover = @
      @dir().turn(@turnDirection)
      super optsCopy, callback


  class TurnerR extends Turner
    @configure {name:'TurnerR', subClass:true, registerAs: 'R'}
    turnDirection: 1


  class TurnerL extends Turner
    @configure {name:'TurnerL', subClass:true, registerAs: 'L'}
    turnDirection: -1


  class TurnerU extends Turner
    @configure {name:'TurnerU', subClass:true, registerAs: 'U'}
    turnDirection: 2


  class Hole extends Entity
    @configure {name:'Hole', subClass:true, registerAs: 'H'}

    hasImmediateEffect: -> true

    effects: ->
      effects = []
      for entity in @board.getMovableEntitiesAt(@x, @y)
        effect = EffectFactory.createFallEffectChain(@board, entity, @)
        effects.push(effect)
      return effects

  
  class Wall extends Entity
    @configure {name:'Wall', subClass:true, registerAs: 'W'}, 'dir'
    @typedProperty 'dir', Direction


  module.exports =
    Conveyor: Conveyor
    ExpressConveyor: ExpressConveyor
    Crusher: Crusher
    Turner: Turner
    TurnerR: TurnerR
    TurnerL: TurnerL
    TurnerU: TurnerU
    Hole: Hole
    Wall: Wall
