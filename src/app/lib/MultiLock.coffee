define (require, exports, module) ->

  class MultiLock
    constructor: (@callback, @timeout=2000) ->
      @number = 0
      @lockers = {}
      @timerID = setTimeout @timeoutF, @timeout

    # timeout callback disables the original callback
    timeoutF: (logWarning=true) =>
      clearTimeout @timerID
      if logWarning
        console.log "MultiLock expired:", @
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
      return =>
        if dbg_name
          @lockers[dbg_name] -= 1
        @number -= 1
        if @number == 0
          @timeoutF false

    triggerIfUnlocked: ->
      if @number == 0
        @timeoutF false

  module.exports = MultiLock
