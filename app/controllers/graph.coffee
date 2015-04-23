`import Ember from 'ember'`
`import datum from './graph/datum'`
`import viewportMixin from '../mixins/viewport_manager'`
`import colorableMixin from '../mixins/colorable'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`

controller = Ember.ObjectController.extend viewportMixin, colorableMixin,
  ### Set by route ###
  # rawData, firstEntryDate, viewportStart, catalog, loadedStartDate, loadedEndDate

  filtered: [] # default to no filtering

  # Some timeline preference helpers
  isTwoWeeks:   Ember.computed.equal("viewportDays.length", 14)
  isTwoMonths:  Ember.computed.equal("viewportDays.length", 60)
  isOneYear:    Ember.computed.equal("viewportDays.length", 365)

  ### Datapoints, made a bit more friendly to our purposes ###
  rawDatapoints: Ember.computed(->
    _data = []
    # Push together all the sources datapoints keeping track of source
    @get("sources").forEach (source) =>
      @get("rawData.#{source}").forEach (datapoint) ->
        datapoint["source"]  = source
        datapoint["id"]      = "#{source}_#{datapoint.x}_#{datapoint.name}"
        _data.pushObject datapoint

    _data.sortBy("x")
  ).property("rawData")

  ### All the days possible inside the raw responses ###
  days: Ember.computed( ->

    if @get("loadedStartDate") and @get("loadedEndDate")
      current   = moment(@get("loadedStartDate"))
      range     = Ember.A([current.unix()])

      until range.get("lastObject") is @get("loadedEndDate").unix() or range.length > 1000
        range.pushObject current.add(1, "days").unix()
      range

  ).property("loadedStartDate", "loadedEndDate")

  ## Datums! ###
  serverProcessingDays: [] # days marked for processing on the API side

  _processedDatumDays:  [] # internal for use in setting up #datums when new data comes in
  _processedDatums:     [] # internal for use in setting up #datums when new data comes in
  clearDatumsForDays: (days) ->
    @get("_processedDatumDays").removeObjects( days )
    @set("_processedDatums", @get("_processedDatums").reject( (datum) => days.contains(datum.get("day")) ))

  datums: Ember.computed ->
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

          # if there is data for that day and source then put it in
          if datapointsForDayBySource.length and not @get("serverProcessingDays").contains(day)

            datapointsForDayBySource.forEach (datapoint,i) =>
              if source is "treatments"
                @get("_processedDatums").pushObject datum.create content:
                  day:        day
                  order:      i
                  name:       datapoint.name
                  type:       "treatment"
                  controller: @

              else # must be a catalog
                if datapoint.points isnt 0
                  [1..datapoint.points].forEach (j) =>
                    y_order = datapoint.order + (j / 10) # order + 1, plus decimal second order (1.1, 1.2, etc)
                    @get("_processedDatums").pushObject datum.create content:
                      day:      day
                      catalog:  source
                      order:    y_order
                      name:     datapoint.name
                      type:     "symptom"
                      controller: @


          else
            catalog = if source is "treatments" then undefined else source
            type    = if source is "treatments" then "treatment" else "symptom"

            if @get("serverProcessingDays").contains(day)

              loading_pips = if type is "treatment" then 1 else 3
              [1..loading_pips].forEach (i) =>
                @get("_processedDatums").pushObject datum.create content:
                  day:        day
                  catalog:    catalog
                  order:      i
                  type:       type
                  processing: true
                  controller: @

            else # There are no datums for the day and soure... so put in a "missing" datum for that source
              unless type is "treatment"
                @get("_processedDatums").pushObject datum.create content:
                  day:      day
                  catalog:  catalog
                  order:    1.1
                  type:     type
                  missing:  true
                  controller: @

    @get("_processedDatums")
  .property("rawDatapoints.@each", "serverProcessingDays.@each")

  ### Catalogs and Filters ###
  sources: Ember.computed( -> Object.keys(@get("rawData")).sort() ).property("rawData")
  catalogs: Ember.computed( ->
    @get("sources").reject((name) -> name is "treatments").map (catalog) => {name: catalog, active: @get("catalog") is catalog}
  ).property("sources", "catalog")

  filterableNames: Ember.computed( ->
    _names = []
    @get("sources").forEach (source) =>
      @get("rawData.#{source}").mapBy("name").uniq().forEach (name) -> _names.pushObject([source,name])
    _names
  ).property("rawData")

  filterables: Ember.computed( ->
    filtered = @get("filtered")
    @get("filterableNames").map (name_array) =>
      [source,name] = name_array
      id            = "#{source}_#{name}"
      type          = if source is "treatments" then "treatment" else "symptom"

      id:       id
      name:     name
      source:   source
      color:    @colorClasses(id,type).bg
      filtered: filtered.contains(id)

  ).property("filterableNames", "filtered.@each")

  activeFilterables:      Ember.computed.filterBy("filterables", "filtered", true)
  inactiveFilterables:    Ember.computed.filterBy("filterables", "filtered", false)
  catalogFilterables:     Ember.computed(-> @get("filterables").filterBy("source", @get("catalog")) ).property("filterables", "catalog")
  treatmentFilterables:   Ember.computed.filterBy("filterables", "source", "treatments")

  ### Collection Sorting/Filtering ###
  viewportDatums: Ember.computed(-> @get("datums").filter((datum) => @get("viewportDays").contains(datum.get("day"))) ).property("datums.@each", "viewportDays")
  treatmentDatums: Ember.computed.filterBy("unfilteredDatums", "type", "treatment")
  symptomDatums:   Ember.computed.filterBy("unfilteredDatums", "type", "symptom")

  ### catalogDatums -> unfilteredDatums -> unfilteredDatumsByDay -> unfilteredDatumsByDayInViewport ###
  catalogDatums: Ember.computed(-> @get("datums").filter( (datum) => datum.get("catalog") is @get("catalog") or Em.isEmpty(datum.get("catalog")) ) ).property("datums.@each", "catalog")

  # Reject filtered datums with ids in filtered
  unfilteredDatums: Ember.computed(->
    if Ember.isEmpty(@get("filtered")) then return @get("catalogDatums")
    @get("catalogDatums").reject (datapoint) => @get("filtered").contains datapoint.get("sourced_name")
  ).property("catalogDatums", "filtered.@each")

  # Group by day
  unfilteredDatumsByDay: Ember.computed( -> @get("days").map (day) => @get("unfilteredDatums").filterBy("day", day).sortBy("order") ).property("unfilteredDatums", "days")

  # Filter by viewport days only
  unfilteredDatumsByDayInViewport: Ember.computed(->
    in_viewport = @get("unfilteredDatums").filter((datum) => @get("viewportDays").contains(datum.get("day")))
    @get("viewportDays").map (day) => in_viewport.filterBy("day", day)
  ).property("unfilteredDatums", "viewportDays")

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

      (response) => console.log "?!?! error on getting graph" # TODO replace with groovy handler
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
    Ember.run.next =>
      @set "rawData", newRaw
      @propertyDidChange("rawData")


  actions:
    dayProcessing: (day) -> @get("serverProcessingDays").addObject(moment(day, "MMM-DD-YYYY").utc().startOf("day").unix())
    dayProcessed: (day) ->
      date  = moment(day, "MMM-DD-YYYY").utc().startOf("day")
      day   = date.unix()
      if @get("serverProcessingDays").contains(day)
        @get("_processedDatumDays").removeObject(day)
        @get("serverProcessingDays").removeObject(day)

      Ember.run.next => @loadMore(date, date)

    changeCatalog: (catalog) -> @set("catalog", catalog)

    filter: (filterable_id) ->
      filtered = @get("filtered")
      if filtered.contains filterable_id
        filtered.removeObject filterable_id
      else
        filtered.pushObject filterable_id

      @propertyDidChange("filtered")

`export default controller`