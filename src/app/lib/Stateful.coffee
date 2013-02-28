# This is basically [stateful.js](https://github.com/foca/stateful.js/)
# transformed into coffeescript. Parts that are currently not necessary
# for our implementation are missing.
define (require, exports, module) ->

  class Stateful
    # If this is set to true than debugging outputs will be enabled.
    @debug = false

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
      console.log 'Leaving state:', @current if Stateful.debug
      api = new @interfaces[@current]
      for property of api
        continue if property == 'constructor'
        console.log 'Deleting property:', property if Stateful.debug
        delete @object[property]

    _enterState: (state) =>
      console.log 'Entering state:', state if Stateful.debug
      api = new @interfaces[state]
      throw "Invalid state: " + state unless api
      for property of api
        continue if property == 'constructor'
        console.log 'Adding property:', property if Stateful.debug
        @object[property] = api[property]

      @current = state
      @object.trigger 'state:entered'
    
  module.exports = Stateful



