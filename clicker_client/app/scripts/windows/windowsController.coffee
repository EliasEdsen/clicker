MenuView         = require "./menuView.coffee"
MenuModel        = require "./menuModel.coffee"
ShopView         = require "./shopView.coffee"
ShopModel        = require "./shopModel.coffee"
BankView         = require "./bankView.coffee"
BankModel        = require "./bankModel.coffee"
AchievmentsView  = require "./achievmentsView.coffee"
AchievmentsModel = require "./achievmentsModel.coffee"
StatisticView    = require "./statisticView.coffee"
StatisticModel   = require "./statisticModel.coffee"

windows = {}
windows.queue = []
windows.params = {}
windows.prevWindow = null
windows.current = null

#####
doScroll = (evt) =>
  windows.current?.doScroll?(evt)
  evt.preventDefault()

if window.addEventListener
  window.addEventListener("mousewheel", doScroll, false)
  window.addEventListener("DOMMouseScroll", doScroll, false)
else
  window.attachEvent("onmousewheel", doScroll)
#####

windows.getController = (controller) =>
  windows.controller = controller

windows.openWindow = (name, params = {}) =>
  if windows.current?
    if not windows.current.isShow
      windows.closeAll name

  windows.addParams name, params
  windows.addWindowInQueue name

windows.addParams = (name, params) =>
  windows.params[name] = params

windows.getParams = (name) =>
  params = windows.params[name]
  delete windows.params[name]
  params

windows.addWindowInQueue = (name) =>
  windows.queue.push name
  windows.queue = _.uniq windows.queue

  windows.openNextWindow()

windows.openNextWindow = =>
  return if windows.current?
  return if _.size(windows.queue) == 0

  name = _.first windows.queue

  params = windows.getParams name
  windows.render name, params

windows.render = (name, params) =>
  windows.current = switch name
    when "Menu"        then new MenuView        model: new MenuModel
    when "Shop"        then new ShopView        model: new ShopModel
    when "Bank"        then new BankView        model: new BankModel
    when "Achievments" then new AchievmentsView model: new AchievmentsModel
    when "Statistic"   then new StatisticView   model: new StatisticModel

  windows.current.getController       windows.controller
  windows.current.model.getController windows.controller

  windows.current.isShow = false

  windows.current.render(params)

windows.show = =>
  Blackout = windows.controller.Blackout

  windows.current.isShow = true

  wcm = windows.current.model
  windows.controller.openingWindow wcm.get("start")
  Blackout.blackoutOn wcm.get('start'), wcm.get('nameWindow')

  windows.current._show()

windows.close = =>
  if windows.current?
    windows.current._hide () =>
      windows.current.remove()
      windows.current.afterRemove () =>
        windows.prevWindow = windows.current
        windows.current = null
        windows.queue = _.rest windows.queue
        windows.openNextWindow()

  windows.controller.closingWindow()

  if _.size(windows.queue) <= 1
    windows.controller.Blackout.blackoutOff()

windows.closeAll = (newWindow) =>
  if windows.current?
    windows.current._hide () =>
      windows.current.remove()
      windows.current.afterRemove () =>
        windows.prevWindow = windows.current
        windows.current = null
        windows.queue = []
        windows.addWindowInQueue newWindow

  if not newWindow?
    windows.controller.Blackout.blackoutOff()

module.exports = windows
