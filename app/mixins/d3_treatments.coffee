`import Ember from 'ember'`
computed = Ember.computed

mixin = Ember.Mixin.create

  treatmentRadius: 7
  treatmentPadding: 30

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

  treatmentSelection: ->
    @get("treatmentCanvas").selectAll("circle.treatment").data(@get("treatmentDatums"), (d) -> d.get("id"))

  treatmentEnter: ->
    @treatmentSelection()
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
    @treatmentSelection()
      .attr
        cy: (d) -> d.get("end_y")
        cx: (d) -> d.get("end_x")

    @treatmentSelection()
      .exit()
      .remove()

`export default mixin`
