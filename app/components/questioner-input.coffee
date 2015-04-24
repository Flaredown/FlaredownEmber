`import Ember from 'ember'`
`import colorableMixin from '../mixins/colorable'`

component = Ember.Component.extend colorableMixin,
  questionName: Ember.computed(-> "catalogs.#{@get("section.category")}.#{@get("question.name")}").property("question.name", "section.category")

  layoutName: Ember.computed(-> "questioner/_#{@get("question.kind")}_input" ).property("question.kind")
  simplifiedQuestion: Ember.computed(-> ["symptoms", "conditions"].contains(@get("section.category")) ).property("section.category")
  hasValue: Ember.computed(-> typeof(@get("value")) is "number" )

  isBasic: Em.computed.equal("type", "basic")
  isCatalog: Em.computed.equal("type", "catalog")

  hoverValue: null
  hovering: Ember.computed(-> Em.isPresent(@get("hoverValue"))).property("hoverValue")

  inputs: Ember.computed(->
    uniq_name = "#{@get("section.category")}_#{@get("question.name")}"

    @get("question.inputs").map (input) =>
      current_value       = if @get("hasValue") then @get("value") else Infinity

      highlight_threshold = if @get("hovering") then @get("hoverValue") else current_value
      highlight           = (@get("hasValue") or @get("hovering")) and (input.value <= highlight_threshold)
      highlight           = if @get("isBasic") then highlight else false

      hovered             = @get("hoverValue") is input.value
      selected            = input.value is @get("value")
      special_first       = @get("isBasic") and input.value is 0

      value:      input.value
      selected:   selected
      highlight:  if (highlight or hovered) then true else false
      color:      if @get("section.category") is "conditions" then "bg-default" else @colorClasses(uniq_name, "symptom").bg

      label:      if input.label and not @get("isBasic") then Ember.I18n.t("labels.#{input.label}") else false
      meta_label: input.meta_label
      helper:     if input.helper then Ember.I18n.t("helpers.#{input.helper}") else false
      type:       @get("type")

      hide_color: special_first and (not hovered and not selected) or (not hovered and @get("hovering") and selected)

  ).property("question.inputs", "value", "question.name", "section.category", "hoverValue")

  value: Ember.computed( ->
    question = @get("responses").filterBy("catalog",@get("section.category")).findBy("name", @get("question.name"))
    if question then question.get("value") else null
  ).property("question", "section.category", "responses.@each")

  checked: Ember.computed( -> @get("value") > 0.0 ).property("value")

  didInsertElement: ->   @set "jBox", new jBox("Tooltip", {id: "jbox-tooltip", offset: {x:0, y:-40} , addClass: "trackable-input-tooltip", x: "center", y: "center", ignoreDelay: true, fade: false})
  willDestroyElement: -> @get("jBox").destroy()

  mouseEnter: -> @set("mouseOff", false)
  mouseLeave: ->
    @get("jBox").close()
    @set("hoverValue", null)
    @set("mouseOff", true)

  actions:
    setHover: (value) ->
      Ember.run.later(
        => @set("hoverValue", value) unless @get("mouseOff")
      , 50
      )

      if @get("hovering")
        input = @get("inputs").findBy("value", @get("hoverValue"))
        index = @get("inputs").indexOf(input)
        @get("jBox").setContent(input.helper).position({ target: @$("li:eq(#{index})") }).open() if input.helper

    toggleBoolean: (value) ->
      @set "value", if value is 0 then 1.0 else 0.0
      @sendAction "action", @get("question.name"), @get("value")
    sendResponse: (value) ->
      @propertyWillChange("value")
      value = parseFloat(value)
      @sendAction("action", @get("question.name"), value)
      @propertyDidChange("value")

`export default component`