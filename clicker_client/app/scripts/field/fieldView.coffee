GS = require "../gameSettings.json"
CreatejsBaseView = require "../createjsBaseView.coffee"

class FieldView extends CreatejsBaseView
  initialize: -> if DEBUG_MODE then global.field = @

  getController: (@Controller) ->
    @UpperLayer = @Controller.UpperLayer
    @PM         = @Controller.Player.model
    @windows    = @Controller.windows
    @info       = @Controller.information
    @Blackout   = @Controller.Blackout

  create: ->
    @achQueue = []
    @achPopUpShow = false
    @liftup = false

    @model.create()

    @FC = @cjAddContainer 0, 0, "REMOVE", canvas, {width: 760, height: 600}

    @createMenuBlock()
    @createCoinsBlock()
    @createAchievementBlock()
    @createShopBlock()
    @createStatisticBlock()

    @createGetNewLevel()

    @createPlayerDoubleStrBlock()
    @createBotDoubleStrBlock()
    @createBotDoubleSpeedBlock()

    @createBtnForce()
    @createGlobalForce()

    @layer_status = @cjAddText 0, 18, "", "18px RM", "#ecf0f1", "Status", @FC
    @layer_level  = @cjAddText 0, 51, "", "16px RR", "#ecf0f1", "Level" , @FC
    @layer_exp    = @cjAddText 0, 73, "", "16px RR", "#ecf0f1", "Exp"   , @FC

    @setListens()

  drowMiniCircleBtn: (parent) ->
    btn1 = {x: 0, y: 0, w: 22, h: null, n: "REMOVE", p: parent, o: {Fill: "#ecf0f1", Circle: {center: false} } }
    btn2 = {x: 0, y: 0, w: 22, h: null, n: "REMOVE", p: parent, o: {Fill: "#ffffff", Circle: {center: false} } }
    btn3 = {x: 0, y: 0, w: 22, h: null, n: "REMOVE", p: parent, o: {Fill: "#cccccc", Circle: {center: false} } }
    { "btn1": btn1, "btn2": btn2, "btn3": btn3 }

  drowBoostersBtn: (parent) ->
    btn1 = {x: 0, y: 0, w: 60, h: 60, n: "REMOVE", p: parent, o: {Fill: "#16191a", RoundRect: [10, 10, 10, 10] } }
    btn2 = {x: 0, y: 0, w: 60, h: 60, n: "REMOVE", p: parent, o: {Fill: "#000000", RoundRect: [10, 10, 10, 10] } }
    btn3 = {x: 0, y: 0, w: 60, h: 60, n: "REMOVE", p: parent, o: {Fill: "#111213", RoundRect: [10, 10, 10, 10] } }
    { "btn1": btn1, "btn2": btn2, "btn3": btn3 }

  createMenuBlock: ->
    @MBC = @cjAddContainer 17.5, 15, "REMOVE", @FC, {width: 44, height: 44}

    btns = @drowMiniCircleBtn @MBC
    @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @MBC

    @MBC.addEventListener "click", => @windows.openWindow('Menu')

    @cjAddImage 0, 0, "menuIco", @MBC

  createCoinsBlock: ->
    @CBC = @cjAddContainer 17.5, 75, "REMOVE", @FC, {width: 44, height: 44}

    btns = @drowMiniCircleBtn @CBC
    @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @CBC

    @CBC.addEventListener "click", => @windows.openWindow('Bank')

    @cjAddImage 0, 0, "coinsIco", @CBC
    @layer_coins = @cjAddText 30, 10, "", "16px RM", "#ecf0f1", "REMOVE", @CBC, {textAlign: 'left'}

  createAchievementBlock: ->
    @ABC = @cjAddContainer 17.5, 498, "REMOVE", @FC, {width: 44, height: 44}

    btns = @drowMiniCircleBtn @ABC
    @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @ABC

    notification = @cjAddDraw 32, 32, 6, null, "REMOVE", @ABC, {Fill: "#db2c2c", Circle: {center: false} }, {visible: false}

    @ABC.addEventListener "click", =>
      @windows.openWindow('Achievments')
      @ABC.hideNotification()

    @ABC.showNotification = => notification.visible = true
    @ABC.hideNotification = => notification.visible = false

    @cjAddImage 0, 0, "achIco", @ABC

  createShopBlock: ->
    @SBC = @cjAddContainer 760 - 17.5 - 44, 15, "REMOVE", @FC, {width: 44, height: 44}

    btns = @drowMiniCircleBtn @SBC
    @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @SBC

    @SBCDisabled = @cjAddDraw -1, -1, 23, null, "REMOVE", @SBC, { Fill: "#37373f", Circle: {center: false} }, {alpha: 0.68}

    @SBC.addEventListener "click", => @windows.openWindow('Shop')

    @cjAddImage -1, 0, "shopIco", @SBC

    @switchShowBtnShop()

  switchShowBtnShop: -> @switchShowBtn @SBCDisabled, @SBC, @PM.get("level") < @PM.get("levelOpenPlayerDoubleStr")

  createStatisticBlock: ->
    @STBC = @cjAddContainer 760 - 17.5 - 44, 75, "REMOVE", @FC, {width: 44, height: 44}

    btns = @drowMiniCircleBtn @STBC
    @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @STBC

    @STBC.addEventListener "click", => @windows.openWindow('Statistic')

    @cjAddImage 0, -1, "statsIco", @STBC

  createGetNewLevel: ->
    if DEBUG_MODE
      @getNewLevel = @cjAddContainer 600, 250, "REMOVE", @FC
      @cjAddDraw 0, 0, 150, 20, "REMOVE", @getNewLevel, {Fill: "#eda744", Rect: {} }
      @cjAddText 0, -1, "Добавить уровеней", "14px RR", "#ecf0f1", "REMOVE", @getNewLevel, {width: 150}

      @getNewLevel.on "click", () => @model.getNewLevel()
    else @getNewLevel = {}

  createPlayerDoubleStrBlock: ->
    @PDStB = @cjAddContainer 685, 287, "REMOVE", @FC, {width: 60, height: 60, visible: false}

    btns = @drowBoostersBtn @PDStB
    @PDStBBtns = @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @PDStB

    @PDStBTimer = @cjAddDraw 0, 60, 45, null, "REMOVE", @PDStB, {Fill: "#343839", Line: [[30, 30]], Arc: {x: 30, y: 30, startAngle: -(Math.PI * 2), endAngle: 0, antiClockWise: false} }, {rotation: -90, visible: false}, true
    @PDStBTimer.shape.mask = @PDStBBtns

    @cjAddImage 0, 0, "playerDoubleStrIco", @PDStB

    @countPDStBCont = @cjAddContainer 57, 57, "REMOVE", @PDStB, {width: 18, height: 18}
    @cjAddDraw 0, 0, 9, null, "REMOVE", @countPDStBCont, {Fill: "#f6cc22", Circle: {center: true} }
    @countPDStB     = @cjAddText -9, -9, "", "14px RM", "#16191a", "REMOVE", @countPDStBCont

    @PDStB.addEventListener "click", =>
      if @PM.get('playerDoubleStr') <= 0
        @windows.openWindow('Shop', {startPage: 'booster'})
      else
        @model.playerDoubleStr () =>
          @PDStBTimer.shape.visible = true
          @renderTimerForBoosters @PDStBTimer, 'playerDoubleStrTime'

  createBotDoubleStrBlock: ->
    @BDStB = @cjAddContainer 685, 357, "REMOVE", @FC, {width: 60, height: 60, visible: false}

    btns = @drowBoostersBtn @BDStB
    @BDStBBtns = @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @BDStB

    @BDStBTimer = @cjAddDraw 0, 60, 45, null, "REMOVE", @BDStB, {Fill: "#343839", Line: [[30, 30]], Arc: {x: 30, y: 30, startAngle: -(Math.PI * 2), endAngle: 0, antiClockWise: false} }, {rotation: -90, visible: false}, true
    @BDStBTimer.shape.mask = @PDStBBtns

    @cjAddImage 0, 0, "botDoubleStrIco", @BDStB

    @countBDStBCont  = @cjAddContainer 57, 57, "REMOVE", @BDStB, {width: 18, height: 18}
    @cjAddDraw 0, 0, 9, null, "REMOVE", @countBDStBCont, {Fill: "#f6cc22", Circle: {center: true} }
    @countBDStB     = @cjAddText -9, -9, "", "14px RM", "#16191a", "REMOVE", @countBDStBCont

    @BDStB.addEventListener "click", =>
      if @PM.get('botDoubleStr') <= 0
        @windows.openWindow('Shop', {startPage: 'booster'})
      else
        @model.botDoubleStr () =>
          @BDStBTimer.shape.visible = true
          @renderTimerForBoosters @BDStBTimer, 'botDoubleStrTime'

  createBotDoubleSpeedBlock: ->
    @BDSpB = @cjAddContainer 685, 427, "REMOVE", @FC, {width: 60, height: 60, visible: false}

    btns = @drowBoostersBtn @BDSpB
    @BDSpBBtns = @cjAddHoverActiveBlock btns.btn1, btns.btn2, btns.btn3, @BDSpB

    @BDSpBTimer = @cjAddDraw 0, 60, 45, null, "REMOVE", @BDSpB, {Fill: "#343839", Line: [[30, 30]], Arc: {x: 30, y: 30, startAngle: -(Math.PI * 2), endAngle: 0, antiClockWise: false} }, {rotation: -90, visible: false}, true
    @BDSpBTimer.shape.mask = @PDStBBtns

    @cjAddImage 0, 0, "botDoubleSpeedIco", @BDSpB

    @countBDSpBCont  = @cjAddContainer 57, 57, "REMOVE", @BDSpB, {width: 18, height: 18}
    @cjAddDraw 0, 0, 9, null, "REMOVE", @countBDSpBCont, {Fill: "#f6cc22", Circle: {center: true} }
    @countBDSpB     = @cjAddText -9, -9, "", "14px RM", "#16191a", "REMOVE", @countBDSpBCont

    @BDSpB.addEventListener "click", =>
      if @PM.get('botDoubleSpeed') <= 0
        @windows.openWindow('Shop', {startPage: 'booster'})
      else
        @model.botDoubleSpeed () =>
          @BDSpBTimer.shape.visible = true
          @renderTimerForBoosters @BDSpBTimer, 'botDoubleSpeedTime'

  createBtnForce: ->
    @BFEC = @cjAddContainer 230, 492, "REMOVE", @FC, {width: 138}
    btn1 = {x: 0, y: 0, w: 138, h: 58, n: "REMOVE", p: @BFEC, o: {Fill: "#db2c2c", RoundRect: [30, 30, 30, 30] } }
    btn2 = {x: 0, y: 0, w: 138, h: 58, n: "REMOVE", p: @BFEC, o: {Fill: "#f63d3d", RoundRect: [30, 30, 30, 30] } }
    btn3 = {x: 0, y: 0, w: 138, h: 58, n: "REMOVE", p: @BFEC, o: {Fill: "#bc2121", RoundRect: [30, 30, 30, 30] } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @BFEC
    @cjAddText 0, 7, "Сотворить зло", "17px RM", "#ecf0f1", "REMOVE", @BFEC, {lineWidth: 100, lineHeight: 20}

    @BFECDisabled = @cjAddDraw 0, 0, 138, 58, "REMOVE", @BFEC, { Fill: "#37373f", RoundRect: [30, 30, 30, 30] }, {alpha: 0.68}

    @BFEC.addEventListener "click", (val) =>
      @renderForceEvilUp val
      @model.forceEvilAdd()
      @switchShowBtnAllForces()
      if @BFEC.y >= 530 then @upBtnForce @BFEC

    @BFGC = @cjAddContainer 392, 492, "REMOVE", @FC, {width: 137}
    btn1 = {x: 0, y: 0, w: 137, h: 58, n: "REMOVE", p: @BFGC, o: {Fill: "#1aa1d9", RoundRect: [30, 30, 30, 30] } }
    btn2 = {x: 0, y: 0, w: 137, h: 58, n: "REMOVE", p: @BFGC, o: {Fill: "#29b8f4", RoundRect: [30, 30, 30, 30] } }
    btn3 = {x: 0, y: 0, w: 137, h: 58, n: "REMOVE", p: @BFGC, o: {Fill: "#1387b8", RoundRect: [30, 30, 30, 30] } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @BFGC
    @cjAddText 0, 7, "Творить добро" , "17px RM", "#ecf0f1", "REMOVE", @BFGC, {lineWidth: 100, lineHeight: 20}

    @BFGCDisabled = @cjAddDraw 0, 0, 137, 58, "REMOVE", @BFGC, { Fill: "#37373f", RoundRect: [30, 30, 30, 30] }, {alpha: 0.68}

    @BFGC.addEventListener "click", (val) =>
      @renderForceGoodUp val
      @model.forceGoodAdd()
      @switchShowBtnAllForces()
      if @BFGC.y >= 530 then @upBtnForce @BFGC

  upBtnForce: (btn) ->
    return if @liftup

    @liftup = true
    Sound.playSound 'spring'
    createjs.Tween.get(btn).to({y: 492}, GS.Speed * 6, createjs.Ease.elasticOut).call => @liftup = false


  switchShowBtnAllForces: ->
    if @PM.get("level") < @PM.get("levelOpenForce")
      @switchShowBtn @BFECDisabled, @BFEC, true
      @switchShowBtn @BFGCDisabled, @BFGC, true
    else
      @switchShowBtn @BFECDisabled, @BFEC, @model.checkCloseForceEvil()
      @switchShowBtn @BFGCDisabled, @BFGC, @model.checkCloseForceGood()

  switchShowBtn: (parent1, parent2, bool) ->
    parent1.visible      = bool
    parent2.mouseEnabled = !bool

  createGlobalForce: ->
    @GFC = @cjAddContainer 602, 140, "REMOVE", @FC, {visible: false}

    @cjAddText 0, 0, "В МИРЕ", "16px RM", "#ecf0f1", "REMOVE", @GFC, {width: 142}

    @GFCWrapper = @cjAddDraw 0, 27, 140, 14, "REMOVE", @GFC, {RoundRect: [7, 7, 7, 7] }
    @globalGoodBgExpanded = @cjAddDraw 2, 27, 136, 14, "REMOVE", @GFC, {Fill: "#ecf0f1", RoundRect: [7, 7, 7, 7] }, {}, true
    @globalEvilBgExpanded = @cjAddDraw 0, 27, 0  , 14, "REMOVE", @GFC, {Fill: "#16191a", RoundRect: [7, 7, 7, 7] }, {}, true

    @globalGoodBgExpanded.shape.mask = @GFCWrapper
    @globalEvilBgExpanded.shape.mask = @GFCWrapper

    @layer_globalForceEvil = @cjAddText 0  , 46, "", "14px RM", "#ecf0f1", "REMOVE", @GFC, {textAlign: 'left'}
    @layer_globalForceGood = @cjAddText 140, 46, "", "14px RM", "#ecf0f1", "REMOVE", @GFC, {textAlign: 'right'}

    @GFC.addEventListener "click", => @windows.openWindow('Statistic')


  ##########


  setListens: ->
    @listenTo @PM, 'change:coins', @renderCoins

    @listenTo @PM, 'change:exp'      , @renderExp
    @listenTo @PM, 'change:maxExp'   , @renderExp
    @listenTo @PM, 'change:level'    , @renderLvl
    @listenTo @PM, 'change:level'    , @switchShowBtnShop

    @listenTo @PM, 'change:forceEvil', @changeForces
    @listenTo @PM, 'change:forceGood', @changeForces

    @listenTo @PM, 'change:globalEvilAll'    , @renderGlobalForce
    @listenTo @PM, 'change:globalGoodAll'    , @renderGlobalForce
    @listenTo @PM, 'change:globalEvilNetwork', @renderGlobalForce
    @listenTo @PM, 'change:globalGoodNetwork', @renderGlobalForce

    @listenTo @PM, 'change:playerDoubleStr', @renderPlayerDoubleStrCount
    @listenTo @PM, 'change:botDoubleStr'   , @renderBotDoubleStrCount
    @listenTo @PM, 'change:botDoubleSpeed' , @renderBotDoubleSpeedCount


  ##########


  render: ->
    @renderCoins()
    @renderStatus()
    @renderLvl()
    @renderExp()

    @renderPlayerDoubleStrCount()
    @renderBotDoubleStrCount()
    @renderBotDoubleSpeedCount()

    @renderGlobalForce()

  changeForces: ->
    @renderStatus()
    @Controller.changeMusic()

  renderCoins               : -> @layer_coins.children[0].text  = "#{@PM.get('coins')}"
  renderStatus              : -> @layer_status.children[0].text = @Controller.getStatusText()
  renderLvl                 : -> @layer_level.children[0].text  = "Уровень: #{@PM.get('level')}"
  renderExp                 : ->
    exp = @Controller.changeNumber @PM.get('exp'), true
    max = @Controller.changeNumber @PM.get('maxExp')
    @layer_exp.children[0].text = "#{exp} / #{max}"

  renderPlayerDoubleStrCount: -> @countPDStB.children[0].text = @PM.get('playerDoubleStr')
  renderBotDoubleStrCount   : -> @countBDStB.children[0].text = @PM.get('botDoubleStr')
  renderBotDoubleSpeedCount : -> @countBDSpB.children[0].text = @PM.get('botDoubleSpeed')

  renderGlobalForce: ->
    if @PM.get('socialNetwork') == 'test'
      globalEvil = @PM.get "globalEvilAll"
      globalGood = @PM.get "globalGoodAll"
    else
      globalEvil = @PM.get "globalEvilNetwork"
      globalGood = @PM.get "globalGoodNetwork"

    sum = globalEvil + globalGood
    if sum == 0 then sum = 2
    onePercent  = 100 / sum
    percentEvil = onePercent * globalEvil
    percentGood = onePercent * globalGood

    if (percentEvil + percentGood) < 100
      fault = (100 - (percentEvil + percentGood)) / 2
      percentEvil += fault
      percentGood += fault

    widthCommon = 140
    onePercent = widthCommon / 100
    widthEvil = onePercent * percentEvil
    widthGood = onePercent * percentGood

    createjs.Tween.get @globalEvilBgExpanded.draw
      .to
        w: widthEvil
      , GS.Speed * 10

    @layer_globalForceEvil.children[0].text = "Зла #{percentEvil.toFixed()}%"
    @layer_globalForceGood.children[0].text = "Добра #{percentGood.toFixed()}%"

  showHiddenForce: ->
    @GFC.visible  = true
    @switchShowBtnAllForces()

  showHiddenPlayerDoubleStr: -> @PDStB.visible = true
  showHiddenBotDoubleStr   : -> @BDStB.visible = true
  showHiddenBotDoubleSpeed : -> @BDSpB.visible = true

  renderTimerForBoosters: (obj, nameBooster) ->
    createjs.Tween.get obj.draw
      .to
        startAngle: -0
      , @PM.get("#{nameBooster}Plus") * 1000
      .call =>
        obj.shape.visible = false
        createjs.Tween.get obj.draw
          .to
            startAngle: -(Math.PI * 2)

  renderForceEvilUp: (evt) ->
    force = @PM.get "forceEvilUp"
    @renderForceUp evt, force, @BFEC

  renderForceGoodUp: (evt) ->
    force = @PM.get "forceGoodUp"
    @renderForceUp evt, force, @BFGC

  renderForceUp: (evt, force, parent) ->
    force = @Controller.changeNumber force

    animate = @cjAddText parent.x + evt.localX, parent.y, force, "24px RM", "#f6cc22", "REMOVE", @UpperLayer.emptyLayer, {width: 0}

    createjs.Tween.get animate
      .to
        y: animate.y - 200
        alpha: 0
      , GS.Speed * 10
      .call =>
        canvas.removeChild animate

  addAchInQueue: (nameAch, key) ->
    @achQueue.push { 'nameAch': nameAch, 'key': key, 'container': null }
    @renderAchFromQueue()

  renderAchFromQueue: ->
    return if @achPopUpShow or _.size(@achQueue) == 0
    @achPopUpShow = true

    ach = _.first @achQueue

    ach.container = @cjAddContainer -190, 390, "REMOVE", @FC, {hidden: false}
    @cjAddDraw 0, 0, 240, 60, "REMOVE", ach.container, {Fill: "#51be84", RoundRect: [0, 30, 30, 0] }, {alpha: 0.7}

    cc = @cjAddContainer 28, 9, "REMOVE", ach.container, {width: 42, height: 42}
    @cjAddDraw 0, 0, 21, null, "REMOVE", cc, {Fill: "#224af8", Circle: {center: false} }, {}
    @cjAddImage 0, 0, "achIco_#{ach.nameAch}", cc, {width: 30}, true, true, false

    @cjAddText 80, 12, "Открыто достижение!", "13px RR", "#ecf0f1", "REMOVE" , ach.container, {textAlign: 'left'}
    @cjAddText 80, 29, "Ура! #{ach.key} уровень ачивки", "13px RR", "#ecf0f1", "REMOVE" , ach.container, {textAlign: 'left', lineWidth: 150}

    createjs.Tween.get ach.container
      .to
        x: -20
      , GS.Speed * 3, createjs.Ease.backOut
      .wait(3000)
      .call =>
        @hideAch ach.container

    ach.container.addEventListener "click", =>
      @windows.openWindow('Achievments')
      @ABC.hideNotification()
      # @hideAch ach.container

  hideAch: (name) ->
    return if name.hidden
    name.hidden = true

    createjs.Tween.get name
      .to
        y: name.y - 150
        alpha: 0.5
      , GS.Speed * 10
      .call =>
        @achQueue = _.rest @achQueue
        @achPopUpShow = false
        @renderAchFromQueue()
      .to
        y: name.y - 300
        alpha: 0
      , GS.Speed * 10
      .call =>
        @cjRemove name, @FC

  hiddingElementsUnderWindow: ->
    _.each [@MBC, @CBC, @ABC, @SBC, @STBC, @getNewLevel, @PDStB, @BDStB, @BDSpB, @BFEC, @BFGC, @GFC, @layer_status, @layer_level, @layer_exp], (cont) ->
      createjs.Tween.get cont
        .to
          alpha: 0
        , GS.Speed * 3

  showingElementsUnderWindow: ->
    _.each [@MBC, @CBC, @ABC, @SBC, @STBC, @getNewLevel, @PDStB, @BDStB, @BDSpB, @BFEC, @BFGC, @GFC, @layer_status, @layer_level, @layer_exp], (cont) =>
      createjs.Tween.get cont
        .to
          alpha: 1
        , GS.Speed * 3
        .call =>
          @Blackout.hiddenCBC()

    @renderAchFromQueue()

  resetBtnsBlockPositon: ->
    @MBC.set({x: 17.5, y: 15})
    @CBC.set({x: 17.5, y: 75})
    @ABC.set({x: 17.5, y: 498})

    @SBC.set({x: 760 - 17.5 - 44, y: 15})
    @STBC.set({x: 760 - 17.5 - 44, y: 75})
    @PDStB.set({x: 685, y: 287})
    @BDStB.set({x: 685, y: 357})
    @BDSpB.set({x: 685, y: 427})
    @BFEC.set({x: 230, y: 492})
    @BFGC.set({x: 392, y: 492})
    @GFC.set({x: 602, y: 140})

module.exports = FieldView
