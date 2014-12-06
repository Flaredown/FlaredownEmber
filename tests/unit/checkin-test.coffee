`import config from '../../config/environment'`
`import Ember from "ember"`
`import DS from 'ember-data'`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App        = null
controller = null

entryFixture = ->
  id = (new Date).getTime() # crazy stuff for avoiding collisions in store which I *CANNOT* seem to clear
  {
    entry: {
      id: "#{id}",
      date: "Aug-13-2014",
      catalogs: ["hbi", "foo"],
      responses: [
        {
          id: "hbi_general_wellbeing_#{id}",
          name: "general_wellbeing",
          value: 2,
          catalog: "hbi"
        },
        {
          id: "hbi_ab_pain_#{id}",
          name: "ab_pain",
          value: 3
          catalog: "hbi"
        }
      ],
      catalog_definitions: {
        hbi: [
          [{
              name: "general_wellbeing", kind: "select",
              inputs: [
                { value: 0, label: "very_well", meta_label: "happy_face", helper: null},
                { value: 1, label: "slightly_below_par", meta_label: "neutral_face", helper: null},
                { value: 2, label: "poor", meta_label: "frowny_face", helper: null },
                { value: 3, label: "very_poor", meta_label: "sad_face", helper: null },
                { value: 4, label: "terrible", meta_label: "sad_face", helper: null }
              ]
          }],
          [{
              name: "ab_pain", kind: "select",
              inputs: [
                { value: 0, label: "none", meta_label: "happy_face", helper: null},
                { value: 1, label: "mild", meta_label: "neutral_face", helper: null},
                { value: 2, label: "moderate", meta_label: "frowny_face", helper: null},
                { value: 3, label: "severe", meta_label: "sad_face", helper: null}
              ]
          }],
          [{
              name: "stools", kind: "number",
              inputs: [ { value: 0, label: null, meta_label: null, helper: "stools_daily"} ]
          }],
          [{
              name: "ab_mass", kind: "select",
              inputs: [
                { value: 0, label: "none", meta_label: "happy_face", helper: null },
                { value: 1, label: "dubious", meta_label: "neutral_face", helper: null},
                { value: 2, label: "definite", meta_label: "frowny_face", helper: null},
                { value: 3, label: "definite_and_tender", meta_label: "sad_face", helper: null}
              ]
          }],
          [
            { name: "complication_arthralgia", kind: "checkbox"},
            { name: "complication_uveitis", kind: "checkbox"},
            { name: "complication_erythema_nodosum", kind: "checkbox"},
            { name: "complication_aphthous_ulcers", kind: "checkbox"},
            { name: "complication_anal_fissure", kind: "checkbox"},
            { name: "complication_fistula", kind: "checkbox"},
            { name: "complication_abscess", kind: "checkbox"}
          ]
        ],
        foo: [
          [{
              name: "how_fantastic_are_you", kind: "select",
              inputs: [
                { value: 0, label: "very_fantastic", meta_label: "happy_face", helper: null},
                { value: 1, label: "super_fantastic", meta_label: "happy_face", helper: null},
                { value: 2, label: "extra_fantastic", meta_label: "happy_face", helper: null },
                { value: 3, label: "crazy_fantastic", meta_label: "happy_face", helper: null },
              ]
          }]
        ]
      }
    }
  }


moduleFor("controller:entries/checkin", "Checkin Controller",
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


    teardown: -> Ember.run(App, App.destroy)
  }
)


test "Catalog definitions are loaded up correctly", ->
  expect 2

  ok controller.get("catalogs.length") is 2
  ok Object.keys(controller.get("catalog_definitions"))[0] is "hbi"

test "Generates #sections from catalog_definitions", ->
  expect 4

  ok controller.get("sections.length") is (5 + 1)                       # hbi + foo
  ok controller.get("sections.firstObject.category") is "foo"   # should be alphabetical, "foo" before "hbi"
  ok controller.get("sections.firstObject.selected") is true
  ok controller.get("sections.lastObject.selected") is false

test "#currentSection is set based on section integer", ->
  expect 7

  ok controller.get("currentSection").selected is true
  ok controller.get("currentSection").number is 1                       # 1st section total
  ok controller.get("currentSection").category_number is 1              # 1st in catalog, also
  ok controller.get("currentSection").category is "foo"

  controller.set("section", 3)
  ok controller.get("currentSection").number is 3                       # 3rd section total
  ok controller.get("currentSection").category_number is 2              # 2nd section in this catalog
  ok controller.get("currentSection").category is "hbi"

test "#categories grabs all category names", ->
  expect 1

  deepEqual controller.get("categories"), ["foo", "hbi"]

test "#currentCategory gives the name of currentSection's category", ->
  expect 2

  ok controller.get("currentCategory") is "foo"

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

  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "ab_pain").get("value") is 3
  ok controller.get("responsesData").filterBy("catalog", "hbi").findBy("name", "stools").get("value") is null
