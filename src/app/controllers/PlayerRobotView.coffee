define (require, exports, module) ->

  EntityView = require 'cs!app/controllers/EntityView'
  CardView = require 'cs!app/controllers/CardView'
  MultiLock = require 'cs!app/lib/MultiLock'
  Direction = require 'cs!app/lib/Direction'

  class PlayerRobotController extends Spine.Controller
    constructor: ->
      super
      throw "@robot required" unless @robot?

  class PlayerRobotView extends PlayerRobotController
    tag: 'div'

    attributes:
      class: 'PlayerRobotView'

    constructor: ->
      super
      @robotView = EntityView.createSubType
        entity: @robot
        type: @robot.get 'type'
        tileW: 68
        tileH: 68
        passive: true
      @bind "release", (=> @robotView.release())
      @descriptionView = new RobotDescriptionView( robot: @robot )
      @bind "release", (=> @descriptionView.release())
      @orientationChooser = new RobotRespawnController( robot: @robot )
      @bind "release", (=> @orientationChooser.release())
      @cardViews = []
      for c in @robot.get 'cards'
        cv = CardView.createSubType
          card: c
          type: c.get 'type'
        @cardViews.push cv
        @bind "release", (=> cv.release())
      @render()

    render: =>
      #@el.html("<div class='PlayerRobotViewName'>Robot <b>\"#{ @robot.get 'name' }\"</b> with #{ @robot.get 'health' } health</div>")
      @append(@descriptionView)
      @append(@orientationChooser)
      @append(@robotView)
      for cv in @cardViews
        @append(cv)


  class RobotDescriptionView extends PlayerRobotController
    tag: 'div'
    
    constructor: ->
      super
      @nameView = new RobotNameView( robot: @robot )
      @bind "release", (=> @nameView.release())
      @healthView = new RobotHealthView( robot: @robot )
      @bind "release", (=> @healthView.release())
      @append("Robot ")
      @append(@nameView)
      @append(" with ")
      @append(@healthView)
      @append(" health")


  class RobotNameView extends PlayerRobotController
    tag: 'span'
    
    attributes:
      class: 'RobotNameView'

    constructor: ->
      super
      @render()
    
    render: =>
      name = @robot.name
      @html("\"#{ name }\"")
  
  
  class RobotHealthView extends PlayerRobotController
    tag: 'span'
    
    constructor: ->
      super
      @robot.bind('robot:damage', @onRobotDamage)
      @bind 'release', (=> @robot.unbind @onRobotDamage)
      @render()
    
    render: =>
      health = @robot.health
      @html("#{ health }")
      
    onRobotDamage: =>
      @render()


  class RobotRespawnController extends PlayerRobotController
    tag: 'div'

    constructor: ->
      super
      if @robot.isPlaced() then @el.hide()
      @robot.bind("robot:fall", @onRobotFall)
      @bind "release", (=> @robot.unbind @onRobotFall)
      @robot.bind("robot:place", @onRobotPlace)
      @bind "release", (=> @robot.unbind @onRobotPlace)
      @description = new RobotRespawnCoordinatesView( robot: @robot )
      @bind("release", (=> @description.release()))
      @directionButtons = []
      for dir in Direction.dirs
        dirButton = new RobotRespawnDirectionController( {robot: @robot, direction: dir} )
        @directionButtons.push(dirButton)
        @bind("release", (=> dirButton.release()))
      @append(@description)
      for dirButton in @directionButtons
        @append(dirButton)

    onRobotFall: (opts, lock) =>
      @el.show(500)
    
    onRobotPlace: (opts, lock) =>
      @el.hide(500)
 

  class RobotRespawnCoordinatesView extends PlayerRobotController
    tag: 'span'

    constructor: ->
      super
      @robot.bind("robot:respawn:confirmed", @onRobotRespawnChanged)
      @bind "release", (=> @robot.unbind @onRobotRespawnChanged)
      @render()

    render: =>
      respawn = @robot.respawnPosition()
      x = respawn.x
      y = respawn.y
      dir = respawn.dir().getName()
      @html("Respawn at [x: #{x}, y: #{y}, dir: #{dir}]")
    
    onRobotRespawnConfirmed: =>
      @render()


  class RobotRespawnDirectionController extends PlayerRobotController
    tag: 'button'

    events:
      "click": "click"

    constructor: ->
      super
      @robot.bind("robot:respawn:changed", @onRobotRespawnChanged)
      @bind "release", (=> @robot.unbind @onRobotRespawnChanged)
      @html("#{@direction}")
    
    click: ->
      @robot.confirmRespawnDirection(@direction)

    onRobotRespawnChanged: ->
      #@render()

      #    render: =>
      #      if @robot.isPlaced() then @el.hide()
      #      @el.html("")
      #      description = @$("<span>Respawn at [#{@robot.respawnX}, #{@robot.respawnY}, #{@robot.respawnDir.getName()}]</span>")
      #      @append(description)
      #      @renderDirectionButton('N', 'N')
      #      @renderDirectionButton('E', 'E')
      #      @renderDirectionButton('S', 'S')
      #      @renderDirectionButton('W', 'W')
      #
      #    renderDirectionButton: (label, direction) =>
      #      setDirection = =>
      #        @robot.setRespawnDirection(direction)
      #      button = @$("<button class='RobotOrientationChooser'>#{label}</button>")
      #      button.click(setDirection)
      #      @append(button)
      #
      #    onRobotRespawnChanged: =>
      #      console.log "onRobotRespawnChanged"
      #      @render()


  module.exports = PlayerRobotView
