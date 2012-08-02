define (require, exports, module) ->

  ST = require "cs!app/lib/SubClassTypes"

  class CardView extends Spine.Controller
    ST.baseClass @
    # typical create call:
    #   CardView.createSubType card:c, type:c.type

    tag: 'div'

    attributes:
      class: 'CardView'

    constructor: ->
      super
      throw "@card required" unless @card

      @entity.bind("update", @render)
      @bind "release", (=> @entity.unbind @render)
      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    render: =>
      @el.html "<span class='CardViewPriority'>#{ @card.get 'priority' }</span><span class='CardViewText'>#{ @card.get 'text' }</span>"
  
  
  class SimpleCardView extends CardView
    @registerTypeName "S"

    attributes:
      class: 'CardView SimpleCardView'

  module.exports = CardView
