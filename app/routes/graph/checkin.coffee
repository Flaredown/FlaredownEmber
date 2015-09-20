`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,
  checkTimeFrequency: 60000,
  model: (params, transition, queryParams) ->
    date = params.date
    today = moment().format("MMM-DD-YYYY")
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

  afterModel: (entry, transition, params) ->
    @_super()
    controller = @controllerFor("graph.checkin")

    # Start refreshing the entry
    @set("checkTheTime", true)
    @_checkTheTime(entry)

    entry.set("section", @get("section"))
    entry.set("initialEntry", entry.get("checkinData"))
    
    # TODO reimplement, perhaps in router
    # fromDate = transition.router.state.params["graph.checkin"].date if transition.router.state.params["graph.checkin"]
    # betweenDays = fromDate and (fromDate isnt entry.get("dateAsParam"))
    #
    # if not entry.get("just_created") and (not fromDate or betweenDays)
    #    # and (fromDate isnt entry.get("dateAsParam"))
    #   Ember.run.next =>
    #     summarySection = controller.get("sections.lastObject").number
    #     entry.set("section", summarySection)

    has_notes = Em.isPresent(entry.get("notes"))
    if has_notes
      Ember.run.next =>
        controller.set("show_notes", has_notes)
        controller.set("notesSaved", has_notes)

  exit: ->
    @set("checkTheTime", false)

  actions:
    close: -> @transitionTo "graph"

  _checkTheTime: (entry) -> # periodically check the time to see if we're still on the right day
    if entry.get("moment")
      checkingTime = setTimeout((=> @_checkTheTime(entry)), @get("checkTimeFrequency")) if @get("checkTheTime")

      if moment().format("MMM-DD-YYYY") isnt entry.get("niceDate")
        clearTimeout(checkingTime)

        Ember.run.next =>
          controller = @controllerFor("graph.checkin")
          @controllerFor("graph.checkin").get("model").propertyDidChange("moment") if controller.get("model")

          @transitionTo("graph.checkin", entry.get("niceDate"), @get("section"))

`export default route`

