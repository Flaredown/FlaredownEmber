`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")
  quantity: DS.attr("number")
  unit:     DS.attr("string")

  takenWithoutDose: Em.computed.equal("quantity", -1)
  hasDose: Em.computed("quantity", "takenWithoutDose", -> @get("quantity") isnt null and not @get("takenWithoutDose"))
  taken: Em.computed.or("hasDose", "takenWithoutDose")

  didLoad: -> @set("active", true) if @get("taken")

`export default model`