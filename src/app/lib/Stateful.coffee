# This is basically [stateful.js](https://github.com/foca/stateful.js/)
# transformed into coffeescript. Parts that are currently not necessary
# for our implementation are missing.
define (require, exports, module) ->

  class Stateful
    # Public: Constructor for the State object.
    # 
    # object       - The object that requires state handling.
    # initialState - The initial state.
    # interfaces   - An object with the API extensions provided by each state.
    constructor: (object, initialState, interfaces) ->
      @object = object
      @interfaces = interfaces
      @transition(initialState)

    # Public: Switch to a new state.
    # 
    # state       - The name of the new state.
    transition: (state) =>
      @_exitState(state) if @current
      @_enterState(state)

    _exitState: (state) =>
      #console.log "Leaving state:", @current
      api = @interfaces[@current]
      for property in api
        delete @object[property]

    _enterState: (state) =>
      #console.log "Entering state:", state
      api = new @interfaces[state]
      throw "Invalid state: " + state unless api
    
      for property of api
        @object[property] = api[property]

      @current = state
      @object.trigger "state:entered"
    
  module.exports = Stateful



