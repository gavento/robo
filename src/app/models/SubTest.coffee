Spine = require('spine')

class SubTest extends Spine.Model
  @configure 'SubTest', 'text'
  constructor: ->
    super                
  
module.exports = SubTest