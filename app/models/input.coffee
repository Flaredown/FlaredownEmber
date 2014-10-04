`import DS from 'ember-data'`

model = DS.Model.extend
  value:      DS.attr "number"
  label:      DS.attr "string"
  meta_label: DS.attr "string"
  helper:     DS.attr "string"

`export default model`