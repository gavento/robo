describe 'Effect', ->
  Robot = null
  Conveyor = null
  Effect = null
  before (done) ->
    require [
      'cs!app/models/entity-robot'
      'cs!app/models/entity-others'
      'cs!app/lib/effects/effect'],
      (robot, entities, effect) ->
        Robot = robot
        Conveyor = entities.Conveyor
        Effect = effect
        done()
  
  robot = null
  conveyor = null
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
  
  describe 'chained effect', ->
    effect2 = null
    beforeEach ->
      robot = new Robot({x: 0, y: 0, type: 'Robot', dir: 'N'})
      conveyor = new Conveyor({x: 0, y: 0, type: 'C', dir: 'E'})
      effect = new Effect(robot, conveyor)
      effect2 = new Effect(robot, robot)
      effect2.appendTo(effect)
    it 'should be first', ->
      effect.isFirst().should.be.true
    it 'should not be last', ->
      effect.isLast().should.be.false
    it 'should have the primary cause same as the first effect in the chain', ->
      effect2.getPrimaryCause().id.should.equal(conveyor.id)
