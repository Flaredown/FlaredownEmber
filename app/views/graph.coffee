`import Ember from 'ember'`
`import D3DatestampsMixin from '../mixins/d3_datestamps'`
`import D3PipsMixin from '../mixins/d3_pips'`

view = Ember.View.extend D3PipsMixin, D3DatestampsMixin,

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
  daysAsMomentsBinding:           "controller.daysAsMoments"
  viewportDaysBinding:            "controller.viewportDays"
  viewportSizeBinding:            "controller.viewportSize"
  viewportMinSizeBinding:         "controller.viewportMinSize"

  datumsBinding:                  "controller.unfilteredDatums"
  datumsByDayBinding:             "controller.unfilteredDatumsByDay"
  datumsByDayInViewportBinding:   "controller.unfilteredDatumsByDayInViewport"


  streamGraphStyle: false
  dragAmplifier: 1.2 # amplify drag a bit

  # Animation Settings
  dropInDuration: 450
  perDatumDelay: 15

  ### CONTROL FUNCTIONALITY ###
  draggable: 'true'
  attributeBindings: 'draggable'
  graphShifted: false

  touchStart: (event) -> @set "dragStartX", event.originalEvent.touches[0].pageX
  touchMove:  (event) -> @dragGraph event.originalEvent.touches[0].pageX
  touchEnd:   (event) -> @changeViewport()

  dragStart:  (event) ->
    event.dataTransfer.setDragImage(window.dragImg, 0, 0)
    event.dataTransfer.setData("text/plain", "")
    @set "dragStartX", event.originalEvent.pageX

  dragOver: (event) -> @dragGraph event.originalEvent.pageX
  dragEnd:    (event) -> @changeViewport()

  dragGraph: (pixels) ->
    if @get("viewportDays.length") and @get("dragStartX") and pixels > 0
      difference          = pixels - @get("dragStartX")
      @set "shiftGraphPx", difference * @get("dragAmplifier")

  changeViewport: ->
    translation         = Math.abs(@get("shiftGraphPx"))
    direction           = if @get("shiftGraphPx") > 0 then "past" else "future"

    if translation > @get("datumWidth")
      days = Math.floor(Math.round(translation / @get("datumWidth")))

      # If graph timeline is overrun, just reset it
      if direction is "future"
        if @get("viewportDays.lastObject") is moment.utc().startOf("day").unix()
          @resetGraphShift()
        else if moment(@get("viewportDays.lastObject")*1000).utc().startOf("day").add(days, "days") > moment.utc().startOf("day")
          days-- until moment(@get("viewportDays.lastObject")*1000).utc().startOf("day").add(days, "days").unix() is moment.utc().startOf("day").unix()

      @controller.send("shiftViewport", days, direction)

    @set "dragStartX", false
    @set "graphShifted", true

  shift: Ember.observer ->
    @get("svg").attr("transform", "translate(" + @get("shiftGraphPx") + "," + @get("margin").top + ")")
  .observes("shiftGraphPx")

  resetGraphShift: ->
    @set "graphShifted", false
    @get("svg").attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")")

  ### Watch underlying datums ###
  symptomsMax: Ember.computed(-> d3.max(@get("datumsByDayInViewport") , (dayDatums) -> dayDatums.length) ).property("datumsByDayInViewport")
  # watchDatums: Ember.observer(-> ).observes("datums", "viewportDays")

  setupEndPositions: Ember.observer ->
    Ember.run.once =>
      @get("datumsByDay").forEach (day) =>
        # day.filter( (datum) -> ["symptom", "processing"].contains(datum.get("type"))).sortBy("order").forEach (datum,i) =>
        day.sortBy("order").forEach (datum,i) =>
          if @get("x")(1) and @get("y")(1)
            datum.set("end_x", @get("x")(datum.get("day")))

            if @get("streamGraphStyle") # half of the difference between max symptoms shown and this days symptoms
              offset = (@get("symptomsMax") - (day.length)) / 2
              datum.set "end_y", @get("y")((i+1) + (offset))
            else
              datum.set "end_y", @get("y")(i+1)

    Ember.run.next => @renderGraph()

  .observes("datumsByDay", "viewportDays")

  renderGraph: ->
    if @get("isSetup")
      @update()
    else
      @setup()

  ### COMMON DIMENSIONS ###
  datumWidth:   Ember.computed( ->  @get("width") / @get("viewportDays.length") ).property("viewportDays.length", "width")
  datumHeight:  Ember.computed( ->  @get("height") / @get("symptomsMax") ).property("symptomsMax", "height")

  symptomDatumDimensions: Ember.computed( ->
    width_margin_percent  = 0.20
    height_margin_percent = 0.10

    right       = @get("datumWidth")  * width_margin_percent
    left        = @get("datumWidth")  * width_margin_percent
    top         = @get("datumHeight") * height_margin_percent
    bottom      = @get("datumHeight") * height_margin_percent

    {
      width:  @get("datumWidth")-left-right
      height: @get("datumHeight")-top-bottom
      right_margin:  right
      left_margin:   left
      top_margin:    top
      bottom_margin: bottom
    }
  ).property("x", "y", "datums")

  ### D3 STUFF ###
  x: Ember.computed ->
    # Add domain to make room for pip width
    last_day = moment(@get("viewportDays.lastObject")*1000).utc().add(1,"day").unix()

    d3.scale.linear()
      .domain([@get("viewportDays.firstObject"), last_day])
      .range [@get("symptomDatumDimensions.right_margin")*2, @get("width")]
  .property("width", "viewportDays.@each")

  y: Ember.computed ->
    d3.scale.linear()
      .domain([0, @get("symptomsMax")+1])
      .range [@get("height"),0]

  .property("height", "symptomsMax")

  setup: ->
    # @set "margin", {top: 50, right: 50, bottom: 50, left: 50}
    @set "margin", {top: 0, right: 0, bottom: 50, left: 0}
    @set "width", $(".graph-container").width() - @get("margin").left - @get("margin").right
    @set "height", $(".graph-container").height() - @get("margin").top - @get("margin").bottom
    @setupEndPositions()

    @set("svg", d3.select(".graph-container").append("svg")
      .attr("id", "graph")
      .attr("width", "100%")
      .attr("height", "100%")
      .attr("viewBox","0 0 #{@get("width") + @get("margin").left + @get("margin").right} #{@get("height") + @get("margin").top + @get("margin").bottom}" )
      .append("g")
        .attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")"))

    @set("isSetup", true)

    @setupDatestamps()
    @setupPips()

    @update()

  update: ->

    @updatePips()
    @updateDatestamps()
    @resetGraphShift()

`export default view`
