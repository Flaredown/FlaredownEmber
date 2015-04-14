`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import UserSetupMixin from '../mixins/user_setup'`

mixin = Ember.Mixin.create UserSetupMixin,

  needs: ["login"]
  translationRoot: "unauthenticated"
  modelClass: "user"

  defaults: Em.computed.alias("model")
  fields: "email password password_confirmation invitation_token".w()
  requirements: "email password password_confirmation".w()
  validations:  "email password password_confirmation".w()

  emailValid: Em.computed( ->
    email_regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    email_regex.test(@get("email"))
  ).property("email")

  passwordValid: Em.computed( -> @get("password.length") >= 2 ).property("password")
  password_confirmationValid: Em.computed( -> @get("password_confirmation") is @get("password") ).property("password_confirmation", "password")

  actions:
    register: ->
      if @saveForm()
        ajax(
          type: "PUT"
          url: "#{config.apiNamespace}/users/invitation.json"
          data: @getProperties(@get("fields"))
        ).then(
          (response) =>
            @endSave()
            @setupUser(@container)
            @transitionToRoute(config.afterLoginRoute)

          (response) => @errorCallback(response)
        )


`export default mixin`
