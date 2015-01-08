`import DS from 'ember-data'`

model = DS.Model.extend
  obfuscated_id:  DS.attr "string"
  entries:        DS.hasMany "entry"

  locale:         DS.attr "string"
  email:          DS.attr "string"
  weight:         DS.attr "number"

`export default model`