`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`


`import graphFixture from "../fixtures/graph-fixture"`

App        = null
view       = null
controller = null
fixture    = null

moduleFor("view:note", "Note View",
  {
    setup: ->
      App         = startApp()
      # controller  = App.__container__.lookup("controller:graph")
      view        = @subject()

      view.reopen { setContent: -> } # don't need to actually render HTML
    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)

test "Creates hashtag html from entered text", ->
  expect 1

  view.set "value", "some #hashtag here"
  ok view.get("hashtaggedContent") is "some <a class='hashtag'>#hashtag</a> here"