describe 'RespawnPosition', ->
  RespawnPosition = null
  Direction = null
  before (done) ->
    require [
      'cs!app/models/RespawnPosition'
      'cs!app/lib/Direction'
      ], (respawnPosition, direction) ->
        RespawnPosition = respawnPosition
        Direction = direction
        done()
  
  describe 'constructor', ->
    it 'should accept direction as number', ->
      respawnPosition = new RespawnPosition({x: 0, y: 0, dir: 1})
      respawnPosition.dir().getName().should.equal('E')
    it 'should accept direction as string', ->
      respawnPosition = new RespawnPosition({x: 0, y: 0, dir: 'W'})
      respawnPosition.dir().getNumber().should.equal(3)
    it 'should construct unconfirmed respawn point by default', ->
      respawnPosition = new RespawnPosition({x: 0, y: 0, dir: 'W'})
      respawnPosition.isConfirmed().should.be.false
    it 'should allow to construct confirmed respawn point', ->
      respawnPosition = new RespawnPosition({x: 0, y: 0, dir: 'W', confirmed: true})
      respawnPosition.isConfirmed().should.be.true
  
  describe 'confirmDirection', ->
    respawnPosition = null
    beforeEach ->
      respawnPosition = new RespawnPosition({x: 0, y: 0, dir: 'N'})
    it 'should accept direction as number', ->
      respawnPosition.confirmDirection(2)
      respawnPosition.dir().getName().should.equal('S')
    it 'should accept direction as string', ->
      respawnPosition.confirmDirection('E')
      respawnPosition.dir().getNumber().should.equal(1)
    it 'should accept direction as Direction', ->
      dir = new Direction('W')
      respawnPosition.confirmDirection(dir)
      respawnPosition.dir().getNumber().should.equal(3)
    it 'should confirm the unconfirmed direction', ->
      respawnPosition.isConfirmed().should.be.false
      respawnPosition.confirmDirection('N')
      respawnPosition.isConfirmed().should.be.true


