`import Ember from 'ember'`
`import FormInputMixin from '../../mixins/form_input'`

view = Ember.View.extend

  errorSource: "controller.errors"
  templateName: "forms/errors"

  errors: Em.computed( -> @get(@get("errorsSource")) ).property("errorsSource", "controller.errors")

`export default view`