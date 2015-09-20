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

  _getResponseData: (entry) ->
    responses       = []
    defaultResponseValues =
      checkbox: 0
      select: null
      number: null

    entryResponses = entry.get("responses")
    catalogs = entry.get("catalogs")

    if catalogs and entryResponses
      catalogs.removeObjects(["symptoms", "conditions"])
      catalogs.sort()
      catalogs.addObjects(["symptoms", "conditions"])

      catalogs.forEach (catalog) =>
        entry.get("catalog_definitions.#{catalog}").forEach (section) =>
          section.forEach (question) ->
            # Lookup an existing response loaded on the Entry, use it's value to setup responsesData, otherwise null
            response  = entryResponses.findBy("id", "#{catalog}_#{question.name}_#{entry.get("id")}")
            value     = if response then response.get("value") else defaultResponseValues[question.kind]

            responses.pushObject Ember.Object.create({name: question.name, value: value, catalog: catalog})

    responses

  _getTreatmentData: (entry) ->
    treatments = entry.get("treatments")
    if treatments
        treatment_data = treatments.map((treatment) ->
          if treatment.get("active")
            if treatment.get("hasDose") # Taken w/ doses
              treatment.getProperties("name", "quantity", "unit")
            else # Taken no doses
              Ember.merge treatment.getProperties("name"), {quantity: -1, unit: null}
          else # Not taken
            treatment.getProperties("name", "quantity", "unit")
        ).compact()

      treatment_data

  afterModel: (entry, transition, params) ->
    @_super()
    controller = @controllerFor("graph.checkin")

    # Start refreshing the entry
    @set("checkTheTime", true)
    @_checkTheTime(entry)

    entry.set("section", @get("section"))
    treatment_data = @_getTreatmentData(entry)
    response_data =  @_getResponseData(entry)
    initial_entry =
        responses: response_data
        notes: entry.get("notes")
        tags: entry.get("tags")
        treatments: treatment_data if Em.isPresent(treatment_data)
    entry.initialEntry = JSON.stringify(initial_entry)
    
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

