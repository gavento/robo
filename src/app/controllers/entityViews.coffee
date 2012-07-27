define (require, exports, module) ->

  SubclassTypes = require "cs!app/lib/SubclassTypes"
  CSSSprite = require "app/lib/CSSSprite"

  class EntityView extends Spine.Controller
    @extend SubclassTypes
    @typeMap = {}

    tag: 'div'

    attributes:
      class: 'EntityView'

    constructor: ->
      super
      throw "@entity required" unless @entity
      throw "@entityW required" unless @entityW
      throw "@entityH required" unless @entityH
      throw "@boardView required" unless @boardView

      @entity.bind("create update", @render)
      @bind "release", (=> @entity.unbind @render)
      @entity.bind("place", @place)
      @bind "release", (=> @entity.unbind @place)
      @entity.bind("lift", @lift)
      @bind "release", (=> @entity.unbind @lift)

      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    place: =>
      @appendTo @boardView.tileViews[@entity.x][@entity.y]

    lift: =>
      @el.remove()

    render: =>
      $('body').append @el
      @el.empty()
      @el.css width:@entityW, height:@entityH
      if @entity.dir
        @el.css 'background-position': "0px #{-(@entity.dir.getNumber() * @entityH)}px"
      @place()


  class ConveyorView extends EntityView
    @registerType "C"
    attributes:
      class: 'EntityView ConveyorView'

    constructor: ->
      super
      @entity.bind "activate", @animate
      @bind "release", (=> @entity.unbind @animate)

    animate: =>
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, -(@entity.dir.getNumber() * @entityH), -@entityW, 0, 40, 12, true, unlock


  class ExpressConveyorView extends ConveyorView
    @registerType "E"
    attributes:
      class: 'EntityView ExpressConveyorView'

    animate: =>
      if @entity.board.lock
        unlock = @entity.board.lock.getLock @entity.cid
      CSSSprite @el, 0, -(@entity.dir.getNumber() * @entityH), -@entityW, 0, 40, 6, true, unlock


  class RobotView extends EntityView
    @registerType "Robot"
    attributes:
      class: 'EntityView RobotView'

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"


  # typical call: EntityView.create entity:e, entityW:w, entityH:h, boardView:b
  create = (attr) ->
    throw "entity required" unless attr.entity
    con = EntityView.getType attr.entity.constructor.typeName
    return new con attr

  module.exports =
    create: create
    EntityView: EntityView
