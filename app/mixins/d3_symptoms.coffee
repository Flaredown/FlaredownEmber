`import Ember from 'ember'`

mixin = Ember.Mixin.create
  symptomHighlightOpacity: 0.1
  maxPipHeight: 50

  symptomsMax: Ember.computed(-> d3.max(@get("datumsByDayInViewport") , (dayDatums) -> dayDatums.filterBy("type", "symptom").length) ).property("datumsByDayInViewport")

  symptoms_y: Ember.computed ->
    max = @get("symptomsMax")
    max = (@symptomsHeight / @maxPipHeight) if @get("pipDimensions.total_height") >= @maxPipHeight

    d3.scale.linear()
      .domain([0, max+1])
      .range [@symptomsHeight,0]
  .property("height", "symptomsMax", "pipDimensions")

  pipDimensions: Ember.computed( ->
    width_margin_percent  = 0.20
    height_margin_percent = 0.10

    height      = if @get("pipHeight") > @maxPipHeight then @maxPipHeight else @get("pipHeight")
    width       = @get("pipWidth")

    right       = width * width_margin_percent
    left        = width * width_margin_percent
    top         = height * height_margin_percent
    bottom      = height * height_margin_percent

    {
      total_height: height
      total_width: width
      width:  width-left-right
      height: height-top-bottom
      right_margin:  right
      left_margin:   left
      top_margin:    top
      bottom_margin: bottom
    }
  ).property("x", "symptoms_y", "datums")

  pipWidth:   Ember.computed( ->  @get("width") / @get("viewportDays.length") ).property("viewportDays.length", "width")
  pipHeight:  Ember.computed( -> @symptomsHeight / @get("symptomsMax") ).property("symptomsMax", "symptomsHeight")

  pipSelection: (datums) ->
    datums ?= @get("symptomDatums")
    @get("mainCanvas").selectAll("rect.symptom").data(datums, (d) -> d.get("id"))

  highestOrderPipByDayAndName: (selected_datum) ->
    datums = @get("datums")
      .filterBy("day", selected_datum.get("day"))
      .filterBy("name", selected_datum.get("name"))

    datums.filter (datum) -> datum.get("order") is d3.max(datums,(d) -> d.get("order"))

  pipHighlight: Ember.observer ->
    Ember.run.later(
      =>
        if name = @get("symptomHighlight")
          @pipSelection().attr(opacity: 1)
          @pipSelection(@get("symptomDatums").rejectBy("name", name)).attr(opacity: @symptomHighlightOpacity)
        else
          @pipSelection().attr(opacity: 1)

      200
    )
  .observes("symptomHighlight")

  dehighlightPips: ->
    @jBoxFor(null, true)
    @pipSelection().attr(opacity: 1)

  pipEnter: ->
    that = @
    @pipSelection()
      .enter()
        .append("rect")
          .datum( (d) =>
            d.set "x", @get("x")(d.get("end_x"))
            d.set "y", @get("symptoms_y")(d.get("end_y"))
            d.set "placed", true
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .on("mouseover", (d,i) =>
            @set("symptomHighlight", d.get("name"))
            @jBoxFor(d) if d.get("status") is "actual"
          )
          .on("mouseout", (d,i) =>
            @set("symptomHighlight", null)
            @jBoxFor(d, true)
          )
          .attr
            class: (d) -> d.get("classes")
            ry: 3
            rx: 3
            y: (d) -> d.get("end_y")
            x: (d) -> d.get("end_x")

  updatePips: ->
    @pipEnter()
    @pipSelection()
      .attr
        class: (d) -> d.get("classes")
        width:  @get("pipDimensions").width
        height: @get("pipDimensions").height
        opacity: 100
        y: (d) -> d.get("end_y")
        x: (d) -> d.get("end_x")

    # unless @get("graphShifted") # don't do animations if the graph has shifted
    #   @pipSelection()
    #     .filter (d,i) => not d.get("placed") and d.get("end_x") > 0 and d.get("end_x") < @get("width")
    #     .attr
    #       y: -2000
    #     .transition()
    #       .ease("quad")
    #       .duration (d) => @get("dropInDuration")
    #       .delay (d,i) => i*@get("perDatumDelay")
    #       .each "end", (d) -> d.set("placed", true)
    #       .attr
    #         y: (d) -> d.get("end_y")

    ### CPU INTENSIVE ###
    # @get("days").forEach (day) =>
    #
    #   filterByDay = ((d,i) -> @ is d.get("day")).bind(day)
    #   dayPips = @pipSelection().filter(filterByDay)
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
    #       width:  @get("pipDimensions").width
    #       height: @get("pipDimensions").height
    #       opacity: 100
    #       y: (d) -> d.get("end_y")
    #       x: (d) -> d.get("end_x")


    @pipSelection()
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

`export default mixin`
