define (require, exports, module) ->

  class Stateful
    constructor: (object, initialState, interfaces) ->
      @object = object
      @interfaces = interfaces
      @transition(initialState)

    transition: (state) =>
      @_exitState(state) if @current
      @_enterState(state)

    _exitState: (state) =>
      console.log "Leaving state:", @current
      api = @interfaces[@current]
      for property in api
        delete @object[property]

    _enterState: (state) =>
      console.log "Entering state:", state
      api = new @interfaces[state]
      throw "Invalid state: " + state unless api
    
      for property of api
        console.log "Property", property
        @object[property] = api[property]

      @current = state
    
  module.exports = Stateful



