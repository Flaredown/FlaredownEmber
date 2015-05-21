`import DS from 'ember-data'`

model = DS.Model.extend
  obfuscated_id:        DS.attr "string"
  entries:              DS.hasMany "entry"
  treatments:           DS.hasMany "treatment"
  conditions:           DS.hasMany "condition"
  symptoms:             DS.hasMany "symptoms"
  catalogs:             DS.hasMany "catalogs"

  locale:               DS.attr "string"
  email:                DS.attr "string"
  authentication_token: DS.attr "string"
  created_at:           DS.attr "date"

  symptomColors:        DS.attr(defaultValue: (-> []) )
  treatmentColors:      DS.attr(defaultValue: (-> []) )

  settings:             DS.attr(defaultValue: (-> {}) )

  checked_in_today:     DS.attr "boolean"

  # settings
  graphable: Em.computed(-> if @get("settings.graphable") is undefined then false else JSON.parse(@get("settings.graphable")) ).property("settings.graphable")
  onboarded: Em.computed(-> if @get("settings.onboarded") is undefined then false else JSON.parse(@get("settings.onboarded")) ).property("settings.onboarded")

  didLoad: ->
    # TODO HACK!
    @set("settings.ethnicOrigin", JSON.parse(@get("settings.ethnicOrigin"))) if @get("settings.ethnicOrigin")

`export default model`