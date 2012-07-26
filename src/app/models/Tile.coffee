define (require, exports, module) ->

  entities = require 'cs!app/models/entities'

  class Tile extends Spine.Model
    @configure 'Tile', 'entities'

    constructor: ->
      @_entities = []
      super

    # just container utility - does not update the Entity
    addEntity: (e) ->
      throw "invalid parameter type" unless e instanceof entities.Entity
      @_entities.push(e)
      @trigger 'update'

    # just container utility - does not update the Entity
    delEntity: (e) ->
      throw "invalid parameter type" unless e instanceof entities.Entity
      @_entities = (i for i in @_entities when i != e)
      @trigger 'update'

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
