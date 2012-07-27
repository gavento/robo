define (require, exports, module) ->

  entities = require 'cs!app/models/entities'

  class Tile extends Spine.Model
    @configure 'Tile', 'entities'

    constructor: ->
      @_entities = []
      super

    # just container utility - does not update the Entity
    placeEntity: (e) ->
      throw "invalid parameter type" unless e instanceof entities.Entity
      @_entities.push(e)
      @trigger 'placeEntity', e

    # just container utility - does not update the Entity
    liftEntity: (e) ->
      throw "invalid parameter type" unless e instanceof entities.Entity
      @_entities = (i for i in @_entities when i != e)
      @trigger 'liftEntity', e

    entities: (val) ->
      if not val
        return @_entities
      all = @_entities.slice()
      for e in all
        a.lift()
        e.destroy()
      @_entities = []
      for e in val
        e.place @
      @trigger 'update'



  module.exports = Tile
