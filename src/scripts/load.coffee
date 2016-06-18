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
    game.load.atlas('objects', 'assets/objects.png', 'assets/objects.json')
    game.load.atlas('soldier_red', 'assets/soldier_red.png', 'assets/soldier.json')
    game.load.atlas('soldier_blue', 'assets/soldier_blue.png', 'assets/soldier.json')
    game.load.atlas('objects', 'assets/objects.png', 'assets/objects.json')
    game.load.atlas('ui', 'assets/ui.png', 'assets/ui.json')
    game.load.image('menu_splash', 'assets/menu_splash.jpg');
    game.load.image('button', 'assets/button.png');
    game.load.tilemap('testlvl', 'assets/testlvl.json', null, Phaser.Tilemap.TILED_JSON)
    game.load.image('tilemap_main', 'assets/tilemap_main.png')
    game.load.image('corpse', 'assets/corpse.png')
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
