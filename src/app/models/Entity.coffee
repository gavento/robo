define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"

  class Entity extends SimpleModel
    @configure {name: 'Entity', baseClass: true}, 'x', 'y', 'type', 'id'

    constructor: ->
      super
      throw "@x and @y required" unless @x? and @y?
      throw "@type required" unless @type?

    getPhases: -> []
    isMovable: -> false
    isRobot: -> false

    # adds Entity to tile
    place: (tile) ->
      if @tile
        @lift()
      @x = tile.x
      @y = tile.y
      @tile = tile
      @board = tile.board
      tile.placeEntity @
      @trigger 'place'

    # removes entity from @tile
    lift: ->
      throw 'entity not placed' unless @tile
      @trigger 'lift'
      @tile.liftEntity @
      delete @x
      delete @y
      delete @tile

    destroy: ->
      if @tile
        throw 'destroying a placed Entity'
      super

    activate: (phase) ->
      console.log "activated #{@} in phase #{phase}"
      @trigger "activate"

  module.exports = Entity
