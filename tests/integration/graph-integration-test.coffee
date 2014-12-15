`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`
`import entryFixture from "../fixtures/entry-fixture"`

App = null

module('Graph Integration', {
  setup: ->
    App = startApp()

    Ember.$.mockjax
      url: "#{config.apiNamespace}/current_user",
      type: 'GET'
      responseText: {
        current_user: {
          id: 1,
          email: "test@test.com"
        }
      }

    Ember.$.mockjax
      url: "#{config.apiNamespace}/graph",
      type: 'GET'
      # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
      responseText: graphFixture()

    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
      responseText: entryFixture()



  teardown: -> Ember.run(App, App.destroy)
})

test "Recent Entries", ->
  expect 1

  visit('/').then( ->
    ok(find("rect.score").length is 39, "Has 39 datums for HBI fixture")
  )

test "Interaction", =>
  expect 1

  visit('/').then(
    ->
      stop()
      clickOn $("rect.score")[0]

      setTimeout(
        ->
          assertModalPresent()
          start()
      , 100)
  )