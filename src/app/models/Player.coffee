define (require, exports, module) ->

  class Player extends Spine.Model
    @configure 'Player', 'name'
    constructor: ->
      super
      @robots ?= []

  module.exports = Player
