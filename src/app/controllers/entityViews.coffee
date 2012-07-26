define (require, exports, module) ->

  SubclassTypes = require "cs!app/lib/SubclassTypes"
  CSSSprite = require "app/lib/CSSSprite"

  class EntityView extends Spine.Controller
    @extend SubclassTypes
    @typeMap = {}
    @registerType "_"

    tag: 'div'

    attributes:
      class: 'EntityView'

    constructor: ->
      super
      throw "@entity required" unless @entity
      throw "@entityW required" unless @entityW
      throw "@entityH required" unless @entityH
      @entity.bind("create update", @render)
      @render()

    render: =>
      @el.empty()
      @el.css width:@entityW, height:@entityH
      if @entity.dir
        @el.css 'background-position': "0px #{(@entity.dir.getNumber() * @entityH)}px"


  class ConveyorView extends EntityView
    @registerType "C"
    attributes:
      class: 'EntityView ConveyorView'

    constructor: ->
      super
      @entity.bind "activate", @animate

    animate: =>
      unlock = undefined
      lock = @entity.board.lock
      if lock
        @log "locking for ", @entity.cid
        unlock = lock.getLock @entity.cid
        @log "lock: ", lock
      CSSSprite @el, 0, (@entity.dir.getNumber() * @entityH), -@entityW, 0, 40, 12, true, unlock


  class ExpressConveyorView extends ConveyorView
    @registerType "E"
    attributes:
      class: 'EntityView ExpressConveyorView'

    animate: =>
      unlock = undefined
      lock = @entity.board.lock
      if lock
        unlock = lock.getLock @entity.cid
      CSSSprite @el, 0, (@entity.dir.getNumber() * @entityH), -@entityW, 0, 40, 6, true, unlock


  class RobotView extends EntityView
    @registerType "Robot"
    attributes:
      class: 'EntityView RobotView'

    constructor: ->
      super
      @entity.bind "push", @animate

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"


  create = (attr) ->
    throw "entity required" unless attr.entity
    con = EntityView.getType attr.entity.constructor.typeName
    return new con attr

  module.exports =
    create: create
    EntityView: EntityView
