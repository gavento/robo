define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/simple-model"

  class Entity extends SimpleModel
    @configure {name: 'Entity', baseClass: true, genId: true}, 'x', 'y', 'type', 'id'

    constructor: ->
      super
      throw "@x and @y required" unless @x? and @y?
      throw "@type required" unless @type?

    getPhases: -> []
    isMovable: -> false
    isTurnable: -> false
    isPushable: -> false
    canPush: -> @isPushable() # only pushable entities can push
    isRobot: -> false
    isPlaced: -> true
    hasImmediateEffect: -> false

    # Move the entity to the desired location.
    # Also triggers an animation if opts.lock given.
    move: (opts, callback) ->
      throw "opts.x and opts.y required" unless opts? and opts.x? and opts.y?
      optsC = Object.create opts
      optsC.entity = @
      optsC.oldX = @x
      optsC.oldY = @y
      @x = optsC.x
      @y = optsC.y
      @triggerLockedEvent("entity:move", optsC, callback)

    # Rotate the entity right, with animation if opts.lock given.
    # Makes sense only for Entities with @dir.
    rotate: (opts, callback) ->
      throw "opts.dir required" unless opts? and opts.dir?
      @dir().turn(opts.dir)
      @triggerLockedEvent("entity:rotate", opts, callback)

    destroy: ->
      super

    # Get effects that will be caused by activation of this entity.
    # These effects will be performed in parallel with activation.
    effects: ->
      return []

    # Activate the Entity in a board activation phase. The phase is
    # in opts.phase.
    activate: (opts, callback) ->
      #console.log "activated ", @, " with opts ", opts
      opts ?= {}
      optsC = Object.create opts
      optsC.entity = @
      @triggerLockedEvent("entity:activate", optsC, callback)

  module.exports = Entity
