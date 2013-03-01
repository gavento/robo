describe 'Board', ->
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
  
  describe 'that was just created', ->
    it 'should have specified size', ->
      board = new Board({width: 3, height: 2})
      board.width().should.equal(3)
      board.height().should.equal(2)
    it 'should be empty', ->
      board = new Board({width: 3, height: 2})
      board.entities().should.be.empty
    it 'should have empty tiles', ->
      board = new Board({width: 2, height: 1})
      board.tile(0, 0).should.be.empty
      board.tile(1, 0).should.be.empty
    it 'should be surrounded by holes', ->
      board = new Board({width: 2, height: 1})
      tile = board.tile(-2, 5)
      tile.length.should.equal(1)
      hole = tile[0]
      hole.should.be.an.instanceof(Hole)

  describe 'with crusher and robot', ->
    board = null
    robot = null
    beforeEach ->
      board = new Board({width: 3, height: 1})
      robot = new Robot({x: 0, y: 0, type: 'Robot', health: 8})
    it 'should damage the robot under the crusher', (done) ->
      crusher = new Crusher({x: 0, y: 0, type: 'X'})
      board.entities([robot, crusher])
      robot.health.should.equal(8)
      board.activateBoard {}, ->
        robot.health.should.equal(7)
        done()
    it 'should damage the robot after the conveyor phase', (done) ->
      crusher = new Crusher({x: 1, y: 0, type: 'X'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([robot, crusher, conveyor])
      robot.health.should.equal(8)
      board.activateBoard {}, ->
        robot.health.should.equal(7)
        robot.x.should.equal(1)
        robot.y.should.equal(0)
        done()
    it 'should not damage the robot before the conveyor phase', (done) ->
      crusher = new Crusher({x: 0, y: 0, type: 'X'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      board.entities([robot, crusher, conveyor])
      robot.health.should.equal(8)
      board.activateBoard {}, ->
        robot.health.should.equal(8)
        robot.x.should.equal(1)
        robot.y.should.equal(0)
        done()

  describe 'with conveyor and robot', ->
    board = null
    robot = null
    beforeEach ->
      board = new Board({width: 3, height: 1})
      robot = new Robot({x: 0, y: 0, type: 'Robot'})
    it 'should move the robot on the conveyor', (done) ->
      conveyor1 = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      conveyor2 = new Conveyor({x: 1, y: 0, type: 'C', dir: 'E'})
      board.entities([robot, conveyor1, conveyor2])
      robot.dir().dir.should.equal(0)
      robot.x.should.equal(0)
      robot.y.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(0)
        robot.x.should.equal(1)
        robot.y.should.equal(0)
        done()
    it 'should move the robot on the express conveyor', (done) ->
      conveyor1 = new ExpressConveyor({x: 0, y: 0, type: 'E', dir: 'E'})
      conveyor2 = new ExpressConveyor({x: 1, y: 0, type: 'E', dir: 'E'})
      board.entities([robot, conveyor1, conveyor2])
      robot.dir().dir.should.equal(0)
      robot.x.should.equal(0)
      robot.y.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(0)
        robot.x.should.equal(2)
        robot.y.should.equal(0)
        done()
    it 'should push the robot into a hole', (done) ->
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'W'})
      board.entities([robot, conveyor])
      robot.isPlaced().should.be.true
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(0)
        robot.isPlaced().should.be.false
        done()

  describe 'with turner and robot', ->
    board = null
    robot = null
    beforeEach ->
      board = new Board({width: 2, height: 1})
      robot = new Robot({x: 0, y: 0, type: 'Robot'})
    it 'should contain the turner and the robot', ->
      turner = new TurnerL({x: 0, y: 0, type: 'L', dir: 'N'})
      board.entities([robot, turner])
      tile = board.tile(0, 0)
      tile.length.should.equal(2)
    it 'should rotate robot and the turner to the left', (done) ->
      turner = new TurnerL({x: 0, y: 0, type: 'L', dir: 'N'})
      board.entities([robot, turner])
      robot.dir().dir.should.equal(0)
      turner.dir().dir.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(3)
        turner.dir().dir.should.equal(3)
        done()
    it 'should rotate robot and the turner to the right', (done) ->
      turner = new TurnerR({x: 0, y: 0, type: 'R', dir: 'N'})
      board.entities([robot, turner])
      robot.dir().dir.should.equal(0)
      turner.dir().dir.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(1)
        turner.dir().dir.should.equal(1)
        done()
    it 'should rotate robot and the turner around', (done) ->
      turner = new TurnerU({x: 0, y: 0, type: 'U', dir: 'N'})
      board.entities([robot, turner])
      robot.dir().dir.should.equal(0)
      turner.dir().dir.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(2)
        turner.dir().dir.should.equal(2)
        done()
    it 'should not rotate robot that is not on the turner', (done) ->
      turner = new TurnerL({x: 1, y: 0, type: 'L', dir: 'N'})
      board.entities([robot, turner])
      robot.dir().dir.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(0)
        done()

  describe 'should update tile when an entity is moved', ->
    board = null
    robot = null
    beforeEach (done) ->
      board = new Board({width: 3, height: 3})
      robot = new Robot({x: 0, y: 0, type: 'Robot'})
      board.entities([robot])
      robot.move({x:0, y:1}, done)
    it 'tile where the robot was should be empty', ->
      board.tile(0, 0).should.be.empty
    it 'tile where the robot should be should contain the robot', ->
      board.tile(0, 1).should.contain(robot)
    it 'tile where the robot is should contain the robot', ->
      board.tile(robot.x, robot.y).should.contain(robot)

  describe 'should not contain robot that is not placed', ->
    board = null
    robot = null
    beforeEach ->
      board = new Board({width: 1, height: 1})
      robot = new Robot({x: 0, y: 0, type: 'Robot'}, health: 8)
      robot.placed = false
      board.entities([robot])
    it 'robot should not be placed', ->
      robot.isPlaced().should.be.false
    it 'the tile where the robot stands should be empty', ->
      board.tile(0, 0).should.be.empty

