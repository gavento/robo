define (require, exports, module) ->

  class TileView extends Spine.Controller
    
    tag:
      'div'

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
      @html "(#{ @tile.x },#{ @tile.y })"
      @el.css width:@tileW, height:@tileH, left:(@tileW * @tile.x), top:(@tileH * @tile.y)

  module.exports = TileView
