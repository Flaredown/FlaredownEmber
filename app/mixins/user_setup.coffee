`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`

mixin = Ember.Mixin.create

  setupUser: (container) ->
    app           = container.lookup("application:main")
    controller    = container.lookup("controller:currentUser")
    app_is_ready  = app._readinessDeferrals is 0

    app.deferReadiness() unless app_is_ready

    controller.store.find("currentUser", 0).then(
      (currentUser) =>
        controller.set "content", currentUser
        window.treatmentColors  = controller.get("treatmentColors")
        window.symptomColors    = controller.get("symptomColors")

        if controller.get("loggedIn")

          # Ask the API for the locale for the current user
          ajax("#{config.apiNamespace}/locales/#{controller.get("locale")}").then(
            (locale) =>
              Ember.I18n.translations = locale
              controller.get("controllers.login").redirectToTransition()

            (response) =>
              @errorCallback(response, @) # TODO this doesn't work
          )

        app.advanceReadiness() unless app_is_ready

      (response) ->
        # @errorCallback(response, @) # TODO this doesn't work
        app.advanceReadiness() unless app_is_ready
    )

`export default mixin`