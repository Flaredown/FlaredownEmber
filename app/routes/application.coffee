`import Ember from 'ember'`

route = Ember.Route.extend
  model: ->
    @store.find("currentUser", 0).then(
      (currentUser) =>
        @controllerFor("currentUser").set "content", currentUser
      () ->
    )
        
  # actions:
  #   error: (reason, transition) ->
  #     if (reason.status is 401)
  #       @redirectToLogin(transition)
  #     else
  #       App.generalError("There was a problem navigating to that page. Please make sure you've entered it correctly and try again.")
  
`export default route`

