`import DS from 'ember-data'`

model = DS.Model.extend
  value:      attr "number"
  label:      attr "string"
  meta_label: attr "string"
  helper:     attr "string"

`export default model`