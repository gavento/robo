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
      @entity.bind("move", @move)
      @bind "release", (=> @entity.unbind @move)
      @entity.bind("rotate", @rotate)
      @bind "release", (=> @entity.unbind @rotate)
      @entity.bind("fall", @fall)
      @bind "release", (=> @entity.unbind @fall)
      @entity.bind("place", @place)
      @bind "release", (=> @entity.unbind @place)

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
      duration = do =>
        if not opts.lock?
          return 0
        if opts.duration
          return opts.duration
        if opts.mover?
          if opts.mover instanceof Entity
            moverView = @boardView.entityViews[opts.mover.get 'id']
            return moverView.animationDuration()
          if opts.mover instanceof Card
            return 450 # a random constant for now
          else throw "unknown mover type"
        console.log "No opts.mover and no opts.duration for ", @, " in ", opts
        return 1000 # random constant just to show some move
      if opts.speed?
        return duration * opts.speed
      return duration

    # Animate a rotating Entity. 
    # `opts.lock` is used for board locking, opts is passed to 
    # guessDuration().
    rotate: (opts) =>
      if @passive
        return
      throw "opts.oldDir and opts.dir required" unless opts? and opts.oldDir? and opts.dir?
      #@log "rotate ", @entity, opts

      opts ?= {}
      duration = @guessDuration opts
      if opts.lock?
        unlock = opts.lock @entity.id
      oDir = opts.oldDir.getNumber()

      i = 0
      f = =>
        if opts.dir > 0
          if i >= opts.dir
            CSSSprite(@el, 0, -(oDir + i) * @tileH, 0, 0, 0, 0, true, unlock)
          else
            i += 1
            CSSSprite(@el, 0, -(oDir + i - 1) * @tileH, -@tileW, 0,
              duration / @animFrames / opts.dir, @animFrames, false, f)
        if opts.dir < 0
          if i <= opts.dir
            CSSSprite(@el, 0, -(oDir + i) * @tileH, 0, 0, 0, 0, true, unlock)
          else
            i -= 1
            CSSSprite(@el, -@tileW * (@animFrames - 1), -(oDir + i) * @tileH, @tileW, 0,
              duration / @animFrames / (-opts.dir), @animFrames, false, f)
      f()

    # Animate a moving Entity. 
    # `opts.lock` is used for board locking, opts is passed to 
    # guessDuration().
    move: (opts) =>
      if @passive
        return

      opts ?= {}
      duration = @guessDuration opts
      if opts.lock?
        unlock = opts.lock @entity.id
      @el.animate({left: @boardView.tileW * @entity.x, top: @boardView.tileH * @entity.y},
        duration, 'linear', unlock)

    # Animate a falling Entity. 
    # `opts.lock` is used for board locking, opts is passed to 
    # guessDuration().
    # TODO: for now implemented as rotation
    fall: (opts) =>
      if @passive
        return
      throw "opts.oldDir and opts.dir required" unless opts? and opts.oldDir? and opts.dir?
      @log "fall ", @entity, opts

      opts ?= {}
      duration = @guessDuration opts
      if opts.lock?
        unlock = (=>
          u = opts.lock @entity.id
          u()
          @el.hide()
          )
      oDir = opts.oldDir.getNumber()

      i = 0
      f = =>
        if opts.dir > 0
          if i >= opts.dir
            CSSSprite(@el, 0, -(oDir + i) * @tileH, 0, 0, 0, 0, true, unlock)
          else
            i += 1
            CSSSprite(@el, 0, -(oDir + i - 1) * @tileH, -@tileW, 0,
              duration / @animFrames / opts.dir, @animFrames, false, f)
        if opts.dir < 0
          if i <= opts.dir
            CSSSprite(@el, 0, -(oDir + i) * @tileH, 0, 0, 0, 0, true, unlock)
          else
            i -= 1
            CSSSprite(@el, -@tileW * (@animFrames - 1), -(oDir + i) * @tileH, @tileW, 0,
              duration / @animFrames / (-opts.dir), @animFrames, false, f)
      f()

    # Place an entity back on the board.
    # This is called for robots when they are placed back on the board
    # after they fall into a hole.
    place: (opts) =>
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


  module.exports = EntityView
