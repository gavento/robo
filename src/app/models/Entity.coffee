define (require, exports, module) ->

  SimpleModel = require "cs!app/lib/SimpleModel"
  MultiLock = require "cs!app/lib/MultiLock"

  class Entity extends SimpleModel
    @configure {name: 'Entity', baseClass: true, genId: true}, 'x', 'y', 'type', 'id'

    constructor: ->
      super
      throw "@x and @y required" unless @x? and @y?
      throw "@type required" unless @type?

    getPhases: -> []
    isMovable: -> false
    isRobot: -> false
    isPlaced: -> true
    isActivatedOnEnter: -> false

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
      @triggerLockedEvent("move", optsC, callback)

    # Rotate the entity right, with animation if opts.lock given.
    # Makes sense only for Entities with @dir.
    rotate: (opts, callback) ->
      throw "opts.dir required" unless opts? and opts.dir?
      optsC = Object.create opts
      optsC.entity = @
      optsC.oldDir = (@get "dir").copy()
      (@get "dir").turnRight opts.dir
      @triggerLockedEvent("rotate", optsC, callback)

    destroy: ->
      super

    # Activate the Entity in a board activation phase. The phase is
    # in opts.phase.
    activate: (opts, callback) ->
      #console.log "activated ", @, " with opts ", opts
      opts ?= {}
      optsC = Object.create opts
      optsC.entity = @
      @triggerLockedEvent("activate", optsC, callback)

    # Helper method that creates lock, locks it, triggers an event and unlocks the
    # lock. 
    triggerLockedEvent: (name, opts, callback) ->
      lock = new MultiLock(callback)
      unlock = lock.getLock("Entity.#{name}", 5000)
      @trigger(name, opts, lock)
      unlock()

  module.exports = Entity
