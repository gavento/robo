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
      (v) -> Spine.isArray v,
      (v) -> (c for c in v.split(" ") when c),
      '@commands_')

    constructor: ->
      @commands_ ?= []
      super

    text: ->
      return @get('commands').join(" ")

    playOnRobot: (robot) ->
      console.log "Playing ", @, " on ", robot 
      for c in @get 'commands'
        switch c
          when "R" then robot.turn dir:1, mover:@
          when "L" then robot.turn dir:(-1), mover:@
          when "U" then robot.turn dir:2, mover:@
          when "S" then robot.step mover:@
          when "J" then # TODO
          when "B" then # TODO
          else throw "unknown command"


  module.exports = Card
