`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")
  value:    DS.attr()
  catalog:  DS.attr("string")

`export default model`