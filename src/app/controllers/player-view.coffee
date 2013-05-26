define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/simple-controller'
  PlayerRobotView = require 'cs!app/controllers/player-robot-view'

  class PlayerController extends SimpleController
    constructor: ->
      super
      throw "@player required" unless @player


  class PlayerView extends PlayerController
    tag: 'div'
    attributes: class: 'PlayerView'
    constructor: ->
      super
      @appendController new PlayerNameView
        player: @player
      @appendController new PlayerRobotViews
        player: @player
        tileW: @tileW
        tileH: @tileH


  class PlayerNameView extends PlayerController
    tag: 'div'
    attributes: class: 'PlayerNameView'
    constructor: ->
      super
      @html("Player \"#{ @player.get 'name' }\"")
  
  
  class PlayerRobotViews extends PlayerController
    tag: 'div'
    constructor: ->
      super
      for robot in @player.robots()
        view = new PlayerRobotView
          player:@player
          robot: robot
          tileW: @tileW
          tileH: @tileH
        @appendController view

  module.exports = PlayerView
