define (require, exports, module) ->

  SimpleModel = require 'cs!app/lib/SimpleModel'
  Card = require 'cs!app/models/Card'

  class HeldCards extends SimpleModel
    @configure {name: 'HeldCards'}, 'fixed', 'drawn', 'limit'
    @typedPropertyArray 'fixed', Card, 'fixed_'
    @typedPropertyArray 'drawn', Card, 'drawn_'

    constructor: (atts) ->
      console.log "1", atts, @
      super
      console.log "2", @
      @limit ?= 8
      @fixed_ ?= [] # cards that are never discarded
      @drawn_ ?= [] # cards that will be discarded
      @allCards = []
      @allCards.push @fixed_...
      @allCards.push @drawn_...
      @nextCardIndex = 0
      console.log "3", @

    nextCard: ->
      if @nextCardIndex >= @allCards.length
        return null
      else
        return @allCards[@nextCardIndex]

    playNextCard: (robot, opts, callback) ->
      card = @nextCard()
      if card
        @nextCardIndex++
        card.playOnRobot robot, opts, callback
      else
        callback()

    drawCards: (deck, opts, callback) ->
      count = @howManyCardsToDraw()
      cards = deck.drawCards count
      @addCardsToHand cards
      @triggerLockedEvent 'robot:cards:drawn', opts, callback

    discardDrawnCards: (deck, opts, callback) ->
      @nextCardIndex = 0
      @confirmed = false
      cards = @drawn_[..]
      @removeCardFromHand cards
      deck.discardCards cards
      @triggerLockedEvent 'robot:cards:discarded', opts, callback

    discardUnplannedCards: (deck, opts, callback) ->
      count = @howManyCardsToDiscard()
      from = @allCards.length - count
      cards = if from > 0 then @allCards[from..] else []
      @removeCardFromHand cards
      deck.discardCards cards
      @triggerLockedEvent 'robot:cards:confirmed', opts, callback

    getAllCards: ->
      return @allCards
    
    reorderCards: (order) ->
      # TODO: update cards from UI
      @triggerLockedEvent 'robot:cards:reordered', {}, =>

    confirmOrder: ->
      @confirmed = true
    
    isOrderConfirmed: ->
      return @confirmed

    increaseLimit: ->
      @limit++

    decreaseLimit: ->
      @limit--

    howManyCardsToDiscard: ->
      count = @allCards.length - 4
      return if count >= 0 then count else 0

    howManyCardsToDraw: ->
      max = @limit
      held = @fixed_.length + @drawn_.length
      count = max - held
      return if count >= 0 then count else 0

    addCardsToHand: (cards) ->
      @drawn_.push cards...
      @allCards.push cards...

    removeCardFromHand: (cards) ->
      @drawn_ = _.difference @drawn_, cards
      @fixed_ = _.difference @fixed_, cards
      @allCards = _.difference @allCards, cards
      

  module.exports = HeldCards


