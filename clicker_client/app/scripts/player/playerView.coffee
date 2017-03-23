CreatejsBaseView = require "../createjsBaseView.coffee"
GS = require "../gameSettings.json"

class PlayerView extends CreatejsBaseView
  initialize: -> if DEBUG_MODE then global.player = @

  getController: (@Controller) ->
    @LowLayer   = @Controller.LowLayer
    @PM         = @Controller.Player.model
    @UpperLayer = @Controller.UpperLayer
    @Server     = @Controller.Server

  create: ->
    @model.create()

    @createMainBlock()
    @createPlayerContainer()
    @createPlayer()
    @createBots()

    @setListens()

  createMainBlock: ->
    @mainBlock       = @cjAddContainer 187, 110, "REMOVE", canvas, {width: 385, height: 361}

    @mainBlockForPlayer = @cjAddContainer 0, 0, "REMOVE", @mainBlock
    @mainBlockForBot    = @cjAddContainer 0, 0, "REMOVE", @mainBlock

    @animatePlayer()

  createPlayerContainer: ->
    @playerThingsBack = @cjAddContainer 0, 0, "REMOVE", @mainBlockForPlayer, {width: 385, height: 361}
    @playerContainer = @cjAddContainer 0, 0, "REMOVE", @mainBlockForPlayer, {width: 385, height: 361}
    @playerThings = @cjAddContainer -4, 0, "REMOVE", @mainBlockForPlayer, {width: 385, height: 361}

    @playerContainer.addEventListener "click", (val) =>
      Sound.playSound("clickCell")
      @renderNumberUp val
      @model.playerClickController()

    @playerContainer.cursor = "pointer"

  createPlayer: ->
    level = if @PM.get('level') > 5 then 5 else @PM.get('level')
    @player = @cjAddImage 0, 0, "player_#{level}", @playerContainer

  changeViewPlayer: ->
    @playerThingsBack.removeAllChildren()
    @playerThings.removeAllChildren()

    return if @PM.get('level') < 5

    for layer in @PM.get('thingsAtPlayer')
      force = switch layer.force
        when 'forceEvil' then 'evil'
        when 'forceGood' then 'good'
        else 'common'

      switch layer.name
        when 'weapon' then _x = 300
        else _x = 0

      if layer.name == 'back' then parent = @playerThingsBack else parent = @playerThings
      @cjAddImage _x, 0, "thing_#{layer.name}_#{force}_#{layer.num}", parent, {}, false

  animatePlayer: ->
    _y = @mainBlockForPlayer.y
    createjs.Tween.get @mainBlockForPlayer, {loop: true}
      .to({y: _y - 7}, GS.Speed * 7)
      .to({y: _y + 7}, GS.Speed * 13)
      .to({y: _y    }, GS.Speed * 7)

  animateForBots: (bot) ->
    _y = bot.y
    createjs.Tween.get bot, {loop: true}
      .to({y: _y - 7}, GS.Speed * 9)
      .to({y: _y + 7}, GS.Speed * 17)
      .to({y: _y    }, GS.Speed * 9)

  createBots: ->
    @createEvilBot()
    @createGoodBot()

  createEvilBot: ->
    level = 1
    botEvil = @model.get "botEvil"
    _.each botEvil, (val, key) => level = key if val > 0

    @evilBotBlock = @cjAddContainer 50, 70, "REMOVE", @mainBlockForBot, {width: 40, height: 40, visible: false}
    @evilBot      = @cjAddImage 0, 0, "botLevel#{level}Evil", @evilBotBlock

    @animateForBots @evilBotBlock

  createGoodBot: ->
    level = 1
    botGood = @model.get "botGood"
    _.each botGood, (val, key) => level = key if val > 0

    @goodBotBlock = @cjAddContainer 310, 70, "REMOVE", @mainBlockForBot, {width: 40, height: 40, visible: false}
    @goodBot      = @cjAddImage 0, 0, "botLevel#{level}Good", @goodBotBlock

    @animateForBots @goodBotBlock


  ##########


  setListens: ->
    @listenTo @PM, 'change:level', @renderPlayer


  ##########


  render: ->

  renderPlayer: ->
    level = if @PM.get('level') > 5 then 5 else @PM.get('level')
    @player = @cjAddImage 0, 0, "player_#{level}", @playerContainer

  renderBots: =>
    @renderEvilBot()
    @renderGoodBot()

  renderEvilBot: ->
    level = 1
    botEvil = @model.get "botEvil"
    _.each botEvil, (val, key) => level = key if val > 0

    @cjChangeImage @evilBot, "botLevel#{level}Evil"

  renderGoodBot: ->
    level = 1
    botGood = @model.get "botGood"
    _.each botGood, (val, key) => level = key if val > 0

    @cjChangeImage @goodBot, "botLevel#{level}Good"

  showHiddenForce: ->
    @evilBotBlock.visible = true
    @goodBotBlock.visible = true
    @changeViewPlayer()

  renderNumberUp: (val, exp, first = false) =>
    if not val?
      posX = _.random 0 , 760
      posY = _.random 100, 610

      if first
        color = "#f6cc22"
        layer = @UpperLayer
        alpha = 1
        size = 30
      else
        color = "#000"
        layer = @LowLayer
        alpha = 0.7
        size = 24

      powerUp = exp ? @model.get("botStr")
      if @model.get("botDoubleStrTime") > 0
        powerUp *= 2
    else
      powerUp = @model.get("powerUp")
      if @model.get("playerDoubleStrTime") > 0
        powerUp *= 2

      color = "#f6cc22"
      layer = @UpperLayer
      alpha = 1
      size = 24

      posX = val.localX      + @mainBlock.x
      posY = val.localY - 20 + @mainBlock.y

    powerUp = @Controller.changeNumber powerUp, true
    return if powerUp == 0

    animate = @cjAddText posX, posY, powerUp, "#{size}px RM", color, "REMOVE", layer.emptyLayer, {width: 0, alpha: alpha}

    speed = if exp? then 40 else 10
    createjs.Tween.get animate
      .to
        y: animate.y - 200
        alpha: 0
      , GS.Speed * speed
      .call =>
        @cjRemove animate

  renderForceUp: (add, force, first = false) ->
    posX = _.random 0 , 760
    posY = _.random 100, 610

    speed = if not first then 10 else 40
    size  = if not first then 24 else 30

    color = switch force
      when 'evil' then 'red'
      when 'good' then 'blue'
      else '#f6cc22'

    add = @Controller.changeNumber add
    return if add == 0

    animate = @cjAddText posX, posY, add, "#{size}px RM", color, "REMOVE", @LowLayer.emptyLayer, {width: 0, alpha: 0.7}

    createjs.Tween.get animate
      .to
        y: animate.y - 200
        alpha: 0
      , GS.Speed * speed
      .call =>
        @cjRemove animate

  movePlayer: (toX) ->
    createjs.Tween.get @mainBlock
      .to x: @mainBlock.x
      .to
        x: toX
      , GS.Speed * 3

module.exports = PlayerView
