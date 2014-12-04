`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App = null
controller = null

response = {
  'errors' : {
    'namespace' : 'inline',
    'fields' : {
      'name' : ['empty', 'invalid'],
      'email' : ['invalid']
      'phone' : ['empty']
    }
  }
}

moduleFor("controller:form-error", "FormError Controller",
  {
    needs: ["router:main"]

    setup: ->
      App = startApp()
      store = App.__container__.lookup("store:main")
      controller = @subject()
      controller.reopen { sectionChanged: -> }

      Ember.run ->
        controller.errorCallback(response)

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "errors are set", ->
  ok controller.get("errors") isnt null

test "error namespace is set", ->
  console.log controller.get("namespace")
  ok controller.get("namespace") is "inline"

test "response object contains fields", ->
  errors_keys = Object.keys(controller.get("errors"))
  ok errors_keys.contains ("fields")

test "fields object should not be empty", ->
  field_keys = Object.keys(controller.get("errors.fields"))
  ok field_keys.length > 0