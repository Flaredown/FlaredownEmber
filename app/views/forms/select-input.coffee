`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "select"
  templateName: "forms/select-input"
  classNames: ["select-input"]
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]

  options: Em.computed(->
    @get("controller.#{@get("name")}Options").map (item,i) =>
      # select2 option format
      {
        id: item
        text: Ember.I18n.t "#{@get("optionI18nKey")}.#{item}"
      }
  ).property("controller", "value")

  placeholder: Em.computed( ->
    name = @get("name").underscore()
    key = if @get("i18nKey") then "#{@get("i18nKey")}.#{name}" else name
    Ember.I18n.t("#{key}_placeholder")
  ).property("i18nKey")

  actions:
    set: (value) -> @set "value", value

`export default view`