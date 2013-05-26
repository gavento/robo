define (require, exports, module) ->


  baseClass = (cls) ->
    throw "#{cls} already has a typeMap" if cls.typeMap?
    cls.typeMap = {}

    cls.registerTypeName = (name) ->
      @typeMap[name] = @prototype.constructor

    cls.createSubType = (atts) ->
      typeName = atts.type or throw "atts.type required"
      type = @typeMap[typeName]
      throw "typeName #{ typeName } not registered" unless type?
      return new type atts

  module.exports =
    baseClass: baseClass
