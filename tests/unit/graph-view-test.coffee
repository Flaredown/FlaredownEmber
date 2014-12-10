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

moduleFor("view:graph/index", "Graph View",
  {
    needs: ["controller:graph/index"]
    setup: ->
      App         = startApp()
      controller  = App.__container__.lookup("controller:graph/index")
      view        = @subject()
      fixture     = graphFixture()

      view.reopen { renderGraph: -> } # don't need to actually run the graph

      Ember.run ->
        controller.set("model", {})
        controller.set("rawData", fixture)
        controller.set("catalog", "hbi")

        view.set("controller", controller)

        # Some lovely round numbers for testing
        view.set("height", 1000)
        view.set("width", 1000)

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "has #datums", ->
  expect 1

  ok view.get("datums.firstObject.order") is 1.1,   "got an expected symptomDatum property"

test "setups up #y correctly with #visibleDatumsByDay", ->
  expect 1

  ok 1000-parseInt(view.get("y")(1)) is 63,          "assuming max datums of 15, we should get back about 63px (from top) with a height of 1000px"

test "setups up #x correctly with #days", ->
  expect 2

  ok view.get("x")(fixture.hbi[24].x) is 0,         "oldest day should have the 0px x position"
  ok view.get("x")(fixture.hbi[19].x) is 200,       "second oldest day should be at about 200px, assuming 6 days and 1000px width"

test "#symptomDatumMargins yields margins object", ->
  expect 4

  ok view.get("symptomDatumMargins.left") is 50,              "should be 25% of 200px"
  ok view.get("symptomDatumMargins.right") is 50,             "should be 25% of 200px"
  ok parseInt(view.get("symptomDatumMargins.top")) is 3,      "should be ~5% of 66px"
  ok parseInt(view.get("symptomDatumMargins.bottom")) is 3,   "should be ~5% of 66px"

test "#setupEndPositions determines y positioning based on visibleDatums and order", ->
  expect 2

  ok 1000 - parseInt(view.get("visibleDatums.firstObject.end_y")) is 63,            "first y pos is around 63"
  ok parseInt(view.get("visibleDatumsByDay")[3][14].get("end_y")) is 62,            "highest datum (4th day from origin, datum 15) should be 62"
