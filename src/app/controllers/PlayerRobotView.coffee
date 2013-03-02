define (require, exports, module) ->

  SimpleController = require 'cs!app/lib/SimpleController'
  EntityView = require 'cs!app/controllers/EntityView'
  CardView = require 'cs!app/controllers/CardView'
  Direction = require 'cs!app/lib/Direction'

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
      @appendController new RobotRespawnController
        robot: @robot
        tileW: @tileW
        tileH: @tileH
      @appendController EntityView.createSubType
        entity: @robot
        type: @robot.get 'type'
        tileW: @tileW
        tileH: @tileH
        passive: true
      for card in @robot.get 'cards'
        view = CardView.createSubType
          card: card
          type: card.get 'type'
        @appendController view


  class RobotDescriptionView extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @append "Robot "
      @appendController new RobotNameView( robot: @robot )
      @append " with "
      @appendController new RobotHealthView( robot: @robot )
      @append " health"


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
 

  class RobotRespawnCoordinatesView extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @html "Choose respawn direction:"


  class RobotRespawnDirectionButton extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @hovering = false
      y = Direction.toNumber(@direction) * @tileH
      @el.css
        'background-image': "url('img/#{@robot.image}')"
        'background-position': "0 #{-y}px"
        'left': 0
        'top': y
        'width': @tileW
        'height': @tileH
        'display': 'inline-block'
        'opacity': 0.4

    events:
      "click": "click"
      "hover": "hover"

    click: -> @robot.confirmRespawnDirection(@direction)
    hover: ->
      @hovering = not @hovering
      if @hovering
        @el.fadeTo(100, 1.0)
      else
        @el.fadeTo(100, 0.4)


  module.exports = PlayerRobotView
