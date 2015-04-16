`import AuthRoute from './authenticated'`
`import Ember from 'ember'`

route = AuthRoute.extend
  steps: "account research conditions catalogs symptoms treatments complete".w()
  step: ""

  model: -> Ember.Object.create({})

  afterModel: (model, transition) ->
    model.set("steps", @get("steps").map (step) -> "onboarding.#{step}")
    @set "step", if transition.targetName is "onboarding"
      "account"
    else
      transition.targetName.split(".")[1]

    @syncStep(@controllerFor("onboarding.#{@get("step")}"))

  syncStep: (controller) ->
    # this should probably be in each subroute, whatever.
    controller.set("isFirstStep", @get("step") is @get("steps.firstObject"))

  actions:
    back: ->
      @set "step", @get("steps")[@get("steps").indexOf(@get("step"))-1]
      @syncStep(@controllerFor("onboarding.#{@get("step")}"))
      @transitionTo("onboarding.#{@get("step")}")
    save: ->
      @set "step", @get("steps")[@get("steps").indexOf(@get("step"))+1]
      @syncStep(@controllerFor("onboarding.#{@get("step")}"))
      @transitionTo("onboarding.#{@get("step")}")

`export default route`

