GS = require "../gameSettings.json"
CommonView = require "./commonView.coffee"

class StatisticView extends CommonView
  render: ->
    super

    @cjAddDraw 0, 0, 380, 600, "REMOVE", @WC, {Fill: "#404048", Rect: {} }

    ######

    @scrollBlock = @cjAddContainer 20, 120, "REMOVE", @WC
    @headBlock   = @cjAddContainer 0, 0, "REMOVE", @WC

    @renderHead()

    @textForceEvil = @cjAddText 17.5      , 96, "", "14px RR", "#ecf0f1", "Booster", @headBlock, {textAlign: "left"}
    @textForceGood = @cjAddText 380 - 17.5, 96, "", "14px RR", "#ecf0f1", "Booster", @headBlock, {textAlign: "right"}

    @addCloseBtn @headBlock
    @resetPage()
    @show()

  renderHead: ->
    @cjAddDraw 0, 0, 380, 120, "REMOVE", @headBlock, {Fill: "#404048", Rect: {} }

    @friendBtnHead = @cjAddContainer 80 + 17.5, 60, "REMOVE", @headBlock
    btn1 = {x: 0, y: 0, w: 80, h: 30, n: "REMOVE", p: @friendBtnHead, o: {Fill: "#33333a", RoundRect: [15, 15, 15, 15] } }
    btn2 = {x: 0, y: 0, w: 80, h: 30, n: "REMOVE", p: @friendBtnHead, o: {Fill: "#585862", RoundRect: [15, 15, 15, 15] } }
    btn3 = {x: 0, y: 0, w: 80, h: 30, n: "REMOVE", p: @friendBtnHead, o: {Fill: "#29292f", RoundRect: [15, 15, 15, 15] } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @friendBtnHead
    @friendBtnHeadActive1 = @cjAddDraw 2, 2, 76, 26, "REMOVE", @friendBtnHead, {Fill: "#404048", RoundRect: [13, 13, 13, 13] }, {visible: true}
    text = @cjAddText 0, 5, "Друзья", "14px RR", "#ecf0f1", "REMOVE", @friendBtnHead, {width: 80}

    @friendBtnHead.addEventListener "click", (val) => @resetFriendBlock()


    @worldBtnHead = @cjAddContainer 80 * 2 + 17.5 + 10 , 60, "REMOVE", @headBlock
    btn1 = {x: 0, y: 0, w: 80, h: 30, n: "REMOVE", p: @worldBtnHead, o: {Fill: "#33333a", RoundRect: [15, 15, 15, 15] } }
    btn2 = {x: 0, y: 0, w: 80, h: 30, n: "REMOVE", p: @worldBtnHead, o: {Fill: "#585862", RoundRect: [15, 15, 15, 15] } }
    btn3 = {x: 0, y: 0, w: 80, h: 30, n: "REMOVE", p: @worldBtnHead, o: {Fill: "#29292f", RoundRect: [15, 15, 15, 15] } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @worldBtnHead
    @worldBtnHeadActive1 = @cjAddDraw 2, 2, 76, 26, "REMOVE", @worldBtnHead, {Fill: "#404048", RoundRect: [13, 13, 13, 13] }, {visible: true}
    text = @cjAddText 0, 5, "В мире", "14px RR", "#ecf0f1", "REMOVE", @worldBtnHead, {width: 80}

    @worldBtnHead.addEventListener "click", (val) => @resetWorldBlock()

    @cjAddText @model.get("xTitle"), 20, "СТАТИСТИКА", "24px RM", "#ecf0f1", "REMOVE", @WC, {textAlign: @model.get("textAlignTitle")}

  resetAllBlock: ->
    @cjRemove @FBC, @WC if @FBC?
    @cjRemove @WBC, @WC if @WBC?

    @cjRemove @scroll, @scrollBlock if @scroll

    createjs.Tween.get @scrollBlock
    .to
      y: 120

    @friendBtnHeadActive1.visible = true
    @worldBtnHeadActive1.visible  = true

  resetPage: ->
    @currentPage ?= "friend"

    if @currentPage == "friend" then @resetFriendBlock()
    if @currentPage == "world"  then @resetWorldBlock()

  resetFriendBlock: ->
    @currentPage = "friend"
    @resetAllBlock()
    @renderFriendBlock()

  resetWorldBlock: ->
    @Server.call "/getWorldStatistic", {}, (res) =>
      @currentPage = "world"
      @resetAllBlock()

      if @PM.get('socialNetwork') == 'test'
        @renderWorldBlock res.people, @PM.get('globalEvilAll'), @PM.get('globalGoodAll')
      else
        @renderWorldBlock res.people, @PM.get('globalEvilNetwork'), @PM.get('globalGoodNetwork')

  ########## ########## ########## ########## ##########

  renderForces: (evil, good) ->
    evil = @Controller.changeNumber evil, true, true
    good = @Controller.changeNumber good, true, true
    @textForceEvil.children[0].text = "Сила зла: #{evil}"
    @textForceGood.children[0].text = "Сила добра: #{good}"

  renderFriendBlock: ->
    @friendBtnHeadActive1.visible = false

    evil = _.reduce(@PM.get('friendsPlay'), ((memo, val) => memo + val.forceEvil), 0)
    good = _.reduce(@PM.get('friendsPlay'), ((memo, val) => memo + val.forceGood), 0)
    evil += @PM.get 'forceEvil'
    good += @PM.get 'forceGood'
    @renderForces evil, good

    people = @sortPeople @PM.get('friendsPlay')
    @setTotalHeight people

    @FBC = @cjAddContainer 0, 0, "REMOVE", @scrollBlock

    @renderCards people, @FBC

  renderWorldBlock: (people, evil, good) ->
    @worldBtnHeadActive1.visible = false

    @renderForces evil, good

    @setTotalHeight people

    @WBC = @cjAddContainer 0, 0, "REMOVE", @scrollBlock

    @renderCards people, @WBC

  sortPeople: (people) ->
    player = {
      id        : @PM.get('id')
      firstName : @PM.get('firstName')
      lastName  : @PM.get('lastName')
      photo100  : @PM.get('photo100')
      exp       : @PM.get('exp')
      level     : @PM.get('level')
      forceEvil : @PM.get('forceEvil')
      forceGood : @PM.get('forceGood')
      status    : @PM.get('status')
      isPlayer  : true
    }

    people = _.values people
    people.push player

    people = _.chain people
      .clone()
      .sortBy (val) => val.exp
      .sortBy (val) => val.level
      .reverse()
      .map (val, key) =>
        val.position = key + 1
        val
      .value();

    people

  renderCards: (people, parent) ->
    _w = 160
    _h = 170

    list = {}
    for val, key in people
      list[key] = {}

      _x = if key == 0 or key % 2 == 0 then 0 else 346 - _w
      _y = Math.floor key / 2

      color = switch key
        when 0 then '#fcf066'
        when 1 then '#ecf0f1'
        when 2 then '#977671'
        else '#4f4f5b'

      list[key].contMain = @cjAddContainer _x, (_y * _h) + ((346 - _w * 2) * _y), "REMOVE", parent
      list[key].bgMain   = @cjAddDraw 0, 0, _w, _h, "REMOVE", list[key].contMain, {Fill: "#33333a", RoundRect: [5, 5, 5, 5] }

      list[key].bgPosit   = @cjAddDraw 0, 0, 30, null, "REMOVE", list[key].contMain, { Fill: color, Circle: {center: true} }, {}, true
      @cjAddText -4, 0, "#{val.position}", "18px RM", "#16191a", "REMOVE", list[key].contMain, {width: 30}

      cont = @cjAddDraw 0, 30, _w, 20, "REMOVE", list[key].contMain, { Fill: '#33333a', Rect: {} }
      text = @cjAddText 0, 28, "#{val.firstName} #{val.lastName}", "16px RM", "#ecf0f1", "REMOVE", list[key].contMain, {width: _w}
      text.mask = cont

      list[key].contPhoto = @cjAddContainer _w / 2 - 60 / 2, 58, "REMOVE", list[key].contMain
      cont = @cjAddDraw 0, 0, 30, null, "REMOVE", list[key].contPhoto, { Fill: '#33333a', Circle: {center: false} }
      img  = @cjAddBitmap 0, 0, val.photo100, list[key].contPhoto, { scaleX: 0.6, scaleY: 0.6}

      img.mask = cont

      evil = @Controller.changeNumber val.forceEvil, true, true
      @cjAddText 0                     , 71, "#{evil}", "14px RR", "#db2c2c", "REMOVE", list[key].contMain, {width: _w / 2 - 60 / 2}

      good = @Controller.changeNumber val.forceGood, true, true
      @cjAddText (_w / 2 - 60 / 2) + 60, 76, "#{good}", "14px RR", "#1aa1d9", "REMOVE", list[key].contMain, {width: _w / 2 - 60 / 2}

      @cjAddText 0, 125, "#{@Controller.getStatusText(val.forceEvil, val.forceGood)}", "14px RR", "#ecf0f1", "REMOVE", list[key].contMain, {width: _w}
      @cjAddText 0, 143, "#{val.level} уровень", "14px RR", "#ecf0f1", "REMOVE", list[key].contMain, {width: _w}

      list[key].bgPosit.shape.mask = list[key].bgMain

  setTotalHeight: (people) ->
    _w = 160
    _h = 170

    @count = Math.ceil(_.size(people) / 2)
    @totalH = (@count * _h) + ( (@count - 1) * (346 - _w * 2) )

  # добавляем прокрутку
  doScroll: (e) =>
    e = window.event ? e
    delta = Math.max(-1, Math.min(1, (e.wheelDelta || -e.detail)))

    return if @count <= 2

    _y = 50
    if delta == 1 and @scrollBlock.y < 120
      if @scrollBlock.y + _y > 120 then _y = 120 - @scrollBlock.y
      createjs.Tween.get(@scrollBlock).to({y: @scrollBlock.y + _y})
    else if delta == -1 and 120 - @scrollBlock.y < @totalH - 480
      if 120 - (@scrollBlock.y - _y) > @totalH - 480
        _y = (120 - (@scrollBlock.y - _y)) - (@totalH - 480)

      createjs.Tween.get(@scrollBlock).to({y: @scrollBlock.y - _y})

module.exports = StatisticView
