Phaser = require('../phaser-shim.coffee')

class TreeBase extends Phaser.Sprite
    constructor: (x, y, frame, @health) ->
        super(game, x, y, 'objects', frame)
        @anchor.x = 0.5
        @anchor.y = 0.9
        @inputEnabled = true
        @input.useHandCursor = true
        @events.onInputUp.add(() =>
            @chop()
        )
    chop: () ->
        emitter = game.add.emitter(@x, @y, 40);
        emitter.gravity = 100;
        emitter.makeParticles('particles', [0,1,2],40,false,false)
        emitter.start(true,500,null,40)
        game.time.events.add(2000, emitter.destroy, emitter)
        @frameName = @stumpFrame


class SmallTree extends TreeBase
    stumpFrame: "tree_small_stump.png"
    constructor: (x, y) ->
        super(x, y, 'tree_small.png', 50)

class BigTree extends TreeBase
    stumpFrame: "tree_big_stump.png"
    constructor: (x, y) ->
        super(x, y, 'tree_big.png', 100)

class OldOak extends TreeBase
    stumpFrame: "tree_main_stump.png"
    constructor: (x, y) ->
        super(x, y, 'tree_main.png', 400)
        @anchor.y = 0.8        


module.exports.Small = SmallTree
module.exports.Big = BigTree
module.exports.OldOak = OldOak