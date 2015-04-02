`import Ember from 'ember'`
`import FormHandlerMixin from '../../mixins/form_handler'`

controller = Ember.Controller.extend FormHandlerMixin,

  translationRoot: "onboarding"

  dobDayValid: (-> not Em.isEmpty(@get("dobDay")) and /^([1-2][0-9]|3[0-1]|0[1-9])$/.test(@get("dobDay")) ).property("dobDay")
  dobMonthValid: (-> not Em.isEmpty(@get("dobMonth")) and /^(1[0-2]|0[1-9])$/.test(@get("dobMonth")) ).property("dobMonth")
  dobYearValid: (-> not Em.isEmpty(@get("dobYear")) and /^\d{4}$/.test(@get("dobYear")) and parseInt(@get("dobYear")) < new Date().getFullYear()+1 ).property("dobYear")
  dobValid: (-> @get("dobDayValid") and @get("dobMonthValid") and @get("dobYearValid") ).property("dobDayValid", "dobMonthValid", "dobYearValid")

  locationOptions: Em.computed(-> Ember.keys(Ember.I18n.translations.location_options) ).property("Ember.I18n.translations")
  sexOptions: "male female".w()

  requirements: "location dobDay dobMonth dobYear sex".w()
  validations:  "dobDay dobMonth dobYear dob".w()

  actions:
    save: ->

      if @saveForm()
        console.log "saved"
        true
      else
        console.log @get("errors.fields")
        console.log "couldn't save"
        false


`export default controller`