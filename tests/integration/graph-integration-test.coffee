`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`
`import singleGraphDayFixture from "../fixtures/single-graph-day-fixture"`
`import entryFixture from "../fixtures/entry-fixture"`

App   = null
today = moment().utc().startOf("day").format("MMM-DD-YYYY")
controller = null

module('Graph Integration', {
  needs: ["controller:graph"]

  setup: ->

    Ember.$.mockjax url: "#{config.apiNamespace}/entries/*", type: 'PUT', responseText: {}

    Ember.$.mockjax url: "#{config.apiNamespace}/graph", type: 'GET', responseText: graphFixture(moment().utc().startOf("day").subtract(5,"days"))
    Ember.$.mockjax url: "#{config.apiNamespace}/entries", type: 'POST', responseText: entryFixture(today)

    App = startApp()

    controller = App.__container__.lookup("controller:graph")
    Ember.run -> controller.set("serverProcessingDays", []) # HACK! Reset from other tests affecting it

    null

  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

# test "Datums show up", ->
#   expect 1
#
#   visit('/').then( ->
#     ok find("rect.symptom.present").length is 39, "Has 39 datums for HBI fixture"
#   )

# test "Datums disappear when shifted out of viewport", ->
#   expect 2
#
#   visit('/').then( ->
#     ok find("rect.symptom.present").length is 39, "Has 39 datums for HBI fixture"
#
#     triggerEvent ".shift-viewport-1-past", "click"
#     stop()
#
#     setTimeout(
#       ->
#         in_bounds = Ember.A(find("rect.symptom.present")).filter (d) -> parseInt($(@).attr("x")) < $("svg").width()
#         ok in_bounds.length is 32, "Has 32 datums when contracted 1 day"
#         start()
#     , 1000)
#
#   )

# test "Modal by clicking datum", =>
#   expect 1
#
#   visit('/').then(
#     ->
#       stop()
#       $("rect.symptom.present:eq(0)").simulate("click")
#
#       setTimeout(
#         ->
#           assertModalPresent()
#           start()
#       , 100)
#   )

test "Switching catalogs removes old and brings in new datums", ->
  expect 1

  visit('/').then( ->
    triggerEvent ".available-catalog:eq(1)", "click"
    andThen ->
      ok find("rect.symptom.present").length is 18, "Has 18 datums for symptoms fixture"
  )

test "Filtering removes matching datums", ->
  expect 2

  visit('/').then( ->
    triggerEvent ".filterable-symptom:eq(0)", "click"
    andThen ->
      ok find("rect.symptom.present").length < 39, "Has less than 39 datums for HBI fixture"
      triggerEvent ".filtered-symptom:eq(0)", "click"

      andThen ->
        equal find("rect.symptom.present").length, 39, "Back to 39"
  )

test "Updating entry goes to loading state and updates entry on graph", ->
  expect 3

  visit('/').then ->

    controller.send("dayProcessing", today) # simulate update/closing modal

    stop()
    Ember.run.later(
      ->
        start()

        equal find("rect.symptom.processing").length, 3, "Has symptom loading datums"
        equal find("rect.treatment.processing").length, 1, "Has treatment loading datum"

        andThen ->
          $.mockjax.clear();

          # Use the single day graph response when loading new "processed" day at the end of test
          Ember.$.mockjax
            url: "#{config.apiNamespace}/graph",
            type: 'GET'
            responseText: singleGraphDayFixture()

            Ember.run.next ->
              controller.send("dayProcessed", today)
              Ember.run.later (-> ok find("rect.symptom.present").length is 39-2, "Has 39 (original) - 2 (new day difference) datums for HBI fixture"), 500

      ,300
    )

