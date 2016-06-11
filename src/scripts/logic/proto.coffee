SPAWNING_RATES = [
  {soldiers: 1, every: 60000, upgradeOn: 5},
  {soldiers: 1, every: 50000, upgradeOn: 10},
  {soldiers: 1, every: 40000, upgradeOn: 20},
  {soldiers: 1, every: 30000, upgradeOn: 50},
  {soldiers: 1, every: 10000, upgradeOn: 9999},
]

LUMBERING_SPEED = 2/1000    # 2 hp per sec
PIX_SIZE = 5
HEIGHT = 400/PIX_SIZE
WIDTH = 800/PIX_SIZE
CENTER = WIDTH/2
SHOOTING_DIST = 10
HIT_PROP = 0.5              #
HITPOINTS_DROP = 10         # hp per shoot
MOVING_SPEED = 1/1000       # 1 pix per sec
ZOMBIE_FACTOR = 0.5
OUTSIDE_FRONTLINE_FACTOR = 0.2
OUTSIDE_FRONTLINE_PROP = 0.3

FRONT_MOVING_SPEED = 0.001/1000

SOLDIER_HP = 100
ZOMBIE_HP = 1000
TREE_HP = 100
MAIN_TREE_HP = 300

INITIAL_LUMBERING_AREA = 0.05

ZOMBIE_HP_LOSS = 2/1000   # 2hp per sec

LEFT = (x) -> x
RIGHT = (x) -> 1 - x

conv =
  left: LEFT
  right: RIGHT

class Side
  constructor: (@absFn)->
    @edge = 0.5
    @lumberingMaxEdge = INITIAL_LUMBERING_AREA
    @lumberingActualEdge = 0
    @lumberCollected = 0

    @spawningRateIdx = 0
    @lastSpawnTs = 0
    @killed = 0

    @unitsEdge = 0
    @unitsEdgeSum = 0

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
    @lumberingMaxEdge = Math.max(0, @edge - 0.5 + INITIAL_LUMBERING_AREA) # + @lumberingActualEdge

  updatePositions: (positions) ->
    if positions.length > 0
      positions = positions.map(@absFn)
      @unitsEdge = Math.max.apply(null, positions)
      @unitsEdgeSum = positions.filter((p) => p > @edge).reduce(((a,b) -> a+b), 0)
    else
      @unitsEdge = 0
      @unitsEdgeSum = 0


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
  _recalculateAreas: (ts) ->
    #@_recalculateAreas_usingKilled(ts)
    #@_recalculateAreas_usingPositions(ts)
    @_recalculateAreas_usingPositionsSum(ts)

  _recalculateAreas_usingPositionsSum: (ts) ->
    return if not ts
    leftMost = @left.unitsEdgeSum
    rightMost = @right.unitsEdgeSum
    if leftMost > 0 || rightMost > 0
      if leftMost > rightMost
        target = Math.min(@left.unitsEdge, @frontLine + FRONT_MOVING_SPEED*ts)
      else
        target = Math.max(1 - @right.unitsEdge, @frontLine - FRONT_MOVING_SPEED*ts)

      if target > @frontLine
        @frontLine += Math.min(target - @frontLine, FRONT_MOVING_SPEED*ts)
      else
        @frontLine -= Math.min(@frontLine - target, FRONT_MOVING_SPEED*ts)

    @left.updateEdge(@frontLine)
    @right.updateEdge(@frontLine)

  _recalculateAreas_usingPositions: (ts) ->
    return if not ts
    leftMost = @left.unitsEdge
    rightMost = @right.unitsEdge
    if leftMost > 0.5 || rightMost > 0.5
      if leftMost > rightMost
        @frontLine = Math.min(leftMost, @frontLine + FRONT_MOVING_SPEED*ts)
      else
        @frontLine = Math.max(1 - rightMost, @frontLine - FRONT_MOVING_SPEED*ts)
    @left.updateEdge(@frontLine)
    @right.updateEdge(@frontLine)

  update: (ts) ->
    @_recalculateAreas(ts)

  _recalculateAreas_usingKilled: (ts) ->
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

  updatePositions: (side, solds) ->
    @[side].updatePositions(solds)




window.Proto = {
  init: ->
    model = new BattleModel()
    ctx = document.getElementById("canvas").getContext("2d")

    generate = (side, count) ->
      [0...count].map () -> {x: conv[side](0.1)*WIDTH, y: Math.random() * HEIGHT, side: side, health: SOLDIER_HP }

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
      ['left', 'right'].forEach (side) ->
        counts = model.getSpawnPlan({side}, totalTs)
        if counts.soldiers
          soldiers[side] = soldiers[side].concat(generate(side, counts.soldiers))
      allowed = model.getMovingRange()
      dxes = {
        left: +MOVING_SPEED*ts,
        right: -MOVING_SPEED*ts
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
          dx = dx * ZOMBIE_FACTOR
          s.health -= ZOMBIE_HP_LOSS*ts
        if s.health <= 0
          soldiers[s.side] = soldiers[s.side].filter((s1) -> s1 != s)
          return
        if inRange(s, s.x + dx)
          s.x += dx
        if not inRange(s, s.x + dx)
          if Math.random() < OUTSIDE_FRONTLINE_PROP
            s.x += dx*OUTSIDE_FRONTLINE_FACTOR


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

      model.updatePositions('left', soldiers.left.map(({x}) -> x/WIDTH))
      model.updatePositions('right', soldiers.right.map(({x}) -> x/WIDTH))
      model.update(ts)
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
        Model:
          frontLine: #{model.frontLine.toFixed(2)}
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