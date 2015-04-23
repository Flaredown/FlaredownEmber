`import Ember from 'ember'`
`import DS from 'ember-data'`

model = DS.Model.extend
  user:                 DS.belongsTo("user")

  date:                 DS.attr("string")
  responses:            DS.hasMany("response")
  catalogs:             DS.attr()
  catalog_definitions:  DS.attr()
  notes:                DS.attr("string")
  treatments:           DS.hasMany("treatment")
  complete:             DS.attr("boolean")
  just_created:         DS.attr("boolean")

  moment:     Ember.computed(-> moment(@get("date")) ).property("date")
  unixDate:   Ember.computed(-> @get("moment").unix() ).property("moment")
  niceDate:   Ember.computed(-> @get("moment").format("MMM-DD-YYYY") ).property("moment")
  fancyDate:  Ember.computed(-> @get("moment").format("MMMM D, YYYY") ).property("moment")

  dateAsParam: Ember.computed ->
    return "today" if moment().format("MMM-DD-YYYY") is @get("niceDate")
    @get("niceDate")
  .property("niceDate")

  validResponses: Ember.computed.filter("responses", (response) -> !Ember.isEmpty response.get("value"))

`export default model`