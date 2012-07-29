define (require, exports, module) ->

  # Spine.Model attribute helpers 

  # Create a accessor for an attribute, automatically converting
  # a JSON-type representation. This makes load()ing very easy.
  typedProperty = (cls, name, type, attrName) ->
    typedPropertyEx(cls, name,
      (val) -> val instanceof type,
      (val) -> if type.createSubType? then (type.createSubType val) else (new type val),
      attrName)

  # Generalised, with explicit instanceof-like criterium and conversion
  typedPropertyEx = (cls, name, criterium, conversion, attrName) ->
    attrName ?= name + '_'
    throw "prototype already contains #{name}" if cls.prototype[name]
    throw "object already contains #{attrName}" if cls[attrName]
    cls.prototype[name] = (val) ->
      if val
        if criterium val
          @[attrName] = val
        else
          @[attrName] = conversion val
      return @[attrName]

  # Create a accessor for an attribute, automatically converting
  # a JSON-type representation. This makes load()ing very easy.
  # This is a variant for array attributes.
  typedPropertyArray = (cls, name, type, attrName) ->
    typedPropertyArrayEx(cls, name,
      (val) -> val instanceof type,
      (val) -> if type.createSubType? then (type.createSubType val) else (new type val),
      attrName)

  # Generalised, with explicit instanceof-like criterium and conversion
  typedPropertyArrayEx = (cls, name, criterium, conversion, attrName) ->
    attrName ?= name + '_'
    throw "prototype already contains #{name}" if cls.prototype[name]
    throw "object already contains #{attrName}" if cls[attrName]
    cls.prototype[name] = (val) ->
      if val
        throw "expected Array for #{name}" unless _.isArray val
        @[attrName] = []
        for i in val
          if criterium i
            @[attrName].push(i)
          else
            @[attrName].push(conversion i)
      return @[attrName]

  module.exports =
    typedProperty: typedProperty
    typedPropertyEx: typedPropertyEx
    typedPropertyArray: typedPropertyArray
    typedPropertyArrayEx: typedPropertyArrayEx
