`import DS from 'ember-data'`
`import config from '../config/environment'`

model = DS.Model.extend
  obfuscated_id:        DS.attr "string"
  intercom_hash:        DS.attr "string"
  entries:              DS.hasMany "entry"
  treatments:           DS.hasMany "treatment"
  conditions:           DS.hasMany "condition"
  symptoms:             DS.hasMany "symptoms"
  catalogs:             DS.hasMany "catalogs"

  locale:               DS.attr "string"
  email:                DS.attr "string"
  authentication_token: DS.attr "string"
  created_at:           DS.attr "date"

  currentLocation:      null

  colors:               DS.attr(defaultValue: (-> []) )

  settings:             DS.attr(defaultValue: (-> {}) )

  checked_in_today:     DS.attr "boolean"

  momentDob: Em.computed("settings.dobDay", "settings.dobMonth", "settings.dobYear", ->
    date_string = "#{@get("settings.dobYear")} #{@get("settings.dobMonth")} #{@get("settings.dobDay")}"
    moment(date_string, "YYYY MM DD")
  )
  niceDob: Em.computed("momentDob", -> @get("momentDob").format("MMM DD, YYYY"))

  # settings
  onboarded: Em.computed(-> if @get("settings.onboarded") is undefined then false else JSON.parse(@get("settings.onboarded")) ).property("settings.onboarded")

  didLoad: ->
    # TODO HACK!
    @set("settings.ethnicOrigin", JSON.parse(@get("settings.ethnicOrigin"))) if @get("settings.ethnicOrigin")

    unless config.environment is "test"
      $.getJSON 'https://www.telize.com/geoip?callback=?', (json) =>
        @set("currentLocation", json)
        window.current_location = json


`export default model`