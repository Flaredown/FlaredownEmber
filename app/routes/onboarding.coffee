`import AuthRoute from './authenticated'`
`import Ember from 'ember'`

route = AuthRoute.extend
  step: 0
  steps: "account research conditions catalogs symptoms treatments complete".w()
  currentStep: Ember.computed(-> @get("steps").objectAt(@get("step")) ).property("step")

  actions:
    save: ->
      @set("step", @get("step")+1)
      @transitionTo("onboarding.#{@get("currentStep")}")

`export default route`

