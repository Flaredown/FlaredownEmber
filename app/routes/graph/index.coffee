`import AuthRoute from './../authenticated'`
`import config from '../../config/environment'`

route = AuthRoute.extend
  model: (params) ->
    Ember.$.ajax(
      url: "#{config.apiNamespace}/graph"
      data: { start_date: @get("currentUser").get("defaultStartDate"), end_date: @get("currentUser").get("defaultEndDate") }
    ).then(
      (response) -> response
      (response) -> # TODO handler here
    )

  setupController: (controller, model) ->
    user = @get("currentUser")

    controller.set "model",     {}
    controller.set "rawData", model
    controller.set "firstEntryDate", moment().utc().startOf("day").subtract(365,"days") # TODO unhaxorize this
    controller.set "catalog",   Object.keys(model).sort()[0]

    # TODO these are antiquated -> /dev/null
    # controller.set "startDate", moment.utc(user.get("defaultStartDate"))
    # controller.set "endDate",   moment.utc(user.get("defaultEndDate"))

  enter: ->
    # user_id = @controllerFor("login").get("loginId")
    # @get("pusher").subscribe("graph_for_#{user_id}") if user_id
  exit: ->
    # user_id = @controllerFor("login").get("loginId")
    # @get("pusher").unsubscribe("graph_for_#{user_id}") if user_id

  actions:
    updates: (message) ->
      # TODO use Pusher data, not hard-coded example
      @controllerFor("graph.index").get("catalog.scores").pushObject {x: 1391922000, y: 500 }

`export default route`