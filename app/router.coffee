`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->    
  @resource "login", path: "login"
  @resource "register", path: "register"
  
  @route "inviteRegister", path: "accept-invitation/:invitation_token"
  
  @resource "entries", path: "", ->
    @route "entry", path: "/entry/:date/:section"

`export default Router`
