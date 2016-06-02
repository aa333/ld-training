# Init game state. Preloads the preloader.

module.exports = 
    init: () ->
    preload: () ->
        game.time.advancedTiming = true
        game.load.image('loading', 'assets/loading.png');
        game.load.image('load_progress_bar', 'assets/progress_bar_bg.png');
        game.load.image('load_progress_bar_dark', 'assets/progress_bar_fg.png');
    create: () ->
        game.state.start('load');

