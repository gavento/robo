define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/SimpleController'
  ST = require "cs!app/lib/SubClassTypes"

  class CardView extends SimpleController
    ST.baseClass @
    # typical create call:
    #   CardView.createSubType card:c, type:c.type
    tag: 'div'
    attributes: class: 'CardView'
    constructor: ->
      super
      throw "@card required" unless @card
      @el.html "<div class='CardViewPriority'>#{ @card.get 'priority' }</div><div class='CardViewText'>#{ @card.get 'text' }</div>"

  class SimpleCardView extends CardView
    @registerTypeName "S"
    attributes: class: 'CardView SimpleCardView PasiveCard'
    constructor: ->
      super
      @bindToModel @card, "card:play:start", @onCardPlayStart
      @bindToModel @card, "card:play:over", @onCardPlayOver

    onCardPlayStart: =>
      @el.switchClass 'PasiveCard', 'ActiveCard', 400
    
    onCardPlayOver: =>
      @el.switchClass 'ActiveCard', 'PasiveCard', 400



  module.exports = CardView
