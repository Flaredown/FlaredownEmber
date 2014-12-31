`import DS from 'ember-data'`

model = DS.Model.extend
  entries:  DS.hasMany "entry"

  locale:   DS.attr "string"
  email:    DS.attr "string"
  weight:   DS.attr "number"

`export default model`