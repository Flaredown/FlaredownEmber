`import UserSetupMixin from '../../mixins/user_setup'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,

  redirect: (model,transition) -> @transitionTo("onboarding.symptoms") if transition.targetName is "onboarding.catalogs" and not Em.keys(model).length
  model: ->
    ajax(
      url: "#{config.apiNamespace}/me/catalogs"
    ).then(
      (response) -> response
      @errorCallback.bind(@)
    )

  beforeModel: (transition) ->
    @_super(transition)
    @get("currentUser.model").reload().then(
      => UserSetupMixin.apply({}).setupUser(@container)
    )


`export default route`

