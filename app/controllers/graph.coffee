`import Ember from 'ember'`
`import symptomDatum from './graph/symptom-datum'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`

controller = Ember.ObjectController.extend
  ### Set by route ###
  # rawData, firstEntryDate, viewportStart, catalog, loadedStartDate, loadedEndDate
  filteredResponseNames: [] # default to no filtering

  ### Timeline manipulation, viewport stuff ###
  bufferMin:        10
  viewportSize:     14
  viewportMinSize:  14
  # viewportStart
  # firstEntrydate

  viewportStartNice: Ember.computed(-> @get("viewportStart").format("MMM-DD-YYYY")).property("viewportStart")

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

  ### Responses, made a bit more friendly to our purposes ###
  rawDataResponses: Ember.computed(->
    _data = []
    # Push together all the catalog datapoints keeping track of catalog
    @get("catalogs").forEach (catalog) =>
      @get("rawData.#{catalog}").forEach (datapoint) ->
        datapoint["catalog"] = catalog
        _data.push datapoint

    _data.sortBy("x")
  ).property("rawData")


  responseNames:                Ember.computed( -> @get("rawDataResponses").mapBy("name").uniq() ).property("rawDataResponses")
  catalogResponseNames:         Ember.computed( -> @get("rawDataResponses").filterBy("catalog", @get("catalog")).mapBy("name").uniq() ).property("rawDataResponses")
  filteredCatalogResponseNames: Ember.computed( -> @get("catalogResponseNames").filter( (name) => @get("filteredResponseNames").contains(name) ).compact() ).property("catalogResponseNames", "filteredResponseNames")

  ### All the days possible inside the raw responses ###
  days: Ember.computed( ->

    if @get("loadedStartDate") and @get("loadedEndDate")
      current   = moment(@get("loadedStartDate"))
      range     = Ember.A([current.unix()])

      until range.get("lastObject") is @get("loadedEndDate").unix() or range.length > 1000
        range.pushObject current.add(1, "days").unix()
      range

  ).property("loadedStartDate", "loadedEndDate")

  ### Catalogs and Catalog Based Filters ###
  catalogs: Ember.computed( -> Object.keys(@get("rawData")) ).property("rawData")

  ### Datums! ###
  datums: []
  datumsObserver: Ember.observer ->

    if @get("rawDataResponses") and @get("days")
      # For each day (x coord) among all data
      existing_days     = @get("datums").mapBy("day").uniq()
      unprocessed_days  = @get("days").reject (day) -> existing_days.contains(day)

      unprocessed_days.forEach (day) =>
        responsesForDay = @get("rawDataResponses").filterBy("x", day).sortBy("order")

        @get("catalogs").forEach (catalog) =>
          responsesForDayByCatalog = responsesForDay.filterBy("catalog", catalog)
          if responsesForDayByCatalog.length
            responsesForDayByCatalog.forEach (response) =>

              if response.points isnt 0
                [1..response.points].forEach (j) =>
                  y_order = response.order + (j / 10) # order + 1, plus decimal second order (1.1, 1.2, etc)
                  @get("datums").push symptomDatum.create content: {day: response.x, catalog: response.catalog, order: y_order, name: response.name, missing: false, type: "symptom" }

          else # There are no datums for the day and catalog... so put in a "missing" datum for that catalog
            @get("datums").push symptomDatum.create content: {day: day, catalog: catalog, order: 1.1, type: "symptom", missing: true }

  .observes("rawDataResponses")


  ### Filtering ###
  viewportDatums: Ember.computed(-> @get("datums").filter((datum) => @get("viewportDays").contains(datum.get("day"))) ).property("datums", "viewportDays")
  catalogDatums: Ember.computed(-> @get("viewportDatums").filterBy("catalog", @get("catalog")) ).property("catalog", "viewportDatums")

  unfilteredDatums: Ember.computed(->
    if Ember.isEmpty(@get("filteredResponseNames")) then return @get("catalogDatums")
    @get("catalogDatums").reject (response) => @get("filteredResponseNames").contains response.get("name")
  ).property("catalogDatums", "filteredResponseNames")

  unfilteredDatumsByDay: Ember.computed( ->
    @get("viewportDays").map (day) => @get("unfilteredDatums").filterBy("day", day)
  ).property("unfilteredDatums", "viewportDays")

  ### Loading/Buffering ###
  bufferRadius: Ember.computed( ->
    radius = Math.floor(@get("viewportSize") / 2)
    if radius < @get("bufferMin") then @get("bufferMin") else radius
  ).property("viewportSize")

  bufferWatcher: Ember.observer ->

    if @get("viewportStart") and @get("loadedStartDate") and @get("loadedEndDate")
      days_in_past_buffer   = Math.abs(@get("viewportStart").diff(@get("loadedStartDate"),"days"))
      days_in_future_buffer = Math.abs(@get("viewportEnd").diff(@get("loadedEndDate"),"days"))

      if days_in_past_buffer < @get("bufferRadius")
        new_loaded_start = moment(@get("loadedStartDate")).subtract(@get("bufferRadius"),"days")
        ajax(
          url: "#{config.apiNamespace}/graph"
          method: "GET"
          data:
            start_date: new_loaded_start.format("MMM-DD-YYYY")
            end_date: @get("viewportStart").format("MMM-DD-YYYY")
        ).then(
          (response) =>
            @set "loadedStartDate",new_loaded_start
            # @propertyWillChange("rawData")
            @set "rawData", Ember.merge(@get("rawData"), response)
            @propertyDidChange("rawData")
          (response) => console.log "?!?! error on getting graph"
        )

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
      #       @propertyWillChange("rawData")
      #       @set "rawData", Ember.merge(@get("rawData"), response)
      #       @propertyDidChange("rawData")
      #
      #     (response) => console.log "?!?! error on getting graph"
      #   )
  .observes("loadedStartDate", "loadedEndDate", "viewportStart")

  actions:
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

`export default controller`