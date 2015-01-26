`import Ember from 'ember'`

object = Ember.ObjectProxy.extend

  # Initial attributes should be: day, catalog, order, name, type, missing
  start_xBinding:  "day"

  id: Ember.computed(-> "#{@get("catalog")}_#{@get("day")}_#{@get("order")}_#{@get("type")}").property("catalog", "day", "order", "type")
  classes: Ember.computed(->
    names = ["symptom"]
    names.pushObject "sfill-#{@get("colorName")}"
    if @get("type") is "processing"
      names.pushObject "processing"
      names.pushObject "processing-#{@get("order")}"
    else
      names.pushObject if @get("missing") then "missing" else "present"

    names.join(" ")
  ).property("type")

  entryDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM-DD-YYYY") ).property("day")
  tickDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM DD") ).property("day")
  colorName: Ember.computed( ->
    uniq_name = "#{@get("catalog")}_#{@get("name")}"
    if symptom_colors = @get("controller.currentUser.symptomColors")
      if color = symptom_colors.find((color) => color[0] is uniq_name) then color[1] else ""
  ).property("controller.currentUser.symptomColors", "catalog", "name")

`export default object`