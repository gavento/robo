define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  Direction = require "cs!app/lib/Direction"
  
  class RespawnPosition extends SimpleModel
    @configure {name: 'RespawnPosition'}, 'x', 'y', 'dir', 'confirmed'
    @typedProperty 'dir', Direction, 'dir_'
    
    constructor: ->
      super
      throw "@x and @y required" unless @x? and @y?
      throw "@dir required" unless @dir?
      @confirmed ?= false

    confirmDirection: (direction) ->
      @dir_ = new Direction(direction)
      @confirmed = true
  
    isConfirmed: ->
      return @confirmed

    unconfirm: ->
      @confirmed = false

  module.exports = RespawnPosition
