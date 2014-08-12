`import Ember from 'ember'`

controller = Ember.Controller.extend
  needs: ["login"]
  
  actions:
    logout: ->
      @get("controllers.login").send("logout")
      @transitionToRoute('login')

`export default controller`