define (require, exports, module) ->

  PlayerRobotView = require 'cs!app/controllers/PlayerRobotView'

  class PlayerController extends Spine.Controller
    constructor: ->
      super
      throw "@player required" unless @player

  class PlayerView extends PlayerController
    tag: 'div'
    attributes: class: 'PlayerView'
    constructor: ->
      super
      @name = new PlayerNameView player: @player
      @bind 'release', (=> @name.release())
      @robots = new PlayerRobotViews player: @player, tileW: @tileW, tileH: @tileH
      @bind 'release', (=> @robots.release())
      @append @name
      @append @robots


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
        @bind 'release', (=> view.release())
        @append view

  module.exports = PlayerView
