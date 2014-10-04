`import DS from 'ember-data'`

model = DS.Model.extend
  entries:  DS.hasMany "entry"
  
  email:    DS.attr "string"
  weight:   DS.attr "number"
  
  cdai_score_coordinates: DS.attr ""
  medication_coordinates: DS.attr ""
  medications:            DS.attr ""
  
`export default model`