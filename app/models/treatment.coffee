`import DS from 'ember-data'`

model = DS.Model.extend
  name:     DS.attr("string")

  quantity: DS.attr("number")
  unit:     DS.attr("string")
  # quantity: Em.computed( -> @get("currentUser.settings.treatment_#{@get("name")}_quantity") ).property("currentUser.settings.@each")
  # unit: Em.computed( -> @get("currentUser.settings.treatment_#{@get("name")}_unit") ).property("currentUser.settings.@each")
  hasDose: Em.computed(-> @get("quantity") isnt null and @get("unit") isnt null).property("quantity", "unit")

  didLoad: ->
    @set("active", true) if @get("hasDose")
    #
    # else
    #   @set("active", false)
    #   @set "quantity", @get("currentUser.settings.treatment_#{@get("name")}_quantity")
    #   @set "unit", @get("currentUser.settings.treatment_#{@get("name")}_unit")

`export default model`