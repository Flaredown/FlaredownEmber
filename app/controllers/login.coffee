`import Ember from 'ember'`
`import config from '../config/environment'`

controller = Ember.Controller.extend #App.ProfileValidationsMixin, App.FormStatesMixin,
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
      data = {}
      data["api_v#{config.apiVersion}_user"] = @getProperties("email", "password")

      Ember.$.ajax(
        type: "POST"
        url: "#{config.apiNamespace}/users/sign_in.json"
        data: data
        context: @

      ).then(
        (response) -> # @set "controllers.currentUser.model", @store.createRecord("currentUser", response)

          @store.find("currentUser", 0).then(
            (currentUser) =>
              @set("currentUser.model", currentUser)
              @redirectToTransition()
            ,
            -> console.log "!!! ERROR"
          )

        (response) -> @errorCallback
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