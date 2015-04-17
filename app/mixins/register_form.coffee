`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import UserSetupMixin from '../mixins/user_setup'`
`import EmailPassValidations from '../mixins/email_pass_validations'`

mixin = Ember.Mixin.create UserSetupMixin, EmailPassValidations,

  needs: ["login"]
  translationRoot: "unauthenticated"
  modelClass: "user"

  defaults: Em.computed.alias("model")
  fields: "email password password_confirmation invitation_token".w()
  requirements: "email password password_confirmation".w()
  validations:  "email password password_confirmation".w()


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
