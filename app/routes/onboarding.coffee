`import AuthRoute from './authenticated'`
`import Ember from 'ember'`

route = AuthRoute.extend
  step: 0
  steps: "account research conditions catalogs symptoms treatments complete".w()
  currentStep: Ember.computed(-> @get("steps").objectAt(@get("step")) ).property("step")

  # genderOptions: [
  #   { label: "Male", value: "male"},
  #   { label: "Female", value: "female"}
  # ]

  errors: {}

  actions:
    save: ->
      @set("step", @get("step")+1)
      @transitionTo("onboarding.#{@get("currentStep")}")

`export default route`

