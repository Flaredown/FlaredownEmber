`import Ember from 'ember'`

object = Ember.ObjectProxy.extend

  content:
    catalog:    undefined
    missing:    false
    processing: false

  sourceType:   Ember.computed(-> if @get("catalog") then "catalog" else @get("type") ).property("catalog", "type")
  source:       Ember.computed(-> if @get("sourceType") is "treatment" then "treatments" else @get("catalog") ).property("sourceType")
  status:       Ember.computed(-> if @get("processing") or @get("missing") then "temporary" else "actual" ).property("processing", "missing")
  sourced_name: Ember.computed( -> "#{@get("source")}_#{@get("name")}" )

  # Initial attributes should be: day, catalog, order, name, type, missing
  id: Ember.computed(-> "#{@get("sourceType")}_#{@get("day")}_#{@get("order")}_#{@get("status")}" ).property("sourceType", "day", "order", "status")

  classes: Ember.computed(->
    names = [@get("type")]

    if not @get("missing") and not @get("processing")
      if @get("sourceType") is "treatment"
        names.pushObject "tfill-#{@get("colorName")}"
      else
        names.pushObject "sfill-#{@get("colorName")}"

    if @get("processing")
      names.pushObject "processing"
      names.pushObject "processing-#{@get("order")}"
    else
      names.pushObject if @get("missing") then "missing" else "present"

    names.join(" ")
  ).property("type")

  entryDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM-DD-YYYY") ).property("day")
  axisDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM DD") ).property("day")

  colorName: Ember.computed( ->
    uniq_name = "#{@get("source")}_#{@get("name")}"
    if colors = @get("controller.currentUser.#{@get("type")}Colors")
      if color = colors.find((color) => color[0] is uniq_name) then color[1] else ""
  ).property("controller.currentUser.symptomColors", "controller.currentUser.treatmentColors", "sourceType", "name")

`export default object`