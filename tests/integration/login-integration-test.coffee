`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import userFixture from "../fixtures/user-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`

inline_response = {
  'errors' : {
    'error_group' : 'inline',
    'fields' : {
      'email' : [
        {
          'type' : 'empty',
          'message' : 'Email Cannot be Empty'
        }
      ],
      'password' : [
        {
          'type' : 'empty',
          'message' : 'Password Cannot be Empty'
        }
      ]
    }
  }
}

general_error_response = {
  'errors' : {
    'kind' : 'general',
    'title' : "Sorry, Your account isn't verified yet",
    'message' : "Check back later when your account will be verified by our admin",
    'type' : "error"
  }
}


App = null

module('Login Integration', {
  setup: ->
    App = startApp()
    null
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

successfulLogin = ->
  Ember.$.mockjax url: "#{config.apiNamespace}/users/sign_in.json", type: 'POST', status: 201, responseText: userFixture()
  Ember.$.mockjax url: "#{config.apiNamespace}/current_user", responseText: userFixture()
  Ember.$.mockjax url: "#{config.apiNamespace}/locales/en", responseText: localeFixture()

test "Inline errors are shown on inline error response", ->
  expect 2

  Ember.$.mockjax url: "#{config.apiNamespace}/users/sign_in.json", type: 'POST', status: 500, responseText: inline_response

  visit('/login').then(
    ->
      triggerEvent(".login-button", "click")
      andThen ->
        ok $(".form-email").hasClass('errors'), 'Email has error class'
        ok $(".form-password").hasClass('errors'), 'Password has error class'
  )

# test "alert is shown on growl error response", ->
#   Ember.$.mockjax
#     url: "#{config.apiNamespace}/users/sign_in.json", type: 'POST', status: 500, responseText: general_error_response
#
#   visit('/login').then(
#     ->
#       triggerEvent(".login-button", "click")
#       andThen -> assertAlertPresent()
#   )

test "sets up colors on login", ->
  expect 1

  visit('/login').then ->
    fillIn(".form-email input", "test@test.com")
    fillIn(".form-password input", "abc123")
    successfulLogin()
    triggerEvent(".login-button", "click")

    andThen -> ok Em.isPresent(window.treatmentColors), "has some treatmentColors"

test "sets up colors when already logged in", ->
  expect 1

  successfulLogin()
  visit('/').then ->
    ok Em.isPresent(window.treatmentColors), "has some treatmentColors"