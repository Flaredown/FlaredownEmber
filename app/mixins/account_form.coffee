`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../mixins/form_handler'`

mixin = Ember.Mixin.create FormHandlerMixin,

  defaults: Ember.computed(-> @get("currentUser.settings") ).property("currentUser")
  fields: "location dobDay dobMonth dobYear sex".w()
  requirements: "location dobDay dobMonth dobYear sex".w()
  validations:  "dobDay dobMonth dobYear".w()

  dobDayValid: (-> /^([1-2][0-9]|3[0-1]|0[1-9])$/.test(@get("dobDay")) ).property("dobDay")
  dobMonthValid: (-> /^(1[0-2]|0[1-9])$/.test(@get("dobMonth")) ).property("dobMonth")
  dobYearValid: (-> /^\d{4}$/.test(@get("dobYear")) and parseInt(@get("dobYear")) < new Date().getFullYear()+1 ).property("dobYear")
  dobValid: (-> @get("dobDayValid") and @get("dobMonthValid") and @get("dobYearValid") ).property("dobDayValid", "dobMonthValid", "dobYearValid")

  locationOptions: Em.computed.alias("Ember.I18n.translations.location_options")

  actions:
    save: ->
      if @saveForm()
        settings = @getProperties(@get("fields"))
        ajax("#{config.apiNamespace}/me.json",
          type: "POST"
          data: {settings: settings}
        ).then(
          (response) =>
            @endSave()
            @get("currentUser").setProperties("settings", settings)

            if @get("isOnboarding")
              @target.send("save") # bump to route
            else
              @set("editing", false)


          @errorCallback.bind(@)
        )
      else
        false


`export default mixin`
