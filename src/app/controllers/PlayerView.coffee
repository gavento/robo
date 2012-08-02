define (require, exports, module) ->

  PlayerRobotView = require 'cs!app/controllers/PlayerRobotView'


  class PlayerView extends Spine.Controller

    tag: 'div'

    attributes:
      class: 'PlayerView'

    constructor: ->
      super
      throw "@player required" unless @player

      @player.bind("update", @render)
      @bind "release", (=> @player.unbind @render)
      for r in @player.robots()
        r.bind("update", @render)
        @bind "release", (=> r.unbind @render)

      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    render: =>
      @el.html("<div class='PlayerViewName'>Player \"#{ @player.get 'name' }\"</div><div class='PlayerViewRobots'></div>")

      if @robotViews? then (rv.release() for rv in @robotViews)
      @robotViews = []
      for r in @player.get 'robots'
        rv = new PlayerRobotView player:@player, playerView:@, robot: r
        @robotViews.push rv
        @$('.PlayerViewRobots').append rv.el


  module.exports = PlayerView
