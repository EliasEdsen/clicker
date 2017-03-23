GS = require '../gameSettings.json'

class BackgroundModel extends Backbone.Model
  getController: (@Controller) ->
    @PM = @Controller.Player.model

  create: ->
    @set 'anim', false

  getBackground: ->
    maxHeight = 6340 - 600
    middle    = maxHeight / 2

    limit = GS.limit

    diff = @PM.get("forceGood") - @PM.get("forceEvil")

    if diff <  0 && -diff > limit then return maxHeight # evil
    if diff >  0 &&  diff > limit then return 0 # good
    if diff == 0 then return middle # neutral

    percentDiff = 100 / limit * diff
    result = (middle / 100) * percentDiff

    middle - result # evil

module.exports = BackgroundModel
