define (require, exports, module) ->

  ST = require "cs!app/lib/SubClassTypes"
  Entity = require "cs!app/models/Entity"
  Card = require "cs!app/models/Card"
  CSSSprite = require "app/lib/CSSSprite"

  class EntityView extends Spine.Controller
    ST.baseClass @
    # typical create call:
    #   EntityView.createSubType entity:e, type:e.type, boardView:b

    tag: 'div'

    animationDuration: ->
      if @animDuration?
        return @animDuration
      return 0

    attributes:
      class: 'EntityView'

    constructor: ->
      super
      throw "@entity required" unless @entity
      throw "@boardView or @tileW and @tileH required" unless @boardView? or (@tileW? and @tileH?)
      @tileW ?= @boardView.tileW
      @tileH ?= @boardView.tileH
      @passive ?= false

      @entity.bind("update", @render)
      @bind "release", (=> @entity.unbind @render)
      @entity.bind("entity:move", @onEntityMove)
      @bind "release", (=> @entity.unbind @onEntityMove)
      @entity.bind("entity:rotate", @onEntityRotate)
      @bind "release", (=> @entity.unbind @onEntityRotate)
      @entity.bind("entity:fall", @onEntityFall)
      @bind "release", (=> @entity.unbind @onEntityFall)
      @entity.bind("entity:place", @onEntityPlace)
      @bind "release", (=> @entity.unbind @onEntityPlace)

      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    # Set entity position, without animation
    # Params x, y default to entity.x, entity.y
    setPosition: (x, y) ->
      unless x? and y?
        x = @entity.get 'x'
        y = @entity.get 'y'
      if not @passive
        @el.css
          'left': x * @tileW
          'top': y * @tileH

    # Animate a rotating Entity. 
    # `opts.lock` is used for board locking, opts is passed to 
    # guessDuration().
    onEntityRotate: (opts, lock) =>
      if @passive
        return
      throw "opts.oldDir and opts.dir required" unless opts? and opts.oldDir? and opts.dir?
      unlock = lock.getLock("EntityView.onEntityRotate")
      @animateEntity(opts, unlock)

    # Animate a moving Entity. 
    # `opts.lock` is used for board locking, opts is passed to 
    # guessDuration().
    onEntityMove: (opts, lock) =>
      if @passive
        return

      unlock = lock.getLock("EntityView.onEntityMove")
      duration = @guessDuration opts
      @el.animate({left: @boardView.tileW * @entity.x, top: @boardView.tileH * @entity.y},
        duration, 'linear', unlock)

    # Animate a falling Entity. 
    onEntityFall: (opts, lock) =>
      if @passive
        return
      unlock = lock.getLock("EntityView.onEntityFall")
      # First animate the entity and then hide it.
      async.series(
        [ ((cb) => @animateEntity(opts, cb)),
          ((cb) =>
            @el.hide()
            cb(null))],
        unlock)

    # Place an entity back on the board.
    # This is called for robots when they are placed back on the board
    # after they fall into a hole.
    onEntityPlace: (opts, lock) =>
      if @passive
        return
      @log "place ", @entity, opts
      @el.show()
      @render()

    # Draw the entity as a 1x1 CSS-sprite tile.
    render: =>
      #@log "rendering", @entity
      @el.empty()
      @el.css width: @tileW, height: @tileH
      if @entity.dir and not @passive
        @el.css 'background-position': "0px #{-(@entity.get('dir').getNumber() * @tileH)}px"
      else
        @el.css 'background-position': "0px 0px"
      @setPosition()

    # A helper to compute the proper duration of an animation
    # Currently works well for Entity-induced movement (Conveyors, Turner, ...)
    # and for Cards (provisionally).
    #
    # `opts` may contain:
    # * `opts.lock` - no lock always gives duration 0, actual value is ignored.
    # * `opts.duration` - to override anim. duration (speed still applies).
    # * `opts.speed` - sets relative speed (2 = twice as long).
    # * `opts.mover` - entity that caused the move.
    guessDuration: (opts) ->
      opts ?= {}
      duration = do =>
        if opts.duration
          # Entity has fixed animation duration.
          return opts.duration
        if opts.mover?
          # Entity is moved by another entity.
          if opts.mover instanceof Entity
            moverView = @boardView.entityViews[opts.mover.get 'id']
            return moverView.animationDuration()
          if opts.mover instanceof Card
            return 450 # a random constant for now
          else throw "unknown mover type"
        if @animationDuration() > 0
          # Entity has its own animation duration.
          return @animationDuration()
        console.log "EntityView.guessDuration: No opts.mover and no opts.duration for ", @, " in ", opts
        return 1000 # random constant just to show some move
      if opts.speed?
        # Spead up or slow down the animation duration.
        return duration * opts.speed
      return duration

    animateEntity: (opts, callback) =>
      duration = @guessDuration opts
      direction = if opts.dir? then opts.dir else 0
      oldDir = if opts.oldDir? then opts.oldDir.getNumber() else 0

      i = 0
      f = =>
        if direction > 0
          # Entity will be rotated clockwise.
          if i >= direction
            CSSSprite(@el, 0, -(oldDir + i) * @tileH, 0, 0, 0, 0, true, callback)
          else
            i += 1
            CSSSprite(@el, 0, -(oldDir + i - 1) * @tileH, -@tileW, 0,
              duration / @animFrames / direction, @animFrames, false, f)
        if direction < 0
          # Entity will be rotated counter clockwise.
          if i <= direction
            CSSSprite(@el, 0, -(oldDir + i) * @tileH, 0, 0, 0, 0, true, callback)
          else
            i -= 1
            CSSSprite(@el, -@tileW * (@animFrames - 1), -(oldDir + i) * @tileH, @tileW, 0,
              duration / @animFrames / (-direction), @animFrames, false, f)
        if direction == 0
          # Entity will not be rotated, only animated.
          y0 = if @entity.dir? then (@entity.dir().getNumber() * @tileH) else 0
          CSSSprite(@el, 0, -y0, -@tileW, 0, duration / @animFrames, @animFrames, true, callback)
      f()

  module.exports = EntityView
