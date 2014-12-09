`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`

App        = null
controller = null
fixture    = null

moduleFor("controller:graph/index", "Graph Controller",
  {
    needs: ["controller:graph/datum"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = graphFixture()

      Ember.run ->
        controller.set("model", {})
        controller.set("rawData", fixture)
        controller.set("catalog", "hbi")

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "#rawDataResponses is a flattened array of responses from rawData", ->
  expect 2

  ok Ember.typeOf(controller.get("rawDataResponses")) is "array",                 "is an array"
  ok controller.get("rawDataResponses.length") is 34,                             "has expected length from fixtures"

test "#responseNames lists all possible symptom names", ->
  expect 3

  ok Ember.typeOf(controller.get("responseNames")) is "array",                    "is an array"
  ok controller.get("responseNames").contains("fat toes") is true,                "contains an expected symptom name"
  ok controller.get("responseNames").length is 8,                                 "is the expected length based on fixtures"

test "#days lists all possible response names", ->
  ok Ember.typeOf(controller.get("days")) is "array",                             "is an array"
  ok controller.get("days.length") is 6,                                          "5 days, and one without responses"

test "#datums is an array of GraphDatums generated from rawData", ->
  expect 4

  expected_datums = fixture.hbi.reduce ((accum, item) -> accum + item.points), 0
  expected_datums += fixture.symptoms.reduce ((accum, item) -> accum + item.points), 0

  ok Ember.typeOf(controller.get("datums")) is "array",                           "is an array"
  ok Ember.typeOf(controller.get("datums.firstObject")) is                        "instance", "objects in array are instances (graphDatums)"
  ok controller.get("datums.firstObject").get("order") is 1.1,                    "rawData objects have decimal order property for y positionin"
  ok controller.get("datums.length") is expected_datums,                          "has as many datums as the sum of rawData 'points'"

