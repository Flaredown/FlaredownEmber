`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


`import entryFixture from "../fixtures/entry-fixture"`
`import graphFixture from "../fixtures/graph-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`

App = null

module('Check-In Integration', {
  setup: ->
    Ember.$.mockjax
      url: "#{config.apiNamespace}/current_user",
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
      url: "#{config.apiNamespace}/graph",
      responseText: graphFixture()


    # For "today" tests
    today = moment().utc().format("MMM-DD-YYYY")
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

    App = startApp()

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
    # foo (1) | hbi (2-6)
    # prev 1 2 3 4 5 6 next
    triggerEvent(".pagination ul li a:eq(2)", "click")
    ok currentURL() == "/checkin/today/2", "Clicking a number goes to that section"

    triggerEvent(".pagination ul li a:eq(7)", "click")
    andThen ->
      ok currentURL() == "/checkin/today/3", "Clicking a next goes forward"

    triggerEvent(".pagination ul li a:eq(0)", "click")
    ok currentURL() == "/checkin/today/2", "Clicking a prev goes back"
  )

test "Limits on prev/next", ->
  expect 2

  visit('/checkin/today/6').then( =>
    triggerEvent(".pagination ul li a:eq(7)", "click")
    ok currentURL() == "/checkin/today/6", "Next button limited"
  )

  visit('/checkin/today/1').then( =>
    triggerEvent(".pagination ul li a:eq(0)", "click")
    ok currentURL() == "/checkin/today/1", "Previous button limited"
  )

test "Can navigate through the sections (other date)", ->
  expect 1

  visit('/checkin/Aug-13-2014/1').then( ->
    triggerEvent(".pagination ul li a:eq(2)", "click")
    ok currentURL() == "/checkin/Aug-13-2014/2", "Clicking a number goes to that section"
  )

test "go to a specific section via url", ->
  expect 2

  visit('/checkin/Aug-13-2014/2').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/2"
    ok $(".pagination ul li a.selected").text() is "2"
  )

test "go to URL with unavailable section defaults to 1", ->
  expect 2

  visit('/checkin/Aug-13-2014/99').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/1"
    ok $(".pagination ul li a.selected").text() is "1"
  )

test "go to the next section when submitting a response", ->
  expect 2

  visit('/checkin/Aug-13-2014/1').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/1"
    triggerEvent ".response-select a:eq(0)", "click"
    ok currentURL() == "/checkin/Aug-13-2014/2", "Went to the next section"
  )

test "closing modal goes back to index", ->
  visit('/checkin/Aug-13-2014/1').then( ->
    ok currentURL() == "/checkin/Aug-13-2014/1"
    triggerEvent $("#modal-1"), "click"

    andThen ->
      ok currentURL() == "/", "Went back to index"


  )