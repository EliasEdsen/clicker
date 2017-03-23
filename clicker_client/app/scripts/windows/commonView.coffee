GS = require "../gameSettings.json"
CreatejsBaseView = require "../createjsBaseView.coffee"

class CommonView extends CreatejsBaseView
  getController: (@Controller) ->
    @Field      = @Controller.Field
    @Player     = @Controller.Player
    @PM         = @Player.model
    @UpperLayer = @Controller.UpperLayer
    @windows    = @Controller.windows
    @Server     = @Controller.Server
    @API        = @Controller.API
    @info       = @Controller.information

  render: ->
    @WC = @cjAddContainer @model.get("start"), 0, "REMOVE", canvas

  addCloseBtn: (parent = @WC) ->
    if @model.get("start") <= 0 then x = 17.5 else x = 380 - 17.5 - 44
    @CBC = @cjAddContainer x, 14, "REMOVE", parent, {width: 44, height: 44}

    btn1 = {x: 0, y: 0, w: 22, h: null, n: "REMOVE", p: @CBC, o: {Fill: "#ecf0f1", Circle: {center: false} } }
    btn2 = {x: 0, y: 0, w: 22, h: null, n: "REMOVE", p: @CBC, o: {Fill: "#ffffff", Circle: {center: false} } }
    btn3 = {x: 0, y: 0, w: 22, h: null, n: "REMOVE", p: @CBC, o: {Fill: "#cccccc", Circle: {center: false} } }
    @cjAddHoverActiveBlock btn1, btn2, btn3, @CBC

    @cjAddImage 0, 0, "closeIco", @CBC

    @CBC.addEventListener "click", => @windows.close()

  show: -> @windows.show()

  _show: (cb) ->
    createjs.Tween.get @WC
      .to
        x: @model.get "end"
      , GS.Speed * 3

  _hide: (cb) ->
    createjs.Tween.get @WC
      .to
        x: @model.get "start"
      , GS.Speed * 3
      .call =>
        cb?()

  remove: ->
    @stopListening() # backbone'овская штука
    @cjRemove @WC
    @WC = null

  afterRemove: (cb) ->
    cb?()

module.exports = CommonView
