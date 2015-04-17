`import Ember from 'ember'`
`import config from '../config/environment'`

route = Ember.Route.extend
  beforeModel: (transition) ->
    debugger
    @transitionTo(config.afterLoginRoute) if @controllerFor('login').get("isAuthenticated")


`export default route`