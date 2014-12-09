`import Ember from 'ember'`
`import DS from 'ember-data'`

model = DS.Model.extend
  user:                 DS.belongsTo("user")

  date:                 DS.attr("string")
  responses:            DS.hasMany("response")
  catalogs:             DS.attr()
  catalog_definitions:  DS.attr()

  moment: Ember.computed ->
    moment.utc(@get("date"))
  .property("date")

  unixDate: Ember.computed ->
    @get("moment").unix()
  .property("moment")

  niceDate: Ember.computed ->
    @get("moment").format("MMM-DD-YYYY")
  .property("moment")

  dateAsParam: Ember.computed ->
    return "today" if moment.utc().format("MMM-DD-YYYY") is @get("niceDate")
    @get("niceDate")
  .property("niceDate")

  validResponses: Ember.computed.filter("responses", (response) -> !Ember.isEmpty response.get("value"))

  # responsesData: Ember.computed ->
  #   normalized = Ember.A([])
  #   @get("responses").forEach (response) ->
  #     switch response.get("question.kind")
  #       when "number"
  #         if response.get("value")
  #           normalized.push(response)
  #           response.set("value", parseInt(response.get("value")) )
  #       when "select"
  #         if response.get("value")
  #           normalized.push(response)
  #           response.set("value", parseInt(response.get("value")) )
  #       when "checkbox"
  #         response.set("value", 0) unless response.get("value")
  #         normalized.push(response)
  # .property("responses.@each.value")

`export default model`