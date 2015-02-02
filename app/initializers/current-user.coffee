`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`


initializer = {
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
    container.injection('view', 'currentUser', 'current-user:current')

    application.deferReadiness()
    container.lookup("store:main").find("currentUser", 0).then(
      (currentUser) =>
        currentUserController.set "content", currentUser

        if currentUserController.get("loggedIn")

          # Ask the API for the locale for the current user
          ajax("#{config.apiNamespace}/locales/#{currentUserController.get("locale")}").then(
            (locale) =>
              Ember.I18n.translations = locale

            (response) =>
              @errorCallback(response, @) # TODO this doesn't work
          )

        application.advanceReadiness()

      (response) ->
        # @errorCallback(response, @) # TODO this doesn't work
        application.advanceReadiness()
    )
}
`export default initializer`