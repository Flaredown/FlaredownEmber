`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

controller = Ember.Controller.extend GroovyResponseHandlerMixin,
  init: ->
    @_super()
    @get("setValidationsByName")

  isAuthenticated: Ember.computed ->
    @get("currentUser.model.id")
  .property("currentUser.model")

  resetFormProperties: "email password".w()

  redirectToTransition: ->
    attemptedTransition = @get("attemptedTransition")
    if attemptedTransition and attemptedTransition.targetName isnt "index"
      attemptedTransition.retry()
      @set("attemptedTransition", null)
    else
      @transitionToRoute(config.afterLoginRoute)

  # credentialsObserver: Ember.observer ->
  #   if Ember.isEmpty(@get("loginId"))
  #     $.removeCookie("loginId")
  #   else
  #     $.cookie("loginId", @get("loginId"))
  # .observes("loginId")

  actions:
    login: ->
      that = @
      data = {}
      data["v#{config.apiVersion}_user"] = @getProperties("email", "password")

      ajax("#{config.apiNamespace}/users/sign_in.json",
        type: "POST"
        data: data
      ).then(
        (response) => # @set "controllers.currentUser.model", @store.createRecord("currentUser", response)
          @store.find("currentUser", 0).then(
            (currentUser) =>
              @set("currentUser.model", currentUser)

              # Ask the API for the locale for the current user
              ajax("#{config.apiNamespace}/locales/#{@get("currentUser.locale")}.json").then(
                (locale) =>
                  Ember.I18n.translations = locale
                  @redirectToTransition()

                (response) =>
                  @errorCallback(response, @) # TODO this doesn't work
              )
            ,
            -> # @errorCallback(response, @) # TODO this doesn't work
          )

        (response) => @errorCallback(response, @)
      )

    # logout: ->
    #   $.ajax
    #     url: "#{config.apiNamespace}/users/sign_out.json"
    #     type: "DELETE"
    #     context: @
    #     success: (response) ->
    #       @get("currentUser.pusherChannels").clear()
    #       @transitionToRoute("login")
    #     error: (response) -> @transitionToRoute("login")

`export default controller`