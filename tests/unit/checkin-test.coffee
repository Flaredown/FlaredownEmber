`import config from '../../config/environment'`
`import Ember from "ember"`
`import { test, moduleFor } from "ember-qunit"`
`import startApp from "../helpers/start-app"`

App        = null
controller = null

entryFixture = {
  entry: {
    id: "fd088f9929639fd742a209b4b083c421",
    date: "Aug-13-2014",
    catalogs: [
      "hbi", "foo"
    ],
    catalog_definitions: {
      hbi: {
        general_wellbeing: [{
            name: "general_wellbeing", section: 0, kind: "select",
            inputs: [
              { value: 0, label: "very_well", meta_label: "happy_face", helper: null},
              { value: 1, label: "slightly_below_par", meta_label: "neutral_face", helper: null},
              { value: 2, label: "poor", meta_label: "frowny_face", helper: null },
              { value: 3, label: "very_poor", meta_label: "sad_face", helper: null },
              { value: 4, label: "terrible", meta_label: "sad_face", helper: null }
            ]
        }],
        ab_pain: [{
            name: "ab_pain", section: 1, kind: "select",
            inputs: [
              { value: 0, label: "none", meta_label: "happy_face", helper: null},
              { value: 1, label: "mild", meta_label: "neutral_face", helper: null},
              { value: 2, label: "moderate", meta_label: "frowny_face", helper: null},
              { value: 3, label: "severe", meta_label: "sad_face", helper: null}
            ]
        }],
        stools: [{
            name: "stools", section: 2, kind: "number",
            inputs: [ { value: 0, label: null, meta_label: null, helper: "stools_daily"} ]
        }],
        ab_mass: [{
            name: "ab_mass", section: 3, kind: "select",
            inputs: [
              { value: 0, label: "none", meta_label: "happy_face", helper: null },
              { value: 1, label: "dubious", meta_label: "neutral_face", helper: null},
              { value: 2, label: "definite", meta_label: "frowny_face", helper: null},
              { value: 3, label: "definite_and_tender", meta_label: "sad_face", helper: null}
            ]
        }],
        complications: [
          { name: "complication_arthralgia", section: 4, kind: "checkbox"},
          { name: "complication_uveitis", section: 4, kind: "checkbox"},
          { name: "complication_erythema_nodosum", section: 4, kind: "checkbox"},
          { name: "complication_aphthous_ulcers", section: 4, kind: "checkbox"},
          { name: "complication_anal_fissure", section: 4, kind: "checkbox"},
          { name: "complication_fistula", section: 4, kind: "checkbox"},
          { name: "complication_abscess", section: 4, kind: "checkbox"}
        ]
      },
      foo: {
        how_fantastic_are_you:  [{
            name: "how_fantastic_are_you", section: 0, kind: "select",
            inputs: [
              { value: 0, label: "very_fantastic", meta_label: "happy_face", helper: null},
              { value: 1, label: "super_fantastic", meta_label: "happy_face", helper: null},
              { value: 2, label: "extra_fantastic", meta_label: "happy_face", helper: null },
              { value: 3, label: "crazy_fantastic", meta_label: "happy_face", helper: null },
            ]
        }]
      }
    }
  }
}


moduleFor("controller:entries/checkin", "Checkin Controller",
  {
    needs: ["router:main"]
    setup: ->
      App         = startApp()
      store       = App.__container__.lookup("store:main")
      controller  = @subject()
      controller.reopen { sectionChanged: -> } # stub stupid observer throwing null error on transitionToRoute. Works fine in integration.

      Ember.run ->
        store.pushPayload "entry", entryFixture
        controller.set('model', store.find('entry', entryFixture.entry.id))

    teardown: -> Ember.run(App, App.destroy)
  }
)

test "Catalog definitions are loaded up correctly", ->
  expect 2
  ok controller.get("catalogs.length") is 2
  ok Object.keys(controller.get("catalog_definitions"))[0] is "hbi"

test "Generates #sections from catalog_definitions", ->
  expect 4

  ok controller.get("sections.length") is (5 + 1)             # hbi + foo
  ok controller.get("sections.firstObject.catalog") is "foo"  # should be alphabetical, "foo" before "hbi"
  ok controller.get("sections.firstObject.selected") is true
  ok controller.get("sections.lastObject.selected") is false

test "#currentSection is set based on section integer", ->
  expect 7

  ok controller.get("currentSection").selected is true
  ok controller.get("currentSection").number is 1           # 1st section total
  ok controller.get("currentSection").catalog_section is 1  # 1st in catalog, also
  ok controller.get("currentSection").catalog is "foo"

  controller.set("section", 3)
  ok controller.get("currentSection").number is 3           # 3rd section total
  ok controller.get("currentSection").catalog_section is 2  # 2nd section in this catalog
  ok controller.get("currentSection").catalog is "hbi"

test "#sectionQuestions returns question(s) based on section", ->
  expect 8

  questions = controller.get("sectionQuestions")
  ok Ember.typeOf(questions) is "array"

  question_keys = Object.keys(questions[0])
  ok question_keys.contains "name"
  ok question_keys.contains "kind"
  ok question_keys.contains "inputs"

  input_keys = Object.keys(questions[0].inputs[0])
  ok input_keys.contains "value"
  ok input_keys.contains "label"
  ok input_keys.contains "meta_label"
  ok input_keys.contains "helper"

