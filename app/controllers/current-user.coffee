`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`


controller = Ember.ObjectController.extend
  needs: ["login"]

   # disable graph
  graphable: Em.computed(->
    if @get("settings.graphable") is undefined
      false
    else
      JSON.parse(@get("settings.graphable"))
  ).property("settings.graphable")

  loggedIn: Ember.computed.alias("controllers.login.isAuthenticated")

  defaultStartDate: moment().utc().subtract(40,"days").startOf("day")
  defaultEndDate: moment().utc().startOf("day")

  ### PUSHER ###
  pusherChannels: []
  modelDidLoad: (->
    if @get("loggedIn") and not @get("checked_in_today")
      @set("checked_in_today", true)
      Ember.run.next => @transitionToRoute("graph.checkin", "today", 1)

    if @get("pusher.enabled")
      @get("pusherChannels").addArrayObserver(@,
        didChange: (channels, offset, removeAmt, addAmt) =>
          if addAmt
            range = [offset..(addAmt-1+offset)]
            channels.objectsAt(range).forEach (channel) => @get("pusher").subscribe(channel)

        willChange: (channels, offset, removeAmt, addAmt) =>
          # if removeAmt
          #   range = [offset..(removeAmt-1+offset)]
          #   channels.objectsAt(range).forEach (channel) =>
          #     @get("pusher").unsubscribe(channel)

    )

    @subscribe("notifications")

  ).observes("obfuscated_id").on("model.didLoad")

  subscribe: (channel) -> @get("pusherChannels").addObject "#{channel}_#{@get("obfuscated_id")}" unless @get("pusherChannels")["#{channel}_#{@get("obfuscated_id")}"]

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