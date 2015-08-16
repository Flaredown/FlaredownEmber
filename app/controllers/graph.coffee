`import Ember from 'ember'`
`import datum from './graph/datum'`
`import viewportMixin from '../mixins/viewport_manager'`
`import colorableMixin from '../mixins/colorable'`
`import graphControls from '../mixins/graph_controls'`
`import config from '../config/environment'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`
`import ajax from 'ic-ajax'`

computed = Ember.computed

controller = Ember.Controller.extend viewportMixin, colorableMixin, graphControls, GroovyResponseHandlerMixin,
  ### The route sets up a few attributes ###
  # rawData -- condensed data by "type" (source)
  # firstEntryDate
  # viewportStart
  # catalog -- current selected catalog
  # loadedStartDate
  # loadedEndDate

  # Some timeline preference helpers
  isTwoWeeks:   computed.equal("viewportDays.length", 14)
  isTwoMonths:  computed.equal("viewportDays.length", 60)
  isOneYear:    computed.equal("viewportDays.length", 365)

  # The various kinds of datums: catalogs, symptoms, treatments
  sources: computed("rawData", -> Object.keys(@get("rawData")).sort() )

  # The Raw Data, made a bit more friendly to our purposes
  # --- Example rawData response ---
  # {
  #   "treatments":[
  #     {
  #       "order": 1,
  #       "x": 1428710400,
  #       "name": "B12",
  #       "quantity": "1.0",
  #       "unit": "tab"
  #     },
  #     ... more days here ...
  #   ],
  #   "symptoms": [ ... same as above ... ],
  #   "hbi": [ ... a catalog example ... ]
  # }
  rawDatapoints: computed("rawData", ->
    _data = []

    # Push together all the sources datapoints keeping track of source
    @get("sources").forEach (source) =>
      @get("rawData.#{source}").forEach (datapoint) ->
        datapoint["source"]  = source
        datapoint["id"]      = "#{source}_#{datapoint.x}_#{datapoint.name}"
        _data.pushObject datapoint

    _data.sortBy("x")
  )

  ### All the days possible within the raw responses ###
  days: computed("loadedStartDate", "loadedEndDate", ->

    if @get("loadedStartDate") and @get("loadedEndDate")
      current   = moment(@get("loadedStartDate"))
      range     = Ember.A([current.unix()])

      until range.get("lastObject") is @get("loadedEndDate").unix() or range.length > 1000
        range.pushObject current.add(1, "days").unix()
      range
  )

  ## Datums! -- All possible individual "pips" available to rendered/filtered ###
  # NOTE: not the same as the D3 datum concept! But close.

  serverProcessingDays: [] # days marked for processing on the API side

  _processedDatumDays:  [] # internal for use in setting up #datums when new data comes in
  _processedDatums:     [] # internal for use in setting up #datums when new data comes in

  datums: computed("rawDatapoints.@each", "serverProcessingDays.@each", ->
    if @get("rawDatapoints") and @get("days")

      # Remove any server processing days from the already processed days so they are reprocessed below

      if @get("serverProcessingDays.length")
        @clearDatumsForDays(@get("serverProcessingDays"))

      # Only do the work for days not already loaded in
      unprocessed_days = @get("days").reject (day) => @get("_processedDatumDays").contains(day)

      # For all days in loaded range
      unprocessed_days.forEach (day) =>
        @get("_processedDatumDays").pushObject day

        datapointsForDay = @get("rawDatapoints").filterBy("x", day).sortBy("order")

        @get("sources").forEach (source) =>
          datapointsForDayBySource = datapointsForDay.filterBy("source", source)

          if source is "treatments" # treatments don't have an order attribute, do a..z sorting by name
            datapointsForDayBySource = datapointsForDayBySource.sortBy("name").reverse()

          # if there is data for that day and source then put it in
          if datapointsForDayBySource.length and not @get("serverProcessingDays").contains(day)

            datapointsForDayBySource.forEach (datapoint,i) =>
              if source is "treatments"
                @get("_processedDatums").pushObject datum.create content: {day: day, order: i, name: datapoint.name, hasDose: (datapoint.points > 0), type: "treatment", controller: @}

              else # it must be a regular pip
                if datapoint.points isnt 0
                  [1..datapoint.points].forEach (j) =>
                    y_order = datapoint.order + (j / 10) # order + 1, plus decimal second order (1.1, 1.2, etc)
                    @get("_processedDatums").pushObject datum.create content: {day: day, catalog: source, order: y_order, name: datapoint.name, type: "symptom", controller: @}

          else # it's loading, being processed or missing

            catalog = if source is "treatments" then undefined else source
            type    = if source is "treatments" then "treatment" else "symptom"

            if @get("serverProcessingDays").contains(day)
              return if type is "treatment" # TODO no loading treatment stuff for now
              loading_pips = if type is "treatment" then 1 else 3 # loading "animation" for treatments only has 1 pip, others have 3 "loading" pips
              [1..loading_pips].forEach (i) =>
                @get("_processedDatums").pushObject datum.create content: {day: day, catalog: catalog, order: i, type: type, processing: true, controller: @}

            else # There are no datums for the day and source... so put in a "missing" datum for that source

              unless type is "treatment"
                @get("_processedDatums").pushObject datum.create content: {day: day, catalog: catalog, order: 1.1, type: type, missing: true, controller: @}

    @get("_processedDatums")
  )

  ### Datum filtering in anticipation of D3 ###
  #
  # 1. catalogDatums
  # 2. unfilteredDatums
  # 3. unfilteredDatumsByDay
  # 4. unfilteredDatumsByDayInViewport
  #
  # Typically only #4 is rendered by D3, but the intermediates are used as well
  # for various sorting/arranging within D3

  # 1. Everything in the acive catalog + treatments
  catalogDatums: computed("datums.@each", "catalog", ->
    @get("datums").filter (datum) =>
      datum.get("catalog") is @get("catalog") or Em.isEmpty(datum.get("catalog")) # TODO: should be "is_treatment" or something, not "not catalog"
  )

  # 2. Reject filtered datums with ids in filtered
  unfilteredDatums: computed("catalogDatums", "filtered.@each", ->
    if Em.isEmpty(@get("filtered")) then return @get("catalogDatums")
    @get("catalogDatums").reject (datapoint) => @get("filtered").contains datapoint.get("sourced_name")
  )

  # 3. Group by day
  unfilteredDatumsByDay: computed("unfilteredDatums", "days", ->
    @get("days").map (day) =>
      @get("unfilteredDatums").filterBy("day", day).sortBy("order")
  )

  # 4. Filter by viewport days only
  unfilteredDatumsByDayInViewport: computed("unfilteredDatums", "viewportDays", ->
    in_viewport = @get("unfilteredDatums").filter((datum) => @get("viewportDays").contains(datum.get("day")))
    @get("viewportDays").map (day) => in_viewport.filterBy("day", day)
  )

  ### Catalogs and Filtering Helpers ###
  catalogs: computed("sources", "catalog", ->
    @get("sources").reject (name) -> name is "treatments"
      .map (catalog) =>
        {name: catalog, active: @get("catalog") is catalog} # is it the currently selected catalog?
  )

  ### Datum Sorting/Filtering ###
  viewportDatums:   computed("datums.@each", "viewportDays", -> @get("datums").filter((datum) => @get("viewportDays").contains(datum.get("day"))) )
  treatmentDatums:  computed.filterBy("unfilteredDatums", "type", "treatment")
  symptomDatums:    computed.filterBy("unfilteredDatums", "type", "symptom")

  treatmentViewportDatumNames: computed("viewportDatums", ->
    @get("viewportDatums")
      .filterBy("type", "treatment")
      .mapBy("name")
      .uniq()
  )

  visibleTreatmentViewportDatumNames: computed("unfilteredDatums",  ->
    @get("unfilteredDatums")
      .filter( (datum) => @get("viewportDays").contains(datum.get("day")) )
      .filterBy("type", "treatment")
      .mapBy("name")
      .uniq()
  )

  # Some internal helpers
  clearDatumsForDays: (days) ->
    @get("_processedDatumDays").removeObjects( days )
    @set("_processedDatums", @get("_processedDatums").reject( (datum) => days.contains(datum.get("day")) ))

  loadMore: (start,end) ->
    @set "loadingStartDate", start

    ajax(
      url: "#{config.apiNamespace}/graph"
      method: "GET"
      data:
        start_date: start.format("MMM-DD-YYYY")
        end_date: end.format("MMM-DD-YYYY")
    ).then(
      (response) =>
        @set("loadedStartDate",start) if start < @get("loadedStartDate")
        @loadMoreRaw(response)

      @errorCallback.bind(@)
    )

  loadMoreRaw: (raw) ->
    newRaw  = @get("rawData")
    days    = []

    Object.keys(raw).forEach (source) =>
      days.addObjects raw[source].mapBy("x").uniq()
      newRaw[source] = newRaw[source].reject (datapoint) -> days.contains(datapoint.x) # get rid of existing days and use newer versions

      raw[source].forEach (raw_datapoint) =>
        newRaw[source].pushObject raw_datapoint

    @clearDatumsForDays(days)
    # TODO is this next really necessary?
    # Em.run.next =>
    @set "rawData", newRaw
    @propertyDidChange("rawData")

  actions:
    # Hooks for Pusher to call
    dayProcessing: (day) -> @get("serverProcessingDays").addObject(moment(day, "MMM-DD-YYYY").utc().startOf("day").unix())
    dayProcessed: (day) ->
      date  = moment(day, "MMM-DD-YYYY").utc().startOf("day")
      day   = date.unix()
      if @get("serverProcessingDays").contains(day)
        @get("_processedDatumDays").removeObject(day)
        @get("serverProcessingDays").removeObject(day)

      Em.run.next => @loadMore(date, date)

`export default controller`