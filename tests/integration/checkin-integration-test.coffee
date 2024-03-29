`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`
`import graphFixture from "../fixtures/graph-fixture"`
`import symptomSearchFixture from "../fixtures/symptom-search-fixture"`

App = null
yesterdayFormatted = moment().subtract(1, "days").format("MMM-DD-YYYY")
today = moment().format("MMM-DD-YYYY")
tomorrow = moment().add(1, "day").format("MMM-DD-YYYY")

module('Check-In Integration', {
  setup: ->
    Ember.$.mockjax url: "#{config.apiNamespace}/graph", responseText: graphFixture()

    # For "today" tests
    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      data:
        date: today
      responseText: entryFixture(today)

    # for tomorrow (time mock)
    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      data:
        date: tomorrow
      responseText: entryFixture(tomorrow)

    # For other dates
    entry = entryFixture(yesterdayFormatted)
    # just one condition for auto-progression test
    entry.entry.catalog_definitions.conditions = [entry.entry.catalog_definitions.conditions[0]]

    Ember.$.mockjax url: "#{config.apiNamespace}/entries", type: 'POST', responseText: entry
    Ember.$.mockjax url: "#{config.apiNamespace}/entries/*", type: 'PUT', responseText: {}
    Ember.$.mockjax url: "#{config.apiNamespace}/symptoms/search/*", responseText: symptomSearchFixture

    App = startApp()

    # 60 second refresh is a bit much for testing purposes
    App.__container__.lookup("route:graph.checkin").reopen
      checkTimeFrequency: 100

    # don't render graph for better test performance
    App.__container__.lookupFactory("view:graph").reopen
      renderGraph: ->

    null

  teardown: ->
    Ember.run(App, App.destroy)
    $.mockjax.clear()

})

test "Can see the checkin", ->
  expect 2

  visit("/checkin/#{yesterdayFormatted}/1").then( ->
    assertModalPresent()
    ok currentURL() == "/checkin/#{yesterdayFormatted}/1"
  )

test "Can see the checkin for 'today' ", ->
  expect 2


  visit('/checkin/today/1').then( ->
    assertModalPresent()
    ok currentURL() == "/checkin/today/1"
  )

test "Goes to today properly after time passes", ->
  expect 3

  visit("/checkin/today/2").then( ->
    tomorrow = parseInt(moment().add(1, "day").format("x"))
    timekeeper.travel(tomorrow)
    yesterdayDate = today

    stop()
    Ember.run.later ->
      start()
      equal $(".checkin-date").text(), "Yesterday", "checkin date changes"
      equal currentURL(), "/checkin/#{yesterdayDate}/2", "URL changes correctly on passing through to next day"

      triggerEvent(".checkin-date-container .tomorrow a", "click")
      andThen ->
        equal currentURL(), "/checkin/today/1", "Clicking next goes to the new 'today'"
        timekeeper.reset()
    , 200

  )

test "Can navigate through the sections (today)", ->
  expect 2

  visit('/checkin/today/1').then( =>
    triggerEvent(".checkin-next", "click")
    andThen ->
      equal currentURL(), "/checkin/today/2", "Clicking a next goes forward"
      triggerEvent(".checkin-back", "click")
      andThen ->
        equal currentURL(), "/checkin/today/1", "Clicking a prev goes back"
  )

test "Disable on prev/next on first/last", ->
  expect 2

  visit('/checkin/today/12').then( =>
    ok find(".checkin-next").length is 0, "No next button on last page"
  )

  visit('/checkin/today/1').then( =>
    ok find(".checkin-back").length is 0, "No next button on last page"
  )

test "Can navigate through the sections (other date)", ->
  expect 1

  visit("/checkin/#{yesterdayFormatted}/1").then( ->
    triggerEvent(".pagination-dots ul li:eq(1)", "click")
    ok currentURL() == "/checkin/#{yesterdayFormatted}/2", "Clicking a number goes to that section"
  )

test "go to a specific section via url", ->
  expect 2

  visit("/checkin/#{yesterdayFormatted}/2").then( ->
    ok currentURL() == "/checkin/#{yesterdayFormatted}/2"
    ok $(".pagination-dots ul li a.selected")[0] is $(".pagination-dots ul li a:eq(1)")[0]
  )

test "go to URL with unavailable section defaults to 1", ->
  expect 2

  visit("/checkin/#{yesterdayFormatted}/99").then( ->
    ok currentURL() == "/checkin/#{yesterdayFormatted}/1"
    ok $(".pagination-dots ul li a.selected")[0] is $(".pagination-dots ul li a:eq(0)")[0]
  )

test "go to the next section when submitting a response (with only 1 question)", ->
  expect 1

  visit("/checkin/#{yesterdayFormatted}/8").then( ->
    triggerEvent ".simple-checkin-response li:eq(1)", "click"
    andThen ->
      ok currentURL() == "/checkin/#{yesterdayFormatted}/9", "Went to the next section"
  )

test "escaping modal goes back to index", ->
  expect 2

  visit("/checkin/#{yesterdayFormatted}/1").then( ->
    ok currentURL() == "/checkin/#{yesterdayFormatted}/1"
    keyEvent($(".ember-modal-dialog"), "keyup", 27)
    triggerEvent $(".main"), "click"

    andThen ->
      ok currentURL() == "/", "Went back to index"
  )

test "Warned of treatment removal", ->
  expect 1

  visit("/checkin/today/10").then( ->
    triggerEvent $(".remove-trackable"), "click"

    andThen -> window.assertAlertPresent()
  )

# Completeness
test "Setting a response on a normal select marks that section as 'complete'", ->
  expect 2

  # Page 3, HBI general wellbeing, incomplete
  visit("/checkin/#{yesterdayFormatted}/3").then( ->
    ok !$(".pagination-dots a:eq(2)").hasClass("complete"), "isn't complete"
    triggerEvent ".checkin-response-select li:eq(0)", "click"
    ok $(".pagination-dots a:eq(2)").hasClass("complete"), "is complete"
  )

# TODO currently disabled because "symptoms" are not considered completable .. (?)
# See userQuestionSections in controllers/checkin
# test "Null values on symptom responses do not count as complete", ->
#   expect 2
#
#   # Page 9, symptoms section
#   visit("/checkin/#{yesterdayFormatted}/9").then( ->
#     triggerEvent ".simple-checkin-response:eq(0) li:eq(1)", "click"
#     triggerEvent ".simple-checkin-response:eq(1) li:eq(1)", "click"
#     ok Em.isEmpty(find(".pagination-dots a.symptoms.complete")), "2/3... not complete yet"
#
#     triggerEvent ".simple-checkin-response:eq(2) li:eq(1)", "click"
#     andThen ->
#       stop()
#       ok Em.isPresent(find(".pagination-dots a.symptoms.complete")), "All symptoms filled, now complete"
#   )

test "Symptoms select bar only highlights last selected digit", ->
  expect 3

  # Page 9, symptoms section
  visit("/checkin/#{yesterdayFormatted}/9").then( ->
    # Make sure they have selection
    triggerEvent ".simple-checkin-response:eq(0) li:eq(3)", "click"

    andThen ->
      ok $(".simple-checkin-response:eq(0)").hasClass("has-value")

      ok $(".simple-checkin-response:eq(0) li:eq(2)").hasClass("highlight")
      ok $(".simple-checkin-response:eq(0) li:eq(3)").hasClass("selected")
  )

# TRACKABLE search/addition
test "Can search for symptoms (any trackable)", ->
  expect 3

  # Page 9, symptoms section
  visit("/checkin/#{yesterdayFormatted}/9").then( ->

    andThen ->
      $("input.form-symptom-select").select2("search", "sli")

      Ember.run.later ->
        ok $(".select2-results li:eq(0) span").text() is "\"sli\"", "first result is search term + quotations"
        ok $(".select2-results li").length is 3, "sli, slippery tongue and sneezing"
        ok $(".select2-results li:eq(1)").hasClass("select2-disabled"), "slippery tongue exists so is disbaled for selection"
      , 500
  )

# !!! TODO Cannot find a way to programmatically select search result
# test "Can add new symptoms", ->

#   expect 2
#
#   # Page 9, symptoms section
#   visit('/checkin/#{yesterdayFormatted}/9').then( ->
#
#     andThen ->
#       $("input.form-symptom-search").select2("search", "sli")
#
#       Ember.run.later ->
#
#         ok $(".select2-results li").length is 3, "sli, slippery tongue and sneezing"
#         triggerEvent(".select2-results li:eq(2)", "keypress", {keyCode: 13}) # click on "sneezing"
#         # $(".select2-results li:eq(2)").simulate("click") # click on "sneezing"
#         stop()
#         ok $(".checkin-symptom:eq(3) h6").text() is "sneezing", "selected sneezing and it was added to symptoms"
#       , 500
#   )

# test "Can add new symptoms freeform", ->
#   expect 2
#
#   # Page 9, symptoms section
#   visit('/checkin/#{yesterdayFormatted}/9').then( ->
#
#     andThen ->
#       stop()
#       $("input.form-symptom-search").select2("search", "flibbertigibbet")
#
#       stop()
#       Ember.run.later ->
#         ok $(".select2-results li").length is 3, "sli, slippery tongue and sneezing"
#       , 500
#   )
