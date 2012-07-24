define (require, exports, module) ->

  SubclassTypes =
    typeMap: {}
    registerType: (type) ->
      @typeMap[type] = @prototype.constructor
      @typeName = type
    getType: (type) ->
      throw "type #{ type } not registered" unless @typeMap[type]
      return @typeMap[type]

  module.exports = SubclassTypes
