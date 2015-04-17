`import Ember from 'ember'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../../mixins/form_handler'`

controller = Ember.Controller.extend FormHandlerMixin,

  translationRoot: "onboarding"

  defaults: Ember.computed(-> @get("currentUser.settings")).property("currentUser")
  fields: "ethnicOrigin occupation highestEducation activityLevel".w()
  requirements: "".w()
  validations:  "activityLevel".w()

  activityLevelValid: Em.computed(-> /\d+/.test(@get("activityLevel")) ).property("activityLevel")

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
          @errorCallback
        )
      else
        false


`export default controller`