`import DS from 'ember-data'`

model = DS.Model.extend
  entries:  hasMany "entry"
  
  email:  attr "string"
  weight: attr "number"
  
  cdai_score_coordinates: attr ""
  medication_coordinates: attr ""
  medications: attr ""
  
`export default model`