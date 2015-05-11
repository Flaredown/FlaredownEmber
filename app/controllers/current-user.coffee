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
  # modelDidLoad: (->
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
  # ).observes("obfuscated_id").on("model.didLoad")

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