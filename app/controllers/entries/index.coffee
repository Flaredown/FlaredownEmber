`import Ember from 'ember'`
`import EntryDatumController from '../entry-datum'`

controller = Ember.ArrayController.extend
  needs: ["currentUser"]
  sortProperties: ["unixDate"]
  sortAscending: true
  
  hasScores: Ember.computed.notEmpty "catalog.scores.[]"
  
  startDateFormatted: Ember.computed( -> @get("startDate").format("MMM-DD-YYYY")).property("startDate")
  endDateFormatted: Ember.computed( -> @get("endDate").format("MMM-DD-YYYY")).property("startEnd")
  
  catalogName: "cdai"
  catalog: Ember.computed ->
    that = @
    @get("content").find (catalog) -> catalog.name == that.get("catalogName")
  .property("content.@each")
  
  dateRange: Ember.computed( ->
    current = moment(@get("catalog.scores.firstObject.x")*1000)
    range   = Ember.A([current.unix()])
    a_day   = moment.duration(86400*1000)
    
    if @get("hasScores")
      until range.get("lastObject") is @get("catalog.scores.lastObject.x")
        current.add a_day
        range.pushObject current.unix()
      range
    else
      Ember.A()
      
  ).property("catalog.scores")
    
  # addMedication: (coord) ->
  #   @get("medicationsData").push App.MedicationDatum.create({med_id: coord.med_id, x: @get("medsX")(coord.x), label: coord.label, date: coord.x, controller: @})
  
  scoreByUnix: (unix) -> @get("catalog.scores").find (score) -> score.x == unix
  
  datum:        (coord) -> EntryDatumController.create({id: coord.x.toString(), type: "normal", catalog: @get("catalogName"), x: coord.x, y: coord.y, origin: {x: coord.x, y: coord.y}, date: coord.x, controller: @})
  missingDatum: (coord) -> EntryDatumController.create({id: coord.x.toString(), type: "missing", catalog: @get("catalogName"), x: coord.x, y: coord.y, origin: {x: coord.x, y: coord.y}, date: coord.x, controller: @})
  
  scoreData: Ember.computed.map("dateRange", (unix) ->
    that = @
    score = that.scoreByUnix(unix)
    console.log score
    if score
      that.datum(score)
    else
      console.log "??!?!"
      that.missingDatum({x: unix, y: 0})
  )
      
  scores: Ember.computed.mapBy("scoreData", "d3Format")

  # nodes: Ember.computed.map "scores", (score) -> {id: score.get("x"), x: score.get("x"), y: score.get("y"), px: score.get("x"), py: score.get("y")}
  
  # links: Ember.computed.map "linksData", (link) ->
  #   {source: link.source.get("index"), target: link.target.get("index")}

  medications: Ember.computed.map "medicationsData", (medication) -> medication.get("d3Format")
    
  medLines: Ember.computed ->
    that = @
    @get("medicationsHistory").map (med_id) ->     
      that.get("medicationsData").filterBy("med_id", med_id).map (medication) ->
        medication.get("d3Format")
  .property("medicationsData")
  
  actions:
    setDateRange: (start, end) ->
      # TODO check formatting of start/end
      
      that = @
      $.ajax(
        url: "/chart"
        method: "GET"
        data: 
          start_date: start
          end_date: end
      ).then(
        (response) ->
          # that.set "catalog.scores", response.chart[0].scores
          # response.chart.forEach (catalog) ->
          #   that.get("model").select (catalogs) -> catalogs
          #   catalog
          Ember.run.once ->
            that.set("model", response.chart)
            
          
        (response) ->
          console.log "?!?! error on getting chart"
      )
      
`export default controller`