`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


App = null

module('Login Errors', {
  setup: -> App = startApp()
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

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

modal_response = {
  'errors' : {
    'error_group' : 'modal',
    'title' : 'Some Error Occurred',
    'message' : 'We are sorry that some error occurred'
  }
}

growl_response = {
  'errors' : {
    'error_group' : 'growl',
    'title' : "Sorry, Your account isn't verified yet",
    'message' : "Check back later when your account will be verified by our admin",
    'type' : "error"
  }
}

inlineErrors = ->

  data = {}
  data["v#{config.apiVersion}_user"] = {"email" : "abc@abc.com" : "password" : "123"}
  Ember.$.mockjax
    url: "#{config.apiNamespace}/users/sign_in.json"
    type: 'POST'
    #data: data
    status: 500
    responseText: inline_response

modalErrors =->
  data = {}
  data["v#{config.apiVersion}_user"] = {"email" : "abc@abc.com" : "password" : "123"}
  Ember.$.mockjax
    url: "#{config.apiNamespace}/users/sign_in.json"
    type: 'POST'
  #data: data
    status: 500
    responseText: modal_response

growlErrors =->
  data = {}
  data["v#{config.apiVersion}_user"] = {"email" : "abc@abc.com" : "password" : "123"}
  Ember.$.mockjax
    url: "#{config.apiNamespace}/users/sign_in.json"
    type: 'POST'
  #data: data
    status: 500
    responseText: growl_response

test "Inline errors are shown on inline error response", ->
  expect 4
  inlineErrors()

  visit('/login').then(
    ->
      triggerEvent("#login-button", "click")
      andThen ->
        ok $("#email").closest('.form-group').hasClass('has-error'), 'Email has class "has-error"'
        ok $("#password").closest('.form-group').hasClass('has-error'), 'Password has class "has-error"'
        ok $("ul#email-messages li").length > 0, 'Email errors are listed'
        ok $("ul#password-messages li").length > 0, 'Password errors are listed'
  )


test "modal is shown on modal error response", ->
  expect 1
  modalErrors()

  visit('/login').then(
    ->
      triggerEvent("#login-button", "click")
      andThen -> assertModalPresent()
  )

test "alert is shown on growl error response", ->
  growlErrors()

  visit('/login').then(
    ->
      triggerEvent("#login-button", "click")
      andThen -> assertAlertPresent()
  )