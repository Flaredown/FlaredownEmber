`import Ember from 'ember'`
`import config from '../config/environment'`

route = Ember.Route.extend
  # authedOnly: false

  model: (params) ->
    Ember.$.ajax(
      type: "get"
      url: "#{config.apiNamespace}/users/invitee/#{params.invitation_token}"
      context: @
    ).then(
      (response) -> response
      (response) ->
        if response.status == 404
          @transitionTo("login")
          sweetAlert("Invitation not found...", "We couldn't find that invitation, perhaps you've already used it?", "error")
        # TODO @errorCallback
    )

  setupController: (controller,model) ->
    if model
      controller.set("content", model)
      controller.set("isInvite", true)

`export default route`