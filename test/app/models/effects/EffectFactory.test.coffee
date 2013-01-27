describe 'EffectFactory', ->
  Board = null
  Robot = null
  Conveyor = null
  EffectFactory = null
  MoveEffect = null
  before (done) ->
    require [
      'cs!app/models/Board'
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      'cs!app/models/effects/EffectFactory'
      'cs!app/models/effects/MoveEffect'
      ], (board, robot, entities, effectFactory, moveEffect) ->
        Board = board
        Robot = robot
        Conveyor = entities.Conveyor
        EffectFactory = effectFactory
        MoveEffect = moveEffect
        done()
  
  board = null
  beforeEach ->
    board = new Board({width: 3, height: 3})

  describe 'createMoveChain', ->
    it 'should create a MoveEffect', ->
      robot = new Robot({x: 0, y: 0, type: 'Robot'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([robot, conveyor])
      effect = EffectFactory.createMoveEffectChain(board, robot, conveyor, conveyor.dir())
      effect.should.be.instanceof(MoveEffect)

  describe 'splitEffects', ->
    it 'should split chained effect to single effects', ->
      robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
      robot2 = new Robot({x: 1, y: 0, type: 'Robot'})
      robot3 = new Robot({x: 1, y: 0, type: 'Robot'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([conveyor, robot1, robot2, robot3])
      effect = EffectFactory.createMoveEffectChain(board, robot1, conveyor, conveyor.dir())
      effects = EffectFactory.splitEffects([effect])
      effects.length.should.equal(3)
