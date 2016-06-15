Base = require('./base.coffee')
Corpse = require('./corpse.coffee')
debug = require('../debug.coffee')

module.exports = class Unit extends Base
  # options - all from common.units.* + x,y,group,side
  constructor: (options) ->
    super(options)
    @side = options.side
    for anim in ['walk', 'idle', 'fire', 'fall', 'resurrect']
      opts = options.animations[anim]
      continue unless opts
      @sprite.animations.add(anim, opts.sprites(@side), opts.rate, opts.loop, false)

    @state = null
    @health = options.health
    @speed = options.speed
    @fireRadius = options.fireRadius
    @damage = options.damage
    @hitChance = options.hitChance
    @healthLossRate = options.healthLossRate
    @resurrectAt = options.resurrectAs
    @corpseImg = options.corpse?(@side)
    @corpseGroup = options.corpseGroup

    if debug.initialized
      @sprite.inputEnabled = true
      @sprite.events.onInputDown.add =>
        console.log(@)



  createCorpse: ->
    new Corpse({x: @getX(), y: @getY(), type: @resurrectAt, image: @corpseImg, side: @side, group: @corpseGroup})

  patroll: (@positions...) ->
    @stop()

  isBusy: -> @state || @inMove()


  getDamage: (damage) ->
    @health -= damage
    #TODO: play some animation


  fire: (onComplete) ->
    @stop()
    @state = 'firing'
    @sprite.animations.play('fire').onComplete.addOnce =>
      @state = null
      onComplete?()


  fall: (onComplete) ->
    @state = 'dying'
    @sprite.animations.play('fall').onComplete.addOnce =>
      @state = 'dead'
      @sprite.destroy()
      onComplete?()


  resurrect: (onComplete) ->
    @state = 'resurrecting'
    @sprite.animations.play('resurrect').onComplete.addOnce =>
      @state = null
      onComplete?()

  updateLogic: ->
    if @healthLoosingSpeed > 0
      @health -= @healthLoosingSpeed * game.time.elapsed
    return if @inMove()
    if @positions?.length
      @stop()
      moveTo = @positions.shift()
      @positions.push(moveTo)
      @walkTo(moveTo)

