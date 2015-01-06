`import AuthRoute from '../authenticated'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`

route = AuthRoute.extend
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
          console.log response
          @store.pushPayload "entry", response
          @store.find "entry", response.entry.id
        ,
        (response) ->
      )

  afterModel: (model, transition, params) ->
    model.set("section", @get("section"))

  actions:
    close: -> @transitionTo "graph"

`export default route`

