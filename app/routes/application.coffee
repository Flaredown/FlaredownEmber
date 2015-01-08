`import Ember from 'ember'`
`import ajax from 'ic-ajax'`

route = Ember.Route.extend

  actions:
    entry_processed: (data) -> @controllerFor("graph").send("dayProcessed", data.entry_date)
  #   error: (reason, transition) ->
  #     if (reason.status is 401)
  #       @redirectToLogin(transition)
  #     else
  #       App.generalError("There was a problem navigating to that page. Please make sure you've entered it correctly and try again.")

`export default route`

