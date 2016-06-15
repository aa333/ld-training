{opposite, direction} = require('../common.coffee')

module.exports = class Commander
  constructor: (@side) ->

  #TODO: get all enemies,
  update: (units, helper) ->
    range = helper.getMovingRange(@side)
    units.forEach (u) =>
      return if u.isBusy()
      enemies = helper.findAround(u, opposite[@side])
      if u.getX() < range[0] or u.getX() > range[1]
        u.speedFactor = 0.2
      else
        u.speedFactor = 1
      if enemies.length > 0
        helper.shoot(u, enemies[0])
      else
        nx = u.getX() + helper.getTileSize()*direction[@side]
        ny = u.getY()
        while helper.insideWorld(nx, ny) and not helper.isEmpty(nx, ny)
          nx += helper.getTileSize()*direction[@side]
        if helper.insideWorld(nx, ny)
          u.walkTo({x: nx, y: ny})


