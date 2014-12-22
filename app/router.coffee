`import DS from 'ember-data'`
`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @resource "login", path: "login"
  @resource "register", path: "register"
  @resource "form-error", path: "form-error"

  @route "inviteRegister", path: "accept-invitation/:invitation_token"

  @resource "graph", path: "", ->
    @route "checkin", path: "/checkin/:date/:section"

  @route "onboarding", path: "onboarding", ->
    @route "conditions", path: "/conditions"
    @route "symptoms", path: "/symptoms"
    @route "catalogs", path: "/catalogs"
    @route "checkin-finished", path: "/checkin-finished"

`export default Router`
