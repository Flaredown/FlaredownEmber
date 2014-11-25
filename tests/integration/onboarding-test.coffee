`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`
`import assertAlertPresent from "../helpers/assert-alert-present"`

App = null

module('Onboarding Integration Tests', {
  setup: -> App = startApp()
  teardown: -> Ember.run(App, App.destroy)
})

test "Shows invitee registration page using invite token", ->
  expect 2

  Ember.$.mockjax
    url: "#{config.apiNamespace}/users/invitee/abc123",
    type: 'GET'
    responseText: {
      id: 1,
      email: "test@test.com",
      invitation_token: "abc123"
    }

  visit('/accept-invitation/abc123').then(
    ->
      ok(find("#accept-invitation-button").length, "Accept Invite button shows up (opposed to register button)")
      ok(find(".form-email").val(), "test@test.com")
  )

test "Invalid invite token gets 404 message", ->
  expect 3

  Ember.$.mockjax
    url: "#{config.apiNamespace}/users/invitee/abc123-invalid-invite-token",
    type: 'GET'
    status: 404
    responseText: {
      error: "Not found."
    }

  visit('/accept-invitation/abc123-invalid-invite-token').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "login", "Rediected to login")
      assertAlertPresent()
  )

test "Existence of onboarding pages", ->
  expect 8
  visit('/onboarding/catalogs').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.catalogs", "Route OK")
  )

  visit('/onboarding/checkin-finished').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.checkin-finished", "Route OK")
  )

  visit('/onboarding/conditions').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.conditions", "Route OK")
  )

  visit('/onboarding/symptoms').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.symptoms", "Route OK")
  )
