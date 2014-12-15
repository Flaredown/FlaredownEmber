`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`

App         = null
controller  = null
fixture     = null

moduleFor("controller:graph/index", "Graph Controller (basic)",
  {
    needs: ["controller:graph/symptom-datum"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      startDay    = moment().utc().startOf("day")
      fixture     = graphFixture(startDay)


      Ember.run ->
        controller.set "model", {}
        controller.set "rawData", fixture
        controller.set "catalog", "hbi"
        controller.set "viewportSize", 6
        controller.set "viewportStart", moment(startDay).utc().subtract(5, "days")
        controller.set "firstEntryDate", moment(startDay).utc().subtract(5, "days")

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "#rawDataResponses is a flattened array of responses from rawData", ->
  expect 2

  ok Ember.typeOf(controller.get("rawDataResponses")) is "array",                 "is an array"
  ok controller.get("rawDataResponses.length") is 34,                             "has expected length from fixtures"

### Responses ###
test "#responseNames lists all possible symptom names", ->
  expect 3

  ok Ember.typeOf(controller.get("responseNames")) is "array",                    "is an array"
  ok controller.get("responseNames").contains("fat toes") is true,                "contains an expected symptom name"
  ok controller.get("responseNames").length is 8,                                 "is the expected length based on fixtures"

test "#filteredCatalogResponseNames gets the difference of #catalogResponseNames and #filteredResponseNames", ->
  expect 1

  controller.set("filteredResponseNames", ["general_wellbeing", "ab_pain", "droopy lips"])
  deepEqual controller.get("filteredCatalogResponseNames").sort(), ["general_wellbeing", "ab_pain"].sort(), "only gives back filtered responses belonging to the catalog"

### Datums ###
test "#datums is an array of SymptomDatums generated from rawData", ->
  expect 4

  expected_datums = fixture.hbi.reduce ((accum, item) -> accum + item.points), 0
  expected_datums += fixture.symptoms.reduce ((accum, item) -> accum + item.points), 0

  ok Ember.typeOf(controller.get("datums")) is "array",                           "is an array"
  ok Ember.typeOf(controller.get("datums.firstObject")) is "instance",            "objects in array are instances (symptomDatums)"
  ok controller.get("datums.firstObject").get("order") is 1.1,                    "rawData objects have decimal order property for y positionin"
  ok controller.get("datums.length") is expected_datums,                          "has as many datums as the sum of rawData 'points'"

test "#viewportDatums: all datums that fit in the viewport", ->
  expect 1
  ok controller.get("viewportDatums.length") is 57,                               "has expected length from fixtures (all datums, all catalogs)"

test "#catalogDatums: all datums that fit in the viewport and catalog", ->
  expect 1
  ok controller.get("catalogDatums.length") is 39,                               "has expected length from fixtures (all datums in current catalog)"


test "#unfilteredDatums returns datums not being filtered based on their name, for the current catalog", ->
  expect 3

  controller.set("filteredResponseNames", []) # default
  deepEqual controller.get("unfilteredDatums").mapBy("name").uniq().sort(), ["general_wellbeing", "ab_pain", "stools", "ab_mass", "complications"].sort(), "no filtered names means all are visible"

  controller.set("filteredResponseNames", ["general_wellbeing", "ab_pain", "stools", "ab_mass"])
  deepEqual controller.get("unfilteredDatums").mapBy("name").uniq().sort(), ["complications"], "only matching datums"

  controller.set("filteredResponseNames", ["ab_pain", "droopy lips"])
  deepEqual controller.get("unfilteredDatums").mapBy("name").uniq().sort(), ["general_wellbeing", "complications", "stools", "ab_mass"].sort(), "doesn't care about filters from other catalogs"

test "#unfilteredDatumsByDay is an array of arrays containing datums for each day in #days", ->
  expect 3

  ok Ember.typeOf(controller.get("unfilteredDatumsByDay")) is "array",               "is an array"
  ok Ember.typeOf(controller.get("unfilteredDatumsByDay.firstObject")) is "array",   "made up of arrays"
  ok controller.get("unfilteredDatumsByDay.firstObject.length") is 7,                "First x coordinate has 5 responses -> 7 datum points"