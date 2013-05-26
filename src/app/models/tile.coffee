define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/simple-model"
  Entity = require 'cs!app/models/entity'

  class Tile extends SimpleModel
    @configure {name: 'Tile'}, 'entities'
    @typedPropertyArray 'entities', Entity, 'entities_'

    constructor: ->
      super
      @entities_ ?= []

    # just container method - does not update the Entity
    placeEntity: (e) ->
      throw "invalid parameter type" unless e instanceof Entity
      @entities_.push(e)
      @trigger 'placeEntity', e

    # just container method - does not update the Entity
    liftEntity: (e) ->
      throw "invalid parameter type" unless e instanceof Entity
      @entities_ = (i for i in @entities_ when i != e)
      @trigger 'liftEntity', e


    destroy: ->
      es = (i for i in @get('entities'))
      for e in es
        e.lift()
        e.destroy()
      super

  module.exports = Tile
