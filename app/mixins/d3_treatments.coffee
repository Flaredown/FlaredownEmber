`import Ember from 'ember'`
computed = Ember.computed

mixin = Ember.Mixin.create

  treatmentRadius: 7
  treatmentPadding: 30

  treatmentLineHeight: 2

  treatmentLineWidth: Ember.computed("pipDimensions", ->
    Ember.assert("need pipDimensions", Ember.isPresent(@get("pipDimensions")))
    @get("pipDimensions").total_width
  )

  treatmentsMax: computed("datumsByDayInViewport", ->
    d3.max(@get("datumsByDayInViewport"), (dayDatums) ->
      dayDatums.filterBy("type", "treatment").length
    )
  )

  treatments_y: computed("treatmentsHeight", "treatmentsMax", ->
    d3.scale.linear()
      .domain([0, @get("treatmentsMax")])
      .range [@get("treatmentsHeight") + @get("treatmentPadding"), @get("treatmentPadding")]
  )

  treatmentCircleSelection: ->
    @get("treatmentCanvas").selectAll("circle.treatment")
      .data(@get("treatmentDatums"), (d) -> d.get("id") if d.get("taken"))

  treatmentLineSelection: ->
    @get("treatmentCanvas").selectAll("line.treatment")
      .data(@get("treatmentDatums"), (d) -> d.get("id"))

  treatmentEnter: ->
    @treatmentLineSelection()
      .enter()
        .append("line")
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .on("mouseover", (d,i) => @jBoxFor(d) if d.get("status") is "actual" )
          .on("mouseout", (d,i) => @jBoxFor(d, true) )
          .attr(
            class: (d) -> d.get("classes")
          )

    @treatmentCircleSelection()
      .enter()
        .append("circle")
          .datum( (d) =>
            d.set "placed", true
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
          .on("mouseover", (d,i) => @jBoxFor(d) if d.get("status") is "actual" )
          .on("mouseout", (d,i) => @jBoxFor(d, true) )
          .attr
            class: (d) -> d.get("classes")
            r: @get("treatmentRadius")
            cy: (d) -> d.get("end_y")
            cx: (d) -> d.get("end_x")

  # treatmentLines: Ember.computed ->
  #   treatmentNames = @get("treatmentDatums").mapBy("name")
  #   treatmentNames.forEach (name) ->
  #     @get("treatmentDatums")
  #
  # .property("datums")

  updateTreatments: ->
    @treatmentEnter()
    @treatmentCircleSelection()
      .attr
        cy: (d) -> d.get("end_y")
        cx: (d) -> d.get("end_x")

    @treatmentCircleSelection()
      .exit()
      .remove()

    @treatmentLineSelection()
      .attr
        "stroke-dasharray": "2, 2"
        "stroke-linecap": "butt"        
        "stroke-width": @get("treatmentLineHeight")
        x1: (d) => d.get("end_x") - @get("treatmentLineWidth") / 2 if d.get("end_x")
        x2: (d) => d.get("end_x") + @get("treatmentLineWidth") / 2 if d.get("end_x")
        y1: (d) => d.get("end_y")
        y2: (d) => d.get("end_y")

    @treatmentLineSelection()
      .exit()
      .remove()

`export default mixin`
