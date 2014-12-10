`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App        = null
view       = null
# parent     = null
controller = null
fixture    = null

moduleFor("controller:graph/symptom-datum", "Graph Symptom Datum",
  {
    setup: ->
      App         = startApp()
      # parent      = App.__container__.lookup("controller:graph/index")
      controller  = @subject()
      fixture     = {
        day:      1417787005
        catalog:  "hbi"
        order:    1.1
        name:     "ab_pain"
        type:     "symptom"
      }

      Ember.run ->
        controller.set("content", fixture)

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "is ok", ->
  expect 2

  ok controller.get("order") is 1.1
  ok controller.get("type") is "symptom"