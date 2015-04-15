`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend FormInputMixin,

  kind: "password"
  templateName: "forms/text-input"
  classNames: ["password-input"]
  classNameBindings: ["isValid:valid:invalid", "hasErrors:errors:no-errors", "present:present:absent"]

`export default view`