GS         = require "../gameSettings.json"
CommonView = require "./commonView.coffee"

class MenuView extends CommonView
  render: ->
    super

    @cjAddDraw 0, 0, 380, 600, "WindowBg", @WC, {Fill: "#404048", Rect: {} }

    async.parallel [
      @createMusicBlock
      @createSoundBlock
      @createFAQBlock
      @createResetBlock
      @createInviteBlock
      ], (err, results) =>
        @createResetList()
        @addCloseBtn()
        @show()

  createMusicBlock: (callback) =>
    min = 18
    max = 148
    diff = max - min
    music = diff / 100 * @PM.get "music"

    @MC = @cjAddContainer 105, 105, "REMOVE", @WC
    @cjAddText 0, -2, "Музыка", "18px RM", "#ecf0f1", "REMOVE", @MC, {width: 170}
    @cjAddDraw 0, 35, 170, 40, "REMOVE", @MC, {Fill: "#2a2a2f", RoundRect: [20, 20, 20, 20] }

    MSC = @cjAddContainer 2, 37, "REMOVE", @MC
    MSB = @cjAddDraw 1, 0, music + 18 + 12, 36, "REMOVE", MSC, {Fill: "#29b88b", RoundRect: [18, 18, 18, 18] }, {}, true
    MS  = @cjAddDraw music, 0, 18, null, "REMOVE", MSC, {Fill: "#404048", Circle: {center: false} }, {cursor: "pointer"}

    move = (evt) =>
      next = evt.stageX - 105
      if next < min then next = min
      if next > max then next = max

      onePercent = (max - min) / 100
      @PM.set "music", (next - min) / onePercent

      MS.x = next
      createjs.Tween.get MSB.draw
        .to
          w: next + 12

    @MC.addEventListener "click", (evt) => move evt
    @MC.addEventListener "pressmove", (evt) => move evt

    callback null, null

  createSoundBlock: (callback) =>
    min = 18
    max = 148
    diff = max - min
    sound = diff / 100 * @PM.get "sound"

    @SC = @cjAddContainer 105, 205, "REMOVE", @WC
    @cjAddText 0, -2, "Звуки", "18px RM", "#ecf0f1", "REMOVE", @SC, {width: 170}
    @cjAddDraw 0, 35, 170, 40, "REMOVE", @SC, {Fill: "#2a2a2f", RoundRect: [20, 20, 20, 20] }

    SSC = @cjAddContainer 2, 37, "REMOVE", @SC
    SSB = @cjAddDraw 1, 0, sound + 18 + 12, 36, "REMOVE", SSC, {Fill: "#29b88b", RoundRect: [18, 18, 18, 18] }, {}, true
    SS  = @cjAddDraw sound, 0, 18, null, "REMOVE", SSC, {Fill: "#404048", Circle: {center: false} }, {cursor: "pointer"}

    move = (evt) =>
      next = evt.stageX - 105
      if next < min then next = min
      if next > max then next = max

      onePercent = (max - min) / 100
      @PM.set "sound", (next - min) / onePercent

      SS.x = next
      createjs.Tween.get SSB.draw
        .to
          w: next + 12

    @SC.addEventListener "click", (evt) => move evt
    @SC.addEventListener "pressmove", (evt) => move evt

    callback null, null

  createFAQBlock: (callback) =>
    @FAQC = @cjAddContainer 105, 340, "REMOVE", @WC

    btn1 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @FAQC, o: {Fill: "#33333a", RoundRect: [20, 20, 20, 20]} }
    btn2 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @FAQC, o: {Fill: "#585862", RoundRect: [20, 20, 20, 20]} }
    btn3 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @FAQC, o: {Fill: "#29292f", RoundRect: [20, 20, 20, 20]} }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @FAQC

    @cjAddText 0, 8, "FAQ", "18px RM", "#ecf0f1", "FAQ", @FAQC, {width: 170}

    @FAQC.addEventListener "click", (val) =>
      @windows.close()

      @faq = @cjAddBitmap 0, 0, "./images/faq.png", @UpperLayer.emptyLayer, {}

      @faq.on "click", (val) =>
        @cjRemove @faq, @UpperLayer.emptyLayer
        , null, true

    callback null, null

  createResetBlock: (callback) =>
    @RC = @cjAddContainer 105, 405, "REMOVE", @WC

    btn1 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @RC, o: {Fill: "#33333a", RoundRect: [20, 20, 20, 20]} }
    btn2 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @RC, o: {Fill: "#585862", RoundRect: [20, 20, 20, 20]} }
    btn3 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @RC, o: {Fill: "#29292f", RoundRect: [20, 20, 20, 20]} }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @RC

    @cjAddText 0, 8, "Сбросить героя", "18px RM", "#ecf0f1", "REMOVE", @RC, {width: 170}

    @RC.addEventListener "click", (val) => @showResetList()
    callback null, null

  createInviteBlock: (callback) =>
    @IC = @cjAddContainer 105, 470, "REMOVE", @WC

    btn1 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @IC, o: {Fill: "#297fb8", RoundRect: [20, 20, 20, 20]} }
    btn2 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @IC, o: {Fill: "#2a93d9", RoundRect: [20, 20, 20, 20]} }
    btn3 = {x: 0, y: 0, w: 170, h: 40, n: "REMOVE", p: @IC, o: {Fill: "#1569a0", RoundRect: [20, 20, 20, 20]} }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @IC

    @cjAddText 0, 8, "Позвать друзей", "18px RM", "#ecf0f1", "REMOVE", @IC, {width: 170}

    @IC.addEventListener "click", (val) =>
      req = { "type": "callMethod", "method": "showInviteBox" }
      @API.call req
      @windows.close()

    callback null, null

  createResetList: ->
    @RL = @cjAddContainer -380, 0, "REMOVE", @WC
    @cjAddDraw 0, 0, 380, 600, "WindowBg", @RL, {Fill: "#404048", Rect: {} }

    @RL.addEventListener 'click', (val) => return

    @cjAddText 380 - 17.5, 20, "СБРОС ГЕРОЯ", "24px RM", "#ecf0f1", "REMOVE", @RL, {textAlign: 'right'}
    @cjAddText 0, 130, "Вы уверены, что хотите\nудалить героя\nи весь свой прогреcc?\nПрогресс в глобальной статистике останется неизменным", "22px RM", "#ecf0f1", "REMOVE", @RL, {width: 380, lineWidth: 300, lineHeight: 26}

    btnYes = @cjAddContainer 40, 350, "REMOVE", @RL
    btn1 = {x: 0, y: 0, w: 146, h: 48, n: "REMOVE", p: btnYes, o: {Fill: "#33333a", RoundRect: [24, 24, 24, 24] } }
    btn2 = {x: 0, y: 0, w: 146, h: 48, n: "REMOVE", p: btnYes, o: {Fill: "#585862", RoundRect: [24, 24, 24, 24] } }
    btn3 = {x: 0, y: 0, w: 146, h: 48, n: "REMOVE", p: btnYes, o: {Fill: "#29292f", RoundRect: [24, 24, 24, 24] } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, btnYes
    @cjAddText 0, 9, 'Сброс', "20px RR", '#ecf0f1', "REMOVE", btnYes, {width: 146}

    disabled = @cjAddDraw 0, 0, 146, 48, "REMOVE", btnYes, { Fill: "#33333a", RoundRect: [24, 24, 24, 24] }, {alpha: 0.68, visible: false}

    btnYes.addEventListener "click", (val) =>
      disabled.visible    = true
      btnYes.mouseEnabled = false

      @Server.call "/resetUser", {}, (res) => location.reload()

    btnNo = @cjAddContainer 194, 350, "REMOVE", @RL
    btn1 = {x: 0, y: 0, w: 146, h: 48, n: "REMOVE", p: btnNo, o: {Fill: "#33333a", RoundRect: [24, 24, 24, 24] } }
    btn2 = {x: 0, y: 0, w: 146, h: 48, n: "REMOVE", p: btnNo, o: {Fill: "#585862", RoundRect: [24, 24, 24, 24] } }
    btn3 = {x: 0, y: 0, w: 146, h: 48, n: "REMOVE", p: btnNo, o: {Fill: "#29292f", RoundRect: [24, 24, 24, 24] } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, btnNo
    @cjAddText 0, 9, 'Отмена', "20px RR", '#ecf0f1', "REMOVE", btnNo, {width: 146}
    btnNo.addEventListener "click", (val) => @hideResetList()

  showResetList: -> createjs.Tween.get(@RL).to({x: 0}   , GS.Speed * 3)
  hideResetList: -> createjs.Tween.get(@RL).to({x: -380}, GS.Speed * 3)

  _hide: (cb) ->
    if @RL.x != -380
      perc = 40
      newx = 380/100*perc
      news = 3/100*perc
      createjs.Tween.get(@RL).to({x: -newx}, GS.Speed * news)
        .call =>
          super cb
    else
      super

module.exports = MenuView
