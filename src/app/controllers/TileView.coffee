define (require, exports, module) ->

  entityViews = require "cs!app/controllers/entityViews"

  class TileView extends Spine.Controller

    tag: 'div'

    attributes:
      class: 'TileView'

    elements:
      '.ElementView': "ElementViews"

    constructor: ->
      super
      throw "@tile required" unless @tile
      @tileW ?= 68
      @tileH ?= 68
      @tile.bind("create update", @render)
      @render()

    render: =>
      @el.empty()
      @el.css width:@tileW, height:@tileH, left:(@tileW * @tile.x), top:(@tileH * @tile.y)
      for e in @tile.entities()
        @append (entityViews.create entity:e, entityW:@tileW, entityH:@tileH)
#      @append "(#{ @tile.x },#{ @tile.y })"


  module.exports = TileView
