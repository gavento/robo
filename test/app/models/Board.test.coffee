describe 'Board', ->
  Board = null
 
  before (done) ->
    require ['cs!app/models/Board'], (board) ->
      Board = board
      done()
  
  describe 'new Board', ->
    it 'should have specified size', ->
        board = new Board({width: 3, height: 2})
        board.width().should.equal(3)
        board.height().should.equal(2)
    it 'should be empty', ->
        board = new Board({width: 3, height: 2})
        board.entities().should.be.empty
