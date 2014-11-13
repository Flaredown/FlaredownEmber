`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App = null

module('An Integration test', {
  setup: -> App = startApp()
  teardown: -> Ember.run(App, App.destroy)
})

test "Sanity Test", ->
  expect(1)
  visit('/').then(
    -> ok(find(".navbar").length, "Page shows up")
  )