`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

`import entryFixture from "../fixtures/entry-fixture"`

App        = null
controller = null
fixture    = null

moduleFor("controller:graph/checkin", "Check-In Controller",
  {
    needs: ["controller:graph"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      fixture     = entryFixture()

      controller.reopen { transitionToRoute: -> }                          # stub stupid observer throwing null error on transitionToRoute. Works fine in integration.

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

  ok controller.get("sections.length") is (1 + 1 + 5 + 1 + 1 + 1 + 1 + 1)   , "start + foo + hbi + conditions + symptoms + treatments + notes + finish"
  ok controller.get("sections.firstObject.category") is "start"         , "first section is 'start'"
  ok controller.get("sections")[1].category is "foo"                    , "should be alphabetical, 'foo' before 'hbi'"
  ok controller.get("sections.firstObject.selected") is true
  ok controller.get("sections.lastObject.selected") is false

test "#sectionsSeen are tracked", ->
  expect 4

  deepEqual controller.get("sectionsSeen"), [1]

  controller.set("section", 2)
  deepEqual controller.get("sectionsSeen"), [1,2]
  ok controller.get("sections")[1].seen is true, "sections in sectionsSeen are seen"
  ok controller.get("sections")[3].seen is false, "sections not in sectionsSeen are not seen"

test "#hasCompleteResponse looks up response completeness by catalog and category", ->
  expect 5

  ok controller.hasCompleteResponse("hbi",0) is false,  "select response missing so incomplete"
  ok controller.hasCompleteResponse("hbi",1) is true,   "select response exists so is complete"
  ok controller.hasCompleteResponse("hbi",3) is true,   "checkboxes are complete even though some responses are missing"

  controller.set("sectionsSeen", [1,2,3,4])
  ok controller.get("sections")[2].complete is false,  "hbi_general_wellbeing response missing, so incomplete"
  ok controller.get("sections")[3].complete is true,   "hbi_ab_pain response exists, is complete"

test "skipped sections are tracked", ->
  expect 2


  controller.set("sectionsSeen", [1,2,3,4])
  controller.set("section", 5)

  ok controller.get("sections")[2].skipped is true,  "hbi_general_wellbeing response missing but section seen so is 'skipped'"
  ok controller.get("sections")[3].skipped is false,  "hbi_ab_pain response exists and seen so isn't 'skipped'"

test "all sections are seen unless Entry is 'just_created'", ->
  expect 4

  Ember.run ->
    controller.set("just_created", false)

    ok controller.get("sections")[1].skipped is true,     "hbi_general_wellbeing response missing but section seen so is 'skipped'"
    ok controller.get("sections")[2].skipped is false,    "hbi_ab_pain response exists and seen so isn't 'skipped'"
    ok controller.get("sections")[1].complete is false,   "hbi_general_wellbeing response missing, so incomplete"
    ok controller.get("sections")[2].complete is true,    "hbi_ab_pain response exists, is complete"

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

  deepEqual controller.get("categories"), ["start", "foo", "hbi", "conditions", "symptoms", "treatments", "notes", "finish"]

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

  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "ab_pain").get("value") is 1, "sets proper value for included response"
  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "complication_arthralgia").get("value") is 0, "defaults to 0 for boolean"

test "action#setResponse sets a value for a response given the current context", ->
  expect 2

  Ember.$.mockjax url: "#{config.apiNamespace}/entries/*", type: 'PUT', responseText: entryFixture("Aug-13-2014")

  Ember.run -> controller.set("section", 6) # hbi complications section

  # Ambiguous with multiple section questions... using as test case
  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "complication_uveitis").get("value") is 1, "should start 0"

  Ember.run ->
    controller.send("setResponse", "complication_uveitis", 2)
    ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "complication_uveitis").get("value") is 2, "sets to 1 (true)"
