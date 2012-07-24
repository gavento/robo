define (require, exports, module) ->

  entities = require 'cs!app/models/entities'

  class Tile extends Spine.Model
    @configure 'Tile', 'entities'

    constructor: ->
      @_entities = []
      super

    addEntity: (e) ->
      throw "invalid parameter type" unless e instanceof entities.Entity
      @_entities.push(e)
      e.placed @

    entities: (val) ->
      if not val
        return @_entities
      for e in @_entities
        e.destroy()
      @_entities = []
      for e in val
        @addEntity e



  module.exports = Tile
