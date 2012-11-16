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
    isPlaced: -> true
    isActivatedOnEnter: -> false

    # Move the entity to the desired location.
    # Also triggers an animation if opts.lock given.
    move: (opts) ->
      throw "opts.x and opts.y required" unless opts? and opts.x? and opts.y?
      optsC = Object.create opts
      optsC.entity = @
      optsC.oldX = @x
      optsC.oldY = @y
      @x = optsC.x
      @y = optsC.y
      @trigger "move", optsC
      # @trigger "update"

    # Rotate the entity right, with animation if opts.lock given.
    # Makes sense only for Entities with @dir.
    rotate: (opts) ->
      throw "opts.dir required" unless opts? and opts.dir?
      optsC = Object.create opts
      optsC.entity = @
      optsC.oldDir = (@get "dir").copy()
      (@get "dir").turnRight optsC.dir
      @trigger "rotate", optsC
      # @trigger "update"

    destroy: ->
      super

    # Activate the Entity in a board activation phase. The phase is
    # in opts.phase.
    activate: (opts) ->
      #console.log "activated ", @, " with opts ", opts
      opts ?= {}
      optsC = Object.create opts
      optsC.entity = @
      @trigger "activate", optsC


  module.exports = Entity
