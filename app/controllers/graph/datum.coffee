`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

object = Ember.ObjectProxy.extend colorableMixin,

  currentUserBinding: "controller.currentUser"

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
  uniqName: Ember.computed(-> "#{@get("source")}_#{@get("name")}").property("name", "source")
  formattedName: Ember.computed "name", "source", ->
    psuedoCatalog = ["treatments", "symptoms", "conditions"].contains(@get("source"))
    if psuedoCatalog then @get("name") else Em.I18n.t("catalogs.#{@get("source")}.#{@get("name")}")

  classes: Ember.computed(->
    names = [@get("type")]

    if not @get("missing") and not @get("processing")
      names.pushObject @colorClasses(@get("uniqName")).fill

    if @get("processing")
      names.pushObject "processing"
      names.pushObject "processing-#{@get("order")}"
    else
      names.pushObject if @get("missing") then "missing" else "present"

    names.join(" ")
  ).property("type")

  entryDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM-DD-YYYY") ).property("day")
  axisDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM DD") ).property("day")

`export default object`