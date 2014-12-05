`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`
`import assetModalPresent from "../helpers/assert-modal-present"`


App = null

module('Login', {
  setup: -> App = startApp()
  teardown: -> Ember.run(App, App.destroy)
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

inlineErrors = ->

  data = {}
  data["v#{config.apiVersion}_user"] = {"email" : "abc" : "password" : "123"}
  Ember.$.mockjax
    url: "#{config.apiNamespace}/users/sign_in.json"
    type: 'POST'
    #data: data
    status: 500
    responseText: inline_response

test "Inline errors occured", ->
  inlineErrors()

  visit('/login').then(
    ->
      stop()
      $("#login-button").simulate("click")
      setTimeout(
        ->
          ok $("#email").closest('.form-group').hasClass('has-error')
          ok $("#password").closest('.form-group').hasClass('has-error')
          ok $("ul#email-messages li").length > 0
          ok $("ul#password-messages li").length > 0
      , 200)


  )