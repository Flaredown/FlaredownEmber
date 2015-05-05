`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend colorableMixin,
  tagName: "li"
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  colorClass: Ember.computed(-> @colorClasses("treatments_#{@get("name")}", "treatment").bg ).property("name")

  active: Em.computed( -> @get("doses.firstObject.active") ).property("name", "doses.@each.active")
  doses: Em.computed(-> @get("controller.treatments").filterBy("name", @get("name"))  ).property("controller.treatments.@each", "name")

  actions:
    destroy: (treatment_name) ->
      swal
        title: "Are you sure?",
        text: Ember.I18n.t("confirm_treatment_remove", treatment: treatment_name)
        type: "warning"
        showCancelButton: true
        closeOnConfirm: true
        => @get("controller").send("removeTreatment", treatment_name)

`export default view`