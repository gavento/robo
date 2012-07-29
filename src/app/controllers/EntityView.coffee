define (require, exports, module) ->

  ST = require "cs!app/lib/SubClassTypes"

  class EntityView extends Spine.Controller
    ST.baseClass @
    # typical create call:
    #   EntityView.createSubType entity:e, type:e.type, boardView:b

    tag: 'div'

    attributes:
      class: 'EntityView'

    constructor: ->
      super
      throw "@entity required" unless @entity
      throw "@boardView required" unless @boardView

      @entity.bind("update", @render)
      @bind "release", (=> @entity.unbind @render)
      @entity.bind("move", @move)
      @bind "release", (=> @entity.unbind @move)

      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    # x, y default to entity.x, entity.y
    setPosition: (x, y) ->
      unless x? and y?
        x = @entity.get 'x'
        y = @entity.get 'y'
      @el.css
        'left': x * @boardView.tileW
        'top': y * @boardView.tileH

    move: (opts) =>
      @setPosition()

    render: =>
      @el.empty()
      @el.css width: @boardView.tileW, height: @boardView.tileH
      if @entity.dir
        @el.css 'background-position': "0px #{-(@entity.get('dir').getNumber() * @boardView.tileH)}px"
      @setPosition()


  module.exports = EntityView
