`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import UserSetupMixin from '../mixins/user_setup'`
`import FormHandlerMixin from '../mixins/form_handler'`
`import EmailPassValidations from '../mixins/email_pass_validations'`

controller = Ember.Controller.extend FormHandlerMixin, EmailPassValidations, UserSetupMixin,

  success: false
  translationRoot: "unauthenticated"
  queryParams: ["resetToken"]

  fields: "email".w()
  requirements: "email".w()
  validations:  "email".w()

  tokenWatcher: Em.observer(->
    if @get("resetToken")
      @set "fields", "password password_confirmation".w()
      @set "requirements", "password password_confirmation".w()
      @set "validations",  "password password_confirmation".w()
  ).observes("resetToken")

  actions:
    resetPass: ->
      if @saveForm()
        data = {}
        data["v#{config.apiVersion}_user"] = @getProperties("password", "password_confirmation")
        data["v#{config.apiVersion}_user"] = {reset_password_token: @get("resetToken")}

        ajax("#{config.apiNamespace}/users/password.json",
          type: "PUT"
          data: data
        ).then(
          (response) =>
            @endSave()
            @setupUser(@container)
            # @transitionToRoute(config.afterLoginRoute)
          @errorCallback.bind(@)
        )

    requestInstructions: ->
      if @saveForm()
        data = {}
        data["v#{config.apiVersion}_user"] = @getProperties("email")

        ajax("#{config.apiNamespace}/users/password.json",
          type: "POST"
          data: data
        ).then(
          (response) =>
            @set("success", true)
            @endSave()
          @errorCallback.bind(@)
        )

`export default controller`