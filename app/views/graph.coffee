`import Ember from 'ember'`
`import D3DatestampsMixin from '../mixins/d3_datestamps'`
`import D3SymptomsMixin from '../mixins/d3_symptoms'`
`import D3TreatmentsMixin from '../mixins/d3_treatments'`
`import DraggableGraphMixin from '../mixins/draggable_graph'`

view = Ember.View.extend D3SymptomsMixin, D3DatestampsMixin, D3TreatmentsMixin, DraggableGraphMixin,

  didInsertElement: ->
    @renderGraph()
    window.onresize = this.updateChartSize.bind(@);

    # datepicker setup
    $('.graph-controls-startDate').pickadate(
      min: @get("currentUser.momentCreatedAt").local().toDate()
      max: @get("controller.viewportEnd").local().toDate()
      onClose: -> @$holder.blur()
    )
    $('.graph-controls-endDate').pickadate(
      min: @get("currentUser.momentCreatedAt").local().toDate()
      max: @get("controller.viewportEnd").local().toDate()
      onClose: -> @$holder.blur()
    )

    # Enable keyboard to manipulate graph, needing focus is bad though
    #   @$().attr({ tabindex: 1 })
    #   @$().focus()
    #
    # keyDown: (e) ->
    #   amount = if e.shiftKey then 10 else 1
    #   switch e.keyCode
    #     when 37 then @controller.send("shiftViewport", amount, "past")    # keyboard: left arrow
    #     when 39 then @controller.send("shiftViewport", amount, "future")  # keyboard: right arrow

  willDestroy: ->
    window.onresize = null

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

  treatmentViewportDatumNamesBinding: "controller.treatmentViewportDatumNames"
  
  streamGraphStyle: false
  dragAmplifier: 1.2 # amplify drag a bit

  # Animation Settings
  dropInDuration: 450
  perDatumDelay: 15

  # Graph section heights, (note: depends on css settings)
  symptomsHeight:   400
  datesHeight:      25

  treatmentsHeight: Ember.computed("treatmentViewportDatumNames.@each", ->
    Ember.assert("must have treatmentViewportDatumNames", !Ember.isNone(@get("treatmentViewportDatumNames")))
    Ember.assert("must have treatmentPadding", Ember.isPresent(@get("treatmentPadding")))
    @get("treatmentPadding") * @get("treatmentViewportDatumNames").uniq().length + 40)

  height: Ember.computed("symptomsHeight", "datesHeight", "treatmentsHeight", ->
    @get("symptomsHeight") + @get("datesHeight") + @get("treatmentsHeight")
  )

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
          # if @get("x")(1) and @get("treatments_y")(1)
          datum.set "end_x", @get("x")(datum.get("day")) + (@get("pipDimensions.width") / 2)
          datum.set "end_y", @get("treatments_y")(datum.get("name"))

    Ember.run.next => @renderGraph()

  .observes("datumsByDay", "viewportSize", "controller.viewportStart")

  watchViewportSize: Ember.observer ->
    @updateDatestamps() if @get("isSetup")
  .observes("viewportSize")

  renderGraph: ->
    if @get("isSetup")
      @updatePips()
      @updateTreatments()
      @updateDatestamps()
      @resetGraphShift()
    else
      @setup()

  ### D3 STUFF ###
  x: Ember.computed ->
    # Add domain to make room for pip width
    last_day = moment(@get("viewportDays.lastObject")*1000).utc().add(1,"day").unix()

    d3.scale.linear()
      .domain([@get("viewportDays.firstObject"), last_day])
      .range [@get("pipDimensions.right_margin") * 2, @get("width")]
  .property("width", "viewportDays.@each")

  setup: ->
    @set "margin", {top: 0, right: 0, bottom: 0, left: 0}
    @set "width", $(".graph-container").width() - @get("margin").left - @get("margin").right
    @setupEndPositions()

    @set("svg", d3.select(".graph-container").append("svg")
      .attr("id", "graph")
      .attr("width", "100%")
      .attr("height", "100%")
      # .attr("height", @get("height"))
      .attr("viewBox","0 0 #{@get("width") + @get("margin").left + @get("margin").right} #{@get("height") + @get("margin").top + @get("margin").bottom}" )
    )

    @set("allCanvases", @get("svg").append("g")
      .attr("class", "all-canvases")
    )

    @set("mainCanvas", @get("allCanvases").append("g")
      .attr("class", "main-canvas")
      .attr("transform", "translate(" + @get("margin").left + ", " + @get("margin").top + ")")
    )

    @set("dateCanvas", @get("allCanvases").append("g")
      .attr("class", "date-canvas")
      .attr("transform", "translate(" + @get("margin").left + ", " + parseInt(@get("margin").top + @get("symptomsHeight")) + ")")
    )

    @set("treatmentCanvas", @get("allCanvases").append("g")
      .attr("class", "treatment-canvas")
      .attr("transform", "translate(" + @get("margin").left + ", " + parseInt(@get("margin").top + @get("symptomsHeight") + @get("datesHeight")) + ")")
    )

    @set("isSetup", true)

    @pipEnter()
    @treatmentEnter()
    @datestampEnter()

  updateChartSize: ->
    @get("svg")
      .attr("viewBox","0 0 #{@get("width") + @get("margin").left + @get("margin").right} #{@get("height") + @get("margin").top + @get("margin").bottom}" )

    # in case we want to adjust size of mainCanvas or dateCanvas later
    # @get("dateCanvas")
    #   .attr("transform", "translate(" + @get("margin").left + ", " + parseInt(@get("margin").top + @get("symptomsHeight")) + ")")
    #
    # @get("treatmentCanvas")
    #   .attr("transform", "translate(" + @get("margin").left + ", " + parseInt(@get("margin").top + @get("symptomsHeight") + @get("datesHeight")) + ")")

    Em.run.next => @renderGraph()

`export default view`
