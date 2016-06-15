BattleModel = require('./battlemodel.coffee')
Commander = require('./commander.coffee')

class MockUnit
  constructor: ({@side, @x, @y, @health, @zombie}) ->
    @speedFactor = 1

  walkTo: ({x,y}) ->
    @nx = x
    @ny = y
    @busy = true

  stop: ->
    @busy = false

  update: (ts) ->
    if @nx and @nx != @x
      dir = if @nx > @x then +1 else -1
      @x += MOVING_SPEED*ts*dir*@speedFactor
      if Math.abs(@nx - @x) < 0.1
        @x = @nx
    if @ny and @ny != @y
      dir = if @ny > @y then +1 else -1
      @y += MOVING_SPEED*ts*dir*@speedFactor
      if Math.abs(@ny - @y) < 0.1
        @y = @ny
    if @nx == @x && @ny == @y
      @nx = null
      @ny = null
      @busy = false

  fire: (onComplete) ->
    onComplete?()
    @busy = false

  fall: (onComplete) ->
    onComplete?()

  getX: -> @x
  getY: -> @y

  isBusy: -> @busy

SOLDIER_HP = 100
ZOMBIE_HP = 1000
TREE_HP = 100
MAIN_TREE_HP = 300
ZOMBIE_HP_LOSS = 2/1000   # 2hp per sec

LUMBERING_SPEED = 2/1000    # 2 hp per sec
PIX_SIZE = 5
SHOOTING_DIST = 10
HIT_PROP = 0.5              #
HITPOINTS_DROP = 10         # hp per shoot
MOVING_SPEED = 1/1000       # 1 pix per sec
ZOMBIE_FACTOR = 0.5
OUTSIDE_FRONTLINE_FACTOR = 0.2
OUTSIDE_FRONTLINE_PROP = 0.3

HEIGHT = 400/PIX_SIZE
WIDTH = 800/PIX_SIZE
CENTER = WIDTH/2



window.Proto = {
  init: ->
    model = new BattleModel(WIDTH)
    ais =
      left: new Commander('left')
      right: new Commander('right')
    ctx = document.getElementById("canvas").getContext("2d")

    generate = (side, count) ->
      [0...count].map () ->  new MockUnit({x: model.convert(side, 4), y: Math.random() * HEIGHT, side, health: SOLDIER_HP} )

    soldiers = {
      left: generate('left', 4),
      right: generate('right', 4)
    }
    trees = [0...80].map -> { x: Math.random()*WIDTH, y: Math.random()*HEIGHT, health: TREE_HP }
    MainTree = {x: WIDTH/2, y: HEIGHT/2, health: MAIN_TREE_HP, main: true}
    trees.push(MainTree)
    shoots = []

    totalTs = 0

    running = true

    update = (ts) ->
      totalTs += ts

      shoots.forEach (s) ->
        s.ts--
        if s.ts == 0 and Math.random() < HIT_PROP
          s.to.health -= HITPOINTS_DROP
          if s.to.health <= 0
            soldiers[s.to.side] = soldiers[s.to.side].filter((s1) -> s1 != s.to)  # kill
            model.onKillBy(s.from)

      shoots = shoots.filter((s) -> s.ts > 0)



      ['left', 'right'].forEach (side) ->
        counts = model.getSpawnPlan({side}, totalTs)
        if counts.soldier
          soldiers[side] = soldiers[side].concat(generate(side, counts.soldier))
        ais[side].update(soldiers[side], {
          battlemodel: model,
          isEmpty: -> true
          getTileSize: -> 1
          getMovingRange: (side) -> model.getMovingRange()[side]
          getEnemies: (side) -> soldiers[{left: 'right', right: 'left'}[side]]
          getEnemiesToShoot: (s1) -> soldiers[{left: 'right', right: 'left'}[s1.side]].filter((s2) ->
            dx = s1.x - s2.x
            dy = s1.y - s2.y
            dx*dx+dy*dy < SHOOTING_DIST*SHOOTING_DIST
          )
          insideWorld: (x, y) ->
            x >= 0 and y >= 0 and x < WIDTH and y < HEIGHT
          shoot: (from, to) ->
            if Math.random() < 0.5
              shoots.push({from, to, ts: 1})
        })
        soldiers[side].forEach (s) -> s.update(ts)


      trees.forEach (tr) ->
        side = model.whoCanCutTreeAt(tr.x)
        if side
          tr.health -= LUMBERING_SPEED*ts
        if tr.health <= 0 and side
          model.onTreeCut({side, relativeX: tr.x})
      trees = trees.filter((tr) -> tr.health > 0)

      model.updatePositions('left', soldiers.left.map(({x}) -> x))
      model.updatePositions('right', soldiers.right.map(({x}) -> x))
      model.update(ts)
      if MainTree.health <= 0
        console.log('Game over')
        running = false




    render = ->
      ctx.clearRect(0, 0, 805, 400)
      ctx.fillStyle = 'rgba(255,0,0,0.2)';
      range = model.getMovingRange()
      ctx.fillRect(range.left[0]*PIX_SIZE, 0, (range.left[1] - range.left[0] + 1)*PIX_SIZE, 400)
      ctx.fillStyle = 'rgba(0,0,255,0.2)';
      ctx.fillRect(range.right[0]*PIX_SIZE, 0, (range.right[1] - range.right[0] + 1)*PIX_SIZE, 400)

      ctx.fillStyle = 'rgba(255,128,0,0.2)';
      range = model.getLumberingRange()
      ctx.fillRect(range.left[0]*PIX_SIZE, 0, (range.left[1] - range.left[0] + 1)*PIX_SIZE, 400)
      ctx.fillStyle = 'rgba(0,128,255,0.2)';
      ctx.fillRect(range.right[0]*PIX_SIZE, 0, (range.right[1] - range.right[0] + 1)*PIX_SIZE, 400)


      trees.forEach ({x,y,health, main}) ->
        if not main
          ctx.fillStyle = 'rgba(128,128,128,' + (health/100).toFixed(2) + ')'
          ctx.fillRect(x*PIX_SIZE, y*PIX_SIZE, PIX_SIZE, PIX_SIZE)
        else
          ctx.fillStyle = 'rgba(255,255,255,' + (health/300).toFixed(2) + ')'
          ctx.fillRect(x*PIX_SIZE-PIX_SIZE, y*PIX_SIZE-PIX_SIZE, PIX_SIZE*3, PIX_SIZE*3)


      ctx.fillStyle = 'red'
      soldiers.left.forEach (s) ->
        ctx.fillRect(s.x*PIX_SIZE, s.y*PIX_SIZE, PIX_SIZE, PIX_SIZE)
      ctx.fillStyle = 'blue'
      soldiers.right.forEach (s) ->
        ctx.fillRect(s.x*PIX_SIZE, s.y*PIX_SIZE, PIX_SIZE, PIX_SIZE)

      ctx.fillStyle = 'green'
      soldiers.left.concat(soldiers.right).forEach (s) ->
        if s.zombie
          ctx.fillRect(s.x*PIX_SIZE, s.y*PIX_SIZE, PIX_SIZE/2, PIX_SIZE/2)
      ctx.strokeStyle = 'yellow'
      ctx.beginPath()
      shoots.forEach ({from, to}) ->
        ctx.moveTo(from.x*PIX_SIZE, from.y*PIX_SIZE)
        ctx.lineTo(to.x*PIX_SIZE, to.y*PIX_SIZE)
      ctx.stroke()

      document.getElementById("st").innerHTML = """
        Left:
          lumbers: #{model.left.lumberCollected}
          killed: #{model.left.killed}
          spawnLevel: #{model.left.spawningRateIdx}
          edge: #{model.left.width.toFixed(2)}
          unitsEdge: #{model.left.unitsWidth.toFixed(2)}
          unitsEdgeSum: #{model.left.unitsSum.toFixed(2)}
        Right:
          lumbers: #{model.right.lumberCollected}
          killed: #{model.right.killed}
          spawnLevel: #{model.right.spawningRateIdx}
          edge: #{model.right.width.toFixed(2)}
          unitsEdge: #{model.right.unitsWidth.toFixed(2)}
          unitsEdgeSum: #{model.right.unitsSum.toFixed(2)}
        Model:
          frontLine: #{model.frontLineLeft.toFixed(2)}
      """

    step = ->
      update(500)
      render()

    stepTo = ->
      return if not running
      step()
      setTimeout(stepTo, 10)

    stepTo()

    document.getElementById("pause").addEventListener "click", ->
      running = false
    document.getElementById("resume").addEventListener "click", ->
      running = true
      stepTo()
    document.getElementById("step").addEventListener "click", ->
      step()
    document.getElementById("left").addEventListener "click", ->
      g = generate('left', 1)[0]
      g.zombie = true
      g.health = ZOMBIE_HP
      soldiers.left.push(g)
      render()

    document.getElementById("right").addEventListener "click", ->
      g = generate('right', 1)[0]
      g.zombie = true
      g.health = ZOMBIE_HP
      soldiers.right.push(g)
      render()
}