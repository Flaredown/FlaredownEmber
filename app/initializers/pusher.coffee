`import Ember from 'ember'`
`import pusher from '../utils/pusher-ember'`

initializer = {
  name: "pusher"
  before: "currentUser"

  initialize: (container, application) ->
    # use the same instance of Pusher everywhere in the app
    container.optionsForType('pusher', { singleton: true })

    # register 'pusher:main' as our Pusher object
    container.register('pusher:main', pusher)

    # inject the Pusher object into all controllers and routes
    container.typeInjection('controller', 'pusher', 'pusher:main')
    container.typeInjection('route', 'pusher', 'pusher:main')
}

`export default initializer`