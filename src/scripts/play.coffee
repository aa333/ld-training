# Main play state
Phaser = require('./phaser-shim.coffee')
Hero = require('./objects/hero.coffee')
Grunt = require('./objects/grunt.coffee')
debug = require('./debug.coffee')
PassableWorld = require('./pathfinding.coffee')
World = require('./logic/world.coffee')


keyLockMap = {}
space = null
hero = null
debugText = null
map = null
layer = null
treetopLayer = null
world = null

cursor = null
passableWorld = null

checkAndLock = (key, action) =>
  id = key.name
  if key.isDown
    if not keyLockMap[id]
      keyLockMap[id] = true
      action()
  else keyLockMap[id] = false

class Cursor
  constructor: (group) ->
    @_cursor = game.add.graphics(0, 0, group)
    @_cursor.beginFill('#000', 0.3)
    @_cursor.drawRect(0, 0, map.tileWidth, map.tileHeight)
    @_cursor.endFill()

  update: (tile) ->
    if tile
      @_cursor.visible = true
      @_cursor.x = tile.worldX
      @_cursor.y = tile.worldY
    else
      @_cursor.visible = false


Options =
  soldier: {health: 100, vision: 100, speed: 0.5}
  soldierZombie: {health: 1000, vision: 100, speed: 1, healthLoosingSpeed: 2}


module.exports.create = () ->
  console.log("creating play state")
  gameObjects = game.add.group()
  treetops = game.add.group()

  map = game.add.tilemap('test1')
  map.addTilesetImage('tilemap', 'tileset')
  layer = map.createLayer('Layer1', undefined, undefined, gameObjects)
  layer.resizeWorld()
  treetopLayer = map.createLayer('treetop', undefined, undefined, treetops)

  passableWorld = new PassableWorld(layer)
  cursor = new Cursor(gameObjects)
  world = new World layer, {
    soldier: (opts) ->
      opts = Phaser.Utils.mixin(Options.soldier, opts)
      opts.group = gameObjects
      g = new Grunt(opts)
      passableWorld.assignPathFinder(g)
      g
  }

  hero = new Hero({x: 400, y: 100, group: gameObjects})

  passableWorld.assignPathFinder(hero)

  game.input.onTap.add (e) =>
    hero.walkTo({x: e.worldX, y: e.worldY})

  #debug.init()


module.exports.update = () ->
  tile = map.getTileWorldXY(game.input.activePointer.worldX, game.input.activePointer.worldY)
  debug(tile?.index ? -1)

  cursor.update(tile)
  hero.update()
  world.update()
  [hero].concat(world.units.left).concat(world.units.right).forEach (g) ->
    treetopLayerItem = map.getTile(treetopLayer.getTileX(g.sprite.x), treetopLayer.getTileY(g.sprite.y), treetopLayer)
    if g.underTreetop and g.underTreetop != treetopLayerItem
      g.underTreetop.alpha = 1.0
      g.underTreetop = null
    if treetopLayerItem
      g.underTreetop = treetopLayerItem
      treetopLayerItem.alpha = 0.5

  passableWorld.update()

  
module.exports.render = () ->
  #drawing here will cost a big performance penalty, so debug only
  game.debug.text('FPS: '+ (game.time.fps || '--'), 32, 62)