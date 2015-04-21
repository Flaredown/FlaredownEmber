`import Ember from 'ember'`

route = Ember.Route.extend
  unauthedOnly: true

  setupController: (controller, model) ->
    @_super(controller, model);

    controller.send("loginWithToken") if controller.get("user_email") and controller.get("user_token")

`export default route`