define (require, exports, module) ->

  CSSSprite = require "app/lib/CSSSprite"
  EntityView = require "cs!app/controllers/EntityView"


  # A base for EntityViews with simple sprite-based animation, optionally with direction.
  # Specify `animFrames` and `animDuration` in children.
  class SimplyAnimatedEntityView extends EntityView
    animFrames: 0
    animDuration: 0

    animationDuration: ->
      return @animDuration

    constructor: ->
      super
      @entity.bind "activate", @animate
      @bind "release", (=> @entity.unbind @animate)

    animate: (opts) =>
      duration = 0
      if opts.lock?
        unlock = opts.lock @entity.cid
        duration = @animDuration
      if opts.speed?
        duration *= opts.speed
      y0 = if @entity.dir? then (@entity.dir().getNumber() * @tileH) else 0
      CSSSprite @el, 0, -y0, -@tileW, 0, @animDuration / @animFrames, @animFrames, true, unlock


  class ConveyorView extends SimplyAnimatedEntityView
    @registerTypeName "C"
    attributes:
      class: 'EntityView ConveyorView'
    animFrames: 12
    animDuration: 60*12


  class ExpressConveyorView extends ConveyorView
    @registerTypeName "E"
    attributes:
      class: 'EntityView ExpressConveyorView'
    animFrames: 6
    animDuration: 40*6


  class CrusherView extends SimplyAnimatedEntityView
    @registerTypeName "X"
    attributes:
      class: 'EntityView CrusherView'
    animFrames: 5
    animDuration: 60*5

  
  class TurnerView extends EntityView
    animFrames: 9
    animDuration: 450


  class TurnerRView extends TurnerView
    @registerTypeName "R"
    attributes:
      class: 'EntityView TurnerRView'


  class TurnerLView extends TurnerView
    @registerTypeName "L"
    attributes:
      class: 'EntityView TurnerLView'


  class TurnerUView extends TurnerView
    @registerTypeName "U"
    attributes:
      class: 'EntityView TurnerUView'

  class HoleView extends EntityView
    @registerTypeName "H"
    attributes:
      class: 'EntityView HoleView'


  module.exports =
    ConveyorView: ConveyorView
    ExpressConveyorView: ExpressConveyorView
    CrusherView: CrusherView

