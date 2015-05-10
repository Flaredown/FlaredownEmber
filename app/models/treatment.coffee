`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")
  quantity: DS.attr("number")
  unit:     DS.attr("string")

  hasDose: Em.computed(-> @get("quantity") isnt null and @get("unit") isnt null).property("quantity", "unit")

  didLoad: -> @set("active", true) if @get("hasDose")

`export default model`