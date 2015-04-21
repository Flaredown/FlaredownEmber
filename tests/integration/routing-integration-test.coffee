`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`
`import graphFixture from "../fixtures/graph-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`
`import userFixture from "../fixtures/user-fixture"`

App = null

module('Base Routing Integration', {
  setup: ->
    Ember.$.mockjax url: "#{config.apiNamespace}/current_user", responseText: userFixture
    Ember.$.mockjax url: "#{config.apiNamespace}/locales/en", responseText: localeFixture
    Ember.$.mockjax url: "#{config.apiNamespace}/graph", type: 'GET', responseText: graphFixture(moment().utc().startOf("day").subtract(5,"days"))
    today = moment().utc().format("MMM-DD-YYYY")
    Ember.$.mockjax url: "#{config.apiNamespace}/entries", type: 'POST', data: {date: today}, responseText: entryFixture(today)

    App = startApp(); null

  teardown: -> Ember.run(App, App.destroy); $.mockjax.clear()
})

test "Logged in on 'unauthedOnly' page goes to default route", ->
  expect 1
  visit('/login').then( -> ok currentURL() == "/" )

# test "Bad checkin params produces 500", ->
#   expect 1
#   visit('/checkin/!@$%^/1').then( -> ok currentURL() == "/something-went-wrong" )

module('Base Routing Integration', {
  setup: ->
    userFixture.current_user.settings.graphable = "false"
    Ember.$.mockjax url: "#{config.apiNamespace}/current_user", responseText: userFixture
    Ember.$.mockjax url: "#{config.apiNamespace}/locales/en", responseText: localeFixture
    today = moment().utc().format("MMM-DD-YYYY")
    Ember.$.mockjax url: "#{config.apiNamespace}/entries", type: 'POST', data: {date: today}, responseText: entryFixture(today)

    App = startApp(); null

  teardown: -> Ember.run(App, App.destroy); $.mockjax.clear()
})

test "No graph user gets redirected to checkin", ->
  expect 1
  visit('/').then( -> ok currentURL() == "/checkin/today/1" )

test "No graph user gets redirected to checkin, unless already going there", ->
  expect 1
  visit('/checkin/today/2').then( -> ok currentURL() == "/checkin/today/2" )

module('Base Routing Integration', {
  setup: ->
    userFixture.current_user.settings.onboarded = "false"
    Ember.$.mockjax url: "#{config.apiNamespace}/current_user", responseText: userFixture
    Ember.$.mockjax url: "#{config.apiNamespace}/locales/en", responseText: localeFixture
    today = moment().utc().format("MMM-DD-YYYY")
    Ember.$.mockjax url: "#{config.apiNamespace}/entries", type: 'POST', data: {date: today}, responseText: entryFixture(today)

    App = startApp(); null

  teardown: -> Ember.run(App, App.destroy); $.mockjax.clear()
})

test "Non-onboarded user gets redirected to onboarding", ->
  expect 2
  visit('/checkin/today/1').then( ->
    ok currentURL() == "/onboarding/account"
    visit('/onboarding/research-questions').then( -> ok currentURL() == "/onboarding/research-questions" )
  )

# test "Unauthed pages while logged in gets 404", ->
#   expect 1
#   visit('/reset-your-password').then( -> console.log currentURL(); ok currentURL() == "/page-not-found" )

module('Base Routing Integration', {
  setup: ->
    Ember.$.mockjax url: "#{config.apiNamespace}/locales/en", responseText: localeFixture

    App = startApp(); null

  teardown: -> Ember.run(App, App.destroy); $.mockjax.clear()

})

test "Not logged in on authedOnly goes to login page", ->
  expect 1
  visit('/checkin/Aug-13-2014/1').then( -> ok currentURL() == "/login")

test "Funky URL produces 404", ->
  expect 1
  visit('/funkypants').then( -> ok currentURL() == "/page-not-found")