`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend colorableMixin,
  tagName: "li"
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  active: Em.computed( -> @get("controller.treatments").filterBy("name", @get("name")).get("firstObject.active") ).property("controller.treatments.@each.active")
  doses: Em.computed(-> @get("controller.treatments").filterBy("name", @get("name")).filterBy("taken",true) ).property("controller.treatments.@each", "name")

  hasPriorSettings: Em.computed(-> @get("currentUser.settings.treatment_#{@get("name")}_1_quantity") ).property("name")
  priorSettingsLabel: Em.computed(->
    repetition = 1
    dosages = []
    until @get("currentUser.settings.treatment_#{@get("name")}_#{repetition}_quantity") is undefined
      dosages.push "#{@get("currentUser.settings.treatment_#{@get("name")}_#{repetition}_quantity")}#{@get("currentUser.settings.treatment_#{@get("name")}_#{repetition}_unit")}"
      repetition = repetition+1

    dosagesString = dosages.join(" + ")
    Ember.I18n.t("use_prior_settings_label", dosages: dosagesString)
  ).property("name")

  colors: Ember.computed(->  @colorClasses("treatments_#{@get("name")}") ).property("name")

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