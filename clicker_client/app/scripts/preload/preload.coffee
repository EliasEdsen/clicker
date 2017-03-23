Controller = require "../controller.coffee"
GS = require "../gameSettings.json"
manif = require './loadManifest.json'

class Preload extends Backbone.Model
  initialize: ->
    global.preload = new createjs.LoadQueue(true)

    timeout = false
    loaded = false

    _.delay () =>
      if not loaded
        console.error 'Error', 'Сервер не отвечает. ;)'
        $('.errorBlock').show()
        $('.errorBlock').find('.message').html('Сервер не отвечает.<br />Скоро все заработает ;)<br />')
        timeout = true
    , 60000

    async.series [
      @preloadResources
      @preloadSounds
      @preloadData
      ], (err, results) =>
        if not timeout
          loaded = true
          if err?
            console.error 'Error', err
            $('.errorBlock').show()
            $('.errorBlock').find('.message').html(err.message)
            timeout = true
          else
            data = _.compact(results)[0]
            Controller = new Controller
            Controller.getDataFirst(data)
            Controller.includeAll()

  getManifest: (names) ->
    if not names?
      names = []
      for key of manif
        names.push key

    result = []

    for name in names
      for key, valArr of manif[name]
        result.push valArr

    result

  #####

  preloadResources: (callback) =>
    fileProgressResources = =>
      progress = (preload.progress * 100|0) + " % Загружено";
      $(".loader").text(progress)

    fileLoadResources = (val) => console.log "A file has loaded of type: #{val.item.type}, id: #{val.item.id}"

    errorLoadResources = (val) =>
      preload.removeAllEventListeners()

      err =
        description: "Не удалось загрузить<br>необходимые файлы =("
        fileName: val

      callback(err, null)

    completeResources = =>
      preload.removeAllEventListeners()
      callback(null, null)

    createjs.Sound.alternateExtensions = ["mp3"]
    preload.installPlugin(createjs.Sound)

    preload.addEventListener("progress", fileProgressResources)
    preload.addEventListener("fileload", fileLoadResources)
    preload.addEventListener("complete", completeResources)
    preload.addEventListener("error"   , errorLoadResources)

    if not createjs.Sound.initializeDefaultPlugins()
      err =
        description: "Не удалось подключить Canvas :'( <br> Обновите ваш браузер"
      callback(err, null)

    if not createjs.Sound.registerPlugins([createjs.HTMLAudioPlugin])
    # if not createjs.Sound.registerPlugins([createjs.HTMLAudioPlugin, createjs.WebAudioPlugin, createjs.FlashPlugin])
      err =
        description: "Не удалось подключить Canvas :'( <br> Обновите ваш браузер"
      callback(err, null)


    preload.loadManifest @getManifest()

  #####

  preloadSounds: (callback) =>
  #   completeSounds = => callback(null, null)

    global.Sound = require "./sounds.coffee"
    callback(null, null)

  #   m = @getManifest ["music"]
  #   s = @getManifest ["sound"]

  #   Sound.init({"music": m, "sound": s}, completeSounds)

  #####

  preloadData: (cb) ->
    getMyId = (callback) =>
      user = {}

      if socialNetwork == "test"
        user.id = user.firstName = user.lastName = prompt("id", '1')
        user.id = Number user.id
        user.socialNetwork = socialNetwork
        user.photo100 = "http://cdn-frm-eu.wargaming.net/wot/eu//profile/5/62/8/photo-517086205-566f3cf8.png"

        while _.isNaN(user.id)
          alert 'type must be "Number"'
          user.id = user.firstName = user.lastName = prompt("id", '1')
          user.id = Number user.id

        if not _.isNaN user.id then callback(null, user)

      if socialNetwork == "vk"

        if DEBUG_MODE then console.log "Client => VK_Server : /users.get"

        VK.api "users.get", {"fields":"photo_100"}, (res) =>
          if DEBUG_MODE then console.log "VK_Server => Client : /users.get", res.response

          if res.error?
            console.error "VK_Server => Client : /users.get", res.error

            err = res
            err.description = 'Скоро все починим ;)'
            callback(err, null)

          user =
            id            : res.response[0].uid
            firstName     : res.response[0].first_name
            lastName      : res.response[0].last_name
            photo100      : res.response[0].photo_100
            socialNetwork : socialNetwork

          callback(null, user)

    getFriendsID = (user, callback) =>
      switch socialNetwork
        when 'test'
          user.friendsAllId = _.without [1..10], Number(user.id)
          callback(null, user)

        when 'vk'
          if DEBUG_MODE then console.log "Client => VK_Server : /friends.getAppUsers"

          VK.api "friends.getAppUsers", {}, (res) =>
            if DEBUG_MODE then console.log "VK_Server => Client : /friends.getAppUsers", res.response

            if res.error?
              console.error "VK_Server => Client : /friends.getAppUsers", res.error

              err = res
              err.description = 'Скоро все починим ;)'
              callback(err, null)

            user.friendsAllId = res.response
            callback(null, user)

    getFromServer = (_user, callback) =>
      if DEBUG_MODE then console.log "Client => Server : authorization :", user

      user = JSON.stringify _user

      $.ajax
        url      : "//#{GS.IP}:20001/authorization"
        type     : 'POST'
        dataType : 'json'
        data     : user
      .done (response) =>
        if DEBUG_MODE then console.log "Server => Client : authorization :", response

        if response.err? then return callback(response.err, null)

        # пересоберем
        data = {}

        data.info               = response.res[0]
        data.user               = response.res[1]

        data.user.friendsPlay    = response.res[2].friendsPlay
        data.user.friendsNotPlay = response.res[2].friendsNotPlay

        data.user.levelOpenForce           = 5
        data.user.levelOpenPlayerDoubleStr = 4
        data.user.levelOpenBotDoubleStr    = 7
        data.user.levelOpenBotDoubleSpeed  = 10

        data.user.forceEvilOld        = data.user.forceEvil
        data.user.forceGoodOld        = data.user.forceGood

        data.user.playerDoubleStrTimePlus = 30
        data.user.botDoubleStrTimePlus    = 30
        data.user.botDoubleSpeedTimePlus  = 30

        for key, val of response.sync
          data.user[key] = val

        delete data.info._id
        delete data.user._id

        callback(null, data)

      .fail (err) =>
        console.error "Server => Client : authorization :", err
        if err.responseJSON.err? then callback(err.responseJSON.err, null)

    async.waterfall [
      getMyId
      getFriendsID
      getFromServer
      ], (err, results) =>
        if err? then return cb(err, null)

        delete global.socialNetwork
        cb(null, results)

  #####

module.exports = Preload
