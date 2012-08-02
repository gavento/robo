define (require, exports, module) ->

  EntityView = require "cs!app/controllers/EntityView"


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
        moverView = @boardView.entityViews[opts.mover.get 'id']
        #DEBUG# @log "mover ", opts.mover, moverView
        if @entity.board.lock
          unlock = @entity.board.lock.getLock @entity.cid
        if moverView.animationLength
          duration = moverView.animationLength()
        @el.animate({left: @boardView.tileW * @entity.x, top: @boardView.tileH * @entity.y},
          duration, 'linear', unlock)

  module.exports = RobotView
