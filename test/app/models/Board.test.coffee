describe 'Board', ->
  Board = null
  Robot = null
  TurnerL = null
  TurnerR = null
  TurnerU = null
  before (done) ->
    require [
      'cs!app/models/Board'
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      ], (board, robot, entities) ->
        Board = board
        Robot = robot
        TurnerL = entities.TurnerL
        TurnerR = entities.TurnerR
        TurnerU = entities.TurnerU
        done()
  
  describe 'new Board', ->
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
    it 'should rotate robot on the turner to the left', (done) ->
        turner = new TurnerL({x: 0, y: 0, type: 'L', dir: 'N'})
        board.entities([robot, turner])
        robot.dir().dir.should.equal(0)
        board.activateBoard {}, ->
          robot.dir().dir.should.equal(3)
          done()
    it 'should not rotate robot that is not on the turner', (done)->
        turner = new TurnerL({x: 1, y: 0, type: 'L', dir: 'N'})
        board.entities([robot, turner])
        robot.dir().dir.should.equal(0)
        board.activateBoard {}, ->
          robot.dir().dir.should.equal(0)
          done()
