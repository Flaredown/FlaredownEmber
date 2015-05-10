`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend colorableMixin,
  tagName: "li"
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  # colorClass: Ember.computed(-> @colorClasses("treatments_#{@get("name")}", "treatment").bg ).property("name")

  active: Em.computed( -> @get("controller.treatments").filterBy("name", @get("name")).get("firstObject.active") ).property("controller.treatments.@each.active")
  doses: Em.computed(-> @get("controller.treatments").filterBy("name", @get("name")).filterBy("hasDose",true) ).property("controller.treatments.@each.hasDose", "name")
  colors: Ember.computed(->  @colorClasses("treatments_#{@get("name")}", "treatment") ).property("name")

  actions:
    remove: (treatment_name) ->
      @set("controller.lastSave", false)
      @get("controller").send("removeTreatment", treatment_name)

    destroy: (treatment_name) ->
      if @get("controller.isPast")
        @send("remove", treatment_name)
      else
        swal
          title: "Are you sure?",
          text: Ember.I18n.t("confirm_treatment_remove", treatment: treatment_name)
          type: "warning"
          showCancelButton: true
          closeOnConfirm: true
          => @send("remove", treatment_name)


`export default view`