`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`

route = Ember.Route.extend GroovyResponseHandlerMixin,

  model: (params) ->
    ajax(
      type: "get"
      url: "#{config.apiNamespace}/users/invitee/#{params.invitation_token}"
    ).then(
      (response) => response
      (response) => @errorCallback(response)
    )

  setupController: (controller,model) ->
    if model
      controller.set("model", model)
      controller.set("isInvite", true)

`export default route`