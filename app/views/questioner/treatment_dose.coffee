`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`
`import formHandlerMixin from '../../mixins/form_handler'`

view = Ember.View.extend colorableMixin, formHandlerMixin,
  tagName: "li"
  templateName: "questioner/_treatment_dose_input"
  classNames: ["checkin-treatment-dose-li"]
  classNameBindings: ["colors.border"]

  editingChanged: Ember.observer ->
    unless @get("editing") # trying to stop editing...
      Ember.run.next =>
        unless @get("isDestroyed") or @get("isDestroying")
          # prevent errors on form by prefilling
          unless @get("hasDose")
            @set "quantity", @get("currentUser.settings.treatment_#{@get("name")}_quantity")
            @set "unit", @get("currentUser.settings.treatment_#{@get("name")}_unit")

          @set("editing", not @saveForm())
          @endSave()

  .observes("editing")

  colors: Ember.computed(->  @colorClasses("treatments_#{@get("name")}", "treatment") ).property("name")

  unitOptions: Em.computed(-> Em.I18n.translations.treatment_units ).property()

  fields: "name quantity unit".w()
  requirements: "name quantity unit".w()
  validations:  "quantity".w()

  id: Em.computed.alias("content.id")
  name: Em.computed.alias("content.name")
  quantity: Em.computed.alias("content.quantity")
  unit: Em.computed.alias("content.unit")
  active: Em.computed.alias("content.active")
  editing: Em.computed.alias("content.editing")
  hasDose: Em.computed.alias("content.hasDose")

  quantityValid: (-> /^([0-9]*[1-9][0-9]*(\.[0-9]+)?|[0]*\.[0-9]*[1-9][0-9]*)$/.test(@get("quantity")) ).property("quantity")

  actions:
    removeDose: -> @get("controller").send("removeTreatmentDose", @get("content"))
    toggleEdit: -> @toggleProperty("editing"); false;

`export default view`