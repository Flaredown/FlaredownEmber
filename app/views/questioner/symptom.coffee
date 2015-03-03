`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/_symptom_input"
  classNames: ["checkin-symptom"]

  actions:
    destroy: (symptom) ->
      swal
        title: "Are you sure?",
        text: Ember.I18n.t("#{@get("controller.currentUser.locale")}.confirm_symptom_remove", symptom: symptom.name)
        type: "warning"
        showCancelButton: true
        closeOnConfirm: true
        =>
          @get("controller").send("removeSymptom", symptom)


    add: (symptom) ->
      @get("controller").send("addSymptom", symptom.name)

    save: ->
      @set("editing", false)
      # @get("controller").send("symptomEdited")


`export default view`