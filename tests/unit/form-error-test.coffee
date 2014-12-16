`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App = null
controller = null

inline_response = {
  'errors' : {
    'error_group' : 'inline',
    'fields' : {
      'name' : [
        {
          'type' : 'empty',
          'message' : 'Name cannot be Empty'
        }
      ],
      'email' : [
        {
          'type' : 'invalid',
          'message' : 'Email is invalid'
        }
      ]
      'phone' : [
        {
          'type' : 'invalid',
          'message' : 'Phone is invalid'
        },
        {
          'type' : 'length',
          'message' : 'Phone number should not exceed 11 characters'
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

moduleFor("controller:form-error", "FormError Controller",
  {
    setup: ->
      App = startApp()
      store = App.__container__.lookup("store:main")
      controller = @subject()

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "response for inline errors is ok", ->
  expect 4

  controller.errorCallback inline_response  #setup response for inline

  ok controller.get("errors") isnt null
  ok controller.get("error_group") is "inline"

  errors_keys = Object.keys(controller.get("errors"))
  ok errors_keys.contains ("fields")

  field_keys = Object.keys(controller.get("errors.fields"))
  ok field_keys.length > 0

test "response for modal is ok", ->
  expect 4

  controller.errorCallback(modal_response) #setup response for modal

  ok controller.get("errors") isnt null
  ok controller.get("error_group") is "modal"

  errors_keys = Object.keys(controller.get("errors"))

  ok errors_keys.contains ("title")
  ok errors_keys.contains ("message")

test "response for growl is ok", ->
  expect 4

  controller.errorCallback(growl_response) #setup response for growl

  ok controller.get("errors") isnt null
  ok controller.get("error_group") is "growl"

  errors_keys = Object.keys(controller.get("errors"))

  ok errors_keys.contains ("message")
  assertAlertPresent()