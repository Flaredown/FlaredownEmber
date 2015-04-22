`import Ember from 'ember'`
`import ajax from 'ic-ajax'`
`import config from '../../config/environment'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

controller = Ember.Controller.extend GroovyResponseHandlerMixin,
  translationRoot: "onboarding"

  actions:
    save: ->
      settings = {onboarded: true}
      ajax("#{config.apiNamespace}/me.json",
        type: "POST"
        data: {settings: settings}
      ).then(
        (response) =>
          @set("currentUser.settings.onboarded", "true")
          @transitionToRoute("graph.checkin", "today", "1")
        @errorCallback.bind(@)
      )

`export default controller`