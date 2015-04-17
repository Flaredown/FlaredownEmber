`import AuthRoute from './authenticated'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`

route = AuthRoute.extend

  # beforeModel: -> @transitionTo("graph.checkin", "today", "1") unless @get("currentUser.graphable")
  model: (params) ->
    ajax(
      url: "#{config.apiNamespace}/graph"
      data: { start_date: @get("currentUser").get("defaultStartDate").format("MMM-DD-YYYY"), end_date: @get("currentUser").get("defaultEndDate").format("MMM-DD-YYYY") }
    ).then(
      (response) -> response
      (response) -> # TODO handler here
    )

  setupController: (controller, model) ->
    @_super()
    user = @get("currentUser")

    controller.set "model",           {}
    controller.set "loadedStartDate", @get("currentUser").get("defaultStartDate") #moment().utc().subtract(40,"days").startOf("day")
    controller.set "loadedEndDate",   @get("currentUser").get("defaultEndDate")#moment().utc().startOf("day")
    controller.set "rawData",         model
    controller.set "firstEntryDate",  moment().utc().startOf("day").subtract(365,"days") # TODO unhaxorize this
    controller.set "catalog",         Object.keys(model).sort()[0]
    controller.set "viewportStart",   moment().utc().startOf("day").subtract(14,"days")

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
      @controllerFor("graph").get("catalog.scores").pushObject {x: 1391922000, y: 500 }

`export default route`
