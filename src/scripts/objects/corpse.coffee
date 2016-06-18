module.exports = class Corpse
  @hovered: null
  constructor: ({x,y, group, @side, @type}) ->
    spriteName = if @side == "left" then "soldier_blue" else "soldier_red"
    @sprite = game.add.sprite(x, y, spriteName, null, group)
    @sprite.frameName = "death_06.png"
    @sprite.anchor.set(0.5, 0.5)
    @sprite.inputEnabled = true
    @sprite.events.onInputOver.add =>
      Corpse.hovered = @
    @sprite.events.onInputOut.add =>
      if Corpse.hovered == @
        Corpse.hovered = null

  getX: -> @sprite.x
  getY: -> @sprite.y

  destroy: -> @sprite.destroy()

  canBeResurrectedAs: -> @type

  getResurrectOptions: ->
    x: @getX()
    y: @getY()
    side: @side