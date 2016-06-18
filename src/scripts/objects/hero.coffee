Base = require('./base.coffee')

module.exports = class Hero extends Base
  constructor: (options) ->
    super(options, "soldier_blue")
    @sprite.animations.add("walk_side", Phaser.Animation.generateFrameNames("walk_side_",1,5,".png",2), 20, true, false)
    @sprite.animations.add("walk_up", Phaser.Animation.generateFrameNames("walk_up_",1,4,".png",2), 20, true, false)
    @sprite.animations.add("walk_down", Phaser.Animation.generateFrameNames("walk_down_",1,4,".png",2), 20, true, false)
    @sprite.animations.add("idle", ["idle_01.png"], 1, true, false)
    # for anim in ['walk', 'idle', 'borrow', 'resurrect']
    #   opts = options.animations[anim]
    #   continue unless opts
    #   @sprite.animations.add(anim, opts.sprites(@side), opts.rate, opts.loop, false)
    game.camera.follow(@sprite)
    @speed = options.speed
  
  
  walk: () ->
    @sprite.animations.play('walk_'+@animPostfix)
    super()
    
  stop: () ->
    @sprite.animations.play('idle')
    super()
    
  resurrect: (x, y, onComplete) ->
    #TODO: walkTo, then play animation, then onComplete
    #TODO: if failed - play some failing sound?

  borrow: (x, y, onComplete) ->
    #TODO: walkTo, then play animation, then onComplete

  animateBorrow: (onComplete) ->
    @sprite.animations.play('borrow').onComplete.addOnce =>
      onComplete?()

  animateResurrect: (onComplete) ->
    @sprite.animations.play('resurrect').onComplete.addOnce =>
      onComplete?()