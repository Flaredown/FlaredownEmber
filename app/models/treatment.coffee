`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")

  quantity: DS.attr("number")
  unit:     DS.attr("string")
  # quantity: Em.computed( -> @get("currentUser.settings.treatment_#{@get("name")}_quantity") ).property("currentUser.settings.@each")
  # unit: Em.computed( -> @get("currentUser.settings.treatment_#{@get("name")}_unit") ).property("currentUser.settings.@each")
  hasDose: Em.computed.and("quantity", "unit")

  didLoad: ->
    if @get("quantity") and @get("unit")
      @set("active", true)
    else
      @set "quantity", @get("currentUser.settings.treatment_#{@get("name")}_quantity")
      @set "unit", @get("currentUser.settings.treatment_#{@get("name")}_unit")

`export default model`