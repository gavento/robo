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


    # ### Board.activateBoard ###
    #
    # Activate the board synchronously.  
    # All phases of the board are activated one after another. Tiles
    # within one phase are activated simultaneously.
    #
    # * `attrs` Object containing all options for board 
    #   activation. It is passed to  `Board.activateOnePhase` and subsequently
    #   to `Entity.activate`.
    # * `callback` Callback that is called after all phases have finished.
    activateBoard: (attrs, callback) ->
      entitiesByPhase = @entitiesByPhase()
      phases = (Number(k) for k in _.keys(entitiesByPhase))
      phases.sort()
      activateOnePhase = (phase, cb) =>
        @activateOnePhase(entitiesByPhase[phase], attrs, cb)
      async.forEachSeries(phases, activateOnePhase, callback)


    # ### Board.activateOnePhase ###
    #
    # Activate given entities.  
    # After that activate entities with immediate effect on all occupied tiles.
    # * `entities` List of entities that will be activated in parallel. 
    # * `attrs` Object containing all options for the tile activation.
    # * `callback` Callback that is called when the phase is finished.
    activateOnePhase: (entities, attrs, callback) ->
      activateEntitiesAndHooks = (cb) =>
        @activateEntitiesAndHooks(entities, attrs, cb)
      activateOccupiedTiles = (cb) =>
        @activateOccupiedTiles(attrs, cb)
      async.series([activateEntitiesAndHooks, activateOccupiedTiles], callback)


    # ### Board.activateOccupiedTiles ###
    #
    # Activate tiles that are occupied by a movable entity.  
    # Only some entities are activated when occupied (hole, water, etc.). 
    # This is called after each phase.
    #
    # * `attrs` Object containing all options for the tile activation. 
    #   It is passed to  `Board.activateOnEnter` and subsequently
    #   to `Entity.activate`.
    # * `callback` Callback that is called after all occupied tiles have been
    #   activated.
    activateOccupiedTiles: (attrs, callback) ->
      activateTileWithEntity = (entity, cb) =>
        attrsCopy = Object.create attrs
        attrsCopy.x = entity.x
        attrsCopy.y = entity.y
        @activateImmediateEffects(attrsCopy, cb)
      movableEntities = (e for e in @entities_ when e.isMovable())
      async.forEach(movableEntities, activateTileWithEntity, callback)


    # ### Board.activateImmediateEffects ###
    #
    # Activate immediate effects of a tile.  
    #
    # Some entities (eg. Hole or Water) have immediate effect on robot
    # standing on them. This funcition activates those effects. It should
    # be called on tiles entered by a movable entity and on tiles occupied by
    # by a movable entity after each board phase. 
    #
    # * `attrs` Object containing all options for the tile activation. Must
    #   contain attributes `x` and `y` (coordinates of activated tile).
    # * `callback` Callback that is called after all entitnies effect on given 
    #   that have an immediate effect have been activated.
    activateImmediateEffects: (attrs, callback) ->
      throw "attrs.x and attrs.y required" unless attrs? and attrs.x? and attrs.y?
      entities = (e for e in @tile(attrs.x, attrs.y) when e.hasImmediateEffect())
      @activateEntitiesAndHooks(entities, attrs, callback)


    # ### Board.activateEntitiesAndHooks ###
    #
    # Activate given entities and perform hooks.
    #
    # * `entities` List of entities that will be activated in parallel.
    # * `attrs` Object containing all options for the tile activation.
    # * `callback` Callback that is called when all entities have been activated
    #   and all hooks finished.
    activateEntitiesAndHooks: (entities, attrs, callback) ->
      attrsCopy = Object.create attrs
      attrsCopy.afterHooks = []
      activateEntities = (cb) =>
        async.forEach(entities, activateEntity, cb)
      activateEntity = (entity, cb) =>
        entity.activate(attrsCopy, cb)
      performHooks = (cb) =>
        async.parallel(attrsCopy.afterHooks, cb)
      async.parallel([activateEntities, performHooks], callback)


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


    # Return list of entities at `[x][y]`. If the coordinates are outside
    # the board than `hole` entity is always part of the returned list.
    tile: (x, y) ->
      if @inside(x, y)
        if @tiles_[x]? and @tiles_[x][y]?
          return @tiles_[x][y]
        else
          return []
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


      

  module.exports = Board
