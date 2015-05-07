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
  tags:                 DS.attr()
  complete:             DS.attr("boolean")
  just_created:         DS.attr("boolean")

  moment:     Ember.computed(-> moment(@get("date"), "MMM-DD-YYYY") ).property("date")
  unixDate:   Ember.computed(-> @get("moment").unix() ).property("moment")
  niceDate:   Ember.computed(-> @get("moment").format("MMM-DD-YYYY") ).property("moment")
  isPast:     Ember.computed(-> @get("fancyDate") isnt Ember.I18n.t("today") ).property("fancyDate")

  fancyDate:  Ember.computed(->
    diff = @get("moment").diff(moment(), "days")
    if diff is 0
      Ember.I18n.t("today")
    else if diff is -1
      Ember.I18n.t("yesterday")
    else if @get("moment").format("YYYY") is moment().format("YYYY")
      @get("moment").format("MMMM D")
    else
      @get("moment").format("MMMM D, YYYY")
  ).property("moment")

  dateAsParam: Ember.computed ->
    return "today" if moment().format("MMM-DD-YYYY") is @get("niceDate")
    @get("niceDate")
  .property("niceDate")

  validResponses: Ember.computed.filter("responses", (response) -> !Ember.isEmpty response.get("value"))


`export default model`