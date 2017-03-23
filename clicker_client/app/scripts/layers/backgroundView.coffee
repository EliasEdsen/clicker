CreatejsBaseView = require "../createjsBaseView.coffee"
GS = require "../gameSettings.json"

class BackgroundView extends CreatejsBaseView
  getController: (@Controller) ->
    @PM = @Controller.Player.model

  create: ->
    @model.create()

    @BC = @cjAddContainer 0, 0, "REMOVE", canvas, {width: 760, height: 600}
    @back = @cjAddBitmap 0, 0, "./images/background.png", @BC, {}

    @setListens()

  ##########

  setListens: ->
    @listenTo @PM, 'change:forceEvil', @changeForces
    @listenTo @PM, 'change:forceGood', @changeForces

  ##########

  changeForces: ->
    @renderBackground true

  render: ->
    @renderBackground false

  renderBackground: (anim = true) =>
    speed = if anim then GS.Speed * 10 else 0

    if not @model.get("anim")
      createjs.Tween.get @back
        .call => @model.set "anim", true
        .to
          y: -@model.getBackground()
        , speed
        .call => @model.set "anim", false

module.exports = BackgroundView
