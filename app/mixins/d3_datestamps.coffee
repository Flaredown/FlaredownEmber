`import Ember from 'ember'`

mixin = Ember.Mixin.create
  datestampSelection: ->
    firstDatumsByDays = []
    allSymptomDatums  = @get("controller.datums").filterBy("type", "symptom")

    @get("days").map( (day) => allSymptomDatums.filterBy("day", day)).forEach (dayDatums) ->
      firstDatumsByDays.pushObject dayDatums.sortBy("order").get("firstObject")

    @get("svg").selectAll("text.datestamp").data(firstDatumsByDays, (d) -> d.get("id"))

    # firstDatumsOfTheDay = @get("datumsByDay").map( (dayDatums) -> dayDatums.filterBy("type", "symptom").get("firstObject") ).compact()
    # @get("svg").selectAll("text.datestamp").data(firstDatumsOfTheDay, (d) -> d.get("id"))

  datestampEnter: ->
    @datestampSelection()
      .enter()
      .append("text")
        .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
        .text (d) -> d.get("axisDate")
        .attr
          class: "datestamp"
          fill: "black"
          "data-width": => @get("pipDimensions.width")
          y: (d) => @symptomsHeight+@datesHeight
          dx: -> "#{($(@).attr("data-width") - @getBBox().width) / 2}px"

  updateDatestamps: ->
    @datestampEnter()
    @datestampSelection()
      .attr
        opacity: 0
        "data-width": => @get("pipDimensions.width")
        x: (d) => @get("x")(d.get("day"))
        dx: -> "#{($(@).attr("data-width") - @getBBox().width) / 2}px"


    modulo = Math.round(@get("viewportSize") / @get("viewportMinSize"))
    @datestampSelection()
      .filter (d,i) => i % modulo is 0
      .attr
        opacity: 1

    @datestampSelection()
      .exit()
      .remove()

`export default mixin`
