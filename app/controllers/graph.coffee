`import Ember from 'ember'`
`import datum from './graph/datum'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`

controller = Ember.ObjectController.extend
  ### Set by route ###
  # rawData, firstEntryDate, viewportStart, catalog, loadedStartDate, loadedEndDate
  filteredNames: [] # default to no filtering

  ### Timeline manipulation, viewport stuff ###
  bufferMin:        20
  viewportSize:     14
  viewportMinSize:  14
  # viewportStart
  # firstEntrydate

  ### DATE PICKER STUFF ###
  datePickerWatcher: Ember.observer ->
    Ember.run.later =>
      if @get("pickerStartDate")
        new_start_date = moment(@get("pickerStartDate"))
        change = @get("viewportStart").diff(new_start_date, "days")
        @send("resizeViewport", change, "past") unless new_start_date.isSame(@get("viewportStart"), "day")

      if @get("pickerEndDate")
        new_end_date = moment(@get("pickerEndDate"))
        change = @get("viewportEnd").diff(new_end_date, "days")
        @send("resizeViewport", change, "future") unless new_end_date.isSame(@get("viewportEnd"), "day")

  .observes("pickerStartDate", "pickerEndDate")

  viewportDateWatcher: Ember.observer ->
    Ember.run.later =>
      if @get("viewportStart")
        formatted_start = moment(@get("viewportStart")).format("D MMMM, YYYY")
        @set("pickerStartDate", formatted_start) if @get("pickerStartDate") isnt formatted_start

      if @get("viewportEnd")
        formatted_end = moment(@get("viewportEnd")).format("D MMMM, YYYY")
        @set("pickerEndDate", formatted_end) if @get("pickerEndDate") isnt formatted_end
  .observes("viewportStart")

  ### VIEWPORT SETUP ###
  changeViewport: (size_change, new_start) ->
    today     = moment().utc().startOf("day")
    new_size  = @get("viewportSize")+size_change

    return if today.diff(new_start, "days") <= 0                                                            # Don't accept changes to invalid viewportStart
    new_start = @get("firstEntryDate") if new_start < @get("firstEntryDate")                                # Limit based on firstEntryDate
    new_size  = Math.abs(today.diff(new_start, "days")) if moment(new_start).add(new_size, "days") > today  # Limit based on no time travel
    new_size  = @get("viewportMinSize") if new_size < @get("viewportMinSize")                               # Can't go below min size
    return if moment(new_start).add(new_size, "days") > today                                               # Can't shift viewport past today

    @setProperties
      viewportSize:   new_size
      viewportStart:  new_start

  # viewportStart
  viewportEnd: Ember.computed( -> moment(@get("viewportDays.lastObject")*1000)).property("viewportDays")
  viewportDays: Ember.computed( ->
    [1..@get("viewportSize")].map (i) =>
      moment(@get("viewportStart")).add(i, "days")
    .filter (date) =>
      date >= @get("firstEntryDate") and date <= moment().utc().startOf("day")
    .map (date) ->
      date.unix()
  ).property("viewportSize", "viewportStart")

  # Some timeline preference helpers
  isTwoWeeks:   Ember.computed.equal("viewportDays.length", 14)
  isTwoMonths:  Ember.computed.equal("viewportDays.length", 60)
  isOneYear:    Ember.computed.equal("viewportDays.length", 365)

  ### Catalogs and Catalog Based Filters ###
  sources: Ember.computed( -> Object.keys(@get("rawData")).sort() ).property("rawData")
  filterableSources: Ember.computed( -> @get("sources").reject( (source) -> source is "treatments") ).property("sources")

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
              @get("_processedDatums").pushObject datum.create content:
                day:      day
                catalog:  catalog
                order:    1.1
                type:     type
                missing:  true
                controller: @

    @get("_processedDatums")
  .property("rawDatapoints.@each", "rawTreatments.@each", "serverProcessingDays.@each")

  ### Filter Controls ###
  datapointNames:       Ember.computed( -> @get("rawDatapoints").mapBy("name").uniq() ).property("rawDatapoints")
  catalogFilters:       Ember.computed( -> @get("rawDatapoints").filterBy("source", @get("catalog")).mapBy("name").uniq() ).property("rawDatapoints", "catalog")
  filteredSourceNames:  Ember.computed( -> @get("datapointNames").filter( (name) => @get("filteredNames").contains(name) ).compact() ).property("datapointNames", "filteredNames.@each")
  datapointFilters: Ember.computed( ->
    filters = []
    @get("filteredSourceNames").forEach (name) -> filters.addObject({name: name, enabled:true})
    @get("catalogFilters").forEach (name) => filters.addObject({name: name, enabled:false}) unless @get("filteredSourceNames").contains(name)
    filters
  ).property("sourceNames.@each", "filteredSourceNames.@each")

  ### Collection Sorting/Filtering ###
  viewportDatums: Ember.computed(-> @get("datums").filter((datum) => @get("viewportDays").contains(datum.get("day"))) ).property("datums.@each", "viewportDays")

  ### catalogDatums -> unfilteredDatums -> unfilteredDatumsByDay -> unfilteredDatumsByDayInViewport ###
  catalogDatums: Ember.computed(-> @get("datums").filter( (datum) => datum.get("catalog") is @get("catalog") or Em.isEmpty(datum.get("catalog")) ) ).property("datums.@each", "catalog")
  unfilteredDatums: Ember.computed(->
    if Ember.isEmpty(@get("filteredNames")) then return @get("catalogDatums")
    @get("catalogDatums").reject (datapoint) => @get("filteredNames").contains datapoint.get("name")
  ).property("catalogDatums", "filteredNames.@each")

  unfilteredDatumsByDay: Ember.computed( ->
    @get("days").map (day) => @get("unfilteredDatums").filterBy("day", day).sortBy("order")
  ).property("unfilteredDatums", "days")

  unfilteredDatumsByDayInViewport: Ember.computed(->
    in_viewport = @get("unfilteredDatums").filter((datum) => @get("viewportDays").contains(datum.get("day")))
    @get("viewportDays").map (day) => in_viewport.filterBy("day", day)
  ).property("unfilteredDatums", "viewportDays")

  ### Loading/Buffering ###
  bufferRadius: Ember.computed( ->
    # radius = Math.floor(@get("viewportSize") / 2)
    radius = @get("viewportSize")
    if radius < @get("bufferMin") then @get("bufferMin") else radius
  ).property("viewportSize")

  bufferWatcher: Ember.observer ->

    if @get("viewportStart") and @get("loadedStartDate") and @get("loadedEndDate")
      days_in_past_buffer   = Math.abs(@get("viewportStart").diff(@get("loadedStartDate"),"days"))
      # days_in_future_buffer = Math.abs(@get("viewportEnd").diff(@get("loadedEndDate"),"days"))

      if days_in_past_buffer < @get("bufferRadius")
        new_loaded_start = moment(@get("loadedStartDate")).subtract(@get("bufferRadius"),"days")
        @loadMore(new_loaded_start, @get("viewportStart")) unless @get("loadingStartDate") <= new_loaded_start

      # TODO deal with future loading later
      # available_future_days = Math.abs(@get("loadedEndDate").diff(moment.utc().startOf("day"),"days"))
      # days_to_load          = if days_in_future_buffer > available_future_days then available_future_days else @get("bufferRadius")
      # days_to_load          = if @get("bufferRadius") > days_to_load then @get("bufferRadius") else days_to_load
      # if days_to_load and available_future_days
      #   console.log "?!!?! #{available_future_days} #{days_in_future_buffer}"
      #   new_loaded_end = moment(@get("loadedEndDate")).add(days_to_load,"days")
      #   ajax(
      #     url: "#{config.apiNamespace}/graph"
      #     method: "GET"
      #     data:
      #       start_date: @get("loadedEndDate").format("MMM-DD-YYYY")
      #       end_date: new_loaded_end.format("MMM-DD-YYYY")
      #   ).then(
      #     (response) =>
      #       @set "loadedEndDate", new_loaded_end
      #       @set "rawData", response
      #       @processRawData()
      #
      #     (response) => console.log "?!?! error on getting graph"
      #   )
  .observes("loadedStartDate", "loadedEndDate", "viewportStart")

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

      (response) => console.log "?!?! error on getting graph"
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
    dayProcessing: (day) -> @get("serverProcessingDays").addObject(moment(day).utc().startOf("day").unix())
    dayProcessed: (day) ->
      date  = moment(day).utc().startOf("day")
      day   = date.unix()
      if @get("serverProcessingDays").contains(day)
        @get("_processedDatumDays").removeObject(day)
        @get("serverProcessingDays").removeObject(day)

      Ember.run.next => @loadMore(date, date)

    resizeViewport: (days, direction) ->
      if typeof(direction) is "undefined" # default direction is both ("pinch")
        @changeViewport (days*2), moment(@get("viewportStart")).subtract(days,"days")
      else
        if direction is "past"
          @changeViewport days, moment(@get("viewportStart")).subtract(days,"days")
        else
          @changeViewport days, moment(@get("viewportStart"))

    shiftViewport: (days, direction) ->
      if direction is "past"
        @changeViewport 0, moment(@get("viewportStart")).subtract(days,"days")
      else # "future"
        @changeViewport 0, moment(@get("viewportStart")).add(days,"days")

    filter: (symptom) ->
      filtered = @get("filteredNames")
      if filtered.contains symptom
        filtered.removeObject symptom
      else
        filtered.pushObject symptom

    changeCatalog: (catalog) -> @set("catalog", catalog)

`export default controller`