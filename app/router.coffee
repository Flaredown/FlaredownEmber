`import DS from 'ember-data'`
`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  # Pre-Auth
  @resource "login", path: "login"
  @resource "register", path: "register"
  @route "passwordReset", path: "reset-your-password"
  @route "inviteRegister", path: "accept-invitation/:invitation_token"

  # Post-Auth
  @resource "graph", path: "", ->
    @route "checkin", path: "/checkin/:date/:section"
    @route "account", path: "/my-account"

  @resource "insights", path: "/insights"

  @resource "reports", path: "/reports"

  @resource "onboarding", path: "/onboarding", ->
    @route "account",     path: "/account"
    @route "research",    path: "/research-questions"
    @route "conditions",  path: "/conditions"
    @route "catalogs",    path: "/condition-questions"
    @route "symptoms",    path: "/symptoms"
    @route "treatments",  path: "/treatments"
    @route "complete",    path: "/complete"

`export default Router`