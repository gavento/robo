define (require, exports, module) ->

  ST = require "cs!app/lib/SubClassTypes"

  class EntityView extends Spine.Controller
    ST.baseClass @
    # typical create call:
    #   EntityView.createSubType entity:e, type:e.type, entityW:w, entityH:h, boardView:b

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
        @el.css 'background-position': "0px #{-(@entity.dir().getNumber() * @entityH)}px"
      @place()


  module.exports = EntityView
