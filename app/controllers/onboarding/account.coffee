`import Ember from 'ember'`

controller = Ember.Controller.extend

  translationRoot: "onboarding"

  dobDayValid: (->
    not Em.isEmpty(@get("dobDay")) and /^([1-2][0-9]|3[0-1]|0[1-9])$/.test(@get("dobDay"))
  ).property("dobDay")

  dobMonthValid: (->
    not Em.isEmpty(@get("dobMonth")) and /^(1[0-2]|0[1-9])$/.test(@get("dobMonth"))
  ).property("dobMonth")

  dobYearValid: (->
    not Em.isEmpty(@get("dobYear")) and /^\d{4}$/.test(@get("dobYear")) and parseInt(@get("dobYear")) < new Date().getFullYear()+1
  ).property("dobYear")

  dobValid: (->
    @get("dobDayValid") and @get("dobMonthValid") and @get("dobYearValid")
  ).property("dobDayValid", "dobMonthValid", "dobYearValid")

  errors: {}

  actions:
    save: ->

      if @get("dobValid")
        true
      else
        false

`export default controller`