`import UserSetupMixin from '../../mixins/user_setup'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,

  redirect: (model,transition) ->
    if not Em.keys(model).length
      if transition.targetName is "onboarding.catalogs"
        @transitionTo("onboarding.symptoms")
      else if transition.targetName is "onboarding.research"
        @transitionTo("onboarding.conditions")

  model: ->
    ajax(
      url: "#{config.apiNamespace}/me/catalogs"
    ).then(
      (response) -> response
      @errorCallback.bind(@)
    )

  afterModel: (model, transition) -> UserSetupMixin.apply({}).getLocale(@container)

`export default route`