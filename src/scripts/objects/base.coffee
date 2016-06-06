Phaser = require('../phaser-shim.coffee')

module.exports = class Base
  @IDLE: 'idle'
  @WALK: 'walk'
  @FINDING: 'finding'

  constructor: ({x, y, group}) ->
    @sprite = game.add.sprite(x, y, 'sprites', undefined, group)
    @sprite.anchor.set(0.5, 0.5)
    @stop()
    @speed = 4
    @mstate = Base.IDLE


  walkTo: (npos) ->
    @stop()
    @_target = npos
    @mstate = @FINDING
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
      if distance < @speed
        @sprite.x = @_walkCell.x
        @sprite.y = @_walkCell.y
        @mstate = Base.FINDING
      else
        @sprite.x += @speed * (@_walkCell.x - @sprite.x) / distance
        @sprite.y += @speed * (@_walkCell.y - @sprite.y) / distance




  assignPathFinder: (pathfinder) ->
    @_pathfinder = pathfinder

  destroy: ->
    @_pathfinder?.destroy()