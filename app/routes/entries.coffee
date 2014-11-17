`import AuthRoute from './authenticated'`
`import config from '../config/environment'`

route = AuthRoute.extend
  model: (params) ->
    Ember.$.ajax(
      url: "#{config.apiNamespace}/chart"
      data: { start_date: @get("currentUser").get("defaultStartDate"), end_date: @get("currentUser").get("defaultEndDate") }
    ).then(
      (response) -> response
      (response) -> # TODO handler here
    )

  setupController: (controller,model) ->
    user = @get("currentUser")
    controller.set("model", model.chart)
    controller.set("startDate", moment.utc(user.get("defaultStartDate")))
    controller.set("endDate", moment.utc(user.get("defaultEndDate")))

  enter: ->
    # user_id = @controllerFor("login").get("loginId")
    # @get("pusher").subscribe("entries_for_#{user_id}") if user_id
  exit: ->
    # user_id = @controllerFor("login").get("loginId")
    # @get("pusher").unsubscribe("entries_for_#{user_id}") if user_id

  actions:
    updates: (message) ->
      @controllerFor("entries").get("catalog.scores").pushObject {x: 1391922000, y: 500 }

`export default route`