`import Ember from 'ember'`

view = Ember.View.extend

  daysBinding:                "controller.days"
  datumsBinding:              "controller.datums"
  visibleDatumsBinding:       "controller.visibleDatums"
  visibleDatumsByDayBinding:  "controller.visibleDatumsByDay"

  symptomColors:
    [
      "#B081D9"
      "#F5A623"
      "#73C1BA"
      "#F47070"
      "#AED584"
    ]

  willDestroy: ->
    # @get("force").stop()

  symptomsMax: Ember.computed(-> d3.max(@get("visibleDatumsByDay") , (dayDatums) -> dayDatums.length) ).property("visibleDatumsByDay")

  watchDatums: Ember.observer ->
    Ember.run.next => @renderGraph()
  .observes("datums").on("didInsertElement")

  setupEndPositions: Ember.observer ->
    @get("visibleDatumsByDay").forEach (day) =>
      # TODO add in other types of datums
      day.filterBy("type", "symptom").sortBy("order").forEach (datum,i) =>
        datum.set("end_x", @get("x")(datum.get("day")))
        datum.set("end_y", @get("y")(i+1))


  .observes("visibleDatumsByDay")

  x: Ember.computed ->
    d3.scale.linear()
      .domain([@get("days.firstObject"), @get("days.lastObject")])
      .range [0, @get("width")]
  .property("width", "days.@each")

  y: Ember.computed ->
    d3.scale.linear()
      .domain([0, @get("symptomsMax")+1])
      .range [@get("height"),0]

  .property("height", "visibleDatumsByDay")

  # fillCoordinates: Ember.computed ->
  #   floor = @get("y")(@get("y").domain()[0])
  #   [
  #     Ember.Object.create({id: -1, x: @get("datums.firstObject.x"), y: floor, origin: {y: -floor}})
  #   ].concat(@get("datums"))
  #   .concat(Ember.Object.create({id: @get("datums.lastObject.id")+1, x: @get("datums.lastObject.x"), y: floor, origin: {y: -floor}}))
  # .property("datums.@each")

  symptomDatumDimensions: Ember.computed( ->
    base_width  =  (@get("width") / @get("days.length"))
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
  ).property("x", "y", "visibleDatums")

  setup: ->
    # TODO can we get rid of "that" and "controller"?
    that = @
    controller = @get("controller")

    @set "container", $(".graph-container")
    @set "colors", d3.scale.ordinal().range(@get("symptomColors")).domain(@get("symptomsMax"))
    # @set "margin", {top: 50, right: 50, bottom: 50, left: 50}
    @set "margin", {top: 0, right: 0, bottom: 0, left: 0}
    @set "width", @get("container").width() - @get("margin").left - @get("margin").right
    @set "height", @get("container").height() - @get("margin").top - @get("margin").bottom
    @setupEndPositions()

    # @set("force", d3.layout.force()
    #   # .charge( (d) -> d.charge)
    #   # .gravity(0)
    #   # .linkDistance(1)
    #   # .linkStrength(0.5)
    #   .alpha(1)
    #   .size([@get("width"), @get("height")])
    #   .on("tick", @tick(@))
    # )

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

    @set("startLine", d3.svg.line()
      .x( (d) -> d.x )
      .y( (d) -> that.get("height")*2 )
    )

    @set("endLine", d3.svg.line()
      .x( (d) -> d.x )
      .y( (d) -> that.get("y")(d.origin.y) )
    )

  # tick: (self) ->
  #     (e) ->
  #       k = e.alpha
  #
  #       Ember.run ->
  #         # Calculate next positions of datums based on physicsy stuff  ("cooling")
  #         self.get("svg").selectAll("circle.score").each (d,i) ->
  #           d.set "y", (d.get("y") + (self.get("y")(d.get("end_y")) - d.get("y")) * k)
  #           # d.set "x", (d.get("x") + (self.get("x")(d.get("start_x")) - d.get("x")) * k)
  #
  #         # Now set those positions on the dom elements
  #         self.get("svg").selectAll("circle.score")
  #           .attr
  #             cx: (d) -> d.get("end_x")
  #             cy: (d) -> d.get("y")



  update: (first) ->

    ### RECT VERSION ###
    scorePip = @get("svg").selectAll("rect.score").data(@get("visibleDatums"))
    # scoreCircle.order()

    scorePip
      .enter()
        .append("rect")
          .datum( (d) =>
            d.set "x", @get("x")(d.get("end_x"))
            d.set "y", @get("y")(d.get("end_y"))
          )
          .attr
            class: (d) -> "score #{d.get("classes")}"
            # r: 3
            ry: 3
            rx: 3
            x: (d) -> d.get("end_x")
            # y: (d) -> d.get("end_y")
            y: (d) => @get("y")(@get("days.length")*6) # way above the graph
            width:  @get("symptomDatumDimensions").width
            height: @get("symptomDatumDimensions").height
            fill: (d) => @get("colors")(d.get("name"))
            # cx: (d) -> d.get("x")
            # cy: (d) => @get("y")(@get("days.length")*6) # way above the graph
            # opacity: 0

    @get("days").forEach (day) ->
      that = @

      filterByDay = ((d,i) -> @ is d.get("day")).bind(day)
      scorePip.filter(filterByDay)
        .transition()
          # .each("start", (d,i) -> d.fixed = false)
          # .each("end", (d,i) -> that.get("force").stop())
          .ease("quad")
          .duration(700)
          .delay((d,i) -> i*60)
          .attr
            opacity: 100
            y: (d) -> d.get("end_y")

    scorePip
      .exit()

      .transition()
        # .each("start", (d,i) -> d.fixed = true)
        .duration(300)
        .attr(
          fixed: true
          y: -1000
          opacity: 0
          x: (d) -> d.get("x")
        )
        .remove()

    hitbox = @get("svg").selectAll("circle.hitbox").data(@get("visibleDatums"))

    hitbox
      .exit()
        .remove()

    hitbox
      .enter()
        .append("rect")
          .attr
            fixed: true
            class: "hitbox"
            fill: "transparent"
            r: (d) -> 5 #(that.get("width") / scoreCircle[0].length) / 2
            cx: (d) => d.get("x")
            cy: (d) => d.get("end_y")

    hitbox.on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
      # .attr
      #   r: (d) -> 10 #(that.get("width") / scoreCircle[0].length) / 2
      #   cx: (d) => d.get("x")
      #   cy: (d) => d.get("end_y")
      #   fill: "black"
      # .on("mouseenter", (d,i) ->
      #   d3.select(scoreCircle[0][d.index]).transition()
      #     .duration(200)
      #     .attr("r", 30)
      #     .style("stroke-width", "3px")
      #
      #   d3.select(scoreText[0][d.index]).transition()
      #     .duration(200)
      #     .attr("opacity", 1)
      #     .style("font-size", "20px")
      # )
      # .on("mouseleave", (d,i) ->
      #
      #   d3.select(scoreCircle[0][d.index]).transition()
      #     .duration(300)
      #     .attr("r", 6)
      #     .style("stroke-width", "2px")
      #
      #   d3.select(scoreText[0][d.index]).transition()
      #     .duration(300)
      #     .attr("opacity", 0)
      #     .style("font-size", "10px")
      # )


      # .each (d,i) ->
      #   hitbox = d3.select(that.get("svg").selectAll("circle.hitbox")[0][i])
      #   d.x = parseFloat hitbox.attr("cx")
      #   d.y = parseFloat hitbox.attr("cy")


    # @get("force").nodes(@get("visibleDatums"))
    # Ember.A(@get("force").nodes()).sortBy("id").forEach (d,i) ->
    #   if isNaN(d.get("x")) or isNaN(d.get("y"))
    #     circle = d3.select(that.get("svg").selectAll("circle.score")[0][i])
    #     d.set "x", parseFloat circle.attr("cx")
    #     d.set "y", parseFloat circle.attr("cy")
    #
    # @get("force").start()

  renderGraph: ->
    first = Ember.isEmpty @get("svg")
    @setup() if first
    @update(first)

`export default view`