# `import config from '../../config/environment'`
# `import Ember from "ember"`
# `import DS from 'ember-data'`
# `import { test, moduleFor } from "ember-qunit"`
# `import startApp from "../helpers/start-app"`
#
#
# `import graphFixture from "../fixtures/graph-fixture"`
#
# App        = null
# view       = null
# controller = null
# fixture    = null
#
# moduleFor("view:questioner/note", "Note View",
#   {
#     setup: ->
#       App         = startApp()
#       # controller  = App.__container__.lookup("controller:graph")
#       view        = @subject()
#
#       view.reopen { setContent: -> } # don't need to actually render HTML
#     teardown: ->
#       Ember.run(App, App.destroy);
#       $.mockjax.clear();
#   }
# )
#
# test "Creates hashtag html from entered text", ->
#   expect 1
#
#   view.set "value", "some #hashtag here"
#   ok view.hashtaggedContent() is "some <a class='hashtag current'>#hashtag</a> here"
#
# test "Removes <a> when tag becomes invalid (too short or no #)", ->
#   expect 3
#
#   view.set "value", "some <a class='hashtag'>#h</a> here"
#   ok view.hashtaggedContent() is "some #h here"
#
#   view.set "value", "some <a class='hashtag'>invalidhashtag</a> here"
#   ok view.hashtaggedContent() is "some invalidhashtag here"
#
#   view.set "value", "some <a class='hashtag'># hashtag</a> here"
#   ok view.hashtaggedContent() is "some # hashtag here"
#
# test "Joins hashtag existing tag and adjacent text", ->
#   expect 1
#
#   view.set "value", "some <a class='hashtag'>#hashtag</a>here and more!"
#   ok view.hashtaggedContent() is "some <a class='hashtag'>#hashtaghere</a> and more!"
#
# test "Splits hashtag on inserting invalid character", ->
#   expect 1
#
#   view.set "value", "some <a class='hashtag'>#hash tag</a> here"
#   ok view.hashtaggedContent() is "some <a class='hashtag'>#hash</a> tag here"
#
