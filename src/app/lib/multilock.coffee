define (require, exports, module) ->

  class MultiLock
    # Id of the last created MultiLock. It is incremented with each new
    # MultiLock. MultiLock id is used for debugging.
    @counter = 0
    # If this is set to true than debugging outputs will be enabled.
    @debug = false

    constructor: (@callback, @timeout=2000) ->
      @number = 0
      @lockers = {}
      @timerID = setTimeout @timeoutF, @timeout
      @id = ++MultiLock.counter
      console.log "MultiLock", @id, "created", @ if MultiLock.debug

    # timeout callback disables the original callback
    timeoutF: (logWarning=true) =>
      clearTimeout @timerID
      if logWarning
        console.log "MultiLock", @id, "expired", @ if logWarning
      else
        console.log "MultiLock", @id, "triggered", @ if MultiLock.debug
      cb = @callback
      @callback = ->
      cb()

    getLock: (dbg_name) =>
      # dbg_name is optional (tracks who is locking it)
      # returns an "unlock" closure
      @number += 1
      if dbg_name
        @lockers[dbg_name] ?= 0
        @lockers[dbg_name] += 1
      console.log "MultiLock", @id, "locked by", dbg_name, @ if MultiLock.debug
      return =>
        if dbg_name
          @lockers[dbg_name] -= 1
        @number -= 1
        console.log "MultiLock", @id, "unlocked by", dbg_name, @ if MultiLock.debug
        if @number == 0
          @timeoutF false

    triggerIfUnlocked: ->
      if @number == 0
        @timeoutF false

  module.exports = MultiLock
