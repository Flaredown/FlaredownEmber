`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`
`import formHandlerMixin from '../../mixins/form_handler'`

view = Ember.View.extend colorableMixin, formHandlerMixin,
  editing: false
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  colorClass: Ember.computed(-> @colorClasses("treatments_#{@get("name")}", "treatment").bg ).property("name")

  fields: "name quantity unit".w()
  requirements: "name quantity unit".w()
  validations:  "quantity".w()

  quantityValid: (-> /^\d+$/.test(@get("quantity")) ).property("quantity")

  actions:
    toggleActive: (treatment) -> treatment.toggleProperty("active")

    edit: -> @set("editing", true)
    destroy: (treatment) ->
      swal
        title: "Are you sure?",
        text: Ember.I18n.t("confirm_treatment_remove", treatment: treatment.get("name"))
        type: "warning"
        showCancelButton: true
        closeOnConfirm: true
        =>
          @get("controller").send("removeTreatment", treatment)

    add: (treatment) ->
      @get("controller").send("addTreatment", treatment.getProperties("name", "quantity", "unit"))

    save: ->
      if @saveForm()
        @set("active", true)
        @set("editing", false)
        @get("controller").send("treatmentEdited")
        @endSave()


`export default view`