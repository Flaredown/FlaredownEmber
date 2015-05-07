`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`
`import formHandlerMixin from '../../mixins/form_handler'`

view = Ember.View.extend colorableMixin, formHandlerMixin,
  tagName: "li"
  templateName: "questioner/_treatment_dose_input"
  classNames: ["checkin-treatment-dose"]

  # modalOpen: true
  editingChanged: Ember.observer ->
    unless @get("editing") # trying to stop editing...
      Ember.run.next =>
        @set("editing", not @saveForm())
        @endSave()
  .observes("editing")

  unitOptions: Em.computed(-> Em.I18n.translations.treatment_units ).property()

  colorClass: Ember.computed(-> @colorClasses("treatments_#{@get("name")}", "treatment").bg ).property("name")

  fields: "name quantity unit".w()
  requirements: "name quantity unit".w()
  validations:  "quantity".w()

  id: Em.computed.alias("content.id")
  name: Em.computed.alias("content.name")
  quantity: Em.computed.alias("content.quantity")
  unit: Em.computed.alias("content.unit")
  active: Em.computed.alias("content.active")
  editing: Em.computed.alias("content.editing")

  quantityValid: (-> /^([0-9]*[1-9][0-9]*(\.[0-9]+)?|[0]*\.[0-9]*[1-9][0-9]*)$/.test(@get("quantity")) ).property("quantity")

  actions:
    removeDose: -> @get("controller").send("removeTreatmentDose", @get("content"))
    toggleEdit: -> @toggleProperty("editing"); false;

`export default view`