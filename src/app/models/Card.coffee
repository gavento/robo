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
      @selected = true
      super

    text: ->
      return @get('commands').join(" ")

    playOnRobot: (robot, opts, callback) ->
      opts ?= {}
      if @selected
        #console.log "Playing ", @, " on ", robot, " with ", opts
        cmds = (@get 'commands').slice()

        # This function handles the movement.
        f1 = (cb) =>
          cmd = cmds.shift()
          optsC = Object.create opts
          optsC.mover = @
          optsC.callback = callback
          switch cmd
            when "R"
              optsC.dir = 1
              robot.turn(optsC, cb)
            when "L"
              optsC.dir = -1
              robot.turn(optsC, cb)
            when "U"
              optsC.dir = 2
              robot.turn(optsC, cb)
            when "S"
              robot.step(optsC, cb)
            else
              cb(null)

        # This function handles the activation of the tile the robot
        # just entered.
        f2 = (cb) =>
          optsC = Object.create opts
          optsC.x = robot.x
          optsC.y = robot.y
          robot.board.activateOnEnter(optsC, cb)

        # play card
        async.whilst(
          => return cmds.length > 0  and robot.isPlaced(),
          (cb) => async.series([f1, f2], cb),
          => callback(null))
      else
        console.log "Skipping ", @, " on ", robot
        callback(null)
    
    select: ->
      @selected = not @selected

  module.exports = Card
