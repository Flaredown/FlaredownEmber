`import Ember from 'ember'`

controller = Ember.ObjectProxy.extend

  # Initial attributes should be: day, catalog, order, name, type, missing
  start_xBinding:  "day"

  id: Ember.computed(-> "#{@get("catalog")}_#{@get("day")}_#{@get("order")}_#{@get("type")}").property("catalog", "day", "order", "type")
  classes: Ember.computed(->
    names = ["symptom"]
    if @get("type") is "processing"
      names.pushObject "processing"
      names.pushObject "processing-#{@get("order")}"
    else
      names.pushObject if @get("missing") then "missing" else "present"

    names.join(" ")
  ).property("type")

  entryDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM-DD-YYYY") ).property("day")

`export default controller`