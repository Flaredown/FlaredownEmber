`import Ember from 'ember'`
`import config from '../config/environment'`

route = Ember.Route.extend
  # authedOnly: false

  model: (params) ->
    Ember.$.ajax
      type: "get"
      url: "#{config.apiNamespace}/users/invitee/#{params.invitation_token}.json"
      context: @

      success: (response) ->
        response.user

      error: @errorCallback

  setupController: (controller,model) ->
    controller.set("content", model)
    controller.set("isInvite", true)

`export default route`