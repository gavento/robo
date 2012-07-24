define (require, exports, module) ->

  SubclassTypes = require "cs!app/lib/SubclassTypes"

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
        @el.css 'background-position-y':(@entity.dir.getNumber() * @entityH)

  class ConveyorView extends EntityView
    @registerType "C"
    attributes:
      class: 'EntityView ConveyorView'

  class ExpressConveyorView extends EntityView
    @registerType "E"
    attributes:
      class: 'EntityView ExpressConveyorView'

  create = (attr) ->
    throw "entity required" unless attr.entity
    con = EntityView.getType attr.entity.constructor.typeName
    return new con attr

  module.exports =
    create: create
    EntityView: EntityView
