Phaser = require('../phaser-shim.coffee')
BattleModel = require('./battlemodel.coffee')
Commander = require('./commander.coffee')
common = require('../common.coffee')
GET_X = (u) -> u.getX()

module.exports = class World
  constructor: (@layer, @spawner) ->
    @units = {
      left: []
      right: []
    }
    @battlemodel = new BattleModel(@layer.map.widthInPixels)
    @ai = {
      left: new Commander('left')
      right: new Commander('right')
    }
    @corpses = {
      dropped: []
      borrowed: 0
      resurrected: 0
    }

  borrow: (hero, corpse) ->
    hero.animateBorrow =>
      i = @corpses.dropped.indexOf(corpse)
      @corpses.dropped.splice(i, 1)
      @corpses.borrowed++
      console.log 'borrowed, total', @corpses.borrowed
      corpse.destroy()

  resurrect: (hero, corpse) ->
    type = corpse.canBeResurrectedAs()
    return unless type
    hero.animateResurrect =>
      i = @corpses.dropped.indexOf(corpse)
      @corpses.dropped.splice(i, 1)
      @corpses.resurrected++
      corpse.destroy()
      zombie = @spawner(type, corpse.getResurrectOptions())
      @units[zombie.side].push(zombie)
      zombie.resurrect()


  dropDead: (group) =>
    alive = []
    @units[group].forEach (u) =>
      if u.health <= 0
        u.fall =>
          corpse = u.createCorpse()
          @corpses.dropped.push(corpse)
      else
        alive.push(u)
    @units[group] = alive

  getCommanderHelper: -> @_helper ?= {

    getTileSize: => @layer.map.tileWidth

    getMovingRange: (side) => @battlemodel.getMovingRange()[side]

    isEmpty: (x,y) =>
      return @_helper.insideWorld(x,y) and not @layer.map.getTile(@layer.getTileX(x), @layer.getTileY(y))

    getEnemiesToShoot: (unit) =>
      @units[common.opposite[unit.side]].filter((u) -> Phaser.Math.distance(u.getX(), u.getY(), unit.getX(), unit.getY()) <= unit.fireRadius)

    getEnemies: (side) =>
      @units[common.opposite[side]]

    insideWorld: (x, y) =>
      x >= 0 and y >= 0 and x < @layer.map.widthInPixels and y < @layer.map.heightInPixels

    shoot: (from, to) =>
      from.fire ->
        if Math.random() < from.hitChance
          to.getDamage(from.damage)


  }

  spawn: (side, spawnPlan) ->
    for type in ['soldier']
      if spawnPlan[type] > 0
        @units[side] = @units[side].concat([0...spawnPlan[type]].map (y) =>
          @spawner(type, {
            side,
            x: @battlemodel.convert(side, 100),
            y: game.rnd.integerInRange(
              0,
              #10
              @layer.map.height - 1
            ) * @layer.map.tileWidth
          })
        )

  update: ->
    for side in ['left', 'right']
      @spawn(side, @battlemodel.getSpawnPlan({side}, game.time.totalElapsedSeconds()*1000))
      @ai[side].update(@units[side], @getCommanderHelper())
    Object.keys(@units).forEach(@dropDead)
    for side in ['left', 'right']
      @battlemodel.updatePositions(side, @units.left.map(GET_X))
      @units[side].forEach((u) -> u.update())
    @battlemodel.update(game.time.elapsed)