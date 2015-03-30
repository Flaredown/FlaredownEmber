`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "switch"
  templateName: "forms/switch-input"
  classNames: ["switch-input"]
  classNameBindings: ["hasErrors:errors:no-errors"]

  switchId: Ember.computed.alias("inputClass")

  checked: Ember.computed( -> @get("value") > 0.0 ).property("value")
  actions:
    toggleBoolean: (value) ->
      @set "value", if value is 0 then 1.0 else 0.0

`export default view`