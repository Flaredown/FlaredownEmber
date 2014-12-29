`import Ember from 'ember'`

view = Ember.View.extend

  ### CONFIG ###
  daysBinding:                    "controller.days"
  viewportDaysBinding:            "controller.viewportDays"

  datumsBinding:                  "controller.unfilteredDatums"
  datumsByDayBinding:             "controller.unfilteredDatumsByDay"
  datumsByDayInViewportBinding:   "controller.unfilteredDatumsByDayInViewport"

  streamGraphStyle: false
  dragAmplifier: 1.2 # amplify drag a bit

  # Animation Settings
  dropInDuration: 400
  perDatumDelay: 60

  symptomColors:
    [
      "#B081D9"
      "#F5A623"
      "#73C1BA"
      "#F47070"
      "#AED584"
    ]

  ### DRAG FUNCTIONALITY ###
  draggable: 'true'
  attributeBindings: 'draggable'

  touchStart: (event) -> @set "dragStartX", event.originalEvent.touches[0].pageX
  touchMove:  (event) -> @dragGraph event.originalEvent.touches[0].pageX
  touchEnd:   (event) -> @changeViewport()

  dragStart:  (event) -> @set "dragStartX", event.originalEvent.x
  drag:       (event) -> @dragGraph event.originalEvent.x
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

  shift: Ember.observer ->
    @get("svg").attr("transform", "translate(" + @get("shiftGraphPx") + "," + @get("margin").top + ")")
  .observes("shiftGraphPx")

  resetGraphShift: ->
    @get("svg").attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")")

  ### Watch underlying datums ###
  symptomsMax: Ember.computed(-> d3.max(@get("datumsByDayInViewport") , (dayDatums) -> dayDatums.length) ).property("datumsByDayInViewport")
  # watchDatums: Ember.observer(-> ).observes("datums", "viewportDays")

  setupEndPositions: Ember.observer ->
    Ember.run.once =>
      @get("datumsByDay").forEach (day) =>
        # TODO add in other types of datums
        day.filterBy("type", "symptom").sortBy("order").forEach (datum,i) =>
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
      @positionByDay() unless @get("dragStartX") # == is dragging
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
    @set "colors", d3.scale.ordinal().range(@get("symptomColors")).domain(@get("symptomsMax"))
    # @set "margin", {top: 50, right: 50, bottom: 50, left: 50}
    @set "margin", {top: 0, right: 0, bottom: 0, left: 0}
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
    scorePip = @get("svg").selectAll("rect.symptom").data(@get("datums"), (d) -> d.get("id"))
    scorePip
      .enter()
        .append("rect")
          .datum( (d) =>
            d.set "x", @get("x")(d.get("end_x"))
            d.set "y", @get("y")(d.get("end_y"))
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .attr
            class: (d) -> d.get("classes")
            ry: 3
            rx: 3
            x: (d) -> d.get("end_x")
            y: (d) => @get("y")(@get("symptomsMax")) # way above the graph
            fill: (d) => @get("colors")(d.get("name"))

    @positionByDay()

  positionByDay: () ->
    scorePip = @get("svg").selectAll("rect.symptom").data(@get("datums"), (d) -> d.get("id"))

    # TODO determine wether graph is shifted
    # onyl transition if graph is not shifted, otherwise skip transition
    # graphShifted =
    @resetGraphShift()

    scorePip
      .attr
        width:  @get("symptomDatumDimensions").width
        height: @get("symptomDatumDimensions").height
        opacity: 100
        y: (d) -> d.get("end_y")
        x: (d) -> d.get("end_x")

    ### CPU INTENSIVE ###
    # @get("days").forEach (day) =>
    #
    #   filterByDay = ((d,i) -> @ is d.get("day")).bind(day)
    #   dayPips = scorePip.filter(filterByDay)
    #   dayPips
    #
    #     # .transition()
    #     #   .ease("quad")
    #     #   .duration (d) =>
    #     #     if d.get("placed") then 100 else @get("dropInDuration")
    #     #   .delay (d,i) =>
    #     #     if d.get("placed") then i*10 else i*@get("perDatumDelay")
    #     #   .each "end", (d) -> d.set("placed", true)
    #     .attr
    #       width:  @get("symptomDatumDimensions").width
    #       height: @get("symptomDatumDimensions").height
    #       opacity: 100
    #       y: (d) -> d.get("end_y")
    #       x: (d) -> d.get("end_x")



  update: ->
    scorePip = @get("svg").selectAll("rect.symptom").data(@get("datums"), (d) -> d.get("id"))
    @set "colors", d3.scale.ordinal().range(@get("symptomColors")).domain(@get("symptomsMax"))

    scorePip
      .enter()
        .append("rect")
          .datum( (d) =>
            d.set "x", @get("x")(d.get("end_x"))
            d.set "y", @get("y")(d.get("end_y"))
            d.set "placed", true
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .attr
            class: (d) -> d.get("classes")
            ry: 3
            rx: 3
            x: (d) -> d.get("end_x")
            y: (d) -> d.get("end_y")
            width:  @get("symptomDatumDimensions").width
            height: @get("symptomDatumDimensions").height
            fill: (d) => @get("colors")(d.get("name"))

    scorePip
      .exit()
      # .transition()
      #   .ease("quad")
      #   .duration(500)
      #   .attr
      #     y: -1000
      #     opacity: 0
      #     fill: "transparent"

      .remove()


      # .each "end", (d) -> d.set("placed", false)

`export default view`
