`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import chartFixture from "../fixtures/chart-fixture"`


App = null
mocks = ->

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
    url: "#{config.apiNamespace}/chart",
    type: 'GET'
    # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
    responseText: chartFixture()

module('Chart Integration', {
  setup: ->

    App = startApp()
    mocks()

  teardown: -> Ember.run(App, App.destroy)
})

test "Recent Entries", ->
  expect 1

  visit('/').then(
    -> ok(find("circle.score").length == 3, "Has 3 entries")
  )

test "Interaction", =>
  expect 1

  Ember.$.mockjax
    url: "#{config.apiNamespace}/entries",
    type: 'POST'
    data:
      date: "Oct-24-2014"
    responseText: {
      entry: {
        id: "abc123",
        date: "2014-10-24"
      }
    }

  visit('/').then(
    ->
      stop()
      clickOn $("circle.hitbox")[0]

      setTimeout(
        ->
          assertModalPresent()
          start()
      , 200)
  )