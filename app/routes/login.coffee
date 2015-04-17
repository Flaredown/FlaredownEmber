`import Ember from 'ember'`
`import UnAuthRoute from './unauthenticated'`

route = UnAuthRoute.extend
  setupController: (controller, model) ->
    @_super(controller, model);

    controller.send("loginWithToken") if controller.get("user_email") and controller.get("user_token")

`export default route`