`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

mixin = Ember.Mixin.create GroovyResponseHandlerMixin,

  setupUser: (container) ->
    @app           = container.lookup("application:main")
    @controller    = container.lookup("controller:currentUser")
    @store         = @controller.get("store")
    @app_is_ready  = @app._readinessDeferrals is 0

    @app.deferReadiness() unless @app_is_ready

    ajax("#{config.apiNamespace}/current_user").then(
      (response) =>
        @store.pushPayload "currentUser", response
        model = @store.find("currentUser", "1")
        # WARNING: I think because deferReadiness is activated, the store does not sync so getLocale cannot depend on currentUser on first load

        @controller.set "model", model
        window.user_id          = response.current_user.obfuscated_id
        window.treatmentColors  = response.current_user.treatmentColors
        window.symptomColors    = response.current_user.symptomColors

        @getLocale("en")

      (response) =>
        @errorCallback(response).bind(@) unless response.jqXHR.status is 401 # don't error on unauthorized, they'll be sent to login instead
        @controller.set "content", {}
        @getLocale("en")

    )

  getLocale: (locale)->
    locale = @controller.get("locale") if @controller.get("locale")

    # Ask the API for the locale for the current user
    ajax("#{config.apiNamespace}/locales/#{locale}").then(
      (response) =>
        # Setup the translations if they aren't already
        if Ember.typeOf(Ember.I18n.translations) is "object" then Ember.I18n.translations = Ember.Object.create({})
        Ember.I18n.translations.setProperties response[locale]

        if @app_is_ready
          # Send to proper place based on login status
          Ember.run.next =>
            @controller.get("controllers.login").redirectToTransition() if @controller.get("loggedIn")
        else
          @app.advanceReadiness()


      (response) =>
        @errorCallback(response)
        @app.advanceReadiness() unless @app_is_ready
    )

`export default mixin`