define (require, exports, module) ->


  TestingView = require 'cs!app/controllers/TestingView'
  RiddleView = require 'cs!app/controllers/RiddleView'

  # # App controller #
  class App extends Spine.Controller
    constructor: ->
      super
      
      # define routes
      @routes
        "/riddles/:id": (params) ->
          # riddle view
          @log "Displaying riddle view", params.id
          @replace new RiddleView riddleid:params.id
        "/*id": (params) ->
          # default view (currently used for testing)
          @log "Displaying default view", params.id
          @replace new TestingView json:"text!app/game_test.json"

      # display current route
      Spine.Route.setup() 

  module.exports = App
