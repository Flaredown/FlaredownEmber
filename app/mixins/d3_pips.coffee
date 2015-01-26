`import Ember from 'ember'`

mixin = Ember.Mixin.create
  scorePip: ->
    @get("svg").selectAll("rect.symptom").data(@get("datums"), (d) -> d.get("id"))

  pipEnter: ->
    @scorePip()
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
            y: (d) -> d.get("end_y")
            x: (d) -> d.get("end_x")

  setupPips: ->
    @pipEnter()

  updatePips: ->
    @pipEnter()

    @scorePip()
      .attr
        width:  @get("symptomDatumDimensions").width
        height: @get("symptomDatumDimensions").height
        opacity: 100
        y: (d) -> d.get("end_y")
        x: (d) -> d.get("end_x")

    # unless @get("graphShifted") # don't do animations if the graph has shifted
    #   @scorePip()
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
    #   dayPips = @scorePip().filter(filterByDay)
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


    @scorePip()
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
