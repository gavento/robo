define (require, exports, module) ->

  EntityView = require 'cs!app/controllers/EntityView'
  CardView = require 'cs!app/controllers/CardView'
  Direction = require 'cs!app/lib/Direction'

  class PlayerRobotController extends Spine.Controller
    constructor: ->
      super
      throw "@robot required" unless @robot?


  class PlayerRobotView extends PlayerRobotController
    tag: 'div'
    attributes: class: 'PlayerRobotView'
    constructor: ->
      super
      @robotView = EntityView.createSubType
        entity: @robot
        type: @robot.get 'type'
        tileW: @tileW
        tileH: @tileH
        passive: true
      @bind "release", (=> @robotView.release())
      @descriptionView = new RobotDescriptionView robot: @robot
      @bind "release", (=> @descriptionView.release())
      @orientationChooser = new RobotRespawnController
        robot: @robot
        tileW: @tileW
        tileH: @tileH
      @bind "release", (=> @orientationChooser.release())
      @cardViews = []
      for card in @robot.get 'cards'
        view = CardView.createSubType
          card: card
          type: card.get 'type'
        @cardViews.push view
        @bind "release", (=> view.release())
      @append @descriptionView
      @append @orientationChooser
      @append @robotView
      for view in @cardViews
        @append view


  class RobotDescriptionView extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @nameView = new RobotNameView( robot: @robot )
      @bind "release", (=> @nameView.release())
      @healthView = new RobotHealthView( robot: @robot )
      @bind "release", (=> @healthView.release())
      @append "Robot "
      @append @nameView
      @append " with "
      @append @healthView
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
      @robot.bind 'robot:damage', @onRobotDamage
      @bind 'release', (=> @robot.unbind @onRobotDamage)
      @render()
    
    render: => @html("#{ @robot.health }")
    onRobotDamage: => @render()


  class RobotRespawnController extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      if @robot.isPlaced() then @el.hide()
      @robot.bind "robot:fall", @onRobotFall
      @bind "release", (=> @robot.unbind @onRobotFall)
      @robot.bind "robot:place", @onRobotPlace
      @bind "release", (=> @robot.unbind @onRobotPlace)
      @robot.bind "robot:respawn:confirmed", @onRobotRespawnConfirmed
      @bind "release", (=> @robot.unbind @onRobotRespawnConfirmed)
      @description = new RobotRespawnCoordinatesView robot: @robot
      @bind("release", (=> @description.release()))
      @directionButtons = []
      for dir in ["W", "N", "E", "S"]
        button = new RobotRespawnDirectionButton
          robot: @robot
          tileW: @tileW
          tileH: @tileH
          direction: dir
        @directionButtons.push button
        @bind "release", (=> button.release())
      @append @description
      for button in @directionButtons
        @append button

    onRobotFall: => @el.slideDown(400)
    onRobotPlace: => @el.slideUp(400)
    onRobotRespawnConfirmed: => @onRobotPlace()
 

  class RobotRespawnCoordinatesView extends PlayerRobotController
    tag: 'div'
    constructor: ->
      super
      @robot.bind "robot:respawn:confirmed", @onRobotRespawnConfirmed
      @bind "release", (=> @robot.unbind @onRobotRespawnConfirmed)
      @render()

    render: =>
      respawn = @robot.respawnPosition()
      x = respawn.x
      y = respawn.y
      dir = respawn.dir().getName()
      @html "Choose respawn direction:"
      #@html "Respawn at [x: #{x}, y: #{y}, dir: #{dir}]"
    
    onRobotRespawnConfirmed: => @render()


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
