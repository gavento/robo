define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/SimpleModel'
  MultiLock = require 'cs!app/lib/MultiLock'

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

    playOnRobot: (robot, opts) ->
      opts ?= {}
      if @selected
        #console.log "Playing ", @, " on ", robot, " with ", opts
        cmds = (@get 'commands').slice()
        if opts.lock?
          unlock = opts.lock("playOnRobot")

        f1 = (callback) =>
          optsC = Object.create opts
          optsC.mover = @
          optsC.callback = callback
          switch cmds.shift()
            when "R"
              optsC.dir = 1
              robot.turn optsC
            when "L"
              optsC.dir = -1
              robot.turn optsC
            when "U"
              optsC.dir = 2
              robot.turn optsC
            when "S"
              robot.step optsC
            else
              callback("unknown command")
          
        f2 = (callback) =>
          optsC = Object.create opts
          optsC.x = robot.x
          optsC.y = robot.y
          optsC.callback = callback
          #robot.board.activateOnEnter(optsC)
          callback(null)

        # play card
        async.until(
          => return cmds.length <= 0 or not robot.isPlaced,
          (callback) => async.waterfall([f1, f2], callback),
          (err) => unlock()
        )
      else
        console.log "Skipping ", @, " on ", robot 
    
    select: ->
      @selected = not @selected

  module.exports = Card
