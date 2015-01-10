`import Ember from 'ember'`
`import config from '../config/environment'`

pusher = Ember.Object.extend(
  key: config.pusher.key
  enabled : true
  init: ->
    if @get("key")
      @service = new Pusher(@get("key"))
      @service.connection.bind "connected", =>
        @connected()
        return

      @service.bind_all (eventName, data) =>
        @handleEvent eventName, data
        return
    else
      @set "enabled", false

  connected: ->
    @socketId = @service.connection.socket_id
    @addSocketIdToXHR()
    return


  # add X-Pusher-Socket header so we can exclude the sender from their own actions
  # http://pusher.com/docs/server_api_guide/server_excluding_recipients
  addSocketIdToXHR: ->
    Ember.$.ajaxPrefilter (options, originalOptions, xhr) =>
      xhr.setRequestHeader "X-Pusher-Socket", @socketId

    return

  subscribe: (channel) ->
    @service.subscribe channel

  unsubscribe: (channel) ->
    @service.unsubscribe channel

  handleEvent: (eventName, data) ->
    router = undefined
    unhandled = undefined

    # ignore pusher internal events
    return  if eventName.match(/^pusher:/)
    router = @get("container").lookup("router:main")
    try
      router.send eventName, data
    catch e
      unhandled = e.message.match(/Nothing handled the event/)
      throw e  unless unhandled
    return
)
Ember.ControllerMixin.reopen pusher: null

`export default pusher`