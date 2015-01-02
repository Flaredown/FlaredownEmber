`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`

App        = null
controller = null

moduleFor("controller:graph/checkin", "Check-In Controller",
  {
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = entryFixture()

      controller.reopen { sectionChanged: -> }                          # stub stupid observer throwing null error on transitionToRoute. Works fine in integration.

      Ember.run ->
        store.pushPayload "entry", fixture
        controller.set('model', store.find('entry', fixture.entry.id))

      controller.set("section", 1)                                      # Default to the first section, normally set by route

    teardown: ->
      Ember.run(App, App.destroy);
      $.mockjax.clear();
  }
)

### The Check-In ###
# Catalogs are loaded based on the `catalog_definitions` in the `Entry`.
# From there, "categories" and "sections" are generated to build a navigable form
# User action changes currentSection and currentCategory which controls the display
# of the form.

# Category: a supersection of the Check-In, such as a catalog (e.g. HBI), treatments or notes
# Section: a particular "page" of the entire Check-In that is navigable by URL

# sectionQuestions are generated for the categories that are associated with a catalog
# this is used to build the form

# responsesData data is built up based on user input and any pre-existing responses in the `Entry`

test "Catalog definitions are loaded up correctly", ->
  expect 2

  ok controller.get("catalogs.length") is 2
  ok Object.keys(controller.get("catalog_definitions"))[0] is "hbi"

test "Generates #sections from catalog_definitions", ->
  expect 5

  ok controller.get("sections.length") is (1 + 1 + 5 + 1 + 1 + 1 + 1)   , "start + foo + hbi + symptoms + treatments + notes + finish"
  ok controller.get("sections.firstObject.category") is "start"         , "first section is 'start'"
  ok controller.get("sections")[1].category is "foo"                    , "should be alphabetical, 'foo' before 'hbi'"
  ok controller.get("sections.firstObject.selected") is true
  ok controller.get("sections.lastObject.selected") is false

test "#currentSection is set based on section integer", ->
  expect 7

  controller.set("section", 2)
  ok controller.get("currentSection").selected is true
  ok controller.get("currentSection").number is 2                       , "2nd section total"
  ok controller.get("currentSection").category_number is 1              , "1st in catalog"
  ok controller.get("currentSection").category is "foo"

  controller.set("section", 4)
  ok controller.get("currentSection").number is 4                       , "4rd section total"
  ok controller.get("currentSection").category_number is 2              , "2nd section in this catalog"
  ok controller.get("currentSection").category is "hbi"

test "#categories grabs all category names", ->
  expect 1

  deepEqual controller.get("categories"), ["start", "foo", "hbi", "symptoms", "treatments", "notes", "finish"]

test "#currentCategory gives the name of currentSection's category", ->
  expect 2

  ok controller.get("currentCategory") is "start"

  Ember.run -> controller.set("section", 3)
  ok controller.get("currentCategory") is "hbi"

test "#currentCategorySections grabs all sections for the currentCategory", ->
  expect 2

  ok controller.get("currentCategorySections.length") is 1 # foo

  Ember.run -> controller.set("section", 3)
  ok controller.get("currentCategorySections.length") is 5 # hbi

### QUESTIONS ###
test "#sectionQuestions returns question(s) based on section", ->
  expect 8

  controller.set("section", 2)
  questions = controller.get("sectionQuestions")
  ok Ember.typeOf(questions) is "array"

  question_keys = Object.keys(questions[0])
  ok question_keys.contains "name"
  ok question_keys.contains "kind"
  ok question_keys.contains "inputs"

  # For the select input kind
  input_keys = Object.keys(questions[0].inputs[0])
  ok input_keys.contains "value"
  ok input_keys.contains "label"
  ok input_keys.contains "meta_label"
  ok input_keys.contains "helper"

### RESPONSES ###
test "builds #responsesData on for all questions, including any existing response values", ->
  expect 2

  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "ab_pain").get("value") is 3, "sets proper value for included response"
  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "stools").get("value") is null, "doesn't set any value when no response present"

test "action#setResponse sets a value for a response given the current context", ->
  expect 2

  Ember.run -> controller.set("section", 6) # hbi complications section

  # Ambiguous with multiple section questions... using as test case
  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "complication_abscess").get("value") is null, "should start null"

  controller.send("setResponse", "complication_abscess", 1)
  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "complication_abscess").get("value") is 1, "sets to 1 (true)"