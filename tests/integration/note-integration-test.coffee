`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`
`import graphFixture from "../fixtures/graph-fixture"`
`import localeFixture from "../fixtures/locale-fixture"`

App = null

module('Note Integration Tests', {
  setup: ->
    Ember.$.mockjax
      url: "#{config.apiNamespace}/current_user",
      responseText: {
        current_user: {
          id: 1,
          email: "test@test.com",
          locale: "en"
        }
      }

    Ember.$.mockjax
      url: "#{config.apiNamespace}/locales/en",
      responseText: localeFixture

    Ember.$.mockjax
      url: "#{config.apiNamespace}/graph",
      responseText: graphFixture()

    Ember.$.mockjax
      url: "#{config.apiNamespace}/entries",
      type: 'POST'
      # data:
      #   date: "Aug-13-2014"
      responseText: entryFixture("Aug-13-2014")

    App = startApp()
  teardown: ->
    Ember.run(App, App.destroy);
    $.mockjax.clear();
})

test "Shows up", ->
  expect 1

  visit("/checkin/Aug-13-2014/10").then ->
    ok Ember.isPresent find(".checkin-note h4")

test "Clears placeholder on focus", ->
  expect 2

  visit("/checkin/Aug-13-2014/10").then ->
    ok $(".checkin-note-textarea").text() is "Use #hashtags to mark triggers on the graph", "has placeholder when unfocused"

    Ember.run.once ->
      range = document.createRange();
      sel   = window.getSelection();
      range.selectNodeContents($(".checkin-note-textarea")[0]);
      sel.removeAllRanges();
      sel.addRange(range);


    andThen ->
      Ember.run.later(
        -> ok $(".checkin-note-textarea").text() is "", "goes away when focused"
        400
      )

# test "Tags them tags", ->
#   expect 1
#
#   visit("/checkin/Aug-13-2014/10").then ->
#     Ember.run.next ->
#       $(".checkin-note-textarea").text("A #tag goes here")
#
#     view.keyUp()
#     andThen ->
#       console.log $(".checkin-note-textarea").html()
#       ok $(".checkin-note-textarea").html() is "A <a span='hashtag'>#tag</a> goes here!", "Writes tag html"
