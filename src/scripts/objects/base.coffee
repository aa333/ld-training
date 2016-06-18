Phaser = require('../phaser-shim.coffee')

module.exports = class Base
  @IDLE: 'idle'
  @WALK: 'walk'
  @FINDING: 'finding'

  constructor: ({x, y, group}, spriteName) ->
    @sprite = game.add.sprite(x, y, spriteName, undefined, group)
    @sprite.anchor.set(0.5, 0.5)
    @animPostfix = 'side'
    @stop()
    @speed = 0.2
    @mstate = Base.IDLE
    @speedFactor = 1

  getX: -> @sprite.x
  getY: -> @sprite.y

  walkTo: (npos) ->
    @stop()
    @_target = npos
    @mstate = Base.FINDING
    @_pathfinder?.find npos.x, npos.y, =>
      if not @_pathfinder.path
        @mstate = Base.IDLE

  stop: ->
    @_target = null
    @_pathfinder?.stop()
    @mstate = Base.IDLE

  walk: ->

  update: ->
    @updateLogic()
    @updateMovement()

  updateLogic: ->
    #override

  inMove: -> @mstate != Base.IDLE

  updateMovement: ->
    if @mstate != Base.WALK and @_pathfinder?.path?
      if @_pathfinder.path.length == 0
        @_pathfinder?.path = null
        @stop()
      else
        @mstate = Base.WALK
        @walk()
        @_walkCell = @_pathfinder?.path?.shift()


    if @mstate == Base.WALK
      distance = Phaser.Math.distance(@sprite.x, @sprite.y, @_walkCell.x, @_walkCell.y)
      delta = game.time.elapsed * @speed * @speedFactor
      if distance < delta
        @sprite.x = @_walkCell.x
        @sprite.y = @_walkCell.y
        @mstate = Base.FINDING
      else
        dx = @_walkCell.x - @sprite.x
        dy = @_walkCell.y - @sprite.y
        oldPostfix = @animPostfix
        @turnSprite(dx, dy)
        if oldPostfix != @animPostfix
          @walk()
        @sprite.x += delta * (dx) / distance
        @sprite.y += delta * (dy) / distance

  turnSprite: (dx, dy) =>
    dx = Math.sign(dx)
    dy = Math.sign(dy)
    @animPostfix = if dy < 0 then "up" else "down"
    if dx != 0
      @animPostfix = "side"
      @sprite.scale.x = dx

  assignPathFinder: (pathfinder) ->
    @_pathfinder = pathfinder

  destroy: ->
    @_pathfinder?.destroy()