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
    @get("svg").selectAll("circle.treatment").data(@get("treatmentDatums"), (d) -> d.get("id"))

  treatmentEnter: ->
    @treatment()
      .enter()
        .append("circle")
          .datum( (d) =>
            d.set "placed", true
          )
          .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
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

`export default mixin`
