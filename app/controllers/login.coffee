`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../mixins/form_handler'`
`import UserSetupMixin from '../mixins/user_setup'`
`import EmailPassValidations from '../mixins/email_pass_validations'`

controller = Ember.Controller.extend FormHandlerMixin, UserSetupMixin, EmailPassValidations,
  translationRoot: "unauthenticated"

  queryParams: ["user_email", "user_token", "sso", "sig"]

  fields: "email password".w()
  requirements: "email password".w()
  validations:  "email password".w()

  isTalkLogin: Ember.computed( -> @get("sso") and @get("sig") ).property("sso","sig")
  isOutsideAuth: Ember.computed( -> @get("isTalkLogin") or @get("tokenLogin") ).property("isTalkLogin","tokenLogin")
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

            # Do single sign on for Discourse
            if @get("sso") and @get("sig")
              ajax("#{config.apiNamespace}/talk_sso.json}",
                type: "GET"
                data: {sso: @get("sso"), sig: @get("sig")}
              ).then(
                (response) => window.location = response.sso_url
                @errorCallback.bind(@)
              )
            else
              @setupUser(@container)

          @errorCallback.bind(@)
        )

    loginWithToken: ->
      @set("tokenLogin", true)
      ajax("#{config.apiNamespace}/current_user",
        type: "GET"
        data: @getProperties("user_email", "user_token")
      ).then(
        (response) => @setupUser(@container)
        @errorCallback.bind(@)
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