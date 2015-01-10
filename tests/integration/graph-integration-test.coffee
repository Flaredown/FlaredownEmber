`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


`import graphFixture from "../fixtures/graph-fixture"`
`import singleGraphDayFixture from "../fixtures/single-graph-day-fixture"`
`import entryFixture from "../fixtures/entry-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`

App   = null
today = moment().utc().startOf("day").format("MMM-DD-YYYY")

module('Graph Integration', {
  setup: ->
    Ember.$.mockjax
      url: "#{config.apiNamespace}/current_user",
      type: 'GET'
      responseText: {
        current_user: {
          id: 1,
          email: "test@test.com",
          locale: "en"
        }
      }

    Ember.$.mockjax
      url: "#{config.apiNamespace}/locales/en",
      responseText: localeFixture

    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries/*",
      type: 'PUT'
      responseText: {}

    Ember.$.mockjax
      url: "#{config.apiNamespace}/graph",
      type: 'GET'
      # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
      responseText: graphFixture(moment().utc().startOf("day").subtract(5,"days"))

    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
      responseText: entryFixture(today)

    App = startApp()
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

test "Datums show up", ->
  expect 1

  visit('/').then( ->
    ok find("rect.symptom.present").length is 39, "Has 39 datums for HBI fixture"
  )

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
        ok find("rect.symptom.present").length is 39, "Back to 39"
  )

test "Updating entry goes to loading state and updates entry on graph", ->
  expect 3

  controller = App.__container__.lookup("controller:graph")

  visit('/').then( ->

    ok find("rect.symptom.present").length is 39, "Has 39 datums for HBI fixture"
    $("rect.symptom.present:eq(0)").simulate("click") # should be first day (today)
    andThen ->

      Ember.run.later(
        (->
          triggerEvent ".checkin-next", "click"

          andThen ->
            triggerEvent ".checkin-response-select li:eq(0)", "click"
            triggerEvent ".modal-close", "click"

            andThen ->
              ok find("rect.symptom.processing").length is 3, "Has loading datums"
              $.mockjax.clear();
              # Use the single day graph response when loading new "processed" day at the end of test
              Ember.$.mockjax
                url: "#{config.apiNamespace}/graph",
                type: 'GET'
                # data: { start_date: "Oct-24-2014", end_date: "Nov-13-2014" }
                responseText: singleGraphDayFixture()


              Ember.run.next ->
                controller.send("dayProcessed", today)
                Ember.run.later (-> ok find("rect.symptom.present").length is 39-2, "Has 39 (original) - 2 (new day difference) datums for HBI fixture"), 200
        )
        , 200
      )

  )