describe 'Entity', ->
  Board = null
  Robot = null
  before (done) ->
    require [
      'cs!app/models/Board'
      'cs!app/models/Entity'
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      ], (board, entity, robot, entities) ->
        Board = board
        Robot = robot
        done()

  entity = null
  beforeEach ->
    entity = new Robot({x: 0, y: 0, dir: 2, type: 'Robot'})
  
  describe 'move', ->
    beforeEach (done) ->
      entity.move({x:1, y:0}, done)
    it 'should move the entity', ->
      entity.x.should.equal(1)
      entity.y.should.equal(0)
  
  describe 'rotate', ->
    beforeEach (done) ->
      entity.rotate({dir:3}, done )
    it 'should rotate the entity', ->
      entity.dir().dir.should.equal(1)

