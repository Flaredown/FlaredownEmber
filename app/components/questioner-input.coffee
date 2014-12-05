`import Ember from 'ember'`

component = Ember.Component.extend
  templateName: Ember.computed(->
    "questioner/_#{@get("question.kind")}_input"
  ).property()

  value: Ember.computed( ->
    @get("responses").filterBy("catalog",@get("section.catalog")).findBy("name", @get("question.name")).get("value")
  ).property("question")

  actions:
    sendResponse: (value) -> @sendAction("action", @get("question.name"), value)

`export default component`