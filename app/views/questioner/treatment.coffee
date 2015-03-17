`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend colorableMixin,

  tagName: "div"
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  colorClass: Ember.computed(-> @colorClasses("treatments_#{@get("name")}", "treatment").bg ).property("name")

  editing: false

  actions:
    toggleActive: (treatment) -> treatment.toggleProperty("active")

    edit: -> @set("editing", true)
    destroy: (treatment) ->
      swal
        title: "Are you sure?",
        text: Ember.I18n.t("#{@get("controller.currentUser.locale")}.confirm_treatment_remove", treatment: treatment.get("name"))
        type: "warning"
        showCancelButton: true
        closeOnConfirm: true
        =>
          @get("controller").send("removeTreatment", treatment)

    add: (treatment) ->
      @get("controller").send("addTreatment", treatment.getProperties("name", "quantity", "unit"))

    save: ->
      @set("active", true)
      @set("editing", false)
      @get("controller").send("treatmentEdited")


`export default view`