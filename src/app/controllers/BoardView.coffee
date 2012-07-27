define (require, exports, module) ->

  TileView = require 'cs!app/controllers/TileView'
  entityViews = require 'cs!app/controllers/entityViews'

  class BoardView extends Spine.Controller

    tag:
      'div'

    attributes:
      class: 'BoardView'

    constructor: ->
      super
      throw "@board required" unless @board
      @tileW ?= 68
      @tileH ?= 68

      # @tiles[x][y] is a TileView
      @tileViews = {}
      @bind "release", (=> @releaseTileViews())

      # map of Entity cid -> EntityView
      @entityViews = {}
      @bind "release", (=> @releaseEntityViews())

      # complete redraw
      @board.bind("create update", @render)
      @bind "release", (=> @board.unbind @render)

      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    releaseTileViews: ->
      for x, row of @tileViews
        for y, tv of row
          tv.release()
      @tileViews = {}

    releaseEntityViews: ->
      for cid, ev of @entityViews
        ev.release()
      @entityViews = {}

    render: =>
      @el.empty()
      @el.css width: (@tileW * @board.width), height: (@tileH * @board.height)
      @tilesDiv = $("<div class='BoardViewTiles'></div>")
      @el.append @tilesDiv
      @releaseTileViews()
      @releaseEntityViews()
      for t in @board.allTiles()
        tv = new TileView tile:t, tileW:@tileW, tileH:@tileH
        @tileViews[t.x] ?= {}
        @tileViews[t.x][t.y] = tv
        @tilesDiv.append tv.el

      for e in @board.allEntities()
        @entityViews[e.cid] = entityViews.create entity: e, entityW: @tileW, entityH: @tileH, boardView: @


  module.exports = BoardView
