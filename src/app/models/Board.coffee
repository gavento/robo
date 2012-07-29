define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  MultiLock = require 'cs!app/lib/MultiLock'
  Tile = require 'cs!app/models/Tile'

  Entity = require 'cs!app/models/Entity'
  require 'cs!app/models/EntityOthers'
  require 'cs!app/models/EntityRobot'


  class Board extends SimpleModel
    @configure {name: 'Board'}, 'width', 'height', 'entities'
    # entities: [Entity]
    # width, height: integers
    # name: string
    # tiles: map x -> map y -> [Entity ids]

    constructor: (atts) ->
      @width_ = 0
      @height_ = 0
      @entities_ = []
      @tiles_ = {}
      @entityById_ = {}
      super atts

    destroy: ->
      @set 'entities', []
      super

    width: (val) ->
      if val? and val != @width_ then @resize val, @height_
      return @width_

    height: (val) ->
      if val? and val != @height then @resize @width_, val
      return @height_

    resize: (w, h) ->
      if w == @width_ and h == @height_ then return
      # remove entities outside the new size
      es = @get('entities').slice()
      for e in es
        if e.x >= w or e.y >= h
          @removeEntity e
      @width_ = w
      @height_ = h
      @trigger "resize"

    entities: (val) ->
      if val?
        es = @entities_.slice()
        for e in es
          @removeEntity e
        for e in val
          @addEntity e
      return @entities_

    addEntity: (e) ->
      unless e instanceof Entity
        e = Entity.createSubType e
      throw "added Entity has @board defined" if e.board
      e.board = @
      e.bind "move", @moveEntity
      @entities_.push e
      @entityById_[e.get 'id'] = e
      @tiles_[e.x] ?= {}
      @tiles_[e.x][e.y] ?= []
      @tiles_[e.x][e.y].push e
      @trigger "addEntity", e

    removeEntity: (e) ->
      @trigger "removeEntity", e
      @tiles_[e.x][e.y] = @tiles_[e.x][e.y].filter (v) -> not (v is e)
      @entities_ = @entities_.filter (v) -> not (v is e)
      delete @entityById_[e.get 'id']
      e.destroy()

    inside: (x, y) ->
      return x >= 0 and y >= 0 and x < @get('width') and y < @get('height')

    tile: (x, y) ->
      if @inside x, y and @tiles_[x]? and @tiles_[x][y]?
        return @tiles_[x][y]
      else
        return []

    # internal - only for updating tiles 
    moveEntity: (opts) =>
      unless opts.oldX? and opts.oldY? and opts.entity?
        throw "opts.oldX, opts.oldY and opts.entity required"
      e = opts.entity
      @tiles_[opts.oldX][opts.oldY] = @tiles_[opts.oldX][opts.oldY].filter (v) -> not (v is e)
      @tiles_[e.x] ?= {}
      @tiles_[e.x][e.y] ?= []
      @tiles_[e.x][e.y].push e

    entityById: (id) ->
      e = @entityById_[id]
      throw "no Entity with id=\"#{id}\"" unless e?
      return e

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
            e.activate phase:t
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
