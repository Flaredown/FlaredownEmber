`import Ember from 'ember'`
`import DS from 'ember-data'`

model = DS.Model.extend
  inputs:   DS.hasMany("input")
  
  catalog:  DS.attr("string")
  name:     DS.attr("string")
  kind:     DS.attr("string")
  section:  DS.attr("number")
  group:    DS.attr("string")
  
  inputPartial: Ember.computed ->
    "questioner/#{@get("kind")}_input"
  .property("kind")

# App.QuestionSerializer = DS.ActiveModelSerializer.extend DS.EmbeddedRecordsMixin,
#   attrs:
#     input_options: {embedded: "always"}

`export default model`