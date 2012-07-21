Spine = require('spine')
SubTest = require('models/SubTest')
class Test extends Spine.Model
  @configure 'Test', 'subtest', 'text'
  constructor: ->
    super
    @subtest = new SubTest

module.exports = Test
