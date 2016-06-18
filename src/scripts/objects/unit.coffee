Base = require('./base.coffee')
Corpse = require('./corpse.coffee')
debug = require('../debug.coffee')

module.exports = class Unit extends Base
  # options - all from common.units.* + x,y,group,side
  constructor: (options) ->
    spriteName = if options.side == "left" then "soldier_blue" else "soldier_red"
    super(options, spriteName)
    @side = options.side
    
    @sprite.animations.add("walk_side", Phaser.Animation.generateFrameNames("walk_side_",1,5,".png",2), 20, true, false)
    @sprite.animations.add("walk_up", Phaser.Animation.generateFrameNames("walk_up_",1,4,".png",2), 20, true, false)
    @sprite.animations.add("walk_down", Phaser.Animation.generateFrameNames("walk_down_",1,4,".png",2), 20, true, false)
    @sprite.animations.add("idle", ["idle_01.png"], 1, true, false)
    @sprite.animations.add("shoot_side", Phaser.Animation.generateFrameNames("shoot_side_",1,4,".png",2), 10, false, false)
    @sprite.animations.add("shoot_up", Phaser.Animation.generateFrameNames("shoot_side_",1,4,".png",2), 10, false, false)
    @sprite.animations.add("shoot_down", Phaser.Animation.generateFrameNames("shoot_side_",1,4,".png",2), 10, false, false)
    @sprite.animations.add("death", Phaser.Animation.generateFrameNames("death_",1,5,".png",2), 10, false, false)
    @sprite.animations.add("bury", Phaser.Animation.generateFrameNames("bury_",1,9,".png",2), 10, false, false)
    
    
    # for anim in ['walk_side', 'idle', 'shoot_side', 'death']
    #  opts = options.animations[anim]
    #  continue unless opts
    #  @sprite.animations.add(anim, opts.sprites(@side), opts.rate, opts.loop, false)

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
  
  walk: () ->
    @sprite.animations.play('walk_'+@animPostfix)
    super()

  getDamage: (damage) ->
    @health -= damage
    #TODO: play some animation

  stop: () ->
    @sprite.animations.play('idle')
    super()
    
  fire: (onComplete) ->
    @stop()
    @state = 'firing'
    @sprite.animations.play('shoot_'+@animPostfix).onComplete.addOnce =>
      @state = null
      onComplete?()


  fall: (onComplete) ->
    @state = 'dying'
    @sprite.animations.play('death').onComplete.addOnce =>
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

