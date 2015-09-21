`import Ember from 'ember'`
`import DS from 'ember-data'`

model = DS.Model.extend
  defaultResponseValues:
    checkbox: 0
    select: null
    number: null

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

  didLoad: ->
    @set("tags",[]) unless @get("tags")

  checkinData: Ember.computed(->
    checkin_data =
      responses: @get("responsesData")
      notes: @get("notes")
      tags: @get("tags")
      treatments: @get("treatmentData")

    JSON.stringify(checkin_data)
  ).property("treatmentData", "responsesData", "notes", "tags")

  responsesData: Ember.computed(->
    that            = @
    responses       = []

    entryResponses = @get("responses")
    catalogs = @get("catalogs")

    if catalogs and entryResponses
      catalogs.removeObjects(["symptoms", "conditions"])
      catalogs.sort()
      catalogs.addObjects(["symptoms", "conditions"])

      catalogs.forEach (catalog) =>
        that.get("catalog_definitions.#{catalog}").forEach (section) =>
          section.forEach (question) ->
            # Lookup an existing response loaded on the Entry, use it's value to setup responsesData, otherwise null
            response  = entryResponses.findBy("id", "#{catalog}_#{question.name}_#{that.get("id")}")
            value     = if response then response.get("value") else that.defaultResponseValues[question.kind]

            responses.pushObject Ember.Object.create({name: question.name, value: value, catalog: catalog})

    responses
  ).property("catalog_definitions", "responses.[]", "responses.@each.value" )

  treatmentData: Ember.computed(->
    treatments = @get("treatments")
    if treatments
        treatment_data = treatments.map((treatment) ->
          if treatment.get("active")
            if treatment.get("hasDose") # Taken w/ doses
              treatment.getProperties("name", "quantity", "unit")
            else # Taken no doses
              Ember.merge treatment.getProperties("name"), {quantity: -1, unit: null}
          else # Not taken
            treatment.getProperties("name", "quantity", "unit")
        ).compact()

    treatment_data
  ).property("treatments.@each")

`export default model`