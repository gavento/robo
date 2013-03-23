describe 'EffectFactory', ->
  Board = null
  Robot = null
  Conveyor = null
  TurnerL = null
  Crusher = null
  EffectFactory = null
  MoveEffect = null
  TurnEffect = null
  CrushEffect = null
  before (done) ->
    require [
      'cs!app/models/Board'
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      'cs!app/models/effects/EffectFactory'
      'cs!app/models/effects/MoveEffect'
      'cs!app/models/effects/TurnEffect'
      'cs!app/models/effects/CrushEffect'
      ], (board, robot, entities, effectFactory,
          moveEffect, turnEffect, crushEffect) ->
        Board = board
        Robot = robot
        Conveyor = entities.Conveyor
        TurnerL = entities.TurnerL
        Crusher = entities.Crusher
        EffectFactory = effectFactory
        MoveEffect = moveEffect
        TurnEffect = turnEffect
        CrushEffect = crushEffect
        done()
  

  describe 'createMoveEffectChain', ->
    robot = null
    conveyor = null
    effect = null
    before ->
      board = new Board({width: 3, height: 3})
      robot = new Robot({x: 0, y: 0, type: 'Robot'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([robot, conveyor])
      effect = EffectFactory.createMoveEffectChain(board, robot, conveyor, conveyor.dir())
    it 'should create a MoveEffect', ->
      effect.should.be.instanceof(MoveEffect)
    it 'should have direction of the conveyor', ->
      originalDir = conveyor.dir().getNumber()
      effect.direction.getNumber().should.equal(originalDir)
    it 'should be caused by the conveyor', ->
      effect.cause.should.equal(conveyor)
    it 'should affect the robot', ->
      effect.entity.should.equal(robot)

  describe 'createTurnEffectChain', ->
    robot = null
    turner = null
    effect1 = null
    effect2 = null
    effect3 = null
    before ->
      board = new Board({width: 3, height: 3})
      robot = new Robot({x: 0, y: 0, type: 'Robot', dir: 'W'})
      turner = new TurnerL({x: 0, y: 0, type: 'L', dir: 'S'})
      board.entities([robot, turner])
      effect1 = EffectFactory.createTurnEffectChain(board, robot, turner, 1)
      effect2 = EffectFactory.createTurnEffectChain(board, robot, turner, -1)
      effect3 = EffectFactory.createTurnEffectChain(board, robot, turner, 2)
    it 'should create a TurnEffect', ->
      effect1.should.be.instanceof(TurnEffect)
    it 'should have direction of the robot', ->
      originalDir = robot.dir().getNumber()
      effect1.direction.getNumber().should.equal(originalDir)
      effect2.direction.getNumber().should.equal(originalDir)
      effect3.direction.getNumber().should.equal(originalDir)
    it 'should rotate the robot by given amount', ->
      effect1.amount.should.equal(1)
      effect2.amount.should.equal(-1)
      effect3.amount.should.equal(2)
    it 'should be caused by the turner', ->
      effect1.cause.should.equal(turner)
    it 'should affect the robot', ->
      effect1.entity.should.equal(robot)

  describe 'createCrushEffectChain', ->
    robot = null
    crusher = null
    effect1 = null
    effect2 = null
    before ->
      board = new Board({width: 3, height: 3})
      robot = new Robot({x: 0, y: 0, type: 'Robot', dir: 'W'})
      crusher = new Crusher({x: 0, y: 0, type: 'X'})
      board.entities([robot, crusher])
      effect1 = EffectFactory.createCrushEffectChain(board, robot, crusher, 1)
      effect2 = EffectFactory.createCrushEffectChain(board, robot, crusher, 2)
    it 'should create a CrushEffect', ->
      effect1.should.be.instanceof(CrushEffect)
    it 'should contain a specified damage', ->
      effect1.damage.should.equal(1)
      effect2.damage.should.equal(2)
    it 'should be caused by the crusher', ->
      effect1.cause.should.equal(crusher)
    it 'should affect the robot', ->
      effect1.entity.should.equal(robot)

  describe 'splitEffects', ->
    it 'should split chained effect to single effects', ->
      board = new Board({width: 3, height: 3})
      robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
      robot2 = new Robot({x: 1, y: 0, type: 'Robot'})
      robot3 = new Robot({x: 1, y: 0, type: 'Robot'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([conveyor, robot1, robot2, robot3])
      effect = EffectFactory.createMoveEffectChain(board, robot1, conveyor, conveyor.dir())
      effects = EffectFactory.splitEffects([effect])
      effects.length.should.equal(3)
