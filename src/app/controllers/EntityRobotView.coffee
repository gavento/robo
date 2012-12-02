define (require, exports, module) ->

  EntityView = require "cs!app/controllers/EntityView"
  Entity = require "cs!app/models/Entity"
  Card = require "cs!app/models/Card"


  class RobotView extends EntityView
    @registerTypeName "Robot"

    attributes:
      class: 'EntityView RobotView'
    animFrames: 9

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"

    # Animate a moving Entity. 
    # `opts` may contain:
    # * `opts.lock` for board locking.
    # * `opts.duration` to override anim. duration.
    # * `opts.speed` to set relative speed (2 = twice as long).
    move: (opts, lock) =>
      #DEBUG# @log "robot moved ", @, opts
      if @passive
        return
      duration = @guessDuration opts
      unlock = lock.getLock("EntityRobotView.move")
      @el.animate({left: @boardView.tileW * @entity.x, top: @boardView.tileH * @entity.y},
        duration, 'linear', unlock)


  module.exports = RobotView
