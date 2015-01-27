`import Ember from 'ember'`

route = Ember.Route.extend
  beforeModel: (transition) ->
    if (@controllerFor('login').get("isAuthenticated"))
      @transitionTo('graph')

  setupController: (controller, model) ->
    @_super(controller, model);

    if controller.get("user_email") and controller.get("user_token")
      controller.send("loginWithToken")

    # controller.resetForm()

`export default route`