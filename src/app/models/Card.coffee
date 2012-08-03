define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/SimpleModel'


  class Card extends SimpleModel
    @configure {name: 'Card', baseClass: true}, 'type', 'priority'

    constructor: ->
      super
      throw "@priority required" unless @priority?

    text: ->
      return "UNDEF CARD"


  class SimpleCard extends Card
    @configure {name: 'SimpleCard', subClass: true, registerAs: "S"}, 'commands'
    @typedPropertyEx('commands',
      (v) -> isArray v,
      (v) -> (c for c in v.split() when c),
      '@commands_')

    constructor: ->
      @commands_ ?= []
      super

    text: ->
      return @get('commands').join(" ")


  module.exports = Card
