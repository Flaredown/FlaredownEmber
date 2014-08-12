`import Ember from 'ember'`

init = {
  name: "currentUser"
  after: 'pusher'

  initialize: (container, application) ->
   currentUserController = container.lookup("controller:currentUser")

   # Register the `user:current` namespace
   container.register 'current-user:current', currentUserController, { instantiate: false, singleton: true }
   Ember.debug("Current User Inject: #{currentUserController}")
   # Inject the namespace into controllers and routes
   container.injection('route', 'currentUser', 'current-user:current')
   container.injection('controller', 'currentUser', 'current-user:current')
}
`export default init`