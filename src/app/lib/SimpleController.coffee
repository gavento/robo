define (require, exports, module) ->

  class SimpleController extends Spine.Controller
    constructor: ->
      super

    bindToModel: (model, event, callback) ->
      model.bind event, callback
      @bind 'release', (=> model.unbind event, callback)

    appendController: (controller) ->
      @bind "release", (=> controller.release())
      @append controller
      return controller

  module.exports = SimpleController

