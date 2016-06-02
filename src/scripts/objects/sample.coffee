# Sample killable object with position, animation and sound
# @sprite.kill cleans Phaser object
# @dead property used to remove SampleObject instance from your own lists

class SampleObject
  constructor: (pos) ->
    console.log("creating sample")
    @sprite = game.add.sprite(pos.x, pos.y, 'sample')
    @sprite.animations.add('doSomething', ["sensor_i00.png","sensor_i01.png",
    "sensor_i02.png","sensor_i03.png","sensor_i04.png",
    "sensor_i03.png","sensor_i02.png","sensor_i01.png"], 5, true, false)
    @sprite.animations.add('idle', ["sensor_a02.png"], 10, false, false)
    @sprite.animations.play('idle')
    #game.physics.p2.enable(@sprite)
    #@sprite.body.static = true
    @sprite.anchor = new Phaser.Point(0.5, 0)
    @sound = game.add.audio('sample_sound')
    
  sprite: null
  doingSomething: false
  dead: false

  doSomething: () =>
    if @doingSomething
      @sprite.animations.play('idle')
    else  
      @sound.play()
      @sprite.animations.play('doSomething')
    @doingSomething = !@doingSomething  
   
  kill: () =>
    @sprite.kill()
    @dead = true
    
  
module.exports = SampleObject
