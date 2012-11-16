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

      @robot.bind("update", @render)
      @bind "release", (=> @robot.unbind @render)
      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()


    render: =>
      @el.html("<div class='PlayerRobotViewName'>Robot <b>\"#{ @robot.get 'name' }\"</b> with #{ @robot.get 'health' } health</div>")
      @append @robotView
      for cv in @cardViews
        @append cv
      @append @$("<button class='PlayerRobotViewButton'>Play cards</button>")
      @$('.PlayerRobotViewButton').click =>
        cards = @robot.get 'cards'
        f = (cardno) =>
          if cardno < cards.length
            ml = new MultiLock ( => f(cardno + 1)), 5000
            unlock = ml.getLock "Card"
            cards[cardno].playOnRobot @robot, {lock: ml.getLock}
            unlock()
        f 0
      @append @$("<button class='PlayerRobotViewButtonPlaceRobot'>Place robot</button>")
      @$('.PlayerRobotViewButtonPlaceRobot').click => @robot.place({})
      if @robot.isPlaced()
        @$('.PlayerRobotViewButtonPlaceRobot').attr("disabled", "disabled")


  module.exports = PlayerRobotView
