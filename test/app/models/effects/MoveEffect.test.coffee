describe 'MoveEffect', ->
  Board = null
  Robot = null
  Conveyor = null
  Wall = null
  Effect = null
  MoveEffect = null
  before (done) ->
    require [
      'cs!app/models/Board'
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      'cs!app/models/effects/Effect'
      'cs!app/models/effects/MoveEffect'
      ], (board, robot, entities, effect, moveEffect) ->
        Board = board
        Robot = robot
        Conveyor = entities.Conveyor
        Wall = entities.Wall
        Effect = effect
        MoveEffect = moveEffect
        done()
  
  initEffect = ->
    board = new Board({width: 3, height: 3})
    robot1 = new Robot({x: 0, y: 0, type: 'Robot', dir: 'N'})
    robot2 = new Robot({x: 1, y: 0, type: 'Robot', dir: 'N'})
    robot3 = new Robot({x: 1, y: 0, type: 'Robot', dir: 'N'})
    conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
    board.entities([conveyor, robot1, robot2, robot3])
    effect = MoveEffect.createEffect(board, robot1, conveyor, conveyor.dir())
    return effect
  
  describe 'chained effect', ->
    effect = null
    beforeEach ->
      effect = initEffect()
    it 'should be derived from Effect', ->
      effect.should.be.instanceof(Effect)
    it 'should have targets', ->
      effect.targets.length.should.equal(2)

  describe 'targets', ->
    effect = null
    target1 = null
    target2 = null
    beforeEach ->
      effect = initEffect()
      target1 = effect.targets[0]
      target2 = effect.targets[1]
    it 'should be last', ->
      target1.isLast().should.be.true
      target2.isLast().should.be.true
    it 'should not be first', ->
      target1.isFirst().should.be.false
      target2.isFirst().should.be.false
    it 'should have the same direction as the initial source', ->
      originalDir = effect.direction.getNumber()
      target1.direction.getNumber().should.equal(originalDir)
      target2.direction.getNumber().should.equal(originalDir)

  describe 'situations', ->
    describe 'when robot on a conveyor is pushing another robot that is not on a conveyor', ->
      robot1 = null
      robot2 = null
      conveyor = null
      before (done) ->
        board = new Board({width: 3, height: 3})
        robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
        robot2 = new Robot({x: 1, y: 0, type: 'Robot'})
        conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
        board.entities([robot1, robot2, conveyor])
        board.activateBoard {}, done
      it 'robot on a conveyor should be moved in the direction of the conveyor', ->
        robot1.x.should.equal(1)
        robot1.y.should.equal(0)
      it 'robot behind the conveyor should be pushed in the direction of the conveyor', ->
        robot2.x.should.equal(2)
        robot2.y.should.equal(0)
      it 'conveyor should not be moved', ->
        conveyor.x.should.equal(0)
        conveyor.y.should.equal(0)
    describe 'when robot on a conveyor is pushing another robot that is also on a conveyor', ->
      describe 'and both conveyors have the same direction', ->
        robot1 = null
        robot2 = null
        conveyor1 = null
        conveyor2 = null
        before (done) ->
          board = new Board({width: 3, height: 3})
          robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
          robot2 = new Robot({x: 1, y: 0, type: 'Robot'})
          conveyor1 = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
          conveyor2 = new Conveyor({x: 1, y: 0, type: 'C', dir: 'E'})
          board.entities([robot1, robot2, conveyor1, conveyor2])
          board.activateBoard {}, done
        it 'robot on the first conveyor should be moved in the direction of the first conveyor', ->
          robot1.x.should.equal(1)
          robot1.y.should.equal(0)
        it 'robot on the second conveyor should be moved in the direction of the second conveyor', ->
          robot2.x.should.equal(2)
          robot2.y.should.equal(0)
        it 'first conveyor should not be moved', ->
          conveyor1.x.should.equal(0)
          conveyor1.y.should.equal(0)
        it 'second conveyor should not be moved', ->
          conveyor2.x.should.equal(1)
          conveyor2.y.should.equal(0)
      describe 'and the second conveyor has an orthogonal direction', ->
        robot1 = null
        robot2 = null
        conveyor1 = null
        conveyor2 = null
        before (done) ->
          board = new Board({width: 3, height: 3})
          robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
          robot2 = new Robot({x: 1, y: 0, type: 'Robot'})
          conveyor1 = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
          conveyor2 = new Conveyor({x: 1, y: 0, type: 'C', dir: 'S'})
          board.entities([robot1, robot2, conveyor1, conveyor2])
          board.activateBoard {}, done
        it 'robot on the first conveyor should be moved in the direction of the first conveyor', ->
          robot1.x.should.equal(1)
          robot1.y.should.equal(0)
        it 'robot on the second conveyor should be moved in the direction of the first conveyor', ->
          robot2.x.should.equal(2)
          robot2.y.should.equal(0)
        it 'first conveyor should not be moved', ->
          conveyor1.x.should.equal(0)
          conveyor1.y.should.equal(0)
        it 'second conveyor should not be moved', ->
          conveyor2.x.should.equal(1)
          conveyor2.y.should.equal(0)
      describe 'and the second conveyor has the oposite direction', ->
        robot1 = null
        robot2 = null
        robot3 = null
        conveyor1 = null
        conveyor2 = null
        before (done) ->
          board = new Board({width: 3, height: 3})
          robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
          robot2 = new Robot({x: 1, y: 0, type: 'Robot'})
          robot3 = new Robot({x: 2, y: 0, type: 'Robot'})
          conveyor1 = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
          conveyor2 = new Conveyor({x: 1, y: 0, type: 'C', dir: 'W'})
          board.entities([robot1, robot2, robot3, conveyor1, conveyor2])
          board.activateBoard {}, done
        it 'robot on the first conveyor should not be moved', ->
          robot1.x.should.equal(0)
          robot1.y.should.equal(0)
        it 'robot on the second conveyor should not be moved', ->
          robot2.x.should.equal(1)
          robot2.y.should.equal(0)
        it 'robot behind the second robot should not be moved', ->
          robot3.x.should.equal(2)
          robot3.y.should.equal(0)
        it 'first conveyor should not be moved', ->
          conveyor1.x.should.equal(0)
          conveyor1.y.should.equal(0)
        it 'second conveyor should not be moved', ->
          conveyor2.x.should.equal(1)
          conveyor2.y.should.equal(0)
    describe 'robot on a conveyor is being moved against a wall', ->
      robot = null
      wall = null
      before (done) ->
        board = new Board({width: 3, height: 3})
        robot = new Robot({x: 0, y: 0, type: 'Robot'})
        conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
        wall = new Wall({x: 0, y: 0, type: 'W', dir: 'E'})
        board.entities([robot, conveyor, wall])
        board.activateBoard {}, done
      it 'the robot should not pass through the wall', ->
        robot.x.should.equal(0)
        robot.y.should.equal(0)
      it 'the wall should not be moved',  ->
        wall.x.should.equal(0)
        wall.y.should.equal(0)
    describe 'robot is being pushed against a wall by second robot', ->
      describe 'and it is also being pushed in an orthogonal direction by third robot', ->
        robot1 = null
        robot2 = null
        robot3 = null
        before (done) ->
          board = new Board({width: 2, height: 3})
          robot1 = new Robot({x: 0, y: 1, type: 'Robot'})
          robot2 = new Robot({x: 1, y: 1, type: 'Robot'})
          robot3 = new Robot({x: 0, y: 2, type: 'Robot'})
          conveyor1 = new Conveyor({x: 1, y: 1, type: 'C', dir: 'W'})
          conveyor2 = new Conveyor({x: 0, y: 2, type: 'C', dir: 'N'})
          wall = new Wall({x: 0, y: 1, type: 'W', dir: 'E'})
          board.entities([robot1, robot2, robot3, conveyor1, conveyor2, wall])
          board.activateBoard {}, done
        it 'the first robot should not move', ->
          robot1.x.should.equal(0)
          robot1.y.should.equal(1)
        it 'the second robot should not move', ->
          robot2.x.should.equal(1)
          robot2.y.should.equal(1)
        it 'the third robot should not move', ->
          robot3.x.should.equal(0)
          robot3.y.should.equal(2)
      describe 'and it is also being moved in an orthogonal direction by a conveyor', ->
        robot1 = null
        robot2 = null
        before (done) ->
          board = new Board({width: 2, height: 2})
          robot1 = new Robot({x: 0, y: 1, type: 'Robot'})
          robot2 = new Robot({x: 1, y: 1, type: 'Robot'})
          conveyor1 = new Conveyor({x: 0, y: 1, type: 'C', dir: 'N'})
          conveyor2 = new Conveyor({x: 1, y: 1, type: 'C', dir: 'W'})
          wall = new Wall({x: 0, y: 1, type: 'W', dir: 'E'})
          board.entities([robot1, robot2, conveyor1, conveyor2, wall])
          board.activateBoard {}, done
        it 'the first robot should not move', ->
          robot1.x.should.equal(0)
          robot1.y.should.equal(0)
        it 'the second robot should be moved in the direction of the conveyor it is standing on', ->
          robot2.x.should.equal(0)
          robot2.y.should.equal(1)
