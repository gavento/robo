define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/simple-controller'
  ST = require "cs!app/lib/subclass-types"

  class CardView extends SimpleController
    ST.baseClass @
    # typical create call:
    #   CardView.createSubType card:c, type:c.type
    tag: 'li'
    attributes: class: 'CardView'
    constructor: ->
      super
      throw "@card required" unless @card
      # Following style cannot be specified in the style sheet because
      # the sortable functionality from jquery ui needs to read this
      # property before this element is connected to DOM. If it fails
      # to locate this property, the sorting does not work very well.
      # More specifically the placeholder updates only on vertical
      # movement not on horizontal and since the dragging is restricted
      # to parent element it is very common that the dragged card is
      # sliding along the upper or lower border with no vertical movement.
      # Without this line it only works in Firefox. For detailed info see
      # https://bugs.webkit.org/show_bug.cgi?id=14563 and
      # http://bugs.jquery.com/ticket/9338
      @el.css "float": "left"
      @el.html "<div class='CardViewPriority'>#{ @card.get 'priority' }</div><div class='CardViewText'>#{ @card.get 'text' }</div>"

  class SimpleCardView extends CardView
    @registerTypeName "S"
    attributes: class: 'CardView SimpleCardView PasiveCard'
    constructor: ->
      super
      @bindToModel @card, "card:play:start", @onCardPlayStart
      @bindToModel @card, "card:play:over", @onCardPlayOver
      @el.attr "order", @card.id

    onCardPlayStart: =>
      @el.switchClass 'PasiveCard', 'ActiveCard', 400
    
    onCardPlayOver: =>
      @el.switchClass 'ActiveCard', 'PasiveCard', 400



  module.exports = CardView
