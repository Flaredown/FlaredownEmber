`import Ember from 'ember'`
`import colorableMixin from '../mixins/colorable'`

component = Ember.Component.extend colorableMixin,
  questionName: Ember.computed(-> "#{@get("currentUser.locale")}.catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name", "section.category")

  layoutName: Ember.computed(-> "questioner/_#{@get("question.kind")}_input" ).property("question.kind")
  simplifiedQuestion: Ember.computed(-> ["symptoms", "conditions"].contains(@get("section.category")) ).property("section.category")
  hasValue: Ember.computed(-> typeof(@get("value")) is "number" )

  hoverValue: null
  hovering: Ember.computed(-> Em.isPresent(@get("hoverValue"))).property("hoverValue")

  inputs: Ember.computed(->
    uniq_name = "#{@get("section.category")}_#{@get("question.name")}"

    @get("question.inputs").map (input) =>
      current_value       = if @get("hasValue") then @get("value") else Infinity
      highlight_threshold = if @get("hovering") then @get("hoverValue") else current_value
      highlight           = (@get("hasValue") or @get("hovering")) and (input.value <= highlight_threshold)

      value: input.value
      highlight: highlight
      selected: input.value is @get("value")
      label: if input.label and @get("type") isnt "basic" then Ember.I18n.t("#{@get("currentUser.locale")}.labels.#{input.label}") else false
      meta_label: input.meta_label
      helper: if input.helper then Ember.I18n.t("#{@get("currentUser.locale")}.helpers.#{input.helper}") else false
      color: if highlight then @colorClasses(uniq_name, "symptom").bg

  ).property("question.inputs", "value", "question.name", "section.category", "hoverValue")

  value: Ember.computed( ->
    question = @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name"))
    if question then question.get("value") else null
  ).property("question", "section.category", "responses.@each")

  checked: Ember.computed( -> @get("value") > 0.0 ).property("value")

  actions:
    setHover: (value) -> @set("hoverValue", value)
    toggleBoolean: (value) ->
      @set "value", if value is 0 then 1.0 else 0.0
      @sendAction "action", @get("question.name"), @get("value")
    sendResponse: (value) ->
      @propertyWillChange("value")
      value = parseFloat(value)
      @sendAction("action", @get("question.name"), value)
      @propertyDidChange("value")

`export default component`