`import ModalDialog from 'ember-modal-dialog/components/modal-dialog'`

component = ModalDialog.extend
  setup: (->
    Ember.$('body').on 'keyup.modal-dialog', (e) => @get("parentView").send(@get("close")) if e.keyCode == 27
  ).on('didInsertElement')

  teardown: (->
    Ember.$('body').off('keyup.modal-dialog')
  ).on('willDestroyElement')

`export default component`