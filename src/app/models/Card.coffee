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

    playOnRobot: (robot, opts) ->
      opts ?= {}
      console.log "Playing ", @, " on ", robot, " with ", opts
      for c in @get 'commands'
        oc = Object.create opts
        oc.mover = @
        switch c
          when "R"
            oc.dir = 1
            robot.turn oc
          when "L"
            oc.dir = -1
            robot.turn oc
          when "U"
            oc.dir = 2
            robot.turn oc
          when "S"
            robot.step oc
          when "J" then # TODO
          when "B" then # TODO
          else throw "unknown command"


  module.exports = Card
