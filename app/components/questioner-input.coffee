`import Ember from 'ember'`

component = Ember.Component.extend
  questionName: Ember.computed(-> "#{@get("currentUser.locale")}.catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name", "section.category")

  layoutName: Ember.computed(->
    "questioner/_#{@get("question.kind")}_input"
  ).property("question.kind")

  inputs: Ember.computed(->
    @get("question.inputs").map (input) =>
      value: input.value,
      selected: input.value is @get("value")
      label: if input.label then Ember.I18n.t("#{@get("currentUser.locale")}.labels.#{input.label}") else false

  ).property("question.inputs")

  value: Ember.computed( ->
    question = @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name"))
    if question then question.get("value") else null
  ).property("question", "section.category")

  actions:
    sendResponse: (value) ->
      value = parseFloat(value)
      @sendAction("action", @get("question.name"), value)

`export default component`