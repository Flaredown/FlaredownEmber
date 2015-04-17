`import AuthRoute from '../authenticated'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

route = AuthRoute.extend GroovyResponseHandlerMixin,
  model: (params, transition, queryParams) ->
    date = params.date
    today = moment.utc().format("MMM-DD-YYYY")
    @set "section", parseInt params.section

    date = today if params.date is "today" or today is params.date

    controller = @controllerFor("graph.checkin")
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
        @errorCallback.bind(@)
      )

  afterModel: (model, transition, params) ->
    model.set("section", @get("section"))

  actions:
    close: -> @transitionTo "graph"

`export default route`

