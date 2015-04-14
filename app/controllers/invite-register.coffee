`import Ember from 'ember'`
`import FormHandlerMixin from '../mixins/form_handler'`
`import RegisterFormMixin from '../mixins/register_form'`

controller = Ember.ObjectController.extend FormHandlerMixin, RegisterFormMixin
`export default controller`
