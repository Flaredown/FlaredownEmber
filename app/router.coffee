`import DS from 'ember-data'`
`import Ember from 'ember'`
`import config from './config/environment'`
`import KeenMixin from './mixins/keen'`

Router = Ember.Router.extend KeenMixin,
  location: config.locationType

Router.reopen
  notifyGoogleAnalytics: (->
    ga('send', 'pageview', { 'page': @get('url'), 'title': @get('url') })
  ).on('didTransition')

  notifyKeen: (->
    @keenPageviewEvent() unless config.environment is "development"
  ).on('didTransition')

Router.map ->
  # Pre-Auth
  @resource "login", path: "login"
  # @resource "register", path: "register"
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