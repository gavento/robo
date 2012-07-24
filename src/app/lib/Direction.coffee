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
      return ((dir % 4) + 4) % 4

    @toName: (dir) ->
      return "NESW"[@toNumber dir]

    constructor: (dir) ->
      @dir = @constructor.toNumber dir

    turnRight: (amount = 1) ->
      @dir = @constructor.toNumber(@dir + amount)

    tyrnLeft: (amount = 1) ->
      @dir = @constructor.toNumber(@dir - amount)

    getNumber: ->
      return @dir

    getName: ->
      return @constructor.toName @dir

    module.exports = Direction
