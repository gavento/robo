define (require, exports, module) ->


  class Direction

    @toNumber: (dir) ->
      if typeof(dir) == "string"
        switch dir.toUpperCase()[0]
          when "N" then return 0
          when "E" then return 1
          when "S" then return 2
          when "W" then return 3
          else throw "invalid Direction #{ dir }"
      else if typeof(dir) == "number"
        return ((dir % 4) + 4) % 4
      else if dir instanceof Direction
        return dir.getNumber()
      else
        throw "invalid Direction #{ dir }"

    @toName: (dir) ->
      return "NESW"[@toNumber dir]

    @dirs: ["N","E","S","W"]

    constructor: (dir) ->
      @dir = @constructor.toNumber dir

    turn: (amount) ->
      throw "Direction.turn: No amount given." unless amount?
      @dir = @constructor.toNumber(@dir + amount)

    turnRight: (amount = 1) ->
      @dir = @constructor.toNumber(@dir + amount)

    tyrnLeft: (amount = 1) ->
      @dir = @constructor.toNumber(@dir - amount)

    set: (dir) ->
      @dir = @constructor.toNumber(dir)

    getNumber: ->
      return @dir

    getName: ->
      return @constructor.toName @dir

    dx: -> return [0, 1, 0, -1][@dir]

    dy: -> return [-1, 0, 1, 0][@dir]

    toJSON: ->
      return @getName()

    copy: -> new Direction @dir
    
    opposite: -> new Direction @constructor.toNumber(@dir + 2)

    equals: (direction) ->
      return direction.getNumber() == @getNumber()


  module.exports = Direction
