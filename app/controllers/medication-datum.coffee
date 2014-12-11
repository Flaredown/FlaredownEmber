`import Ember from 'ember'`

controller = Ember.Controller.extend
  dataBinding: "controller.medicationsData"

  text: Ember.computed ->
    if @get("dosage")
      "#{@get('label')} - #{@get('dosage')}"
    else
      @get("label")
  .property("label", "dosage")

  entryDate: Ember.computed ->
    moment.utc(@get("date")*1000).format("MMM-DD-YYYY")
  .property("x")

  level: Ember.computed ->
    that = @
    @get("data").filter (datum) ->
      datum.date is that.get("date")
    .sortBy("medClass").indexOf(this)
  .property("date", "med_id")

  medClass: Ember.computed ->
    @get("controller.medicationsHistory").indexOf(@get("med_id"))
  .property("med_id")

  y: Ember.computed ->
    @get("level")
  .property("level")

  index: Ember.computed ->
    @get("data").indexOf(@)
  .property("data")

  # origin: Ember.computed ->
  #   {x: @get("x"), y:@get("y")}
  # .property()

  objectFormat: Ember.computed ->
    Ember.Object.create @getProperties("x", "y", "level", "medClass", "text")
  .property("")

  d3Format: Ember.computed ->
    @get("objectFormat").setProperties index: @get("data").indexOf(@), model: @
  .property("kind")

  goTo: -> @transitionToRoute("graph.checkin", @get("entryDate"), 1)

`export default controller`