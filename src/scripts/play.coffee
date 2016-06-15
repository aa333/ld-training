# Main play state
Phaser = require('./phaser-shim.coffee')
Hero = require('./objects/hero.coffee')
Grunt = require('./objects/grunt.coffee')
debug = require('./debug.coffee')
PassableWorld = require('./pathfinding.coffee')


keyLockMap = {}
space = null
hero = null
debugText = null
map = null
groundLayer = null
obstaclesLayer = null
treetopLayer = null
grunts1 = []

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
  gameObjects = game.add.group()
  treetops = game.add.group()

  map = game.add.tilemap('testlvl')
  map.addTilesetImage('tilemap_main', 'tilemap_main')
  groundLayer = map.createLayer('ground')
  obstaclesLayer = map.createLayer('obstacles')
  treetopLayer = map.createLayer('foreground', undefined, undefined, treetops)
  groundLayer.resizeWorld()
  
  passableWorld = new PassableWorld(obstaclesLayer)
  cursor = new Cursor(gameObjects)

  hero = new Hero({x: 100, y: 100, group: gameObjects})
  [0...20].forEach (i) ->
    g = new Grunt({x: 130 + i*40, y: 100, group: gameObjects})
    grunts1.push(g)
    g.patroll({x: 400+i*40, y: 300}, {x: 700+i*40, y: 200}, {x: 400+i*40, y: 100})
  passableWorld.addObstacle(100,500,200,20)

  [hero].concat(grunts1).forEach passableWorld.assignPathFinder

  game.input.onTap.add (e) =>
    hero.walkTo({x: e.worldX, y: e.worldY})

  debug.init()


module.exports.update = () ->
  tile = map.getTileWorldXY(game.input.activePointer.worldX, game.input.activePointer.worldY)
  debug(tile?.index ? -1)

  cursor.update(tile)
  [hero].concat(grunts1).forEach (g) ->
    g.update()
    #treetopLayerItem = map.getTile(treetopLayer.getTileX(g.sprite.x), treetopLayer.getTileY(g.sprite.y), treetopLayer)
    #if g.underTreetop and g.underTreetop != treetopLayerItem
    #  g.underTreetop.alpha = 1.0
    #  g.underTreetop = null
    #if treetopLayerItem
    #  g.underTreetop = treetopLayerItem
    #  treetopLayerItem.alpha = 0.5

  passableWorld.update()

  
module.exports.render = () ->
  #drawing here will cost a big performance penalty, so debug only
  game.debug.text('FPS: '+ (game.time.fps || '--'), 32, 62)