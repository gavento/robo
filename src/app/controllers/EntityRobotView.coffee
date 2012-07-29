define (require, exports, module) ->

  EntityView = require "cs!app/controllers/EntityView"


  class RobotView extends EntityView
    @registerTypeName "Robot"

    attributes:
      class: 'EntityView RobotView'

    render: =>
      super
      if @entity.image
        @el.css 'background-image': "url('img/#{@entity.image}')"


  module.exports = RobotView
