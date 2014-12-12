`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`

App         = null
route       = null
controller  = null
fixture     = null

moduleFor("route:graph/index", "Graph Route",
  {
    needs: ["controller:current-user", "model:user"]
    setup: ->
      App         = startApp()
      route       = @subject()
      store       = App.__container__.lookup("store:main")
      controller  = App.__container__.lookup("controller:graph/index")
      fixture     = graphFixture()

      Ember.run ->
        route.set("currentUser", store.createRecord("user", {id: 1,email: "test@test.com"}))

      Ember.$.mockjax
        url: "#{config.apiNamespace}/graph"
        type: 'GET'
        responseText: fixture

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "sets rawData, firstEntryDate and catalog", ->
  expect 1

  route.setupController(controller,fixture)
  deepEqual Object.keys(controller.get("model")).sort(), ["rawData", "firstEntryDate", "catalog"].sort()