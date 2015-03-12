`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")
  quantity: DS.attr("number")
  unit:     DS.attr("string")
  active:   DS.attr("boolean")

`export default model`