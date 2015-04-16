`import Ember from 'ember'`

view = Ember.View.extend
  action: "save"
  name: "save"

  tagName: "button"
  templateName: "forms/save-button"
  classNames: ["submit-button", "save-button", "btn-primary"]
  classNameBindings: ["buttonClass"]
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

  click: -> @send(@get("action")) unless @get("disabled")

`export default view`