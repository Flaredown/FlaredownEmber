`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import localeFixture from "../fixtures/locale-fixture"`
`import userFixture from "../fixtures/user-fixture"`

App = null

module('Register Integration Tests', {
  setup: ->
    App = startApp()
    null
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

# Registration currently disabled
# TODO reenable

# test "Shows invitee registration page using invite token", ->
#   expect 2
#
#   Ember.$.mockjax
#     url: "#{config.apiNamespace}/users/invitee/abc123",
#     type: 'GET'
#     responseText: {
#       id: 1,
#       email: "test@test.com",
#       invitation_token: "abc123"
#     }
#
#   visit('/accept-invitation/abc123').then(
#     ->
#       ok(find("#accept-invitation-button").length, "Accept Invite button shows up (opposed to register button)")
#       ok(find(".form-email").val(), "test@test.com")
#   )
#
# test "Invalid invite token gets 404 message", ->
#   expect 3
#
#   Ember.$.mockjax
#     url: "#{config.apiNamespace}/users/invitee/abc123-invalid-invite-token",
#     type: 'GET'
#     status: 404
#     responseText: {
#       error: "Not found."
#     }
#
#   visit('/accept-invitation/abc123-invalid-invite-token').then(
#     ->
#       ok(find(".navbar").length, "Page shows up")
#       ok(currentRouteName() == "login", "Rediected to login")
#       assertAlertPresent()
#   )