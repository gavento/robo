define (require, exports, module) ->

  EntityView = require "cs!app/controllers/EntityView"
  Entity = require "cs!app/models/Entity"
  Card = require "cs!app/models/Card"


  class RobotView extends EntityView
    @registerTypeName "Robot"

    attributes:
      class: 'EntityView RobotView'
    animFrames: 9

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"


  module.exports = RobotView
