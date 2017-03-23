class FieldModel extends Backbone.Model
  getController: (@Controller) ->
    @PM    = @Controller.Player.model
    @Field = @Controller.Field
    @info  = @Controller.information

  create: ->
    @set 'isOpenForce'          , false
    @set 'isOpenPlayerDoubleStr', false
    @set 'isOpenBotDoubleStr'   , false
    @set 'isOpenBotDoubleSpeed' , false

  showHidden: ->
    if @PM.get('level') >= @PM.get('levelOpenForce') and not @get('isOpenForce')
      @set 'isOpenForce', true
      @Field.showHiddenForce()

    if @PM.get('level') >= @PM.get('levelOpenPlayerDoubleStr') and not @get('isOpenPlayerDoubleStr')
      @set 'isOpenPlayerDoubleStr', true
      @Field.showHiddenPlayerDoubleStr()

    if @PM.get('level') >= @PM.get('levelOpenBotDoubleStr') and not @get('isOpenBotDoubleStr')
      @set 'isOpenBotDoubleStr', true
      @Field.showHiddenBotDoubleStr()

    if @PM.get('level') >= @PM.get('levelOpenBotDoubleSpeed') and not @get('isOpenBotDoubleSpeed')
      @set 'isOpenBotDoubleSpeed', true
      @Field.showHiddenBotDoubleSpeed()

  playerDoubleStr: (cb) -> @PM.playerDoubleStr cb
  botDoubleStr:    (cb) -> @PM.botDoubleStr cb
  botDoubleSpeed:  (cb) -> @PM.botDoubleSpeed cb

  forceEvilAdd: -> @PM.forceEvilAdd()
  forceGoodAdd: -> @PM.forceGoodAdd()

  checkCloseForceEvil: (returnTotalForce = false) ->
    res = null

    res = _.find @info.shop.thing, (val) =>
      val.force == 'forceEvil' and val.position == _.size(@PM.get('thingsEvil'))

    if not res? then return false

    if returnTotalForce then return res.need.force
    @PM.get('forceEvil') > res.need.force

  checkCloseForceGood: (returnTotalForce = false) ->
    res = null

    res = _.find @info.shop.thing, (val) =>
      val.force == 'forceGood' and val.position == _.size(@PM.get('thingsGood'))

    if not res? then return false

    if returnTotalForce then return res.need.force
    @PM.get('forceGood') > res.need.force

  getNewLevel: -> @PM.getNewLevel()

module.exports = FieldModel
