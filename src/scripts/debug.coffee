debugText = null
debugGroup = null

module.exports = (msg) ->
  debugText.setText(msg ? 'undefined') if debugText

module.exports.init = ->
  debugGroup = game.add.group()
  debugGroup.fixedToCamera = true
  debugText = game.add.text(0, 0, '1', {fill: 'yellow'}, debugGroup)
  debugText.setTextBounds(0, 0, game.camera.width, 40)
  debugText.boundsAlignH = 'right'
  debugText.setText('debug')
  game.world.bringToTop(debugGroup)
  @initialized = true

