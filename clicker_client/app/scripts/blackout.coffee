GS = require './gameSettings.json'
CreatejsBaseView = require './createjsBaseView.coffee'

class Blackout extends CreatejsBaseView
  initialize: -> if DEBUG_MODE then global.blackout = @

  getController: (@Controller) ->
    @windows = @Controller.windows
    @PM = @Controller.Player.model

  create: ->
    @blackout = @cjAddContainer 0, 0, "REMOVE", canvas, {width: 760, height: 600}

    @layer_blackoutLeft  = @cjAddDraw 0  , 0, 380, 600, "REMOVE", @blackout, {Fill: "#16191a", Rect: {} }, { "alpha": 0 }
    @layer_blackoutRight = @cjAddDraw 380, 0, 380, 600, "REMOVE", @blackout, {Fill: "#16191a", Rect: {} }, { "alpha": 0 }

    @createCoinsBlock()

    @setListens()

  createCoinsBlock: ->
    @CBC = @cjAddContainer 17.5, 75, "REMOVE", @blackout, {width: 44, height: 44, alpha: 0}

    @cjAddDraw 0, 0, 22, null, "REMOVE", @CBC, {Fill: "#ecf0f1", Circle: {center: false} }
    @cjAddImage 0, 0, "coinsIco", @CBC
    @layer_coins = @cjAddText 30, 10, "", "16px RM", "#ecf0f1", "REMOVE", @CBC, {textAlign: 'left'}

  setListens: ->
    @listenTo @PM, 'change:coins', @renderCoins

  render: ->
    @renderCoins()

  renderCoins: -> @layer_coins.children[0].text  = "#{@PM.get('coins')}"

  blackoutOn: (start, nameWindow) ->
    @setListeners start

    if nameWindow == 'shop' then @CBC.alpha = 1

    return if @layer_blackoutLeft.alpha > 0

    createjs.Tween.get @layer_blackoutLeft
      .to
        alpha: 0.5
      , GS.Speed * 2

    createjs.Tween.get @layer_blackoutRight
      .to
        alpha: 0.5
      , GS.Speed * 2

  setListeners: (start) ->
    @removeListeners()

    if start == 'left' or start > 0
      @layer_blackoutLeft.addEventListener  "click", => @windows.close()
      @layer_blackoutRight.addEventListener "click", => return null
    if start == 'right' or start <= 0
      @layer_blackoutLeft.addEventListener "click", => return null
      @layer_blackoutRight.addEventListener "click", => @windows.close()
    if not start?
      @layer_blackoutLeft.addEventListener  "click", => return null
      @layer_blackoutRight.addEventListener "click", => return null

  removeListeners: ->
    @layer_blackoutLeft?.removeAllEventListeners()
    @layer_blackoutRight?.removeAllEventListeners()

  blackoutOff: ->
    @removeListeners()

    createjs.Tween.get @layer_blackoutLeft
      .to
        alpha: 0
      , GS.Speed * 2

    createjs.Tween.get @layer_blackoutRight
      .to
        alpha: 0
      , GS.Speed * 2

  hiddenCBC: ->
    return if @CBC.alpha == 0

    createjs.Tween.get @CBC
      .to
        alpha: 0
      , GS.Speed * 2

module.exports = Blackout
