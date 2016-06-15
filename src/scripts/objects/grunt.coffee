Base = require('./base.coffee')
debug = require('../debug.coffee')

module.exports = class Grunt extends Base
  constructor: (options) ->
    super(options)
    @sprite.animations.add('walk', [1...5].map((i) => "walk_b_#{i}.png"), 1, true, false)
    @sprite.animations.add('idle', ["walk_b_1.png"], 10, false, false)
    fireAnim = @sprite.animations.add('fire', [1...10].map((i) -> "walk_r_#{1+i%2}.png"), 10, false, false)
    fireAnim.onComplete.add(@onFireComplete)
    @state = null
    @health = options.health || 100
    @side = options.side
    @speed = options.speed || 4
    @vision = options.vision || 100

    @healthLoosingSpeed = options.healthLoosingSpeed || 0


  patroll: (@positions...) ->
    @stop()

  isBusy: -> @state || @inMove()


  getDamage: (damage) ->
    @health -= damage
    #TODO: play some animation


  fire: ->
    @stop()
    @state = 'firing'
    @sprite.animations.play('fire')

  onFireComplete: =>
    @state = null

  fall: (onComplete) ->
    # play dying anim
    @sprite.destroy()
    onComplete()

  updateLogic: ->
    if @healthLoosingSpeed > 0
      @health -= @healthLoosingSpeed * game.time.elapsed
    return if @inMove()
    if @positions?.length
      @stop()
      moveTo = @positions.shift()
      @positions.push(moveTo)
      @walkTo(moveTo)

