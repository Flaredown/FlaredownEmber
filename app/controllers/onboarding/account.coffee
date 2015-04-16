`import Ember from 'ember'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../../mixins/form_handler'`
`import AccountFormMixin from '../../mixins/account_form'`

controller = Ember.Controller.extend FormHandlerMixin, AccountFormMixin,

  translationRoot: "onboarding"

  actions:
    save: ->
      if @saveForm()
        ajax("#{config.apiNamespace}/me.json",
          type: "POST"
          data: {settings: @getProperties(@get("fields"))}
        ).then(
          (response) =>
            @endSave()
            @target.send("save") # bump to route
          (response) => @errorCallback(response, @)
        )
      else
        false

`export default controller`