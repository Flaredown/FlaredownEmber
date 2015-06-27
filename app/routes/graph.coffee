`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,

  model: (params) ->
    ajax(
      url: "#{config.apiNamespace}/graph"
      data: { start_date: @get("currentUser").get("defaultStartDate").format("MMM-DD-YYYY"), end_date: @get("currentUser").get("defaultEndDate").format("MMM-DD-YYYY") }
    ).then(
      (response) -> response
      @errorCallback.bind(@)
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

  actions:
    entry_processing: (dateString) -> # from checkin saving
      @controllerFor("graph").send("dayProcessing",dateString)

    entry_processed: (message) -> # from Pusher
      @controllerFor("graph").send("dayProcessed", message.entry_date)

`export default route`
