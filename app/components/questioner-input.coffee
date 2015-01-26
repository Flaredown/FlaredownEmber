`import Ember from 'ember'`

component = Ember.Component.extend
  questionName: Ember.computed(-> "#{@get("currentUser.locale")}.catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name", "section.category")

  layoutName: Ember.computed(-> "questioner/_#{@get("question.kind")}_input" ).property("question.kind")
  symptomQuestion: Ember.computed.equal("section.category", "symptoms")

  inputs: Ember.computed(->
    uniq_name     = "#{@get("section.category")}_#{@get("question.name")}"
    color         = @get("controller.currentUser.symptomColors").find((color) => color[0] is uniq_name)
    color_number  = if color then color[1] else 0

    @get("question.inputs").map (input) =>
      selected = if @get("symptomQuestion")
        Ember.isPresent(@get("value")) and input.value <= @get("value")
      else
        input.value is @get("value")


      value: input.value,
      selected: selected
      label: if input.label then Ember.I18n.t("#{@get("currentUser.locale")}.labels.#{input.label}") else false
      color: if selected then "sselect-#{color_number}" else "sselect-faded-#{color_number}"

  ).property("question.inputs", "value", "controller.currentUser.symptomColors", "question.name", "section.category")

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