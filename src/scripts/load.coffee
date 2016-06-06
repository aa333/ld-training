# Preloader game state. Loads the assets, displays progress

module.exports =
  loadingLabel: ->
    #Here we add a label to let the user know we are loading everything
    @loading = game.add.sprite(game.world.centerX, game.world.centerY - 20, "loading")
    @loading.anchor.setTo 0.5, 0.5
    
    #This is the bright blue bar that is hidden by the dark bar
    @barBg = game.add.sprite(game.world.centerX, game.world.centerY + 40, "load_progress_bar")
    @barBg.anchor.setTo 0.5, 0.5
    
    #This bar will get cropped by the setPreloadSprite function as the game loads!
    @bar = game.add.sprite(game.world.centerX - 192, game.world.centerY + 40, "load_progress_bar_dark")
    @bar.anchor.setTo 0, 0.5
    game.load.setPreloadSprite @bar

  preload: ->
    @loadingLabel()
    
    #Add here all the assets that you need to game.load
    game.load.atlas('sprites', 'assets/sprites.png', 'assets/sprites.json')
    game.load.image('menu_splash', 'assets/menu_splash.jpg');
    game.load.image('button', 'assets/button.png');
    game.load.tilemap('test1', 'assets/test1.json', null, Phaser.Tilemap.TILED_JSON)
    game.load.image('tileset', 'assets/tilemap.png')
    console.log("loaded assets")

  create: ->
    game.state.start "play"

# window.WebFontConfig =
# #'active' means all requested fonts have finished loading
# #We set a 1 second delay before calling 'createText'.
# #For some reason if we don't the browser cannot render the text the first time it's created.
#   active: () ->
# #The Google Fonts we want to load (specify as many as you like in the array)
#   google:
#     families: ['Revalia']
