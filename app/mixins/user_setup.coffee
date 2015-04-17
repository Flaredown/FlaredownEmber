`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../config/environment'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

mixin = Ember.Mixin.create GroovyResponseHandlerMixin,

  setupUser: (container) ->
    @app           = container.lookup("application:main")
    @controller    = container.lookup("controller:currentUser")
    @app_is_ready  = @app._readinessDeferrals is 0

    @app.deferReadiness() unless @app_is_ready

    @controller.store.find("currentUser", 0).then(
      (currentUser) =>
        @controller.set "content", currentUser
        window.treatmentColors  = @controller.get("treatmentColors")
        window.symptomColors    = @controller.get("symptomColors")

        @getLocale()

      (response) =>
        @errorCallback(response).bind(@) unless response.status is 401 # don't error on unauthorized, they'll be sent to login instead
        @getLocale()

    )

  getLocale: ->
    unless @controller.get("locale")
      @controller.set("content", {locale: "en"})

    # Ask the API for the locale for the current user
    ajax("#{config.apiNamespace}/locales/#{@controller.get("locale")}").then(
      (locale) =>
        # Setup the translations if they aren't already
        if Ember.typeOf(Ember.I18n.translations) is "object" then Ember.I18n.translations = Ember.Object.create({})
        Ember.I18n.translations.setProperties locale[@controller.get("locale")]

        if @app_is_ready
          # Send to proper place based on login status
          @controller.get("controllers.login").redirectToTransition() if @controller.get("controllers.login.isAuthenticated")
        else
          @app.advanceReadiness()


      (response) =>
        @errorCallback(response)
        @app.advanceReadiness() unless @app_is_ready
    )

`export default mixin`