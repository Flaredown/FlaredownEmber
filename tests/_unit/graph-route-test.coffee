`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


`import graphFixture from "../fixtures/graph-fixture"`
`import userFixture from "../fixtures/user-fixture"`

App         = null
route       = null
controller  = null
fixture     = null

moduleFor("route:graph", "Graph Route",
  {
    needs: ["controller:current-user", "model:user"]
    setup: ->
      App         = startApp()
      route       = @subject()
      store       = App.__container__.lookup("store:main")
      controller  = App.__container__.lookup("controller:graph")
      fixture     = graphFixture()

      Ember.run ->
        current_user = App.__container__.lookup("controller:current_user")
        current_user.set "model", store.createRecord("user", userFixture().current_user)
        route.set("currentUser", current_user)

      Ember.$.mockjax
        url: "#{config.apiNamespace}/graph"
        type: 'GET'
        responseText: fixture

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)

test "sets rawData, firstEntryDate, loadedStartDate, loadedEndDate, viewportStart and catalog", ->
  expect 1

  route.setupController(controller,fixture)
  deepEqual Object.keys(controller.get("model")).sort(), ["rawData", "firstEntryDate", "catalog", "viewportStart", "loadedStartDate", "loadedEndDate"].sort()
