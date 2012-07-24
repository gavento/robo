define (require, exports, module) ->

  SubclassTypes = require "cs!app/lib/SubclassTypes"

  class Card extends Spine.Model
    @configure 'Card'
    @extend SubclassTypes
    @typemap = {}
    @registerType "C"

  class SimpleCard extends Card
    @configure 'SimpleCard', 'commands'
    @registerType "S"
    constructor: ->
      super
      @commands ?= []
      # conversion from string to array
      if typeof(@commands) == "string"
        @commands = (c for c in @commands.split() when c)
    name: ->
      return @commands.join(" ")

  module.exports =
    Card: Card
    SimpleCard: SimpleCard
