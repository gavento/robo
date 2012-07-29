define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  MultiLock = require 'cs!app/lib/MultiLock'
  Tile = require 'cs!app/models/Tile'

  Entity = require 'cs!app/models/Entity'
  require 'cs!app/models/EntityOthers'
  require 'cs!app/models/EntityRobot'


  class Board extends SimpleModel
    @configure {name: 'Board'}, 'width', 'height', 'entities'
    @typedPropertyArray 'entities', Entity
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

      for e in @entities()
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

    entitiesByPhase: ->
      eByP = {}
      for e in @entities()
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
          # FIFO of hooks to execute after phase
          @afterPhase = []
          for e in eByP[t]
            e.activate(t)
          while @afterPhase.length > 0
            cb = @afterPhase.shift()
            cb()
          return t + 1
      return -1

    activateAllPhases: (callback) ->
      # experimental animation locking
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
