module.exports =
  opposite:
    left: 'right'
    right: 'left'
  direction:
    left: +1    # left side goes to the right - x++
    right: -1   # right side goes to the left - x--
  units:
    hero:
      speed: 200/1000
      animations:
        walk:
          sprites: (side) -> [1...5].map((i) => "walk_b_#{i}.png")
          loop: true
          rate: 1
        idle:
          sprites: (side) -> ["walk_b_1.png"]
          loop: false
          rate: 10
        resurrect:
          sprites: (side) -> [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10
        borrow:
          sprites: (side) -> [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10

    soldier:
      health: 100
      speed: 160/1000             # pixels per mssec
      damage: 10
      hitChance: 0.9
      healthLossRate: 0    # hits per mssec
      fireRadius: 100
      animations:
        walk:
          sprites: (side) -> [1...5].map((i) => "walk_b_#{i}.png")
          loop: true
          rate: 1
        idle:
          sprites: (side) -> ["walk_b_1.png"]
          loop: false
          rate: 10
        fire:
          sprites: (side) -> [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10
        fall:
          sprites: (side) -> [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10
      corpse: (side) -> 'corpse'
      resurrectAs: 'zombie'
    zombie:
      health: 300
      speed: 80/1000
      damage: 20
      hitChance: 0.25
      healthLossRate: 300/10000   # = 10 sec of life
      fireRadius: 100
      animations:
        walk:
          sprites: (side) ->  [1...5].map((i) => "walk_b_#{i}.png")
          loop: true
          rate: 1
        idle:
          sprites: (side) ->  ["walk_b_1.png"]
          loop: false
          rate: 10
        fire:
          sprites: (side) ->  [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10
        fall:
          sprites: (side) ->  [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10
        resurrect:
          sprites: (side) ->  [1...10].map((i) -> "walk_r_#{1+i%2}.png")
          loop: false
          rate: 10

