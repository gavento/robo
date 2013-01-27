describe 'Effect', ->
  Robot = null
  Conveyor = null
  Effect = null
  before (done) ->
    require [
      'cs!app/models/EntityRobot'
      'cs!app/models/EntityOthers'
      'cs!app/models/effects/Effect'
      ], (robot, entities, effect) ->
        Robot = robot
        Conveyor = entities.Conveyor
        Effect = effect
        done()
  
  effect = null
  beforeEach ->
    robot = new Robot({x: 0, y: 0, type: 'Robot', dir: 'N'})
    conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
    effect = new Effect(robot, conveyor)
  
  describe 'simple effect', ->
    it 'should be first', ->
      effect.isFirst().should.be.true
    it 'should be last', ->
      effect.isLast().should.be.true
    it 'should be valid', ->
      effect.isValid().should.be.true

  describe 'invalidated effect', ->
    it 'should not be valid', ->
      effect.invalidate()
      effect.isValid().should.be.false
