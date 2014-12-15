`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import bigGraphFixture from "../fixtures/big-graph-fixture"`

App         = null
controller  = null
fixture     = null
startDay    = null
endDay      = null

moduleFor("controller:graph", "Graph Controller (big)",
  {
    needs: ["controller:graph/symptom-datum"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = bigGraphFixture(365)

      # Setup somewhere in the middle of available data
      # amount should account for buffer so it doesn't send off another request
      startDay  = moment().utc().startOf("day").subtract(100, "days")  # 100 days ago
      endDay    = moment(startDay).add(33, "days")     # 13 additional days, +10 buffer on either side

      modifiedFixture     = bigGraphFixture(365)
      modifiedFixture.hbi = modifiedFixture.hbi.filter((r) -> r.x >= startDay.unix() and r.x <= endDay.unix() )

      Ember.run ->
        controller.set "model", {}
        controller.set "rawData", modifiedFixture
        controller.set "viewportSize", 14
        # controller.set "viewportStart", moment(startDay).add(, "day")
        controller.set "firstEntryDate", moment().utc().startOf("day").subtract(364, "days")
        controller.set "catalog", "symptoms"

    teardown: -> Ember.run(App, App.destroy)
  }
)

### Viewport, buffer, range limitation ###
# test "#viewport adjusts ", ->

test "#viewportDays all days visible in viewportSize", ->
  expect 4


  ok controller.get("viewportDays.length") is controller.get("viewportSize"),               "matches viewport size"
  ok controller.get("viewportDays.firstObject") is controller.get("viewportStart").unix(),  "first day is same as viewportStart"
  # TODO remove computed property viewportStart
  # ok controller.get("days").contains(controller.get("viewportStart").unix()),               "days contains the viewportStart"
  # ok controller.get("days").contains(controller.get("viewportDays.lastObject")),            "days contains other viewportDays"

  controller.set("viewportSize", 500)
  # TODO after removing computed property viewportStart, this should be less than 365
  ok controller.get("viewportDays.length") is 365, "viewport can't get bigger than limits"

  controller.set("viewportStart", controller.get("firstEntryDate"))
  ok controller.get("viewportDays.length") is 365, "viewport can't get bigger than limits"

test "#bufferRadius is based on viewportSize, but has minimum", ->
  expect 2

  ok controller.get("bufferRadius") is 10, "Returns min with small viewport"

  controller.set "viewportSize", 50
  ok controller.get("bufferRadius") is 25, "Should be half the viewport"

test "#days loaded from rawData", ->
  expect 4

  ok Ember.typeOf(controller.get("days")) is "array",       "is an array"
  ok controller.get("days.length") is 34,                   "34 days total"
  ok controller.get("days.firstObject") is startDay.unix(), "startDay matches first day"
  ok controller.get("days.lastObject") is endDay.unix(),    "endDay matches last day"

### Actions ###
test "#expandViewport(days) expands the day range towards the past", ->
  expect 0
  # ok controller.send("expandViewport", ) is 7,                "First x coordinate has 5 responses -> 7 datum points"