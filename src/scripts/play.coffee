# Main play state
Phaser = require('./phaser-shim.coffee')
Hero = require('./objects/hero.coffee')
Unit = require('./objects/unit.coffee')
Corpse = require('./objects/corpse.coffee')
debug = require('./debug.coffee')
PassableWorld = require('./pathfinding.coffee')
World = require('./logic/world.coffee')
common = require('./common.coffee')


keyLockMap = {}
space = null
hero = null
debugText = null
map = null
obstaclesLayer = null
treetopLayer = null
groundLayer = null
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

module.exports.create = () ->
  console.log("creating play state")
  ground = game.add.group()
  corpses = game.add.group()
  gameObjects = game.add.group()
  treetops = game.add.group()

  map = game.add.tilemap('testlvl')
  map.addTilesetImage('tilemap_main', 'tilemap_main')
  groundLayer = map.createLayer('ground', undefined, undefined, ground)
  obstaclesLayer = map.createLayer('obstacles', undefined, undefined, gameObjects)
  treetopLayer = map.createLayer('foreground', undefined, undefined, treetops)
  groundLayer.resizeWorld()
  map.setLayer(obstaclesLayer)

  passableWorld = new PassableWorld(obstaclesLayer)
  cursor = new Cursor(gameObjects)
  spawn = (type, options) ->
    options = Phaser.Utils.mixin(common.units[type], options)
    options.group = gameObjects
    options.corpseGroup = corpses
    u = new Unit(options)
    passableWorld.assignPathFinder(u)
    return u
  world = new World(obstaclesLayer, spawn)
  hero = new Hero(Phaser.Utils.mixin(common.units.hero, {x: 400, y: 100, group: gameObjects}) )
  passableWorld.assignPathFinder(hero)

  game.input.onTap.add (e) =>
    hero.walkTo({x: e.worldX, y: e.worldY})

  game.input.keyboard.onPressCallback = (key) ->
    return if not Corpse.hovered
    switch key
      when 'x'
        world.resurrect(hero, Corpse.hovered)
        # resurrect
      when 'b'
        # borrow
        world.borrow(hero, Corpse.hovered)

  #debug.init()


module.exports.update = () ->
  tile = map.getTileWorldXY(game.input.activePointer.worldX, game.input.activePointer.worldY, groundLayer)
  debug(tile?.index ? -1)

  cursor.update(tile)
  hero.update()
  world.update()
  #[hero].concat(world.units.left).concat(world.units.right).forEach (g) ->
  #  treetopLayerItem = map.getTile(treetopLayer.getTileX(g.sprite.x), treetopLayer.getTileY(g.sprite.y), treetopLayer)
  #  if g.underTreetop and g.underTreetop != treetopLayerItem
  #    g.underTreetop.alpha = 1.0
  #    g.underTreetop = null
  #  if treetopLayerItem
  #    g.underTreetop = treetopLayerItem
  #    treetopLayerItem.alpha = 0.5

  passableWorld.update()

  
module.exports.render = () ->
  #drawing here will cost a big performance penalty, so debug only
  game.debug.text('FPS: '+ (game.time.fps || '--'), 32, 62)