`import Ember from 'ember'`

Router = Ember.Router.extend
  location: FlaredownENV.locationType

Router.map ->    
  @resource "login", path: "login"
  @resource "register", path: "register"
  
  @resource "entries", path: "", ->
    @route "entry", path: "/entry/:date/:section"

`export default Router`
