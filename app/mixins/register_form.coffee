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
  fields: "email password password_confirmation invitation_token legal".w()
  requirements: "email password password_confirmation legal".w()
  validations:  "email password password_confirmation legal".w()

  legalValid: Em.computed.equal("legal", 1)

  actions:
    register: ->
      console.log @get("legal")
      if @saveForm()
        ajax(
          type: "PUT"
          url: "#{config.apiNamespace}/users/invitation.json"
          data: @getProperties(@get("fields"))
        ).then(
          (response) =>
            @endSave()
            @setupUser(@container, response)
            @transitionToRoute(config.afterLoginRoute)

          (response) => @errorCallback(response)
        )


`export default mixin`
