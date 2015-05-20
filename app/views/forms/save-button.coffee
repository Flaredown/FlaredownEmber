`import Ember from 'ember'`

view = Ember.View.extend
  action: "save"
  name: "save"

  alignment: "right"

  tagName: "button"
  templateName: "forms/save-button"
  classNames: ["btn-primary", ]
  classNameBindings: ["buttonClass", "alignment"]
  attributeBindings: ["type", "disabled"]

  type: "submit"
  buttonClass: Em.computed(-> "#{@get("name")}-button" ).property("name")
  disabled: Ember.computed.alias("controller.saving")

  i18nKey: Ember.computed(->
    root = @get("translationRoot")
    root ||= @get("controller.translationRoot")
    root
  ).property("translationRoot")

  text: Ember.computed(->
    name = if @get("name") then @get("name") else "forms.save"
    if Ember.I18n.translations.get(name) then Ember.I18n.t(name) else Ember.I18n.t("#{@get("i18nKey")}.#{name}")
  ).property("i18nKey")

  # This relies on form submit action currently
  # TODO: perhaps relying on the button is better? But both means double action firing
  # tap: -> @get("controller").send(@get("action")) unless @get("disabled")
  # click: -> @get("controller").send(@get("action")) unless @get("disabled")


`export default view`