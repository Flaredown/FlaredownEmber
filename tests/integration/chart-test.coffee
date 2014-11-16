`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`
`import assetModalPresent from "../helpers/assert-modal-present"`

App = null

module('Chart Integration', {
  setup: -> App = startApp()
  teardown: -> Ember.run(App, App.destroy)
})

chartMocks = ->
  Ember.$.mockjax
    url: '/api/v1/current_user',
    type: 'GET'
    responseText: {
      current_user: {
        id: 1,
        email: "test@test.com"
      }
    }

  Ember.$.mockjax
    url: '/api/v1/chart',
    type: 'GET'
    # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
    responseText: {
      chart: [{
        name: "cdai",
        scores: [
          {x: 1414108800, y: 260},
          {x: 1414195200, y: 301},
          {x: 1414281600, y: 288}
        ],
        components: [ ]
      }]
    }

test "Recent Entries", ->
  expect 1
  chartMocks()

  visit('/').then(
    -> ok(find("circle.score").length == 3, "Has 3 entries")
  )

test "Interaction", =>
  expect 1
  chartMocks()

  Ember.$.mockjax
    url: '/api/v1/entries/Oct-23-2014',
    type: 'GET'
    # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
    responseText: {
      entry: {
        id: "abc123",
        date: "2014-10-23"
      }
    }

  visit('/').then(
    =>
      stop()
      $($("circle.hitbox")[0]).simulate("click")
      setTimeout(
        ->
          start()
          assetModalPresent()

      , 3000)
      # , 300)
      #
      # stop()
      #
      # setTimeout(
      #   ->
      #     Ember.run ->
      #       el = $($("circle.score")[0])
      #       offset = el.offset()
      #       event = jQuery.Event( "mousedown", {
      #         which: 1,
      #         pageX: offset.left,
      #         pageY: offset.top
      #       })
      #       el.trigger(event)
      #
      #       start
      #       # debugger
      #       ok(find(".modal").length, "open modal by clicking a circle")
      #       # start()
      #   , 2000
      # )

  )