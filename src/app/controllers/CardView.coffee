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

      @card.bind("update", @render)
      @bind "release", (=> @card.unbind @render)
      #DEBUG# @bind "release", (=> @log "releasing ", @)
      @render()

    render: =>
      @el.html "<div class='CardViewPriority'>#{ @card.get 'priority' }</div><div class='CardViewText'>#{ @card.get 'text' }</div>"
  
  
  class SimpleCardView extends CardView
    @registerTypeName "S"

    attributes:
      class: 'CardView SimpleCardView'


  module.exports = CardView
