`import Ember from 'ember'`

mixin = Ember.Mixin.create
  datestamp: ->
    firstDatumsOfTheDay = @get("datumsByDay").mapBy("firstObject").compact()
    @get("svg").selectAll("text.datestamp").data(firstDatumsOfTheDay, (d) -> d.get("id"))

  datestampEnter: ->
    @datestamp()
      .enter()
      .append("text")
        .on("click", (d,i) => @get("controller").transitionToRoute("graph.checkin", d.get("entryDate"), 1) )
        .text (d) -> d.get("tickDate")
        .attr
          class: "datestamp"
          fill: "black"
          "data-width": => @get("symptomDatumDimensions.width")
          y: (d) => @get("height")+20
          x: (d) -> d.get("end_x")
          dx: -> "#{($(@).attr("data-width") - @getBBox().width) / 2}px"


  setupDatestamps: -> @datestampEnter()

  updateDatestamps: ->
    @datestampEnter()

    @datestamp()
      .attr
        opacity: 0
        "data-width": => @get("symptomDatumDimensions.width")
        x: (d) -> d.get("end_x")
        dx: -> "#{($(@).attr("data-width") - @getBBox().width) / 2}px"


    modulo = Math.round(@get("viewportSize") / @get("viewportMinSize"))
    @datestamp()
      .filter (d,i) => i % modulo is 0
      .attr
        opacity: 1

    @datestamp()
      .exit()
      .remove()

`export default mixin`
