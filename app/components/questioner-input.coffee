`import Ember from 'ember'`
`import colorableMixin from '../mixins/colorable'`

component = Ember.Component.extend colorableMixin,
  questionName: Ember.computed(-> "#{@get("currentUser.locale")}.catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name", "section.category")

  layoutName: Ember.computed(-> "questioner/_#{@get("question.kind")}_input" ).property("question.kind")
  simplifiedQuestion: Ember.computed(-> ["symptoms", "conditions"].contains(@get("section.category")) ).property("section.category")
  hasValue: Ember.computed(-> typeof(@get("value")) is "number" )

  isBasic: Em.computed.equal("type", "basic")
  isCatalog: Em.computed.equal("type", "catalog")

  hoverValue: null
  hovering: Ember.computed(-> Em.isPresent(@get("hoverValue"))).property("hoverValue")
  jBox: new jBox("Tooltip", {id: "jbox-tooltip", x: "center", y: "center",ignoreDelay: true})

  inputs: Ember.computed(->
    uniq_name = "#{@get("section.category")}_#{@get("question.name")}"

    @get("question.inputs").map (input) =>
      current_value       = if @get("hasValue") then @get("value") else Infinity
      highlight_threshold = if @get("hovering") then @get("hoverValue") else current_value
      highlight           = (@get("hasValue") or @get("hovering")) and (input.value <= highlight_threshold)
      highlight           = if @get("isBasic") then highlight else false

      value: input.value
      selected: input.value is @get("value")
      label: if input.label and not @get("isBasic") then Ember.I18n.t("#{@get("currentUser.locale")}.labels.#{input.label}") else false
      meta_label: input.meta_label
      helper: if input.helper then Ember.I18n.t("#{@get("currentUser.locale")}.helpers.#{input.helper}") else false
      color: if (highlight or input.value is @get("hoverValue")) then @colorClasses(uniq_name, "symptom").bg

  ).property("question.inputs", "value", "question.name", "section.category", "hoverValue")

  value: Ember.computed( ->
    question = @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name"))
    if question then question.get("value") else null
  ).property("question", "section.category", "responses.@each")

  checked: Ember.computed( -> @get("value") > 0.0 ).property("value")

  willDestroyElement: -> @get("jBox").destroy()

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