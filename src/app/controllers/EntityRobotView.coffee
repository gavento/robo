define (require, exports, module) ->

  EntityView = require "cs!app/controllers/EntityView"
  Entity = require "cs!app/models/Entity"
  Card = require "cs!app/models/Card"


  class RobotView extends EntityView
    @registerTypeName "Robot"

    attributes:
      class: 'EntityView RobotView'

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"

    move: (opts) =>
      #DEBUG# @log "robot moved ", @, opts
      if opts.mover? and not @passive
        duration = 100

        if opts.mover instanceof Entity
          moverView = @boardView.entityViews[opts.mover.get 'id']
          if moverView.animationLength?
            duration = moverView.animationLength()
        else if opts.mover instanceof Card
          duration = 400
        else throw "unknown mover type"

        if @entity.board.lock
          unlock = @entity.board.lock.getLock @entity.cid
        @el.animate({left: @boardView.tileW * @entity.x, top: @boardView.tileH * @entity.y},
          duration, 'linear', unlock)


  module.exports = RobotView
