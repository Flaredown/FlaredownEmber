`import Ember from 'ember'`
`import D3DatestampsMixin from '../mixins/d3_datestamps'`
`import D3SymptomsMixin from '../mixins/d3_symptoms'`
`import D3TreatmentsMixin from '../mixins/d3_treatments'`
`import DraggableGraphMixin from '../mixins/draggable_graph'`

view = Ember.View.extend D3SymptomsMixin, D3DatestampsMixin, D3TreatmentsMixin, DraggableGraphMixin,

  didInsertElement: ->
    $('.graph-controls-startDate').pickadate()
    $('.graph-controls-endDate').pickadate(max: @get("controller.viewportEnd").local().toDate())
    # Enable keyboard to manipulate graph, needing focus is bad though
    #   @$().attr({ tabindex: 1 })
    #   @$().focus()
    #
    # keyDown: (e) ->
    #   amount = if e.shiftKey then 10 else 1
    #   switch e.keyCode
    #     when 37 then @controller.send("shiftViewport", amount, "past")    # keyboard: left arrow
    #     when 39 then @controller.send("shiftViewport", amount, "future")  # keyboard: right arrow

  ### CONFIG ###
  daysBinding:                    "controller.days"
  viewportDaysBinding:            "controller.viewportDays"
  viewportSizeBinding:            "controller.viewportSize"
  viewportMinSizeBinding:         "controller.viewportMinSize"

  datumsBinding:                  "controller.unfilteredDatums"
  datumsByDayBinding:             "controller.unfilteredDatumsByDay"
  datumsByDayInViewportBinding:   "controller.unfilteredDatumsByDayInViewport"

  treatmentDatumsBinding:         "controller.treatmentDatums"
  symptomDatumsBinding:           "controller.symptomDatums"

  streamGraphStyle: false
  dragAmplifier: 1.2 # amplify drag a bit

  # Animation Settings
  dropInDuration: 450
  perDatumDelay: 15

  # Graph section heights, (note: depends on css settings)
  symptomsHeight:   400
  datesHeight:      25
  treatmentsHeight: 100
  height: Ember.computed(-> @symptomsHeight + @datesHeight + @treatmentsHeight)

  jBoxFor: (datum, close) ->
    @set "tooltip", new jBox("Mouse", {id: "jbox-tooltip", x: "right", y: "center"}) unless @get("tooltip")
    if close then @get("tooltip").close() else @get("tooltip").setContent(datum.get("formattedName")).open()

  setupEndPositions: Ember.observer ->
    Ember.run.once =>
      @get("datumsByDay").forEach (datums) =>
        datums.filterBy("type", "symptom").sortBy("order").forEach (datum,i) =>
          if @get("x")(1) and @get("symptoms_y")(1)
            datum.set "end_x", @get("x")(datum.get("day"))
            datum.set "end_y", @get("symptoms_y")(i+1)

        datums.filterBy("type", "treatment").sortBy("order").forEach (datum,i) =>
          if @get("x")(1) and @get("treatments_y")(1)
            datum.set "end_x", @get("x")(datum.get("day")) + (@get("pipDimensions.width")  / 2)
            datum.set "end_y", @get("treatments_y")(i+1)

    Ember.run.next => @renderGraph()

  .observes("datumsByDay", "viewportSize", "controller.viewportStart")

  watchViewportSize: Ember.observer ->
    @updateDatestamps() if @get("isSetup")
  .observes("viewportSize")

  renderGraph: ->
    if @get("isSetup")
      @updatePips()
      @updateTreatments()
      @resetGraphShift()
    else
      @setup()
      @updateDatestamps()

  ### D3 STUFF ###
  x: Ember.computed ->
    # Add domain to make room for pip width
    last_day = moment(@get("viewportDays.lastObject")*1000).utc().add(1,"day").unix()

    d3.scale.linear()
      .domain([@get("viewportDays.firstObject"), last_day])
      .range [@get("pipDimensions.right_margin")*2, @get("width")]
  .property("width", "viewportDays.@each")

  setup: ->
    # @set "margin", {top: 50, right: 50, bottom: 50, left: 50}
    @set "margin", {top: 0, right: 0, bottom: 0, left: 0}
    @set "width", $(".graph-container").width() - @get("margin").left - @get("margin").right
    # @set "height", $(".graph-container").height() - @get("margin").top - @get("margin").bottom
    @setupEndPositions()

    @set("svg", d3.select(".graph-container").append("svg")
      .attr("id", "graph")
      .attr("width", "100%")
      .attr("height", "100%")
      .attr("viewBox","0 0 #{@get("width") + @get("margin").left + @get("margin").right} #{@get("height") + @get("margin").top + @get("margin").bottom}" )
      .append("g")
        .attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")"))

    @set("isSetup", true)


    @pipEnter()
    @treatmentEnter()
    @datestampEnter()

`export default view`
