define (require, exports, module) ->

  BoardView = require 'cs!app/controllers/board-view'
  EntityView = require 'cs!app/controllers/entity-view'
  Entity = require 'cs!app/models/entity'
  Direction = require 'cs!app/lib/direction'


  class EditorView extends Spine.Controller

    tag:
      'div'

    attributes:
      class: 'EditorView'

    constructor: (options) ->
      super
      throw "@board required" unless @board
      @tileW ?= 68
      @tileH ?= 68

      # List of items in the palette
      @tools = []
      for name, type of Entity.typeMap
        if 'dir' in type.attributes
          for d in Direction.dirs
            e = Entity.createSubType x:0, y:0, type:name, dir:d
            @tools.push e
        else
          e = Entity.createSubType x:0, y:0, type:name
          @tools.push e
      @bind "release", (=> @tools = [])

      @board.bind("update", @render)
      @render()

    render: =>
      @html """
            <div class='EditorSidebar'>
              <div class='EditorCategory'>Coming soon ...</div>
              <div class='EditorPalette'></div>
            </div>
            <div class='EditorBoard'></div>
            """

      for tool in @tools
        e = EntityView.createSubType
          entity:tool
          tileW:@tileW
          tileH:@tileH
          type:tool.get 'type'
        @$('.EditorPalette').append e.el


      if @boardView? then @boardView.release()
      @boardView = new BoardView board:@board, tileW:@tileW, tileH:@tileH
      @$('.EditorBoard').append @boardView.el


  module.exports = EditorView
