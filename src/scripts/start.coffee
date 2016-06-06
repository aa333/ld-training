# Game entry point
Phaser = require('./phaser-shim.coffee')

window.enableFirefoxOptimisations = true # navigator.userAgent.toLowerCase().indexOf('firefox') > -1
#Alexey: without it in Chrome I do not see pathlines for some reason
window.game = new Phaser.Game(800, 600, (if enableFirefoxOptimisations then Phaser.CANVAS else Phaser.AUTO), 'canvas')

game.state.add('init', require('./init.coffee'));
game.state.add('load', require('./load.coffee'));
game.state.add('menu', require('./menu.coffee'));
game.state.add('play', require('./play.coffee'));
game.state.add('win', require('./win.coffee'));

game.state.start('init')
