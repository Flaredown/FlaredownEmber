`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`
`import formHandlerMixin from '../../mixins/form_handler'`

view = Ember.View.extend colorableMixin, formHandlerMixin,
  editing: false
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

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

  quantityValid: (-> /^([0-9]*[1-9][0-9]*(\.[0-9]+)?|[0]*\.[0-9]*[1-9][0-9]*)$/.test(@get("quantity")) ).property("quantity")

  willDestroyElement: -> @get("controller").send("addTreatment", @getProperties("id", "name", "quantity", "unit")) if @get("active") and @get("inactiveList")
  didInsertElement: -> @set("content.active", true) unless @get("inactiveList")

  actions:
    toggleActive: (treatment) -> @get("controller").send("toggleTreatment", treatment)

    destroy: (treatment) ->
      swal
        title: "Are you sure?",
        text: Ember.I18n.t("confirm_treatment_remove", treatment: treatment.get("name"))
        type: "warning"
        showCancelButton: true
        closeOnConfirm: true
        => @get("controller").send("removeTreatment", treatment)

`export default view`