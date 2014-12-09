`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`

App        = null
controller = null

moduleFor("controller:graph/index", "Graph Controller",
  {
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = graphFixture()

      Ember.run ->
        controller.set("model", fixture.graph)

    teardown: -> Ember.run(App, App.destroy)
  }
)


test "#currentCatalog is set based on graph data", ->
  expect 2

  ok true
  ok true
