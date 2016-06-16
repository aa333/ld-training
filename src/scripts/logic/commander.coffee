{opposite, direction} = require('../common.coffee')

distance = (u1, u2) ->
  Math.abs(u1.getX() - u2.getX()) + Math.abs(u1.getY() - u2.getY())

directionTo = (x1, x2) ->
  if x2 > x1
    +1
  else if x2 < x1
    -1
  else
    0

shortestDirection = (u1, u2) ->
  dx = u2.getX() - u1.getX()
  dy = u2.getY() - u1.getY()
  if dy == 0
    {dx: directionTo(u1.getX(), u2.getX()), dy: 0}
  else if dx == 0
    {dy: directionTo(u1.getY(), u2.getY()), dx: 0}
  else if Math.abs(dx) > Math.abs(dy)
    {dx: Math.floor(dx / Math.abs(dy)), dy: dy / Math.abs(dy) }
  else
    {dy: Math.floor(dy / Math.abs(dx)), dx: dx / Math.abs(dx) }

module.exports = class Commander
  constructor: (@side) ->

  update: (units, helper) ->
    range = helper.getMovingRange(@side)
    enemies = helper.getEnemies(@side)
    units.forEach (u) =>
      if u.getX() < range[0] or u.getX() > range[1]
        u.speedFactor = 0.2
      else
        u.speedFactor = 1
      return if u.isBusy()
      toShoot = helper.getEnemiesToShoot(u)[0]
      closestEnemy = enemies.map((e) -> {enemy: e, dist: distance(e, u)}).sort((a,b) -> a.dist-b.dist)[0]?.enemy
      if toShoot
        helper.shoot(u, toShoot)
        return
      else if closestEnemy
        {dx, dy} = shortestDirection(u, closestEnemy)
      else
        dx = direction[@side]
        dy = 0
      nx = u.getX() + dx*helper.getTileSize()
      ny = u.getY() + dy*helper.getTileSize()
      while helper.insideWorld(nx, ny) and not helper.isEmpty(nx, ny)
        nx += helper.getTileSize()*dx
      if helper.insideWorld(nx, ny)
        u.walkTo({x: nx, y: ny})


  update_old: (units, helper) ->
    range = helper.getMovingRange(@side)
    units.forEach (u) =>
      return if u.isBusy()
      enemies = helper.getEnemiesToShoot(u)
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


