Base = require('./base.coffee')

module.exports = class Hero extends Base
  constructor: (options) ->
    super(options)
    @sprite.animations.add('walk', [1...5].map((i) => "walk_b_#{i}.png"), 1, true, false)
    @sprite.animations.add('idle', ["walk_b_1.png"], 10, false, false)
    game.camera.follow(@sprite)
