`import ModalDialog from 'ember-modal-dialog/components/modal-dialog'`

component = ModalDialog.extend
  alignment: "none"
  setup: (->
    Ember.$('body').on 'keyup.modal-dialog', (e) =>
      @send("close") if e.keyCode == 27
  ).on('didInsertElement')

  teardown: (->
    Ember.$('body').off('keyup.modal-dialog')
  ).on('willDestroyElement')

  actions:
    close: ->
      if @get("parentView._actions.#{@get("close")}")# HACK! For allowing parent view to close modal
        @get("parentView").send(@get("close"))
      else
        @sendAction("close") # default to controller otherwise

`export default component`