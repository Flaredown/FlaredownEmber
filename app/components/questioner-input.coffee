`import Ember from 'ember'`

component = Ember.Component.extend
  questionName: Ember.computed(-> "#{@get("currentUser.locale")}.catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name")

  layoutName: Ember.computed(->
    "questioner/_#{@get("question.kind")}_input"
  ).property()

  value: Ember.computed( ->
    @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name")).get("value")
  ).property("question")

  actions:
    sendResponse: (value) ->
      value = parseFloat(value)
      @sendAction("action", @get("question.name"), value)

`export default component`