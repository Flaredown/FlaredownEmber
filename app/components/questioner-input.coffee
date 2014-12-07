`import Ember from 'ember'`

component = Ember.Component.extend
  layoutName: Ember.computed(->
    "questioner/_#{@get("question.kind")}_input"
  ).property()

  value: Ember.computed( ->
    @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name")).get("value")
  ).property("question")

  actions:
    sendResponse: (value) -> @sendAction("action", @get("question.name"), value)

`export default component`