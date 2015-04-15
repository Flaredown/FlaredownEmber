`import Ember from 'ember'`
`import FormHandlerMixin from '../mixins/form_handler'`
`import RegisterFormMixin from '../mixins/register_form'`

controller = Ember.Controller.extend FormHandlerMixin, RegisterFormMixin
`export default controller`