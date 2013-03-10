define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/SimpleModel'
  Card = require 'cs!app/models/Card'
  Robot = require 'cs!app/models/EntityRobot'

  class Deck extends SimpleModel
    @configure {name: 'Deck'}
    @typedPropertyArray 'cards', Card, 'cards_'

    constructor: ->
      super

    shuffle: ->
      @cards_ = _.shuffle(@cards_)

    drawCards: (count) ->
      index = @cards_.length - count
      if index < 0
        drawnCards = []
      else
        drawnCards = @cards_.splice index, count
      return drawnCards

    discardCards: (cards) ->
      @cards_.push cards...

  module.exports = Deck

