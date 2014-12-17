`import Ember from 'ember'`
`import symptomDatum from './graph/symptom-datum'`
`import config from '../config/environment'`

controller = Ember.ObjectController.extend
  ### Set by route ###
  # rawData, firstEntryDate, viewportStart, catalog
  filteredResponseNames: []

  # startDateFormatted: Ember.computed( -> @get("startDate").format("MMM-DD-YYYY")).property("startDate")
  # endDateFormatted:   Ember.computed( -> @get("endDate").format("MMM-DD-YYYY")).property("startEnd")

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

  viewportDays: Ember.computed( ->
    [1..@get("viewportSize")].map (i) =>
      moment(@get("viewportStart")).add(i, "days")
    .filter (date) =>
      date >= @get("firstEntryDate") and date <= moment().utc().startOf("day")
    .map (date) ->
      date.unix()
  ).property("viewportSize", "viewportStart")

  days: Ember.computed( ->
    _days     = @get("rawDataResponses").mapBy("x").uniq()
    current   = moment(_days.get("firstObject")*1000).utc().startOf("day")
    last      = moment(_days.get("lastObject")*1000)
    range     = Ember.A([current.unix()])

    # Fill in days in between first data point even if no responses are present
    if _days.length
      until range.get("lastObject") is last.unix()
        range.pushObject current.add(1, "days").unix()
      range
    else
      []

  ).property("rawDataResponses")

  bufferRadius: Ember.computed( ->
    radius = Math.floor(@get("viewportSize") / 2)
    if radius < @get("bufferMin") then @get("bufferMin") else radius
  ).property("viewportSize")

  # Some timeline preference helpers
  isTwoWeeks:   Ember.computed.equal("viewportDays.length", 14)
  isTwoMonths:  Ember.computed.equal("viewportDays.length", 60)
  isOneYear:    Ember.computed.equal("viewportDays.length", 365)

  ### Catalogs and Catalog Based Filters ###
  catalogs: Ember.computed( -> Object.keys(@get("rawData")) ).property("rawData")

  ### Datums! ###
  datums: Ember.computed( ->

    _datums = []

    # For each day (x coord) among all data
    @get("days").forEach (day) =>
      @get("rawDataResponses").filterBy("x", day).sortBy("order").forEach (response) =>

        if response.points isnt 0
          [1..response.points].forEach (j) =>
            y_order = response.order + (j / 10) # order + 1, plus decimal second order (1.1, 1.2, etc)
                                                                                                                                                 #... as opposed to treatment or trigger
            _datums.push symptomDatum.create content: {day: response.x, catalog: response.catalog, order: y_order, name: response.name, type: "symptom" }

    _datums
  ).property("rawData", "days")


  viewportDatums: Ember.computed(-> @get("datums").filter((datum) => @get("viewportDays").contains(datum.get("day"))) ).property("datums", "viewportDays")
  catalogDatums: Ember.computed(-> @get("viewportDatums").filterBy("catalog", @get("catalog")) ).property("catalog", "viewportDatums")

  unfilteredDatums: Ember.computed(->
    if Ember.isEmpty(@get("filteredResponseNames")) then return @get("catalogDatums")
    @get("catalogDatums").reject (response) => @get("filteredResponseNames").contains response.get("name")
  ).property("catalogDatums", "filteredResponseNames")

  unfilteredDatumsByDay: Ember.computed( ->
    @get("viewportDays").map (day) => @get("unfilteredDatums").filterBy("day", day)
  ).property("unfilteredDatums", "viewportDays")

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

    setDateRange: (start, end) ->
      # TODO check formatting of start/end

      that = @
      $.ajax(
        url: "#{config.apiNamespace}/graph"
        method: "GET"
        data:
          start_date: start
          end_date: end
      ).then(
        (response) ->
          # that.set "catalog.scores", response.graph[0].scores
          # response.graph.forEach (catalog) ->
          #   that.get("model").select (catalogs) -> catalogs
          #   catalog
          Ember.run.once ->
            that.set("model", response.graph)


        (response) ->
          console.log "?!?! error on getting graph"
      )

`export default controller`