`import Ember from 'ember'`

mixin = Ember.Mixin.create

  treatmentRadius: 7

  treatmentsMax: Ember.computed(-> d3.max(@get("datumsByDayInViewport") , (dayDatums) -> dayDatums.filterBy("type", "treatment").length) ).property("datumsByDayInViewport")

  treatments_y: Ember.computed(->
    d3.scale.linear()
      .domain([0, @get("treatmentsMax")])
      .range [@get("height")-@get("treatmentsHeight"),@get("height")]
  ).property("height", "treatmentsMax")

  treatment: ->
    @get("svg").selectAll("circle.treatment").data(@get("datums").filterBy("type", "treatment"), (d) -> d.get("id"))

  treatmentEnter: ->
    @treatment()
      .enter()
        .append("circle")
          .datum( (d) =>
            # d.set "x", @get("x")(d.get("end_x"))
            # d.set "y", @get("treatments_y")(d.get("end_y"))
            d.set "placed", true
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .attr
            class: (d) -> d.get("classes")
            r: @get("treatmentRadius")
            cy: (d) -> d.get("end_y")
            cx: (d) -> d.get("end_x")

  #
  # addMedication: (coord, xScale, yScale, target) ->
  #   @get("medicationsData").push App.ChartMedication.create({med_id: coord.med_id, x: xScale(coord.x), label: coord.label, date: coord.x,  controller: @, target: target})
  #
  # medications: Em.computed.map "medicationsData", (medication) ->
  #   medication.get("d3Format")
  #
  # medLines: Em.computed ->
  #   that = @
  #   @get("medicationsHistory").map (med_id) ->
  #     that.get("medicationsData").filterBy("med_id", med_id).map (medication) ->
  #       medication.get("d3Format")
  # .property("medicationsData")
  #
  #
  setupTreatments: ->
    @treatmentEnter()

  updateTreatments: ->
    @treatmentEnter()

    @treatment()
      .attr
        cy: (d) -> d.get("end_y")
        cx: (d) -> d.get("end_x")

    @treatment()
      .exit()
      .remove()

    # MEDS
    # medications = @get("controller.user.medication_coordinates")
    #
    # @set "medicationsHistory", Em.A(@get("controller.user.medications"))
    #
    # @set "meds-container", $(".meds-chart-container")
    # @set "meds-margin", {top: 50, right: 50, bottom: 10, left: 50}
    # @set "meds-width", @get("meds-container").width() - @get("meds-margin").left - @get("meds-margin").right
    # @set "meds-height", @get("meds-container").height() - @get("meds-margin").top - @get("meds-margin").bottom

    # @set "meds-y", d3.scale.linear()
    #   .domain([@get("medicationsHistory").length-1,0])
    #   .range [@get("meds-height"),0]
    # @set "meds-x", d3.scale.linear()
    #   .domain([d3.min(medications, (d) -> d.x), d3.max(medications, (d) -> d.x)])
    #   .range [0, @get("meds-width")]

    # @set "meds-svg", d3.select(".meds-chart-container").append("svg")
    #   .attr("id", "meds-chart")
    #   .attr("width", "100%")
    #   .attr("height", "100%")
    #   .attr("viewBox","0 0 #{@get("meds-width") + @get("meds-margin").left + @get("meds-margin").right} #{@get("meds-height") + @get("meds-margin").top + @get("meds-margin").bottom}" )
    #   .append("g")
    #     .attr("transform", "translate(" + @get("meds-margin").left + "," + @get("meds-margin").top + ")")
    #
    # medications.forEach (coord) ->
    #   that.addMedication coord, that.get("meds-x"), that.get("meds-y"), that.get("controller.target") unless coord is null
  #
  # renderMedications: ->
  #   that = @
  #
  #   @get("medLines").forEach (medLine) ->
  #
  #     line = d3.svg.line().x( (d) -> d.x ).y( (d) -> d.y )
  #
  #     that.get("meds-svg").append("path")
  #       .datum(medLine)
  #       .attr("class", "med-line")
  #       .attr("d", line)
  #
  #   medication = @get("meds-svg").selectAll("g.medication-group").data(@get("medications")).enter()
  #     .append("g")
  #       .attr(class: "medication-group")
  #       .on("mouseenter", (d,i) ->
  #         d3.select(this).select("text").transition()
  #           .duration(500)
  #           .attr
  #             "opacity": 1
  #             "dy": (d) -> d.y - 20
  #           .style("font-size", "15px")
  #       )
  #       .on("mouseleave", (d,i) ->
  #         d3.select(this).select("text").transition()
  #           .duration(10)
  #           .attr
  #             "opacity": 0
  #             "dy": (d) -> d.y
  #
  #           .style("font-size", "10px")
  #       )
  #
  #   medication.append("text")
  #     .attr
  #        class: "med-text"
  #        dx: (d) -> d.x
  #        dy: (d) -> d.y
  #        opacity: 0
  #     .style("text-anchor", "middle")
  #     .attr("font-family", "Arial")
  #     .attr("font-size", "10px")
  #     .text( (d) -> d.text)
  #
  #   medication.append("circle")
  #     .attr
  #       class: (d) -> "medication med-level-#{d.medClass+1}"
  #       cx: (d) -> d.x
  #       cy: (d) -> d.y
  #       r: 5


`export default mixin`
