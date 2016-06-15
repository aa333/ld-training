module.exports = class Corpse
  @hovered: null
  constructor: ({x,y, group, @side, @type, image}) ->
    @sprite = game.add.sprite(x, y, image, null, group)
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