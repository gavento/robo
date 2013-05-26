define (require, exports, module) ->

  EntityView = require 'cs!app/controllers/entity-view'
  Entity = require 'cs!app/models/entity'
  Card = require 'cs!app/models/card'


  class RobotView extends EntityView
    @registerTypeName 'Robot'
    attributes: class: 'EntityView RobotView'
    animFrames: 9
    constructor: ->
      super
      @bindToModel @entity, 'robot:fall', @onRobotFall
      @bindToModel @entity, 'robot:place', @onRobotPlace
      @bindToModel @entity, 'robot:respawn:confirmed', @onRobotRespawnConfirmed

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/robots/#{@entity.image}')"

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
