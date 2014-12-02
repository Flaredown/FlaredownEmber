`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App = null

module('Check-in Form Integration', {
  setup: -> App = startApp()
  teardown: -> Ember.run(App, App.destroy)
})

# test "Can switch sections", ->
#   expect 1
#
#   ok(@subject())
#
# test "Going back keeps old values", ->
#   expect 1
#
#   ok(@subject())
#
# test "Can jump to arbitrary section via section number link", ->
#   expect 1
#
#   ok(@subject())