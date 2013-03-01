define (require, exports, module) ->

  EntityView = require 'cs!app/controllers/EntityView'
  Entity = require 'cs!app/models/Entity'
  Card = require 'cs!app/models/Card'


  class RobotView extends EntityView
    @registerTypeName 'Robot'

    attributes: class: 'EntityView RobotView'
    animFrames: 9
    constructor: ->
      super
      @entity.bind('robot:fall', @onRobotFall)
      @bind 'release', (=> @entity.unbind @onRobotFall)
      @entity.bind('robot:place', @onRobotPlace)
      @bind "release", (=> @entity.unbind @onRobotPlace)
      @entity.bind('robot:respawn:confirmed', @onRobotRespawnConfirmed)
      @bind 'release', (=> @entity.unbind @onRobotRespawnConfirmed)

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"

    onRobotFall: (opts, lock) =>
      if @passive
        return
      unlock = lock.getLock('EntityRobotView.onRobotFall')
      duration = 600
      rotate = (cb) =>
        optsC = Object.create opts
        optsC.dir = 8 # rotate the robot around twice
        optsC.duration = duration
        @animateEntity(optsC, cb)
      hide = (cb) =>
        @el.fadeOut(duration, cb)
      move = (cb) =>
        @render()
        cb()
      show = (cb) =>
        @el.fadeTo(400, 0.4, cb)
      fall = (cb) =>
        async.parallel([rotate, hide], cb)
      async.series([
          fall
          move
          show
        ],
        unlock)

    onRobotPlace: (opts, lock) =>
      if @passive
        return
      unlock = lock.getLock('EntityRobotView.onRobotPlace')
      @el.fadeTo(400, 1.0, unlock)

    onRobotRespawnConfirmed: (opts) =>
      @render()

  module.exports = RobotView
