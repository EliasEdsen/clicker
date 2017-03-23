GS = require "../gameSettings.json"

class Server extends Backbone.Model
  initialize: -> if DEBUG_MODE then global.server = @

  getController: (@Controller) ->
    @PM      = @Controller.Player.model
    @Field   = @Controller.Field
    @windows = @Controller.windows

  call: (path, data, cb) ->
    data.id            = @PM.get "id"
    data.socialNetwork = @PM.get "socialNetwork"

    if DEBUG_MODE then console.log "Client => Server : #{path} :", data

    $.ajax
      url      : "//#{GS.IP}:20001#{path}"
      type     : 'POST'
      dataType : 'json'
      data     : JSON.stringify(data)
    .done (response) =>
      if DEBUG_MODE then console.log "Server => Client : #{path} :", response

      if response.err?
        console.error "Server => Client 1: #{path} :", response
        @Controller.showError response.err
      else
        if response.res.sync?
          _.each response.res.sync, (value, key) =>
            @PM.set("#{key}", value)

        if response.notification?
          switch response.notification.hashCode
            when 0 then @windows.closeAll 'Bank'
        else
          cb?(response.res)
    .fail (err) =>
      console.error "Server => Client 2: #{path} :", err
      @Controller.showError err.responseJSON.err

module.exports = Server
