`import Ember from 'ember'`

mixin = Ember.Mixin.create

  defaults: Ember.computed(-> @get("currentUser.settings")).property("currentUser")
  fields: "location dobDay dobMonth dobYear sex gender".w()
  requirements: "location dobDay dobMonth dobYear sex".w()
  validations:  "dobDay dobMonth dobYear".w()

  dobDayValid: (-> /^([1-2][0-9]|3[0-1]|0[1-9])$/.test(@get("dobDay")) ).property("dobDay")
  dobMonthValid: (-> /^(1[0-2]|0[1-9])$/.test(@get("dobMonth")) ).property("dobMonth")
  dobYearValid: (-> /^\d{4}$/.test(@get("dobYear")) and parseInt(@get("dobYear")) < new Date().getFullYear()+1 ).property("dobYear")
  dobValid: (-> @get("dobDayValid") and @get("dobMonthValid") and @get("dobYearValid") ).property("dobDayValid", "dobMonthValid", "dobYearValid")

  locationOptions: Em.computed.alias("Ember.I18n.translations.location_options")

`export default mixin`
