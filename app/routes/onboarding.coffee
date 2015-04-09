`import AuthRoute from './authenticated'`
`import Ember from 'ember'`

route = AuthRoute.extend
  steps: "account research conditions catalogs symptoms treatments complete".w()
  step: ""

  beforeModel: (transition) ->
    @_super()
    step = if transition.targetName is "onboarding"
      "account"
    else
      transition.targetName.split(".")[1]

    @set("step", step)

  setupController: (controller, model) ->
    @_super(controller, model);
    controller.set("steps", @get("steps").map (step) -> "onboarding.#{step}")

  actions:
    save: ->
      @set "step", @get("steps")[@get("steps").indexOf(@get("step"))+1]
      @transitionTo("onboarding.#{@get("step")}")

`export default route`

