define (require, exports, module) ->

  ST = require "cs!app/lib/SubClassTypes"

  class EntityView extends Spine.Controller
    ST.baseClass @
    # typical create call:
    #   EntityView.createSubType entity:e, type:e.type, boardView:b

    tag: 'div'

    animationDuration: ->
      return 0

    attributes:
      class: 'EntityView'

    constructor: ->
      super
      throw "@entity required" unless @entity
      throw "@boardView or @tileW and @tileH required" unless @boardView? or (@tileW? and @tileH?)
      @tileW ?= @boardView.tileW
      @tileH ?= @boardView.tileH
      @passive ?= false

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
      if not @passive
        @el.css
          'left': x * @tileW
          'top': y * @tileH

    move: (opts) =>
      @setPosition()

    render: =>
      @el.empty()
      @el.css width: @tileW, height: @tileH
      if @entity.dir and not @passive
        @el.css 'background-position': "0px #{-(@entity.get('dir').getNumber() * @tileH)}px"
      @setPosition()


  module.exports = EntityView
