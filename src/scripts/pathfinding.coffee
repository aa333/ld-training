debug = require('./debug.coffee')
EasyStar = require('easystarjs')

OBSTACLES = [5, 9, 13]
SMALL_CELL_SIZE = 8

fromWorld = (c) -> Math.floor(c/SMALL_CELL_SIZE)
toWorld = (c) -> c*SMALL_CELL_SIZE

FREE = 0
PERMANENT_OBSTACLE = 0xff0000
TEMP_OBSTACLE = 0xffc000
UNIT = 0xff00ff

#TODO: make path more smooth
#TODO: update paths when units are close

module.exports = class PassableWorld
  constructor: (layer) ->
    smallInTile = layer.map.tileHeight / SMALL_CELL_SIZE
    @_units = []
    @_worldMap = [0...layer.map.height*smallInTile].map (y) ->
      [0...layer.map.width*smallInTile].map (x) ->
        if layer.layer.data[Math.floor(y/smallInTile)][Math.floor(x/smallInTile)].index in OBSTACLES then PERMANENT_OBSTACLE else FREE


  update: ->
    @_units.forEach ({finder}) -> finder.update()
    @drawDebug()

  drawDebug: (force) ->
    return if not debug.initialized
    if not @_debugGroup
      @_debugGroup = game.add.group()
      game.world.bringToTop(@_debugGroup)
      @_nextTime = 0
    if @_nextTime > game.time.totalElapsedSeconds() and not force
      return
    @_nextTime = game.time.totalElapsedSeconds() + 0.5
    @_debugGroup.removeAll()
    g = game.add.graphics(0, 0, @_debugGroup)
    for o in [PERMANENT_OBSTACLE, TEMP_OBSTACLE, UNIT]
      g.beginFill(o, 0.2)
      (@_units[0].finder.debugGrid ? @_worldMap).forEach (row, y) ->
        row.forEach (cell, x) ->
          g.drawRect(toWorld(x), toWorld(y), SMALL_CELL_SIZE, SMALL_CELL_SIZE) if cell == o
      g.endFill()
    g2 = game.add.graphics(0, 0, @_debugGroup)
    g2.lineColor = 0x0000ff
    g2.lineWidth = 3
    g2.lineAlpha = 1
    @_units.forEach ({finder}) ->
      return if not finder.path or finder.path.length == 0
      g2.moveTo(finder.path[0].x, finder.path[0].y)
      finder.path.slice(1).forEach ({x,y}) ->
        g2.lineTo(x, y)


  addObstacle: (x1, y1, width, height, type) ->
    for x in [fromWorld(x1)...fromWorld(x1+width)]
      for y in [fromWorld(y1)...fromWorld(y1+height)]
        @_worldMap[y][x] = type ? TEMP_OBSTACLE

  removeObstacle: (x1, y1, width, height) ->
    for x in [fromWorld(x1)...fromWorld(x1+width)]
      for y in [fromWorld(y1)...fromWorld(y1+height)]
        @_worldMap[y][x] = FREE


  assignPathFinder: (unit) =>
    unit.assignPathFinder(@createPathFinder(unit))

  createPathFinder: (unit) ->
    es = null
    finder = {
      path: null,
      debugGrid: null,
      find: (tx, ty, cb) =>
        if es
          throw "path finding already started. seems to be a mistake in logic"
        es = new EasyStar.js()
        grid = @_worldMap.map (row) -> row.map (cell) -> cell  # just a copy

        @_units.forEach (u) ->
          return if u.unit == unit
          x1 = fromWorld(u.unit.sprite.x)
          y1 = fromWorld(u.unit.sprite.y)
          x2 = fromWorld(u.unit.sprite.x + u.unit.sprite.width)
          y2 = fromWorld(u.unit.sprite.y + u.unit.sprite.height)
          for x in [x1...x2]
            for y in [y1...y2]
              grid[y][x] = UNIT
        es.setGrid(grid)
        finder.debugGrid = grid
        es.setAcceptableTiles([FREE])
        es.findPath fromWorld(unit.sprite.x), fromWorld(unit.sprite.y), fromWorld(tx), fromWorld(ty), (path) =>
          finder.path = path?.map ({x,y}) -> {x: toWorld(x), y: toWorld(y)}
          if not path
            console.warn("could not find way to ", tx, ty)
          cb()
          @drawDebug(true)

      stop: ->
        es = null
        finder.path = null

      update: ->
        es?.calculate()

      destroy: ->
        @destroyPathFinder(unit)

    }
    @_units.push({unit, finder})
    finder


  destroyPathFinder: (unit) ->
    @_units = @_units.filter((u) -> u.unit isnt unit)