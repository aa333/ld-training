SPAWNING_RATES = [
  {soldier: 1, every: 6000, upgradeOn: 5},
  {soldier: 1, every: 5000, upgradeOn: 10},
  {soldier: 1, every: 4000, upgradeOn: 20},
  {soldier: 1, every: 3000, upgradeOn: 50},
  {soldier: 1, every: 1000, upgradeOn: 9999},
]

INITIAL_LUMBERING_AREA = 0.05


class Side
  constructor: (@baseWidth, @absFn)->
    @width = @baseWidth
    @lumberingInitialWidth = Math.floor(INITIAL_LUMBERING_AREA * @baseWidth)
    @lumberingWidth = @lumberingInitialWidth
    @lumberCollected = 0

    @spawningRateIdx = 0
    @lastSpawnTs = -SPAWNING_RATES[0].every-1000
    @killed = 0

    @unitsWidth = 0
    @unitsSum = 0

  spawningRate: -> SPAWNING_RATES[@spawningRateIdx]

  shallSpawn: (ts) ->
    ts - @lastSpawnTs >= @spawningRate().every

  canCut: (relativeX) ->
    @absFn(relativeX) <= @lumberingWidth

  onSpawn: (ts) ->
    @lastSpawnTs = ts

  onKill: ->
    @killed++

  onTreeCut: (relativeX) ->
    @lumberCollected++
    if @lumberCollected >= @spawningRate().upgradeOn
      @spawningRateIdx++

  updateEdge: (absX) ->
    @width = absX
    @lumberingWidth = Math.max(0, @width - @baseWidth + @lumberingInitialWidth) # + @lumberingActualEdge

  updatePositions: (positions) ->
    if positions.length > 0
      positions = positions.map(@absFn)
      @unitsWidth = Math.max.apply(null, positions)
      @unitsSum = positions.filter((p) => p > @width).reduce(((a,b) -> a+b), 0)
    else
      @unitsWidth = 0
      @unitsSum = 0


  getMovingRange: ->
    x1 = @absFn(@width - 1)
    x2 = @absFn(0)
    return [Math.min(x1,x2), Math.max(x1,x2)]

  getLumberingRange: ->
    x1 = @absFn(@lumberingWidth - 1)
    x2 = @absFn(0)
    return [Math.min(x1,x2), Math.max(x1,x2)]


class BattleModel

  constructor: (@width) ->
    @half = @width / 2
    @frontLineLeft = @half
    @left = new Side(@half, (x) -> x)
    @right = new Side(@half, (x) => @width - x - 1)
    @frontMovingSpeed = 0.5/1000

###### Here we calculate area for each side
  _recalculateAreas: (ts) ->
#@_recalculateAreas_usingKilled(ts)
#@_recalculateAreas_usingPositions(ts)
    @_recalculateAreas_usingPositionsSum(ts)

  _recalculateAreas_usingPositionsSum: (ts) ->
    return if not ts
    leftMost = @left.unitsSum
    rightMost = @right.unitsSum
    if leftMost > 0 || rightMost > 0
      if leftMost > rightMost
        target = Math.min(@left.absFn(@left.unitsWidth), @frontLineLeft + @frontMovingSpeed*ts)
      else
        target = Math.max(@right.absFn(@right.unitsWidth), @frontLineLeft - @frontMovingSpeed*ts)

      if target > @frontLineLeft
        @frontLineLeft += Math.min(target - @frontLineLeft, @frontMovingSpeed*ts)
      else
        @frontLineLeft -= Math.min(@frontLineLeft - target, @frontMovingSpeed*ts)

    @left.updateEdge(@frontLineLeft)
    @right.updateEdge(@width - @frontLineLeft)

  update: (ts) ->
    @_recalculateAreas(ts)

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

  onTreeCut: ({side, relativeX}) ->
    @[side].onTreeCut(relativeX)

  onKillBy: ({side}) ->
    @[side].onKill()
    @_recalculateAreas()

  updatePositions: (side, solds) ->
    @[side].updatePositions(solds)

  convert: (side, x) ->
    @[side].absFn(x)



module.exports = BattleModel