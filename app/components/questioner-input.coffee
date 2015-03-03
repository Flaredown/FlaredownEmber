`import Ember from 'ember'`
`import colorableMixin from '../mixins/colorable'`

component = Ember.Component.extend colorableMixin,
  questionName: Ember.computed(-> "#{@get("currentUser.locale")}.catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name", "section.category")

  layoutName: Ember.computed(-> "questioner/_#{@get("question.kind")}_input" ).property("question.kind")
  simplifiedQuestion: Ember.computed(-> ["symptoms", "conditions"].contains(@get("section.category")) ).property("section.category")
  hasValue: Ember.computed(-> typeof(@get("value")) is "number" )

  inputs: Ember.computed(->
    uniq_name = "#{@get("section.category")}_#{@get("question.name")}"


    @get("question.inputs").map (input) =>
      preselected = @get("hasValue") and input.value <= @get("value")

      value: input.value
      preselection: preselected
      selected: input.value is @get("value")
      label: if input.label then Ember.I18n.t("#{@get("currentUser.locale")}.labels.#{input.label}") else false
      color: if preselected then @colorClasses(uniq_name, "symptom").bg

  ).property("question.inputs", "value", "question.name", "section.category")

  value: Ember.computed( ->
    question = @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name"))
    if question then question.get("value") else null
  ).property("question", "section.category", "responses.@each")

  checked: Ember.computed( -> @get("value") > 0.0 ).property("value")

  actions:
    toggleBoolean: (value) ->
      @set "value", if value is 0 then 1.0 else 0.0
      @sendAction "action", @get("question.name"), @get("value")
    sendResponse: (value) ->
      @propertyWillChange("value")
      value = parseFloat(value)
      @sendAction("action", @get("question.name"), value)
      @propertyDidChange("value")

`export default component`