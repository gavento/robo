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
      if @selected
        #console.log "Playing ", @, " on ", robot, " with ", opts
        commands = (@get 'commands').slice()

        # If this function returns true than there is at least one
        # more command to be played and the robot is able to play it.
        canPlayNextCommand = () =>
          return commands.length > 0 and robot.isPlaced()

        # Play current command of the card.
        playNextCommand = (cb) =>
          async.series([playNextCommandMovement, playNextCommandTile], cb)

        # This function handles the movement.
        playNextCommandMovement = (cb) =>
          command = commands.shift()
          optsC = Object.create opts
          optsC.mover = @
          switch command
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
        playNextCommandTile = (cb) =>
          optsC = Object.create opts
          optsC.x = robot.x
          optsC.y = robot.y
          robot.board.activateImmediateEffects(optsC, cb)
        
        # Play all commands of the card one by one.
        async.whilst(canPlayNextCommand, playNextCommand, callback)

      else
        console.log "Skipping ", @, " on ", robot
        callback()
    
    select: ->
      @selected = not @selected

  module.exports = Card
