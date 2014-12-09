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

      Ember.run ->
        controller.set("model", {})
        controller.set("rawData", fixture)
        controller.set("catalog", "hbi")

        view.set("controller", controller)

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "has #datums", ->
  expect 1

  ok view.get("datums.firstObject.order") is 1.1, "got an expected GraphDatum property"

test "setups up #y correctly with #visibleDatumsByDay", ->
  expect 1

  view.set("height", 1000)
  ok parseInt(view.get("y")(1)) is 66, "assuming max datums of 15, we should get back about 66px with a height of 1000px"

test "setups up #x correctly with #days", ->
  expect 2

  view.set("width", 1000)
  ok view.get("x")(fixture.hbi[24].x) is 0, "oldest day should have the 0px x position"
  ok view.get("x")(fixture.hbi[19].x) is 200, "second oldest day should be at about 200px, assuming 6 days and 1000px width"