`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  editing: false

  actions:
    edit: -> @set("editing", true)
    destroy: (treatment) ->

      swal
        title: "Are you sure?",
        text: Ember.I18n.t("#{@get("controller.currentUser.locale")}.confirm_treatment_remove", treatment: treatment.get("name"))
        type: "warning"
        showCancelButton: true
        # confirmButtonColor: "#DD6B55"
        # confirmButtonText: "Yes, delete it!"
        closeOnConfirm: true
        =>
          @get("controller.treatments").removeObject treatment
          treatment.unloadRecord()

    add: (treatment) ->
      @get("controller").send("treatmentAdded", treatment.getProperties("name", "quantity", "unit"))

    save: ->
      @set("editing", false)
      @get("controller").send("treatmentEdited")


`export default view`