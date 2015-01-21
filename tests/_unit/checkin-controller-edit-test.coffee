`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`

App        = null
controller = null
fixture    = null

moduleFor("controller:graph/checkin", "Check-In Edit Controller",
  {
    needs: ["controller:graph"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = entryFixture()

      controller.reopen { transitionToRoute: -> }                          # stub stupid observer throwing null error on transitionToRoute. Works fine in integration.

      Ember.run ->
        store.pushPayload "entry", fixture
        controller.set('model', store.find('entry', fixture.entry.id))

      controller.set("section", 1)                                      # Default to the first section, normally set by route

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)


# test "Catalog definitions are loaded up correctly", ->
#   expect 2
#
#   ok controller.get("catalogs.length") is 2
#   ok Object.keys(controller.get("catalog_definitions"))[0] is "hbi"
#
