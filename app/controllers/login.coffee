`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`
`import UserSetupMixin from '../mixins/user_setup'`

controller = Ember.Controller.extend GroovyResponseHandlerMixin, UserSetupMixin,
  init: ->
    @_super()
    @get("setValidationsByName")

  isAuthenticated: Ember.computed ->
    @get("currentUser.model.id")
  .property("currentUser.model")

  resetFormProperties: "email password".w()

  queryParams: ["user_email", "user_token"]

  redirectToTransition: ->
    attemptedTransition = @get("attemptedTransition")
    if attemptedTransition and attemptedTransition.targetName isnt "index"
      attemptedTransition.retry()
      @set("attemptedTransition", null)
    else
      @transitionToRoute(config.afterLoginRoute)

  actions:
    login: ->
      data = {}
      data["v#{config.apiVersion}_user"] = @getProperties("email", "password")

      ajax("#{config.apiNamespace}/users/sign_in.json",
        type: "POST"
        data: data
      ).then(
        @setupUser(@container)
        # @loginCallback.bind(@)
        (response) => @errorCallback(response, @)
      )

    loginWithToken: ->
      ajax("#{config.apiNamespace}/current_user",
        type: "GET"
        data: @getProperties("user_email", "user_token")
      ).then(
        @setupUser(@container)
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