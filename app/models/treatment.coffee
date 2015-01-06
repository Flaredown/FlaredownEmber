`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")
  quantity: DS.attr("number")
  unit:     DS.attr("string")

`export default model`