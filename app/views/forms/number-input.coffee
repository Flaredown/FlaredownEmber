`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "number"
  min:  "0"
  step: "1"
  willValidate: false

  templateName: "forms/text-input"
  classNames: ["number-input"]
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]
  attributeBindings: ["min", "step", "willValidate"]


`export default view`