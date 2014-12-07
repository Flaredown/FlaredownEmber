`import Ember from 'ember'`

route = Ember.Route.extend
  beforeModel: (transition) ->
    if (@controllerFor('login').get("isAuthenticated"))
      @transitionTo('graph')
      
  setupController: (controller, model) ->
    # controller.resetForm()
    
`export default route`