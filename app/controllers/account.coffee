`import Ember from 'ember'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../../mixins/form_handler'`
`import AccountFormMixin from '../../mixins/account_form'`

controller = Ember.Controller.extend FormHandlerMixin, AccountFormMixin,

  editing: false
  modalOpen: true
  modalChanged: Ember.observer ->
    unless @get("modalOpen")
      @set("editing", false)
      @transitionToRoute("graph")
      @set("modalOpen", true)
  .observes("modalOpen")

  translationRoot: "onboarding"

  actions:
    edit: -> @set("editing", true)
    save: ->
      if @saveForm()
        ajax("#{config.apiNamespace}/me.json",
          type: "POST"
          data: {settings: @getProperties(@get("fields"))}
        ).then(
          (response) =>
            @set("editing", false)
            @endSave()
          @errorCallback.bind(@)
        )
      else
        false

`export default controller`