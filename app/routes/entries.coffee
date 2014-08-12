`import Ember from 'ember'`
`import AuthRoute from './authenticated'`

route = AuthRoute.extend
  model: (params) ->
    ajax "#{FlaredownENV.apiNamespace}/chart", {data: {start_date: @get("currentUser").get("defaultStartDate"), end_date: @get("currentUser").get("defaultEndDate")}}

  setupController: (controller,model) ->
    user = @get("currentUser")
    controller.set("model", model.chart)
    controller.set("startDate", moment(user.get("defaultStartDate")))
    controller.set("endDate", moment(user.get("defaultEndDate")))

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