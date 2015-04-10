`import DS from 'ember-data'`

model = DS.Model.extend
  obfuscated_id:        DS.attr "string"
  entries:              DS.hasMany "entry"
  treatments:           DS.hasMany "treatment"
  conditions:           DS.hasMany "condition"
  symptoms:             DS.hasMany "symptoms"

  locale:               DS.attr "string"
  email:                DS.attr "string"
  authentication_token: DS.attr "string"

  symptomColors:        DS.attr()
  treatmentColors:      DS.attr()

  settings:             DS.attr()
  catalogs:             DS.attr()

  checked_in_today:     DS.attr "boolean"

`export default model`