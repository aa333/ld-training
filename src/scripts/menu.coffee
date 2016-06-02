# Main menu state

module.exports =
  create: () ->
    console.log("creating menu")
    game.add.sprite(0, 0, 'menu_splash')
    start = game.add.sprite(560, 500, 'button')
    start.inputEnabled = true
    start.input.useHandCursor = true
    start.events.onInputUp.add(() ->
      game.state.start "play"
    )
