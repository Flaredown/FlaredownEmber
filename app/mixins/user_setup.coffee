`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

mixin = Ember.Mixin.create GroovyResponseHandlerMixin,

  setup: (container) ->
    @app           = container.lookup("application:main")
    @controller    = container.lookup("controller:currentUser")
    @store         = @controller.get("store")
    @app_is_ready  = @app._readinessDeferrals is 0

  setupUser: (container, payload) ->
    @setup(container)

    @app.deferReadiness() unless @app_is_ready

    promise = if payload
      payload.current_user = payload.user if payload.user

      @store.pushPayload("currentUser", payload)
      @store.find("currentUser", payload.current_user.id)
    else
      @store.fetchById("currentUser", 0)

    promise.then(
        (response) =>
          @controller.set "model", response
          window.user_id          = @controller.get("obfuscated_id")
          window.colors           = @controller.get("colors")

          @getLocale(container)

        (response) =>
          @errorCallback(response).bind(@) unless response.status is 401 # don't error on unauthorized, they'll be sent to login instead
          @controller.set "content", {}
          @getLocale(container)

      )

  getLocale: (container)->
    @setup(container)
    locale = @controller.get("locale") if @controller.get("locale")
    locale ||= "en"

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