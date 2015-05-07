`import Ember from 'ember'`
`import config from '../../config/environment'`
`import AccountFormMixin from '../../mixins/account_form'`

controller = Ember.Controller.extend AccountFormMixin,
  translationRoot: "onboarding"
  editing: false
  modalOpen: true

  modalChanged: Ember.observer ->
    unless @get("modalOpen")
      @set("editing", false)
      @transitionToRoute("graph")
      @set("modalOpen", true)
  .observes("modalOpen")

  actions:
    close: -> @set("modalOpen", false)
    edit: -> @set("editing", true)

`export default controller`