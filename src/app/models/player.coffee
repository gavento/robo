define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/simple-model'
  Card = require 'cs!app/models/card'


  class Player extends SimpleModel
    @configure {name: 'Player'} , 'name', 'robotIds', 'cards'
    # `robotIds` is JSON-stored as an ID list
    @typedPropertyArray 'cards', Card, 'cards_'

    constructor: ->
      @robotIds ?= []
      @cards_ ?= []
      super
      throw "Player.name required" unless @name?

    robots: ->
      throw "Player.game required to get robots" unless @game?
      board = @game.get('board')
      return (board.entityById(id) for id in @get('robotIds'))

    addRobot: (robot) ->
      @robotIds.push(robot.get('id'))


  module.exports = Player
