define (require, exports, module) ->

  TileView = require 'cs!app/controllers/TileView'

  EntityView = require 'cs!app/controllers/EntityView'
  require 'cs!app/controllers/EntityOthersView'
  require 'cs!app/controllers/EntityRobotView'

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

      # map of Entity id -> EntityView
      @entityViews = {}
      @bind "release", (=> @releaseEntityViews())

      # complete redraw
      @board.bind("update", @render)
      @bind "release", (=> @board.unbind @render)

      # only resize
      @board.bind("resize", @resize)
      @bind "release", (=> @board.unbind @resize)

      # add/remove entity
      @board.bind("addEntity", @addEntityView)
      @bind "release", (=> @board.unbind @addEntityView)
      @board.bind("removeEntity", @removeEntityView)
      @bind "release", (=> @board.unbind @addEntityView)

      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    releaseEntityViews: ->
      for id, ev of @entityViews
        ev.release()
      @entityViews = {}

    resize: =>
      @el.css
        width: @tileW * @board.get 'width'
        height: @tileH * @board.get 'height'

    render: =>
      @releaseEntityViews()

      @el.empty()
      @tilesDiv = $("<div class='BoardViewTiles'></div>")
      @resize()
      @el.append @tilesDiv

      for e in @board.get 'entities'
        @addEntityView e

    addEntityView: (entity) =>
      ev = EntityView.createSubType
        entity: entity
        type: entity.get 'type'
        entityW: @tileW
        entityH: @tileH
        boardView: @
      @tilesDiv.append ev.el
      @entityViews[entity.get 'id'] = ev
      return ev

    removeEntityView: (entity) =>
      # entity can be an id
      if typeof entity == "string"
        id = entity
      else
        id = entity.get 'id'
      ev = @entityViews[id]
      delete @entityViews[id]
      ev.release()


  module.exports = BoardView
