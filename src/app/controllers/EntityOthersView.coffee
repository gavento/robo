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
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, -(@entity.dir().getNumber() * @tileH), -@tileW, 0, 60, 12, true, unlock

    animationLength: ->
      return 60 * 12


  class ExpressConveyorView extends ConveyorView
    @registerTypeName "E"
    attributes:
      class: 'EntityView ExpressConveyorView'

    animate: =>
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, -(@entity.dir().getNumber() * @tileH), -@tileW, 0, 40, 6, true, unlock

    animationLength: ->
      return 40 * 6


  class CrusherView extends EntityView
    @registerTypeName "X"
    attributes:
      class: 'EntityView CrusherView'

    constructor: ->
      super
      @entity.bind "activate", @animate
      @bind "release", (=> @entity.unbind @animate)

    animate: =>
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, 0, -@tileW, 0, 60, 5, true, unlock

    animationLength: ->
      return 60 * 5


  module.exports =
    ConveyorView: ConveyorView
    ExpressConveyorView: ExpressConveyorView
    CrusherView: CrusherView

