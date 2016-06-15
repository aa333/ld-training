Phaser = require('../phaser-shim.coffee')

module.exports = class Base
  @IDLE: 'idle'
  @WALK: 'walk'
  @FINDING: 'finding'

  constructor: ({x, y, group}) ->
    @sprite = game.add.sprite(x, y, 'sprites', undefined, group)
    @sprite.anchor.set(0.5, 0.5)
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
    @sprite.animations.play(Base.IDLE)



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
        @sprite.animations.play(Base.WALK)
        @_walkCell = @_pathfinder?.path?.shift()


    if @mstate == Base.WALK
      distance = Phaser.Math.distance(@sprite.x, @sprite.y, @_walkCell.x, @_walkCell.y)
      delta = game.time.elapsed * @speed * @speedFactor
      if distance < delta
        @sprite.x = @_walkCell.x
        @sprite.y = @_walkCell.y
        @mstate = Base.FINDING
      else
        @sprite.x += delta * (@_walkCell.x - @sprite.x) / distance
        @sprite.y += delta * (@_walkCell.y - @sprite.y) / distance




  assignPathFinder: (pathfinder) ->
    @_pathfinder = pathfinder

  destroy: ->
    @_pathfinder?.destroy()