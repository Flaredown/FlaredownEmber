`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`

App         = null
controller  = null
fixture     = null

moduleFor("controller:graph", "Graph Controller (basic)",
  {
    needs: ["controller:graph/datum"]
    setup: ->
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
  ok Ember.typeOf(first) is "object",                            "made up of objects"
  ok first.id is "hbi_general_wellbeing",                        "has a uniq name for an ID"
  ok first.name is "general_wellbeing",                          "has a sensible name"
  ok first.source is "hbi",                                      "comes from a source"
  ok first.filtered is false,                                    "initially unfiltered"

  controller.get("filtered").pushObject "hbi_general_wellbeing"
  ok controller.get("filterables.firstObject.filtered") is true, "now filtered"

test "#catalogFilterables gets filterables for current catalog", ->
  expect 2

  ok controller.get("catalogFilterables.firstObject.name") is "general_wellbeing"

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
  ok controller.get("viewportDatums.length") is 57+4+14,                              "has expected length from fixtures (all datums, all catalogs) + treatments + 4 total missing days"

test "#catalogDatums: all datums that fit in the viewport and catalog and treatments", ->
  expect 1
  ok controller.get("catalogDatums.length") is 39+1+14,                               "has expected length from fixtures (all datums in current catalog) + treatments + 1 missing day"

test "#unfilteredDatumsByDay is an array of arrays containing datums for each day in #days", ->
  expect 3

  ok Ember.typeOf(controller.get("unfilteredDatumsByDay")) is "array",               "is an array"
  ok Ember.typeOf(controller.get("unfilteredDatumsByDay.firstObject")) is "array",   "made up of arrays"
  ok controller.get("unfilteredDatumsByDay.firstObject.length") is (2+1+1+2+2 + 3),  "First x coordinate has 5 responses, 3 treatments, -> 11 datum points"

### PROCESSING ###
test "#dayProcessing replaces datums for a day with processing representation", ->
  expect 2

  controller.get("serverProcessingDays").addObject(controller.get("days.lastObject"))
  ok controller.get("unfilteredDatumsByDay.lastObject.length") is 4,                         "3 symptoms + 1 treatment processing dots in the processing representation"
  ok controller.get("unfilteredDatumsByDay.lastObject.firstObject.processing") is true,      "is processing type"
