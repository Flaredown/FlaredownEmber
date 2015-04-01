`import Ember from 'ember'`

mixin = Ember.Mixin.create
  # Takes a "name" when instantiated
  # Assumes the controller has validations and errors based on that name.

  init: ->
    @_super()

    Em.defineProperty @, "errors", Em.computed( ->
      @get("controller.errors.fields.#{@get("name")}")
    ).property("controller.errors.fields.#{@get("name")}")

  inputClass: Ember.computed(-> "form-#{@get("name").dasherize()}")

  valueName: Ember.computed(-> "controller.#{@get("name")}" ).property("name")
  value: Ember.computed(-> @get(@get("valueName")) ).property("controller","valueName")

  valueObserver: Ember.observer(-> @set("controller.#{@get("name")}", @get("value")) ).observes("value")

  present: Ember.computed(-> Ember.isPresent(@get("value")) ).property("value")
  isValid: Ember.computed(-> @get("controller.#{@get("name")}Valid")).property("value")
  hasErrors: Ember.computed(-> Ember.isPresent(@get("errors")) ).property("errors")

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

`export default mixin`
