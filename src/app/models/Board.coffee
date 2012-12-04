define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  MultiLock = require 'cs!app/lib/MultiLock'
  Tile = require 'cs!app/models/Tile'

  # Load all Entity subtypes for loading
  Entity = require 'cs!app/models/Entity'
  EO = require 'cs!app/models/EntityOthers'
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
    @configure {name: 'Board'}, 'width', 'height', 'entities', 'entitiesOutside', 'hole'
    @typedProperty 'hole', EO.Hole


    constructor: (atts) ->
      @width_ = 0
      @height_ = 0
      @entities_ = []
      @tiles_ = {}
      @hole_ ?= new EO.Hole({x: -1, y: -1, type: 'H'})
      @hole_.board = @
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
      e.bind "move place", @moveEntity
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
      if (@inside x, y) and @tiles_[x]? and @tiles_[x][y]?
        return @tiles_[x][y]
      else
        entities = [@hole_]
        for e in @entities_
          if e.x == x && e.y == y
            entities.push(e)
        return entities


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
    activateOnePhase: (attrs, t, eByP, callback) ->
      eByP ?= @entitiesByPhase()
      attrsCopy = Object.create attrs
      attrsCopy.afterHooks = []

      # Activate all entities with the same activation phase simultaneously.
      # Perform hooks that should be executed after the phase is finished.
      # Finally activate all tiles occupied by robots.
      async.series([
        ((cb3) => async.parallel([
          (cb2) => async.forEach(eByP[t], ((e, cb) => e.activate(attrsCopy, cb)), cb2),
          (cb2) => async.parallel(attrsCopy.afterHooks, cb2)],
           cb3)),
        (cb3) => @activateOccupiedTiles(attrsCopy, cb3)],
        callback)
    
    # Activate tile entered by a robot. Only some tiles are activated immediately 
    # when robot enters them (eg. hole).
    activateOnEnter: (attrs, callback) ->
      throw "attrs.x and attrs.y required" unless attrs? and attrs.x? and attrs.y?
      ent = (e for e in @tile(attrs.x, attrs.y) when e.isActivatedOnEnter())
      attrsCopy = Object.create attrs
      attrsCopy.afterHooks = []

      # Activate all entities at given position that should be activated on
      # enter. After that perform hooks.
      async.parallel([
        (cb2) => async.forEach(ent, ((e, cb) => e.activate(attrsCopy, cb)), cb2),
        (cb2) => async.parallel(attrsCopy.afterHooks, cb2)],
        callback)

    # Activate tiles that are occupied by a movable entity. This is called
    # after each phase.
    activateOccupiedTiles: (attrs, callback) ->
      # Get all movable entities and activate tiles these entities
      # are standing on.
      ent = (e for e in @entities_ when e.isMovable())
      async.forEach(ent,
        ((e, cb) =>
          attrsCopy = Object.create attrs
          attrsCopy.x = e.x
          attrsCopy.y = e.y
          @activateOnEnter(attrsCopy, cb)),
        callback)

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
    activateBoardLocking: (attrs, callback) ->
      eByP = @entitiesByPhase()
      phases = (Number(k) for k in _.keys(eByP))
      phases.sort()

      # Activate all phases in sequence. Ie. the next phase will be executed
      # only after the previous phase finished. When all phases are finished
      # callback function will be called.
      async.forEachSeries(
        phases,
        ((phase, cb) =>
          attrsCopy = Object.create attrs
          @activateOnePhase attrsCopy, phase, eByP, cb),
        callback)


  module.exports = Board
