define (require, exports, module) ->

  class Player extends Spine.Model
    @configure 'Player', 'name'
    # `robots` is stored as a name list
    constructor: ->
      super
      @robots_ ?= []
      @cards ?= []

#    robots: (val) ->
#      if val

  module.exports = Player
