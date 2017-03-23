class Notifications extends Backbone.Model
  initialize: ->
    if DEBUG_MODE then global.notifications = @

  getController: (@Controller) ->
    @PM     = @Controller.Player.model
    @Field  = @Controller.Field
    @Server = @Controller.Server
    @info   = @Controller.information

    @achInBase = @info.achievments

  create: ->
    @show =
      everyday: -1
      friendsPlay: -1
      level: -1
      coins: -1
      countClick: -1
      forceEvil: -1
      forceGood: -1
      timeForEvil: -1
      timeForGood: -1
      countOfBots: -1
      playerDoubleStrWasUsed: -1
      botDoubleStrWasUsed: -1
      botDoubleSpeedWasUsed: -1

    @setListens()
    @check()

  setListens: ->
    @listenTo @PM, 'change:dateNow'    , @checkEveryday
    @listenTo @PM, 'change:level'      , @checkLevel
    @listenTo @PM, 'change:coins'      , @checkCoin
    @listenTo @PM, 'change:countClick' , @checkClick

    @listenTo @PM, 'change:forceEvil'  , @checkEvil
    @listenTo @PM, 'change:forceGood'  , @checkGood
    @listenTo @PM, 'change:timeForEvil', @checkTimeForEvil
    @listenTo @PM, 'change:timeForGood', @checkTimeForGood

    @listenTo @Controller, 'changeCountOfBots', @checkCountOfBots

    @listenTo @PM, 'change:playerDoubleStrWasUsed', @checkPlayerDoubleStr
    @listenTo @PM, 'change:botDoubleStrWasUsed'   , @checkBotDoubleStr
    @listenTo @PM, 'change:botDoubleSpeedWasUsed' , @checkBotDoubleSpeed

  checkLevel          : => @check 'level'
  checkCoin           : => @check 'coins'
  checkClick          : => @check 'countClick'
  checkEvil           : => @check 'forceEvil'
  checkGood           : => @check 'forceGood'
  checkTimeForEvil    : => @check 'timeForEvil'
  checkTimeForGood    : => @check 'timeForGood'
  checkCountOfBots    : => @check 'countOfBots'
  checkPlayerDoubleStr: => @check 'playerDoubleStrWasUsed'
  checkBotDoubleStr   : => @check 'botDoubleStrWasUsed'
  checkBotDoubleSpeed : => @check 'botDoubleSpeedWasUsed'

  arrAchievments: -> ['friendsPlay', 'level','coins','countClick','forceEvil','forceGood','timeForEvil','timeForGood', 'countOfBots', 'playerDoubleStrWasUsed','botDoubleStrWasUsed','botDoubleSpeedWasUsed']

  check: (name) ->
    arrAch = []

    if name
      return if not _.include @arrAchievments(), name
      arrAch.push name
    else
      arrAch = @arrAchievments()

    for nameAch in arrAch
      achPlayer = @PM.get("achievments")["#{nameAch}"] ? 0
      achInfo   = @achInBase["#{nameAch}"]

      continue if achPlayer >= _.size(achInfo)

      if nameAch == 'friendsPlay'
        if _.size( @PM.get("#{nameAch}") ) >= achInfo[achPlayer].task then @Field.ABC.showNotification()
      else
        count = null

        if nameAch == 'countOfBots'
          sum1 = _.reduce _.values(@PM.get('botCommon')), ((memo, num) => memo + num), 0
          sum2 = _.reduce _.values(@PM.get('botEvil')),   ((memo, num) => memo + num), 0
          sum3 = _.reduce _.values(@PM.get('botGood')),   ((memo, num) => memo + num), 0
          count = sum1 + sum2 + sum3

        count ?= @PM.get("#{nameAch}")

        _.each achInfo, (val, key) =>
          key = Number key

          if key >= achPlayer
            if count >= val.task
              if key > @show["#{nameAch}"]
                @Field.addAchInQueue nameAch, key
                @show["#{nameAch}"] = key

              @Field.ABC.showNotification()

    if not name? then @checkEveryday()

  checkEveryday: ->
    achEveryday  = @PM.get("achievments").everyday ? 0
    lastEveryday = @PM.get('lastEveryday')
    dateNow      = @PM.get('dateNow')

    diff = dateNow - lastEveryday

    if diff >= 1 * 60 * 60 * 24 * 2 and achEveryday != 0 # 2 days
      @Server.call '/resetEverydayAch', {}, (res) =>
        @Controller.trigger 'resetedEverydayAch'
    else if diff >= 1 * 60 * 60 * 24 * 1 # 1 days
      if achEveryday > @show.everyday
        @Field.addAchInQueue "everyday_#{achEveryday}_enabled", achEveryday
        @show.everyday = achEveryday

      @Field.ABC.showNotification()

module.exports = Notifications
