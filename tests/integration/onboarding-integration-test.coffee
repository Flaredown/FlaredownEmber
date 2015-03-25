`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


App = null

module('Onboarding Integration Tests', {
  setup: ->
    App = startApp()
    null
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
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

## ONBOARDING FLOW ##
# "account"     -> "/account"
# "research"    -> "/research-questions"
# "conditions"  -> "/conditions"
# "catalogs"    -> "/condition-questions"
# "symptoms"    -> "/symptoms"
# "treatments"  -> "/treatments"
# "complete"    -> "/complete"

test "Existence of onboarding pages", ->
  expect 14

  visit('/onboarding/account').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.account", "Route OK")
  )

  visit('/onboarding/research-questions').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.research", "Route OK")
  )

  visit('/onboarding/conditions').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.conditions", "Route OK")
  )

  visit('/onboarding/condition-questions').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.catalogs", "Route OK")
  )

  visit('/onboarding/symptoms').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.symptoms", "Route OK")
  )

  visit('/onboarding/treatments').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.treatments", "Route OK")
  )

  visit('/onboarding/complete').then(
    ->
      ok(find(".navbar").length, "Page shows up")
      ok(currentRouteName() == "onboarding.complete", "Route OK")
  )
