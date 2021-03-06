define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/simple-model'
  EffectFactory = require 'cs!app/lib/effects/effect-factory'
  async = require 'async'
  _ = require 'underscore'

  class Card extends SimpleModel
    @configure {name: 'Card', baseClass: true, genId: true}, 'type', 'priority'

    constructor: ->
      super
      throw "@priority required" unless @priority?

    text: ->
      return "UNDEF CARD"


  class SimpleCard extends Card
    @configure {name: 'SimpleCard', subClass: true, registerAs: "S"}, 'commands'
    @typedPropertyEx('commands',
      (v) -> _.isArray v,
      (v) -> (c for c in v.split(" ") when c),
      '@commands_')

    constructor: ->
      @commands_ ?= []
      @selected = true
      super

    text: ->
      return @get('commands').join(" ")

    playOnRobot: (robot, opts, callback) ->
      #console.log "Playing ", @, " on ", robot, " with ", opts
      commands = (@get 'commands').slice()

      # If this function returns true than there is at least one
      # more command to be played and the robot is able to play it.
      canPlayNextCommand = () =>
        return commands.length > 0 and robot.isPlaced()

      # Play current command of the card.
      playNextCommand = (cb) =>
        async.series([playNextCommandMovement, playNextCommandTiles], cb)

      # This function handles the movement.
      playNextCommandMovement = (cb) =>
        command = commands.shift()
        effect = null
        switch command
          when "R"
            effect = EffectFactory.createTurnEffectChain(
              robot.board, robot, @, 1)
          when "L"
            effect = EffectFactory.createTurnEffectChain(
              robot.board, robot, @, -1)
          when "U"
            effect = EffectFactory.createTurnEffectChain(
              robot.board, robot, @, 2)
          when "S"
            effect = EffectFactory.createMoveEffectChain(
              robot.board, robot, @, robot.dir())
          when "B"
            effect = EffectFactory.createMoveEffectChain(
              robot.board, robot, @, robot.dir().opposite())
          else
            cb(null)
        EffectFactory.handleAllEffects([effect], opts, cb)
      
      # This function handles the activation of occupied tiles.
      # It is needed for holes to work properly when the active
      # robot pushes another robot into a hole.
      playNextCommandTiles = (cb) =>
        robot.board.activateOccupiedTiles(opts, cb)
      start = (cb) =>
        @triggerLockedEvent "card:play:start", {}, cb
      play = (cb) =>
        async.whilst(canPlayNextCommand, playNextCommand, cb)
      over = (cb) =>
        @triggerLockedEvent "card:play:over", {}, cb

      async.series [start, play, over], callback
    
    select: ->
      @selected = not @selected

  module.exports = Card
