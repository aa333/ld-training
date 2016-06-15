Phaser = require('../phaser-shim.coffee')
BattleModel = require('./battlemodel.coffee')
Napoleon = require('./napoleon.coffee')
GET_X = (u) -> u.getX()

#TODO: duplicate
OPPOSITE =
  left: 'right'
  right: 'left'

module.exports = class World
  constructor: (@layer, @spawner) ->
    @units = {
      left: []
      right: []
    }
    @battlemodel = new BattleModel(@layer.map.widthInPixels)
    @ai = {
      left: new Napoleon('left')
      right: new Napoleon('right')
    }

    @corpses = {
      dropped: []
      borrowed: []
      resurrected: []
    }
    #@spawn('left', {soldier: 1})

  borrow: (corpse) ->
    i = @corpses.dropped.indexOf(corpse)
    @corpses.splice(i, 1)
    @corpses.borrowed.push(corpse)

  resurrect: (corpse) ->
    #TODO



  dropDead: (group) =>
    alive = []
    for u in @units[group]
      if u.health <= 0
        u.fall => @corpses.dropped.push(u)
      else
        alive.push(u)
    @units[group] = alive

  getTileSize: -> @layer.map.tileWidth

  isEmpty: (x,y) ->
    tile = @layer.map.getTile(@layer.getTileX(x), @layer.getTileY(y))
    return tile and not(tile.index in [21]) #TODO: copy-paste from pathfinding, refactor

  findAround: (unit) ->
    @units[OPPOSITE[unit.side]].filter((u) -> Phaser.Math.distance(u.getX(), u.getY(), unit.getX(), unit.getY()) <= unit.vision)

  insideWorld: (x, y) ->
    x >= 0 and y >= 0 and x < @layer.map.widthInPixels and y < @layer.map.heightInPixels

  shoot: (from, to) ->
    if Math.random() < 0.5
      to.getDamage(10)

  spawn: (side, spawnPlan) ->
    if spawnPlan.soldier
      @units[side] = @units[side].concat([0...spawnPlan.soldier].map (y) =>
        @spawner.soldier({
          side,
          x: @battlemodel.convert(side, 100),
          y: game.rnd.integerInRange(
            0,
            #10 # for debug
            @layer.map.height - 1
          )*@getTileSize()
        })
      ) # TODO: spawning code

  update: ->
    for side in ['left', 'right']
      @spawn(side, @battlemodel.getSpawnPlan({side}, game.time.totalElapsedSeconds()*1000))
      @ai[side].update(@units[side], @)
    Object.keys(@units).forEach(@dropDead)
    for side in ['left', 'right']
      @battlemodel.updatePositions(side, @units.left.map(GET_X))
      @units[side].forEach((u) -> u.update())
    @battlemodel.update(game.time.elapsed)