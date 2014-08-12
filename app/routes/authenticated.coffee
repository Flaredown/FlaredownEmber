`import Ember from 'ember'`

route = Ember.Route.extend
  beforeModel: (transition) ->
    login = @controllerFor('login')
    unless login.get("isAuthenticated")
      @redirectToLogin(transition)
      
  redirectToLogin: (transition) ->
    loginController = @controllerFor('login')
    loginController.set('attemptedTransition', transition)
    @transitionTo('login')
        
  # actions:
  #   error: (reason, transition) ->
  #     if (reason.status is 401)
  #       @redirectToLogin(transition)
  #     else
  #       App.generalError("There was a problem navigating to that page. Please make sure you've entered it correctly and try again.")
  
`export default route`