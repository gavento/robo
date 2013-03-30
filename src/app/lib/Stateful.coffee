# This is basically [stateful.js](https://github.com/foca/stateful.js/)
# transformed into coffeescript. Parts that are currently not necessary
# for our implementation are missing.
define (require, exports, module) ->

  class Stateful
    # If this is greater than 0 than debugging outputs will be enabled.
    # If set to 1, only state transitions will be logged.
    # If set to 2, added and removed properties will be logged as well.
    @debug = 1

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
      console.log 'Leaving state:', @current if Stateful.debug >= 1
      api = new @interfaces[@current]
      for property of api
        continue if property == 'constructor'
        console.log 'Deleting property:', property if Stateful.debug >= 2
        delete @object[property]

    _enterState: (state) =>
      console.log 'Entering state:', state if Stateful.debug >= 1
      throw "Invalid state: " + state unless @interfaces[state]
      api = new @interfaces[state]
      for property of api
        continue if property == 'constructor'
        console.log 'Adding property:', property if Stateful.debug >= 2
        @object[property] = api[property]

      @current = state
      @object.trigger 'state:entered'
    
  module.exports = Stateful



