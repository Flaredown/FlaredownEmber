`import DS from 'ember-data'`

model = DS.Model.extend
  entries:  DS.hasMany "entry"

  email:    DS.attr "string"
  weight:   DS.attr "number"

`export default model`