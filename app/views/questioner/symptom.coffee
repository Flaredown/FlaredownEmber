`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/_symptom_input"
  classNames: ["checkin-symptom"]

  actions:
    remove: (symptom) ->
      @set("controller.lastSave", false)
      @get("controller").send("removeSymptom", symptom)

    destroy: (symptom) ->
      if @get("controller.isPast")
        @send("remove", symptom)
      else
        swal
          title: "Are you sure?",
          text: Ember.I18n.t("confirm_symptom_remove", symptom: symptom.name)
          type: "warning"
          showCancelButton: true
          closeOnConfirm: true
          => @send("remove", symptom)

    add: (symptom) ->
      @set("controller.lastSave", false)
      @get("controller").send("addSymptom", symptom.name)

    save: ->
      @set("editing", false)
      # @get("controller").send("symptomEdited")


`export default view`