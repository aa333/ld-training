Base = require('./base.coffee')

module.exports = class Hero extends Base
  constructor: (options) ->
    super(options)
    for anim in ['walk', 'idle', 'borrow', 'resurrect']
      opts = options.animations[anim]
      continue unless opts
      @sprite.animations.add(anim, opts.sprites(@side), opts.rate, opts.loop, false)
    game.camera.follow(@sprite)
    @speed = options.speed


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