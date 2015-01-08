`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: ["login"]

  loggedIn: Ember.computed ->
    @get("controllers.login.isAuthenticated")
  .property("controllers.login.isAuthenticated")

  defaultStartDate: moment().utc().subtract(40,"days").startOf("day")
  defaultEndDate: moment().utc().startOf("day")

  ### PUSHER ###
  pusherChannels: []
  modelDidLoad: (->
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



`export default controller`