`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`
`import graphFixture from "../fixtures/graph-fixture"`
`import symptomSearchFixture from "../fixtures/symptom-search-fixture"`

App = null
yesterdayFormatted = moment().subtract(1, "days").format("MMM-DD-YYYY")

module('Colors Integration', {
  setup: ->

    Ember.$.mockjax url: "#{config.apiNamespace}/graph", responseText: graphFixture()
    Ember.$.mockjax url: "#{config.apiNamespace}/entries", type: 'POST', responseText: entryFixture(yesterdayFormatted)
    Ember.$.mockjax url: "#{config.apiNamespace}/entries/*", type: 'PUT', responseText: {}

    App = startApp()

    # don't render graph for better test performance
    App.__container__.lookupFactory("view:graph").reopen
      renderGraph: ->

    null

  teardown: ->
    Ember.run(App, App.destroy)
    $.mockjax.clear()

})

test "Treatments get uniq colors", ->
  expect 2

  # Page 10, treatments section
  visit("/checkin/#{yesterdayFormatted}/10").then( ->
    color_class = $(".checkin-treatment:eq(0) .checkin-treatment-dose-add").attr("class").match(/(colorable-\w{1,6}-\d+)/)[0]
    ok color_class, "Has a color class"

    ok color_class isnt $(".checkin-treatment:eq(1) .checkin-treatment-dose-add").attr("class").match(/(colorable-\w{1,6}-\d+)/)[0], "Color class is different from other treatment"
  )

test "Conditions get uniq colors", ->
  expect 2

  # Page 10, treatments section
  visit("/checkin/#{yesterdayFormatted}/8").then( ->
    color_class = $(".simple-checkin-response:eq(0) li").attr("class").match(/(colorable-\w{1,6}-\d+)/)[0]
    ok color_class, "Has a color class"

    ok color_class isnt $(".simple-checkin-response:eq(1) li").attr("class").match(/(colorable-\w{1,6}-\d+)/)[0], "Color class is different from other conditions"
  )

test "Symptoms get uniq colors", ->
  expect 2

  # Page 9, symptoms section
  visit("/checkin/#{yesterdayFormatted}/9").then( ->
    # Make sure they have selection
    triggerEvent ".simple-checkin-response:eq(0) li:eq(1)", "click"
    triggerEvent ".simple-checkin-response:eq(1) li:eq(1)", "click"

    andThen ->
      color_class = $(".simple-checkin-response:eq(0) li:eq(0)").attr("class").match(/(colorable-\w{1,6}-\d+)/)[1]
      ok color_class, "Has a color class"

      ok color_class isnt $(".simple-checkin-response:eq(1) li:eq(0)").attr("class").match(/(colorable-\w{1,6}-\d+)/)[1], "Color class is different from other symptom"
  )