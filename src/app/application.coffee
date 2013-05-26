define (require, exports, module) ->


  TestingView = require 'cs!app/controllers/testing-view'
  RiddleView = require 'cs!app/controllers/riddle-view'
  EditorView = require 'cs!app/controllers/editor-view'
  Board = require 'cs!app/models/board'

  # # App controller #
  class App extends Spine.Controller
    constructor: ->
      super
      @view = null
      # define routes
      replaceView = (newView) =>
        oldView = @view
        @view = newView
        @replace @view
        oldView.release() if oldView?
      @routes
        '/riddles/:id': (params) =>
          # riddle view
          @log 'Displaying riddle view', params.id
          replaceView new RiddleView riddleid:params.id
        '/edit/': (params) =>
          # editor with an empty board
          board = new Board width:4, height:4
          @log 'Displaying editor for new board', board
          replaceView new EditorView board:board
        '/*id': (params) =>
          # default view (currently used for testing)
          @log 'Displaying default view', params.id
          replaceView new TestingView json: 'text!json/game-test.json'

      # display current route
      Spine.Route.setup()
      
      # socket.io tests  
      socket = io.connect('http://localhost:4242')
      socket.on('news', (data) =>
        console.log(data)
        socket.emit('my other event', { my: 'data' }))


  module.exports = App
