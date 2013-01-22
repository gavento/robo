describe 'MoveEffect', ->
  Board = null
  Robot = null
  Conveyor = null
  ExpressConveyor = null
  Crusher = null
  TurnerL = null
  TurnerR = null
  TurnerU = null
  Hole = null
  Wall = null
  before (done) ->
    require [
      'cs!app/models/Board'
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      ], (board, robot, entities) ->
        Board = board
        Robot = robot
        Conveyor = entities.Conveyor
        ExpressConveyor = entities.ExpressConveyor
        Crusher = entities.Crusher
        TurnerL = entities.TurnerL
        TurnerR = entities.TurnerR
        TurnerU = entities.TurnerU
        Hole = entities.Hole
        Wall = entities.Wall
        done()
  
  describe 'robot on conveyor', ->
    board = null
    beforeEach ->
      board = new Board({width: 3, height: 3})
  
    it 'should push robot on an empty tile', (done) ->
      robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
      robot2 = new Robot({x: 0, y: 0, type: 'Robot'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([robot1, robot2, conveyor])
      board.activateBoard {}, ->
        robot1.x.should.equal(1)
        robot1.y.should.equal(0)
        robot2.x.should.equal(2)
        robot2.y.should.equal(0)
        done()

    it 'should not push robot on an oposing conveyor', (done) ->
      robot1 = new Robot({x: 0, y: 0, type: 'Robot'})
      robot2 = new Robot({x: 0, y: 0, type: 'Robot'})
      conveyor1 = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      conveyor2 = new Conveyor({x: 1, y: 0, type: 'C', dir: 'W'})
      board.entities([robot1, robot2, conveyor1, conveyor2])
      board.activateBoard {}, ->
        robot1.x.should.equal(0)
        robot1.y.should.equal(0)
        robot2.x.should.equal(1)
        robot2.y.should.equal(0)
        done()
    
    it 'should not pass through a wall', (done) ->
      robot = new Robot({x: 0, y: 0, type: 'Robot', dir: 'E'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      wall = new Wall({x: 0, y: 0, type: 'W', dir: 'E'})
      board.entities([robot, conveyor, wall])
      board.activateBoard {}, ->
        robot.x.should.equal(0)
        robot.y.should.equal(0)
        done()
