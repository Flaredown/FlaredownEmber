`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


`import bigGraphFixture from "../fixtures/big-graph-fixture"`

App           = null
controller    = null
fixture       = null
startDay      = null
endDay        = null
viewportStart = null
firstEntry    = null

moduleFor("controller:graph", "Graph Controller (big)",
  {
    needs: ["controller:graph/symptom-datum"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = bigGraphFixture(365)

      Ember.$.mockjax
        url: "#{config.apiNamespace}/graph",
        type: 'GET'
        responseText: fixture

      # Setup somewhere in the middle of available data
      # amount should account for buffer so it doesn't send off another request
      startDay      = moment().utc().startOf("day").subtract(100, "days")   # 100 days ago
      endDay        = moment(startDay).add(53, "days")                      # 13 additional days (match viewport), +20 buffer on either side
      viewportStart = moment(startDay).add(20,"days")                       # place buffer on the left
      firstEntry    = moment().utc().startOf("day").subtract(364, "days")   # a year ago

      modifiedFixture     = bigGraphFixture(365)
      modifiedFixture.hbi = modifiedFixture.hbi.filter((r) -> r.x >= startDay.unix() and r.x <= endDay.unix() )

      Ember.run ->
        controller.set "model",           {}
        controller.set "rawData",         modifiedFixture
        controller.set "viewportSize",    14
        controller.set "viewportStart",   viewportStart
        controller.set "firstEntryDate",  firstEntry
        controller.set "catalog",         "symptoms"
        controller.set "loadedStartDate", moment(startDay)
        controller.set "loadedEndDate",   moment(endDay)

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)

### Viewport, buffer, range limitation ###
test "#viewportDays all days visible in viewportSize", ->
  expect 5

  ok controller.get("viewportDays.length") is controller.get("viewportSize"),                                                         "matches viewport size"
  ok controller.get("viewportDays.firstObject") is moment(controller.get("viewportStart")).add(1,"day").unix(),                       "first day is same as viewportStart + 1 (non-inclusive)"
  ok controller.get("viewportDays.lastObject") is controller.get("viewportStart").add(controller.get("viewportSize"),"days").unix(),  "last day is same as viewportStart + viewportSize"

  ok controller.get("days").contains(controller.get("viewportStart").unix()),               "days contains the viewportStart"
  ok controller.get("days").contains(controller.get("viewportDays.lastObject")),            "days contains other viewportDays"

test "#viewportEnd is the last date in the viewportDays", ->
  expect 1

  ok controller.get("viewportEnd").unix() is controller.get("viewportStart").add(controller.get("viewportSize"),"days").unix()

test "viewport can't overrun graph limitations", ->
  expect 2

  controller.send("resizeViewport", 500)
  ok controller.get("viewportSize") is 364, "expands to max based on limitations"
  ok controller.get("viewportStart").unix() is controller.get("firstEntryDate").unix()

test "viewport can't size down below minimum", ->
  expect 1

  controller.send("resizeViewport", -100, startDay)
  ok controller.get("viewportSize") is controller.get("viewportMinSize")

test "viewport can't shift below minimum size", ->
  expect 1

  controller.send("resizeViewport", 0, moment.utc().startOf("day"))
  ok controller.get("viewportSize") is controller.get("viewportMinSize")

test "viewport can't size up viewport past 'today'", ->
  expect 1

  controller.set("viewportStart", moment().utc().startOf("day").subtract(14, "days"))
  controller.send("resizeViewport", 10, "future")
  ok controller.get("viewportSize") is 14

test "#days loaded from rawData", ->
  expect 4

  ok Ember.typeOf(controller.get("days")) is "array",       "is an array"
  ok controller.get("days.length") is 54,                   "54 days total"
  ok controller.get("days.firstObject") is startDay.unix(), "startDay matches first day"
  ok controller.get("days.lastObject") is endDay.unix(),    "endDay matches last day"

test "#bufferRadius is based on viewportSize, but has minimum", ->
  expect 2

  ok controller.get("bufferRadius") is 20, "Returns min with small viewport"

  controller.set "viewportSize", 50
  ok controller.get("bufferRadius") is 50, "Should be same size as the viewport"

test "shifting viewport outside of loaded range triggers loading", ->
  expect 2

  # min buffer is 20
  # 20 days buffered, shift 1 to trigger more buffer
  controller.send("shiftViewport", 1, "past")
  stop()

  # What an ugly test you are
  setTimeout(
    ->
      Ember.run ->
        ok controller.get("loadedStartDate").unix() is moment(controller.get("viewportStart")).subtract(39,"days").unix(), "adds 20 more to the existing buffer"
      start()

      controller.send("shiftViewport", 1, "past")
      stop()
      setTimeout(
        ->
          Ember.run ->
            ok controller.get("loadedStartDate").unix() is moment(controller.get("viewportStart")).subtract(38,"days").unix(), "doesn't rebuffer unless radius is crossed again"
            start()
      , 10)
  , 10)

test "shifting viewport outside of loaded range adds more datums", ->
  raw_length = controller.get("rawData.hbi.length")
  controller.send("shiftViewport", 11, "past")
  stop()

  setTimeout(
    ->
      Ember.run ->
        ok controller.get("rawData.hbi.length") > raw_length, "adds some to rawData"
        start()

  , 10)

### Actions ###
test "#resizeViewport(days, 'past/future') expands the viewportSize in one direction", ->
  expect 4

  controller.send("resizeViewport", 2, "past")
  ok controller.get("viewportSize") is 16,                                                        "expand 2 days towards the past"
  ok controller.get("viewportStart").unix() is moment(viewportStart).subtract(2,"days").unix(),   "viewportStart goes back 2 days as well"

  controller.send("resizeViewport", 2, "future")
  ok controller.get("viewportSize") is 18,                                                        "expand 2 days towards the future"
  ok controller.get("viewportStart").unix() is moment(viewportStart).subtract(2,"days").unix(),   "viewportStart doesn't change"

test "#resizeViewport(days) expands the viewportSize in both directions", ->
  expect 2

  controller.send("resizeViewport", 4)
  ok controller.get("viewportSize") is 22, "expand in both directions"
  ok controller.get("viewportStart").unix() is moment(viewportStart).subtract(4,"days").unix()

test "#shiftViewport(days) changes the viewportStart", ->
  expect 4

  controller.send("shiftViewport", 3, "past")
  ok controller.get("viewportSize") is 14, "size stays the same"
  ok controller.get("viewportStart").unix() is moment(viewportStart).subtract(3,"days").unix()

  controller.send("shiftViewport", 5, "future")
  ok controller.get("viewportSize") is 14, "size stays the same"
  ok controller.get("viewportStart").unix() is moment(viewportStart).add(2,"days").unix()