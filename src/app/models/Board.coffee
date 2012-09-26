define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  MultiLock = require 'cs!app/lib/MultiLock'
  Tile = require 'cs!app/models/Tile'

  # Load all Entity subtypes for loading
  Entity = require 'cs!app/models/Entity'
  require 'cs!app/models/EntityOthers'
  require 'cs!app/models/EntityRobot'


  # # class Board #
  #
  # Board representation, owns all the contained entities.
  #
  # ### Model properties ###
  #
  # * `entities: [Entity]` - list of Entities, in no particular order.
  # * `width, height` - board size, coordinates are in ranges `0..(width-1)`.
  # * `name` - board or map name, just informative.
  # 
  # ### Internal ###
  #
  # * `tiles_: map x -> map y -> [Entity ids]` - list of Entity id for every
  #   map tile.
  # * `entityById_` - map of entities by their id.

  class Board extends SimpleModel
    @configure {name: 'Board'}, 'width', 'height', 'entities'


    constructor: (atts) ->
      @width_ = 0
      @height_ = 0
      @entities_ = []
      @tiles_ = {}
      @entityById_ = {}
      super atts


    destroy: ->
      @set 'entities', [] # properly call destoy for all Entities
      super


    # Setters/getters for attributes

    width: (val) ->
      if val? and val != @width_ then @resize val, @height_
      return @width_


    height: (val) ->
      if val? and val != @height then @resize @width_, val
      return @height_


    entities: (val) ->
      if val?
        es = @entities_.slice()
        for e in es
          @removeEntity e
        for e in val
          @addEntity e
      return @entities_


    # Resize board, destroying those outside the new size.
    # Triggers `"resize"` event.
    resize: (w, h) ->
      if w == @width_ and h == @height_ then return
      es = @get('entities').slice()
      for e in es
        if e.x >= w or e.y >= h
          @removeEntity e
      @width_ = w
      @height_ = h
      @trigger "resize"


    # Add the Entity, triggers `"addEntity", e`. If `e` is not Entity, it is
    # loaded from JSON.
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


    # Remove and destroy the given Entity. Triggers `"removeEntity", e`.
    removeEntity: (e) ->
      @trigger "removeEntity", e
      @tiles_[e.x][e.y] = @tiles_[e.x][e.y].filter (v) -> not (v is e)
      @entities_ = @entities_.filter (v) -> not (v is e)
      delete @entityById_[e.get 'id']
      e.destroy()


    # Is the given point inside the Board?
    inside: (x, y) ->
      return x >= 0 and y >= 0 and x < @get('width') and y < @get('height')


    # Return list of entities at `[x][y]`. Returns `[]` outside the board.
    tile: (x, y) ->
      if @inside x, y and @tiles_[x]? and @tiles_[x][y]?
        return @tiles_[x][y]
      else
        return []


    # Update internal structures on Entity move. Internal,
    # called on event "move" from the Entity.
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

    # Activate all entities within ONE phase after phase `fromTime` (exclusive).
    # Returns the actually activated phase number (pass this to the next iteration) or -1 in case
    # of no more phases.
    # Passes `attr` extended with `phase` and `afterHooks` to `Entity.activate`.
    # Optionally, `eByP` can be a precomputed value of `@entitiesByPhase`.
    activateOnePhase: (attrs, fromTime=-1, eByP) ->
      eByP ?= @entitiesByPhase()
      phases = (Number(k) for k in _.keys(eByP))
      phases.sort()

      for t in phases
        if t > fromTime
          attrsCopy = Object.create attrs
          # Somewhat a HACK: FIFO of hooks to execute after phase
          attrsCopy.afterHooks = []
          attrsCopy.phase = t
          for e in eByP[t]
            e.activate attrsCopy
          while attrsCopy.afterHooks.length > 0
            cb = attrsCopy.afterHooks.shift()
            cb()
          return t
      return -1

    # Activate the board, synchronously. Note that this does not do any locking or animation synchronization.
    # Passes `attrs` to `activateOnePhase` and subsequently to `Entity.activate`
    activateBoard: (attrs) ->
      eByP = @entitiesByPhase()
      t = -0.5
      while t > -1
        t = @activateOnePhase attrs, t, eByP

    # Activate the board, asynchronously, with locking for animation synchronisation.
    # For every phase, a `Multilock` is created with the given timeout (in ms, 5s default).
    # Passes `attrs` to `activateOnePhase` and subsequently to `Entity.activate`.
    # After all phases, `callback` is called.
    activateBoardLocking: (attrs, callback, timeout=5000) ->
      eByP = @entitiesByPhase()
      t = -0.5
      f = =>
        if t > -1
          attrsCopy = Object.create attrs
          multilock = new MultiLock f, timeout
          attrsCopy.lock = (args...) -> multilock.getLock args...
          attrsCopy.timeout = timeout
          unlock = attrsCopy.lock "Board"
          t = @activateOnePhase attrsCopy, t, eByP
          unlock()
        else
          if callback
            callback()
      f()

  module.exports = Board
