define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/SimpleController'
  EntityView = require 'cs!app/controllers/EntityView'
  require 'cs!app/controllers/EntityOthersView'
  require 'cs!app/controllers/EntityRobotView'

  class BoardController extends SimpleController
    constructor: ->
      super
      throw "@board required" unless @board
      throw "@tileW and @tileH required" unless @tileW and @tileH


  class BoardView extends SimpleController
    tag: 'div'
    attributes: class: 'BoardView'
    constructor: ->
      super
      @appendController new BoardViewTiles
        board: @board
        tileW: @tileW
        tileH: @tileH


  class BoardViewTiles extends BoardController
    tag: 'div'
    attributes: class: 'BoardViewTiles'
    constructor: ->
      super
      @bindToModel @board, "update", @render
      @bindToModel @board, "resize", @resize
      @bindToModel @board, "addEntity", @addEntityView
      @bindToModel @board, "removeEntity", @removeEntityView
      @entityViews = {} # map of Entity id -> EntityView
      @bind "release", (=> @releaseEntityViews())
      @render()
    
    render: =>
      @releaseEntityViews()
      @resize()
      for entity in @board.get 'entities'
        @addEntityView entity

    resize: =>
      @el.css
        width: @tileW * @board.get 'width'
        height: @tileH * @board.get 'height'

    addEntityView: (entity) =>
      view = EntityView.createSubType
        entity: entity
        type: entity.get 'type'
        tileW: @tileW
        tileH: @tileH
        entityViews: @entityViews
      @append view
      @entityViews[entity.get 'id'] = view

    removeEntityView: (entity) =>
      # entity can be an id
      if typeof entity == "string"
        id = entity
      else
        id = entity.get 'id'
      view = @entityViews[id]
      delete @entityViews[id]
      view.release()

    releaseEntityViews: =>
      for id, view of @entityViews
        view.release()
      @entityViews = {}


  module.exports = BoardView
