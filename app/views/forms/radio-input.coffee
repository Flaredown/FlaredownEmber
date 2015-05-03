`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "radio"
  templateName: "forms/radio-input"
  classNames: ["radio-input"]
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]

  options: Em.computed(->
    optionKey = Ember.I18n.translations.get("#{@get("optionI18nKey")}")
    options = Ember.keys(optionKey) if optionKey
    options ||= @get("controller.#{@get("name")}Options")
    options ||= []

    options.map (item) =>
      {
        name: Ember.I18n.t "#{@get("optionI18nKey")}.#{item}"
        class: "radio-option form-#{@get("name").dasherize()}-option-#{item.dasherize()}"
        value: item
      }
  ).property("controller", "value")

  actions:
    set: (value) -> @set "value", value unless @get("disabled")

`export default view`