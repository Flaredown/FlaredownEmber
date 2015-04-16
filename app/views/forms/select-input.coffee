`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "select"
  templateName: "forms/select-input"
  classNames: ["select-input"]
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]

  options: Em.computed(->
    options = Ember.keys(Ember.I18n.translations.get("#{@get("optionI18nKey")}")) if Ember.I18n.translations.get("#{@get("optionI18nKey")}")
    options ||= @get("controller.#{@get("name")}Options")
    options.map (item,i) =>
      # select2 option format
      option = {
        id: item
        text: Ember.I18n.t "#{@get("optionI18nKey")}.#{item}"
      }
      option.description = Ember.I18n.translations.get("#{@get("optionI18nKey")}_descriptions")[i] if @get("descriptions")
      option

  ).property("controller", "value")

  placeholder: Em.computed( ->
    key = if @get("i18nKey") then "#{@get("i18nKey")}.#{name}" else @get("name").underscore()
    placeholder = Ember.I18n.t("#{key}_placeholder")
    if placeholder.match(/missing translation/i) then Ember.I18n.t(key) else placeholder
  ).property("i18nKey")

`export default view`