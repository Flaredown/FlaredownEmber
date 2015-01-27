`import Ember from 'ember'`

object = Ember.ObjectProxy.extend

  content:
    catalog:    undefined
    missing:    false
    processing: false

  sourceType: Ember.computed(-> if @get("catalog") then @get("catalog") else @get("type") ).property("catalog", "type")
  replacementType: Ember.computed(-> if @get("processing") or @get("misisng") then "temporary" else "actual" ).property("processing", "missing")

  # Initial attributes should be: day, catalog, order, name, type, missing
  id: Ember.computed(-> "#{@get("sourceType")}_#{@get("day")}_#{@get("order")}_#{@get("replacementType")}" ).property("sourceType", "day", "order", "replacementType")

  classes: Ember.computed(->
    names = [@get("type")]

    if not @get("missing") and not @get("processing")
      if @get("type") is "symptom"
        names.pushObject "sfill-#{@get("colorName")}"
      else if @get("type") is "treatment"
        names.pushObject "tfill-#{@get("colorName")}"

    if @get("processing")
      names.pushObject "processing"
      names.pushObject "processing-#{@get("order")}"
    else
      names.pushObject if @get("missing") then "missing" else "present"

    names.join(" ")
  ).property("type")

  entryDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM-DD-YYYY") ).property("day")
  tickDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM DD") ).property("day")

  colorName: Ember.computed( ->
    uniq_name = "#{@get("sourceType")}_#{@get("name")}"
    if colors = @get("controller.currentUser.#{@get("type")}Colors")
      if color = colors.find((color) => color[0] is uniq_name) then color[1] else ""
  ).property("controller.currentUser.symptomColors", "controller.currentUser.treatmentColors", "catalog", "name")

`export default object`