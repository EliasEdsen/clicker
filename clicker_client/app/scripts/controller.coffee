GS = require './gameSettings.json'

Server = require "./server/server.coffee"
API    = require "./server/api.coffee"

BackgroundView  = require "./layers/backgroundView.coffee"
BackgroundModel = require "./layers/backgroundModel.coffee"

LowLayerView  = require "./layers/emptyView.coffee"
LowLayerModel = require "./layers/emptyModel.coffee"

FieldView  = require "./field/fieldView.coffee"
FieldModel = require "./field/fieldModel.coffee"

MediumLayerView  = require "./layers/emptyView.coffee"
MediumLayerModel = require "./layers/emptyModel.coffee"

PlayerView  = require "./player/playerView.coffee"
PlayerModel = require "./player/playerModel.coffee"

UpperLayerView  = require "./layers/emptyView.coffee"
UpperLayerModel = require "./layers/emptyModel.coffee"

Blackout = require './blackout.coffee'

class Controller extends Backbone.Model
  initialize: ->
    if DEBUG_MODE then global.controller = @

  getDataFirst: (@dataFirst) ->

  includeAll: ->
    # подключим всё
    $.getJSON './sprites/sprite.json', {}, (json) =>
      global.sprites = json

      @Background     = new BackgroundView model: new BackgroundModel
      @LowLayer     = new LowLayerView model: new LowLayerModel
      @Field        = new FieldView  model: new FieldModel
      @MediumLayer  = new MediumLayerView model: new MediumLayerModel
      @Player       = new PlayerView model: new PlayerModel
      @UpperLayer   = new UpperLayerView model: new UpperLayerModel
      @Blackout     = new Blackout

      @windows = require './windows/windowsController.coffee'

      @Server = new Server
      @API = new API

      @information = @dataFirst.info

      @Background.getController @
      @Background.model.getController @

      @LowLayer.getController @
      @LowLayer.model.getController @

      @Field.getController @
      @Field.model.getController @

      @MediumLayer.getController @
      @MediumLayer.model.getController @

      @Player.getController @
      @Player.model.getController @

      @UpperLayer.getController @
      @UpperLayer.model.getController @

      @Blackout.getController @

      @Server.getController @
      @API.getController @

      @windows.getController @

      @Player.model.setData()
      @createAll()

  createAll: ->
    @Background.create()
    @LowLayer.create()
    @Field.create()
    @MediumLayer.create()
    @Player.create()
    @UpperLayer.create()
    @Blackout.create()

    @Background.render()
    @LowLayer.render()
    @Field.render()
    @MediumLayer.render()
    @Player.render()
    @UpperLayer.render()
    @Blackout.render()

    @checkShowHidden()

    @Field.switchShowBtnAllForces()

    hide = =>
      $(".loader").hide().remove()

    _.delay hide, 1000

    Sound.setVolume("music", @Player.model.get("music"))
    Sound.setVolume("sound", @Player.model.get("sound"))

    @setListens()

    @Player.model.recalcExp()
    @Player.model.recalcTimeForces()
    @Player.model.recalcForcesDueToBots()
    @changeMusic()

  setListens: ->
    @listenTo @Player.model, 'change:music', @changeMusicVolume
    @listenTo @Player.model, 'change:sound', @changeSoundVolume

  changeMusic: ->
    back = @Background.model.getBackground()
    diff = 2870 - back

    aPercent = 100 / 2870
    percent  = aPercent * diff

    # evil
    if -100 <= percent <= -75
      Sound.playMusic("music_-3")
    if -75 < percent <= -50
      Sound.playMusic("music_-2")
    if -50 < percent <= -25
      Sound.playMusic("music_-1")
    # neutral
    if -25 < percent < 25
      Sound.playMusic("music_0")
    # good
    if 25 <= percent < 50
      Sound.playMusic("music_1")
    if 50 <= percent < 75
      Sound.playMusic("music_2")
    if 75 <= percent <= 100
      Sound.playMusic("music_3")

  changeMusicVolume: ->
    Sound.setVolume("music", @Player.model.get("music"))

    i = =>
      music = @Player.model.get "music"

      req = { "music": music}
      @Server.call "/save", req

    clearTimeout @musicTimerSave if @musicTimerSave?
    @musicTimerSave = null
    @musicTimerSave = setTimeout(i, 5000)

  changeSoundVolume: ->
    Sound.setVolume("sound", @Player.model.get("sound"))

    i = =>
      sound = @Player.model.get "sound"

      req = { "sound": sound}
      @Server.call "/save", req

    clearTimeout @soundTimerSave if @soundTimerSave?
    @soundTimerSave = null
    @soundTimerSave = setTimeout(i, 5000)

  ######

  showError: (err) ->
    $('.errorBlock').show()
    if not err.message? then err.message = 'Что то пошло не так :(' # нет сети у юзера
    $('.errorBlock').find('.message').html(err.message)

  ######

  setFixed: (val, count = 1) ->
    result = val.toFixed count
    result = Number result
    result

  changeNumber: (val, int = false, force = false) ->
    return if not val?

    size = Number val
    size = val.toFixed().toString().length

    if size < 7
      if int and (@Player.model.get('level') > 8 or force)
        result = @setFixed val, 0
      else
        result = @setFixed val
    else
      num = Math.floor((size - 7) / 3)

      if num > 9 then num = 9

      result = val / Math.pow(10, num * 3 + 6)
      result = result.toFixed(3)
      result = Number(result)

      switch num
        when 0 then result = "#{result} млн"
        when 1 then result = "#{result} млрд"
        when 2 then result = "#{result} трлн"
        when 3 then result = "#{result} квадр"
        when 4 then result = "#{result} квинт"
        when 5 then result = "#{result} секст"
        when 6 then result = "#{result} септ"
        when 7 then result = "#{result} окт"
        when 8 then result = "#{result} нон"
        when 9 then result = "#{result} дец"

    result

  checkShowHidden: ->
    @Field.model.showHidden()
    @Player.model.showHidden()

  getStatusText: (evil, good) ->
    diff = @Player.model.get("forceGood") - @Player.model.get("forceEvil")
    forcePercent = 100 / GS.limit * diff

    evil = [
      'Полный ноль'
      'Миленькое злодейство'
      'Блондинка'
      'Заклинатель змей'
      'Личинка зла'
      'Полтергейст'
      'Стервятник'
      'Гоблин'
      'Тролль'
      'Годзилла'
      'Тот чье имя нельзя называть'
      'Злой дух'
      'Чертик'
      'Бес'
      'Черт'
      'Демон'
      'Люцифер'
    ]

    neutral = ['Никто']

    good = [
      'Студент'
      'Светлячок'
      'Леприкон'
      'Поднебесный'
      'Мессия'
      'Добрый дух'
      'Положительный бес'
      'Меч света'
      'Чистильщик душ'
      'Саша белый'
      'Пьяный ангел'
      'Апостол'
      'Божество'
      'Бог'
    ]

    evilCount = _.size evil
    goodCount = _.size good

    stepEvil = 100 / evilCount
    stepGood = 100 / goodCount

    if forcePercent >= 0
      pos = Math.floor(forcePercent / stepGood)
      if forcePercent >= 100
        pos = +(_.size(good))
    else
      pos = Math.ceil(forcePercent / stepEvil)
      if forcePercent <= -100
        pos = -(_.size(evil))

    if pos < 0
      pos = -pos
      pos -= 1
      if evil[pos]? then return evil[pos] else return evil[_.size(evil) - 1]

    if pos == 0 then return neutral[0]

    if pos > 0
      pos -= 1
      if good[pos]? then return good[pos] else return good[_.size(good) - 1]

  recalcBots: ->
    @Player.model.recalcBots()
    @trigger 'changeCountOfBots'

  openingWindow: (start) ->
    if start <= 0 then toX = 380 else toX = 0
    @Player.movePlayer toX
    @Field.hiddingElementsUnderWindow()

  closingWindow: ->
    @Player.movePlayer 187
    @Field.showingElementsUnderWindow()
    @Field.resetBtnsBlockPositon()

module.exports = Controller
