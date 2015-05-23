`import UserSetupMixin from '../../mixins/user_setup'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,

  redirect: (model,transition) ->
    if not Em.keys(model).length # no catalog questions
      console.log transition.targetName
      if /conditions/.test(window.location.pathname) # coming from conditinos
        @send("back", "symptoms")
      else if /symptoms/.test(window.location.pathname) # coming from symptoms
        @send("back", "conditions")

  model: ->
    ajax(
      url: "#{config.apiNamespace}/me/catalogs"
    ).then(
      (response) -> response
      @errorCallback.bind(@)
    )

  afterModel: (model, transition) -> UserSetupMixin.apply({}).getLocale(@container)

`export default route`