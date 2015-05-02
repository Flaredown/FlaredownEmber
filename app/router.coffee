`import DS from 'ember-data'`
`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from './config/environment'`
`import GroovyResponseHandlerMixin from './mixins/groovy_response_handler'`
`import KeenMixin from './mixins/keen'`

Router = Ember.Router.extend KeenMixin, GroovyResponseHandlerMixin,
  location: config.locationType

Router.reopen
  notifyGoogleAnalytics: (->
    ga('send', 'pageview', { 'page': @get('url'), 'title': @get('url') }) unless typeof(ga) is "undefined"
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
  @route 'upcoming', path: "upcoming"

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

  @route "fourOhFour", path: "page-not-found"
  @route "fiveHundred", path: "something-went-wrong"
  @route('badURL', { path: '/*badurl' });

`export default Router`

# Base Routing Behavior
Em.Route.reopen
  authedOnly: true
  unauthedOnly: false
  attemptedTransition: false

  beforeModel: (transition) ->
    attemptedTransition = @get("attemptedTransition")
    routeName = @get("routeName")
    @set("authedOnly", false) if @get("unauthedOnly")

    return if routeName is "application"
    return if routeName is "fourOhFour"
    return if routeName is "fiveHundred"

    if routeName is "badURL"
      @transitionTo("fourOhFour")
    else

      if @get("currentUser.loggedIn")
        if transition.targetName is "graph.checkin" and transition.state.params["graph.checkin"]
          attempted_date = moment(transition.state.params["graph.checkin"].date, "MMM-DD-YYYY")
          if attempted_date.isValid()
            if attempted_date > moment()
              Ember.Logger.info("Base.Route :: No future dates, transition aborted with error")
              @generalErrorFor("future_date")
              @transitionTo("graph.checkin", "today", "1")
            else if attempted_date < moment().subtract(2, "weeks")
              Ember.Logger.info("Base.Route :: No future dates, transition aborted with error")
              @generalErrorFor("distant_past_date")
              @transitionTo("graph.checkin", moment().subtract(13, "days").format("MMM-DD-YYYY"), "1")


        if transition.queryParams.sso and transition.queryParams.sig
          return @redirectToTalk(transition.queryParams.sso, transition.queryParams.sig)

        if attemptedTransition
          Ember.Logger.info("Base.Route :: Redirect existing attemped transition")
          attemptedTransition.retry()
          @set("attemptedTransition", false)

        else if @get("unauthedOnly")
          Ember.Logger.info("Base.Route :: Redirect to afterLoginRoute on trying to access unauthedOnly page")
          @transitionTo(config.afterLoginRoute)

          # Or 404?
          # Ember.Logger.info("Base.Route :: 404 because logged in on no-auth page")
          # @transitionTo("fourOhFour")

        else if @get("currentUser.onboarded") and routeName is "onboarding"
          Ember.Logger.info("Base.Route :: Already onboarded, sending to after login route")
          @transitionTo(config.afterLoginRoute)

        else if not @get("currentUser.onboarded") and not /onboarding/.test(routeName)
          Ember.Logger.info("Base.Route :: Redirect to onboarding not complete")
          if /onboarding/.test(window.location.pathname) # what was original intention?
            return transition.abort()

          @transitionTo("onboarding.account")

        else if transition.targetName is "graph.index" and not @get("currentUser.graphable")
          Ember.Logger.info("Base.Route :: Redirect ungraphable user to checkin")
          @transitionTo("graph.checkin", "today", "1")


        else if not @get("currentUser.checked_in_today") and @get("currentUser.onboarded") and routeName isnt "graph.checkin"
          Ember.Logger.info("Base.Route :: Not checked in today and no other catches, redirect to checkin")
          @set("currentUser.checked_in_today", true)
          @transitionTo("graph.checkin", "today", 1)

      else

        if @get("authedOnly")
          Ember.Logger.info("Base.Route :: Redirect to login because not logged in")
          @set("attemptedTransition", transition)
          @transitionTo("login")

        else if transition.queryParams.sso and transition.queryParams.sig
          @transitionTo("login", queryParams: transition.queryParams)

  redirectToTalk: (sso, sig) ->
    ajax("#{config.apiNamespace}/talk_sso.json}",
      type: "GET"
      data: {sso: sso, sig: sig}
    ).then(
      (response) => window.location = response.sso_url
      (response) => @transitionTo("fiveHundred")
    )

