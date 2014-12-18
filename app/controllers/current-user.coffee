`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: ["login"]

  loggedIn: Ember.computed ->
    @get("controllers.login.isAuthenticated")
  .property("controllers.login.isAuthenticated")

  defaultStartDate: moment().utc().subtract(20,"days").startOf("day")
  defaultEndDate: moment().utc().startOf("day")

`export default controller`