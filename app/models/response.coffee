`import DS from 'ember-data'`

model = DS.Model.extend
  name:   DS.attr("string")
  value:  DS.attr()
  
`export default model`