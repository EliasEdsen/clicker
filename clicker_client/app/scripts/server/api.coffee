class API extends Backbone.Model
  initialize: -> if DEBUG_MODE then global.api = @

  getController: (@Controller) ->
    @PM = @Controller.Player.model

  call: (req, cb) ->
    if @PM.get("socialNetwork") == "vk"   then @call_vk   req, cb
    if @PM.get("socialNetwork") == "test" then @call_test req, cb

  call_test: (req, cb) ->
    if DEBUG_MODE then console.log "Client => Test_Server : /#{req.method} :", req
    if DEBUG_MODE then console.log "Test_Server => Client : /#{req.method} :", {}
    if DEBUG_MODE then alert "Вызов #{req.method}"
    cb?(null)

  call_vk: (req, cb) ->
    if DEBUG_MODE then console.log "Client => VK_Server : /#{req.method} :", req

    switch req.type
      when "api"                    # http://vk.com/dev/methods
        req.parameters ?= {}

        VK.api req.method, req.parameters, (res) =>
          if DEBUG_MODE then console.log "VK_Server => Client : /#{req.method} :", res

          if res.error?
            @Controller.showError res.error
          else
            cb?(res.response)

      when "callMethod"             # http://vk.com/dev/clientapi
        req.parameters ?= {}
        VK.callMethod(req.method, req.parameters)

module.exports = API
