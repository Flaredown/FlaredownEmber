`import DS from 'ember-data'`

model = DS.Model.extend
  obfuscated_id:  DS.attr "string"
  entries:        DS.hasMany "entry"

  locale:         DS.attr "string"
  email:          DS.attr "string"

  symptomColors:   DS.attr()
  treatmentColors: DS.attr()

`export default model`