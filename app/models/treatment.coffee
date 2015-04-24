`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")

  # quantity: DS.attr("number")
  # unit:     DS.attr("string")
  quantity: Em.computed( -> @get("currentUser.settings.treatment_#{@get("name")}_quantity") ).property("currentUser.settings.@each")
  unit: Em.computed( -> @get("currentUser.settings.treatment_#{@get("name")}_unit") ).property("currentUser.settings.@each")

`export default model`