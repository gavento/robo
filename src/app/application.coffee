define (require, exports, module) ->


  TestingView = require 'cs!app/controllers/TestingView'
  RiddleView = require 'cs!app/controllers/RiddleView'
  EditorView = require 'cs!app/controllers/EditorView'
  Board = require 'cs!app/models/Board'

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
          replaceView new TestingView json: 'text!app/game_test.json'

      # display current route
      Spine.Route.setup()


  module.exports = App
