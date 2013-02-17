define (require, exports, module) ->

  EntityView = require 'cs!app/controllers/EntityView'
  CardView = require 'cs!app/controllers/CardView'
  MultiLock = require 'cs!app/lib/MultiLock'

  class PlayerRobotView extends Spine.Controller

    tag: 'div'

    attributes:
      class: 'PlayerRobotView'

    constructor: ->
      super
      throw "@robot required" unless @robot?

      @robotView = EntityView.createSubType
        entity: @robot
        type: @robot.get 'type'
        tileW: 68
        tileH: 68
        passive: true
      @bind "release", (=> @robotView.release())

      @cardViews = []
      for c in @robot.get 'cards'
        cv = CardView.createSubType
          card: c
          type: c.get 'type'
        @cardViews.push cv
        @bind "release", (=> cv.release())

      @robot.bind("entity:damage", @onEntityDamage)
      @bind "release", (=> @robot.unbind @onEntityDamage)
      @robot.bind("entity:fall", @onEntityFall)
      @bind "release", (=> @robot.unbind @onEntityFall)
      @robot.bind("entity:place", @onEntityPlace)
      @bind "release", (=> @robot.unbind @onEntityFall)
      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()


    render: =>
      @el.html("<div class='PlayerRobotViewName'>Robot <b>\"#{ @robot.get 'name' }\"</b> with #{ @robot.get 'health' } health</div>")
      @append @robotView
      for cv in @cardViews
        @append cv

    onEntityDamage: =>
      @render()

    onEntityFall: =>
      console.log "onEntityFall"
      @append @$("<button class='PlayerRobotViewButtonPlaceRobot'>Place robot</button>")
      @$('.PlayerRobotViewButtonPlaceRobot').click => @robot.setRespawnDirection('N')
      if @robot.isPlaced()
        @$('.PlayerRobotViewButtonPlaceRobot').attr("disabled", "disabled")

    onEntityPlace: =>
      @render()
    

  module.exports = PlayerRobotView
