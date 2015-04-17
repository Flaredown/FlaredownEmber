`import Ember from 'ember'`
`import AccountFormMixin from '../../mixins/account_form'`

controller = Ember.Controller.extend AccountFormMixin,

  translationRoot: "onboarding"
  isOnboarding: true

`export default controller`