define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/simple-controller'
  EntityView = require 'cs!app/controllers/entity-view'
  CardView = require 'cs!app/controllers/card-view'
  Direction = require 'cs!app/lib/direction'

  class PlayerRobotController extends SimpleController
    constructor: ->
      super
      throw "@robot required" unless @robot?


  class PlayerRobotView extends PlayerRobotController
    tag: 'div'
    attributes: class: 'PlayerRobotView'
    constructor: ->
      super
      @appendController new RobotDescriptionView robot: @robot
      @appendController EntityView.createSubType
        entity: @robot
        type: @robot.get 'type'
        tileW: @tileW
        tileH: @tileH
        passive: true
      @appendController new RobotRespawnController
        robot: @robot
        tileW: @tileW
        tileH: @tileH
      @appendController new RobotCardViews cards: @robot.cards()


  class RobotDescriptionView extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @append "Robot "
      @appendController new RobotNameView( robot: @robot )
      @append " with "
      @appendController new RobotHealthView( robot: @robot )
      @append " health"


  class RobotRespawnController extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      if @robot.isPlaced() then @el.hide()
      @bindToModel @robot, "robot:fall", @onRobotFall
      @bindToModel @robot, "robot:place", @onRobotPlace
      @bindToModel @robot, "robot:respawn:confirmed", @onRobotRespawnConfirmed
      @appendController new RobotRespawnCoordinatesView robot: @robot
      for dir in ["W", "N", "E", "S"]
        button = new RobotRespawnDirectionButton
          robot: @robot
          tileW: @tileW
          tileH: @tileH
          direction: dir
        @appendController button

    onRobotFall: => @el.slideDown(400)
    onRobotPlace: => @el.slideUp(400)
    onRobotRespawnConfirmed: => @onRobotPlace()

  
  class RobotCardViews extends SimpleController
    tag: 'ul'
    attributes: class: 'RobotCardViews'
    constructor: ->
      super
      @bindToModel @cards, "robot:cards:drawn", @onRobotCardsDrawn
      @bindToModel @cards, "robot:cards:discarded", @onRobotCardsDiscarded
      @bindToModel @cards, "robot:cards:confirmed", @onRobotCardsConfirmed
      @cardViews = []
      @render()
   
    render: =>
      @releaseCardViews()
      index = 0
      for card in @cards.getAllCards()
        view = CardView.createSubType
          card: card
          type: card.get 'type'
          index: index++
        @cardViews.push view
        @appendController view
        

    initSortable: =>
      @el.sortable
        tolerance: 'pointer'
        containment: 'parent'
        stop: @onSortableStop
      @el.disableSelection()

    destroySortable: =>
      @el.sortable 'destroy'

    releaseCardViews: =>
      for view in @cardViews
        view.release()
      @cardViews = []

    onRobotCardsDrawn: =>
      @render()
      @initSortable()
      @el.addClass 'SortableRobotCardViews', 400

    onRobotCardsDiscarded: =>
      @render()

    onRobotCardsConfirmed: =>
      @el.removeClass 'SortableRobotCardViews', 400
      @destroySortable()
      @render()

    onSortableStop: (event, ui) =>
      order = @el.sortable 'toArray', {attribute: 'order'}
      @cards.reorderCards order
 

  class RobotNameView extends PlayerRobotController
    tag: 'span'
    attributes: class: 'RobotNameView'
    constructor: ->
      super
      @html "\"#{ @robot.name }\""
  
  
  class RobotHealthView extends PlayerRobotController
    tag: 'span'
    constructor: ->
      super
      @bindToModel @robot, 'robot:damage', @onRobotDamage
      @render()
    
    render: => @html("#{ @robot.health }")
    onRobotDamage: => @render()


  class RobotRespawnCoordinatesView extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @html "Choose respawn direction:"


  class RobotRespawnDirectionButton extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      y = Direction.toNumber(@direction) * @tileH
      @el.css
        'background-image': "url('img/robots/#{@robot.image}')"
        'background-position': "0 #{-y}px"
        'left': 0
        'top': y
        'width': @tileW
        'height': @tileH
        'display': 'inline-block'
        'opacity': 0.4
      @el.hover @hoverIn, @hoverOut

    events: "click": "click"
    click: -> @robot.confirmRespawnDirection(@direction)
    hoverIn: => @el.fadeTo(100, 1.0)
    hoverOut: => @el.fadeTo(100, 0.4)

  
  module.exports = PlayerRobotView
