describe 'Board', ->
  Board = null
  Robot = null
  TurnerL = null
  TurnerR = null
  TurnerU = null
  Conveyor = null
  ExpressConveyor = null
  Hole = null
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
        TurnerL = entities.TurnerL
        TurnerR = entities.TurnerR
        TurnerU = entities.TurnerU
        Hole = entities.Hole
        done()
  
  describe 'new board', ->
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

  describe 'board with conveyor and robot', ->
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
      robot.dir().dir.should.equal(0)
      robot.x.should.equal(0)
      robot.y.should.equal(0)
      robot.isPlaced().should.be.ok
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(0)
        robot.x.should.equal(-1)
        robot.y.should.equal(0)
        robot.isPlaced().should.not.be.ok
        done()

  describe 'board with turner and robot', ->
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
    it 'should not rotate robot that is not on the turner', (done)->
      turner = new TurnerL({x: 1, y: 0, type: 'L', dir: 'N'})
      board.entities([robot, turner])
      robot.dir().dir.should.equal(0)
      board.activateBoard {}, ->
        robot.dir().dir.should.equal(0)
        done()
