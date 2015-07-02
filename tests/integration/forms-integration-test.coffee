`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import userFixture from "../fixtures/user-fixture"`

App = null

module('Forms Integration Tests', {
  setup: ->
    user = userFixture()
    user.current_user.settings.onboarded = "false"
    $.mockjax.clear()
    $.mockjax url: "#{config.apiNamespace}/current_user", responseText: user

    App = startApp()

    # don't render graph for better test performance
    App.__container__.lookupFactory("view:graph").reopen
      renderGraph: ->

    null
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

# test "Defaults are populated", ->
#
test "Text field required", ->
  expect 3

  visit('/onboarding/account').then(
    ->
      triggerEvent(".continue-button", "click")
      ok $(".form-dob-day .errors .error-message").length is 1
      ok $(".form-dob-day .errors .error-message").text().match(/required/i)

      fillIn(".form-dob-day-input", "13")
      andThen ->
        ok $(".form-dob-day .errors .error-message").length is 0
  )

test "Text field invalid", ->

  expect 2

  visit('/onboarding/account').then(
    ->
      fillIn(".form-dob-day-input", "133")
      triggerEvent(".continue-button", "click")
      andThen ->
        ok $(".form-dob-day .errors .error-message").length is 1
        ok $(".form-dob-day .errors .error-message").text().match(/valid/i)
  )

test "Radio input required", ->
  expect 2

  visit('/onboarding/account').then(
    ->
      triggerEvent(".continue-button", "click")
      andThen ->
        equal $(".form-sex .errors .error-message").length, 1
        ok $(".form-sex .errors .error-message").text().match(/required/i)

  )