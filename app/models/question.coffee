`import DS from 'ember-data'`

model = DS.Model.extend
  inputs:   hasMany("input")
  
  catalog:  attr("string")
  name:     attr("string")
  kind:     attr("string")
  section:  attr("number")
  group:    attr("string")
  
  inputPartial: Ember.computed ->
    "questioner/#{@get("kind")}_input"
  .property("kind")

# App.QuestionSerializer = DS.ActiveModelSerializer.extend DS.EmbeddedRecordsMixin,
#   attrs:
#     input_options: {embedded: "always"}

`export default model`