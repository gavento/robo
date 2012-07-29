define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"

  class Entity extends SimpleModel
    @configure {name: 'Entity', baseClass: true, genId: true}, 'x', 'y', 'type', 'id'

    constructor: ->
      super
      throw "@x and @y required" unless @x? and @y?
      throw "@type required" unless @type?

    getPhases: -> []
    isMovable: -> false
    isRobot: -> false

    move: (opts) ->
      throw "opts.x and opts.y required" unless opts.x? and opts.y?
      opts.entity = @
      opts.oldX = @x
      opts.oldY = @y
      @x = opts.x
      @y = opts.y
      @trigger "move", opts

    destroy: ->
      super

    activate: (opts) ->
      opts ?= {}
      #DEBUG# console.log "activated ", @, " with opts ", opts
      opts.entity = @
      @trigger "activate", opts

  module.exports = Entity
