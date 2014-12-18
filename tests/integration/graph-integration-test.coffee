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
      responseText: graphFixture(moment().utc().startOf("day").subtract(5,"days"))

    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
      responseText: entryFixture()

  teardown: -> Ember.run(App, App.destroy)
})

test "Datums show up", ->
  expect 1

  visit('/').then( ->
    ok find("rect.symptom.present").length is 39, "Has 39 datums for HBI fixture"
  )

test "Datums disappear when shifted out of viewport", ->
  expect 2

  visit('/').then( ->
    ok find("rect.symptom.present").length is 39, "Has 39 datums for HBI fixture"

    triggerEvent ".shift-viewport-1-past", "click"
    stop()

    setTimeout(
      ->
        ok find("rect.symptom.present").length is 32, "Has 32 datums when contracted 1 day"
        start()
    , 1000)

  )

test "Modal by clicking datum", =>
  expect 1

  visit('/').then(
    ->
      stop()
      $("rect.symptom.present:eq(0)").simulate("click")

      setTimeout(
        ->
          assertModalPresent()
          start()
      , 100)
  )

