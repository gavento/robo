define (require, exports, module) ->

  CSSSprite = require "app/lib/css-sprite"
  EntityView = require "cs!app/controllers/entity-view"


  # A base for EntityViews with simple sprite-based animation, optionally with direction.
  # Specify `animFrames` and `animDuration` in children.
  class SimplyAnimatedEntityView extends EntityView
    animFrames: 0
    animDuration: 0
    animationDuration: -> return @animDuration
    constructor: ->
      super
      @bindToModel @entity, "entity:activate", @onEntityActivate

    onEntityActivate: (opts, lock) =>
      unlock = lock.getLock("EntityOthersView.onEntityActivate")
      @animateEntity(opts, unlock)


  class ConveyorView extends SimplyAnimatedEntityView
    @registerTypeName "C"
    attributes: class: 'EntityView ConveyorView'
    animFrames: 12
    animDuration: 60*12


  class ExpressConveyorView extends ConveyorView
    @registerTypeName "E"
    attributes: class: 'EntityView ExpressConveyorView'
    animFrames: 6
    animDuration: 40*6


  class CrusherView extends SimplyAnimatedEntityView
    @registerTypeName "X"
    attributes: class: 'EntityView CrusherView'
    animFrames: 5
    animDuration: 60*5

  
  class TurnerView extends SimplyAnimatedEntityView
    animFrames: 9
    animDuration: 450


  class TurnerRView extends TurnerView
    @registerTypeName "R"
    attributes: class: 'EntityView TurnerRView'


  class TurnerLView extends TurnerView
    @registerTypeName "L"
    attributes: class: 'EntityView TurnerLView'


  class TurnerUView extends TurnerView
    @registerTypeName "U"
    attributes: class: 'EntityView TurnerUView'


  class HoleView extends EntityView
    @registerTypeName "H"
    attributes: class: 'EntityView HoleView'


  class WallView extends EntityView
    @registerTypeName "W"
    attributes: class: 'EntityView WallView'


  module.exports =
    ConveyorView: ConveyorView
    ExpressConveyorView: ExpressConveyorView
    CrusherView: CrusherView
    TurnerRView: TurnerRView
    TurnerLView: TurnerLView
    TurnerUView: TurnerUView
    HoleView: HoleView

