`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`


controller = Ember.ObjectController.extend
  needs: ["login"]

  loggedIn: Ember.computed( -> parseInt(@get("model.id")) ).property("model.id")

  defaultStartDate: moment().utc().subtract(40,"days").startOf("day")
  defaultEndDate: moment().utc().startOf("day")

  ### PUSHER ###
  # pusherChannels: []
  modelDidLoad: (->
    dob = @get("momentDob").unix() if @get("momentDob")

    window.intercomSettings = {
      email: @get("email"),
      user_hash: @get("intercom_hash")
      user_country: @get("settings.location")
      sex: @get("settings.sex")
      born_at: dob
      onboarded: @get("onboarded")
      created_at: moment(this.get("created_at")).utc().unix(),
      app_id: config.intercom_id
    }

    @setupIntercom() if config.environment is "production"
  #   if @get("pusher.enabled")
  #     @get("pusherChannels").addArrayObserver(@,
  #       didChange: (channels, offset, removeAmt, addAmt) =>
  #         if addAmt
  #           range = [offset..(addAmt-1+offset)]
  #           channels.objectsAt(range).forEach (channel) => @get("pusher").subscribe(channel)
  #
  #       willChange: (channels, offset, removeAmt, addAmt) =>
  #         # if removeAmt
  #         #   range = [offset..(removeAmt-1+offset)]
  #         #   channels.objectsAt(range).forEach (channel) =>
  #         #     @get("pusher").unsubscribe(channel)
  #
  #   )
  #
  #   @subscribe("notifications")
  #
  ).observes("obfuscated_id").on("model.didLoad")

  subscribe: (channel) -> @get("pusherChannels").addObject "#{channel}_#{@get("obfuscated_id")}" unless @get("pusherChannels")["#{channel}_#{@get("obfuscated_id")}"]

  setupIntercom: ->
    w = window
    ic = w.Intercom

    l = ->
      s = d.createElement('script')
      s.type = 'text/javascript'
      s.async = true
      s.src = 'https://widget.intercom.io/widget/zi05kys7'
      x = d.getElementsByTagName('script')[0]
      x.parentNode.insertBefore s, x
      return

    if typeof ic == 'function'
      ic 'reattach_activator'
      ic 'update', intercomSettings
    else
      d = document

      i = ->
        i.c arguments
        return

      i.q = []

      i.c = (args) ->
        i.q.push args
        return

      w.Intercom = i
      if w.attachEvent
        w.attachEvent 'onload', l
      else
        w.addEventListener 'load', l, false

  actions:
    toggleGraph: ->
      graphable = not @get("graphable")
      @set("settings.graphable", "#{graphable}")
      ajax("#{config.apiNamespace}/me.json",
        type: "POST"
        data: {settings: {graphable: graphable}}
      ).then(
        (response) => window.location = "/"
        (response) => null
      )


`export default controller`