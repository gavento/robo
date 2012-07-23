define (require, exports, module) ->

  TileView = require 'cs!app/controllers/TileView'

  class BoardView extends Spine.Controller
    
    tag:
      'div'

    attributes:
      class: 'BoardView'

    elements:
      '.TileView': "tileViews"
      
    constructor: ->
      super
      throw "@board required" unless @board
      @tileW ?= 68
      @tileH ?= 68
      @board.bind("create update", @render)
      @render()
      
    render: =>
      @el.empty()
      @el.css width: (@tileW * @board.width), height: (@tileH * @board.height)
      @tilesDiv = $("<div class='BoardViewTiles'></div>")
      @el.append @tilesDiv
      for t in @board.allTiles()
        tv = new TileView tile:t, tileW:@tileW, tileH:@tileH
        @tilesDiv.append tv.el

  module.exports = BoardView
