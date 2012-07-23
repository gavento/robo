define (require, exports, module) ->

  Tile = require 'cs!app/models/Tile'

  class Board extends Spine.Model
    @configure 'Board', 'width', 'height', 'tiles'
    # width, height - integers
    # name - string
    # tiles - map x -> map y -> Tile

    constructor: ->
      super
      @width ?= 0
      @height ?= 0
      @tiles ?= {}

    resize: (w, h) ->
      # remove old tiles
      if @width > 0 and @height > 0
        for x in [0..(@width-1)]
          for y in [0..(@height-1)]
            if x >= w or y >= h
              @tiles[x][y].destroy()
              @tiles[x][y] = undefined
      # add new tiles
      if w > 0 and h > 0
        for x in [0..(w-1)]
          for y in [0..(h-1)]
            if x >= @width or y >= @height
              @tiles[x] ?= {}
              @tiles[x][y] = new Tile x:x, y:y, board:@
      @width = w
      @height = h
      @trigger "update"

    getTile: (x, y) ->
      return @tiles[x][y]

    allTiles: ->
      res = []
      for x in [0..(@width-1)]
        for y in [0..(@height-1)]
          res.push @tiles[x][y]
      return res
  
    allEntities: ->
      return (t.entities for col, t of (row for x, row of @tiles).join()).join()

    entitiesByPhase: ->
      eByP = {}
      for e in @allEntities()
        for p in e.phases
          eByP[p] ?= []
          eByP[p].push(e)
      return eByP
      
    activateOnePhase: (fromTime=0) ->
      eByP = @entitiesByPhase()
      phases = _.keys eByP
      phases.sort()
      for t in phases
        if t >= fromTime
          for e in eByP[t]
            e.activate(t)
        return t + 1
      return -1
          
    activateAllPhases: ->
      t = 0
      while t >= 0
        t = @activateOnePhase t
      
  module.exports = Board
