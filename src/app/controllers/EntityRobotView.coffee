define (require, exports, module) ->

  EntityView = require "cs!app/controllers/EntityView"
  Entity = require "cs!app/models/Entity"
  Card = require "cs!app/models/Card"


  class RobotView extends EntityView
    @registerTypeName "Robot"

    attributes: class: 'EntityView RobotView'
    animFrames: 9
    constructor: ->
      super
      @entity.bind("robot:fall", @onRobotFall)
      @bind "release", (=> @entity.unbind @onRobotFall)
      @entity.bind("robot:place", @onRobotPlace)
      @bind "release", (=> @entity.unbind @onRobotPlace)

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"

    onRobotFall: (opts, lock) =>
      if @passive
        return
      unlock = lock.getLock("EntityRobotView.onRobotFall")
      # First animate the entity and then hide it.
      async.series(
        [ ((cb) => @animateEntity(opts, cb)),
          ((cb) =>
            @el.hide()
            cb(null))],
        unlock)

    onRobotPlace: (opts, lock) =>
      if @passive
        return
      @render()
      @el.show()

  module.exports = RobotView
