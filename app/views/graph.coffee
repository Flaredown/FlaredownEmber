`import Ember from 'ember'`

view = Ember.View.extend

  viewportDaysBinding:            "controller.viewportDays"
  viewportDatumsBinding:          "controller.viewportDatums"
  unfilteredDatumsBinding:        "controller.unfilteredDatums"
  unfilteredDatumsByDayBinding:   "controller.unfilteredDatumsByDay"

  streamGraphStyle: false

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

  draggable: 'true'
  attributeBindings: 'draggable'

  dragTooltip: new jBox("Tooltip")
  didInsertElement: -> @dragTooltip.attach(@$(".graph-container"))

  dragStart: (event) ->
    @set "dragStartX", event.originalEvent.x
  drag: (event) ->
    if @get("viewportDays.length") and @get("dragStartX") and event.originalEvent.x > 0
      difference = event.originalEvent.x - @get("dragStartX")
      days = Math.floor(difference / (@get("width") / @get("viewportDays.length")))
      @set("shiftViewportDays", days)
      if days > 0
        @dragTooltip.setContent("Go Back: #{days} days")
      else
        @dragTooltip.setContent("Go Forward: #{Math.abs(days)} days")

  dragEnd: (event) ->
    @set "dragStartX", false
    if @get("shiftViewportDays")
      direction = if @get("shiftViewportDays") > 0 then "past" else "future"
      @controller.send("shiftViewport", Math.abs(@get("shiftViewportDays")), direction)
      @set("shiftViewportDays", false)

  symptomsMax: Ember.computed(-> d3.max(@get("unfilteredDatumsByDay") , (dayDatums) -> dayDatums.length) ).property("unfilteredDatumsByDay")

  watchDatums: Ember.observer(-> Ember.run.next => @renderGraph()).observes("viewportDatums").on("didInsertElement")

  setupEndDatums: Ember.observer ->
    @get("unfilteredDatumsByDay").forEach (day) =>
      # TODO add in other types of datums
      day.filterBy("type", "symptom").sortBy("order").forEach (datum,i) =>
        if @get("x")(1) and @get("y")(1)
          datum.set("end_x", @get("x")(datum.get("day")))

          if @get("streamGraphStyle") # half of the difference between max symptoms shown and this days symptoms
            offset    = (@get("symptomsMax") - (day.length)) / 2
            datum.set "end_y", @get("y")((i+1) + (offset))
          else
            datum.set "end_y", @get("y")(i+1)

  .observes("unfilteredDatumsByDay")

  x: Ember.computed ->
    # Add domain to make room for pips
    tomorrow = moment(@get("viewportDays.lastObject")*1000).utc().add(1,"day").unix()

    d3.scale.linear()
      .domain([@get("viewportDays.firstObject"), tomorrow])
      .range [0, @get("width")]
  .property("width", "viewportDays.@each")

  y: Ember.computed ->
    d3.scale.linear()
      .domain([0, @get("symptomsMax")+1])
      .range [@get("height"),0]

  .property("height", "unfilteredDatumsByDay")

  # fillCoordinates: Ember.computed ->
  #   floor = @get("y")(@get("y").domain()[0])
  #   [
  #     Ember.Object.create({id: -1, x: @get("datums.firstObject.x"), y: floor, origin: {y: -floor}})
  #   ].concat(@get("datums"))
  #   .concat(Ember.Object.create({id: @get("datums.lastObject.id")+1, x: @get("datums.lastObject.x"), y: floor, origin: {y: -floor}}))
  # .property("datums.@each")

  symptomDatumDimensions: Ember.computed( ->
    base_width  =  (@get("width") / @get("viewportDays.length"))
    base_height =  (@get("height") / @get("symptomsMax"))

    width_margin_percent  = 0.20
    height_margin_percent = 0.10

    right       = base_width  * width_margin_percent
    left        = base_width  * width_margin_percent
    top         = base_height * height_margin_percent
    bottom      = base_height * height_margin_percent

    {
      width:  base_width-left-right
      height: base_height-top-bottom
      right_margin:  right
      left_margin:   left
      top_margin:    top
      bottom_margin: bottom
    }
  ).property("x", "y", "unfilteredDatums")

  setup: ->
    @set "colors", d3.scale.ordinal().range(@get("symptomColors")).domain(@get("symptomsMax"))
    # @set "margin", {top: 50, right: 50, bottom: 50, left: 50}
    @set "margin", {top: 0, right: 0, bottom: 0, left: 0}
    @set "width", $(".graph-container").width() - @get("margin").left - @get("margin").right
    @set "height", $(".graph-container").height() - @get("margin").top - @get("margin").bottom
    @setupEndDatums()

    @set("svg", d3.select(".graph-container").append("svg")
      .attr("id", "graph")
      .attr("width", "100%")
      .attr("height", "100%")
      .attr("viewBox","0 0 #{@get("width") + @get("margin").left + @get("margin").right} #{@get("height") + @get("margin").top + @get("margin").bottom}" )
      .append("g")
        .attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")"))

    # @get("svg").selectAll("line.horizontalGrid").data(@get("y").ticks(3)).enter()
    #   .append("line")
    #     .attr
    #       "class" : "horizontalGrid"
    #       "x1" : 0
    #       "x2" : @get("width")
    #       "y1" : (d) -> that.get("y")(d)
    #       "y2" : (d) -> that.get("y")(d)
    #       "fill" : "none"
    #       "shape-rendering" : "crispEdges"
    #       "stroke" : "black"
    #       "stroke-width" : "1px"

    # @get("svg").selectAll("line.verticalGrid").data(@get("x").ticks(10)).enter()
    #   .append("line")
    #     .attr
    #       "class" : "verticalGrid"
    #       "y1" : 0
    #       "y2" : @get("height")
    #       "x1" : (d) -> that.get("x")(d)
    #       "x2" : (d) -> that.get("x")(d)
    #       "fill" : "none"
    #       "shape-rendering" : "crispEdges"
    #       "stroke" : "black"
    #       "stroke-width" : "1px"

    # @set("startLine", d3.svg.line()
    #   .x( (d) -> d.x )
    #   .y( (d) => @get("height")*2 )
    # )
    #
    # @set("endLine", d3.svg.line()
    #   .x( (d) -> d.x )
    #   .y( (d) => @get("y")(d.get("end_y")) )
    # )

  update: (first) ->
    ### RECT VERSION ###
    scorePip = @get("svg").selectAll("rect.score").data(@get("unfilteredDatums"), (d) -> d.get("id"))

    scorePip
      .enter()
        .append("rect")
          .datum( (d) =>
            d.set "x", @get("x")(d.get("end_x"))
            d.set "y", @get("y")(d.get("end_y"))
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .attr
            class: (d) -> "score #{d.get("classes")}"
            ry: 3
            rx: 3
            x: (d) -> d.get("end_x")
            y: (d) => @get("y")(@get("viewportDays.length")*6) # way above the graph
            fill: (d) => @get("colors")(d.get("name"))

    @get("viewportDays").forEach (day) =>

      filterByDay = ((d,i) -> @ is d.get("day")).bind(day)
      dayPips = scorePip.filter(filterByDay)
      dayPips
        .transition()
          .ease("quad")
          .duration (d) =>
            if d.get("placed") then 100 else @get("dropInDuration")
          .delay (d,i) =>
            if d.get("placed") then i*10 else i*@get("perDatumDelay")
          .attr
            width:  @get("symptomDatumDimensions").width
            height: @get("symptomDatumDimensions").height
            opacity: 100
            y: (d) -> d.get("end_y")
            x: (d) -> d.get("end_x")
          .each "end", (d) -> d.set("placed", true)

    scorePip
      .exit()

      .transition()
        .ease("quad")
        .duration(500)
        .attr
          y: -1000
          opacity: 0
          fill: "transparent"
        .each "end", (d) -> d.set("placed", false)
        .remove()


  renderGraph: ->
    first = Ember.isEmpty @get("svg")
    @setup() if first
    @update(first)

`export default view`
