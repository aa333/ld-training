SPAWNING_RATES = [
  {soldiers: 1, every: 10000, upgradeOn: 5},
  {soldiers: 1, every: 8000, upgradeOn: 10},
  {soldiers: 1, every: 5000, upgradeOn: 20},
  {soldiers: 1, every: 2000, upgradeOn: 50},
  {soldiers: 1, every: 1000, upgradeOn: 9999},
]

LUMBERING_SPEED = 2/1000    # 2 hp per sec
PIX_SIZE = 5
HEIGHT = 400/PIX_SIZE
WIDTH = 800/PIX_SIZE
CENTER = WIDTH/2
SHOOTING_DIST = 10
HIT_PROP = 0.5              #
HITPOINTS_DROP = 10         # hp per shoot

LEFT = (x) -> x
RIGHT = (x) -> 1 - x

conv =
  left: LEFT
  right: RIGHT

class Side
  constructor: (@absFn)->
    @edge = 0.5
    @lumberingMaxEdge = 0.0
    @lumberingActualEdge = 0
    @lumberCollected = 0

    @spawningRateIdx = 0
    @lastSpawnTs = 0
    @killed = 0

  spawningRate: -> SPAWNING_RATES[@spawningRateIdx]

  shallSpawn: (ts) ->
    ts - @lastSpawnTs >= @spawningRate().every

  canCut: (relativeX) ->
    @absFn(relativeX) <= @lumberingMaxEdge

  onSpawn: (ts) ->
    @lastSpawnTs = ts

  onKill: ->
    @killed++

  onTreeCut: (relativeX) ->
    @lumberingActualEdge = Math.max(@lumberingActualEdge, @absFn(relativeX))
    @lumberCollected++
    if @lumberCollected >= @spawningRate().upgradeOn
      @spawningRateIdx++

  updateEdge: (relativeX) ->
    @edge = @absFn(relativeX)
    @lumberingMaxEdge = Math.max(0, @edge - 0.5) # + @lumberingActualEdge


  getMovingRange: ->
    x1 = @absFn(@edge)
    x2 = @absFn(0)
    return [Math.min(x1,x2), Math.max(x1,x2)]

  getLumberingRange: ->
    x1 = @absFn(@lumberingMaxEdge)
    x2 = @absFn(0)
    return [Math.min(x1,x2), Math.max(x1,x2)]



class BattleModel

  constructor: ->
    @frontLine = 0.5
    @left = new Side(LEFT)
    @right = new Side(RIGHT)

  ###### Here we calculate area for each side
  _recalculateAreas: ->
    diffInKills = @right.killed - @left.killed
    totalKills = @right.killed + @left.killed
    @frontLine = 0.5 - Math.max(-0.5, Math.min(0.5, diffInKills / Math.max(40, totalKills)))
    @left.updateEdge(@frontLine)
    @right.updateEdge(@frontLine)


  whoCanCutTreeAt: (relativeX) ->
    ['left','right'].filter((side) => @[side].canCut(relativeX))[0]

  getSpawnPlan: ({side}, ts) ->
    if @[side].shallSpawn(ts)
      @[side].onSpawn(ts)
      return @[side].spawningRate()
    return {}

  getMovingRange: -> {
    left: @left.getMovingRange()
    right: @right.getMovingRange()
  }

  getLumberingRange: ->
    left: @left.getLumberingRange()
    right: @right.getLumberingRange()

  getStatus: -> {
    leftLumbering: @left.lumberingMaxEdge,
    center: @frontLine,
    rightLumbering: @right.lumberingMaxEdge
  }

  onTreeCut: ({side, relativeX}) ->
    @[side].onTreeCut(relativeX)

  onKillBy: ({side}) ->
    @[side].onKill()
    @_recalculateAreas()





window.Proto = {
  init: ->
    model = new BattleModel()
    ctx = document.getElementById("canvas").getContext("2d")

    generate = (side, count) ->
      [0...count].map () -> {x: conv[side](0.1)*WIDTH, y: Math.random() * HEIGHT, side: side, health: 100 }

    soldiers = {
      left: generate('left', 4),
      right: generate('right', 4)
    }
    trees = [0...80].map -> { x: Math.random()*WIDTH, y: Math.random()*HEIGHT, health: 100 }
    MainTree = {x: WIDTH/2, y: HEIGHT/2, health: 300, main: true}
    trees.push(MainTree)
    shoots = []

    totalTs = 0

    running = true

    update = (ts) ->
      totalTs += ts
      ['left', 'right'].forEach (side) ->
        counts = model.getSpawnPlan({side}, totalTs)
        if counts.soldiers
          soldiers[side] = soldiers[side].concat(generate(side, counts.soldiers))
      allowed = model.getMovingRange()
      dxes = {
        left: +1,
        right: -1
      }
      inRange = (s, x) ->
        allowed[s.side][0]*WIDTH <= x and allowed[s.side][1]*WIDTH >= x

      shoots.forEach (s) ->
        s.ts--
        if s.ts == 0 and Math.random() < HIT_PROP
          s.to.health -= HITPOINTS_DROP
          if s.to.health <= 0
            soldiers[s.to.side] = soldiers[s.to.side].filter((s1) -> s1 != s.to)  # kill
            model.onKillBy(s.from)

      shoots = shoots.filter((s) -> s.ts > 0)

      soldiers.left.concat(soldiers.right).forEach (s) ->
        dx = dxes[s.side]
        if s.zombie
          dx = dx / 2
        if inRange(s, s.x + dx)
          s.x += dx
        if not inRange(s, s.x)
          s.x -= dx

      # shooting
      soldiers.left.forEach (s1) ->
        soldiers.right.forEach (s2) ->
          dx = s1.x - s2.x
          dy = s1.y - s2.y
          if dx*dx+dy*dy < SHOOTING_DIST*SHOOTING_DIST
            if Math.random() < 0.5
              shoots.push({from: s1, to: s2, ts: 1})
            else
              shoots.push({from: s2, to: s1, ts: 1})

      trees.forEach (tr) ->
        side = model.whoCanCutTreeAt(tr.x / WIDTH)
        if side
          tr.health -= LUMBERING_SPEED*ts
        if tr.health <= 0 and side
          model.onTreeCut({side, relativeX: tr.x / WIDTH})
      trees = trees.filter((tr) -> tr.health > 0)

      if MainTree.health <= 0
        console.log('Game over')
        running = false




    render = ->
      ctx.clearRect(0, 0, 805, 400)
      ctx.fillStyle = 'rgba(255,0,0,0.2)';
      range = model.getMovingRange()
      ctx.fillRect(range.left[0]*800, 0, range.left[1]*800, 400)
      ctx.fillStyle = 'rgba(0,0,255,0.2)';
      ctx.fillRect(range.right[0]*800, 0, range.right[1]*800, 400)

      ctx.fillStyle = 'rgba(255,128,0,0.2)';
      range = model.getLumberingRange()
      ctx.fillRect(range.left[0]*800, 0, range.left[1]*800, 400)
      ctx.fillStyle = 'rgba(0,128,255,0.2)';
      ctx.fillRect(range.right[0]*800, 0, range.right[1]*800, 400)


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
        Right:
          lumbers: #{model.right.lumberCollected}
          killed: #{model.right.killed}
          spawnLevel: #{model.right.spawningRateIdx}
      """

    step = ->
      update(500)
      render()

    stepTo = ->
      return if not running
      step()
      setTimeout(stepTo, 50)

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
      g.health = 300
      soldiers.left.push(g)
      render()

    document.getElementById("right").addEventListener "click", ->
      g = generate('right', 1)[0]
      g.zombie = true
      g.health = 300
      soldiers.right.push(g)
      render()


}