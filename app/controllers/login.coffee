`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../mixins/form_handler'`
`import UserSetupMixin from '../mixins/user_setup'`

controller = Ember.Controller.extend FormHandlerMixin, UserSetupMixin,
  translationRoot: "unauthenticated"

  queryParams: ["user_email", "user_token"]

  fields: "email password".w()
  requirements: "email password".w()
  validations:  "email password".w()

  emailValid: Em.computed( ->
    email_regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    email_regex.test(@get("email"))
  ).property("email")
  passwordValid: Em.computed( -> @get("password.length") >= 2 ).property("password")

  isAuthenticated: Ember.computed(-> @get("currentUser.model.id") ).property("currentUser.model")

  redirectToTransition: ->
    attemptedTransition = @get("attemptedTransition")
    if attemptedTransition and attemptedTransition.targetName isnt "index"
      attemptedTransition.retry()
      @set("attemptedTransition", null)
    else
      @transitionToRoute(config.afterLoginRoute) if window.location.pathname is "/login"

  actions:
    login: ->
      if @saveForm()
        data = {}
        data["v#{config.apiVersion}_user"] = @getProperties("email", "password")

        ajax("#{config.apiNamespace}/users/sign_in.json",
          type: "POST"
          data: data
        ).then(
          (response) =>
            @endSave()
            @setupUser(@container)
          (response) => @errorCallback(response, @)
        )

    loginWithToken: ->
      ajax("#{config.apiNamespace}/current_user",
        type: "GET"
        data: @getProperties("user_email", "user_token")
      ).then(
        (response) => @setupUser(@container)
        (response) => @errorCallback(response, @)
      )

    logout: ->
      ajax(
        url: "#{config.apiNamespace}/users/sign_out.json"
        type: "GET"
        context: @
      ).then(
        (response) -> window.location = "/login"
        (response) => @transitionToRoute("login")
      )

`export default controller`