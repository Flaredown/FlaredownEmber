`import Ember from 'ember'`
`import UserSetupMixin from '../mixins/user_setup'`

initializer = Ember.Object.create {
  name: "currentUser"
  after: "store"

  initialize: (container, application) ->
    currentUserController = container.lookup("controller:currentUser")

    # Register the `user:current` namespace
    container.register 'current-user:current', currentUserController, { instantiate: false, singleton: true }

    # Inject the namespace into controllers and routes
    container.injection('route', 'currentUser', 'current-user:current')
    container.injection('controller', 'currentUser', 'current-user:current')
    container.injection('component', 'currentUser', 'current-user:current')
    container.injection('model', 'currentUser', 'current-user:current')
    container.injection('view', 'currentUser', 'current-user:current')

    UserSetupMixin.apply({}).setupUser(container)
}

`export default initializer`