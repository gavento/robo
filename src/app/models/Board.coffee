define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  MultiLock = require 'cs!app/lib/MultiLock'
  EffectFactory = require 'cs!app/models/effects/EffectFactory'

  # Load all Entity subtypes for loading
  Entity = require 'cs!app/models/Entity'
  require 'cs!app/models/EntityRobot'
  EO = require 'cs!app/models/EntityOthers'
  Wall = EO.Wall


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
    # * `opts` Object containing all options for board 
    #   activation. It is passed to  `Board.activateOnePhase` and subsequently
    #   to `Entity.activate`.
    # * `callback` Callback that is called after all phases have finished.
    activateBoard: (opts, callback) ->
      entitiesByPhase = @entitiesByPhase()
      phases = (Number(k) for k in _.keys(entitiesByPhase))
      phases.sort()
      activateOnePhase = (phase, cb) =>
        @activateOnePhase(entitiesByPhase[phase], opts, cb)
      async.forEachSeries(phases, activateOnePhase, callback)


    # ### Board.activateOnePhase ###
    #
    # Activate given entities.  
    # After that activate entities with immediate effect on all occupied tiles.
    # * `entities` List of entities that will be activated in parallel. 
    # * `opts` Object containing all options for the tile activation.
    # * `callback` Callback that is called when the phase is finished.
    activateOnePhase: (entities, opts, callback) ->
      activateEntitiesAndHooks = (cb) =>
        @activateEntitiesAndHooks(entities, opts, cb)
      activateOccupiedTiles = (cb) =>
        @activateOccupiedTiles(opts, cb)
      async.series([activateEntitiesAndHooks, activateOccupiedTiles], callback)


    # ### Board.activateOccupiedTiles ###
    #
    # Activate tiles that are occupied by a movable entity.  
    # Only some entities are activated when occupied (hole, water, etc.). 
    # This is called after each phase.
    #
    # * `opts` Object containing all options for the tile activation. 
    #   It is passed to  `Board.activateOnEnter` and subsequently
    #   to `Entity.activate`.
    # * `callback` Callback that is called after all occupied tiles have been
    #   activated.
    activateOccupiedTiles: (opts, callback) ->
      activateTileWithEntity = (entity, cb) =>
        optsCopy = Object.create opts
        optsCopy.x = entity.x
        optsCopy.y = entity.y
        @activateImmediateEffects(optsCopy, cb)
      movableEntities = @getMovableEntities()
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
    # * `opts` Object containing all options for the tile activation. Must
    #   contain attributes `x` and `y` (coordinates of activated tile).
    # * `callback` Callback that is called after all entitnies effect on given 
    #   that have an immediate effect have been activated.
    activateImmediateEffects: (opts, callback) ->
      throw "opts.x and opts.y required" unless opts? and opts.x? and opts.y?
      entities = (e for e in @tile(opts.x, opts.y) when e.hasImmediateEffect())
      @activateEntitiesAndHooks(entities, opts, callback)


    # ### Board.activateEntitiesAndHooks ###
    #
    # Activate given entities and perform hooks.
    #
    # * `entities` List of entities that will be activated in parallel.
    # * `opts` Object containing all options for the tile activation.
    # * `callback` Callback that is called when all entities have been activated
    #   and all hooks finished.
    activateEntitiesAndHooks: (entities, opts, callback) ->
      optsCopy = Object.create opts
      optsCopy.afterHooks = []
      optsCopy.effects = []
      activateEntities = (cb) =>
        async.forEach(entities, activateEntity, cb)
      activateEntity = (entity, cb) =>
        entity.activate(optsCopy, cb)
      performHooks = (cb) =>
        if optsCopy.effects.length > 0
          EffectFactory.handleAllEffects(optsCopy.effects, opts, cb)
        else
          async.parallel(optsCopy.afterHooks, cb)
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
      e.bind "entity:move entity:place", @moveEntity
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
      entities = []
      if @inside(x, y)
        if @tiles_[x]? and @tiles_[x][y]?
          entities = @tiles_[x][y]
      else
        entities.push(@hole_)
        for e in @entities_
          if e.x == x && e.y == y
            entities.push(e)
      entities = (e for e in entities when e.isPlaced())
      return entities

    getEntitiesAt: (x, y) ->
      entities = @tile(x, y)

    getMovableEntitiesAt: (x, y) ->
      entities = (e for e in @getEntitiesAt(x, y) when e.isMovable())
   
    getPushableEntitiesAt: (x, y) ->
      entities = (e for e in @getEntitiesAt(x, y) when e.isPushable())

    getTurnableEntitiesAt: (x, y) ->
      entities = (e for e in @getEntitiesAt(x, y) when e.isTurnable())
     
    getRobotEntitiesAt: (x, y) ->
      entities = (e for e in @getEntitiesAt(x, y) when e.isRobot())
    
    getEntitiesOfTypeAt: (x, y, type) ->
      entities = (e for e in @getEntitiesAt(x, y) when e instanceof type)
    
    getMovableEntities: ->
      entities = (e for e in @entities_ when e.isMovable())

    getPushableEntities: ->
      entities = (e for e in @entities_ when e.isPushable())

    # Returns true if an entity can move from position 'x', 'y'
    # in direction 'direction'.
    isPassable: (x, y, direction) ->
      walls = @getEntitiesOfTypeAt(x, y, Wall)
      walls = (w for w in walls when w.dir().equals(direction))
      return walls.length == 0

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

