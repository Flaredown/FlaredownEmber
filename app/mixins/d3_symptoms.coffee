`import Ember from 'ember'`

mixin = Ember.Mixin.create
  symptomHighlightOpacity: 0.3

  symptomsMax: Ember.computed(-> d3.max(@get("datumsByDayInViewport") , (dayDatums) -> dayDatums.filterBy("type", "symptom").length) ).property("datumsByDayInViewport")

  symptoms_y: Ember.computed ->
    d3.scale.linear()
      .domain([0, @get("symptomsMax")+1])
      .range [@symptomsHeight,0]
  .property("height", "symptomsMax")

  symptomDatumDimensions: Ember.computed( ->
    width_margin_percent  = 0.20
    height_margin_percent = 0.10

    right       = @get("pipWidth")  * width_margin_percent
    left        = @get("pipWidth")  * width_margin_percent
    top         = @get("pipHeight") * height_margin_percent
    bottom      = @get("pipHeight") * height_margin_percent

    {
      width:  @get("pipWidth")-left-right
      height: @get("pipHeight")-top-bottom
      right_margin:  right
      left_margin:   left
      top_margin:    top
      bottom_margin: bottom
    }
  ).property("x", "symptoms_y", "datums")

  pipWidth:   Ember.computed( ->  @get("width") / @get("viewportDays.length") ).property("viewportDays.length", "width")
  pipHeight:  Ember.computed( ->  @symptomsHeight / @get("symptomsMax") ).property("symptomsMax", "symptomsHeight")

  pip: (datums) ->
    datums ?= @get("symptomDatums")
    @get("svg").selectAll("rect.symptom").data(datums, (d) -> d.get("id"))
  pipHighlight: Ember.observer ->
    Ember.run.later(
      =>
        if name = @get("symptomHighlight")
          @pip().attr(opacity: 1)
          @pip(@get("symptomDatums").rejectBy("name", name)).attr(opacity: @symptomHighlightOpacity)
        else
          @pip().attr(opacity: 1)

      200
    )
    @get("symptomDatums")
  .observes("symptomHighlight")

  pipEnter: ->
    @pip()
      .enter()
        .append("rect")
          .datum( (d) =>
            d.set "x", @get("x")(d.get("end_x"))
            d.set "y", @get("symptoms_y")(d.get("end_y"))
            d.set "placed", true
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .on("mouseover", (d,i) => @set("symptomHighlight", d.get("name")) )
          .on("mouseout", (d,i) => @set("symptomHighlight", null) )
          .attr
            class: (d) -> d.get("classes")
            ry: 3
            rx: 3
            y: (d) -> d.get("end_y")
            x: (d) -> d.get("end_x")

  setupPips: ->
    @pipEnter()

  updatePips: ->
    @pipEnter()

    @pip()
      .attr
        width:  @get("symptomDatumDimensions").width
        height: @get("symptomDatumDimensions").height
        opacity: 100
        y: (d) -> d.get("end_y")
        x: (d) -> d.get("end_x")

    # unless @get("graphShifted") # don't do animations if the graph has shifted
    #   @pip()
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
    #   dayPips = @pip().filter(filterByDay)
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


    @pip()
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
