`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,
  unauthedOnly: true

  model: (params) ->
    ajax(
      type: "get"
      url: "#{config.apiNamespace}/users/invitee/#{params.invitation_token}"
    ).then(
      (response) => response
      @errorCallback.bind(@)
    )

  setupController: (controller,model) ->
    if model
      controller.set("model", model)
      controller.set("isInvite", true)

`export default route`