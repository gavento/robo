define (require, exports, module) ->

  class TileView extends Spine.Controller

    tag: 'div'

    attributes:
      class: 'TileView'

    constructor: ->
      super
      throw "@tile required" unless @tile
      @tileW ?= 68
      @tileH ?= 68
      @tile.bind "update", @render
      @bind "release", (=> @tile.unbind @render)
      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    render: =>
      evs = @el.children('.ElementView')
      @el.empty()
      @el.css width:@tileW, height:@tileH, left:(@tileW * @tile.x), top:(@tileH * @tile.y)
      @append evs

  module.exports = TileView
