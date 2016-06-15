DIRECTION =
  left: +1
  right: -1

OPPOSITE =
  left: 'right'
  right: 'left'

module.exports = class Napoleon
  constructor: (@side) ->

  update: (units, world) ->
    range = world.battlemodel.getMovingRange()[@side]
    units.forEach (u) =>
      return if u.isBusy()
      enemies = world.findAround(u, OPPOSITE[@side])
      if u.getX() < range[0] or u.getX() > range[1]
        u.speedFactor = 0.2
      else
        u.speedFactor = 1
      if enemies.length > 0
        u.stop()
        u.fire()
        world.shoot(u, enemies[0])
      else
        nx = u.getX() + world.getTileSize()*DIRECTION[@side]
        ny = u.getY()
        while world.insideWorld(nx, ny) and not world.isEmpty(nx, ny)
          nx += world.getTileSize()*DIRECTION[@side]
        if world.insideWorld(nx, ny)
          u.walkTo({x: nx, y: ny})


