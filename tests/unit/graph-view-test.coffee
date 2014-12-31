`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


`import graphFixture from "../fixtures/graph-fixture"`

App        = null
view       = null
controller = null
fixture    = null

moduleFor("view:graph", "Graph View",
  {
    needs: ["controller:graph"]
    setup: ->
      App         = startApp()
      controller  = App.__container__.lookup("controller:graph")
      view        = @subject()
      startDay    = moment().utc().startOf("day").subtract(5,"days")
      fixture     = graphFixture(startDay)

      view.reopen { renderGraph: -> } # don't need to actually run the graph
      controller.reopen { bufferWatcher: -> } # don't need to buffer

      Ember.run ->
        controller.set "model",           {}
        controller.set "rawData",         fixture
        controller.set "catalog",         "hbi"
        controller.set "viewportSize",    6
        controller.set "viewportMinSize", 6
        controller.set "viewportStart",   moment(startDay).subtract(1,"day")
        controller.set "firstEntryDate",  moment(startDay)
        controller.set "loadedStartDate", moment(startDay)
        controller.set "loadedEndDate",   moment().utc().startOf("day")

        view.set("controller", controller)

        # Some lovely round numbers for testing
        view.set("height", 1000)
        view.set("width", 1000)

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)

test "has #viewportDatums", ->
  expect 1

  ok view.get("datums.firstObject.order") is 1.1, "got an expected symptomDatum property"

test "setups up #y correctly with #unfilteredDatumsByDay", ->
  expect 1

  ok 1000-parseInt(view.get("y")(1)) is 63, "assuming max datums of 15, we should get back about 63px (from top) with a height of 1000px"

test "setups up #x correctly with #viewportDays", ->
  expect 1

  left_offset = view.get("symptomDatumDimensions.left_margin")*2
  ok view.get("x")(fixture.hbi[0].x) is left_offset, "oldest day should have the 0px x position + margin offset"

test "#symptomDatumMargins yields margins object", ->
  expect 6

  ok parseInt(view.get("symptomDatumDimensions.width")) < 100,        "less than 1/6th the width of 1000 (due to margins)"
  ok parseInt(view.get("symptomDatumDimensions.height")) < 66,        "less than 1/15th the height of 1000 (due to margins)"
  ok view.get("symptomDatumDimensions.left_margin") < 50,             "should be less than 25% of 200"
  ok view.get("symptomDatumDimensions.right_margin") < 50,            "should be less than 25% of 200"
  ok parseInt(view.get("symptomDatumDimensions.top_margin")) < 14,    "should be less than 20% of 66"
  ok parseInt(view.get("symptomDatumDimensions.bottom_margin")) < 14, "should be less than 20% of 66"

test "#setupEndPositions determines y positioning based on unfilteredDatums and order", ->
  expect 2

  ok 1000 - parseInt(view.get("datums.firstObject.end_y")) is 63, "first y pos is around 63"
  ok parseInt(view.get("datumsByDay")[2][14].get("end_y")) is 62, "highest datum (4th day from origin, datum 15) should be 62"
