GS = require '../gameSettings.json'
Notifications = require "./notifications.coffee"

class PlayerModel extends Backbone.Model
  getController: (@Controller) ->
    @Player = @Controller.Player
    @Field  = @Controller.Field
    @Server = @Controller.Server
    @info   = @Controller.information

  setData: ->
    _.each @Controller.dataFirst.user, (value, key) =>
      @set "#{key}", value

  create: ->
    @set 'isOpenForce', false

    @Notifications = new Notifications
    @Notifications.getController @Controller
    @Notifications.create()

    @recalcMaxExp()
    @recalcPowerUp()

    @saveLastSaveDate()
    @saveUser()
    @startInterval()

  saveLastSaveDate: -> @lastSaveDate = @get 'saveDate'

  startInterval: ->
    oneSec = =>
      @set "dateNow", @get("dateNow") + 1

      @timeForForce()
      @addForcesDueToBots()
      @decrementBoosterTime()

    @interval1 = setInterval oneSec , 1000, oneSec()

  timeForForce: ->
    if @get("forceEvil") > @get("forceGood")
      @set "timeForEvil", @get("timeForEvil") + 1
    if @get("forceGood") > @get("forceEvil")
      @set "timeForGood", @get("timeForGood") + 1

  addForcesDueToBots: ->
    return if @get('level') < @get('levelOpenForce')

    sum1 = _.reduce _.values(@get('botEvil')), ((memo, num) => memo + num), 0
    sum2 = _.reduce _.values(@get('botGood')), ((memo, num) => memo + num), 0

    if not @Field.model.checkCloseForceEvil()
      newEvil = sum1 * 0.1
      @Player.renderForceUp newEvil, 'evil'
      @forceEvilAdd newEvil

    if not @Field.model.checkCloseForceGood()
      newGood = sum2 * 0.1
      @Player.renderForceUp newGood, 'good'
      @forceGoodAdd newGood

    @Field.switchShowBtnAllForces()

  decrementBoosterTime: ->
    @set("playerDoubleStrTime", @get("playerDoubleStrTime") - 1) if @get("playerDoubleStrTime") >= 0
    @set("botDoubleStrTime", @get("botDoubleStrTime") - 1) if @get("botDoubleStrTime") >= 0
    @set("botDoubleSpeedTime", @get("botDoubleSpeedTime") - 1) if @get("botDoubleSpeedTime") >= 0


  ##########


  playerClickController: ->
    @incCountClick()
    @playerClick()

  playerClick: ->
    powerUp = @get("powerUp")
    if @get("playerDoubleStrTime") > 0
      powerUp *= 2

    @addExp powerUp

  getNewLevel: ->
    addLevel = if @get('level') == 1 then 5 else @get('level') + 5

    newLevel = prompt "Каким уровнем желаешь стать?", addLevel
    if _.isNull(newLevel) then return
    newLevel = Number newLevel

    while newLevel <= @get('level')
      alert 'Должен быть больше текущего'
      newLevel = prompt "Каким уровнем желаешь стать?", addLevel
      if _.isNull(newLevel) then return
      newLevel = Number newLevel

    addExp = -@get 'exp'
    for num in [@get('level') ... newLevel]
      addExp += @getMaxExp num

    @addExp addExp

  addExp: (exp) ->
    nextExp = @Controller.setFixed @get("exp") + exp
    @set "totalExp", @get('totalExp') + exp

    @checkLvlUp nextExp

  checkLvlUp: (nextExp) ->
    if nextExp >= @get("maxExp")
      @levelUp nextExp
      @Controller.checkShowHidden()
    else
      @set "exp", nextExp

  levelUp: (nextExp) ->
    maxExp = @getMaxExp @get('level')

    level = 0

    while nextExp >= maxExp
      nextExp = nextExp - maxExp

      level += 1
      maxExp = @getMaxExp(@get('level') + level)

    @incLevel level
    @set 'exp', nextExp

    @recalcMaxExp()
    @recalcPowerUp()
    @recalcForceUp()

  forceEvilAdd: (add) ->
    add ?= @get("forceEvilUp")
    res = @get("forceEvil") + add
    @set "forceEvil", @Controller.setFixed res
    @recalcForceUp()

  forceGoodAdd: (add) ->
    add ?= @get("forceGoodUp")
    res = @get("forceGood") + add
    @set "forceGood", @Controller.setFixed res
    @recalcForceUp()

  playerDoubleStr: (cb) ->
    return if @get("playerDoubleStrTime") > 0
    return if @get("playerDoubleStr") <= 0
    cb?()
    @set "playerDoubleStr", @get("playerDoubleStr") - 1
    @set "playerDoubleStrWasUsed", @get("playerDoubleStrWasUsed") + 1
    @set "playerDoubleStrTime", @get 'playerDoubleStrTimePlus'

  botDoubleStr: (cb) ->
    return if @get("botDoubleStrTime") > 0
    return if @get("botDoubleStr") <= 0
    cb?()
    @set "botDoubleStr", @get("botDoubleStr") - 1
    @set "botDoubleStrWasUsed", @get("botDoubleStrWasUsed") + 1
    @set "botDoubleStrTime", @get 'botDoubleStrTimePlus'

  botDoubleSpeed: (cb) ->
    return if @get("botDoubleSpeedTime") > 0
    return if @get("botDoubleSpeed") <= 0
    cb?()
    @set "botDoubleSpeed", @get("botDoubleSpeed") - 1
    @set "botDoubleSpeedWasUsed", @get("botDoubleSpeedWasUsed") + 1
    @set "botDoubleSpeedTime", @get 'botDoubleSpeedTimePlus'

  showHidden: ->
    if @get('level') >= @get('levelOpenForce') and not @get('isOpenForce')
      @set 'isOpenForce', true
      @recalcBots()
      @startBot()
      @recalcForceUp()
      @Player.showHiddenForce()

  startBot: ->
    i = =>
      botStr = @get("botStr")
      if @get("botDoubleStrTime") > 0
        botStr *= 2

      @Player.renderNumberUp()
      @addExp botStr

      speed = @get("botSpeed")
      if @get("botDoubleSpeedTime") > 0
        speed *= 2

      _.delay i, 1000 / speed

    i()


  ##########


  recalcPowerUp: -> @set 'powerUp', @recalcPowerUpClick() + @recalcPowerUpThing()

  recalcPowerUpClick: -> @Controller.setFixed @get('level')
  recalcPowerUpThing: -> 0    #TODO

  recalcExp: ->
    saveDate = @lastSaveDate
    dateNow  = @get 'dateNow'
    botStr   = @get 'botStr'
    botSpeed = @get 'botSpeed'

    return if not saveDate? or not dateNow? or not botStr? or not botSpeed?

    invisibleExp = (dateNow - saveDate ) * botSpeed * botStr

    invisibleExp = @Controller.setFixed invisibleExp

    @Player.renderNumberUp null, invisibleExp, true
    @addExp invisibleExp

  recalcTimeForces: ->
    saveDate = @lastSaveDate
    dateNow  = @get 'dateNow'

    diffTime = dateNow - saveDate

    if @get('forceEvil') > @get('forceGood')
      @set('timeForEvil', @get('timeForEvil') + diffTime)
    if @get('forceGood') > @get('forceEvil')
      @set('timeForGood', @get('timeForGood') + diffTime)

  recalcForcesDueToBots: ->
    return if @get('level') < @get('levelOpenForce')

    saveDate = @lastSaveDate
    dateNow  = @get 'dateNow'

    diffTime = dateNow - saveDate

    sum1 = _.reduce _.values(@get('botEvil')),   ((memo, num) => memo + num), 0
    sum2 = _.reduce _.values(@get('botGood')),   ((memo, num) => memo + num), 0

    if not @Field.model.checkCloseForceEvil()
      newEvil = sum1 * diffTime * 0.1
      maxEvil = @Field.model.checkCloseForceEvil true
      if newEvil + @get('forceEvil') > maxEvil and maxEvil
        @forceEvilAdd maxEvil - @get('forceEvil')
        @Player.renderForceUp maxEvil - @get('forceEvil'), 'evil', true
      else
        @forceEvilAdd newEvil
        @Player.renderForceUp newEvil, 'evil', true

    if not @Field.model.checkCloseForceGood()
      newGood = sum2 * diffTime * 0.1
      maxGood = @Field.model.checkCloseForceGood true
      if newGood + @get('forceGood') > maxGood and maxGood
        @forceGoodAdd maxGood - @get('forceGood')
        @Player.renderForceUp maxGood - @get('forceGood'), 'good', true
      else
        @forceGoodAdd newGood
        @Player.renderForceUp newGood, 'good', true

  getMaxExp: (level) ->
    if level == 1
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 5
    else if 1 < level <= 5
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 2
    else if 5 < level <= 15
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 2
    else if 15 < level <= 20
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 3
    else if 20 < level <= 30
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 4
    else if 30 < level <= 40
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 5
    else if 40 < level <= 50
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 6
    else if 50 < level <= 60
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 7
    else if 60 < level <= 70
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 8
    else if 70 < level <= 80
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 9
    else
      @Controller.setFixed Math.pow((((level + 1) * level ) / 2), 2) * 10

  recalcMaxExp: -> @set 'maxExp', @getMaxExp(@get('level'))

  recalcBots: ->
    botStr   = 0
    botSpeed = 0

    for key, val of @info.shop.bot
      if val.force == 'common' and _.contains _.keys( @get('botCommon') ), val.grade then break
      if val.force == 'evil'   and _.contains _.keys( @get('botEvil')   ), val.grade then break
      if val.force == 'good'   and _.contains _.keys( @get('botGood')   ), val.grade then break

      force = val.force.charAt(0).toUpperCase() + val.force.substr(1)
      bot = @get("bot#{force}")
      level = bot[val.grade]

      if val.str? and level > 0
        for n in [1 .. level]
          if n == 1
            botStr += val.str.botStr
          else
            botStr += val.str.botStrStep

      if val.speed? and level > 0
        for n in [1 .. level]
          if n == 1
            botSpeed += val.speed.botSpeed
          else
            botSpeed += val.speed.botSpeedStep


    @set 'botStr', @Controller.setFixed botStr
    @set 'botSpeed', @Controller.setFixed botSpeed

    @Player.renderBots()

  recalcForceUp: ->
    forceEvilUpMinus = 0
    forceGoodUpMinus = 0
    forceEvilUpPlus  = 0
    forceGoodUpPlus  = 0

    if @get('forceGood') > @get('forceEvil')
      diff = @Player.model.get("forceGood") - @Player.model.get("forceEvil")
      forceEvilUpMinus = 100 / GS.limit * diff

    if @get('forceEvil') > @get('forceGood')
      diff = @Player.model.get("forceEvil") - @Player.model.get("forceGood")
      forceGoodUpMinus = 100 / GS.limit * diff

    forceUp = @Controller.setFixed @get('level')

    resEvil = forceUp + forceEvilUpPlus - forceEvilUpMinus
    if resEvil < 1 then resEvil = 1
    @set 'forceEvilUp', Math.round resEvil

    resGood = forceUp + forceGoodUpPlus - forceGoodUpMinus
    if resGood < 1 then resGood = 1
    @set 'forceGoodUp', Math.round resGood

  incCountClick: -> @set 'countClick', @get('countClick') + 1
  incLevel     : (val) -> @set 'level', @get('level') + val


  ##########


  saveUser: (cb) =>
    clearTimeout @saveUserTimeout if @saveUserTimeout?
    @saveUserTimeout = null

    exp                    = @get 'exp'
    totalExp               = @get 'totalExp'
    level                  = @get 'level'
    countClick             = @get 'countClick'
    forceEvil              = @get 'forceEvil'
    forceGood              = @get 'forceGood'
    timeForEvil            = @get 'timeForEvil'
    timeForGood            = @get 'timeForGood'
    forceEvilDiff          = forceEvil - @get 'forceEvilOld'
    forceGoodDiff          = forceGood - @get 'forceGoodOld'
    playerDoubleStr        = @get 'playerDoubleStr'
    botDoubleStr           = @get 'botDoubleStr'
    botDoubleSpeed         = @get 'botDoubleSpeed'
    playerDoubleStrWasUsed = @get 'playerDoubleStrWasUsed'
    botDoubleStrWasUsed    = @get 'botDoubleStrWasUsed'
    botDoubleSpeedWasUsed  = @get 'botDoubleSpeedWasUsed'
    saveDate               = @get 'dateNow'

    @set 'saveDate'    , saveDate
    @set 'forceEvilOld', forceEvil
    @set 'forceGoodOld', forceGood

    req = { 'exp': exp, 'totalExp': totalExp, 'level': level, 'countClick': countClick, 'forceEvil': forceEvil, 'forceGood': forceGood, 'forceEvilDiff', forceEvilDiff, 'forceGoodDiff', forceGoodDiff, 'timeForEvil': timeForEvil, 'timeForGood': timeForGood, 'playerDoubleStr': playerDoubleStr, 'botDoubleStr': botDoubleStr, 'botDoubleSpeed': botDoubleSpeed, 'playerDoubleStrWasUsed': playerDoubleStrWasUsed, 'botDoubleStrWasUsed': botDoubleStrWasUsed, 'botDoubleSpeedWasUsed': botDoubleSpeedWasUsed, 'saveDate': saveDate }

    @Server.call '/save', req, (res) =>
      @saveUserTimeout = setTimeout @saveUser, 5000
      cb?()

module.exports = PlayerModel
