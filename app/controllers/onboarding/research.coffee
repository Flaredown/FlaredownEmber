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

  ethnicOriginOptions: Em.computed(-> Ember.keys(Ember.I18n.translations.onboarding.ethnic_origin_options) ).property("Ember.I18n.translations")
  occupationOptions: Em.computed(-> Ember.keys(Ember.I18n.translations.onboarding.occupation_options) ).property("Ember.I18n.translations")
  highestEducationOptions: Em.computed(-> Ember.keys(Ember.I18n.translations.onboarding.highest_education_options) ).property("Ember.I18n.translations")

  actions:
    save: ->

      if @saveForm()
        ajax("#{config.apiNamespace}/me.json",
          type: "POST"
          data: {settings: @getProperties(@get("fields"))}
        ).then(
          (response) => @endSave()
          (response) => @errorCallback(response, @)
        )
      else
        false


`export default controller`