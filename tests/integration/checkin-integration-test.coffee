`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`
`import graphFixture from "../fixtures/graph-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`
`import userFixture from "../fixtures/user-fixture"`
`import symptomSearchFixture from "../fixtures/symptom-search-fixture"`

App = null

module('Check-In Integration', {
  setup: ->
    Ember.$.mockjax
      url: "#{config.apiNamespace}/current_user",
      responseText: userFixture

    Ember.$.mockjax
      url: "#{config.apiNamespace}/locales/en",
      responseText: localeFixture

    Ember.$.mockjax
      url: "#{config.apiNamespace}/graph",
      responseText: graphFixture()

    # For "today" tests
    today = moment().format("MMM-DD-YYYY")
    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      data:
        date: today
      responseText: entryFixture(today)

    # For other dates
    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      # data:
      #   date: "Aug-13-2014"
      responseText: entryFixture("Aug-13-2014")

    Ember.$.mockjax
      url: "#{config.apiNamespace}/symptoms/search/*",
      responseText: symptomSearchFixture

    App = startApp()
    null

  teardown: ->
    Ember.run(App, App.destroy)
    $.mockjax.clear()

})

test "Can see the checkin", ->
  expect 2

  visit('/checkin/Aug-13-2014/1').then( ->
    assertModalPresent()
    ok currentURL() == "/checkin/Aug-13-2014/1"
  )

test "Can see the checkin for 'today' ", ->
  expect 2


  visit('/checkin/today/1').then( ->
    assertModalPresent()
    ok currentURL() == "/checkin/today/1"
  )

test "Can navigate through the sections (today)", ->
  expect 3

  visit('/checkin/today/1').then( =>
    triggerEvent(".pagination-dots ul li:eq(1)", "click")
    ok currentURL() == "/checkin/today/2", "Clicking a number goes to that section"

    triggerEvent(".checkin-next", "click")
    andThen ->
      ok currentURL() == "/checkin/today/3", "Clicking a next goes forward"

    triggerEvent(".checkin-back", "click")
    ok currentURL() == "/checkin/today/2", "Clicking a prev goes back"
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

  visit('/checkin/Aug-13-2014/1').then( ->
    triggerEvent(".pagination-dots ul li:eq(1)", "click")
    ok currentURL() == "/checkin/Aug-13-2014/2", "Clicking a number goes to that section"
  )

test "go to a specific section via url", ->
  expect 2

  visit('/checkin/Aug-13-2014/2').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/2"
    ok $(".pagination-dots ul li a.selected")[0] is $(".pagination-dots ul li a:eq(1)")[0]
  )

test "go to URL with unavailable section defaults to 1", ->
  expect 2

  visit('/checkin/Aug-13-2014/99').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/1"
    ok $(".pagination-dots ul li a.selected")[0] is $(".pagination-dots ul li a:eq(0)")[0]
  )

test "go to the next section when submitting a response", ->
  expect 2

  visit('/checkin/Aug-13-2014/2').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/2"
    triggerEvent ".checkin-response-select li:eq(0)", "click"
    ok currentURL() == "/checkin/Aug-13-2014/3", "Went to the next section"
  )

test "closing modal goes back to index", ->
  expect 2

  visit('/checkin/Aug-13-2014/1').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/1"
    triggerEvent $("#modal-1"), "click"

    andThen ->
      ok currentURL() == "/", "Went back to index"
  )

# test "Can edit treatment", ->
#   expect 2
#
#   visit('/checkin/Aug-13-2014/10').then( ->
#     triggerEvent ".inactive-treatments .checkin-treatment-name:eq(0)", "click"
#     # triggerEvent $(".checkin-treatment-edit:eq(0)"), "click"
#
#     andThen ->
#       ok find(".treatment-name-input")
#       ok find(".checkin-treatment-dose-inputs .form-quantity-input")
#       # fillIn(".treatment-quantity-input", "200")
#       # triggerEvent ".save-treatment", "click"
#       # andThen ->
#       #   ok $(".checkin-treatment-quantity:eq(0)").text() is "200"
#   )

test "Warned of treatment removal", ->
  expect 1

  visit('/checkin/Aug-13-2014/10?edit=treatments').then( ->
    triggerEvent $(".checkin-treatment-remove:eq(0)"), "click"

    andThen -> window.assertAlertPresent()
  )

# Completeness
test "Setting a response on a normal select marks that section as 'complete'", ->
  expect 1

  # Page 3, HBI general wellbeing, incomplete
  visit('/checkin/Aug-13-2014/3').then( ->
    current_complete_count = $(".pagination-dots a.complete").length
    triggerEvent ".checkin-response-select li:eq(0)", "click"
    ok current_complete_count is $(".pagination-dots a.complete").length - 1
  )

test "Null values on symptom responses do not count as complete", ->
  expect 2

  # Page 9, symptoms section
  visit('/checkin/Aug-13-2014/9').then( ->
    triggerEvent ".simple-checkin-response:eq(0) li:eq(1)", "click"
    triggerEvent ".simple-checkin-response:eq(1) li:eq(1)", "click"
    ok Em.isEmpty(find(".pagination-dots a.symptoms.complete")), "2/3... not complete yet"

    triggerEvent ".simple-checkin-response:eq(2) li:eq(1)", "click"
    andThen ->
      ok Em.isPresent(find(".pagination-dots a.symptoms.complete")), "All symptoms filled, now complete"
  )

# Colors
test "Treatments get uniq colors", ->
  expect 2

  # Page 10, treatments section
  visit('/checkin/Aug-13-2014/10').then( ->
    color_class = $(".checkin-treatment-name:eq(0)").attr("class").match(/(tbg-\d+)/)[0]
    ok color_class, "Has a color class"

    ok color_class isnt $(".checkin-treatment-name:eq(1)").attr("class").match(/(tbg-\d+)/)[0], "Color class is different from other treatment"
  )

test "Symptoms get uniq colors", ->
  expect 2

  # Page 9, symptoms section
  visit('/checkin/Aug-13-2014/9').then( ->
    # Make sure they have selection
    triggerEvent ".simple-checkin-response:eq(0) li:eq(1)", "click"
    triggerEvent ".simple-checkin-response:eq(1) li:eq(1)", "click"

    andThen ->
      color_class = $(".simple-checkin-response:eq(0) li:eq(0)").attr("class").match(/(sbg-\d+)/)[1]
      ok color_class, "Has a color class"

      ok color_class isnt $(".simple-checkin-response:eq(1) li:eq(0)").attr("class").match(/(sbg-\d+)/)[1], "Color class is different from other symptom"
  )

test "Symptoms select bar only highlights last selected digit", ->
  expect 3

  # Page 9, symptoms section
  visit('/checkin/Aug-13-2014/9').then( ->
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
  visit('/checkin/Aug-13-2014/9').then( ->

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
#   visit('/checkin/Aug-13-2014/9').then( ->
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
#   visit('/checkin/Aug-13-2014/9').then( ->
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
