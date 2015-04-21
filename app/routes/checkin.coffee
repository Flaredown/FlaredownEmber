`import config from '../config/environment'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`
`import ajax from 'ic-ajax'`

route = Ember.Route.extend GroovyResponseHandlerMixin,
  model: (params, transition, queryParams) ->
    date = params.date
    today = moment.utc().format("MMM-DD-YYYY")
    @set "section", parseInt params.section

    date = today if params.date is "today" or today is params.date

    controller = @controllerFor("checkin")
    if controller and controller.get("model.niceDate") is date
      controller.get("model")
    else
      ajax(
        "#{config.apiNamespace}/entries",
        type: "POST",
        data:
          date: date
      ).then(
        (response) =>
          @store.pushPayload "entry", response
          @store.find "entry", response.entry.id
        ,
        @errorCallback(response)
      )

  afterModel: (model, transition, params) ->
    model.set("section", @get("section"))

  actions:
    close: -> @transitionTo "graph"

`export default route`

