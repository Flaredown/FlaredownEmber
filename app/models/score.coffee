`import DS from 'ember-data'`

model = DS.Model.extend
  name: DS.attr('string')
  value: DS.attr('number')

`export default model`