Phaser = require('./phaser-shim.coffee')

module.exports =
  init: () ->
  create: () ->
    console.log("congratulations")
    style = { font: "65px Arial", fill: "#ffffff", align: "center" };
    text = game.add.text(200, 150, "You win!", style);
    text.anchor.set(0.5);


