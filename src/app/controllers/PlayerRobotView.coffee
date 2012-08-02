define (require, exports, module) ->

  EntityView = require 'cs!app/controllers/EntityView'


  class PlayerRobotView extends Spine.Controller

    tag: 'div'

    attributes:
      class: 'PlayerRobotView'

    constructor: ->
      super
      throw "@robot required" unless @robot?

      @robot.bind("update", @render)
      @bind "release", (=> @robot.unbind @render)
      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    render: =>
      @el.html("<b>#{ @robot.get 'name' }</b> with #{ @robot.get 'health' } health")
      if @robotView then @robotView.release()
      @log @robot
      @robotView = EntityView.createSubType
        entity: @robot
        type: @robot.get 'type'
        tileW: 68
        tileH: 68
        passive: true

      @el.prepend @robotView.el


  module.exports = PlayerRobotView
