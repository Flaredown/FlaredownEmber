`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "radio"
  templateName: "forms/radio-input"
  classNames: ["radio-input"]
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]

  options: Em.computed(->
    @get("controller.#{@get("name")}Options").map (item) =>
      checked = item is @get("value")
      {
        name: Ember.I18n.t "#{@get("optionI18nKey")}.#{item}"
        checked: checked
        class: "radio-option #{if checked then 'checked' else 'unchecked'} form-#{@get("name").dasherize()}-option-#{item.dasherize()}"
        value: item
      }
  ).property("controller", "value")

  actions:
    set: (value) -> @set "value", value

`export default view`