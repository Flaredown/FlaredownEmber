`import Ember from 'ember'`

view = Ember.View.extend
  # Takes a "name" when instantiated
  # Assumes the controller has validations and errors based on that name.

  templateName: "forms/text-input"

  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]

  inputClass: Ember.computed(-> "form-#{@get("name").dasherize()}")

  valueName: Ember.computed(-> "controller.#{@get("name")}" ).property("name")
  value: Ember.computed(-> @get(@get("valueName")) ).property("controller","valueName")

  valueObserver: Ember.observer(-> @set("controller.#{@get("name")}", @get("value")) ).observes("value")

  present: Ember.computed(-> Ember.isPresent(@get("value")) ).property("value")
  isValid: Ember.computed(-> @get("controller.#{@get("name")}Valid")).property("value")
  errors: Ember.computed(-> @get("controller.errors.fields.#{@get("name")}") ).property("controller.errors.@each")
  hasErrors: Ember.computed(-> Ember.isPresent(@get("errors")) ).property("controller.errors")

  I18nKey: Ember.computed(->
    root = @get("translationRoot")
    root ||= @get("controller.translationRoot")
    root
  ).property("translationRoot")

  label: Ember.computed(->
    name = @get("name").underscore()
    key = if @get("I18nKey") then "#{@get("I18nKey")}.#{name}" else name
    Ember.I18n.t(key)
  ).property("I18nKey")


`export default view`