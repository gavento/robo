define (require, exports, module) ->

  Tile = require 'cs!app/models/Tile'
  entities = require 'cs!app/models/entities'
  MultiLock = require 'cs!app/lib/MultiLock'

  class Board extends Spine.Model
    @configure 'Board', 'width', 'height', 'entities'
    # width, height - integers
    # name - string
    # tiles - map x -> map y -> Tile

    constructor: (atts) ->
      @width ?= 0
      @height ?= 0
      @tiles ?= {}
      super atts

    load: (atts) ->
      if (atts.width and atts.width != @width) or
          (atts.height and atts.height != @height)
        @resize atts.width, atts.height
      delete atts.width
      delete atts.height
      super atts

    entities: (val) ->
      if not val
        return @allEntities()
      all = @allEntities()
      for e in all
        e.lift()
        e.destroy()
      for e in val
        if e not instanceof entities.Entity
          e = entities.load e
        throw "invalid positon for #{e}" unless (e.x < @width and e.y < @height and e.x >= 0 and e.y >= 0)
        e.place @tiles[e.x][e.y]

    resize: (w, h) ->
      # remove old tiles
      if @width > 0 and @height > 0
        for x in [0..(@width-1)]
          for y in [0..(@height-1)]
            if x >= w or y >= h
              @tiles[x][y].destroy()
              delete @tiles[x][y]
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
      if x >= 0 and y >= 0 and x < @width and y < @height
        return @tiles[x][y]
      else
        return undefined

    allTiles: ->
      res = []
      if @width > 0 and @height > 0
        for x in [0..(@width-1)]
          for y in [0..(@height-1)]
            res.push @tiles[x][y]
      return res

    allEntities: ->
      res = []
      for t in @allTiles()
        res = res.concat(t.entities())
      return res

    entitiesByPhase: ->
      eByP = {}
      for e in @allEntities()
        for p in e.getPhases()
          eByP[p] ?= []
          eByP[p].push(e)
      return eByP

    activateOnePhase: (fromTime=0) ->
      eByP = @entitiesByPhase()
      phases = (Number(k) for k in _.keys(eByP))
      phases.sort()
      for t in phases
        if t >= fromTime
          for e in eByP[t]
            e.activate(t)
          return t + 1
      return -1

    activateAllPhases: (callback) ->
      # experimental
      t = 0
      f = =>
        if t >= 0
          @lock = new MultiLock f, 5000
          unlock = @lock.getLock "Board"
          t = @activateOnePhase t
          unlock()
        else
          delete @lock
          if callback
            callback()
      f()

  module.exports = Board
