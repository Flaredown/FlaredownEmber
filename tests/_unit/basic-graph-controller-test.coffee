`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`
`import userFixture from "../fixtures/user-fixture"`

App         = null
controller  = null
fixture     = null

moduleFor("controller:graph", "Graph Controller (basic)",
  {
    needs: ["controller:graph/datum", "controller:current-user", "model:user"]
    setup: ->

      Ember.$.mockjax url: "#{config.apiNamespace}/current_user", responseText: userFixture()
      Ember.$.mockjax url: "#{config.apiNamespace}/locales/en", responseText: localeFixture()

      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      startDay    = moment().utc().startOf("day").subtract(5,"days")
      fixture     = graphFixture(startDay)

      controller.reopen { bufferWatcher: -> }

      Ember.run ->
        controller.set "model",           {}
        controller.set "rawData",         fixture
        controller.set "catalog",         "hbi"
        controller.set "catalog",         "hbi"
        controller.set "viewportSize",    6
        controller.set "viewportMinSize", 6
        controller.set "viewportStart",   moment(startDay).subtract(1,"day")
        controller.set "firstEntryDate",  moment(startDay)
        controller.set "loadedStartDate", moment(startDay)
        controller.set "loadedEndDate",   moment().utc().startOf("day")

        window.symptomColors    = userFixture().current_user.symptom_colors
        window.treatmentColors  = userFixture().current_user.treatment_colors

        # Not reset properly by App.destroy
        controller.set "_processedDatumDays",   []
        controller.set "_processedDatums",      []
        controller.set "serverProcessingDays",  []
        controller.set "filtered",              []

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)


test "#rawDatapoints is a flattened array of responses from rawData", ->
  expect 2

  ok Ember.typeOf(controller.get("rawDatapoints")) is "array",                 "is an array"
  ok controller.get("rawDatapoints.length") is 34+14,                          "has expected length from fixtures"

### Filters ###
test "#filterables contains filterable objects and their status", ->
  expect 8

  ok Ember.typeOf(controller.get("filterables")) is "array",    "is an array"
  ok controller.get("filterables").length is 11,                "is the expected length based on fixtures"

  first = controller.get("filterables.firstObject")
  equal Ember.typeOf(first), "object",                            "made up of objects"
  equal first.id, "hbi_general_wellbeing",                        "has a uniq name for an ID"
  equal first.name, "General well-being",                         "has a sensible name"
  equal first.source, "hbi",                                      "comes from a source"
  equal first.filtered, false,                                    "initially unfiltered"

  controller.get("filtered").pushObject "hbi_general_wellbeing"
  ok controller.get("filterables.firstObject.filtered") is true, "now filtered"

test "#catalogFilterables gets filterables for current catalog", ->
  expect 2

  ok controller.get("catalogFilterables.firstObject.name") is "General well-being"

  controller.set "catalog", "symptoms"
  ok controller.get("catalogFilterables.firstObject.name") is "fat toes"

test "#treatmentFilterables gets treatment filterables", ->
  expect 1

  ok controller.get("treatmentFilterables.firstObject.name") is "Tickles"

### Datums ###
test "#datums is an array of SymptomDatums generated from rawData", ->
  expect 3

  ok Ember.typeOf(controller.get("datums")) is "array",                           "is an array"
  ok Ember.typeOf(controller.get("datums.firstObject")) is "instance",            "objects in array are instances (symptomDatums)"
  ok controller.get("datums.firstObject").get("order") is 1.1,                    "rawData objects have decimal order property for y positionin"

test "#viewportDatums: all datums that fit in the viewport", ->
  expect 1

  equal controller.get("viewportDatums.length"), 57+8+14,                          "has expected length from fixtures (all datums, all catalogs) + treatments + 4 total missing days"

test "#catalogDatums: all datums that fit in the viewport and catalog and treatments", ->
  expect 1
  equal controller.get("catalogDatums.length"), 39+5+14,                           "has expected length from fixtures (all datums in current catalog) + treatments + 1 missing day"

test "#unfilteredDatumsByDay is an array of arrays containing datums for each day in #days", ->
  expect 3

  ok Ember.typeOf(controller.get("unfilteredDatumsByDay")) is "array",               "is an array"
  ok Ember.typeOf(controller.get("unfilteredDatumsByDay.firstObject")) is "array",   "made up of arrays"
  ok controller.get("unfilteredDatumsByDay.firstObject.length") is (2+1+1+2+2 + 3),  "First x coordinate has 5 responses, 3 treatments, -> 11 datum points"

### PROCESSING ###
test "#dayProcessing replaces datums for a day with processing representation", ->
  expect 2

  controller.get("serverProcessingDays").addObject(controller.get("days.lastObject"))
  equal controller.get("unfilteredDatumsByDay.lastObject.length"), 4,                         "3 symptoms dots in the processing representation + 1 treatment missing"
  ok controller.get("unfilteredDatumsByDay.lastObject.firstObject.processing") is true,      "is processing type"
