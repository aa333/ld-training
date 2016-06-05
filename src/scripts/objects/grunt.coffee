Base = require('./base.coffee')
debug = require('../debug.coffee')

module.exports = class Grunt extends Base
  constructor: (options) ->
    super(options)
    @sprite.animations.add('walk', [1...5].map((i) => "walk_b_#{i}.png"), 1, true, false)
    @sprite.animations.add('idle', ["walk_b_1.png"], 10, false, false)

  patroll: (@positions...) ->
    @stop()

  updateLogic: ->
    return if @inMove()
    @stop()
    moveTo = @positions.shift()
    @positions.push(moveTo)
    @walkTo(moveTo)

