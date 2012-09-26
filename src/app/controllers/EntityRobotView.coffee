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
    move: (opts) =>
      #DEBUG# @log "robot moved ", @, opts
      if @passive
        return

      opts ?= {}

      if opts.lock?
        if opts.mover?
          if opts.mover instanceof Entity
            moverView = @boardView.entityViews[opts.mover.get 'id']
            opts.duration ?= moverView.animationDuration()
          else if opts.mover instanceof Card
            opts.duration ?= 1000 # a random constant for now
          else throw "unknown mover type"
        opts.duration ?= 1000 # random constant just to show some move
        unlock = opts.lock @entity.cid

      opts.duration ?= 0
      if opts.speed?
        opts.duration *= opts.speed

      @el.animate({left: @boardView.tileW * @entity.x, top: @boardView.tileH * @entity.y},
        opts.duration, 'linear', unlock)


  module.exports = RobotView
