`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import localeFixture from "../fixtures/locale-fixture"`
`import userFixture from "../fixtures/user-fixture"`

App = null

module('Onboarding Integration Tests', {
  setup: ->
    Ember.$.mockjax
      url: "#{config.apiNamespace}/current_user",
      responseText: userFixture

    Ember.$.mockjax
      url: "#{config.apiNamespace}/locales/en",
      responseText: localeFixture

    App = startApp()
    null
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

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
