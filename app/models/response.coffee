`import DS from 'ember-data'`

model = DS.Model.extend
  name:  attr("string")
  value:  attr()
  
`export default model`