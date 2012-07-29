define (require, exports, module) ->

  CSSSprite = require "app/lib/CSSSprite"
  EntityView = require "cs!app/controllers/EntityView"


  class ConveyorView extends EntityView
    @registerTypeName "C"
    attributes:
      class: 'EntityView ConveyorView'

    constructor: ->
      super
      @entity.bind "activate", @animate
      @bind "release", (=> @entity.unbind @animate)

    animate: =>
      @log "animating ", @
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, -(@entity.dir().getNumber() * @entityH), -@entityW, 0, 40, 12, true, unlock


  class ExpressConveyorView extends ConveyorView
    @registerTypeName "E"
    attributes:
      class: 'EntityView ExpressConveyorView'

    animate: =>
      @log "animating ", @
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, -(@entity.dir().getNumber() * @entityH), -@entityW, 0, 40, 6, true, unlock


  module.exports =
    ConveyorView: ConveyorView
    ExpressConveyorView: ExpressConveyorView

