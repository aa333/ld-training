# Main play state

Phaser = require('./phaser-shim.coffee')
SampleObject = require('./objects/sample.coffee')

keyLockMap = {}
space = null
sample = null

checkAndLock = (key, action) =>
  id = key.name
  if key.isDown
    if not keyLockMap[id]
      keyLockMap[id] = true
      action()
  else keyLockMap[id] = false

module.exports.create = () ->
  console.log("creating play state")
  sample = new SampleObject({x:100, y:100})
  cursors = game.input.keyboard.createCursorKeys()
  space = game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR)
  

module.exports.update = () ->
  checkAndLock(space, sample.doSomething)
  
module.exports.render = () ->
  #drawing here will cost a big performance penalty, so debug only
  game.debug.text('FPS: '+ (game.time.fps || '--'), 32, 62)