define (require, exports, module) ->

  Entity = require "cs!app/models/Entity"
  Direction = require "cs!app/lib/Direction"
  Card = require "cs!app/models/Card"

  class Robot extends Entity
    @configure {name:'Robot', subClass: true, registerAs: 'Robot'}, 'name', 'dir', 'image', 'cards'
    @typedProperty 'dir', Direction
    @typedPropertyArray 'cards', Card

    constructor: ->
      super

    isMovable: -> true
    isRobot: -> true

  module.exports = Robot
