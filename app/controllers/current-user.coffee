`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: ["login"]

  loggedIn: Ember.computed ->
    @get("controllers.login.isAuthenticated")
  .property("controllers.login.isAuthenticated")
  
  defaultStartDate: moment.utc().subtract(moment.duration({"days": 20})).format("MMM-DD-YYYY")
  defaultEndDate: moment.utc().format("MMM-DD-YYYY")
  
`export default controller`