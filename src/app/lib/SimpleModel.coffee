define (require, exports, module) ->

  # Spine = require "spine"
  ST = require "cs!app/lib/SubClassTypes"
  MP = require 'cs!app/lib/ModelProperties'


  class SimpleModel extends Spine.Module
    @include Spine.Events

    @attributes: []
    @records = {}

    @configure: (opts, attributes...) ->
      throw "opts.name is required" unless opts.name?
      @className  = opts.name
      opts.baseClass ?= false
      opts.subClass ?= false
      if opts.baseClass
        ST.baseClass @, {modelClass: true}
      unless opts.subClass
        @records = {}
      if opts.registerAs?
        @registerTypeName opts.registerAs
      @attributes = @attributes.concat attributes
      return @

    @typedProperty: -> MP.typedProperty @, arguments...
    @typedPropertyEx: -> MP.typedPropertyEx @, arguments...
    @typedPropertyArray: -> MP.typedPropertyArray @, arguments...
    @typedPropertyArrayEx: -> MP.typedPropertyArrayEx @, arguments...

    @toString: -> "#{@className}(#{@attributes.join(", ")})"

    @fromJSON: (objects) ->
      return unless objects
      if typeof objects is 'string'
        objects = JSON.parse(objects)
      if isArray(objects)
        (new @(value) for value in objects)
      else
        new @(objects)

    constructor: (atts) ->
      super
      @load atts if atts

    set: (key, value) ->
      if typeof @[key] is 'function'
        @[key](value)
      else
        @[key] = value
      return @

    get: (key) ->
      if typeof @[key] is 'function'
        return @[key]()
      else
        return @[key]

    load: (atts) ->
      for key, value of atts
        @set key, value
      return @

    attributes: ->
      result = {}
      for key in @constructor.attributes when key of this
        result[key] = @get key
      return result

    destroy: (options = {}) ->
      @trigger('destroy', options)
      @unbind()
      return this

    toJSON: ->
      @attributes()

    toString: ->
      "<#{@constructor.className} (#{JSON.stringify(this)})>"

  module.exports = SimpleModel
