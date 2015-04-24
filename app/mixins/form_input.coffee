`import Ember from 'ember'`

mixin = Ember.Mixin.create
  # Takes a "name" when instantiated
  # Assumes the controller has validations and errors based on that name.

  errorsRoot: "controller.errors.fields"
  parentForm: false # if present, validates also at specified controller
  customLabel: false

  init: ->
    @_super()

    if @get("controller.modelClass")
      Em.defineProperty @, "errors", Em.computed( ->
        @get("#{@get("errorsRoot")}.#{@get("controller.modelClass")}.#{@get("name")}")
      ).property("#{@get("errorsRoot")}.#{@get("controller.modelClass")}.#{@get("name")}.@each")
    else
      Em.defineProperty @, "errors", Em.computed( ->
        @get("#{@get("errorsRoot")}.#{@get("name")}")
      ).property("#{@get("errorsRoot")}.#{@get("name")}.@each")

    @get("parentForm.subForms").addObject(@get("controller")) if @get("parentForm")

  didInsertElement: -> @set("value","") if @get("kind") is "text" and @get("value") is undefined

  # CSS Classes
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent", "rootClass"]
  rootClass: Ember.computed(-> "form-#{@get("name").dasherize()}")
  inputClass: Ember.computed(-> "form-#{@get("name").dasherize()}-input")

  # Value and properties
  valueName: Ember.computed(-> "controller.#{@get("name")}" ).property("name")
  value: Ember.computed(-> @get(@get("valueName")) ).property("controller","valueName")



  valueObserver: Ember.observer(-> @set("controller.#{@get("name")}", @get("value")) ).observes("value")

  present: Ember.computed(->

    if @get("kind") is "number" # special validity for number input types (they don't return a value when inputting word characters)
      el = $("##{@get("elementId")} input")[0]
      return true if el and el.validity and el.validity.badInput
    else
      Ember.isPresent(@get("value"))
  ).property("value")
  isValid: Ember.computed(->
    return true unless @get("controller.validations").contains(@get("name"))

    if @get("kind") is "number" # special validity for number input types (they don't return a value when inputting word characters)
      el = $("##{@get("elementId")} input")[0]
      return false if el and el.validity and not el.validity.valid
    else
      @get("controller.#{@get("name")}Valid")
  ).property("value")
  hasErrors: Ember.computed(-> Ember.isPresent(@get("errors")) ).property("errors")
  saving: Ember.computed.alias("controller.saving")
  disabled: Ember.computed.alias("controller.saving")

  # Translations
  i18nKey: Ember.computed(->
    root = @get("translationRoot")
    root ||= @get("controller.translationRoot")
    root
  ).property("translationRoot")

  optionI18nKey: Em.computed( ->
    name = @get("name").underscore()
    root = if (typeof(@get("optionsTranslationRoot")) isnt "undefined") then @get("optionsTranslationRoot") else @get("i18nKey")
    key  = if root then "#{root}.#{name}_options" else "#{name}_options"
  ).property("name", "i18nKey")

  label: Ember.computed(->
    return @get("customLabel") if @get("customLabel")
    name = @get("name").underscore()
    key = if @get("i18nKey") then "#{@get("i18nKey")}.#{name}" else name
    Ember.I18n.t(key)
  ).property("i18nKey")

  placeholderText: Ember.computed(->
    return @get("placeholder") if @get("placeholder")
    name = @get("name").underscore()
    key = "#{@get("i18nKey")}.#{name}_placeholder"
    if Ember.I18n.translations.get(key) then Ember.I18n.t(key) else ""
  ).property("i18nKey")

  keyUp: (e) ->
    @propertyDidChange("value") if @get("kind") is "number"

`export default mixin`

