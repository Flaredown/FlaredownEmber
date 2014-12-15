`import Ember from 'ember'`
`import symptomDatum from './graph/symptom-datum'`
`import config from '../config/environment'`

controller = Ember.ObjectController.extend
  # sortProperties: ["unixDate"]
  # sortAscending: true

  ### Set by route ###
  # rawData, startDate, endDate, catalog
  filteredResponseNames: []

  startDateFormatted: Ember.computed( -> @get("startDate").format("MMM-DD-YYYY")).property("startDate")
  endDateFormatted:   Ember.computed( -> @get("endDate").format("MMM-DD-YYYY")).property("startEnd")

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

  days: Ember.computed( ->
    _days     = @get("rawDataResponses").mapBy("x").uniq()
    current   = moment(_days.get("firstObject")*1000)
    range     = Ember.A([current.unix()])
    a_day     = moment.duration(86400*1000)

    # Fill in days in between first data point even if no responses are present
    if _days.length
      until range.get("lastObject") is moment(_days.get("lastObject")*1000).unix()
        current.add a_day
        range.pushObject current.unix()
      range
    else
      []

  ).property("rawDataResponses")

  # Some timeline preference helpers
  isTwoWeeks:   Ember.computed.equal("days.length", 14)
  isTwoMonths:  Ember.computed.equal("days.length", 60)
  isOneYear:    Ember.computed.equal("days.length", 365)

  responseNames:                Ember.computed( -> @get("rawDataResponses").mapBy("name").uniq() ).property("rawDataResponses")
  catalogResponseNames:         Ember.computed( -> @get("rawDataResponses").filterBy("catalog", @get("catalog")).mapBy("name").uniq() ).property("rawDataResponses")
  filteredCatalogResponseNames: Ember.computed( -> @get("catalogResponseNames").filter( (name) => @get("filteredResponseNames").contains(name) ).compact() ).property("catalogResponseNames", "filteredResponseNames")

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

  catalogDatums: Ember.computed(-> @get("datums").filterBy("catalog", @get("catalog")) ).property("catalog", "datums")

  visibleDatums: Ember.computed(->
    if Ember.isEmpty(@get("filteredResponseNames")) then return @get("catalogDatums")
    @get("catalogDatums").reject (response) => @get("filteredResponseNames").contains response.get("name")
  ).property("catalogDatums", "filteredResponseNames")

  visibleDatumsByDay: Ember.computed( ->
    @get("days").map (day) => @get("visibleDatums").filterBy("day", day)
  ).property("visibleDatums", "days")

  # catalog: Ember.computed ->
  #   that = @
  #   @get("content").find (catalog) -> catalog.name == that.get("catalogName")
  # .property("content.@each")

  # addMedication: (coord) ->
  #   @get("medicationsData").push App.MedicationDatum.create({med_id: coord.med_id, x: @get("medsX")(coord.x), label: coord.label, date: coord.x, controller: @})

  # scoreByUnix: (unix) -> @get("catalog.scores").find (score) -> score.x == unix

  # datum:        (coord) -> symptomDatumController.create({id: coord.x.toString(), type: "normal", catalog: @get("catalogName"), x: coord.x, y: coord.y, origin: {x: coord.x, y: coord.y}, date: coord.x, controller: @})
  # missingDatum: (coord) -> symptomDatumController.create({id: coord.x.toString(), type: "missing", catalog: @get("catalogName"), x: coord.x, y: coord.y, origin: {x: coord.x, y: coord.y}, date: coord.x, controller: @})

  # scoreData: Ember.computed.map("dateRange", (unix) ->
  #   that = @
  #   score = that.scoreByUnix(unix)
  #   if score
  #     that.datum(score)
  #   else
  #     console.log "missing datum"
  #     that.missingDatum({x: unix, y: 0})
  # )
  #
  # scores: Ember.computed.mapBy("scoreData", "d3Format")

  # nodes: Ember.computed.map "scores", (score) -> {id: score.get("x"), x: score.get("x"), y: score.get("y"), px: score.get("x"), py: score.get("y")}

  # links: Ember.computed.map "linksData", (link) ->
  #   {source: link.source.get("index"), target: link.target.get("index")}

  # medications: Ember.computed.map "medicationsData", (medication) -> medication.get("d3Format")

  # medLines: Ember.computed ->
  #   that = @
  #   @get("medicationsHistory").map (med_id) ->
  #     that.get("medicationsData").filterBy("med_id", med_id).map (medication) ->
  #       medication.get("d3Format")
  # .property("medicationsData")

  actions:
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