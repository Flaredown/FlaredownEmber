`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import graphFixture from "../fixtures/graph-fixture"`
`import userFixture from "../fixtures/user-fixture"`

App         = null
controller  = null
fixture     = null

moduleFor("controller:onboarding.account", "Form Handler Mixin Test",
  {
    needs: []
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()

      Ember.run ->
        controller.set "model",       {}

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)


test "saving without valid inputs triggers inline validation errors", ->
  expect 6

  controller.set("requirements", ["dobDay"])
  controller.set("validations", ["dobDay"])
  controller.saveForm()

  ok controller.get("errors.kind") is "inline"              , "has correct error group"
  ok controller.get("errors.fields.dobDay.length") > 0      , "has field errors"
  ok controller.get("errors.fields.dobDay.firstObject.kind") is "required"

  Ember.run ->
    controller.set("dobDay", "111")
    controller.saveForm()

  ok controller.get("errors.fields.dobDay.length") > 0      , "has field errors"
  ok controller.get("errors.fields.dobDay.firstObject.kind") is "invalid"

  Ember.run ->
    controller.set("dobDay", "11")
    controller.saveForm()

  ok controller.get("errors.fields.dobDay") is null       , "no more errors"

test "changing a field removes any errors on it", ->
  controller.set("requirements", ["dobDay"])
  controller.set("validations", ["dobDay"])
  controller.saveForm()

  ok controller.get("errors.fields.dobDay.length") is 1      , "has field errors"

  Ember.run ->
    controller.set("dobDay", "111superinvalid")

  ok controller.get("errors.fields.dobDay.length") is 0      , "still has field errors"
